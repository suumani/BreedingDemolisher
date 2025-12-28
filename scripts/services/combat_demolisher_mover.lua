-- ----------------------------
-- Combat Demolisher Mover (no storage ownership)
-- scripts/services/combat_demolisher_mover.lua
-- ----------------------------
local M = {}

local DRand = require("scripts.util.DeterministicRandom")
local DemolisherNames = require("__Manis_lib__/scripts/definition/DemolisherNames")

local PLAYER_FORCE_NAME = "player"
local BUILDING_CHECK_RADIUS = 10
local MAX_MOVES_PER_EVENT = 20

-- ----------------------------
-- 距離の二乗
-- ----------------------------
local function squared_distance(pos1, pos2)
  return (pos1.x - pos2.x)^2 + (pos1.y - pos2.y)^2
end

-- ----------------------------
-- 次の座標（pos1 -> pos2 に max_distance だけ近づく）
-- ----------------------------
local function calculate_next_position(pos1, pos2, max_distance)
  local dx = pos2.x - pos1.x
  local dy = pos2.y - pos1.y
  local distance = math.sqrt(dx * dx + dy * dy)

  if distance <= max_distance then
    return { x = pos2.x, y = pos2.y }
  end

  local ratio = max_distance / distance
  return { x = pos1.x + dx * ratio, y = pos1.y + dy * ratio }
end

-- ----------------------------
-- player建物（エンティティ）が近いか？
-- AABB(±radius)内に player force のエンティティが1つでもあれば true
-- ----------------------------
local function has_player_building_near(surface, pos, radius)
  local area = {
    { x = pos.x - radius, y = pos.y - radius },
    { x = pos.x + radius, y = pos.y + radius }
  }

  local entities = surface.find_entities_filtered{ area = area, force = PLAYER_FORCE_NAME }
  if not entities or #entities == 0 then
    return false
  end

  -- player force のエンティティは基本「建物扱い」で良い、という仕様に基づき即true
  return true
end

-- ----------------------------
-- Entityをサイロ座標（positions）の最寄りへ向けてワープ
-- teleport不可なので create + destroy
-- ----------------------------
local function move_entity_to_positions(entity, positions, max_distance)
  local min_distance
  local target_position

  for _, pos in pairs(positions) do
    local d = squared_distance(entity.position, pos)
    if min_distance == nil or d < min_distance then
      min_distance = d
      target_position = pos
    end
  end

  if not target_position then
    return false
  end

  local move_position = calculate_next_position(entity.position, target_position, max_distance)

  -- player建物が近いなら移動中止
  if has_player_building_near(entity.surface, move_position, BUILDING_CHECK_RADIUS) then
    return false
  end

  local new_entity = entity.surface.create_entity{
    name      = entity.name,
    position  = move_position,
    force     = entity.force,
    direction = entity.direction,
    quality   = entity.quality
  }

  if new_entity ~= nil then entity.destroy() end
  return new_entity ~= nil
end

-- ----------------------------
-- 移動可能判定（フルゴラMod仕様準拠）
-- ----------------------------
local function can_move_by_evolution(name, evo)
  if name == DemolisherNames.SMALL then return evo > 0.4 end
  if name == DemolisherNames.MEDIUM then return evo > 0.7 end
  if name == DemolisherNames.BIG then return evo > 0.9 end
  return false
end

-- ----------------------------
-- 移動イベント（フルゴラMod仕様準拠）
-- demolishers: surface上のentity配列（またはfind_entities_filtered結果）
-- evolution_factor: 0..1
-- move_rate: 1..3
-- positions: ロケットサイロ履歴（座標配列）
-- ----------------------------
function M.move(demolishers, evolution_factor, move_rate, positions)
  if not demolishers or #demolishers == 0 then
    return 0
  end
  if not positions or #positions == 0 then
    return 0
  end

  local count = 0

  for _, entity in pairs(demolishers) do
    -- 上限：1回のイベントで最大MAX_MOVES_PER_EVENT体まで
    if count >= MAX_MOVES_PER_EVENT then
      break
    end

    -- 進化度に応じて、移動するデモリッシャーは制限される
    -- 進化度の50%の確率で移動（フルゴラ準拠）
    if DRand.random() < (evolution_factor / 2) then
      local max_distance = math.floor(20 * evolution_factor * move_rate) + 1
      max_distance = DRand.random(0, max_distance)
      if max_distance ~= 0 and can_move_by_evolution(entity.name, evolution_factor) then
       if move_entity_to_positions(entity, positions, max_distance) then
        count = count + 1
       end
      end
    end
  end

  return count
end

return M