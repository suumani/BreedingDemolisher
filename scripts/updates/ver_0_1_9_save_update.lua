
local LimitLifeSpanService = require("scripts.services.LimitLifeSpanService")
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
-- すべてのデモリッシャーのうち、周辺150マスにデモリッシャー配列に属さないデモリッシャーが6体以上いる場合に寿命を付与
-- ----------------------------
function add_demolishers_life(all_demolishers)
	for _, entity in pairs(all_demolishers) do
		-- 高品質デモリッシャーは確実に追加Mob
		add_high_quality_demolisher_life(entity)
	end
end

-- ----------------------------
-- 高品質デモリッシャーは確実に追加Mob
-- ----------------------------
function add_high_quality_demolisher_life(entity)
	if entity.quality.name == "uncommon" or entity.quality.name == "rare" or entity.quality.name == "epic" or entity.quality.name == "legendary" then
		if storage.new_vulcanus_demolishers[entity.unit_number] == nil then
			LimitLifeSpanService.add_lifelimit_wild_demolisher(storage.new_vulcanus_demolishers, entity, game.tick + 36000)
		end
	end
end