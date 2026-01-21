-- __BreedingDemolisher__/scripts/services/DemolisherSpawnService.lua
-- ----------------------------
-- Responsibility:
--   Spawn demolisher entity for hatch, apply genetics, register as pet,
--   and enqueue chart job for the pet safe area.
-- ----------------------------
local PetChartJobService = require("scripts.services.PetChartJobService")
local SpawnClampPolicy = require("scripts.domain.genetics.SpawnClampPolicy")

local S = {}

local function ensure_pet_id_seq()
  storage.bd_next_pet_id = storage.bd_next_pet_id or 1
end

local function new_pet_id()
  ensure_pet_id_seq()
  local id = storage.bd_next_pet_id
  storage.bd_next_pet_id = id + 1
  return "P" .. tostring(id)
end

function S.spawn_from_throw(player, egg, customparam)
  storage.my_demolishers = storage.my_demolishers or {}

  local surface = player.surface
  local entity_name = egg.resolve_size(egg.item_name)
  local force = egg.resolve_force(egg.item_name, player)
  local spawn_position = egg.compute_spawn_position(player)

  local safe_pos = surface.find_non_colliding_position(entity_name, spawn_position, 16, 0.5) or spawn_position

  -- If genetic payload exists, derive spawn-time safe values (clamps + quality_name).
  -- Otherwise, keep legacy behavior (egg.quality_name etc.).
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
    -- Align stored params with spawn-time clamps.
    -- (Genetic values remain the source; this just ensures consistency for runtime usage.)
    if spawn then
      customparam.entity_name = entity_name
      customparam.size = spawn.size
      customparam.speed = spawn.speed
      customparam.max_life = spawn.max_life
      customparam.life = spawn.max_life
      customparam.max_growth = spawn.max_growth
      customparam.max_satiety = spawn.max_satiety
      -- traits are kept as genetic payload; expression is handled at spawn/use time.
      -- If you later introduce runtime "expressed_traits", hook it here.
    end
  end

  local pet_id = new_pet_id()
  local home_surface_name = entity.surface.name
  local home_pos = { x = entity.position.x, y = entity.position.y }

  table.insert(storage.my_demolishers, {
    -- --- stable identity (v0.5.5+)
    pet_id = pet_id,
    home_surface_name = home_surface_name,
    home_pos = home_pos,
    linked_unit_number = entity.unit_number, -- current link (may break later)
    born_tick = game.tick,

    -- --- legacy/compat fields (keep for now)
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

return S