-- __BreedingDemolisher__/scripts/common/customparam.lua
-- ----------------------------
-- class Customparam
-- Responsibility:
--   Create plain-table demolisher genetic/runtime parameters.
--   - Does NOT use metatable.
--   - Does NOT register globals.
--   - Works with entity=nil (egg state).
--   - Mutation/inheritance logic is delegated to GeneticsMutator.
--   - Spawn-time clamping is handled elsewhere (SpawnClampPolicy).
-- ----------------------------

local Customparam = {}

local DemolisherNames = require("__Manis_definitions__/scripts/definition/DemolisherNames")
local DRand = require("scripts.core.services.DeterministicRandom")

-- ----------------------------
-- internal helpers
-- ----------------------------
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
  local customparam = {
    -- basic
    entity = entity,
    entity_name = entity_name or (entity and entity.name) or DemolisherNames.SMALL,
    name = name or private_default_name(entity),

    -- NOTE:
    -- v0.5.6 design prefers "new is a container", but legacy/compat paths may still
    -- call new() without genetics. Keep conservative defaults for now.
    size = size or DRand.random(100, 500),
    quality = quality or (DRand.random(1, 4) / 10), -- 0.1 - 0.4
    speed = speed or (1 + DRand.random(1, 4) / 10), -- 1.1 - 1.4

    max_life = max_life or 180,
    life = max_life or 180,

    max_growth = max_growth or 50,
    growth = 0,

    max_satiety = max_satiety or 100,
    satiety = max_satiety or 100,

    lv = 1,

    -- genetic traits (may include negative in v0.5.6+)
    traits = traits or {
      [CONST_DEMOLISHER_TRAIT.SHORT_WARP] = 1 + DRand.random(0, 4) / 10,
      [CONST_DEMOLISHER_TRAIT.EMERGENCY_FOOD] = 1 + DRand.random(0, 4) / 10,
      [CONST_DEMOLISHER_TRAIT.BONUS_GROWTH] = 1 + DRand.random(0, 4) / 10
    },

    born_tick = tick,
  }

  if customparam.name == "unknown" then
    customparam.name = "egg: size, quality, speed, max_life, max_satiety, max_growth = "
      .. tostring(customparam.size)
      .. ", " .. tostring(customparam.quality)
      .. ", " .. tostring(customparam.speed)
      .. ", " .. tostring(customparam.max_life)
      .. ", " .. tostring(customparam.max_satiety)
      .. ", " .. tostring(customparam.max_growth)
  end

  return customparam
end

return Customparam