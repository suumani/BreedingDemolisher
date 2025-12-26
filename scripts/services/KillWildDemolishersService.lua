local KillWildDemolishersService = {}
local DemolisherQuery = require("__Manis_lib__/scripts/queries/DemolisherQuery")
local DRand = require("scripts.util.DeterministicRandom")
-- ----------------------------
-- vulcanusの野生のデモリッシャー自然死 1分
-- ----------------------------
function KillWildDemolishersService.kill_wild_demolishers(vulcanus_surface)
	
	-- デモリッシャ削除イベント
	if vulcanus_surface == nil then
		return
	end

	local dead_count = 0

	local all_demolishers = DemolisherQuery.find_all_demolishers(vulcanus_surface)
	for _, entity in pairs(all_demolishers) do
		
		if(storage.new_vulcanus_demolishers[entity.unit_number] ~= nil) then
			if((storage.new_vulcanus_demolishers[entity.unit_number].life) < game.tick) then

				local count = #(DemolisherQuery.find_neighbor_demolishers(
					vulcanus_surface, {
					{x = entity.position.x - 150, y = entity.position.y - 150},
					{x = entity.position.x + 150, y = entity.position.y + 150}
				}))

				if count >= 3 then -- 半径150以内に3匹以上なら普通に死亡
					storage.new_vulcanus_demolishers[entity.unit_number] = nil
					-- destoroyから、dieに変更(石は残っても良いし、それよりdieイベントをキャッチできないケースの方が怖いと判断)
					entity.die()
					dead_count = dead_count + 1
				else  -- 2匹しか居ないなら、寿命延長
					storage.new_vulcanus_demolishers[entity.unit_number].life = game.tick + DRand.random(120, 180) * 3600 -- 3時間延長
				end
				
			end
		end

	end
	-- game_print.debug("dead_count = " .. dead_count)
end

return KillWildDemolishersService