-- __BreedingDemolisher__/control.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Breeding Demolisher control stage bootstrap.
-- ------------------------------------------------------------

require("scripts.defines.constant_demolisher_parameters")
require("scripts.defines.constant_demolisher_traits")
require("scripts.defines.constant_quality")

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

local function init()
  DeterministicRandom.init()
  StorageInitializer.init_all()
  ForceInitializer.ensure_demolishers_force()
  BreedingDemolisherTjcGateway.register()
end

script.on_init(function()
  init()
end)

script.on_load(function()
  SaveRestoreService.on_load_restore()
end)

script.on_configuration_changed(function(_event)
  init()
end)