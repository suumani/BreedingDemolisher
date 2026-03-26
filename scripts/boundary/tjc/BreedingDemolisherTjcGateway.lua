-- __BreedingDemolisher__/scripts/boundary/tjc/BreedingDemolisherTjcGateway.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Breeding Demolisher の TJC 境界窓口。
--   - TJC の event id を runtime で解決する。
--   - planning / execution request を mod_key に応じて
--     対応する TargetMod へ委譲する。
--   - planning_count_report / execution_done_report を送信する。
--   - bootstrap 時に runtime event binding と
--     target mod registration を行う。
--
-- Contract:
--   - bootstrap() は on_init / on_configuration_changed / on_load から呼ばれる。
--   - on_load でも register_target_mod を再送する。
--   - 本クラスは runtime event binding と TJC 再登録を担当する。
--
-- Notes:
--   - planning_request / execution_request は TJC 共通 event を購読するため、
--     他 mod 宛ての payload が到着しうる。
--   - mod_key が BD 管轄外の場合は異常ではないため、無言で無視する。
--   - payload 構造不正のみ INVALID としてログ出力する。
-- ------------------------------------------------------------
local BreedingDemolisherTjcGateway = {}

local Logger = require("scripts.infrastructure.logging.Logger")

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

local function refresh_event_ids()
  EVENT_IDS = nil
  return get_event_ids()
end

local function log_register(mod_key)
  Logger.info({
    event = "BD_TJC_REGISTER_TARGET_MOD",
    result = "OK",
    reason = "TJC:REGISTER_TARGET_MOD",
    mod_key = mod_key,
  })
end

local function log_invalid_payload(event_name, reason, detail)
  Logger.info({
    event = event_name,
    result = "FAIL",
    reason = reason,
    error = detail and detail.error or nil,
    mod_key = detail and detail.mod_key or nil,
    mod_key_type = detail and detail.mod_key_type or nil,
    payload_type = detail and detail.payload_type or nil,
    cycle_tick = detail and detail.cycle_tick or nil,
    cycle_tick_type = detail and detail.cycle_tick_type or nil,
    step_index = detail and detail.step_index or nil,
    step_index_type = detail and detail.step_index_type or nil,
  })
end

local function log_planning_result(mod_key, cycle_tick, planning_dto, count)
  Logger.info({
    event = "BD_TJC_PLANNING_RESULT",
    mod_key = mod_key,
    cycle_tick = cycle_tick,
    ok = planning_dto and planning_dto.ok or nil,
    result = planning_dto and planning_dto.result or nil,
    reason = planning_dto and planning_dto.reason or nil,
    count = count,
  })
end

local function log_execution_done(mod_key, step_index)
  Logger.info({
    event = "BD_TJC_EXECUTION_DONE",
    result = "OK",
    reason = "TJC:EXECUTION_DONE",
    mod_key = mod_key,
    step_index = step_index,
  })
end

local function log_bootstrap_skipped()
  Logger.info({
    event = "BD_TJC_BOOTSTRAP_SKIPPED",
    result = "FAIL",
    reason = "TJC:EVENT_IDS_UNAVAILABLE",
    action = "BOOTSTRAP_GATEWAY",
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

local function coerce_planning_count(planning_dto)
  if type(planning_dto) ~= "table" then
    return 0
  end

  if type(planning_dto.detail) ~= "table" then
    return 0
  end

  if type(planning_dto.detail.count) ~= "number" then
    return 0
  end

  return planning_dto.detail.count
end

local function resolve_target_from_payload(payload, event_name)
  if type(payload) ~= "table" then
    log_invalid_payload(event_name, "TJC:INVALID_PAYLOAD", {
      error = "payload_not_table",
      payload_type = type(payload),
    })
    return nil
  end

  if type(payload.mod_key) ~= "string" or payload.mod_key == "" then
    log_invalid_payload(event_name, "TJC:INVALID_PAYLOAD", {
      error = "mod_key_invalid",
      mod_key_type = type(payload.mod_key),
      mod_key = payload.mod_key,
    })
    return nil
  end

  local target = TARGETS[payload.mod_key]
  if target == nil then
    return nil
  end

  return target
end

local function on_planning_request(event)
  local payload = event
  local target = resolve_target_from_payload(payload, "BD_TJC_PLANNING_REQUEST_INVALID")
  if target == nil then
    return
  end

  if type(payload.cycle_tick) ~= "number" then
    log_invalid_payload("BD_TJC_PLANNING_REQUEST_INVALID", "TJC:INVALID_PAYLOAD", {
      error = "cycle_tick_invalid",
      mod_key = payload.mod_key,
      cycle_tick_type = type(payload.cycle_tick),
      cycle_tick = payload.cycle_tick,
    })
    return
  end

  local planning_dto = target.handle_planning_request(payload.cycle_tick)
  local count = coerce_planning_count(planning_dto)

  log_planning_result(payload.mod_key, payload.cycle_tick, planning_dto, count)
  raise_planning_count_report(payload.mod_key, count)
end

local function on_execution_request(event)
  local payload = event
  local target = resolve_target_from_payload(payload, "BD_TJC_EXECUTION_REQUEST_INVALID")
  if target == nil then
    return
  end

  if type(payload.step_index) ~= "number" then
    log_invalid_payload("BD_TJC_EXECUTION_REQUEST_INVALID", "TJC:INVALID_PAYLOAD", {
      error = "step_index_invalid",
      mod_key = payload.mod_key,
      step_index_type = type(payload.step_index),
      step_index = payload.step_index,
    })
    return
  end

  target.handle_execution_request(payload.step_index)
  raise_execution_done_report(payload.mod_key, payload.step_index)
  log_execution_done(payload.mod_key, payload.step_index)
end

local function bind_runtime_events(ids)
  script.on_event(ids.planning_request, on_planning_request)
  script.on_event(ids.execution_request, on_execution_request)
end

local function raise_register_target_mods(ids)
  for mod_key, _target in pairs(TARGETS) do
    script.raise_event(ids.register_target_mod, {
      mod_key = mod_key,
    })
    log_register(mod_key)
  end
end

function BreedingDemolisherTjcGateway.bootstrap()
  local ids = refresh_event_ids()
  if not ids then
    log_bootstrap_skipped()
    return false
  end

  bind_runtime_events(ids)
  raise_register_target_mods(ids)
  return true
end

return BreedingDemolisherTjcGateway