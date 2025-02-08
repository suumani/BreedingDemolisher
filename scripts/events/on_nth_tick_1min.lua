-- ----------------------------
-- タイマーイベント
-- ----------------------------
local initialized = false


-- ----------------------------
-- 野生のデモリッシャー発生
-- ----------------------------
local function spawn_wild_demolishers(vulcanus_surface)

	local demolishers = find_all_demolishers(vulcanus_surface)

	-- デモリッシャの複製イベント
	for i = #storage.respawn_queue, 1, -1 do
		local queued = storage.respawn_queue[i]
		if game.tick >= queued.respawn_tick then
			-- debug_print("!!!demolisher egg hatched at x = "..queued.position.x ..", y = "..queued.position.y..", name = "..queued.entity_name..", force = "..queued.force.name)
			-- home に近すぎるpositionを上書き
			position = queued.position
			l2 = position.x * position.x + position.y * position.y
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
			local count = #(find_neighbor_demolishers(
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
					quality = choose_quality(queued.evolution_factor)
				}
				-- リスポーンキュー削除
				table.remove(storage.respawn_queue, i)
				-- デモリッシャーテーブルに追加
				if(queued.surface.name == "vulcanus") then
					add_new_wild_demolisher(storage.new_vulcanus_demolishers, new_entity, game.tick + 180 * 3600)
				elseif (queued.surface.name == "fulgora") then
					add_new_wild_demolisher(storage.new_fulgora_demolishers, new_entity, game.tick + 180 * 3600)
				end
				-- game_print.debug("hatched at (" .. position.x .. ", " .. position.y .. ")")
			end
		end
	end
end

-- ----------------------------
-- 毎分イベント
-- ----------------------------
script.on_nth_tick(3600, function()

	--[[
	game_print.debug("storage.new_vulcanus_demolishers = " .. table_length(storage.new_vulcanus_demolishers))
	game_print.debug("6665597 = " .. type(storage.new_vulcanus_demolishers["6665597"]))
	local c = 0
	local invalid = 0
	for key, value in pairs(storage.new_vulcanus_demolishers) do
		if value.entity.valid then
			c = c + 1
			if c < 10 then
				game_print.debug(
					"key = " .. key .. 
					", value = " .. value.entity.unit_number .. 
					", surface = " .. value.entity.surface.name .. 
					", pos = " .. value.entity.position.x .. ", " .. value.entity.position.y .. ")")
			end
		else
			invalid = invalid + 1
		end
	end
	game_print.debug("valid = " .. c .. ", invalid = " .. invalid)
	]]

	-- vulcanus 無ければ対処なし
	local vulcanus_surface = game.surfaces["vulcanus"]
	if vulcanus_surface == nil then
		return
	end

	local demolishers = find_all_demolishers(vulcanus_surface)
	-- game_print.debug("demolishers = " .. #demolishers)

	-- ランダムにどれか、寿命チェック
	add_demolisher_life(demolishers[math.random(1, #demolishers)], demolishers)

	-- ペットおなかが減る 1分
	my_demolisher_getting_hangry()

	-- ペット産卵する 1分 (todo イベント登録してタスク処理する方が無難か。同時に生まれた個体が多いとマルチは落ちるかも) 
	my_demolisher_breeding()

	-- 野生のデモリッシャー自然死 1分
	die_wild_demolishers(vulcanus_surface)

	-- 野生のデモリッシャー発生 1分
	spawn_wild_demolishers(vulcanus_surface)

end)

-- ----------------------------
-- vulcanusの野生のデモリッシャー自然死 1分
-- ----------------------------
function die_wild_demolishers(vulcanus_surface)
	
	-- デモリッシャ削除イベント
	if vulcanus_surface == nil then
		return
	end

	local dead_count = 0

	local all_demolishers = find_all_demolishers(vulcanus_surface)
	for _, entity in pairs(all_demolishers) do
		
		if(storage.new_vulcanus_demolishers[entity.unit_number] ~= nil) then
			if((storage.new_vulcanus_demolishers[entity.unit_number].life) < game.tick) then

				local count = #(find_neighbor_demolishers(
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
					storage.new_vulcanus_demolishers[entity.unit_number].life = game.tick + math.random(120, 180) * 3600 -- 3時間延長
				end
				
			end
		end

	end
	-- game_print.debug("dead_count = " .. dead_count)
end

-- ----------------------------
-- ペット産卵する
-- ----------------------------
function my_demolisher_breeding()

	-- ペットが居なければ終了
	if #storage.my_demolishers == 0 then
		return
	end
	game_print.debug("[BreedingDemolisher] my_demolisher_breeding function")
	
	for _, parent_value in pairs(storage.my_demolishers) do
		if parent_value.customparam:get_entity() ~= nil and parent_value.customparam:get_entity().valid then
			-- 成長度
			local growth = parent_value.customparam:get_growth()
			if growth < 20 and growth ~= parent_value.customparam:get_max_growth() then
				-- continue
			elseif ((math.floor(growth) % 20) == 0) then --20の倍数の成長度の時、近くに成熟したペットデモリッシャーが居たら繁殖し、追加成長
				local parent_entity = parent_value.customparam:get_entity()
				for _, partner_value in pairs(storage.my_demolishers) do
					if partner_value.customparam:get_growth() < 20 then
						-- continue
					else
						local partner_entity = partner_value.customparam:get_entity()
						if partner_entity.valid then
							-- 100 マス以内に居れば配合可能
							if (parent_entity.position.x - partner_entity.position.x)^2 + (parent_entity.position.y - partner_entity.position.y)^2 < 10000 then
								-- 連続繁殖防止のための追加成長
								parent_value.customparam:grow(1)
								local customparam = parent_value.customparam:mutate(parent_entity.force.name, partner_value.customparam)
								local drop_rate = 1
								local item_name = CONST_ITEM_NAME.FRIEND_DEMOLISHER_EGG
								if parent_entity.force == "enemy" then
									item_name = CONST_ITEM_NAME.DEMOLISHER_EGG
								elseif parent_entity.force == "demolishers" then
									item_name = CONST_ITEM_NAME.NEW_SPIECES_DEMOLISHER_EGG
								end
								game_print.debug("[BreedingDemolisher] my_demolisher_breeding neer (x, y) = (" .. parent_entity.position.x .. ", " .. parent_entity.position.y ..")" )
								drop_item(parent_entity, item_name, drop_rate, customparam, customparam:get_quality())
								return
							end
						end
					end
				end
			end
		end
	end
end
