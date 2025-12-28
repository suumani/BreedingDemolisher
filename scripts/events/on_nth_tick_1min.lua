-- scripts/events/on_nth_tick_1min.lua

local MyDemolisherGettingHangryService = require("scripts.services.MyDemolisherGettingHangryService")
local MyDemolisherBreedingService = require("scripts.services.MyDemolisherBreedingService")
local SpawnWildDemolishersService = require("scripts.services.SpawnWildDemolishersService")

local VulcanusDemolisherMovePlanRunner = require("scripts.services.VulcanusDemolisherMovePlanRunner")

local function on_nth_tick_1min(event)
  local vulcanus_surface = game.surfaces["vulcanus"]
  if not vulcanus_surface then
    return
  end

  -- 移動計画があれば1ステップ消費（最大cap体）
  VulcanusDemolisherMovePlanRunner.run_one_step_if_present()

  MyDemolisherGettingHangryService.my_demolisher_getting_hangry()
  MyDemolisherBreedingService.my_demolisher_breeding()
  SpawnWildDemolishersService.spawn_wild_demolishers(vulcanus_surface)
end

script.on_nth_tick(3600, on_nth_tick_1min)