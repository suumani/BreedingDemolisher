-- ----------------------------
-- ペット産卵する
-- ----------------------------

local MyDemolisherBreedingService = {}

function MyDemolisherBreedingService.my_demolisher_breeding()

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
return MyDemolisherBreedingService