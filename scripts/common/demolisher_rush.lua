-- ----------------------------
-- デモリッシャーラッシュ用
-- 全てのデモリッシャーが、2～5体に分裂し、ある程度広範囲に散らばる
-- ----------------------------
function demolisher_rush(surface, evolution_factor)

	local all_demolishers_result = surface.find_entities_filtered{force = "enemy", {name = "small-demolisher", name = "medium-demolisher", name = "big-demolisher"}}

	local counter = 0
	local all_demolishers_a = {}
	for _, entity in pairs(all_demolishers_result) do
		
		if entity.valid and (entity.name == "small-demolisher" or entity.name == "medium-demolisher" or entity.name == "big-demolisher") then
			all_demolishers_a[counter] = entity
			counter = counter + 1
		end
	end
	
	-- デモリッシャーの開始順での並び替え
	local all_demolishers = {}
	local start = math.random(counter)
	for i = 0, counter - 1, 1 do
		local param = i + start
		if (param >= counter) then
			param = param - counter
		end
		all_demolishers[i] = all_demolishers_a[param]
	end
	
	-- 追加200体未満であれば発動
	if(storage.additional_demolishers["count"] > 200) then
		game.print("[vulcanus]demolishers abound...")
	else
		
		local c = 0
		for _, entity in pairs(all_demolishers) do
			for i = 0, (0 + 5*evolution_factor*math.random()), 1 do -- 進化度の5倍を上限に生成
				-- 1度のラッシュの最大の生成数は100体
				if c > 100 then
					break
				end
				
				-- 死亡などの無効な個体は対象外
				if not( entity.valid) then
					break
				end
				
				-- パーツ名などは対象外
				if not(entity.name == "small-demolisher" or entity.name == "medium-demolisher" or entity.name == "big-demolisher") then
					break
				end
				
				-- 複製個体は複製を発生させない
				-- if (storage.additional_demolishers[entity.unit_number] ~= nil) then
				--	break
				-- end
				
				local demolisher_position = entity.position
				local spawn_position = getSpawnPosition(surface, evolution_factor, demolisher_position)
				
				if spawn_position ~= nil then
					table.insert(
						storage.respawn_queue
						, {
							surface=entity.surface
							, entity_name = entity.name
							, position = spawn_position
							, evolution_factor = evolution_factor
							, force = entity.force
							, respawn_tick = game.tick + 18000 + 60*c} -- 60=1秒, 3600=1分, 18000=5分, 5分後から1秒間隔で孵化
					)
					c = c+1
				end
			end
		end
		if c ~= 0 then
			game.print("[vulcanus]demolishers are multiplying... more than ".. c.." eggs are missing...")
		else
			game.print("[vulcanus]demolishers are multiplying... but nothing happen...")
		end
	end
end

-- ----------------------------
-- デモリッシャー拡散先座標
-- ----------------------------
function getSpawnPosition(surface, evolution_factor, demolisher_position)
	local spawn_area_radius = 100*evolution_factor -- スポーンエリア最大100マス
	-- 周辺座標取得
	local positions = surface.find_tiles_filtered{
		area = {
			{demolisher_position.x - spawn_area_radius, demolisher_position.y - spawn_area_radius}
			, {demolisher_position.x + spawn_area_radius, demolisher_position.y + spawn_area_radius}
		}, has_hidden_tile = false}
	-- 周辺座標が存在し、hidden_tileでないならば存在
	if #positions > 0 then
		local index = math.random(#positions)
		local spawn_position = {x = positions[index].position.x, y = positions[index].position.y}
		-- チャンク生成済み判定を取得（念のため）
		if surface.is_chunk_generated({x = math.floor(spawn_position.x / 32), y = math.floor(spawn_position.y / 32)}) then
			return spawn_position
		end
	end
	-- なんらか処理に失敗した場合、nilを返す
	return nil
end
