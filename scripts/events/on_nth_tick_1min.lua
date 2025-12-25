-- ----------------------------
-- タイマーイベント
-- ----------------------------

local LimitLifeSpanService = require("scripts.services.LimitLifeSpanService")
local MyDemolisherGettingHangryService = require("scripts.services.MyDemolisherGettingHangryService")
local MyDemolisherBreedingService = require("scripts.services.MyDemolisherBreedingService")
local KillWildDemolishersService = require("scripts.services.KillWildDemolishersService")
local SpawnWildDemolishersService = require("scripts.services.SpawnWildDemolishersService")

-- ----------------------------
-- 毎分イベント
-- ----------------------------

local function on_nth_tick_1min(event)
  -- vulcanus 無ければ対処なし
  local vulcanus_surface = game.surfaces["vulcanus"]
  if not vulcanus_surface then
    return
  end

  -- vulcanusのデモリッシャーに寿命を付与
  LimitLifeSpanService.limit_lifespan(vulcanus_surface)

  -- ペットおなかが減る 1分
  MyDemolisherGettingHangryService.my_demolisher_getting_hangry()

  -- ペット産卵する 1分
  MyDemolisherBreedingService.my_demolisher_breeding()

  -- 野生のデモリッシャー自然死 1分
  KillWildDemolishersService.kill_wild_demolishers(vulcanus_surface)

  -- 野生のデモリッシャー発生 1分
  SpawnWildDemolishersService.spawn_wild_demolishers(vulcanus_surface)
end

script.on_nth_tick(3600, on_nth_tick_1min)

