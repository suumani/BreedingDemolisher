-- ----------------------------
-- 投擲イベント
-- ----------------------------
script.on_event(defines.events.on_player_used_capsule, function(event)

	local force = nil
	local customparam = nil
	if event.item.name == CONST_ITEM_NAME.DEMOLISHER_EGG then
		force = "enemy"
		if storage.my_wild_eggs and #storage.my_wild_eggs > 0 then
			customparam = storage.my_wild_eggs[1].customparam
			table.remove(storage.my_wild_eggs, 1)
		end
	elseif  event.item.name == CONST_ITEM_NAME.NEW_SPIECES_DEMOLISHER_EGG then
		force = "demolishers"
		if storage.my_new_spieces_eggs and #storage.my_new_spieces_eggs > 0 then
			customparam = storage.my_new_spieces_eggs[1].customparam
			table.remove(storage.my_new_spieces_eggs, 1)
		end
	elseif  event.item.name == CONST_ITEM_NAME.FRIEND_DEMOLISHER_EGG then
		local player = game.get_player(event.player_index)
		force = player.force
		if storage.my_friend_eggs and #storage.my_friend_eggs > 0 then
			customparam = storage.my_friend_eggs[1].customparam
			table.remove(storage.my_friend_eggs, 1)
		end
	elseif event.item.name == CONST_ITEM_NAME.DEMOLISHER_EGG_FROZEN then
		game.print("shattered...")
		return
	elseif  event.item.name == CONST_ITEM_NAME.NEW_SPIECES_DEMOLISHER_EGG_FROZEN then
		game.print("shattered...")
		return
	elseif  event.item.name == CONST_ITEM_NAME.FRIEND_DEMOLISHER_EGG_FROZEN then
		game.print("shattered...")
		return
	end
	
	-- デモリッシャーを生成
	if force ~= nil then
		local player = game.get_player(event.player_index)
		local surface = player.surface
		local position = event.position
		spawn_my_demolisher(surface, position, force, customparam)
	end
	
end)

-- ----------------------------
-- ペットデモリッシャーの生成
-- ----------------------------
function spawn_my_demolisher(surface, position, force, customparam)
	local entity = surface.create_entity({
		name = CONST_ENTITY_NAME.SMALL_DEMOLISHER,
		position = position,
		force = force})
		
	local name = nil
	local size = nil
	local quality = nil
	local speed = nil
	local traits = nil

	if customparam ~= nil then
		customparam:set_entity(entity)
	end

	table.insert(storage.my_demolishers,
		{
			surface = entity.surface
			, entity_name = entity.name
			, force = entity.force
			, unit_number = entity.unit_number
			, customparam = customparam or Customparam.new(
				entity
				, entity_name
				, name
				, size
				, quality
				, speed
				, life
				, CONST_DEMOLISHER_PARAMETER.DEFAULT_MAX_GROWTH
				, CONST_DEMOLISHER_PARAMETER.DEFAULT_MAX_SATIETY
				, traits
				, game.tick
			)
		}
	)
end