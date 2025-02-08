-- ----------------------------
-- タイマーイベント
-- ----------------------------
local initialized = false


-- ----------------------------
-- 30分イベント
-- ----------------------------
script.on_nth_tick(108000, function()

	-- 補足できていない削除対処
	local valid = 0
	local invalid = 0
	for key, value in pairs(storage.new_vulcanus_demolishers) do
		if value.entity.valid then
			valid = valid + 1
		else
			invalid = invalid + 1
			storage.new_vulcanus_demolishers[key] = nil
		end
	end
	-- game_print.debug("valid = " .. valid .. ", invalid = " .. invalid .. "new_vulcanus_demolishers updated: " .. table_length(storage.new_vulcanus_demolishers))

	-- デモリッシャラッシュ--30分
	wild_demolisher_breeding()
end)


-- ----------------------------
-- ペットおなかが減る
-- ----------------------------
function my_demolisher_getting_hangry()

	-- game_print.debug("my_demolisher_getting_hangry")
	-- ペットが居なければ終了
	if #storage.my_demolishers == 0 then
		return
	end
	
	for _, value in pairs(storage.my_demolishers) do
		-- 腹減り
		value.customparam:getting_hangury()
		-- 満腹度が-1以下になったら死亡
		if value.customparam:get_satiety() < 0 then
			if value.customparam:get_entity() ~= nil and value.customparam:get_entity().valid() then value.customparam:get_entity().die() end
		end
		-- 寿命減り
		value.customparam:getting_old()
		-- 寿命が-1以下になったら死亡
		if value.customparam:get_life() < 0 then
			if value.customparam:get_entity() ~= nil and value.customparam:get_entity().valid() then
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
