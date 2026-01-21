-- __BreedingDemolisher__/scripts/domain/genetics/SpawnClampPolicy.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Apply spawn-time (create_entity-time) constraints and derived values.
--
-- v0.5.6 Design:
--   - Genetic values are kept "as-is" (may be negative / out of range).
--   - Only at spawn time, we clamp values to safe/meaningful ranges.
--   - quality_name is derived from continuous genetic quality via QualityUtil.
--   - Traits are not deleted; we compute "expressed traits" based on per-trait thresholds.
--
-- Scope:
--   - size cap by species
--   - speed cap by species base * [0.5, 2.0] (normal & speedstar lines)
--   - max_life/max_growth/max_satiety min/max per species
--   - quality_name derivation
--   - expressed traits filtering by threshold
--
-- Notes:
--   - This module intentionally does NOT decide species evolution (evolve_entity).
--   - It does not require entity/prototype existence checks.
-- ------------------------------------------------------------
local C = {}

local DemolisherNames = require("__Manis_definitions__/scripts/definition/DemolisherNames")
local QualityUtil = require("scripts.util.QualityUtil")

-- ------------------------------------------------------------
-- Helpers
-- ------------------------------------------------------------
local function clamp(x, lo, hi)
  if x < lo then return lo end
  if x > hi then return hi end
  return x
end

local function num_or(x, fallback)
  return (type(x) == "number") and x or fallback
end

-- ------------------------------------------------------------
-- Size caps (upper bounds) by species
-- ------------------------------------------------------------
local SIZE_CAP = {
  -- default / normal small
  [DemolisherNames.SMALL] = 30000,
  [DemolisherNames.MANIS_SMALL] = 30000,
  [DemolisherNames.MANIS_SMALL_ALT] = 30000,

  -- default / normal medium
  [DemolisherNames.MEDIUM] = 100000,
  [DemolisherNames.MANIS_MEDIUM] = 100000,
  [DemolisherNames.MANIS_MEDIUM_ALT] = 100000,

  -- default / normal big
  [DemolisherNames.BIG] = 300000,
  [DemolisherNames.MANIS_BIG] = 300000,
  [DemolisherNames.MANIS_BIG_ALT] = 300000,

  -- behemoth (boss normal)
  [DemolisherNames.MANIS_BEHEMOTH] = 1000000,
  [DemolisherNames.MANIS_BEHEMOTH_ALT] = 1000000,

  -- speedstar series
  [DemolisherNames.MANIS_SPEEDSTAR_SMALL] = 30000,
  [DemolisherNames.MANIS_SPEEDSTAR_MEDIUM] = 100000,
  [DemolisherNames.MANIS_SPEEDSTAR_BIG] = 300000,
  [DemolisherNames.MANIS_SPEEDSTAR_BEHEMOTH] = 1000000,

  [DemolisherNames.MANIS_SPEEDSTAR_SMALL_ALT] = 30000,
  [DemolisherNames.MANIS_SPEEDSTAR_MEDIUM_ALT] = 100000,
  [DemolisherNames.MANIS_SPEEDSTAR_BIG_ALT] = 300000,
  [DemolisherNames.MANIS_SPEEDSTAR_BEHEMOTH_ALT] = 1000000,

  -- gigantic series (fatal)
  [DemolisherNames.MANIS_GIGANTIC_SMALL] = 2000000,
  [DemolisherNames.MANIS_GIGANTIC_MEDIUM] = 3000000,
  [DemolisherNames.MANIS_GIGANTIC_BIG] = 4000000,
  [DemolisherNames.MANIS_GIGANTIC_BEHEMOTH] = 5000000,

  [DemolisherNames.MANIS_GIGANTIC_SMALL_ALT] = 2000000,
  [DemolisherNames.MANIS_GIGANTIC_MEDIUM_ALT] = 3000000,
  [DemolisherNames.MANIS_GIGANTIC_BIG_ALT] = 4000000,
  [DemolisherNames.MANIS_GIGANTIC_BEHEMOTH_ALT] = 5000000,

  -- crazy-king series (fatal)
  [DemolisherNames.MANIS_CRAZY_KING] = 10000000,
  [DemolisherNames.MANIS_CRAZY_KING_ALT] = 10000000,
}

-- ------------------------------------------------------------
-- Speed base table (normal line) by species
-- Spawn-time clamp range is base * [0.5, 2.0]
-- ------------------------------------------------------------
local SPEED_BASE_NORMAL = {
  -- normal series
  [DemolisherNames.SMALL] = 4.0,
  [DemolisherNames.MANIS_SMALL] = 4.0,
  [DemolisherNames.MANIS_SMALL_ALT] = 4.0,

  [DemolisherNames.MEDIUM] = 4.3,
  [DemolisherNames.MANIS_MEDIUM] = 4.3,
  [DemolisherNames.MANIS_MEDIUM_ALT] = 4.3,

  [DemolisherNames.BIG] = 4.7,
  [DemolisherNames.MANIS_BIG] = 4.7,
  [DemolisherNames.MANIS_BIG_ALT] = 4.7,

  [DemolisherNames.MANIS_BEHEMOTH] = 5.4,
  [DemolisherNames.MANIS_BEHEMOTH_ALT] = 5.4,

  -- gigantic series (fatal): speed (small 3.2, medium 4.0, big 4.7, behemoth 5.4)
  [DemolisherNames.MANIS_GIGANTIC_SMALL] = 3.2,
  [DemolisherNames.MANIS_GIGANTIC_SMALL_ALT] = 3.2,

  [DemolisherNames.MANIS_GIGANTIC_MEDIUM] = 4.0,
  [DemolisherNames.MANIS_GIGANTIC_MEDIUM_ALT] = 4.0,

  [DemolisherNames.MANIS_GIGANTIC_BIG] = 4.7,
  [DemolisherNames.MANIS_GIGANTIC_BIG_ALT] = 4.7,

  [DemolisherNames.MANIS_GIGANTIC_BEHEMOTH] = 5.4,
  [DemolisherNames.MANIS_GIGANTIC_BEHEMOTH_ALT] = 5.4,

  -- crazy-king: speed 8.6
  [DemolisherNames.MANIS_CRAZY_KING] = 8.6,
  [DemolisherNames.MANIS_CRAZY_KING_ALT] = 8.6,
}

-- ------------------------------------------------------------
-- Speed base table (speedstar line) by species
-- ------------------------------------------------------------
local SPEED_BASE_SPEEDSTAR = {
  [DemolisherNames.MANIS_SPEEDSTAR_SMALL] = 6.1,
  [DemolisherNames.MANIS_SPEEDSTAR_MEDIUM] = 6.8,
  [DemolisherNames.MANIS_SPEEDSTAR_BIG] = 7.6,
  [DemolisherNames.MANIS_SPEEDSTAR_BEHEMOTH] = 8.3,

  [DemolisherNames.MANIS_SPEEDSTAR_SMALL_ALT] = 6.1,
  [DemolisherNames.MANIS_SPEEDSTAR_MEDIUM_ALT] = 6.8,
  [DemolisherNames.MANIS_SPEEDSTAR_BIG_ALT] = 7.6,
  [DemolisherNames.MANIS_SPEEDSTAR_BEHEMOTH_ALT] = 8.3,
}

-- ------------------------------------------------------------
-- max_* ranges by species
-- ------------------------------------------------------------
local LIFE_MIN = 120
local GROWTH_MIN = 30
local SATIETY_MIN = 75

local LIFE_MAX = {
  [DemolisherNames.SMALL] = 180,
  [DemolisherNames.MANIS_SMALL] = 180,
  [DemolisherNames.MANIS_SMALL_ALT] = 180,
  [DemolisherNames.MANIS_SPEEDSTAR_SMALL] = 180,
  [DemolisherNames.MANIS_SPEEDSTAR_SMALL_ALT] = 180,
  [DemolisherNames.MANIS_GIGANTIC_SMALL] = 180,
  [DemolisherNames.MANIS_GIGANTIC_SMALL_ALT] = 180,

  [DemolisherNames.MEDIUM] = 240,
  [DemolisherNames.MANIS_MEDIUM] = 240,
  [DemolisherNames.MANIS_MEDIUM_ALT] = 240,
  [DemolisherNames.MANIS_SPEEDSTAR_MEDIUM] = 240,
  [DemolisherNames.MANIS_SPEEDSTAR_MEDIUM_ALT] = 240,
  [DemolisherNames.MANIS_GIGANTIC_MEDIUM] = 240,
  [DemolisherNames.MANIS_GIGANTIC_MEDIUM_ALT] = 240,

  [DemolisherNames.BIG] = 300,
  [DemolisherNames.MANIS_BIG] = 300,
  [DemolisherNames.MANIS_BIG_ALT] = 300,
  [DemolisherNames.MANIS_SPEEDSTAR_BIG] = 300,
  [DemolisherNames.MANIS_SPEEDSTAR_BIG_ALT] = 300,
  [DemolisherNames.MANIS_GIGANTIC_BIG] = 300,
  [DemolisherNames.MANIS_GIGANTIC_BIG_ALT] = 300,

  [DemolisherNames.MANIS_BEHEMOTH] = 360,
  [DemolisherNames.MANIS_BEHEMOTH_ALT] = 360,
  [DemolisherNames.MANIS_SPEEDSTAR_BEHEMOTH] = 360,
  [DemolisherNames.MANIS_SPEEDSTAR_BEHEMOTH_ALT] = 360,
  [DemolisherNames.MANIS_GIGANTIC_BEHEMOTH] = 360,
  [DemolisherNames.MANIS_GIGANTIC_BEHEMOTH_ALT] = 360,

  [DemolisherNames.MANIS_CRAZY_KING] = 360,
  [DemolisherNames.MANIS_CRAZY_KING_ALT] = 360,
}

local GROWTH_MAX = {
  [DemolisherNames.SMALL] = 50,
  [DemolisherNames.MANIS_SMALL] = 50,
  [DemolisherNames.MANIS_SMALL_ALT] = 50,
  [DemolisherNames.MANIS_SPEEDSTAR_SMALL] = 50,
  [DemolisherNames.MANIS_SPEEDSTAR_SMALL_ALT] = 50,
  [DemolisherNames.MANIS_GIGANTIC_SMALL] = 50,
  [DemolisherNames.MANIS_GIGANTIC_SMALL_ALT] = 50,

  [DemolisherNames.MEDIUM] = 75,
  [DemolisherNames.MANIS_MEDIUM] = 75,
  [DemolisherNames.MANIS_MEDIUM_ALT] = 75,
  [DemolisherNames.MANIS_SPEEDSTAR_MEDIUM] = 75,
  [DemolisherNames.MANIS_SPEEDSTAR_MEDIUM_ALT] = 75,
  [DemolisherNames.MANIS_GIGANTIC_MEDIUM] = 75,
  [DemolisherNames.MANIS_GIGANTIC_MEDIUM_ALT] = 75,

  [DemolisherNames.BIG] = 100,
  [DemolisherNames.MANIS_BIG] = 100,
  [DemolisherNames.MANIS_BIG_ALT] = 100,
  [DemolisherNames.MANIS_SPEEDSTAR_BIG] = 100,
  [DemolisherNames.MANIS_SPEEDSTAR_BIG_ALT] = 100,
  [DemolisherNames.MANIS_GIGANTIC_BIG] = 100,
  [DemolisherNames.MANIS_GIGANTIC_BIG_ALT] = 100,

  [DemolisherNames.MANIS_BEHEMOTH] = 125,
  [DemolisherNames.MANIS_BEHEMOTH_ALT] = 125,
  [DemolisherNames.MANIS_SPEEDSTAR_BEHEMOTH] = 125,
  [DemolisherNames.MANIS_SPEEDSTAR_BEHEMOTH_ALT] = 125,
  [DemolisherNames.MANIS_GIGANTIC_BEHEMOTH] = 125,
  [DemolisherNames.MANIS_GIGANTIC_BEHEMOTH_ALT] = 125,

  [DemolisherNames.MANIS_CRAZY_KING] = 125,
  [DemolisherNames.MANIS_CRAZY_KING_ALT] = 125,
}

local SATIETY_MAX = {
  [DemolisherNames.SMALL] = 100,
  [DemolisherNames.MANIS_SMALL] = 100,
  [DemolisherNames.MANIS_SMALL_ALT] = 100,
  [DemolisherNames.MANIS_SPEEDSTAR_SMALL] = 100,
  [DemolisherNames.MANIS_SPEEDSTAR_SMALL_ALT] = 100,
  [DemolisherNames.MANIS_GIGANTIC_SMALL] = 100,
  [DemolisherNames.MANIS_GIGANTIC_SMALL_ALT] = 100,

  [DemolisherNames.MEDIUM] = 150,
  [DemolisherNames.MANIS_MEDIUM] = 150,
  [DemolisherNames.MANIS_MEDIUM_ALT] = 150,
  [DemolisherNames.MANIS_SPEEDSTAR_MEDIUM] = 150,
  [DemolisherNames.MANIS_SPEEDSTAR_MEDIUM_ALT] = 150,
  [DemolisherNames.MANIS_GIGANTIC_MEDIUM] = 150,
  [DemolisherNames.MANIS_GIGANTIC_MEDIUM_ALT] = 150,

  [DemolisherNames.BIG] = 200,
  [DemolisherNames.MANIS_BIG] = 200,
  [DemolisherNames.MANIS_BIG_ALT] = 200,
  [DemolisherNames.MANIS_SPEEDSTAR_BIG] = 200,
  [DemolisherNames.MANIS_SPEEDSTAR_BIG_ALT] = 200,
  [DemolisherNames.MANIS_GIGANTIC_BIG] = 200,
  [DemolisherNames.MANIS_GIGANTIC_BIG_ALT] = 200,

  [DemolisherNames.MANIS_BEHEMOTH] = 250,
  [DemolisherNames.MANIS_BEHEMOTH_ALT] = 250,
  [DemolisherNames.MANIS_SPEEDSTAR_BEHEMOTH] = 250,
  [DemolisherNames.MANIS_SPEEDSTAR_BEHEMOTH_ALT] = 250,
  [DemolisherNames.MANIS_GIGANTIC_BEHEMOTH] = 250,
  [DemolisherNames.MANIS_GIGANTIC_BEHEMOTH_ALT] = 250,

  [DemolisherNames.MANIS_CRAZY_KING] = 250,
  [DemolisherNames.MANIS_CRAZY_KING_ALT] = 250,
}

-- ------------------------------------------------------------
-- Trait expression thresholds
-- By default, threshold is 0 (express if strength >= 0).
-- You can override per trait id.
-- ------------------------------------------------------------
local DEFAULT_TRAIT_THRESHOLD = 0.0

-- [trait_id] = threshold
local TRAIT_THRESHOLD = {
  -- Fill with actual trait IDs/constants in your project.
  -- You may set some to 10.0 etc. to represent "latent but not expressed".
}

local function get_trait_threshold(trait_id)
  local t = TRAIT_THRESHOLD[trait_id]
  if type(t) ~= "number" then return DEFAULT_TRAIT_THRESHOLD end
  return t
end

-- ------------------------------------------------------------
-- Public API
-- ------------------------------------------------------------

-- Compute spawn-safe numeric values and derived strings.
-- Input "gen" is a table with at least:
--   gen.entity_name (string)
--   gen.size (number)
--   gen.speed (number)
--   gen.quality (number)   -- continuous genetic quality
--   gen.max_life (number)
--   gen.max_growth (number)
--   gen.max_satiety (number)
--   gen.traits (table)     -- all genetic traits (may include negative)
--
-- Returns:
--   out = {
--     entity_name,
--     size,
--     speed,
--     max_life,
--     max_growth,
--     max_satiety,
--     quality_name,
--     expressed_traits,   -- filtered by threshold (not deleting original traits)
--   }
--
function C.compute_spawn_values(gen)
  gen = gen or {}
  local entity_name = gen.entity_name

  -- size clamp (upper bound only)
  local size = num_or(gen.size, 0)
  local size_cap = SIZE_CAP[entity_name]
  if type(size_cap) == "number" then
    size = math.min(size, size_cap)
  end

  -- speed clamp by base * [0.5, 2.0]
  local speed = num_or(gen.speed, 0)

  local base = SPEED_BASE_NORMAL[entity_name]
  if base == nil then
    base = SPEED_BASE_SPEEDSTAR[entity_name]
  end
  if type(base) == "number" then
    local lo = base * 0.5
    local hi = base * 2.0
    speed = clamp(speed, lo, hi)
  end

  -- max_* clamp
  local max_life = num_or(gen.max_life, LIFE_MIN)
  local max_growth = num_or(gen.max_growth, GROWTH_MIN)
  local max_satiety = num_or(gen.max_satiety, SATIETY_MIN)

  local life_hi = LIFE_MAX[entity_name] or LIFE_MAX[DemolisherNames.SMALL] or 180
  local growth_hi = GROWTH_MAX[entity_name] or GROWTH_MAX[DemolisherNames.SMALL] or 50
  local satiety_hi = SATIETY_MAX[entity_name] or SATIETY_MAX[DemolisherNames.SMALL] or 100

  max_life = clamp(max_life, LIFE_MIN, life_hi)
  max_growth = clamp(max_growth, GROWTH_MIN, growth_hi)
  max_satiety = clamp(max_satiety, SATIETY_MIN, satiety_hi)

  -- quality_name (Factorio 5-step item quality)
  local quality_name = QualityUtil.to_item_quality_name(gen.quality)

  -- expressed traits: keep only those meeting threshold.
  local expressed = {}
  if type(gen.traits) == "table" then
    for trait_id, strength in pairs(gen.traits) do
      if type(strength) == "number" then
        local th = get_trait_threshold(trait_id)
        if strength >= th then
          expressed[trait_id] = strength
        end
      end
    end
  end

  return {
    entity_name = entity_name,
    size = size,
    speed = speed,
    max_life = max_life,
    max_growth = max_growth,
    max_satiety = max_satiety,
    quality_name = quality_name,
    expressed_traits = expressed,
  }
end

function C.set_trait_threshold(trait_id, threshold)
  if trait_id == nil then return end
  if type(threshold) ~= "number" then return end
  TRAIT_THRESHOLD[trait_id] = threshold
end

C.SIZE_CAP = SIZE_CAP
C.LIFE_MIN = LIFE_MIN
C.GROWTH_MIN = GROWTH_MIN
C.SATIETY_MIN = SATIETY_MIN
C.LIFE_MAX = LIFE_MAX
C.GROWTH_MAX = GROWTH_MAX
C.SATIETY_MAX = SATIETY_MAX

return C