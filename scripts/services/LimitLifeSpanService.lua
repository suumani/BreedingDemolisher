-- ----------------------------
-- vulcanusのデモリッシャーに寿命を付与
-- ----------------------------
local DemolisherQuery = require("__Manis_lib__/scripts/queries/DemolisherQuery")

-- ----------------------------
-- 寿命のないデモリッシャーを抽出
-- ----------------------------
local function extract_nolife_demolishers(demolishers)
  local nolife = {}
  local registry = storage.new_vulcanus_demolishers or {}

  for _, entity in pairs(demolishers) do
    if entity and entity.valid and entity.unit_number then
      if registry[entity.unit_number] == nil then
        table.insert(nolife, entity)
      end
    end
  end

  return nolife
end

-- ----------------------------
-- 周辺のデモリッシャー
-- ----------------------------
local function extract_nearby_demolishers(vulcanus_surface, position, all_demolishers, range)
	local count = 0
	local demolishers = {}
	for _, entity in pairs(all_demolishers) do
		if entity and entity.valid and entity.unit_number then
			local dx = position.x - entity.position.x
			local dy = position.y - entity.position.y
			if (dx*dx + dy*dy) < range*range then
				table.insert(demolishers, entity) -- 1始まりの配列になる
			end
		end
	end
	return demolishers
end

local LimitLifeSpanService = {}

-- ----------------------------
-- 寿命の追加
-- ----------------------------
function LimitLifeSpanService.add_lifelimit_wild_demolisher(tbl, entity, life)
	if not entity then
		game_print.message("add_lifelimit_wild_demolisher: entity is nil")
		return
	end
	if not entity.valid then
		game_print.message("add_lifelimit_wild_demolisher: entity invalid, name=" .. tostring(entity.name))
		return
	end
	if not entity.unit_number then
		game_print.message("add_lifelimit_wild_demolisher: unit_number nil, name=" .. tostring(entity.name))
		return
	end

	tbl[entity.unit_number] = { entity = entity, life = life }
end

-- ----------------------------
-- 特定のデモリッシャーに、周辺50マスにデモリッシャー配列に属さないデモリッシャーが6体以上いる場合に寿命を付与
-- ----------------------------
function LimitLifeSpanService.add_demolisher_life(vulcanus_surface, all_demolishers, entity)
	
	local count = 0
	-- 周辺150マス以内のデモリッシャーを取得
	local demolishers = extract_nearby_demolishers(vulcanus_surface, entity.position, all_demolishers, 150)
	-- 寿命のないデモリッシャーを抽出
	local noliffe_demolishers = extract_nolife_demolishers(demolishers)

	-- 寿命の付与
	if #noliffe_demolishers >= 6 then
		-- game_print.debug("Added life... " .. #noliffe_demolishers .. " demos, entity = " .. entity.unit_number .. ", pos = ()" .. entity.position.x .. ", " .. entity.position.y .. ")")
		local count = 0
		for _, entity2 in pairs(noliffe_demolishers) do
			count = count + 1
			if count >= 6 then
				LimitLifeSpanService.add_lifelimit_wild_demolisher(storage.new_vulcanus_demolishers, entity2, game.tick + math.random(1, 30) * 3600)
			end
		end
	end
end

-- ----------------------------
-- vulcanusのデモリッシャーに寿命を付与
-- ----------------------------
function LimitLifeSpanService.limit_lifespan(vulcanus_surface)

	local demolishers = DemolisherQuery.find_all_demolishers(vulcanus_surface)
	-- ランダムにどれか、寿命チェック
	if #demolishers > 1 then
		LimitLifeSpanService.add_demolisher_life(vulcanus_surface, demolishers, demolishers[math.random(1, #demolishers)])
	end

end

return LimitLifeSpanService