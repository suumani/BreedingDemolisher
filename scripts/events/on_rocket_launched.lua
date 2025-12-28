-- ----------------------------
-- ロケット打ち上げイベント
-- scripts/events/on_rocket_launched.lua
-- ----------------------------

local RocketLaunchHistoryStore = require("scripts.services.RocketLaunchHistoryStore")

script.on_event(defines.events.on_rocket_launched, function(event)
  local silo = event.rocket_silo
  if not silo or not silo.valid then
    return
  end

  local surface = silo.surface
  if not surface or not surface.valid or surface.name ~= "vulcanus" then
    return
  end

  -- ロケット履歴を記録（30分移動イベント用）
  RocketLaunchHistoryStore.add(surface.name, silo.position)
end)