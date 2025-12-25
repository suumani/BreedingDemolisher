-- DemolisherRushService.lua

-- ----------------------------
-- デモリッシャーラッシュ用
-- 全てのデモリッシャーが、2～5体に分裂し、ある程度広範囲に散らばる
-- ----------------------------
local DemolisherRushService = {}

local DemolisherQuery = require("__Manis_lib__/scripts/queries/DemolisherQuery")
local SpawnPositionService = require("scripts.services.SpawnPositionService")

function DemolisherRushService.demolisher_rush(surface, evolution_factor)
	
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
				town_center_pos = silo.position
			end
		end
		
	end

	-- デモリッシャーの取得
	local all_demolishers = DemolisherQuery.find_all_demolishers(surface)
		
	local c = 0
	for _, entity in pairs(all_demolishers) do

		-- 産卵率は、進化度の半分
		if math.random() < evolution_factor / 2 then
			-- 1度のラッシュの最大の生成数は (100 * evolution_factor / 10) + 10 体
			if c >  (100 * evolution_factor / 10) + 5 then
				break
			end
			c = c + 1
		end
	end

	-- demolisherが居ない（ゲーム上のイレギュラー例外状態）
	if #all_demolishers == 0 then
		return
	end

	for i = 1, c, 1 do
		local entity = all_demolishers[math.random(1, #all_demolishers)]
		local demolisher_position = entity.position
		local spawn_position = SpawnPositionService.getSpawnPosition(surface, evolution_factor, demolisher_position, town_center_pos)
		
		if spawn_position ~= nil then
			table.insert(
				storage.respawn_queue
				, {
					surface=entity.surface
					, entity_name = entity.name
					, position = spawn_position
					, evolution_factor = evolution_factor
					, force = entity.force
					, respawn_tick = game.tick + 18000 + 3600*i} -- 60=1秒, 3600=1分, 18000=5分, 5分後から1秒間隔で孵化
			)
		end

	end

	if c ~= 0 then
		game_print.message("[vulcanus]demolishers are multiplying... more than ".. c.." eggs are missing...")
	else
		game_print.message("[vulcanus]demolishers are multiplying... but nothing happen...")
	end
end

return DemolisherRushService