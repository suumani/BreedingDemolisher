-- __BreedingDemolisher__/scripts/application/pet_breeding/PetBreedingExecutionService.lua
-- ------------------------------------------------------------
-- Responsibility:
--   1 pet 分の Pet Breeding execution を実行する。
--
-- Scope:
--   - step_index -> pet_id 解決
--   - pet 解決
--   - breeding evaluation
--   - 卵生成
--   - notification
--   - breeding chance 消費(stage 更新)
--
-- Notes:
--   - hatch は行わない
--   - population cap は hatch 時に適用する
--   - partner 不在時は parthenogenesis を行う
--   - storage.my_demolishers は辞書 table を許容する
--   - 実行結果は ResultDTO で返す
--   - storage shape は bootstrap 済み前提で扱い、この層では自動生成しない
-- ------------------------------------------------------------
local PetBreedingExecutionService = {}

local PetBreedingPlanStore = require("scripts.infrastructure.runtime.PetBreedingPlanStore")
local PetBreedingEvaluator = require("scripts.domain.pet_breeding.PetBreedingEvaluator")
local GeneticsMutator = require("scripts.domain.genetics.GeneticsMutator")
local EggDropService = require("scripts.application.hatch.EggDropService")
local NotificationService = require("scripts.boundary.notification.NotificationService")
local QualityUtil = require("scripts.util.QualityUtil")
local CONST_ITEM_NAME = require("scripts.defines.constant_item_name")

local function dto_ok(reason, detail)
  return {
    ok = true,
    result = "OK",
    reason = reason,
    detail = detail,
  }
end

local function dto_skip(reason, detail)
  return {
    ok = true,
    result = "SKIP",
    reason = reason,
    detail = detail,
  }
end

local function expect_storage_shape()
  if storage == nil then
    error("PetBreedingExecutionService: storage is nil")
  end
  if storage.my_demolishers == nil then
    error("PetBreedingExecutionService: storage.my_demolishers is nil. Call StorageBootstrap.bootstrap() first.")
  end
end

local function resolve_pet_by_id(pet_id)
  if type(pet_id) ~= "string" or pet_id == "" then
    error("PetBreedingExecutionService.resolve_pet_by_id: pet_id must be a non-empty string")
  end

  expect_storage_shape()

  local pets = storage.my_demolishers
  for _, pet in pairs(pets) do
    if type(pet) == "table" and pet.pet_id == pet_id then
      return pet
    end
  end

  return nil
end

local function decide_egg_item_name_by_force_name(force_name)
  if force_name == "enemy" then
    return CONST_ITEM_NAME.DEMOLISHER_EGG
  elseif force_name == "demolishers" then
    return CONST_ITEM_NAME.NEW_SPIECES_DEMOLISHER_EGG
  else
    return CONST_ITEM_NAME.FRIEND_DEMOLISHER_EGG
  end
end

local function create_parthenogenesis_customparam(subject_cp, subject_force_name)
  return GeneticsMutator.mutate_to_child(subject_cp, subject_force_name, nil)
end

local function create_reproduction_customparam(subject_cp, subject_force_name, partner_cp)
  return GeneticsMutator.mutate_to_child(subject_cp, subject_force_name, partner_cp)
end

local function emit_egg(subject_entity, child_force_name, egg_customparam)
  if subject_entity == nil or subject_entity.valid == false then
    error("PetBreedingExecutionService.emit_egg: valid subject_entity is required")
  end
  if egg_customparam == nil then
    error("PetBreedingExecutionService.emit_egg: egg_customparam is required")
  end

  local item_name = decide_egg_item_name_by_force_name(child_force_name or subject_entity.force.name)
  local item_quality = QualityUtil.to_item_quality_name(egg_customparam.quality)

  NotificationService.breeding_egg_laid(subject_entity.surface, subject_entity.position)
  EggDropService.drop_egg(
    subject_entity.surface,
    subject_entity.position,
    item_name,
    item_quality,
    egg_customparam
  )
end

local function consume_breeding_chance(subject_pet, current_stage)
  if subject_pet == nil then
    error("PetBreedingExecutionService.consume_breeding_chance: subject_pet is required")
  end
  if type(current_stage) ~= "number" then
    error("PetBreedingExecutionService.consume_breeding_chance: current_stage must be a number")
  end

  subject_pet.last_breed_stage = current_stage
end

function PetBreedingExecutionService.execute_step(step_index)
  if type(step_index) ~= "number" then
    error("PetBreedingExecutionService.execute_step: step_index must be a number")
  end

  expect_storage_shape()

  local entry = PetBreedingPlanStore.get_entry(step_index)
  if entry == nil then
    return dto_skip("PET_BREEDING_EXECUTION:NO_ENTRY", {
      step_index = step_index,
    })
  end

  local pet = resolve_pet_by_id(entry.pet_id)
  if pet == nil then
    return dto_skip("PET_BREEDING_EXECUTION:PET_NOT_FOUND", {
      step_index = step_index,
      pet_id = entry.pet_id,
    })
  end

  local pets = storage.my_demolishers
  local evaluated = PetBreedingEvaluator.evaluate(pet, pets)

  if evaluated.result == PetBreedingEvaluator.RESULT_IMMATURE then
    return dto_skip("PET_BREEDING_EXECUTION:IMMATURE", {
      step_index = step_index,
      pet_id = entry.pet_id,
    })
  end

  if evaluated.result == PetBreedingEvaluator.RESULT_NO_NEW_CHANCE then
    return dto_skip("PET_BREEDING_EXECUTION:NO_NEW_CHANCE", {
      step_index = step_index,
      pet_id = entry.pet_id,
    })
  end

  local subject_pet = evaluated.subject_pet
  local subject_cp = evaluated.subject_cp
  local subject_entity = evaluated.subject_entity
  local current_stage = evaluated.current_stage

  if subject_pet == nil or subject_cp == nil or subject_entity == nil or current_stage == nil then
    return dto_skip("PET_BREEDING_EXECUTION:EVALUATION_INCOMPLETE", {
      step_index = step_index,
      pet_id = entry.pet_id,
      has_subject_pet = subject_pet ~= nil,
      has_subject_cp = subject_cp ~= nil,
      has_subject_entity = subject_entity ~= nil,
      has_current_stage = current_stage ~= nil,
    })
  end

  local child_force_name = subject_entity.force and subject_entity.force.name or "player"
  local egg_customparam

  if evaluated.result == PetBreedingEvaluator.RESULT_PARTHENOGENESIS then
    egg_customparam = create_parthenogenesis_customparam(subject_cp, child_force_name)
  elseif evaluated.result == PetBreedingEvaluator.RESULT_REPRODUCTION then
    egg_customparam = create_reproduction_customparam(subject_cp, child_force_name, evaluated.partner_cp)
  else
    error("PetBreedingExecutionService.execute_step: unknown breeding result")
  end

  emit_egg(subject_entity, child_force_name, egg_customparam)
  consume_breeding_chance(subject_pet, current_stage)

  return dto_ok("PET_BREEDING_EXECUTION:EXECUTED", {
    step_index = step_index,
    pet_id = entry.pet_id,
    breeding_result = evaluated.result,
    child_force_name = child_force_name,
  })
end

return PetBreedingExecutionService