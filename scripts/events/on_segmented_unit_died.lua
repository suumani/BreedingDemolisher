-- __BreedingDemolisher__/scripts/events/on_segmented_unit_died.lua
-- ------------------------------------------------------------
-- Responsibility:
--   enemy demolisher の撃破を検知し、
--   delayed respawn queue 登録 / egg drop / message 表示を行う。
--
-- Scope:
--   - on_segmented_unit_died 受信
--   - enemy gate 判定
--   - future respawn 抽選
--   - delayed respawn pending 登録
--   - item drop 抽選と demolisher-egg ドロップ
--   - message 表示
--
-- Notes:
--   - surface は全対象。
--   - delayed respawn 当選時は item drop 抽選を行わない。
--   - entity name / display name は segmented_unit.prototype から取得する。
--   - body node 先頭座標から chunk を計算して保存する。
--   - egg drop 位置は body node 先頭座標を使用する。
-- ------------------------------------------------------------
local Logger = require("scripts.infrastructure.logging.Logger")
local DeterministicRandom = require("scripts.core.services.DeterministicRandom")
local DelayedWildRespawnQueueStore = require("scripts.infrastructure.runtime.DelayedWildRespawnQueueStore")

local ITEM_NAME = "demolisher-egg"
local RESPAWN_MIN_TICKS = 60 * 60 * 5
local RESPAWN_MAX_TICKS = 60 * 60 * 15
local ITEM_DROP_RATE = 0.05

local function is_enemy_demolisher(segmented_unit)
  if segmented_unit == nil or segmented_unit.valid == false then
    return false
  end
  if segmented_unit.force == nil or segmented_unit.force.name ~= "enemy" then
    return false
  end
  if segmented_unit.prototype == nil then
    return false
  end
  if type(segmented_unit.prototype.name) ~= "string" then
    return false
  end

  return string.find(segmented_unit.prototype.name, "demolisher", 1, true) ~= nil
end

local function get_enemy_evolution_factor(surface)
  local enemy_force = game.forces["enemy"]
  if enemy_force == nil then
    error("on_segmented_unit_died: game.forces['enemy'] is not available")
  end
  return enemy_force.get_evolution_factor(surface)
end

local function calc_future_respawn_rate(evolution_factor)
  return 0.10 + 0.20 * evolution_factor
end

local function random_roll(probability)
  return DeterministicRandom.random() < probability
end

local function calc_random_due_tick(current_tick)
  local offset_range = RESPAWN_MAX_TICKS - RESPAWN_MIN_TICKS + 1
  local offset = math.floor(DeterministicRandom.random() * offset_range)
  return current_tick + RESPAWN_MIN_TICKS + offset
end

local function to_chunk_coord(tile_coord)
  return math.floor(tile_coord / 32)
end

local function resolve_head_node(segmented_unit)
  local nodes = segmented_unit.get_body_nodes()
  local head = nodes[1]

  return {
    x = head.x,
    y = head.y,
  }
end

local function resolve_unit_display_name(segmented_unit)
  return segmented_unit.prototype.localised_name
end

local function try_drop_egg(surface, position)
  local dropped = surface.spill_item_stack{
    position = position,
    stack = {
      name = ITEM_NAME,
      count = 1,
    },
    enable_looted = true,
    allow_belts = false,
  }

  return dropped ~= nil and #dropped > 0
end

local function print_future_respawn_message(unit_display_name)
  game.print({ "bd.message.wild_demolisher_future_respawn", unit_display_name })
end

local function print_egg_drop_message(unit_display_name)
  game.print({ "bd.message.wild_demolisher_egg_drop", unit_display_name })
end

local function print_egg_destroyed_message(unit_display_name)
  game.print({ "bd.message.wild_demolisher_egg_destroyed", unit_display_name })
end

local function on_segmented_unit_died(event)
  local segmented_unit = event.segmented_unit
  if is_enemy_demolisher(segmented_unit) ~= true then
    return
  end

  local surface = segmented_unit.surface
  if surface == nil or surface.valid == false then
    return
  end

  local entity_name = segmented_unit.prototype.name
  local head_pos = resolve_head_node(segmented_unit)
  local chunk_x = to_chunk_coord(head_pos.x)
  local chunk_y = to_chunk_coord(head_pos.y)

  local unit_display_name = resolve_unit_display_name(segmented_unit)
  local evolution_factor = get_enemy_evolution_factor(surface)
  local future_respawn_rate = calc_future_respawn_rate(evolution_factor)

  if random_roll(future_respawn_rate) == true then
    local due_tick = calc_random_due_tick(event.tick)

    DelayedWildRespawnQueueStore.enqueue({
      surface_name = surface.name,
      entity_name = entity_name,
      chunk_x = chunk_x,
      chunk_y = chunk_y,
      due_tick = due_tick,
    })

    Logger.info({
      event = "BD_DELAYED_WILD_RESPAWN_ENQUEUED",
      surface = surface.name,
      entity_name = entity_name,
      unit_number = segmented_unit.unit_number,
      chunk_x = chunk_x,
      chunk_y = chunk_y,
      due_tick = due_tick,
      evolution_factor = evolution_factor,
      probability = future_respawn_rate,
    })

    print_future_respawn_message(unit_display_name)
    return
  end

  if random_roll(ITEM_DROP_RATE) == true then
    local dropped = try_drop_egg(surface, head_pos)

    Logger.info({
      event = "BD_WILD_DEMOLISHER_EGG_DROP_RESULT",
      surface = surface.name,
      entity_name = entity_name,
      unit_number = segmented_unit.unit_number,
      position_x = head_pos.x,
      position_y = head_pos.y,
      chunk_x = chunk_x,
      chunk_y = chunk_y,
      dropped = dropped,
    })

    print_egg_drop_message(unit_display_name)
    return
  end

  Logger.info({
    event = "BD_WILD_DEMOLISHER_EGG_DESTROYED",
    surface = surface.name,
    entity_name = entity_name,
    unit_number = segmented_unit.unit_number,
    position_x = head_pos.x,
    position_y = head_pos.y,
    chunk_x = chunk_x,
    chunk_y = chunk_y,
  })

  print_egg_destroyed_message(unit_display_name)
end

script.on_event(defines.events.on_segmented_unit_died, on_segmented_unit_died)