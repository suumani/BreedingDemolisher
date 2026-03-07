-- __BreedingDemolisher__/scripts/domain/reproduction/SpawnEntityResolver.lua
-- ------------------------------------------------------------
-- Responsibility:
--   02_Reproduction.md に従い、
--   親 unit と evolution factor から spawn entity name を決定する。
--
-- Scope:
--   - parent entity name 読み取り
--   - mutation candidate 判定
--   - mutation threshold 判定
--   - evolution table 判定
--   - mutation 優先、失敗時 evolution fallback
--
-- Notes:
--   - mutation 成立率そのものは本クラスで判定しない。
--   - mutation_roll_result は execution 側から渡される。
--   - BossMod 依存ゲートを持つ。
--   - LuaSegmentedUnit の識別は prototype.name を使用する。
-- ------------------------------------------------------------
local SpawnEntityResolver = {}

local DemolisherNames = require("__Manis_definitions__/scripts/definition/DemolisherNames")

local HAS_BOSS = (script and script.active_mods and script.active_mods["ManisBossDemolisher"]) ~= nil
local HAS_SPEEDSTAR = HAS_BOSS
local HAS_BEHEMOTH = HAS_BOSS

local EVOLUTION_ROWS = {
  {
    parent_entity_name = DemolisherNames.MANIS_SMALL,
    threshold = 0.25,
    spawn_entity_name = DemolisherNames.MANIS_MEDIUM,
  },
  {
    parent_entity_name = DemolisherNames.MANIS_MEDIUM,
    threshold = 0.50,
    spawn_entity_name = DemolisherNames.MANIS_BIG,
  },
  {
    parent_entity_name = DemolisherNames.MANIS_BIG,
    threshold = 0.75,
    spawn_entity_name = DemolisherNames.MANIS_BEHEMOTH,
    requires_behemoth = true,
  },
}

local MUTATION_ROWS = {
  {
    parent_entity_name = DemolisherNames.MANIS_MEDIUM,
    threshold = 0.25,
    mutation_entity_name = DemolisherNames.MANIS_SPEEDSTAR_SMALL,
    requires_speedstar = true,
  },
  {
    parent_entity_name = DemolisherNames.MANIS_BIG,
    threshold = 0.50,
    mutation_entity_name = DemolisherNames.MANIS_SPEEDSTAR_MEDIUM,
    requires_speedstar = true,
  },
  {
    parent_entity_name = DemolisherNames.MANIS_BEHEMOTH,
    threshold = 0.75,
    mutation_entity_name = DemolisherNames.MANIS_SPEEDSTAR_BIG,
    requires_speedstar = true,
  },
}

local function get_parent_entity_name(parent_unit)
  if parent_unit == nil then
    error("SpawnEntityResolver: parent_unit is required")
  end
  if parent_unit.valid == false then
    error("SpawnEntityResolver: parent_unit must be valid")
  end
  if parent_unit.prototype == nil then
    error("SpawnEntityResolver: parent_unit.prototype is required")
  end

  local name = parent_unit.prototype.name
  if type(name) ~= "string" or name == "" then
    error("SpawnEntityResolver: parent_unit.prototype.name must be a non-empty string")
  end

  return name
end

local function is_row_enabled(row)
  if row.requires_speedstar == true and not HAS_SPEEDSTAR then
    return false
  end
  if row.requires_behemoth == true and not HAS_BEHEMOTH then
    return false
  end
  return true
end

local function find_mutation_row(parent_entity_name, evolution_factor)
  for _, row in ipairs(MUTATION_ROWS) do
    if row.parent_entity_name == parent_entity_name and evolution_factor >= row.threshold and is_row_enabled(row) then
      return row
    end
  end
  return nil
end

local function find_evolution_row(parent_entity_name, evolution_factor)
  for _, row in ipairs(EVOLUTION_ROWS) do
    if row.parent_entity_name == parent_entity_name and evolution_factor >= row.threshold and is_row_enabled(row) then
      return row
    end
  end
  return nil
end

--- get_parent_entity_name
--- Responsibility:
---   親 segmented unit の prototype 名を返す。
--- @param parent_unit LuaSegmentedUnit
--- @return string
function SpawnEntityResolver.get_parent_entity_name(parent_unit)
  return get_parent_entity_name(parent_unit)
end

--- has_mutation_candidate
--- Responsibility:
---   親 unit / evolution factor に対して mutation 候補が存在するかを返す。
--- @param parent_unit LuaSegmentedUnit
--- @param evolution_factor number
--- @return boolean
function SpawnEntityResolver.has_mutation_candidate(parent_unit, evolution_factor)
  if type(evolution_factor) ~= "number" then
    error("SpawnEntityResolver.has_mutation_candidate: evolution_factor must be a number")
  end

  local parent_entity_name = get_parent_entity_name(parent_unit)
  return find_mutation_row(parent_entity_name, evolution_factor) ~= nil
end

--- get_mutation_threshold
--- Responsibility:
---   mutation candidate が存在する場合、その threshold を返す。
--- @param parent_unit LuaSegmentedUnit
--- @param evolution_factor number
--- @return number|nil
function SpawnEntityResolver.get_mutation_threshold(parent_unit, evolution_factor)
  if type(evolution_factor) ~= "number" then
    error("SpawnEntityResolver.get_mutation_threshold: evolution_factor must be a number")
  end

  local parent_entity_name = get_parent_entity_name(parent_unit)
  local row = find_mutation_row(parent_entity_name, evolution_factor)
  return row and row.threshold or nil
end

--- resolve_spawn_entity
--- Responsibility:
---   親 unit / evolution factor / mutation_roll_result から
---   最終 spawn entity name を返す。
--- @param parent_unit LuaSegmentedUnit
--- @param evolution_factor number
--- @param mutation_roll_result boolean|nil
--- @return string
function SpawnEntityResolver.resolve_spawn_entity(parent_unit, evolution_factor, mutation_roll_result)
  if type(evolution_factor) ~= "number" then
    error("SpawnEntityResolver.resolve_spawn_entity: evolution_factor must be a number")
  end

  local parent_entity_name = get_parent_entity_name(parent_unit)

  local mutation_row = find_mutation_row(parent_entity_name, evolution_factor)
  if mutation_row ~= nil then
    if type(mutation_roll_result) ~= "boolean" then
      error("SpawnEntityResolver.resolve_spawn_entity: mutation_roll_result must be provided when mutation candidate exists")
    end

    if mutation_roll_result == true then
      return mutation_row.mutation_entity_name
    end
  end

  local evolution_row = find_evolution_row(parent_entity_name, evolution_factor)
  if evolution_row ~= nil then
    return evolution_row.spawn_entity_name
  end

  return parent_entity_name
end

return SpawnEntityResolver