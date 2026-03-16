-- __BreedingDemolisher__/control.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Breeding Demolisher control stage bootstrap.
--   - Initialize runtime state on init/configuration changed.
--   - Restore runtime-only bindings on save load.
--   - Reconnect and re-register TJC integration on every bootstrap boundary,
--     including on_load, because TJC dispatch requires target-mod registration.
--   - Protect bootstrap boundaries by pcall and write minimal boot logs on failure.
-- ------------------------------------------------------------

require("scripts.defines.constant_demolisher_parameters")
require("scripts.defines.constant_demolisher_traits")

require("scripts.common.customparam")
require("scripts.common.game_print")
require("scripts.common.util")

require("scripts.events.on_breeding_demolisher_mouse_button_2")
require("scripts.events.on_entity_died")
require("scripts.events.on_object_destroyed")
require("scripts.events.on_selected_entity_changed")
require("scripts.events.on_nth_tick_1min")
require("scripts.events.on_nth_tick_1sec_pet_chart")

require("scripts.gui.selected_demolisher_gui")
require("scripts.commands.bd_debug_commands")

local DeterministicRandom = require("scripts.core.services.DeterministicRandom")
local SaveRestoreService = require("scripts.services.SaveRestoreService")
local ForceInitializer = require("scripts.services.ForceInitializer")
local StorageInitializer = require("scripts.services.StorageInitializer")
local BreedingDemolisherTjcGateway = require("scripts.boundary.tjc.BreedingDemolisherTjcGateway")

local BOOT_TAG = "BreedingDemolisher"
local BOOT_PHASE_TAG = "BOOT"

local function boot_log_error(context, err)
  log("[" .. BOOT_TAG .. "][ERROR][" .. BOOT_PHASE_TAG .. "] " .. tostring(context) .. ": " .. tostring(err))
end

local function init()
  DeterministicRandom.init()
  StorageInitializer.init_all()
  ForceInitializer.ensure_demolishers_force()
  BreedingDemolisherTjcGateway.bootstrap()
end

local function on_init_handler()
  init()
end

local function on_load_handler()
  SaveRestoreService.on_load_restore()
  BreedingDemolisherTjcGateway.bootstrap()
end

local function on_configuration_changed_handler(_event)
  init()
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