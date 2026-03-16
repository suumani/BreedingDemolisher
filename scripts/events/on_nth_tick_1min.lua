-- __BreedingDemolisher__/scripts/events/on_nth_tick_1min.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Pet runtime の 1分 tick 処理を行う。
--
-- Scope:
--   - pet hunger
--   - pet aging
--   - event boundary protection by pcall
--
-- Notes:
--   - Pet Breeding は TJC job に移管済みのため扱わない。
--   - Wild Reproduction は扱わない。
--   - pcall は event boundary にのみ配置し、失敗は Logger へ明示記録する。
-- ------------------------------------------------------------
local MyDemolisherGettingHangryService = require("scripts.services.MyDemolisherGettingHangryService")
local Logger = require("scripts.services.Logger")

local function on_nth_tick_1min_handler(_event)
  MyDemolisherGettingHangryService.my_demolisher_getting_hangry()
end

script.on_nth_tick(3600, function(event)
  local ok, err = pcall(on_nth_tick_1min_handler, event)
  if not ok then
    Logger.error({
      event = "on_nth_tick_1min",
      error = tostring(err),
      tick = game and game.tick or nil,
      nth_tick = 3600,
    })
  end
end)