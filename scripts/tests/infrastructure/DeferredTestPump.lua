-- scripts/tests/infrastructure/DeferredTestPump.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Central pump to resume deferred tests.
--   - Called from a stable tick event (e.g., 1-min nth_tick) to process due deferred tasks.
-- Notes:
--   - This is test-only infrastructure.
--   - No scheduling here; the caller decides when to call Pump.pump().
-- ------------------------------------------------------------
local Pump = {}

local Runner = require("scripts.tests.infrastructure.DeferredTestRunner")

function Pump.pump()
  Runner._pump()
end

return Pump