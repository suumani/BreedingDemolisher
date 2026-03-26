-- __BreedingDemolisher__/scripts/infrastructure/runtime/WildReproductionPlanStore.lua
-- ------------------------------------------------------------
-- Responsibility:
--   storage 上で Wild Reproduction plan を保持する。
--
-- Scope:
--   - cycle_tick ごとの plan 全置換
--   - step_index -> plan entry 解決
--   - plan count 取得
--   - clear
--
-- Notes:
--   - storage に保存されるため save/load を跨ぎうる。
--   - plan entry は validate 済み ContractDTO shape のみ保持する。
--   - metatable ベースの DTO 判定は行わない。
--   - storage.bd / storage.bd.runtime は bootstrap 済み前提で扱い、
--     このクラスでは自動生成しない。
-- ------------------------------------------------------------
local WildReproductionPlanStore = {}

local WildReproductionPlanEntryDTO = require("scripts.application.reproduction.dto.WildReproductionPlanEntryDTO")

local function expect_runtime_root()
  if storage == nil then
    error("WildReproductionPlanStore: storage is nil")
  end
  if storage.bd == nil then
    error("WildReproductionPlanStore: storage.bd is nil. Call StorageBootstrap.bootstrap() first.")
  end
  if storage.bd.runtime == nil then
    error("WildReproductionPlanStore: storage.bd.runtime is nil. Call StorageBootstrap.bootstrap() first.")
  end

  return storage.bd.runtime
end

local function plan_root()
  local runtime = expect_runtime_root()

  if runtime.wild_reproduction_plan == nil then
    runtime.wild_reproduction_plan = {
      cycle_tick = nil,
      entries = {},
    }
  end

  return runtime.wild_reproduction_plan
end

local function copy_entries(entries)
  local copied = {}
  for index, entry in ipairs(entries) do
    WildReproductionPlanEntryDTO.validate(entry)
    copied[index] = WildReproductionPlanEntryDTO.new({
      surface_name = entry.surface_name,
      representative_chunk_x = entry.representative_chunk_x,
      representative_chunk_y = entry.representative_chunk_y,
    })
  end
  return copied
end

local function validate_entries(entries)
  for index, entry in ipairs(entries) do
    if type(entry) ~= "table" then
      error("WildReproductionPlanStore.replace_plan: entry at index " .. tostring(index) .. " must be a table")
    end
    WildReproductionPlanEntryDTO.validate(entry)
  end
end

--- replace_plan
--- Responsibility:
---   現 cycle の plan を全置換する。
--- @param cycle_tick uint
--- @param entries table[]
function WildReproductionPlanStore.replace_plan(cycle_tick, entries)
  if type(cycle_tick) ~= "number" then
    error("WildReproductionPlanStore.replace_plan: cycle_tick must be a number")
  end
  if type(entries) ~= "table" then
    error("WildReproductionPlanStore.replace_plan: entries must be a table")
  end

  validate_entries(entries)

  local root = plan_root()
  root.cycle_tick = cycle_tick
  root.entries = copy_entries(entries)
end

--- get_entry
--- Responsibility:
---   step_index に対応する entry を返す。
--- @param step_index uint
--- @return table|nil
function WildReproductionPlanStore.get_entry(step_index)
  if type(step_index) ~= "number" then
    error("WildReproductionPlanStore.get_entry: step_index must be a number")
  end

  local root = plan_root()
  return root.entries[step_index]
end

--- get_count
--- Responsibility:
---   現 plan の entry 数を返す。
--- @return uint
function WildReproductionPlanStore.get_count()
  local root = plan_root()
  return #root.entries
end

--- get_cycle_tick
--- Responsibility:
---   現 plan の cycle_tick を返す。
--- @return uint|nil
function WildReproductionPlanStore.get_cycle_tick()
  local root = plan_root()
  return root.cycle_tick
end

--- clear
--- Responsibility:
---   現 plan をクリアする。
function WildReproductionPlanStore.clear()
  local root = plan_root()
  root.cycle_tick = nil
  root.entries = {}
end

return WildReproductionPlanStore