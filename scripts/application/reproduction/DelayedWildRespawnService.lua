-- __BreedingDemolisher__/scripts/application/reproduction/DelayedWildRespawnService.lua
-- ------------------------------------------------------------
-- Responsibility:
--   期限到来した delayed wild respawn queue を処理する。
--   - due entry を取得する。
--   - chunk から territory を再解決する。
--   - enemy demolisher を segmented unit として再スポーンする。
--   - quality を再抽選する。
--   - observability log を出力する。
--
-- Notes:
--   - territory が再解決できない entry は skip する。
--   - segmented unit の生成は LuaSurface.create_segmented_unit を使用する。
--   - quality は enemy evolution factor と deterministic random に基づき再抽選する。
--   - spawn position には撃破時に保存した座標を使用する。
-- ------------------------------------------------------------
local DelayedWildRespawnService = {}

local Logger = require("scripts.infrastructure.logging.Logger")
local DelayedWildRespawnQueueStore = require("scripts.infrastructure.runtime.DelayedWildRespawnQueueStore")
local DeterministicRandom = require("scripts.core.services.DeterministicRandom")
local QualityRoller = require("scripts.domain.reproduction.QualityRoller")

local function resolve_territory(surface, chunk_x, chunk_y)
  if surface == nil or surface.valid == false then
    return nil
  end
  if type(chunk_x) ~= "number" or type(chunk_y) ~= "number" then
    return nil
  end

  return surface.get_territory_for_chunk({
    x = chunk_x,
    y = chunk_y,
  })
end

local function get_enemy_evolution_factor(surface)
  local enemy_force = game.forces["enemy"]
  if enemy_force == nil then
    error("DelayedWildRespawnService: game.forces['enemy'] is not available")
  end
  return enemy_force.get_evolution_factor(surface)
end

local function resolve_quality_id_from_steps(quality_steps)
  if quality_steps == 0 then
    return "normal"
  elseif quality_steps == 1 then
    return "uncommon"
  elseif quality_steps == 2 then
    return "rare"
  elseif quality_steps == 3 then
    return "epic"
  elseif quality_steps == 4 then
    return "legendary"
  end

  error("DelayedWildRespawnService.resolve_quality_id_from_steps: unsupported quality_steps=" .. tostring(quality_steps))
end

local function resolve_respawn_quality_id(surface)
  local evolution_factor = get_enemy_evolution_factor(surface)
  local roll_value = DeterministicRandom.random()
  local quality_steps = QualityRoller.choose_quality_steps(evolution_factor, roll_value)
  local quality_id = resolve_quality_id_from_steps(quality_steps)

  return quality_id, evolution_factor, roll_value, quality_steps
end

local function is_valid_position(position)
  return type(position) == "table"
    and type(position.x) == "number"
    and type(position.y) == "number"
end

local function spawn_segmented_unit(surface, territory, entity_name, position, quality_id)
  if surface == nil or surface.valid == false then
    return nil
  end
  if territory == nil or territory.valid == false then
    return nil
  end
  if type(entity_name) ~= "string" or entity_name == "" then
    return nil
  end
  if is_valid_position(position) ~= true then
    return nil
  end
  if type(quality_id) ~= "string" or quality_id == "" then
    return nil
  end

  return surface.create_segmented_unit{
    name = entity_name,
    force = "enemy",
    territory = territory,
    position = {
      x = position.x,
      y = position.y,
    },
    quality = quality_id,
  }
end

local function process_due_entry(entry)
  local surface = game.surfaces[entry.surface_name]
  if surface == nil or surface.valid == false then
    Logger.warn({
      event = "BD_DELAYED_WILD_RESPAWN_SKIP",
      reason = "SURFACE_UNAVAILABLE",
      surface_name = entry.surface_name,
      entity_name = entry.entity_name,
      due_tick = entry.due_tick,
    })
    return
  end

  local territory = resolve_territory(surface, entry.chunk_x, entry.chunk_y)
  if territory == nil then
    Logger.warn({
      event = "BD_DELAYED_WILD_RESPAWN_SKIP",
      reason = "TERRITORY_UNAVAILABLE",
      surface = surface.name,
      entity_name = entry.entity_name,
      chunk_x = entry.chunk_x,
      chunk_y = entry.chunk_y,
      due_tick = entry.due_tick,
    })
    return
  end

  if is_valid_position(entry.position) ~= true then
    Logger.warn({
      event = "BD_DELAYED_WILD_RESPAWN_SKIP",
      reason = "POSITION_UNAVAILABLE",
      surface = surface.name,
      entity_name = entry.entity_name,
      chunk_x = entry.chunk_x,
      chunk_y = entry.chunk_y,
      due_tick = entry.due_tick,
    })
    return
  end

  local quality_id, evolution_factor, roll_value, quality_steps = resolve_respawn_quality_id(surface)
  local unit = spawn_segmented_unit(surface, territory, entry.entity_name, entry.position, quality_id)

  Logger.info({
    event = "BD_DELAYED_WILD_RESPAWN_RESULT",
    surface = surface.name,
    entity_name = entry.entity_name,
    position_x = entry.position.x,
    position_y = entry.position.y,
    chunk_x = entry.chunk_x,
    chunk_y = entry.chunk_y,
    due_tick = entry.due_tick,
    success = unit ~= nil,
    quality = quality_id,
    quality_steps = quality_steps,
    evolution_factor = evolution_factor,
    roll_value = roll_value,
  })
end

--- run
--- Responsibility:
---   current_tick 時点で期限到来した delayed respawn entry を処理する。
--- @param current_tick uint
function DelayedWildRespawnService.run(current_tick)
  if type(current_tick) ~= "number" then
    error("DelayedWildRespawnService.run: current_tick must be a number")
  end

  local due_entries = DelayedWildRespawnQueueStore.pop_due(current_tick)
  if due_entries == nil or #due_entries == 0 then
    return
  end

  for _, entry in ipairs(due_entries) do
    process_due_entry(entry)
  end
end

return DelayedWildRespawnService