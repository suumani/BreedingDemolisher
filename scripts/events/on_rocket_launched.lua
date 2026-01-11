-- __BreedingDemolisher __/scripts/events/on_rocket_launched.lua

-- ----------------------------
-- ロケット打ち上げイベント
-- ----------------------------
local RocketLaunchHistoryStore = require("__Manis_lib__/scripts/domain/demolisher/move/RocketLaunchHistoryStore")
local util        = require("scripts.common.util")

script.on_event(defines.events.on_rocket_launched, function(event)
  util.debug("__BreedingDemolisher defines.events.on_rocket_launched")
  local silo = event.rocket_silo
  if not silo or not silo.valid then
    return
  end

  local surface = silo.surface
  if not surface or not surface.valid or surface.name ~= "vulcanus" then
    return
  end

  -- ロケット履歴を記録（チャンク集約＋TTL）
  RocketLaunchHistoryStore.add(surface.name, silo.position, event.tick)
end)