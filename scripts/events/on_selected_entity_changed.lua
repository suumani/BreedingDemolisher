-- __BreedingDemolisher__/scripts/events/on_selected_entity_changed.lua
-- ----------------------------
-- Responsibility:
--   Refresh demolisher info GUI when the player's selected entity changes.
-- ----------------------------
local SelectedDemolisherGui = require("scripts.gui.selected_demolisher_gui")

script.on_event(defines.events.on_selected_entity_changed, function(event)
  local player = game.get_player(event.player_index)
  if not (player and player.valid) then return end
  SelectedDemolisherGui.update(player, player.selected)
end)