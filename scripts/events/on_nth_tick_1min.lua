-- __BreedingDemolisher__/scripts/events/on_nth_tick_1min.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Pet runtime と delayed wild respawn の 1分 tick 処理を行う。
--
-- Scope:
--   - pet hunger
--   - pet aging
--   - delayed wild respawn
--   - event boundary protection by pcall
--
-- Notes:
--   - Pet Breeding は TJC job に移管済みのため扱わない。
--   - Wild Reproduction の planning / execution 自体は扱わない。
--   - delayed wild respawn queue の期限到来処理のみ扱う。
--   - pcall は event boundary にのみ配置し、失敗は Logger へ明示記録する。
-- ------------------------------------------------------------
local MyDemolisherGettingHangryService = require("scripts.domain.pet.MyDemolisherGettingHangryService")
local DelayedWildRespawnService = require("scripts.application.reproduction.DelayedWildRespawnService")
local Logger = require("scripts.infrastructure.logging.Logger")

local function on_nth_tick_1min_handler(event)
  MyDemolisherGettingHangryService.my_demolisher_getting_hangry()
  DelayedWildRespawnService.run(event.tick)
end

script.on_nth_tick(3600, function(event)
  local ok, err = pcall(on_nth_tick_1min_handler, event)
  if not ok then
    Logger.error({
      event = "ON_NTH_TICK_1MIN_FAILED",
      error = tostring(err),
      tick = game and game.tick or nil,
      nth_tick = 3600,
    })
  end
end)