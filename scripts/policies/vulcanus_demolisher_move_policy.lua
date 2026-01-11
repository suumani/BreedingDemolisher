-- scripts/policies/vulcanus_demolisher_move_policy.lua
-- ----------------------------
-- Responsibility:
--   Vulcanusデモリッシャー移動に関する「Mod固有のポリシー」を提供する。
--   （閾値、move_rate算出など）
-- ----------------------------
local Policy = {}

local DemolisherNames = require("__Manis_definitions__/scripts/definition/DemolisherNames")

-- 進化度による移動可否（このModの閾値）
local thresholds = {
  [DemolisherNames.SMALL]  = 0.4,
  [DemolisherNames.MEDIUM] = 0.7,
  [DemolisherNames.BIG]    = 0.9
}

-- (name, evo) -> boolean
function Policy.can_move(name, evo)
  local t = thresholds[name]
  return t ~= nil and evo > t
end

-- ロケット候補数から move_rate を決める（最大3）
function Policy.compute_move_rate(rocket_positions)
  local n = rocket_positions and #rocket_positions or 0
  if n > 3 then n = 3 end
  return n
end

return Policy