-- __BreedingDemolisher__/scripts/events/on_nth_tick_30min_wild_reproduction_stats.lua
-- ------------------------------------------------------------
-- Responsibility:
--   30分ごとに wild reproduction 統計を全playerへ通知する。
--   - 現在の30分窓の孵化件数を読む。
--   - locale 付きメッセージを game.print で表示する。
--   - 表示後に統計をリセットする。
--
-- Notes:
--   - 件数が0でも必ず表示する。
--   - vulcanus の (0, 0) chunk が generated になるまでは何もしない。
--   - 未到着期間は統計表示対象外とし、統計もリセットしない。
--   - 本イベントは TJC や job chain に依存しない。
-- ------------------------------------------------------------
local Logger = require("scripts.infrastructure.logging.Logger")
local WildReproductionStatsStore = require("scripts.infrastructure.runtime.WildReproductionStatsStore")

local TICKS_PER_30MIN = 60 * 60 * 30
local VULCANUS_SURFACE_NAME = "vulcanus"

local function is_vulcanus_opened()
  local surface = game.surfaces[VULCANUS_SURFACE_NAME]
  if surface == nil or surface.valid == false then
    return false
  end

  return surface.is_chunk_generated({ x = 0, y = 0 })
end

local function resolve_message(count)
  if count == 0 then
    return { "bd.message.bd-wild-reproduction-summary-zero" }
  end

  return { "bd.message.bd-wild-reproduction-summary-positive", count }
end

local function on_nth_tick_30min(_event)
  if is_vulcanus_opened() ~= true then
    return
  end

  local count = WildReproductionStatsStore.get_count()
  local message = resolve_message(count)

  game.print(message)

  Logger.info({
    event = "WILD_REPRODUCTION_30MIN_SUMMARY",
    hatched_count = count,
  })

  WildReproductionStatsStore.reset()
end

script.on_nth_tick(TICKS_PER_30MIN, on_nth_tick_30min)