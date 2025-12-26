-- ----------------------------
-- class SpawnWildDemolishersService
-- ----------------------------
local SpawnWildDemolishersService = {}

-- ----------------------------
-- requires
-- ----------------------------
local QualityRoller = require("__Manis_lib__/scripts/rollers/QualityRoller")
local DemolisherQuery = require("__Manis_lib__/scripts/queries/DemolisherQuery")
local LimitLifeSpanService = require("scripts.services.LimitLifeSpanService")
local DRand = require("scripts.util.DeterministicRandom")
-- ----------------------------
-- 野生のデモリッシャー発生
-- ----------------------------
function SpawnWildDemolishersService.spawn_wild_demolishers(vulcanus_surface)

	local demolishers = DemolisherQuery.find_all_demolishers(vulcanus_surface)

	-- デモリッシャの複製イベント
	for i = #storage.respawn_queue, 1, -1 do
		local queued = storage.respawn_queue[i]
		if game.tick >= queued.respawn_tick then
			-- debug_print("!!!demolisher egg hatched at x = "..queued.position.x ..", y = "..queued.position.y..", name = "..queued.entity_name..", force = "..queued.force.name)
			-- home に近すぎるpositionを上書き
			local position = queued.position
			local l2 = position.x * position.x + position.y * position.y
			if l2 < 40000 then -- 200 m 以内判定
				if position.x * position.x < position.y * position.y then -- xの絶対値の方が小さい
					if position.y < 0 then
						position.y = position.y - 200
					else
						position.y = position.y + 200
					end
				else
					if position.x < 0 then
						position.x = position.x - 200
					else
						position.x = position.x + 200
					end
				end
			end

			-- 半径60以内に4匹以上いたら腐る
			local count = #(DemolisherQuery.find_neighbor_demolishers(
				vulcanus_surface, {
				{x = position.x - 60, y = position.y - 60},
				{x = position.x + 60, y = position.y + 60}
			}))

			if count >= 4 then 
				-- リスポーンキュー削除
				table.remove(storage.respawn_queue, i)
				-- game_print.debug("egg rotten")
			else
				-- entity作成
				local new_entity = queued.surface.create_entity{
					name = queued.entity_name,
					position = position,
					force = queued.force,
					quality = QualityRoller.choose_quality(queued.evolution_factor, Drand.random())
				}
				-- リスポーンキュー削除
				table.remove(storage.respawn_queue, i)
				-- デモリッシャーテーブルに追加
				if(queued.surface.name == "vulcanus") then
					LimitLifeSpanService.add_lifelimit_wild_demolisher(storage.new_vulcanus_demolishers, new_entity, game.tick + 180 * 3600)
				elseif (queued.surface.name == "fulgora") then
					LimitLifeSpanService.add_lifelimit_wild_demolisher(storage.new_fulgora_demolishers, new_entity, game.tick + 180 * 3600)
				end
				-- game_print.debug("hatched at (" .. position.x .. ", " .. position.y .. ")")
			end
		end
	end
end

return SpawnWildDemolishersService