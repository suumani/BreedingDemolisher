-- __BreedingDemolisher__/control.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Breeding Demolisher の control stage bootstrap 境界を定義する。
--   - on_init / on_configuration_changed / on_load のイベント境界を登録する。
--   - bootstrap 境界のみ pcall で保護する。
--   - 失敗時は最小限の boot ログを出力する。
-- ------------------------------------------------------------

require("scripts.defines.constant_demolisher_parameters")
require("scripts.defines.constant_demolisher_traits")

require("scripts.events.on_breeding_demolisher_mouse_button_2")
require("scripts.events.on_entity_died")
require("scripts.events.on_object_destroyed")
require("scripts.events.on_selected_entity_changed")
require("scripts.events.on_nth_tick_1min")
require("scripts.events.on_nth_tick_1sec_pet_chart")

require("scripts.gui.selected_demolisher_gui")
require("scripts.commands.bd_debug_commands")

local BreedingDemolisherBootstrap = require("scripts.boundary.bootstrap.BreedingDemolisherBootstrap")

local BOOT_TAG = "BreedingDemolisher"
local BOOT_PHASE_TAG = "BOOT"

local function boot_log_error(context, err)
  log("[" .. BOOT_TAG .. "][ERROR][" .. BOOT_PHASE_TAG .. "] " .. tostring(context) .. ": " .. tostring(err))
end

local function on_init_handler()
  BreedingDemolisherBootstrap.run_full_bootstrap()
end

local function on_load_handler()
  BreedingDemolisherBootstrap.run_load_bootstrap()
end

local function on_configuration_changed_handler(_event)
  BreedingDemolisherBootstrap.run_full_bootstrap()
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