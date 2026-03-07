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
--   - planning ResultDTO 返却
--
-- Notes:
--   - plan は runtime-only。
--   - LuaTerritory / LuaChunk / unit list を保存しない。
-- ------------------------------------------------------------
local WildReproductionPlanningService = {}

local TerritoryQueryService = require("scripts.domain.reproduction.TerritoryQueryService")
local WildReproductionPlanStore = require("scripts.infrastructure.runtime.WildReproductionPlanStore")

local function dto_ok(reason, detail)
  return {
    ok = true,
    result = "OK",
    reason = reason,
    detail = detail,
  }
end

local function dto_skip(reason, detail)
  return {
    ok = true,
    result = "SKIP",
    reason = reason,
    detail = detail,
  }
end

local function dto_fail(reason, detail)
  return {
    ok = false,
    result = "FAIL",
    reason = reason,
    detail = detail,
  }
end

local function build_detail(cycle_tick, surface_name, territory_count, representative_chunk_resolved_count, representative_chunk_missing_count, count)
  return {
    cycle_tick = cycle_tick,
    surface_name = surface_name,
    territory_count = territory_count,
    representative_chunk_resolved_count = representative_chunk_resolved_count,
    representative_chunk_missing_count = representative_chunk_missing_count,
    count = count,
  }
end

--- plan
--- Responsibility:
---   cycle_tick に対応する Wild Reproduction plan を生成し保存する。
--- @param cycle_tick uint
--- @return table dto
function WildReproductionPlanningService.plan(cycle_tick)
  if type(cycle_tick) ~= "number" then
    error("WildReproductionPlanningService.plan: cycle_tick must be a number")
  end

  local surface = TerritoryQueryService.get_target_surface()
  if not surface or not surface.valid then
    WildReproductionPlanStore.replace_plan(cycle_tick, {})
    return dto_skip("REPRO:TARGET_SURFACE_INVALID", build_detail(
      cycle_tick,
      surface and surface.name or "vulcanus",
      0,
      0,
      0,
      0
    ))
  end

  local entries, territory_count, representative_chunk_resolved_count, representative_chunk_missing_count =
    TerritoryQueryService.get_sorted_territory_entries(surface)

  WildReproductionPlanStore.replace_plan(cycle_tick, entries)

  if territory_count == 0 then
    return dto_skip("REPRO:NO_TERRITORIES", build_detail(
      cycle_tick,
      surface.name,
      territory_count,
      representative_chunk_resolved_count,
      representative_chunk_missing_count,
      0
    ))
  end

  if #entries == 0 then
    return dto_skip("REPRO:NO_PLAN_ENTRIES", build_detail(
      cycle_tick,
      surface.name,
      territory_count,
      representative_chunk_resolved_count,
      representative_chunk_missing_count,
      0
    ))
  end

  return dto_ok("REPRO:PLAN_CREATED", build_detail(
    cycle_tick,
    surface.name,
    territory_count,
    representative_chunk_resolved_count,
    representative_chunk_missing_count,
    #entries
  ))
end

return WildReproductionPlanningService