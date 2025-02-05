function table_length(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

-- ----------------------------
-- 全てのデモリッシャーを検索
-- ----------------------------
function find_all_demolishers(surface)
	return surface.find_entities_filtered{force = "enemy", name = {CONST_ENTITY_NAME.SMALL_DEMOLISHER, CONST_ENTITY_NAME.MEDIUM_DEMOLISHER, CONST_ENTITY_NAME.BIG_DEMOLISHER}}
end

function find_neighbor_demolishers(surface, area)
	return surface.find_entities_filtered{
	force = "enemy", 
	name = {CONST_ENTITY_NAME.SMALL_DEMOLISHER, CONST_ENTITY_NAME.MEDIUM_DEMOLISHER, CONST_ENTITY_NAME.BIG_DEMOLISHER},
	area = area}
end

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
		game_print.debug("Added life... " .. #noliffe_demolishers .. " demos, entity = " .. entity.unit_number .. 
        ", pos = ()" .. entity.position.x .. ", " .. entity.position.y .. ")")
		local count = 0
		for _, entity in pairs(noliffe_demolishers) do
			count = count + 1
			if count >= 6 then
				add_new_wild_demolisher(storage.new_vulcanus_demolishers, entity, game.tick + math.random(1, 30) * 3600)
			end
		end
	end
end

-- ----------------------------
-- [public] デモリッシャー配列から、検索でかからないデモリッシャーを削除
-- ----------------------------
function delete_unfound_demolishers(all_demolishers)
	
	-- 検索で出てきた場合のみ、新しい配列に格納
	local additional_demolishers = {}
	for key, value in pairs(storage.new_vulcanus_demolishers) do
		for _, entity in pairs(all_demolishers) do
			if key == entity.unit_number then
				additional_demolishers[key] = value
				break
			end
		end
	end
	
	-- 新しい配列を古い配列に代入
	storage.new_vulcanus_demolishers = additional_demolishers
	
end