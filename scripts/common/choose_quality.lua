-- ----------------------------
-- 品質の決定
-- ----------------------------
function choose_quality(evolution_factor)
	-- 変更なければnormal
	local quality = "normal"
	local r = math.random()
	
	if evolution_factor < 0.1 then
		if r < 0.01 then
			-- レア1％
			return "rare"
		elseif r < 0.1 then
			-- アンコモン9％
			return "uncommon"
		end
		
	elseif evolution_factor < 0.2 then
		if r < 0.05 then
			-- レア5％
			return "rare"
		elseif r < 0.2 then
			-- アンコモン15％
			return "uncommon"
		end
	
	elseif evolution_factor < 0.3 then
		if r < 0.1 then
			-- レア10％
			return "rare"
		elseif r < 0.3 then
			-- アンコモン20％
			return "uncommon"
		end
	
	elseif evolution_factor < 0.4 then
		if r < 0.01 then
			-- エピック1％
			return "epic"
		elseif r < 0.16 then
			-- レア15％
			return "rare"
		elseif r < 0.4 then
			-- アンコモン24％
			return "uncommon"
		end
	
	elseif evolution_factor < 0.5 then
		if r < 0.05 then
			-- エピック5％
			return "epic"
		elseif r < 0.25 then
			-- レア20％
			return "rare"
		elseif r < 0.5 then
			-- アンコモン25％
			return "uncommon"
		end
	
	elseif evolution_factor < 0.6 then
		if r < 0.10 then
			-- エピック10％
			return "epic"
		elseif r < 0.3 then
			-- レア20％
			return "rare"
		elseif r < 0.6 then
			-- アンコモン30％
			return "uncommon"
		end
	
	elseif evolution_factor < 0.7 then
		if r < 0.01 then
			-- レジェンド
			return "legendary"
		elseif r < 0.16 then
			-- エピック15％
			return "epic"
		elseif r < 0.41 then
			-- レア25％
			return "rare"
		elseif r < 0.7 then
			-- アンコモン29％
			return "uncommon"
		end
	
	elseif evolution_factor < 0.8 then
		if r < 0.05 then
			-- レジェンド5%
			return "legendary"
		elseif r < 0.25 then
			-- エピック20％
			return "epic"
		elseif r < 0.55 then
			-- レア30％
			return "rare"
		elseif r < 0.8 then
			-- アンコモン25％
			return "uncommon"
		end
	
	elseif evolution_factor < 0.9 then
		if r < 0.1 then
			-- レジェンド10%
			return "legendary"
		elseif r < 0.35 then
			-- エピック25％
			return "epic"
		elseif r < 0.65 then
			-- レア30％
			return "rare"
		elseif r < 0.9 then
			-- アンコモン25％
			return "uncommon"
		end
	
	elseif evolution_factor < 0.95 then
		if r < 0.2 then
			-- レジェンド20%
			return "legendary"
		elseif r < 0.5 then
			-- エピック30％
			return "epic"
		elseif r < 0.75 then
			-- レア25％
			return "rare"
		elseif r < 0.95 then
			-- アンコモン20％
			return "uncommon"
		end
	
	elseif evolution_factor < 0.98 then
		if r < 0.34 then
			-- レジェンド34%
			return "legendary"
		elseif r < 0.64 then
			-- エピック30％
			return "epic"
		elseif r < 0.84 then
			-- レア20％
			return "rare"
		elseif r < 0.99 then
			-- アンコモン15％
			return "uncommon"
		end
	
	else
		if r < 0.5 then
			-- レジェンド50%
			return "legendary"
		elseif r < 0.85 then
			-- エピック35％
			return "epic"
		elseif r < 0.95 then
			-- レア10％
			return "rare"
		else
			-- アンコモン5％
			return "uncommon"
		end
	
	end
	return "normal"
end