-- ----------------------------
-- 構成変更処理 adding_demolisher_life (ver.0.1.1)
-- ----------------------------
function adding_demolisher_life()
	local vulcanus_surface = game.surfaces["vulcanus"]
	if vulcanus_surface ~= nil then
		-- vulcanusのデモリッシャーを検索
		local all_demolishers = find_all_vulcanus_demolisher(vulcanus_surface)
		
		-- デモリッシャー配列から、検索でかからないデモリッシャーを削除
		delete_unfound_demolishers(all_demolishers)
		
		-- すべてのデモリッシャーのうち、周辺50マスにデモリッシャー配列に属さないデモリッシャーが6体以上いる場合に寿命を付与
		add_demolishers_life(all_demolishers)
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
		for key, value in pairs(storage.new_vulcanus_demolishers) do
			if key == entity.unit_number then
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
-- 周辺150マスのデモリッシャーを取得
-- ----------------------------
function find_demolishers_nearby(position, all_demolishers)
	local demolishers = {}
	local count = 0
	for _, entity in pairs(all_demolishers) do
		if(((position.x - entity.position.x)^2 + (position.y - entity.position.y)^2) < 22500) then
			demolishers[count] = entity
			count = count + 1
		end
	end
	return demolishers
end

-- ----------------------------
-- すべてのデモリッシャーのうち、周辺150マスにデモリッシャー配列に属さないデモリッシャーが6体以上いる場合に寿命を付与
-- ----------------------------
function add_demolishers_life(all_demolishers)
	for _, entity in pairs(all_demolishers) do
		-- 高品質デモリッシャーは確実に追加Mob
		add_high_quality_demolisher_life(entity)
	end
	for _, entity in pairs(all_demolishers) do
		add_demolisher_life(entity, all_demolishers)
	end
end

-- ----------------------------
-- 高品質デモリッシャーは確実に追加Mob
-- ----------------------------
function add_high_quality_demolisher_life(entity)
	if entity.quality.name == "uncommon" or entity.quality.name == "rare" or entity.quality.name == "epic" or entity.quality.name == "legendary" then
		if storage.new_vulcanus_demolishers[entity.unit_number] == nil then
			add_new_wild_demolisher(storage.new_vulcanus_demolishers, entity, game.tick + 36000)
		end
	end
end