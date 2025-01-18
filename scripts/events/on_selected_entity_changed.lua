-- ----------------------------
-- エンティティ選択イベント
-- ----------------------------
script.on_event(defines.events.on_selected_entity_changed, function(event)
	if not game.players then
		game.print("game.players == nil ")
		return
	end
	local player = game.players[event.player_index]
	if not player then
		game.print("Error: Invalid player index " .. tostring(event.player_index))
		return
	end
	local entity = player.selected
	-- GUI更新
	update_selected_demolisher_gui(player, entity)
end)