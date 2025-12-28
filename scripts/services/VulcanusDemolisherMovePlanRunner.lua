-- scripts/services/VulcanusDemolisherMovePlanRunner.lua
-- ----------------------------
-- Responsibility:
--   保存されたMovePlanがあれば、1分ごとに1ステップ消費する。
--   計画完了（20セル消化 or 予算消化）で plan を破棄する。
-- ----------------------------
local R = {}

local MovePlanStore = require("scripts.services.VulcanusDemolisherMovePlanStore")
local Executor = require("scripts.services.VulcanusDemolisherMoveExecutor")

function R.run_one_step_if_present()
  local plan = MovePlanStore.get()
  if not plan then
    return 0
  end

  local cell_count = plan.rows * plan.cols

  -- 既に終わっている
  if plan.moved_so_far >= plan.planned_total or plan.step > cell_count then
    MovePlanStore.clear()
    return 0
  end

  local moved = Executor.execute_one_step(plan)

  -- 更新したplanを保存（参照は同じだが明示）
  MovePlanStore.set(plan)

  -- 終了条件
  if plan.moved_so_far >= plan.planned_total or plan.step > cell_count then
    MovePlanStore.clear()
  end

  return moved
end

return R