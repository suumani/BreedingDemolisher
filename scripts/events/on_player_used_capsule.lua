-- ----------------------------
-- 投擲イベント
-- ----------------------------
script.on_event(defines.events.on_player_used_capsule, function(event)

	local force = nil
	if event.item.name == "demolisher-egg" then
		force = "enemy"
	elseif  event.item.name == "new-spieces-demolisher-egg" then
		force = "demolishers"
	elseif  event.item.name == "friend-demolisher-egg" then
		local player = game.get_player(event.player_index)
		force = player.force
	elseif event.item.name == "demolisher-egg-frozen" then
		game.print("shattered...")
	elseif  event.item.name == "new-spieces-demolisher-egg-frozen" then
		game.print("shattered...")
	elseif  event.item.name == "friend-demolisher-egg-frozen" then
		game.print("shattered...")
	end
	
	-- デモリッシャーを生成
	if force ~= nil then
		
		local player = game.get_player(event.player_index)
		local surface = player.surface
		local position = event.position
		spawn_my_demolisher(surface, position, force)
	end
	
end)

-- ----------------------------
-- ペットデモリッシャーの生成
-- ----------------------------
function spawn_my_demolisher(surface, position, force)
	local entity = surface.create_entity({
		name = "small-demolisher",
		position = position,
		force = force})
		
	local name = nil
	local size = nil
	local quality = nil
	local speed = nil
	local traits = nil
	table.insert(storage.my_demolishers,
		{
			surface = entity.surface
			, entity_name = entity.name
			, force = entity.force
			, unit_number = entity.unit_number
			, customparam = Customparam.new(entity, name, size, quality, speed, traits, game.tick)
		}
	)
end