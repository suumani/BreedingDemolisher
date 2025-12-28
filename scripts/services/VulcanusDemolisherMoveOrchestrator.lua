-- scripts/services/VulcanusDemolisherMoveOrchestrator.lua
-- ----------------------------
-- Responsibility:
--   Vulcanus専用の「ロケット発射履歴があれば、移動計画（MovePlan）を生成して保存する」処理を統括する。
--   30分イベント側から呼ばれる想定。
-- ----------------------------
local Orchestrator = {}

local RocketLaunchHistoryStore = require("scripts.services.RocketLaunchHistoryStore")
local MovePlanStore = require("scripts.services.VulcanusDemolisherMovePlanStore")
local MovePlanner = require("scripts.services.VulcanusDemolisherMovePlanner")

local DemolisherQuery = require("__Manis_lib__/scripts/queries/DemolisherQuery")
local util  = require("scripts.common.util")

local SURFACE_NAME = "vulcanus"
local MOVE_RATE_CAP = 3
local MAX_PLANNED_TOTAL = 100

function Orchestrator.run_once()
  local positions = RocketLaunchHistoryStore.consume_positions(SURFACE_NAME)
  if not positions or #positions == 0 then
    return 0
  end

  local surface = game.surfaces[SURFACE_NAME]
  if not (surface and surface.valid) then
    return 0
  end

  -- move_rate（発射回数は最大3まで）
  local move_rate = #positions
  if move_rate > MOVE_RATE_CAP then move_rate = MOVE_RATE_CAP end

  -- planned_total（移動予算）
  -- normal含むデモリッシャー数 * evo * 0.5、上限100でクリップする。
  local all_demolishers = DemolisherQuery.find_all_demolishers(surface)

  local demolisher_count = #all_demolishers

  local evo = game.forces.enemy.get_evolution_factor(surface)

  local planned_total = math.floor(demolisher_count * evo * 0.5)

  if planned_total > MAX_PLANNED_TOTAL then planned_total = MAX_PLANNED_TOTAL end
  if planned_total <= 0 then
    util.debug({"", "[BossDemolisher][", SURFACE_NAME, "] move plan skipped (planned_total=0)"})
    return 0
  end

  if planned_total <= 0 then
    util.debug({"", "[BossDemolisher][", SURFACE_NAME, "] move plan skipped (planned_total=0)"})
    return 0
  end

  local plan = MovePlanner.build_plan(planned_total, positions)
  if not plan then
    util.debug({"", "[BossDemolisher][", SURFACE_NAME, "] move plan build failed"})
    return 0
  end

  MovePlanStore.set(plan)

  util.debug({"", "[BossDemolisher][", SURFACE_NAME, "] move plan created total=", planned_total, " cells=", plan.rows * plan.cols, " move_rate=", move_rate})
  return planned_total
end

return Orchestrator