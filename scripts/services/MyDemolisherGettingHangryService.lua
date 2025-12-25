-- ----------------------------
-- ペット産卵する
-- ----------------------------

local MyDemolisherGettingHangryService = {}

-- ----------------------------
-- ペットおなかが減る
-- ----------------------------
function MyDemolisherGettingHangryService.my_demolisher_getting_hangry()

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
			if value.customparam:get_entity() ~= nil and value.customparam:get_entity().valid then value.customparam:get_entity().die() end
		end
		-- 寿命減り
		value.customparam:getting_old()
		-- 寿命が-1以下になったら死亡
		if value.customparam:get_life() < 0 then
			if value.customparam:get_entity() ~= nil and value.customparam:get_entity().valid then
				value.customparam:get_entity().die()
			end
		end
	end
end

return MyDemolisherGettingHangryService