-- ----------------------------
-- 特定のデモリッシャーに、周辺50マスにデモリッシャー配列に属さないデモリッシャーが6体以上いる場合に寿命を付与
-- ----------------------------
function add_demolisher_life(entity, all_demolishers)
	local count = 0
	-- 周辺50マス以内のデモリッシャーを取得
	local demolishers = find_demolishers_nearby(entity.position, all_demolishers)
	-- 寿命のないデモリッシャーを抽出
	local noliffe_demolishers = extract_nolife_demolishers(demolishers)
	-- 寿命の付与
	if #noliffe_demolishers >= 6 then
		local count = 0
		for _, entity in pairs(noliffe_demolishers) do
			count = count + 1
			if count >= 6 then
				storage.additional_demolishers[entity.unit_number] = game.tick
			end
		end
	end
end

-- ----------------------------
-- 寿命のないデモリッシャーを抽出
-- ----------------------------
function extract_nolife_demolishers(demolishers)
	local noliffe_demolishers = {}
	local count = 0
	for _, entity in pairs(demolishers) do
		local is_exist = "false"
		for key, value in pairs(storage.additional_demolishers) do
			if key ~= "count" and key == entity.unit_number then
				is_exist = "true"
				break
			end
		end
		if is_exist == "false" then
			noliffe_demolishers[count] = entity
			count = count + 1
		end
	end
	return noliffe_demolishers
end

-- ----------------------------
-- 周辺50マスのデモリッシャーを取得
-- ----------------------------
function find_demolishers_nearby(position, all_demolishers)
	local demolishers = {}
	local count = 0
	for _, entity in pairs(all_demolishers) do
		if(((position.x - entity.position.x)^2 + (position.y - entity.position.y)^2) < 2500) then
			demolishers[count] = entity
			count = count + 1
		end
	end
	return demolishers
end

-- ----------------------------
-- すべてのデモリッシャーのうち、周辺50マスにデモリッシャー配列に属さないデモリッシャーが6体以上いる場合に寿命を付与
-- ----------------------------
function add_demolishers_life(all_demolishers)
	for _, entity in pairs(all_demolishers) do
		add_demolisher_life(entity, all_demolishers)
	end
end

-- ----------------------------
-- 全てのデモリッシャーを検索（この方式で検索しないと、unit_numberが一定しない。たぶん、体節の関係じゃなかろうか）
-- ----------------------------
function find_all_vulcanus_demolisher(vulcanus_surface)
	local all_demolishers_result = vulcanus_surface.find_entities_filtered{force = "enemy", {name = CONST_ENTITY_NAME.SMALL_DEMOLISHER, name = CONST_ENTITY_NAME.MIDIUM_DEMOLISHER, name = CONST_ENTITY_NAME.BIG_DEMOLISHER}}
	local counter = 0
	local all_demolishers = {}
	for _, entity in pairs(all_demolishers_result) do
		if entity.valid and (entity.name == CONST_ENTITY_NAME.SMALL_DEMOLISHER or entity.name == CONST_ENTITY_NAME.MIDIUM_DEMOLISHER or entity.name == CONST_ENTITY_NAME.BIG_DEMOLISHER) then
			all_demolishers[counter] = entity
			counter = counter + 1
		end
	end
	return all_demolishers
end

-- ----------------------------
-- [public] デモリッシャー配列から、検索でかからないデモリッシャーを削除
-- ----------------------------
function delete_unfound_demolishers(all_demolishers)
	
	-- 検索で出てきた場合のみ、新しい配列に格納
	local additional_demolishers = {}
	additional_demolishers["count"] = 0
	for key, value in pairs(storage.additional_demolishers) do
		if key ~= "count" then
			for _, entity in pairs(all_demolishers) do
				if key == entity.unit_number then
					additional_demolishers[key] = value
					additional_demolishers["count"] = additional_demolishers["count"] + 1
					break
				end
			end
		end
	end
	
	-- 新しい配列を古い配列に代入
	storage.additional_demolishers = additional_demolishers
	
end