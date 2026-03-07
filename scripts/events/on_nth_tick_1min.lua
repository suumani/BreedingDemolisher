-- __BreedingDemolisher__/scripts/events/on_nth_tick_1min.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Pet runtime の 1分 tick 処理を行う。
--
-- Scope:
--   - pet hunger
--   - pet aging
--
-- Notes:
--   - Pet Breeding は TJC job に移管済みのため扱わない。
--   - Wild Reproduction は扱わない。
-- ------------------------------------------------------------
local MyDemolisherGettingHangryService = require("scripts.services.MyDemolisherGettingHangryService")

local function on_nth_tick_1min(_event)
  MyDemolisherGettingHangryService.my_demolisher_getting_hangry()
end

script.on_nth_tick(3600, on_nth_tick_1min)