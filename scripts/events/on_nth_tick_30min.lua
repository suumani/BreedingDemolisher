-- ----------------------------
-- タイマーイベント
-- ----------------------------
local DemolisherRushService = require("scripts.services.DemolisherRushService")

-- ----------------------------
-- デモリッシャラッシュ--30分
-- ----------------------------
local function wild_demolisher_breeding()
  local vulcanus_surface = game.surfaces["vulcanus"]
  if vulcanus_surface then
    local evolution_factor = game.forces.enemy.get_evolution_factor(vulcanus_surface)
    DemolisherRushService.demolisher_rush(vulcanus_surface, evolution_factor)
  end
end

-- ----------------------------
-- 30分イベント
-- ----------------------------
local function on_nth_tick_30min(event)
  -- 補足できていない削除対処
  local valid = 0
  local invalid = 0

  for key, value in pairs(storage.new_vulcanus_demolishers) do
    if value.entity.valid then
      valid = valid + 1
    else
      invalid = invalid + 1
      storage.new_vulcanus_demolishers[key] = nil
    end
  end

  -- デモリッシャラッシュ--30分
  wild_demolisher_breeding()
end

script.on_nth_tick(108000, on_nth_tick_30min)