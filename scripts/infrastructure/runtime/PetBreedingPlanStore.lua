-- __BreedingDemolisher__/scripts/infrastructure/runtime/PetBreedingPlanStore.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Runtime-only で Pet Breeding plan を保持する。
--
-- Scope:
--   - cycle_tick ごとの plan 全置換
--   - step_index -> pet_id 解決
--   - plan count 取得
--   - clear
--
-- Notes:
--   - 永続 source ではない。
--   - entry shape:
--       {
--         pet_id = string,
--       }
-- ------------------------------------------------------------
local PetBreedingPlanStore = {}

local function ensure_root()
  storage.bd = storage.bd or {}
  storage.bd.runtime = storage.bd.runtime or {}
  storage.bd.runtime.pet_breeding_plan = storage.bd.runtime.pet_breeding_plan or {
    cycle_tick = nil,
    entries = {},
  }
  return storage.bd.runtime.pet_breeding_plan
end

function PetBreedingPlanStore.replace_plan(cycle_tick, entries)
  if type(cycle_tick) ~= "number" then
    error("PetBreedingPlanStore.replace_plan: cycle_tick must be a number")
  end
  if type(entries) ~= "table" then
    error("PetBreedingPlanStore.replace_plan: entries must be a table")
  end

  local root = ensure_root()
  root.cycle_tick = cycle_tick
  root.entries = entries
end

function PetBreedingPlanStore.get_entry(step_index)
  if type(step_index) ~= "number" then
    error("PetBreedingPlanStore.get_entry: step_index must be a number")
  end

  local root = ensure_root()
  return root.entries[step_index]
end

function PetBreedingPlanStore.get_count()
  local root = ensure_root()
  return #root.entries
end

function PetBreedingPlanStore.get_cycle_tick()
  local root = ensure_root()
  return root.cycle_tick
end

function PetBreedingPlanStore.clear()
  local root = ensure_root()
  root.cycle_tick = nil
  root.entries = {}
end

return PetBreedingPlanStore