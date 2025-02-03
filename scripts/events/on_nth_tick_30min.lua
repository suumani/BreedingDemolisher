-- ----------------------------
-- タイマーイベント
-- ----------------------------
local initialized = false


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
-- 野生のデモリッシャー自然死 30分
-- ----------------------------
function die_wild_demolishers()
	
	-- デモリッシャ削除イベント
	local vulcanus_surface = game.surfaces["vulcanus"]
	if vulcanus_surface ~= nil then
		local all_demolishers = vulcanus_surface.find_entities_filtered{force = "enemy", name = {CONST_ENTITY_NAME.SMALL_DEMOLISHER, CONST_ENTITY_NAME.MEDIUM_DEMOLISHER, CONST_ENTITY_NAME.BIG_DEMOLISHER}}
		for _, entity in pairs(all_demolishers) do
			if entity.valid and (entity.name == CONST_ENTITY_NAME.SMALL_DEMOLISHER or entity.name == CONST_ENTITY_NAME.MEDIUM_DEMOLISHER or entity.name == CONST_ENTITY_NAME.BIG_DEMOLISHER) then
				if(storage.additional_demolishers[entity.unit_number] ~= nil) then
					-- debug_print("demolisher remove try storage.additional_demolishers[entity.unit_number] = "..storage.additional_demolishers[entity.unit_number])
					if((storage.additional_demolishers[entity.unit_number] + 648000) < game.tick) then -- 648000は3時間
						-- debug_print("demolisher despawned")
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

	-- debug_print("my_demolisher_getting_hangry")
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
			if value.customparam:get_entity().valid() then
				value.customparam:get_entity().die()
			end
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
