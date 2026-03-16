-- __BreedingDemolisher__/scripts/events/on_nth_tick_1sec_pet_chart.lua
-- ----------------------------
-- Responsibility:
--   Drive PetChartJobService once per second.
--
-- Scope:
--   - process 1 pet-chart job step per second
--   - event boundary protection by pcall
--
-- Notes:
--   - pcall は event boundary にのみ配置し、失敗は Logger へ明示記録する。
-- ----------------------------
local PetChartJobService = require("scripts.services.PetChartJobService")
local Logger = require("scripts.services.Logger")

local function on_tick_1sec_handler(_event)
  -- 1秒に1ジョブだけ、ジョブ内は最大12チャンクを塗る（調整ポイント）
  PetChartJobService.process_step(1, 12)
end

script.on_nth_tick(60, function(event)
  local ok, err = pcall(on_tick_1sec_handler, event)
  if not ok then
    Logger.error({
      event = "on_nth_tick_1sec_pet_chart",
      error = tostring(err),
      tick = game and game.tick or nil,
      nth_tick = 60,
    })
  end
end)