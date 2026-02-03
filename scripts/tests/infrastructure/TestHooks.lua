-- scripts/tests/infrastructure/TestHooks.lua
-- ------------------------------------------------------------
-- Responsibility:
--   The ONLY gateway production code may use to cooperate with tests.
--   - Reads TestRuntime + TestConfig and exposes optional overrides.
-- ------------------------------------------------------------
local H = {}

local Runtime = require("scripts.tests.infrastructure.TestRuntime")
local Config  = require("scripts.tests.infrastructure.TestConfig")

function H.is_enabled() return Runtime.is_enabled() end
function H.get_active_pack_id() return Runtime.get_active_pack_id() end

function H.try_get_scheduler_ticks(scheduler_key)
  if not Runtime.is_enabled() then return nil end
  local pack_id = Runtime.get_active_pack_id()
  if not pack_id then return nil end
  return Config.get_scheduler_ticks(pack_id, scheduler_key)
end

function H.get_scheduler_ticks_or_default(scheduler_key, default_ticks)
  local t = H.try_get_scheduler_ticks(scheduler_key)
  if type(t) == "number" and t > 0 then return t end
  return default_ticks
end

function H.try_get_move_min_planned_total()
  if not Runtime.is_enabled() then return nil end
  local pack_id = Runtime.get_active_pack_id()
  if not pack_id then return nil end
  return Config.get_move_min_planned_total(pack_id)
end

function H.try_get_move_evo_override()
  if not Runtime.is_enabled() then return nil end
  local pack_id = Runtime.get_active_pack_id()
  if not pack_id then return nil end
  return Config.get_move_evo_override(pack_id)
end

return H