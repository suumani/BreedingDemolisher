-- __BreedingDemolisher__/scripts/events/on_nth_tick_1sec_pet_chart.lua
-- ----------------------------
-- Responsibility:
--   Drive PetChartJobService once per second.
-- ----------------------------
local PetChartJobService = require("scripts.services.PetChartJobService")

local function on_tick_1sec()
  -- 1秒に1ジョブだけ、ジョブ内は最大12チャンクを塗る（調整ポイント）
  PetChartJobService.process_step(1, 12)
end

script.on_nth_tick(60, on_tick_1sec)