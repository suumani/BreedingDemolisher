-- ----------------------------
-- デモリッシャーラッシュ用
-- 全てのデモリッシャーが、2～5体に分裂し、ある程度広範囲に散らばる
-- ----------------------------
function demolisher_rush(surface, evolution_factor)
	
	-- 追加200体以上は終了
	if(table_length(storage.new_vulcanus_demolishers) > 200) then
		game_print.message("[vulcanus] demolishers abound...")
		return
	end

	-- 中心地に向けて繁殖地が拡大する
	local town_center_pos = {x = 0, y = 0}

	-- ロケットサイロがあれば、そのうちの一つの方向へ
	local silos = surface.find_entities_filtered{type = "rocket-silo"}
	
	if silos ~= nil and #silos ~= 0 then
		-- 最も(0,0)に近い座標に

		local min_length
		for _, silo in pairs(silos) do
			if min_length == nil then
				town_center_pos = silo.position
				min_length = town_center_pos.x ^ 2 + town_center_pos.y ^ 2
			elseif min_length > (silo.position.x^2 + silo.position.y^2) then
				min_length = (silo.position.x^2 + silo.position.y^2)
				town_center_pos = silo
			end
		end
		
		-- 重心方向(離れたサイロのとき、上手くいかないからNG)
		-- 	for _, silo in pairs(silos) do
		--		town_center_pos.x = town_center_pos.x + silo.position.x
		--		town_center_pos.y = town_center_pos.y + silo.position.y
		--	end
		--	town_center_pos.x = town_center_pos.x / #silos
		--	town_center_pos.y = town_center_pos.y / #silos
	end

	game_print.debug("town_center = " .. town_center_pos.x .. ", " .. town_center_pos.y)

	-- デモリッシャーの取得
	local all_demolishers = find_all_demolishers(surface)
		
	local c = 0
	for _, entity in pairs(all_demolishers) do

		-- 産卵率は、進化度の半分
		if math.random() < evolution_factor / 2 then
			-- 1度のラッシュの最大の生成数は (100 * evolution_factor / 10) + 5 体
			if c >  (100 * evolution_factor / 10) + 5 then
				break
			end
			c = c + 1
		end
	end

	for i = 1, c, 1 do
		local entity = all_demolishers[math.random(1, #all_demolishers)]
		local demolisher_position = entity.position
		local spawn_position = getSpawnPosition(surface, evolution_factor, demolisher_position, town_center_pos)
		
		if spawn_position ~= nil then
			table.insert(
				storage.respawn_queue
				, {
					surface=entity.surface
					, entity_name = entity.name
					, position = spawn_position
					, evolution_factor = evolution_factor
					, force = entity.force
					, respawn_tick = game.tick + 18000 + 3600*c} -- 60=1秒, 3600=1分, 18000=5分, 5分後から1秒間隔で孵化
			)
		end

	end

	if c ~= 0 then
		game_print.message("[vulcanus]demolishers are multiplying... more than ".. c.." eggs are missing...")
	else
		game_print.message("[vulcanus]demolishers are multiplying... but nothing happen...")
	end
end

-- ----------------------------
-- デモリッシャー拡散先座標
-- ----------------------------
function getSpawnPosition(surface, evolution_factor, demolisher_position, town_center_pos)
	local spawn_area_radius =  math.floor(100*evolution_factor) -- スポーンエリア最大100マス

	local dx, dy, pos_a, pos_b

	pos_a = {x = demolisher_position.x - spawn_area_radius, y = demolisher_position.y - spawn_area_radius}
	pos_b = {x = demolisher_position.x + spawn_area_radius, y = demolisher_position.y + spawn_area_radius}

	-- 中心部に寄せる場合
	if town_center_pos == nil then town_center_pos = {x = 0, y = 0} end
	dx = town_center_pos.x - demolisher_position.x
	dy = town_center_pos.y - demolisher_position.y
	local length = math.sqrt(dx^2 + dy^2)
	if length ~= 0 then
		dx = spawn_area_radius * dx / length
		dy = spawn_area_radius * dy / length

		pos_a.x = pos_a.x + dx
		pos_a.y = pos_a.y + dy
		pos_b.x = pos_b.x + dx
		pos_b.y = pos_b.y + dy
	end


	-- 周辺座標取得
	local positions = surface.find_tiles_filtered{
		area = {pos_a, pos_b},
		has_hidden_tile = false}
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
