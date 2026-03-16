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
-- ------------------------------------------------------------
local PetBreedingExecutionService = {}

local PetBreedingPlanStore = require("scripts.infrastructure.runtime.PetBreedingPlanStore")
local PetBreedingEvaluator = require("scripts.domain.pet_breeding.PetBreedingEvaluator")
local GeneticsMutator = require("scripts.domain.genetics.GeneticsMutator")
local EggDropService = require("scripts.services.EggDropService")
local NotificationService = require("scripts.services.NotificationService")
local QualityUtil = require("scripts.util.QualityUtil")
local CONST_ITEM_NAME = require("scripts.defines.constant_item_name")

local function resolve_pet_by_id(pet_id)
  if type(pet_id) ~= "string" or pet_id == "" then
    error("PetBreedingExecutionService.resolve_pet_by_id: pet_id must be a non-empty string")
  end

  local pets = storage.my_demolishers or {}
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
  local child = GeneticsMutator.mutate_to_child(subject_cp, subject_force_name, nil)
  return child
end

local function create_reproduction_customparam(subject_cp, subject_force_name, partner_cp)
  local child = GeneticsMutator.mutate_to_child(subject_cp, subject_force_name, partner_cp)
  return child
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

--- execute_step
--- Responsibility:
---   step_index に対応する 1 pet 分の execution を行う。
--- @param step_index uint
function PetBreedingExecutionService.execute_step(step_index)
  if type(step_index) ~= "number" then
    error("PetBreedingExecutionService.execute_step: step_index must be a number")
  end

  local entry = PetBreedingPlanStore.get_entry(step_index)
  if entry == nil then
    return
  end

  local pet = resolve_pet_by_id(entry.pet_id)
  if pet == nil then
    return
  end

  local pets = storage.my_demolishers or {}
  local evaluated = PetBreedingEvaluator.evaluate(pet, pets)

  if evaluated.result == PetBreedingEvaluator.RESULT_IMMATURE then
    return
  end

  if evaluated.result == PetBreedingEvaluator.RESULT_NO_NEW_CHANCE then
    return
  end

  local subject_pet = evaluated.subject_pet
  local subject_cp = evaluated.subject_cp
  local subject_entity = evaluated.subject_entity
  local current_stage = evaluated.current_stage

  if subject_pet == nil or subject_cp == nil or subject_entity == nil or current_stage == nil then
    return
  end

  local child_force_name = subject_entity.force and subject_entity.force.name or "player"
  local egg_customparam = nil

  if evaluated.result == PetBreedingEvaluator.RESULT_PARTHENOGENESIS then
    egg_customparam = create_parthenogenesis_customparam(subject_cp, child_force_name)
  elseif evaluated.result == PetBreedingEvaluator.RESULT_REPRODUCTION then
    egg_customparam = create_reproduction_customparam(subject_cp, child_force_name, evaluated.partner_cp)
  else
    error("PetBreedingExecutionService.execute_step: unknown breeding result")
  end

  emit_egg(subject_entity, child_force_name, egg_customparam)
  consume_breeding_chance(subject_pet, current_stage)
end

return PetBreedingExecutionService