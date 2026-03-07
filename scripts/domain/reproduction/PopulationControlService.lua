-- __BreedingDemolisher__/scripts/domain/reproduction/PopulationControlService.lua
-- ------------------------------------------------------------
-- Responsibility:
--   03_PopulationControl.md に従い、
--   spawn 実行直前の suppress 判定を行う。
--
-- Scope:
--   - territory population count
--   - surface population count
--   - territory cap / surface cap 判定
--   - suppress reason code 返却
--
-- Notes:
--   - population の正は world state
--   - storage キャッシュを正としてはならない
-- ------------------------------------------------------------
local PopulationControlService = {}

local TERRITORY_CAP = 6
local SURFACE_CAP = 200

PopulationControlService.REASON_NONE = "NONE"
PopulationControlService.REASON_TERRITORY_CAP_REACHED = "TERRITORY_CAP_REACHED"
PopulationControlService.REASON_SURFACE_CAP_REACHED = "SURFACE_CAP_REACHED"

local function is_counted_segmented_unit(unit)
  if unit == nil then
    return false
  end

  if unit.valid == false then
    return false
  end

  return true
end

--- get_territory_population
--- Responsibility:
---   territory に属する segmented unit 数を world から数える。
--- @param territory LuaTerritory
--- @return uint
function PopulationControlService.get_territory_population(territory)
  if territory == nil then
    error("PopulationControlService.get_territory_population: territory is required")
  end

  local units = territory.get_segmented_units()
  if units == nil then
    return 0
  end

  local count = 0
  for _, unit in ipairs(units) do
    if is_counted_segmented_unit(unit) then
      count = count + 1
    end
  end

  return count
end

--- get_surface_population
--- Responsibility:
---   surface 上の全 segmented unit 数を world から数える。
--- @param surface LuaSurface
--- @return uint
function PopulationControlService.get_surface_population(surface)
  if surface == nil or surface.valid == false then
    error("PopulationControlService.get_surface_population: valid surface is required")
  end

  local units = surface.get_segmented_units()
  if units == nil then
    return 0
  end

  local count = 0
  for _, unit in ipairs(units) do
    if is_counted_segmented_unit(unit) then
      count = count + 1
    end
  end

  return count
end

--- should_suppress_spawn
--- Responsibility:
---   spawn 実行直前の suppress 判定を返す。
--- @param territory LuaTerritory
--- @param surface LuaSurface
--- @return boolean suppress
--- @return string reason_code
function PopulationControlService.should_suppress_spawn(territory, surface)
  local territory_population = PopulationControlService.get_territory_population(territory)
  if territory_population >= TERRITORY_CAP then
    return true, PopulationControlService.REASON_TERRITORY_CAP_REACHED
  end

  local surface_population = PopulationControlService.get_surface_population(surface)
  if surface_population >= SURFACE_CAP then
    return true, PopulationControlService.REASON_SURFACE_CAP_REACHED
  end

  return false, PopulationControlService.REASON_NONE
end

return PopulationControlService