-- __BreedingDemolisher__/scripts/services/VulcanusDemolisherMoveExecutor.lua
-- ----------------------------
-- Responsibility:
--   Lib側の共通実行器（DemolisherMoveStepExecutor）に対して、
--   繁殖Mod固有の「移動対象抽選」と「ポリシー」を注入して1ステップ実行する。
--   乱数状態（LuaRandomGenerator）は本Modのstorageで所有し、deps.get_rngで注入する。
-- ----------------------------
local E = {}

-- Lib共通実行器
local StepExecutor = require("__Manis_lib__/scripts/domain/demolisher/move/DemolisherMoveStepExecutor")

-- 共通クエリ（Lib）
local DemolisherQuery = require("__Manis_lib__/scripts/queries/DemolisherQuery")

-- Mod固有ロジック
local NormalClusterProbe = require("scripts.services.NormalClusterProbe")
local MovePolicy = require("scripts.policies.vulcanus_demolisher_move_policy")
local ModRandomProvider = require("scripts.services.ModRandomProvider")

local util  = require("scripts.common.util")

-- ----------------------------
-- Mod固有：移動対象抽選
--   - manis-small, manis-medium, manis-big限定
-- ----------------------------
local function build_move_targets(surface, area, ctx)
  local move_targets = DemolisherQuery.find_breeding_demolishers_range(surface, area)
  return move_targets
end

-- planからロケット候補座標配列を取得（互換: rocket_positions / positions）
local function get_rocket_positions(plan)
  return plan.rocket_positions or plan.positions
end

function E.execute_one_step(plan)
  return StepExecutor.execute_one_step(plan, {
    get_surface = function(surface_name)
      return game.surfaces[surface_name]
    end,

    get_rocket_positions = get_rocket_positions,
    build_move_targets = build_move_targets,

    compute_move_rate = MovePolicy.compute_move_rate,
    can_move = MovePolicy.can_move,

    -- ★追加：rng注入（本Modのstorageに保持しているRNGを返す）
    get_rng = function()
      return ModRandomProvider.get()
    end,

    log = util.debug
  })
end

return E