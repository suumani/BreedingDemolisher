-- __BreedingDemolisher__/scripts/boundary/tjc/BreedingDemolisherTjcGateway.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Breeding Demolisher 内の複数 target job を、
--   単一の TJC event handler で受けて mod_key に応じて振り分ける。
--
-- Scope:
--   - TJC event id discovery
--   - register_target_mod 送信
--   - planning_request 受信
--   - execution_request 受信
--   - planning_count_report 送信
--   - execution_done_report 送信
--   - 最小限の observability
-- ------------------------------------------------------------
local BreedingDemolisherTjcGateway = {}

local Logger = require("scripts.services.Logger")

local WildReproductionTargetMod = require("scripts.boundary.tjc.WildReproductionTargetMod")
local PetBreedingTargetMod = require("scripts.boundary.tjc.PetBreedingTargetMod")

local EVENT_IDS = nil

local TARGETS = {
  [WildReproductionTargetMod.get_mod_key()] = WildReproductionTargetMod,
  [PetBreedingTargetMod.get_mod_key()] = PetBreedingTargetMod,
}

local function get_event_ids()
  if EVENT_IDS ~= nil then
    return EVENT_IDS
  end

  if not remote.interfaces["manis_total_job_controller"] then
    return nil
  end

  EVENT_IDS = remote.call("manis_total_job_controller", "get_event_ids")
  return EVENT_IDS
end

local function log_register(mod_key)
  Logger.info({
    "[BreedingDemolisher][TJC][Register][OK]",
    " mod_key=", tostring(mod_key),
  })
end

local function raise_planning_count_report(mod_key, count)
  local ids = get_event_ids()
  if not ids or not ids.planning_count_report then
    return
  end

  script.raise_event(ids.planning_count_report, {
    mod_key = mod_key,
    count = count,
  })
end

local function raise_execution_done_report(mod_key, step_index)
  local ids = get_event_ids()
  if not ids or not ids.execution_done_report then
    return
  end

  script.raise_event(ids.execution_done_report, {
    mod_key = mod_key,
    step_index = step_index,
  })
end

local function on_planning_request(event)
  local payload = event
  local target = TARGETS[payload.mod_key]
  if target == nil then
    return
  end

  local count = target.handle_planning_request(payload.cycle_tick)
  raise_planning_count_report(payload.mod_key, count)
end

local function on_execution_request(event)
  local payload = event
  local target = TARGETS[payload.mod_key]
  if target == nil then
    return
  end

  target.handle_execution_request(payload.step_index)
  raise_execution_done_report(payload.mod_key, payload.step_index)
end

function BreedingDemolisherTjcGateway.register()
  local ids = get_event_ids()
  if not ids then
    return false
  end

  script.on_event(ids.planning_request, on_planning_request)
  script.on_event(ids.execution_request, on_execution_request)

  for mod_key, _target in pairs(TARGETS) do
    script.raise_event(ids.register_target_mod, {
      mod_key = mod_key,
    })
    log_register(mod_key)
  end

  return true
end

return BreedingDemolisherTjcGateway