-- __BreedingDemolisher__/control.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Breeding Demolisher の control stage 入口を定義する。
--   - on_init / on_configuration_changed / on_load のイベント境界を登録する。
--   - bootstrap 境界のみ pcall で保護する。
--   - 失敗時は最小限の boot ログを出力する。
--
-- Notes:
--   - すべてのイベント登録は本ファイルで行う。
-- ------------------------------------------------------------

require("scripts.defines.constant_demolisher_parameters")
require("scripts.defines.constant_demolisher_traits")

require("scripts.events.on_breeding_demolisher_mouse_button_2")
require("scripts.events.on_entity_died")
require("scripts.events.on_object_destroyed")
require("scripts.events.on_selected_entity_changed")
require("scripts.events.on_segmented_unit_died")
require("scripts.events.on_nth_tick_1min")
require("scripts.events.on_nth_tick_1sec_pet_chart")
require("scripts.events.on_nth_tick_30min_wild_reproduction_stats")

require("scripts.gui.selected_demolisher_gui")
require("scripts.commands.bd_debug_commands")

local Bootstrap = require("scripts.core.Bootstrap")

local BOOT_TAG = "BreedingDemolisher"
local BOOT_PHASE_TAG = "BOOT"

local function boot_log_error(context, err)
  log("[" .. BOOT_TAG .. "][ERROR][" .. BOOT_PHASE_TAG .. "] " .. tostring(context) .. ": " .. tostring(err))
end

local function on_init_handler()
  Bootstrap.on_init()
end

local function on_load_handler()
  Bootstrap.on_load()
end

local function on_configuration_changed_handler(event)
  Bootstrap.on_configuration_changed(event)
end

script.on_init(function()
  local ok, err = pcall(on_init_handler)
  if not ok then
    boot_log_error("on_init", err)
  end
end)

script.on_load(function()
  local ok, err = pcall(on_load_handler)
  if not ok then
    boot_log_error("on_load", err)
  end
end)

script.on_configuration_changed(function(event)
  local ok, err = pcall(on_configuration_changed_handler, event)
  if not ok then
    boot_log_error("on_configuration_changed", err)
  end
end)