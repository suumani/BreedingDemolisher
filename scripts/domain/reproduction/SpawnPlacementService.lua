-- __BreedingDemolisher__/scripts/domain/reproduction/SpawnPlacementService.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Wild Reproduction の territory context 内で
--   actual spawn に使用する座標を決定する。
--
-- Scope:
--   - territory 内の生成済み chunk 抽出
--   - 生成済み chunk からランダム選択
--   - chunk 中心座標を actual spawn position として返す
--
-- Notes:
--   - parent 近傍探索は行わない
--   - 座標は territory 内の generated chunk から選ぶ
-- ------------------------------------------------------------
local SpawnPlacementService = {}

local DeterministicRandom = require("scripts.core.services.DeterministicRandom")

local CHUNK_SIZE = 32
local CHUNK_CENTER_OFFSET = 16

local function chunk_to_tile_center(chunk_x, chunk_y)
  return {
    x = chunk_x * CHUNK_SIZE + CHUNK_CENTER_OFFSET,
    y = chunk_y * CHUNK_SIZE + CHUNK_CENTER_OFFSET,
  }
end

local function get_generated_chunk_positions(territory)
  local surface = territory.surface
  local chunks = territory.get_chunks()
  local generated = {}

  if chunks == nil or #chunks == 0 then
    return generated
  end

  for _, chunk_info in ipairs(chunks) do
    local pos = chunk_info.position
    if pos ~= nil and surface.is_chunk_generated(pos) then
      generated[#generated + 1] = { x = pos.x, y = pos.y }
    end
  end

  return generated
end

local function choose_random_chunk_position(chunk_positions)
  if chunk_positions == nil or #chunk_positions == 0 then
    return nil
  end

  local index = DeterministicRandom.random(1, #chunk_positions)
  return chunk_positions[index]
end

--- resolve_spawn_position
--- Responsibility:
---   territory 内の生成済み chunk からランダムに 1つ選び、
---   その chunk 中心座標を actual spawn position として返す。
--- @param territory LuaTerritory
--- @param parent_unit LuaSegmentedUnit
--- @param entity_name string
--- @return MapPosition|nil
function SpawnPlacementService.resolve_spawn_position(territory, parent_unit, entity_name)
  if territory == nil then
    error("SpawnPlacementService.resolve_spawn_position: territory is required")
  end
  if parent_unit == nil then
    error("SpawnPlacementService.resolve_spawn_position: parent_unit is required")
  end
  if type(entity_name) ~= "string" or entity_name == "" then
    error("SpawnPlacementService.resolve_spawn_position: entity_name must be a non-empty string")
  end

  local generated_chunk_positions = get_generated_chunk_positions(territory)
  if #generated_chunk_positions == 0 then
    return nil
  end

  local picked_chunk = choose_random_chunk_position(generated_chunk_positions)
  if picked_chunk == nil then
    return nil
  end

  return chunk_to_tile_center(picked_chunk.x, picked_chunk.y)
end

return SpawnPlacementService