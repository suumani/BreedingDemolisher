-- __BreedingDemolisher__/scripts/boundary/tjc/PetBreedingTargetMod.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Pet Breeding job の TJC 向け target module として、
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
  PetBreedingExecutionService.execute_step(step_index)
end

return PetBreedingTargetMod