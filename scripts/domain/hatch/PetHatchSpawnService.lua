-- __BreedingDemolisher__/scripts/domain/hatch/PetHatchSpawnService.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Hatch による pet demolisher spawn を行い、
--   genetics を適用し、pet 登録と destroyed tracking を設定する。
--
-- Scope:
--   - hatch spawn
--   - genetics apply
--   - pet_id 発行
--   - storage.my_demolishers 登録
--   - register_on_object_destroyed 登録
--
-- Notes:
--   - Wild Reproduction 用 spawn ではない。
--   - Interaction / Hatch 専用 service として扱う。
--   - pet chart job enqueue は上位オーケストレーション側責務。
--   - storage shape は bootstrap 済み前提で扱い、この層では自動生成しない。
-- ------------------------------------------------------------
local SpawnClampPolicy = require("scripts.domain.hatch.SpawnClampPolicy")
local DemolisherParamsFactory = require("scripts.domain.pet.DemolisherParamsFactory")
local CONST_DEMOLISHER_PARAMETER = require("scripts.defines.constant_demolisher_parameters")

local PetHatchSpawnService = {}

local function expect_storage_shape()
  if storage == nil then
    error("PetHatchSpawnService: storage is nil")
  end
  if storage.my_demolishers == nil then
    error("PetHatchSpawnService: storage.my_demolishers is nil. Call StorageBootstrap.bootstrap() first.")
  end
  if storage.bd_next_pet_id == nil then
    error("PetHatchSpawnService: storage.bd_next_pet_id is nil. Call StorageBootstrap.bootstrap() first.")
  end
  if storage.bd == nil then
    error("PetHatchSpawnService: storage.bd is nil. Call StorageBootstrap.bootstrap() first.")
  end
  if storage.bd.pet_destroy_reg_to_pet_id == nil then
    error("PetHatchSpawnService: storage.bd.pet_destroy_reg_to_pet_id is nil. Call StorageBootstrap.bootstrap() first.")
  end
  if storage.bd.pet_id_to_destroy_reg == nil then
    error("PetHatchSpawnService: storage.bd.pet_id_to_destroy_reg is nil. Call StorageBootstrap.bootstrap() first.")
  end
end

local function new_pet_id()
  expect_storage_shape()
  local id = storage.bd_next_pet_id
  storage.bd_next_pet_id = id + 1
  return "P" .. tostring(id)
end

local function register_pet_destroy_tracking(entity, pet_id)
  if entity == nil or entity.valid == false then
    error("PetHatchSpawnService.register_pet_destroy_tracking: valid entity is required")
  end
  if type(pet_id) ~= "string" or pet_id == "" then
    error("PetHatchSpawnService.register_pet_destroy_tracking: pet_id must be a non-empty string")
  end

  expect_storage_shape()

  local registration_number = script.register_on_object_destroyed(entity)
  storage.bd.pet_destroy_reg_to_pet_id[registration_number] = pet_id
  storage.bd.pet_id_to_destroy_reg[pet_id] = registration_number

  return registration_number
end

function PetHatchSpawnService.spawn_from_throw(player, egg, customparam)
  expect_storage_shape()

  local surface = player.surface
  local entity_name = egg.resolve_size(egg.item_name)
  local force = egg.resolve_force(egg.item_name, player)
  local spawn_position = egg.compute_spawn_position(player)

  local safe_pos = surface.find_non_colliding_position(entity_name, spawn_position, 16, 0.5) or spawn_position

  local spawn = nil
  if customparam ~= nil then
    spawn = SpawnClampPolicy.compute_spawn_values({
      entity_name = entity_name,
      size = customparam.size,
      speed = customparam.speed,
      quality = customparam.quality,
      max_life = customparam.max_life,
      max_growth = customparam.max_growth,
      max_satiety = customparam.max_satiety,
      traits = customparam.traits,
    })
  end

  local entity = surface.create_entity({
    name = entity_name,
    position = safe_pos,
    force = force,
    quality = (spawn and spawn.quality_name) or egg.quality_name,
  })

  if not (entity and entity.valid) then
    if player ~= nil and player.valid then
      player.print("No space to hatch here.")
    end
    return nil
  end

  if customparam ~= nil then
    customparam.entity = entity
    if spawn then
      customparam.entity_name = entity_name
      customparam.size = spawn.size
      customparam.speed = spawn.speed
      customparam.max_life = spawn.max_life
      customparam.life = spawn.max_life
      customparam.max_growth = spawn.max_growth
      customparam.max_satiety = spawn.max_satiety
      customparam.satiety = spawn.max_satiety
    end
  end

  local pet_id = new_pet_id()
  local destroyed_registration_number = register_pet_destroy_tracking(entity, pet_id)

  local home_surface_name = entity.surface.name
  local home_pos = { x = entity.position.x, y = entity.position.y }

  table.insert(storage.my_demolishers, {
    pet_id = pet_id,
    home_surface_name = home_surface_name,
    home_pos = home_pos,
    linked_unit_number = entity.unit_number,
    born_tick = game.tick,
    destroyed_registration_number = destroyed_registration_number,

    surface = entity.surface,
    entity_name = entity.name,
    force = entity.force,
    unit_number = entity.unit_number,

    customparam = customparam or DemolisherParamsFactory.new_randomized({
      entity = entity,
      entity_name = entity_name,
      max_growth = CONST_DEMOLISHER_PARAMETER.DEFAULT_MAX_GROWTH,
      max_satiety = CONST_DEMOLISHER_PARAMETER.DEFAULT_MAX_SATIETY,
      born_tick = game.tick,
    })
  })

  return entity
end

return PetHatchSpawnService