-- ----------------------------
-- エンティティ選択イベント
-- ----------------------------
script.on_event(defines.events.on_selected_entity_changed, function(event)
	local player = game.players[event.player_index]
	local entity = player.selected
	-- GUI更新
	update_selected_demolisher_gui(player, entity)
end)