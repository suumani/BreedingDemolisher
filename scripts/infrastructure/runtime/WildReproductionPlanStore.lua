-- __BreedingDemolisher__/scripts/infrastructure/runtime/WildReproductionPlanStore.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Runtime-only で Wild Reproduction plan を保持する。
--
-- Scope:
--   - cycle_tick ごとの plan 全置換
--   - step_index -> plan entry 解決
--   - plan count 取得
--   - clear
--
-- Notes:
--   - 永続 source ではない。
--   - plan entry は ContractDTO のみ保持する。
-- ------------------------------------------------------------
local WildReproductionPlanStore = {}

local WildReproductionPlanEntryDTO = require("scripts.application.reproduction.dto.WildReproductionPlanEntryDTO")

local function ensure_root()
  storage.bd = storage.bd or {}
  storage.bd.runtime = storage.bd.runtime or {}
  storage.bd.runtime.wild_reproduction_plan = storage.bd.runtime.wild_reproduction_plan or {
    cycle_tick = nil,
    entries = {},
  }
  return storage.bd.runtime.wild_reproduction_plan
end

local function copy_entries(entries)
  local copied = {}
  for index, entry in ipairs(entries) do
    copied[index] = entry
  end
  return copied
end

local function validate_entries(entries)
  for index, entry in ipairs(entries) do
    if not WildReproductionPlanEntryDTO.is_instance(entry) then
      error("WildReproductionPlanStore.replace_plan: entry at index " .. tostring(index) .. " must be WildReproductionPlanEntryDTO")
    end
  end
end

--- replace_plan
--- Responsibility:
---   現 cycle の plan を全置換する。
--- @param cycle_tick uint
--- @param entries WildReproductionPlanEntryDTO[]
function WildReproductionPlanStore.replace_plan(cycle_tick, entries)
  if type(cycle_tick) ~= "number" then
    error("WildReproductionPlanStore.replace_plan: cycle_tick must be a number")
  end
  if type(entries) ~= "table" then
    error("WildReproductionPlanStore.replace_plan: entries must be a table")
  end

  validate_entries(entries)

  local root = ensure_root()
  root.cycle_tick = cycle_tick
  root.entries = copy_entries(entries)
end

--- get_entry
--- Responsibility:
---   step_index に対応する entry を返す。
--- @param step_index uint
--- @return WildReproductionPlanEntryDTO|nil
function WildReproductionPlanStore.get_entry(step_index)
  if type(step_index) ~= "number" then
    error("WildReproductionPlanStore.get_entry: step_index must be a number")
  end

  local root = ensure_root()
  return root.entries[step_index]
end

--- get_count
--- Responsibility:
---   現 plan の entry 数を返す。
--- @return uint
function WildReproductionPlanStore.get_count()
  local root = ensure_root()
  return #root.entries
end

--- get_cycle_tick
--- Responsibility:
---   現 plan の cycle_tick を返す。
--- @return uint|nil
function WildReproductionPlanStore.get_cycle_tick()
  local root = ensure_root()
  return root.cycle_tick
end

--- clear
--- Responsibility:
---   現 plan をクリアする。
function WildReproductionPlanStore.clear()
  local root = ensure_root()
  root.cycle_tick = nil
  root.entries = {}
end

return WildReproductionPlanStore