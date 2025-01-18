-- ----------------------------
-- Customparamクラス
-- ----------------------------

Customparam = {}
Customparam.__index = Customparam

-- ----------------------------
-- コンストラクタ
-- ----------------------------
function Customparam.new(entity, name, size, quality, speed, traits, tick)
	local self = setmetatable({}, Customparam)

	-- 基本情報
	self.entity = entity
	self.name = name or (private_default_name(entity))
	self.size = size or math.random(100, 500) -- サイズ
	self.quality = quality or 1 + math.random(1, 4) / 10  -- 品質 (0.0 - 1.0)
	self.speed = speed or 1 + math.random(1, 4) / 10 -- 移動速度 (0.1 - 1.0)
	self.life = 180
	self.growth = 0
	self.satiety = 100
	self.lv = 1

	-- 遺伝的特徴: 特性リスト
	self.traits = traits or {
		["short_warp"] = 1+math.random(0, 4) / 10, -- 近距離ワープ
		["emergency_food"] = 1+math.random(0, 4) / 10, -- 緊急食
		["bonus_growth"] = 1+math.random(0, 4) / 10 -- 成長ボーナス
	}

	return self
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

-- 成長
function Customparam:grow(value)
	self.growth = self.growth + value
end

-- 食事
function Customparam:eat(value)
	self.satiety = self.satiety + value
end

-- 腹減り
function Customparam:getting_hangury()
	self.satiety = self.satiety - 1
end

-- 老化
function Customparam:getting_old()
	self.life = self.life - 1
end

-- 進化: ランダム変異
function Customparam:mutate()
	self.size = self.size + math.random(-10, 10) -- サイズを微調整
	self.quality = math.min(1.0, self.quality + (math.random() * 0.1 - 0.05)) -- 品質を微調整
	self.speed = math.max(0.1, self.speed + (math.random() * 0.2 - 0.1)) -- 移動速度を微調整

	-- 特性の変異
	for trait, value in pairs(self.traits) do
		if math.random() < 0.1 then -- 10%の確率で特性が変化
			self.traits[trait] = not value
		end
	end
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
	if self.entity.name == "big-demolisher" then
		return  "S"
	elseif  self.entity.name == "medium-demolisher" then
		return  "A"
	elseif  self.entity.name == "small-demolisher" then
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
	if entity.name == "big-demolisher" then
		name = name .. "_" .. "S"
	elseif  entity.name == "medium-demolisher" then
		name = name .. "_" .. "A"
	elseif  entity.name == "small-demolisher" then
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