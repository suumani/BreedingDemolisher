-- __BreedingDemolisher__/scripts/services/VulcanusDemolisherMoveOrchestrator.lua
-- ----------------------------
-- Responsibility:
--   Vulcanus専用の「ロケット発射履歴があれば、移動計画（MovePlan）を生成して保存する」処理を統括する。
--   30分イベント側から呼ばれる想定。
--
--   Lib側の共通要素（RocketLaunchHistoryStore / DemolisherMovePlanner）を使用し、
--   本ファイルは結線と planned_total 算出・保存のみを担当する。
-- ----------------------------
local Orchestrator = {}

-- Lib（共通）
local RocketLaunchHistoryStore = require("__Manis_lib__/scripts/domain/demolisher/move/RocketLaunchHistoryStore")
local MovePlanner = require("__Manis_lib__/scripts/domain/demolisher/move/DemolisherMovePlanner")
local DemolisherQuery = require("__Manis_lib__/scripts/queries/DemolisherQuery")

-- Mod（storage所有）
local MovePlanStore = require("scripts.services.VulcanusDemolisherMovePlanStore")

local util  = require("scripts.common.util")
local ModRng = require("scripts.services.ModRandomProvider")

local SURFACE_NAME = "vulcanus"
local MAX_PLANNED_TOTAL = 100

function Orchestrator.run_once()
  local surface = game.surfaces[SURFACE_NAME]
  if not (surface and surface.valid) then
    return 0
  end

  -- TTL内のロケット発射「チャンク中心」一覧（consumeしない）
  local rocket_positions = RocketLaunchHistoryStore.get_positions(SURFACE_NAME, game.tick)
  if not rocket_positions or #rocket_positions == 0 then
    return 0
  end

  -- planned_total（移動予算）
  -- normal含むデモリッシャー数 * evo * 0.5、上限100でクリップする。
  local all_demolishers = DemolisherQuery.find_all_demolishers(surface)
  local demolisher_count = #all_demolishers

  local evo = game.forces.enemy.get_evolution_factor(surface)
  local planned_total = math.floor(demolisher_count * evo * 0.5)

  if planned_total > MAX_PLANNED_TOTAL then planned_total = MAX_PLANNED_TOTAL end
  if planned_total <= 0 then
    util.debug({"", "[DemolisherMove][", SURFACE_NAME, "] move plan skipped (planned_total=0)"})
    return 0
  end

  local rng = ModRng.get()
  local plan = MovePlanner.build_plan(SURFACE_NAME, planned_total, rocket_positions, rng)

  if not plan then
    util.debug({"", "[DemolisherMove][", SURFACE_NAME, "] move plan build failed"})
    return 0
  end

  MovePlanStore.set(plan)

  util.debug({
    "",
    "[DemolisherMove][", SURFACE_NAME, "] move plan created total=", planned_total,
    " cells=", plan.rows * plan.cols,
    " rocket_chunks=", #rocket_positions
  })

  return planned_total
end

return Orchestrator