-- scripts/services/VulcanusDemolisherBreedingOrchestrator.lua
-- ----------------------------
-- Responsibility:
--   Vulcanus専用の「繁殖（卵のキュー投入）」処理を1回分実行する。
--   surface取得とevolution取得を内包し、イベント側を薄くする。
-- ----------------------------
local O = {}

local DemolisherRushService = require("scripts.services.DemolisherRushService")

local SURFACE_NAME = "vulcanus"

function O.run_once()
  local surface = game.surfaces[SURFACE_NAME]
  if not surface then
    return
  end

  local evolution_factor = game.forces.enemy.get_evolution_factor(surface)
  DemolisherRushService.demolisher_rush(surface, evolution_factor)
end

return O