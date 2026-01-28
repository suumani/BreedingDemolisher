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
local VirtualMgr      = require("__Manis_lib__/scripts/managers/VirtualEntityManager")
local DRand = require("scripts.util.DeterministicRandom")
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
  -- チャンク未生成(Void)の場合は建物なしとみなす
  if not surface.is_chunk_generated(pos) then return false end

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
  -- チャンク未生成の場合は近隣判定ができないため、腐らせない(false)とする
  -- あるいは仮想データも含めて検索する必要があるが、ここでは簡易的に物理のみチェック
  if not surface.is_chunk_generated(position) then return false end

  local neighbors = DemolisherQuery.find_breeding_demolishers_range(surface, {
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

-- Force/Qualityの安全な取得 (String化)
local function normalize_force_quality(queued, rolled_quality)
    local f = queued.force
    local f_name = "enemy"
    if type(f) == "userdata" then
        f_name = f.name
    elseif type(f) == "string" then
        f_name = f
    end

    local q = rolled_quality
    local q_name = "normal"
    if type(q) == "userdata" then
        q_name = q.name
    elseif type(q) == "string" then
        q_name = q
    end

    return f_name, q_name
end

local function spawn_demolisher(surface, queued, position, town_center)
  local dir = choose_cardinal_direction(position, town_center)

  -- Quality決定 (Rollerは userdata を返す可能性があるため正規化する)
  local raw_quality = QualityRoller.choose_quality(queued.evolution_factor, DRand.random())
  local force_name, quality_name = normalize_force_quality(queued, raw_quality)

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

  -- ■ Void対応修正: チャンク生成済みなら実体化、未生成なら仮想キューへ
  if surface.is_chunk_generated(position) then
    local ent = surface.create_entity{
      name      = entity_name,
      position  = position,
      force     = force_name,   -- Stringで渡す
      quality   = quality_name, -- Stringで渡す
      direction = dir
    }
    return { success = (ent ~= nil), entity = ent, virtual = false }
  else
    -- ★修正: 第2引数(id)に nil を渡す (新規発行)
    -- ★修正: データ構造をBossMod等と統一 (is_fatal, String化)
    VirtualMgr.enqueue(surface, nil, position, {
      name     = entity_name,
      quality  = quality_name,
      force    = force_name,
      category = "combat",
      is_fatal = false
    })
    return { success = true, entity = nil, virtual = true }
  end
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