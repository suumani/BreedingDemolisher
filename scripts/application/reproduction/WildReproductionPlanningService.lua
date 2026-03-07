-- __BreedingDemolisher__/scripts/application/reproduction/WildReproductionPlanningService.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Wild Reproduction の planning を行い、
--   今 cycle の execution plan を生成する。
--
-- Scope:
--   - target surface 取得
--   - territory 列挙
--   - representative chunk による plan entry 生成
--   - plan store への保存
--   - execution step count 返却
--
-- Notes:
--   - plan は runtime-only。
--   - LuaTerritory / LuaChunk / unit list を保存しない。
-- ------------------------------------------------------------
local WildReproductionPlanningService = {}

local TerritoryQueryService = require("scripts.domain.reproduction.TerritoryQueryService")
local WildReproductionPlanStore = require("scripts.infrastructure.runtime.WildReproductionPlanStore")

--- plan
--- Responsibility:
---   cycle_tick に対応する Wild Reproduction plan を生成し保存する。
--- @param cycle_tick uint
--- @return uint count
function WildReproductionPlanningService.plan(cycle_tick)
  if type(cycle_tick) ~= "number" then
    error("WildReproductionPlanningService.plan: cycle_tick must be a number")
  end

  local surface = TerritoryQueryService.get_target_surface()
  if not surface or not surface.valid then
    WildReproductionPlanStore.replace_plan(cycle_tick, {})
    return 0
  end

  local entries = TerritoryQueryService.get_sorted_territory_entries(surface)
  WildReproductionPlanStore.replace_plan(cycle_tick, entries)

  return #entries
end

return WildReproductionPlanningService