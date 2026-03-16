-- __BreedingDemolisher__/scripts/infrastructure/runtime/PetBreedingPlanStore.lua
-- ------------------------------------------------------------
-- Responsibility:
--   storage 上で Pet Breeding plan を保持する。
--
-- Scope:
--   - cycle_tick ごとの plan 全置換
--   - step_index -> pet_id 解決
--   - plan count 取得
--   - clear
--
-- Notes:
--   - storage に保存されるため save/load を跨ぎうる。
--   - plan entry は validate 済み ContractDTO shape のみ保持する。
--   - metatable ベースの DTO 判定は行わない。
-- ------------------------------------------------------------
local PetBreedingPlanStore = {}

local PetBreedingPlanEntryDTO = require("scripts.application.pet_breeding.dto.PetBreedingPlanEntryDTO")

local function ensure_root()
  storage.bd = storage.bd or {}
  storage.bd.runtime = storage.bd.runtime or {}
  storage.bd.runtime.pet_breeding_plan = storage.bd.runtime.pet_breeding_plan or {
    cycle_tick = nil,
    entries = {},
  }
  return storage.bd.runtime.pet_breeding_plan
end

local function copy_entries(entries)
  local copied = {}
  for index, entry in ipairs(entries) do
    PetBreedingPlanEntryDTO.validate(entry)
    copied[index] = PetBreedingPlanEntryDTO.new({
      pet_id = entry.pet_id,
    })
  end
  return copied
end

local function validate_entries(entries)
  for index, entry in ipairs(entries) do
    if type(entry) ~= "table" then
      error("PetBreedingPlanStore.replace_plan: entry at index " .. tostring(index) .. " must be a table")
    end
    PetBreedingPlanEntryDTO.validate(entry)
  end
end

--- replace_plan
--- Responsibility:
---   現 cycle の plan を全置換する。
--- @param cycle_tick uint
--- @param entries table[]
function PetBreedingPlanStore.replace_plan(cycle_tick, entries)
  if type(cycle_tick) ~= "number" then
    error("PetBreedingPlanStore.replace_plan: cycle_tick must be a number")
  end
  if type(entries) ~= "table" then
    error("PetBreedingPlanStore.replace_plan: entries must be a table")
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
--- @return table|nil
function PetBreedingPlanStore.get_entry(step_index)
  if type(step_index) ~= "number" then
    error("PetBreedingPlanStore.get_entry: step_index must be a number")
  end

  local root = ensure_root()
  return root.entries[step_index]
end

--- get_count
--- Responsibility:
---   現 plan の entry 数を返す。
--- @return uint
function PetBreedingPlanStore.get_count()
  local root = ensure_root()
  return #root.entries
end

--- get_cycle_tick
--- Responsibility:
---   現 plan の cycle_tick を返す。
--- @return uint|nil
function PetBreedingPlanStore.get_cycle_tick()
  local root = ensure_root()
  return root.cycle_tick
end

--- clear
--- Responsibility:
---   現 plan をクリアする。
function PetBreedingPlanStore.clear()
  local root = ensure_root()
  root.cycle_tick = nil
  root.entries = {}
end

return PetBreedingPlanStore