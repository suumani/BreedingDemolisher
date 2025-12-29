-- __BreedingDemolisher__/scripts/services/VulcanusDemolisherMovePlanStore.lua
-- ----------------------------
-- Responsibility:
--   Vulcanus用の移動計画（MovePlan）を storage に保存/取得/破棄する。
--   entity参照は保持しない（チャンク外で同一性が失われる問題を回避）。
-- ----------------------------
local S = {}

local STORAGE_KEY = "bd_vulcanus_move_plan"

function S.get()
  return storage[STORAGE_KEY]
end

function S.set(plan)
  storage[STORAGE_KEY] = plan
end

function S.clear()
  storage[STORAGE_KEY] = nil
end

return S