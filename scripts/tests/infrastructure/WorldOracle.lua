-- __BreedingDemolisher__/scripts/tests/infrastructure/WorldOracle.lua
-- ------------------------------------------------------------
-- Responsibility:
--   World-state oracle for BD tests (primary oracle).
--   - Observe respawn_queue size
--   - Observe physical/virtual demolisher counts when needed
-- ------------------------------------------------------------
local O = {}

local VirtualMgr = require("__Manis_lib__/scripts/managers/VirtualEntityManager")
local DemolisherQuery = require("__Manis_lib__/scripts/queries/DemolisherQuery")

function O.respawn_queue_size()
  local q = storage and storage.respawn_queue
  return (q and #q) or 0
end

function O.count_virtual(surface)
  return VirtualMgr.count(surface)
end

function O.count_physical(surface)
  local ents = DemolisherQuery.find_demolishers(surface) or {}
  local c = 0
  for _, e in pairs(ents) do
    if e and e.valid then c = c + 1 end
  end
  return c
end

return O