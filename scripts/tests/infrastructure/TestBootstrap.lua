-- scripts/tests/infrastructure/TestBootstrap.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Bootstrap utilities for BD test packs.
--   - Enable a pack in TestRuntime.
--   - Clear test-owned transient storage keys if requested.
-- ------------------------------------------------------------
local B = {}

local Runtime = require("scripts.tests.infrastructure.TestRuntime")

local function clear_virtual_store()
  storage.virtual_entities = nil
  storage.virtual_id_seq = nil
end

function B.start_pack(pack_id, opts)
  opts = opts or {}
  storage = storage or {}

  Runtime.enable(pack_id)

  if opts.clear_virtual then
    clear_virtual_store()
  end

  -- respawn_queue is BD-owned transient (safe for repeatability)
  if opts.clear_respawn_queue then
    storage.respawn_queue = {}
  end
end

function B.end_pack()
  Runtime.disable()
end

return B