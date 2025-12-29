-- __BreedingDemolisher__/scripts/events/on_nth_tick_30min.lua

local VulcanusDemolisherBreedingOrchestrator = require("scripts.services.VulcanusDemolisherBreedingOrchestrator")
local VulcanusDemolisherMoveOrchestrator = require("scripts.services.VulcanusDemolisherMoveOrchestrator")

local function on_nth_tick_30min(event)
  storage.respawn_queue = {}
  VulcanusDemolisherBreedingOrchestrator.run_once()
  VulcanusDemolisherMoveOrchestrator.run_once()
end

local TICK_30MIN = 108000

script.on_nth_tick(TICK_30MIN, on_nth_tick_30min)