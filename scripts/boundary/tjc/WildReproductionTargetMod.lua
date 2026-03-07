-- __BreedingDemolisher__/scripts/boundary/tjc/WildReproductionTargetMod.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Wild Reproduction job の TJC 向け target module として、
--   mod_key と planning / execution の委譲入口を提供する。
--
-- Scope:
--   - mod_key 定義
--   - planning_request の処理委譲
--   - execution_request の処理委譲
--
-- Notes:
--   - script.on_event 登録は行わない。
--   - 実イベント接続は BreedingDemolisherTjcGateway が担う。
-- ------------------------------------------------------------
local WildReproductionTargetMod = {}

local WildReproductionPlanningService = require("scripts.application.reproduction.WildReproductionPlanningService")
local WildReproductionExecutionService = require("scripts.application.reproduction.WildReproductionExecutionService")

local MOD_KEY = "breeding_demolisher_wild_reproduction"

function WildReproductionTargetMod.get_mod_key()
  return MOD_KEY
end

function WildReproductionTargetMod.handle_planning_request(cycle_tick)
  return WildReproductionPlanningService.plan(cycle_tick)
end

function WildReproductionTargetMod.handle_execution_request(step_index)
  WildReproductionExecutionService.execute_step(step_index)
end

return WildReproductionTargetMod