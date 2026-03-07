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
--   - pet chart job enqueue
--
-- Notes:
--   - Wild Reproduction 用 spawn ではない。
--   - Interaction / Hatch 専用 service として扱う。
-- ------------------------------------------------------------
local PetChartJobService = require("scripts.services.PetChartJobService")
local SpawnClampPolicy = require("scripts.domain.hatch.SpawnClampPolicy")

local PetHatchSpawnService = {}

local function ensure_storage()
  storage.my_demolishers = storage.my_demolishers or {}
  storage.bd_next_pet_id = storage.bd_next_pet_id or 1

  storage.bd = storage.bd or {}
  storage.bd.pet_destroy_reg_to_pet_id = storage.bd.pet_destroy_reg_to_pet_id or {}
  storage.bd.pet_id_to_destroy_reg = storage.bd.pet_id_to_destroy_reg or {}
end

local function new_pet_id()
  ensure_storage()
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

  ensure_storage()

  local registration_number = script.register_on_object_destroyed(entity)
  storage.bd.pet_destroy_reg_to_pet_id[registration_number] = pet_id
  storage.bd.pet_id_to_destroy_reg[pet_id] = registration_number

  return registration_number
end

function PetHatchSpawnService.spawn_from_throw(player, egg, customparam)
  ensure_storage()

  local surface = player.surface
  local entity_name = egg.resolve_size(egg.item_name)
  local force = egg.resolve_force(egg.item_name, player)
  local spawn_position = egg.compute_spawn_position(player)

  local safe_pos = surface.find_non_colliding_position(entity_name, spawn_position, 16, 0.5) or spawn_position

  local spawn = nil
  if customparam ~= nil then
    spawn = SpawnClampPolicy.compute_spawn_values({
      entity_name = entity_name,
      size = customparam:get_size(),
      speed = customparam:get_speed(),
      quality = customparam:get_quality(),
      max_life = customparam:get_max_life(),
      max_growth = customparam:get_max_growth(),
      max_satiety = customparam:get_max_satiety(),
      traits = customparam:get_traits(),
    })
  end

  local entity = surface.create_entity({
    name = entity_name,
    position = safe_pos,
    force = force,
    quality = (spawn and spawn.quality_name) or egg.quality_name,
  })

  if not (entity and entity.valid) then
    game.print("No space to hatch here.")
    return false
  end

  -- 1280x1280 => radius 640 tiles
  PetChartJobService.enqueue(entity.surface, entity.position, player.force.name, 640)

  if customparam ~= nil then
    customparam:set_entity(entity)
    if spawn then
      customparam.entity_name = entity_name
      customparam.size = spawn.size
      customparam.speed = spawn.speed
      customparam.max_life = spawn.max_life
      customparam.life = spawn.max_life
      customparam.max_growth = spawn.max_growth
      customparam.max_satiety = spawn.max_satiety
    end
  end

  local pet_id = new_pet_id()
  local destroyed_registration_number = register_pet_destroy_tracking(entity, pet_id)

  local home_surface_name = entity.surface.name
  local home_pos = { x = entity.position.x, y = entity.position.y }

  table.insert(storage.my_demolishers, {
    -- stable identity
    pet_id = pet_id,
    home_surface_name = home_surface_name,
    home_pos = home_pos,
    linked_unit_number = entity.unit_number,
    born_tick = game.tick,
    destroyed_registration_number = destroyed_registration_number,

    -- legacy / compat fields
    surface = entity.surface,
    entity_name = entity.name,
    force = entity.force,
    unit_number = entity.unit_number,

    customparam = customparam or Customparam.new(
      entity,
      entity_name,
      nil, nil, nil, nil, nil,
      CONST_DEMOLISHER_PARAMETER.DEFAULT_MAX_GROWTH,
      CONST_DEMOLISHER_PARAMETER.DEFAULT_MAX_SATIETY,
      nil,
      game.tick
    )
  })

  return true
end

return PetHatchSpawnService