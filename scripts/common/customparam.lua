-- __BreedingDemolisher__/scripts/common/customparam.lua
-- ----------------------------
-- class Customparam
-- Responsibility:
--   Hold demolisher genetic/runtime parameters and provide basic operations.
--   - Works with entity=nil (egg state).
--   - Mutation/inheritance logic is delegated to GeneticsMutator (v0.5.6+).
--   - Spawn-time clamping is handled elsewhere (SpawnClampPolicy).
-- ----------------------------

Customparam = {}
Customparam.__index = Customparam

local DemolisherNames = require("__Manis_definitions__/scripts/definition/DemolisherNames")
local DRand = require("scripts.util.DeterministicRandom")
local GeneticsMutator = require("scripts.domain.genetics.GeneticsMutator")

-- ----------------------------
-- internal helpers
-- ----------------------------
local function get_valid_entity(self)
  local e = self and self.entity
  if e and e.valid then return e end
  return nil
end

local function private_default_name(entity)
  if entity == nil then
    return "unknown"
  end

  local name = ""
  name = entity.surface.name

  -- unit type
  if entity.name == DemolisherNames.BIG then
    name = name .. "_" .. "S"
  elseif entity.name == DemolisherNames.MEDIUM then
    name = name .. "_" .. "A"
  elseif entity.name == DemolisherNames.SMALL then
    name = name .. "_" .. "B"
  else
    name = name .. "_" .. "U"
  end

  -- quality
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

  -- unit number
  name = name .. "型_#" .. entity.unit_number

  return name
end

-- ----------------------------
-- ctor
-- ----------------------------
function Customparam.new(
  entity,
  entity_name,
  name,
  size,
  quality,
  speed,
  max_life,
  max_growth,
  max_satiety,
  traits,
  tick
)
  local self = setmetatable({}, Customparam)

  -- basic
  self.entity = entity
  self.entity_name = entity_name or (entity and entity.name) or DemolisherNames.SMALL

  self.name = name or private_default_name(entity)

  -- NOTE:
  -- v0.5.6 design prefers "new is a container", but legacy/compat paths may still
  -- call new() without genetics. Keep conservative defaults for now.
  self.size = size or DRand.random(100, 500)
  self.quality = quality or (DRand.random(1, 4) / 10)  -- 0.1 - 0.4
  self.speed = speed or (1 + DRand.random(1, 4) / 10)  -- 1.1 - 1.4

  self.max_life = max_life or 180
  self.life = self.max_life

  self.max_growth = max_growth or 50
  self.growth = 0

  self.max_satiety = max_satiety or 100
  self.satiety = self.max_satiety

  self.lv = 1

  -- genetic traits (may include negative in v0.5.6+)
  self.traits = traits or {
    [CONST_DEMOLISHER_TRAIT.SHORT_WARP] = 1 + DRand.random(0, 4) / 10,
    [CONST_DEMOLISHER_TRAIT.EMERGENCY_FOOD] = 1 + DRand.random(0, 4) / 10,
    [CONST_DEMOLISHER_TRAIT.BONUS_GROWTH] = 1 + DRand.random(0, 4) / 10
  }

  if self.name == "unknown" then
    self.name = "egg: size, quality, speed, max_life, max_satiety, max_growth = "
      .. tostring(self.size)
      .. ", " .. tostring(self.quality)
      .. ", " .. tostring(self.speed)
      .. ", " .. tostring(self.max_life)
      .. ", " .. tostring(self.max_satiety)
      .. ", " .. tostring(self.max_growth)
  end

  return self
end

-- ----------------------------
-- v0.5.6+ mutation delegation
-- ----------------------------
function Customparam:mutate(parent_force_name, partnerparam)
  -- parent_force_name: "enemy"|"demolishers"|"player"
  -- partner force is resolved inside GeneticsMutator from partnerparam's entity when present.
  local child, child_force = GeneticsMutator.mutate_to_child(self, parent_force_name, partnerparam)
  return child, child_force
end

-- ----------------------------
-- entity binding
-- ----------------------------
function Customparam:set_entity(entity)
  self.entity = entity
end

function Customparam:get_entity()
  return self.entity
end

-- ----------------------------
-- getters
-- ----------------------------
function Customparam:get_name() return self.name end
function Customparam:get_size() return self.size end
function Customparam:get_quality() return self.quality end
function Customparam:get_speed() return self.speed end
function Customparam:get_life() return self.life end
function Customparam:get_satiety() return self.satiety end
function Customparam:get_growth() return self.growth end
function Customparam:get_lv() return self.lv end
function Customparam:get_traits() return self.traits end
function Customparam:get_max_satiety() return self.max_satiety end
function Customparam:get_max_growth() return self.max_growth end
function Customparam:get_max_life() return self.max_life end

-- ----------------------------
-- operations
-- ----------------------------
function Customparam:grow(value)
  self.growth = self.growth + value
  if self.growth > self.max_growth then
    self.growth = self.max_growth
  end
end

function Customparam:eat(value)
  self.satiety = self.satiety + value
  if self.satiety > self.max_satiety then
    self.satiety = self.max_satiety
  end
end

function Customparam:getting_hangury()
  self.satiety = self.satiety - 1
end

function Customparam:getting_old()
  self.life = self.life - 1
end

-- ----------------------------
-- default-name helpers (safe for entity=nil)
-- ----------------------------
function Customparam:get_dafault_name_surface()
  local e = get_valid_entity(self)
  return e and e.surface.name or "unknown"
end

function Customparam:get_dafault_name_size()
  local e = get_valid_entity(self)
  if not e then return "U" end

  if e.name == DemolisherNames.BIG then
    return "S"
  elseif e.name == DemolisherNames.MEDIUM then
    return "A"
  elseif e.name == DemolisherNames.SMALL then
    return "B"
  else
    return "U"
  end
end

function Customparam:get_dafault_name_quality()
  local e = get_valid_entity(self)
  if not e then return "--" end

  if e.quality == "legendary" then
    return "++"
  elseif e.quality == "epic" then
    return "+"
  elseif e.quality == "rare" then
    return ""
  elseif e.quality == "uncommon" then
    return "-"
  else
    return "--"
  end
end

function Customparam:get_dafault_name_unit_number()
  local e = get_valid_entity(self)
  return e and e.unit_number or 0
end