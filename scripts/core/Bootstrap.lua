-- __BreedingDemolisher__/scripts/core/Bootstrap.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Breeding Demolisher の control stage bootstrap 入口を統括する。
--   - on_init / on_configuration_changed / on_load から呼ばれる入口を提供する。
--   - ImmediateInitializer を起動する。
--   - DeferredInitializer を次tickで一度だけ起動する。
--   - on_load では storage を変更せず、deferred の再登録だけを行う。
--
-- Notes:
--   - Deferred は 1tick で一度だけ実行し、即時解除する。
--   - 既存の on_nth_tick(60, ...) とは干渉しない。
-- ------------------------------------------------------------
local Bootstrap = {}

local ImmediateInitializer = require("scripts.core.ImmediateInitializer")
local DeferredInitializer = require("scripts.core.DeferredInitializer")

local function deferred_on_nth_tick(_event)
  DeferredInitializer.run()
  -- 一度だけ実行して解除
  script.on_nth_tick(1, nil)
end

function Bootstrap.schedule_deferred()
  script.on_nth_tick(1, deferred_on_nth_tick)
end

function Bootstrap.on_init()
  ImmediateInitializer.run()
  Bootstrap.schedule_deferred()
end

function Bootstrap.on_configuration_changed(_event)
  ImmediateInitializer.run()
  Bootstrap.schedule_deferred()
end

function Bootstrap.on_load()
  Bootstrap.schedule_deferred()
end

return Bootstrap