-- __BreedingDemolisher__/scripts/common/customparam.lua

-- ----------------------------
-- Customparamクラス
-- ----------------------------

Customparam = {}
Customparam.__index = Customparam
local DemolisherNames = require("__Manis_definitions__/scripts/definition/DemolisherNames")
local DRand = require("scripts.util.DeterministicRandom")
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
	self.size = size or DRand.random(100, 500) -- サイズ
	self.quality = quality or 0 + DRand.random(1, 4) / 10  -- 品質 (0.0 - 0.4)
	self.speed = speed or 1 + DRand.random(1, 4) / 10 -- 移動速度 (0.1 - 1.0)
	self.max_life = max_life or 180
	self.life = self.max_life
	self.max_growth = max_growth or 50
	self.growth = 0 --40
	self.max_satiety = max_satiety or 100
	self.satiety = self.max_satiety
	self.lv = 1

	-- 遺伝的特徴: 特性リスト
	self.traits = traits or {
		[CONST_DEMOLISHER_TRAIT.SHORT_WARP] = 1+DRand.random(0, 4) / 10, -- 近距離ワープ
		[CONST_DEMOLISHER_TRAIT.EMERGENCY_FOOD] = 1+DRand.random(0, 4) / 10, -- 緊急食
		[CONST_DEMOLISHER_TRAIT.BONUS_GROWTH] = 1+DRand.random(0, 4) / 10 -- 成長ボーナス
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

local function apply_quality_mutation(quality, parent_num, max_rate, type)
  -- 減衰係数：quality が大きいほど成長率が下がる（上限は持たせない）
  -- a = 1.0
  local d = 1.0 / (1.0 + quality)

  -- 片親：下がりやすい（平均マイナス）
  if parent_num == 1 then
    local delta = DRand.random(-2, 0) / 10    -- -0.2 .. 0.0
    quality = quality + delta * d

  else
    -- 両親：ベース成長（平均 +0.2 相当を想定）
    local delta = DRand.random(-2, 6) / 10    -- -0.2 .. +0.6
    quality = quality + delta * d

    -- 突然変異：両親のみ、確率。max_rate が大きいほど起きやすい
    local p = 0.05 * max_rate
    if p > 0.30 then p = 0.30 end

    if DRand.random() < p then
      local mut = DRand.random(0, 6) / 10     -- +0.0 .. +0.6
      quality = quality + mut * d
    end
  end

  -- 下限のみ保証（上限は設けない）
  if quality < 0 then quality = 0 end
  return quality
end

local function resolve_parent_context(self, type, partnerparam)
  local parent_num = partnerparam and 2 or 1

  local entity_name = self.entity_name or DemolisherNames.SMALL
  local type_control_max = 0

  if type == "enemy" then
    entity_name = DemolisherNames.SMALL
    type_control_max = 0
  elseif type == "demolishers" then
    type_control_max = 1
  elseif type == "player" then
    type_control_max = 2
  else
    type_control_max = 2
  end

  local max_rate = parent_num * (1 + type_control_max)
  return parent_num, max_rate, entity_name
end

local function inherit_base(self, partnerparam)
  if not partnerparam then
    return
      self.size,
      self.quality,
      self.speed,
      self.max_life,
      self.max_growth or 50,
      self.max_satiety or 100
  end

  local function pick(a, b)
    return (DRand.random() < 0.5) and a or b
  end

  return
    pick(self.size,        partnerparam:get_size()),
    pick(self.quality,     partnerparam:get_quality()),
    pick(self.speed,       partnerparam:get_speed()),
    pick(self.max_life,    partnerparam:get_max_life()),
    pick(self.max_growth,  partnerparam:get_max_growth()),
    pick(self.max_satiety, partnerparam:get_max_satiety())
end

local function quality_decay(q)
  return 1.0 / (1.0 + q)   -- a=1.0
end

local function mutate_size(size, max_rate)
  return size + DRand.random(-2000, 2000 * max_rate)
end

local function mutate_speed(speed, quality, max_rate)
  speed = speed + DRand.random(-4, 4 * max_rate) / 100
  local min = 0.25 + quality * 0.1
  local max = 0.25 + quality * 0.25
  if speed < min then return min end
  if speed > max then return max end
  return speed
end

local function mutate_life(max_life, quality, max_rate)
  max_life = max_life + DRand.random(-10, 10 * max_rate) / 10
  local min = 60 + quality * 30
  local max = 150 + quality * 30
  if max_life < min then return min end
  if max_life > max then return max end
  return max_life
end

local function mutate_growth(max_growth, quality, max_rate)
  max_growth = max_growth + DRand.random(-1, 1 * max_rate)
  local min = 30 + quality * 10
  local max = 50 + quality * 10
  if max_growth < min then return min end
  if max_growth > max then return max end
  return max_growth
end

local function mutate_satiety(max_satiety, quality, max_rate)
  max_satiety = max_satiety + DRand.random(-10, 10 * max_rate)
  local min = 50 + quality * 10
  local max = 110 + quality * 20
  if max_satiety < min then return min end
  if max_satiety > max then return max end
  return max_satiety
end

local function mutate_traits(self_traits, partner_traits, max_rate)
  local traits = {}

  for k, v in pairs(self_traits) do
    local nv = v + DRand.random(-1, 1 * max_rate) / 10
    if nv > 0 then traits[k] = nv end
  end

  if partner_traits then
    for k, v in pairs(partner_traits) do
      local nv = v + DRand.random(-1, 1 * max_rate) / 10
      if nv > 0 then
        if traits[k] then
          traits[k] = math.max(traits[k], nv) + 0.1
        else
          traits[k] = nv
        end
      end
    end
  end

  return traits
end

local function evolve_entity(entity_name, size)
  if entity_name == DemolisherNames.SMALL then
    if size > 100000 then return DemolisherNames.MEDIUM end
    if size < 15000 then return DemolisherNames.SMALL, 15000 end
  elseif entity_name == DemolisherNames.MEDIUM then
    if size > 300000 then return DemolisherNames.BIG end
    if size < 30000 then return DemolisherNames.SMALL end
  else
    if size < 300000 then return DemolisherNames.MEDIUM end
  end
  return entity_name
end

-- ----------------------------
-- 進化: ランダム変異
-- ----------------------------
function Customparam:mutate(type, partnerparam)

  local parent_num, max_rate, entity_name =
    resolve_parent_context(self, type, partnerparam)

  local size, quality, speed, max_life, max_growth, max_satiety =
    inherit_base(self, partnerparam)

  size       = mutate_size(size, max_rate)
  quality    = apply_quality_mutation(quality, parent_num, max_rate, type)
  speed      = mutate_speed(speed, quality, max_rate)
  max_life   = mutate_life(max_life, quality, max_rate)
  max_growth = mutate_growth(max_growth, quality, max_rate)
  max_satiety= mutate_satiety(max_satiety, quality, max_rate)

  local traits = mutate_traits(
    self.traits,
    partnerparam and partnerparam:get_traits() or nil,
    max_rate
  )

  local new_entity_name, fixed_size = evolve_entity(entity_name, size)
  if fixed_size then size = fixed_size end

  return Customparam.new(
    nil, new_entity_name, nil,
    size, quality, speed,
    max_life, max_growth, max_satiety,
    traits, game.tick
  )
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
	return self.max_satiety
end
function Customparam:get_max_growth()
	return self.max_growth
end
function Customparam:get_max_life()
	return self.max_life
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
	if self.entity.name == DemolisherNames.BIG then
		return  "S"
	elseif  self.entity.name == DemolisherNames.MEDIUM then
		return  "A"
	elseif  self.entity.name == DemolisherNames.SMALL then
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
	if entity.name == DemolisherNames.BIG then
		name = name .. "_" .. "S"
	elseif  entity.name == DemolisherNames.MEDIUM then
		name = name .. "_" .. "A"
	elseif  entity.name == DemolisherNames.SMALL then
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