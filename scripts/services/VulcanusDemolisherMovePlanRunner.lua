-- __BreedingDemolisher__/scripts/services/VulcanusDemolisherMovePlanRunner.lua
-- ----------------------------
-- Responsibility:
--   保存されたMovePlanがあれば、1分ごとに1ステップ消費する。
--   計画完了（セル消化 or 予算消化）または計画が古すぎる場合に plan を破棄する。
-- ----------------------------
local R = {}

local MovePlanStore = require("scripts.services.VulcanusDemolisherMovePlanStore")
local Executor = require("scripts.services.VulcanusDemolisherMoveExecutor")

local MAX_PLAN_AGE_TICKS = 60 * 60 * 60 -- 60分

local function is_plan_expired(plan)
  if not plan.created_tick then
    return false
  end
  return (game.tick - plan.created_tick) > MAX_PLAN_AGE_TICKS
end

local function is_plan_finished(plan)
  local cell_count = plan.rows * plan.cols
  return (plan.moved_so_far >= plan.planned_total) or (plan.step > cell_count)
end

function R.run_one_step_if_present()
  local plan = MovePlanStore.get()
  if not plan then
    return 0
  end

  -- 古すぎる計画は破棄（TTL切れ等で意味を失っている可能性が高い）
  if is_plan_expired(plan) then
    MovePlanStore.clear()
    return 0
  end

  -- 既に終わっている
  if is_plan_finished(plan) then
    MovePlanStore.clear()
    return 0
  end

  local moved = Executor.execute_one_step(plan)

  -- 実行後に終了条件を満たすなら保存せず破棄
  if is_plan_finished(plan) then
    MovePlanStore.clear()
    return moved
  end

  -- 更新したplanを保存（参照は同じだが明示）
  MovePlanStore.set(plan)
  return moved
end

return R