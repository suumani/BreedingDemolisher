-- ----------------------------
-- タイマーイベント
-- ----------------------------
local initialized = false

-- ----------------------------
-- 毎分イベント
-- ----------------------------
script.on_nth_tick(3600, function()
	-- ペットおなかが減る 1分
	my_demolisher_getting_hangry()

	-- 野生のデモリッシャー発生 1分
	spawn_wild_demolishers()
end)
-- ----------------------------
-- 30分イベント
-- ----------------------------
script.on_nth_tick(108000, function()

	-- 野生のデモリッシャー自然死 30分
	die_wild_demolishers()

	-- デモリッシャラッシュ--30分
	wild_demolisher_breeding()
end)

-- ----------------------------
-- 野生のデモリッシャー発生
-- ----------------------------
function spawn_wild_demolishers()
	-- デモリッシャの複製イベント
	for i = #storage.respawn_queue, 1, -1 do
		local queued = storage.respawn_queue[i]
		if game.tick >= queued.respawn_tick then
			-- game.print("!!!demolisher egg hatched at x = "..queued.position.x ..", y = "..queued.position.y..", name = "..queued.entity_name..", force = "..queued.force.name)
			local new_entity = queued.surface.create_entity{
				name = queued.entity_name,
				position = queued.position,
				force = queued.force,
				quality = choose_quality(queued.evolution_factor)
			}
			-- リスポーンキュー削除
			table.remove(storage.respawn_queue, i)
			-- デモリッシャーテーブルに現在のtickを追加
			if(queued.surface.name == "vulcanus") then
				storage.additional_demolishers[new_entity.unit_number] = game.tick
				storage.additional_demolishers["count"] = storage.additional_demolishers["count"] + 1
				-- game.print("new_entity.unit_number = " ..new_entity.unit_number)
			elseif (queued.surface.name == "fulgora") then
				storage.fulgora_demolishers[new_entity.unit_number] = game.tick
				storage.fulgora_demolishers["count"] = storage.additional_demolishers["count"] + 1
			end
		end
	end
end


-- ----------------------------
-- 野生のデモリッシャー自然死 30分
-- ----------------------------
function die_wild_demolishers()
	
	-- デモリッシャ削除イベント
	local vulcanus_surface = game.surfaces["vulcanus"]
	if vulcanus_surface ~= nil then
		local all_demolishers = vulcanus_surface.find_entities_filtered{force = "enemy", {name = "small-demolisher", name = "medium-demolisher", name = "big-demolisher"}}
		for _, entity in pairs(all_demolishers) do
			if entity.valid and (entity.name == "small-demolisher" or entity.name == "medium-demolisher" or entity.name == "big-demolisher") then
				if(storage.additional_demolishers[entity.unit_number] ~= nil) then
					-- game.print("demolisher remove try storage.additional_demolishers[entity.unit_number] = "..storage.additional_demolishers[entity.unit_number])
					if((storage.additional_demolishers[entity.unit_number] + 648000) < game.tick) then -- 648000は3時間
						-- game.print("demolisher despawned")
						storage.additional_demolishers[entity.unit_number] = nil
						storage.additional_demolishers["count"] = storage.additional_demolishers["count"] - 1
						entity.destroy()
					end
				end
			end
		end
	end
end


-- ----------------------------
-- ペットおなかが減る
-- ----------------------------
function my_demolisher_getting_hangry()

	-- game.print("my_demolisher_getting_hangry")
	-- ペットが居なければ終了
	if #storage.my_demolishers == 0 then
		return
	end
	
	for _, value in pairs(storage.my_demolishers) do
		-- 腹減り
		value.customparam:getting_hangury()
		-- 満腹度が-1以下になったら死亡
		if value.customparam:get_satiety() < 0 then
			value.customparam:get_entity().die()
		end
		-- 寿命減り
		value.customparam:getting_old()
		-- 寿命が-1以下になったら死亡
		if value.customparam:get_life() < 0 then
			value.customparam:get_entity().die()
		end
	end
end

-- ----------------------------
-- デモリッシャラッシュ--30分
-- ----------------------------
function wild_demolisher_breeding()
	local vulcanus_surface = game.surfaces["vulcanus"]
	if vulcanus_surface ~= nil then
		local evolution_factor = game.forces["enemy"].get_evolution_factor(vulcanus_surface)
		demolisher_rush(vulcanus_surface, evolution_factor)
	end
end
