-- ----------------------------
-- Customparamクラス
-- ----------------------------

Customparam = {}
Customparam.__index = Customparam

-- ----------------------------
-- コンストラクタ
-- ----------------------------
function Customparam.new(
	entity
	, entity_name
	, name
	, size
	, quality
	, speed
	, max_life
	, max_growth
	, max_satiety
	, traits
	, tick)
	local self = setmetatable({}, Customparam)

	-- 基本情報
	self.entity = entity -- entityが誕生済みなら設定
	self.entity_name = entity_name or entity.name -- 種別名
	self.name = name or (private_default_name(entity)) -- 個体名
	self.size = size or math.random(100, 500) -- サイズ
	self.quality = quality or 1 + math.random(1, 4) / 10  -- 品質 (0.0 - 1.0)
	self.speed = speed or 1 + math.random(1, 4) / 10 -- 移動速度 (0.1 - 1.0)
	self.max_life = max_life or 180
	self.life = max_life or 180
	self.max_growth = max_growth
	self.growth = 40
	self.max_satiety = max_satiety
	self.satiety = max_satiety
	self.lv = 1

	-- game.print("self.quality1 = " .. self.quality)
	-- 遺伝的特徴: 特性リスト
	self.traits = traits or {
		[CONST_DEMOLISHER_TRAIT.SHORT_WARP] = 1+math.random(0, 4) / 10, -- 近距離ワープ
		[CONST_DEMOLISHER_TRAIT.EMERGENCY_FOOD] = 1+math.random(0, 4) / 10, -- 緊急食
		[CONST_DEMOLISHER_TRAIT.BONUS_GROWTH] = 1+math.random(0, 4) / 10 -- 成長ボーナス
	}

	if self.name == "unknown" then
		self.name = "egg: size, quality, speed, max_life, max_satiety, max_growth = "
			.. self.size
			.. ", " .. self.quality
			.. ", " .. self.speed
			.. ", " .. self.max_life
			.. ", " .. self.max_satiety
			.. ", " .. self.max_growth
	end

	return self
end

-- ----------------------------
-- 進化: ランダム変異
-- ----------------------------
function Customparam:mutate(type, partnerparam)
	-- game.print("self.quality2 = " .. self.quality)

	-- 親の数を指定
	local parent_num = 1
	if partnerparam ~= nil then
		parent_num = 2
	end

	-- 種別補正を指定
	local type_control_min = 0
	local type_control_max = 0
	local entity_name = nil
	-- 生みの親がDEMOLISHER_EGG出身
	if type == "enemy" then
		entity_name = CONST_ENTITY_NAME.DEMOLISHER
		type_control_max = 0
	elseif type == "demolishers" then
		type_control_max = 1
	else
		type_control_max = 2
	end
	local max_rate = parent_num * (1 + type_control_max)

	local entity = nil
	local name = nil

	local size, quality, speed, max_life, max_growth, max_satiety

	-- 基礎値の決定
	local size
	if partnerparam == nil then
		-- 片親
		size = self.size
		quality = self.quality
		speed = self.speed
		max_life = self.max_life
		max_growth = self.max_growth or 50
		max_satiety = self.max_satiety or 100
	else
		-- size
		local r = math.random()
		if r < 0.5 then
			size = self.size
		else
			size = partnerparam:get_size()
		end
		-- quality
		r = math.random()
		if r < 0.5 then
			quality = self.quality
		else
			quality = partnerparam:get_quality()
		end
		-- speed
		r = math.random()
		if r < 0.5 then
			speed = self.speed
		else
			speed = partnerparam:get_speed()
		end
		-- max_life
		r = math.random()
		if r < 0.5 then
			max_life = self.max_life
		else
			max_life = partnerparam:get_max_life()
		end
		-- max_growth
		r = math.random()
		if r < 0.5 then
			max_growth = self.max_growth
		else
			max_growth = partnerparam:get_max_growth()
		end
		-- max_satiety
		r = math.random()
		if r < 0.5 then
			max_satiety = self.max_satiety
		else
			max_satiety = partnerparam:get_max_satiety()
		end
	end

	-- 大きさの変動
	size = size + math.random(-2000, 2000 * max_rate) -- サイズ変動 (small 30000, midium 100000, big 300000 )
	-- 大きさ制限処理は、進化依存

	-- 品質の変動
	quality = quality + math.random(-4, 4 * max_rate) / 100 -- 品質変動
	if quality < 0 then
		quality = 0
	end

	-- 速度の変動
	speed = speed + math.random(-4, 4 * max_rate) / 100 -- 移動速度 (変動0.04)
	-- speed の下限は、0.25 + quality * 0.1、上限は0.25 + quality * 0.25
	if speed < 0.25 + quality * 0.1 then
		speed = 0.25 + quality * 0.1
	elseif speed > 0.25 + quality * 0.25 then
		speed = 0.25 + quality * 0.25
	end

	-- 寿命の変動
	max_life = max_life + math.random(-10, 10 * max_rate) / 10 -- 寿命（変動10分・品質上限あり）
	-- max_life の下限は、60 + quality * 30、上限は150 + quality * 30
	if max_life < 60 + quality * 30 then
		max_life = 60 + quality * 30
	elseif max_life > 150 + quality * 30 then
		max_life = 150 + quality * 30
	end

	-- 最大成長値初期化なしデータ対応
	max_growth = max_growth + math.random(-1, 1 * max_rate) -- 成長値（変動1・品質上限あり）
	-- max_growth の下限は、30 + quality * 10、上限は50 + quality * 10
	if max_growth < 30 + quality * 10 then
		max_growth = 30 + quality * 10
	elseif max_growth > 50 + quality * 10 then
		max_growth = 50 + quality * 10
	end

	-- 最大満腹度初期化なしデータ対応
	local max_satiety = max_satiety + math.random(-10, 10 * max_rate) -- 満腹度（変動10・品質上限あり）
	-- max_satiety の下限は、50 + quality * 10、上限は110 + quality * 20
	if max_satiety < 50 + quality * 10 then
		max_satiety = 50 + quality * 10
	elseif max_satiety > 110 + quality * 20 then
		max_satiety = 110 + quality * 20
	end
	
	-- 遺伝的特徴: 特性リスト
	local traits = {}
	-- 生み親
	for key, value in pairs(self.traits) do
		local v = value + math.random(-1, 1 * max_rate) / 10
		if v > 0 then
			traits[key] = v
		end
	end
	-- パートナー
	if partnerparam ~= nil then
		for key, value in pairs(partnerparam:get_traits()) do
			local v = value + math.random(-1, 1 * max_rate) / 10
			if v > 0 then
				if traits[key] ~= nil then
					-- 両親とも保有しているときは高い方にボーナス
					if traits[key] < v then
						traits[key] = v + 0.1
					else
						-- 両親とも保有しているときはボーナス
						traits[key] = traits[key] + 0.1
					end
				else
					traits[key] = v
				end
			end
		end
	end

	-- 進化処理：small demolisher <-> midium demolisher <-> big demolisher
	if entity_name == CONST_ENTITY_NAME.SMALL_DEMOLISHER then
		if size > 100000 then
			entity_name = CONST_ENTITY_NAME.MIDIUM_DEMOLISHER
		elseif size < 15000 then
			size = 15000
		end
	elseif entity_name == CONST_ENTITY_NAME.MIDIUM_DEMOLISHER then
		if size > 300000 then
			entity_name = CONST_ENTITY_NAME.BIG_DEMOLISHER
		elseif size < 30000 then
			entity_name = CONST_ENTITY_NAME.SMALL_DEMOLISHER
		end
	else
		if size < 300000 then
			entity_name = CONST_ENTITY_NAME.MIDIUM_DEMOLISHER
		end
	end

	return Customparam.new(entity, entity_name, name, size, quality, speed, max_life, max_growth, max_satiety, traits, tick)
end

function Customparam:set_entity(entity)
	self.entity = entity
end
function Customparam:get_entity()
	return self.entity
end
function Customparam:get_name()
	return self.name
end
function Customparam:get_size()
	return self.size
end
function Customparam:get_quality()
	return self.quality
end
function Customparam:get_speed()
	return self.speed
end
function Customparam:get_life()
	return self.life
end
function Customparam:get_satiety()
	return self.satiety
end
function Customparam:get_growth()
	return self.growth
end
function Customparam:get_lv()
	return self.lv
end
function Customparam:get_traits()
	return self.traits
end
function Customparam:get_max_satiety()
	return self.satiety
end
function Customparam:get_max_growth()
	return self.growth
end
function Customparam:get_max_life()
	return self.growth
end

-- 成長
function Customparam:grow(value)
	self.growth = self.growth + value
	if self.growth > self.max_growth then
		self.growth = self.max_growth
	end
end

-- 食事
function Customparam:eat(value)
	self.satiety = self.satiety + value
	if self.satiety > self.max_satiety then
		self.satiety = self.max_satiety
	end
end

-- 腹減り
function Customparam:getting_hangury()
	self.satiety = self.satiety - 1
end

-- 老化
function Customparam:getting_old()
	self.life = self.life - 1
end


-- ----------------------------
-- 標準名用のサーフェイス名
-- ----------------------------
function Customparam:get_dafault_name_surface()
	return self.entity.surface.name
end

-- ----------------------------
-- 標準名用の大きさ名
-- ----------------------------
function Customparam:get_dafault_name_size()
	-- ユニットタイプ
	if self.entity.name == CONST_ENTITY_NAME.BIG_DEMOLISHER then
		return  "S"
	elseif  self.entity.name == CONST_ENTITY_NAME.MIDIUM_DEMOLISHER then
		return  "A"
	elseif  self.entity.name == CONST_ENTITY_NAME.SMALL_DEMOLISHER then
		return  "B"
	else
		return  "U"
	end
end

-- ----------------------------
-- 標準名用の品質名
-- ----------------------------
function Customparam:get_dafault_name_quality()
	-- 品質
	if self.entity.quality == "legendary" then
		return "++"
	elseif self.entity.quality == "epic" then
		return "+"
	elseif self.entity.quality == "rare" then
		return ""
	elseif self.entity.quality == "uncommon" then
		return "-"
	else
		return "--"
	end
end

-- ----------------------------
-- 標準名用のNo名
-- ----------------------------
function Customparam:get_dafault_name_unit_number()
	return self.entity.unit_number
end

-- ----------------------------
-- 標準名の設定
-- ----------------------------
function private_default_name(entity)
	if entity == nil then
		return "unknown"
	end
	
	-- 名前
	local name = ""
	
	-- サーフェイス情報
	name = entity.surface.name
	
	-- ユニットタイプ
	if entity.name == CONST_ENTITY_NAME.BIG_DEMOLISHER then
		name = name .. "_" .. "S"
	elseif  entity.name == CONST_ENTITY_NAME.MIDIUM_DEMOLISHER then
		name = name .. "_" .. "A"
	elseif  entity.name == CONST_ENTITY_NAME.SMALL_DEMOLISHER then
		name = name .. "_" .. "B"
	else
		name = name .. "_" .. "U"
	end
	
	-- 品質
	if entity.quality == "legendary" then
		name = name .. "++"
	elseif entity.quality == "epic" then
		name = name .. "+"
	elseif entity.quality == "rare" then
		name = name .. ""
	elseif entity.quality == "uncommon" then
		name = name .. "-"
	else
		name = name .. "--"
	end
	
	-- Unit番号
	name = name .. "型_#" .. entity.unit_number
	
	return name
end