-- scripts/tests/infrastructure/TestConfig.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Pack-level deterministic configuration store for BreedingDemolisher.
--   - Holds knobs for tests (scheduler ticks, optional overrides).
--   - Separated by pack_id.
-- ------------------------------------------------------------
local C = {}
local STORAGE_KEY = "bd_test_config"

local function root()
  storage[STORAGE_KEY] = storage[STORAGE_KEY] or {}
  return storage[STORAGE_KEY]
end

local function peek_root()
  return storage and storage[STORAGE_KEY] or nil
end

local function ensure_pack(pack_id)
  local r = root()
  r.packs = r.packs or {}
  r.packs[pack_id] = r.packs[pack_id] or {}
  return r.packs[pack_id]
end

local function get_pack(pack_id)
  local r = peek_root()
  local packs = r and r.packs
  return packs and packs[pack_id] or nil
end

function C.clear_all()
  storage[STORAGE_KEY] = nil
end

function C.clear_pack(pack_id)
  local r = peek_root()
  if not r or not r.packs then return end
  r.packs[pack_id] = nil
end

-- Scheduler ticks (pack-level)
function C.set_scheduler_ticks(pack_id, scheduler_key, ticks)
  local p = ensure_pack(pack_id)
  p.schedulers = p.schedulers or {}
  p.schedulers[scheduler_key] = ticks
end

function C.get_scheduler_ticks(pack_id, scheduler_key)
  local p = get_pack(pack_id)
  local s = p and p.schedulers
  return s and s[scheduler_key] or nil
end

return C