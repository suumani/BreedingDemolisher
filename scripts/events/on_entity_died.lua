local SpawnPositionService = require("scripts.services.SpawnPositionService")
local DemolisherNames = require("__Manis_lib__/scripts/definition/DemolisherNames")

-- ----------------------------
-- デモリッシャー以外のすべての破壊イベント
-- ----------------------------
local function enemy_except_demolisher_dead(event, entity)

	if entity == nil or not entity.valid then
		return
	end

	-- ペットが居なければ終了
	if not storage.my_demolishers or #storage.my_demolishers == 0 then
		return
	end
	
	local surface = entity.surface
	local nearby_demolisher = nil
	
	-- 最大食事距離は30
	local max = 900
	for _, value in pairs(storage.my_demolishers) do
		local demolisher_entity = value.customparam:get_entity()
		if demolisher_entity.valid then
			local length = (entity.position.x - demolisher_entity.position.x)^2 + (entity.position.y - demolisher_entity.position.y)^2
			if max > length then
				max = length
				nearby_demolisher = demolisher_entity
			end
		end
	end
	
	-- 近くに居なければ終了
	if nearby_demolisher == nil then
		return
	end
	
	-- paramの特定と値の更新
	for _, value in pairs(storage.my_demolishers) do
		if value.unit_number == nearby_demolisher.unit_number then
			value.customparam:grow(entity.max_health / 20000)
			value.customparam:eat(0.1)
			return
		end
	end
	
	game_print.message("enemy_except_demolisher_dead error")
end

-- ----------------------------
-- ペットのデモリッシャーが死んだ
-- ----------------------------
function dead_my_demolisher(event, entity)
	-- ペットが居なければ終了
	if #storage.my_demolishers == 0 then
		return
	end
	
	for i = #storage.my_demolishers, 1, -1 do
		local my_demolisher = storage.my_demolishers[i]
		if entity.unit_number == my_demolisher.unit_number then
		
			if my_demolisher.customparam:get_growth() > 20 then
				local drop_rate = 0
				local r2 = math.random()
				local item = CONST_ITEM_NAME.DEMOLISHER_EGG
				
				-- 標準種の場合、卵ドロップは50％、種類はランダム
				if entity.force.name == "enemy" then
					drop_rate = 0.5
					if r2 < 0.2 then 
						item = CONST_ITEM_NAME.NEW_SPIECES_DEMOLISHER_EGG
					end
					-- 標準種の進化
					egg_customparam = my_demolisher.customparam:mutate(CONST_ITEM_NAME.DEMOLISHER_EGG, nil)
					
				-- 新種の場合、卵ドロップは70％、種類はランダム
				elseif entity.force.name == "demolishers" then
					drop_rate = 0.7
					if r2 < 0.2 then 
						item = CONST_ITEM_NAME.FRIEND_DEMOLISHER_EGG
					elseif r2 < 0.7 then
						item = CONST_ITEM_NAME.NEW_SPIECES_DEMOLISHER_EGG
					end
					-- 新種の進化
					egg_customparam = my_demolisher.customparam:mutate(CONST_ITEM_NAME.NEW_SPIECES_DEMOLISHER_EGG, nil)
				
				-- 友好種の場合、卵ドロップは90％、種類はランダム
				elseif entity.force.name == "player" then
					drop_rate = 0.9
					if r2 < 0.9 then 
						item = CONST_ITEM_NAME.FRIEND_DEMOLISHER_EGG
					else
						item = CONST_ITEM_NAME.NEW_SPIECES_DEMOLISHER_EGG
					end
					-- 新種の進化
					egg_customparam = my_demolisher.customparam:mutate(CONST_ITEM_NAME.FRIEND_DEMOLISHER_EGG, nil)
				end

				-- アイテムドロップ
				drop_item(entity, item, drop_rate, egg_customparam, egg_customparam:get_quality())
			end
			
			-- 除去
			table.remove(storage.my_demolishers, i)
			return true
		end
	end
	return false
end

-- ----------------------------
-- デモリッシャー死亡イベント
-- ----------------------------
local function demolisher_dead_event(event, entity)

	-- ペットデモリッシャー処理
	local result = dead_my_demolisher(event, entity)
	
	-- ペット処理が終わっていたら終了
	if result == true then
		return
	end

	-- ペット処理以外で寿命で死んだ場合は、ドロップ処理もメッセージ処理もなし
	local dead_cause_lifespan = false
	if(storage.new_vulcanus_demolishers[entity.unit_number] ~= nil) then
		dead_cause_lifespan = (storage.new_vulcanus_demolishers[entity.unit_number].customparam:get_life() < 0)
	end
	if dead_cause_lifespan == true then
		return
	end

	-- 野良デモリッシャー
	local drop_rate = 0.05
	local item = CONST_ITEM_NAME.DEMOLISHER_EGG
	local drop = drop_item(event.entity, item, drop_rate)
	
	if drop == true then
		return
	end

	local r = math.random()
	local r2 = math.random()
	
	-- 進化度の取得
	local evolution_factor = game.forces["enemy"].get_evolution_factor(entity.surface)
	
	-- (進化度の半分未満のrの時)または、(進化度が30以下の時は固定15％)で、卵が発生
	if((r < evolution_factor/4) or (evolution_factor < 0.3 and r < 0.15)) then
		local spawn_position = SpawnPositionService.getSpawnPosition(entity.surface, evolution_factor, entity.position)
		if spawn_position ~= nil then
			game_print.message("["..entity.surface.name.."]".. entity.quality.name .. " " .. entity.name .. " defeated, but egg is missing... would hatch within 10 minutes...")
			table.insert(
				storage.respawn_queue
				, {
					surface = entity.surface
					, entity_name = entity.name
					, position = entity.position
					, evolution_factor = evolution_factor
					, force = entity.force
					, respawn_tick = game.tick + 18000 + 18000*r2} -- 60=1秒, 3600=1分, 18000=5分, 5～10分で孵化
			)
		else
			game_print.message("["..entity.surface.name.."] ".. entity.quality.name .. " " .. entity.name .. " defeated, egg was rotten...")
		end
	else
		game_print.message("["..entity.surface.name.."] ".. entity.quality.name .. " ".. entity.name .. " defeated, egg destroyed.")
	end
	
	-- 追加デモリッシャーリストから削除
	if(storage.new_vulcanus_demolishers[entity.unit_number] ~= nil) then
		storage.new_vulcanus_demolishers[entity.unit_number] = nil
	end
end


-- ----------------------------
-- アイテムドロップ
-- ----------------------------
function drop_item(entity, item_name, drop_rate, customparam, quality)
	local surface = entity.surface
	local position = entity.position
	local drop_count = 1

	-- 野良でもりんは、quality == nil が期待値
	if quality == nil then
		quality = 0
	end
	
	local r = math.random()
	if r < drop_rate then
		
		local str_quality = CONST_QUALITY.NORMAL
		if quality ~= nil then
			if quality >= 2 then
				str_quality = CONST_QUALITY.UNCOMMON
			elseif quality >= 3 then
				str_quality = CONST_QUALITY.RARE
			elseif quality >= 4 then
				str_quality = CONST_QUALITY.EPIC
			elseif quality >= 5 then
				str_quality = CONST_QUALITY.LEGENDARY
			end
		end
		-- アイテムをドロップ
		surface.spill_item_stack{
			position = position, -- ドロップする座標
			stack = {name = item_name, count = 1, quality = str_quality}, -- ドロップするアイテム
		}

		
		if customparam == nil then
			game_print.message("["..entity.surface.name.."]".."demolisher defeated, you can find egg somewhere!")
		else
		
			game_print.message("item_name, str_quality = " .. item_name .. ", " .. str_quality)
			-- ドロップした卵のステータスを保存
			if storage.my_eggs[item_name] == nil then
				storage.my_eggs[item_name] = {}
			end
			if storage.my_eggs[item_name][str_quality] == nil then
				storage.my_eggs[item_name][str_quality] = {}
			end
			table.insert(storage.my_eggs[item_name][str_quality], {gametick = game.tick, customparam = customparam})
			
			game_print.message("["..entity.surface.name.."]".."demolisher lay eggs, you can find egg somewhere!")
		end

		return true
	end
	return false
end

-- ----------------------------
-- エンティティの死亡イベントを捕捉
-- ----------------------------
script.on_event(defines.events.on_entity_died, function(event)

	local entity = event.entity

	if (entity.name == DemolisherNames.SMALL_DEMOLISHER or entity.name == DemolisherNames.MEDIUM_DEMOLISHER or entity.name == DemolisherNames.BIG_DEMOLISHER) then
		-- デモリッシャー死亡イベント
		demolisher_dead_event(event, entity)
	else
		-- デモリッシャー食事イベント
		enemy_except_demolisher_dead(event, entity)
	end
end)