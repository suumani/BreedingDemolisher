-- __BreedingDemolisher__/scripts/boundary/tjc/PetBreedingTargetMod.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Pet Breeding job の TJC 向け target module。
--   - mod_key を定義する。
--   - planning_request を PlanningService へ委譲する。
--   - execution_request を ExecutionService へ委譲する。
--
-- Scope:
--   - mod_key 定義
--   - planning_request の委譲
--   - execution_request の委譲
--
-- Notes:
--   - script.on_event の登録は行わない。
--   - 実イベント接続は BreedingDemolisherTjcGateway が担当する。
-- ------------------------------------------------------------
local PetBreedingTargetMod = {}

local PetBreedingPlanningService = require("scripts.application.pet_breeding.PetBreedingPlanningService")
local PetBreedingExecutionService = require("scripts.application.pet_breeding.PetBreedingExecutionService")

local MOD_KEY = "breeding_demolisher_pet_breeding"

function PetBreedingTargetMod.get_mod_key()
  return MOD_KEY
end

function PetBreedingTargetMod.handle_planning_request(cycle_tick)
  return PetBreedingPlanningService.plan(cycle_tick)
end

function PetBreedingTargetMod.handle_execution_request(step_index)
  return PetBreedingExecutionService.execute_step(step_index)
end

return PetBreedingTargetMod