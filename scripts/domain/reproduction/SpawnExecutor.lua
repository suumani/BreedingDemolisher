-- __BreedingDemolisher__/scripts/domain/reproduction/SpawnExecutor.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Wild Reproduction における actual spawn を実行する。
--
-- Scope:
--   - LuaSurface.create_segmented_unit 実行
--   - territory 所属 wild segmented unit 生成
--   - position 指定 spawn
--   - success / failure 返却
--
-- Notes:
--   - Hatch / Pet 用 spawn を兼務しない
--   - spawn_position は実際の head position として使用する
-- ------------------------------------------------------------
local SpawnExecutor = {}

--- spawn
--- Responsibility:
---   territory に属する wild segmented unit を生成する。
--- @param surface LuaSurface
--- @param territory LuaTerritory
--- @param entity_name string
--- @param spawn_position MapPosition
--- @param force_name string|nil
--- @return boolean success
--- @return LuaSegmentedUnit|nil spawned_unit
function SpawnExecutor.spawn(surface, territory, entity_name, spawn_position, force_name)
  if surface == nil or surface.valid == false then
    error("SpawnExecutor.spawn: valid surface is required")
  end
  if territory == nil then
    error("SpawnExecutor.spawn: territory is required")
  end
  if type(entity_name) ~= "string" or entity_name == "" then
    error("SpawnExecutor.spawn: entity_name must be a non-empty string")
  end
  if spawn_position == nil or type(spawn_position.x) ~= "number" or type(spawn_position.y) ~= "number" then
    error("SpawnExecutor.spawn: valid spawn_position is required")
  end

  local unit = surface.create_segmented_unit{
    name = entity_name,
    force = force_name or "enemy",
    territory = territory,
    position = spawn_position,
  }

  if unit == nil then
    return false, nil
  end

  return true, unit
end

return SpawnExecutor