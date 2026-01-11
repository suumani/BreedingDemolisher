-- __BreedingDemolisher__/scripts/services/DemolisherEggHatchService.lua
-- ----------------------------
-- class DemolisherEggHatchService
-- Responsibility:
--   卵（respawn_queue）を孵化させてデモリッシャーを生成する。
--   ※respawn_queue の所有・追加は別責務。ここは消費のみ。
-- ----------------------------
local DemolisherEggHatchService = {}

-- ----------------------------
-- requires
-- ----------------------------
local QualityRoller = require("__Manis_lib__/scripts/rollers/QualityRoller")
local DemolisherQuery = require("__Manis_lib__/scripts/queries/DemolisherQuery")
local DRand = require("scripts.util.DeterministicRandom") -- 当面維持
local TownCenter  = require("scripts.services.TownCenterResolver")

local function choose_cardinal_direction(from_pos, to_pos)
  local dx = to_pos.x - from_pos.x
  local dy = to_pos.y - from_pos.y
  if math.abs(dx) >= math.abs(dy) then
    return (dx >= 0) and defines.direction.east or defines.direction.west
  else
    return (dy >= 0) and defines.direction.south or defines.direction.north
  end
end

local function has_player_buildings_near(surface, pos, r)
  local area = { {pos.x - r, pos.y - r}, {pos.x + r, pos.y + r} }
  return surface.count_entities_filtered{
    area = area,
    force = game.forces.player
  } > 0
end

local function adjust_position_if_too_close_to_origin(position)
  local l2 = position.x * position.x + position.y * position.y
  if l2 >= 40000 then
    return position
  end

  local p = { x = position.x, y = position.y }

  if p.x * p.x < p.y * p.y then
    p.y = (p.y < 0) and (p.y - 200) or (p.y + 200)
  else
    p.x = (p.x < 0) and (p.x - 200) or (p.x + 200)
  end

  return p
end

local function should_rot_egg(surface, position)
  local neighbors = DemolisherQuery.find_demolishers_range(surface, {
    { x = position.x - 60, y = position.y - 60 },
    { x = position.x + 60, y = position.y + 60 },
  })
  return #neighbors >= 4
end

local function retry_position_away_from_town_center(position, town_center)
  local p = { x = position.x, y = position.y }

  local dx = p.x - town_center.x
  p.x = (dx > 0) and (p.x + 50) or (p.x - 50)

  local dy = p.y - town_center.y
  p.y = (dy > 0) and (p.y + 50) or (p.y - 50)

  return p
end

local function resolve_spawn_position(surface, position, town_center)
  if not has_player_buildings_near(surface, position, 30) then
    return position
  end

  local retry = retry_position_away_from_town_center(position, town_center)
  if not has_player_buildings_near(surface, retry, 30) then
    return retry
  end

  return nil
end

local function spawn_demolisher(surface, queued, position, town_center)
  local dir = choose_cardinal_direction(position, town_center)

  local quality = QualityRoller.choose_quality(queued.evolution_factor, DRand.random())

  local entity_name = queued.entity_name
  if surface.name == "vulcanus" then
    if entity_name == "small-demolisher" then
      entity_name = "manis-small-demolisher"
    elseif entity_name == "medium-demolisher" then
      entity_name = "manis-medium-demolisher"
    elseif entity_name == "big-demolisher" then
      entity_name = "manis-big-demolisher"
    end
  end

  return surface.create_entity{
    name = entity_name,
    position = position,
    force = queued.force,
    quality = quality,
    direction = dir
  }
end

-- ----------------------------
-- 卵の孵化（respawn_queueを消費）
-- ----------------------------
function DemolisherEggHatchService.spawn_wild_demolishers(vulcanus_surface)
  for i = #storage.respawn_queue, 1, -1 do
    local queued = storage.respawn_queue[i]
    if game.tick >= queued.respawn_tick then
      local surface = queued.surface
      local position = adjust_position_if_too_close_to_origin(queued.position)

      if should_rot_egg(vulcanus_surface, position) then
        table.remove(storage.respawn_queue, i)
      else
        local town_center = TownCenter.resolve(surface)
        local spawn_pos = resolve_spawn_position(surface, position, town_center)

        if not spawn_pos then
          table.remove(storage.respawn_queue, i) -- 腐る
        else
          spawn_demolisher(surface, queued, spawn_pos, town_center)
          table.remove(storage.respawn_queue, i)
        end
      end
    end
  end
end

return DemolisherEggHatchService