-- scripts/tests/infrastructure/TestRuntime.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Test runtime context for BreedingDemolisher.
--   - Own the test-mode flag and active pack/scenario identity.
--   - Provide scheduler override knobs (ticks) for test mode.
-- ------------------------------------------------------------
local R = {}
local STORAGE_KEY = "bd_test_runtime"

local function root()
  storage[STORAGE_KEY] = storage[STORAGE_KEY] or {}
  return storage[STORAGE_KEY]
end

function R.is_enabled()
  local t = storage and storage[STORAGE_KEY]
  return (t and t.enabled) == true
end

function R.enable(pack_id)
  local t = root()
  t.enabled = true
  t.active_pack_id = pack_id or t.active_pack_id or "UNKNOWN"
end

function R.disable()
  if storage and storage[STORAGE_KEY] then
    storage[STORAGE_KEY].enabled = false
  end
end

function R.set_active(pack_id, scenario_id)
  local t = root()
  t.active_pack_id = pack_id
  t.active_scenario_id = scenario_id
end

function R.get_active_pack_id()
  local t = storage and storage[STORAGE_KEY]
  return t and t.active_pack_id or nil
end

function R.get_active_scenario_id()
  local t = storage and storage[STORAGE_KEY]
  return t and t.active_scenario_id or nil
end

function R.set_scheduler_override(key, ticks)
  local t = root()
  t.scheduler_overrides = t.scheduler_overrides or {}
  t.scheduler_overrides[key] = ticks
end

function R.get_scheduler_override(key)
  local t = storage and storage[STORAGE_KEY]
  local m = t and t.scheduler_overrides
  return m and m[key] or nil
end

return R