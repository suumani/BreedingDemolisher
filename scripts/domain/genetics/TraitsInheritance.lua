-- __BreedingDemolisher__/scripts/domain/genetics/TraitsInheritance.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Inherit and mutate genetic traits (特性) for the next generation.
--
-- Design (v0.5.6):
--   - Trait representation: { [trait_id] = strength_number }, strength may be negative.
--   - Stage 1 (inheritance):
--       - Union of parents' trait IDs
--       - If both have same trait: take max strength
--   - Stage 2 (mutation):
--       - Symmetric +/- strength delta per trait (small)
--       - Mean drift via force/parent bonus can be applied (optional)
--       - Random new trait addition with probability (mutation)
--   - "Loss" is NOT deletion. Non-expression is handled at spawn time
--     (threshold per trait), not here.
--
-- Notes:
--   - This module never deletes traits by policy.
--   - Negative strengths are kept.
--   - Deterministic RNG via DRand (shared RNG stream).
-- ------------------------------------------------------------
local R = {}

local DRand = require("scripts.util.DeterministicRandom")

local FORCE_ENEMY = "enemy"
local FORCE_DEMOLISHERS = "demolishers"
local FORCE_PLAYER = "player"

-- Conservative defaults; tune later in config.
local DEFAULTS = {
  -- Per-trait mutation amplitude (strength delta): symmetric +/-.
  -- Example: 0.10 means each trait strength shifts within [-0.10, +0.10] (+ drift).
  per_trait_amplitude = 0.10,

  -- Mean drift factors (do not widen range, only shift mean).
  force_drift = {
    [FORCE_ENEMY] = 0.00,
    [FORCE_DEMOLISHERS] = 0.02,
    [FORCE_PLAYER] = 0.05,
  },

  -- Two-parent drift bonus (added to force drift).
  two_parent_bonus = 0.02,

  -- Single-parent drift (added when single parent).
  single_parent_drift = 0.00,

  -- New trait addition (mutation) probability.
  add_trait_probability = 0.05,

  -- Initial strength range for newly added trait (negative allowed).
  add_trait_strength_min = -0.10,
  add_trait_strength_max = 0.30,
}

-- ----------------------------
-- helpers
-- ----------------------------
local function copy_traits(t)
  local out = {}
  if type(t) ~= "table" then return out end
  for k, v in pairs(t) do
    if v ~= nil then out[k] = v end
  end
  return out
end

local function max(a, b) return (a > b) and a or b end

local FLOAT_SCALE = 1000000

local function rand_int(lo, hi)
  return DRand.random(lo, hi)
end

local function rand_float(lo, hi)
  if type(lo) ~= "number" then lo = 0 end
  if type(hi) ~= "number" then hi = 0 end
  if hi < lo then lo, hi = hi, lo end
  local ilo = math.floor(lo * FLOAT_SCALE)
  local ihi = math.floor(hi * FLOAT_SCALE)
  if ihi < ilo then ihi = ilo end
  return rand_int(ilo, ihi) / FLOAT_SCALE
end

local function rand_unit_symmetric()
  return rand_float(-1.0, 1.0)
end

local function get_force_drift(force, cfg)
  local tbl = (cfg and cfg.force_drift) or DEFAULTS.force_drift
  return tbl[force] or tbl[FORCE_ENEMY] or 0.0
end

local function get_parent_drift(parent_count, cfg)
  local pc = parent_count or 1
  if pc >= 2 then
    return (cfg and cfg.two_parent_bonus) or DEFAULTS.two_parent_bonus
  end
  return (cfg and cfg.single_parent_drift) or DEFAULTS.single_parent_drift
end

-- ----------------------------
-- Stage 1: union + max
-- ----------------------------
local function stage1_union_max(parent_traits_a, parent_traits_b, parent_count)
  local pc = parent_count or (parent_traits_b and 2 or 1)

  local a = (type(parent_traits_a) == "table") and parent_traits_a or nil
  local b = (pc >= 2 and type(parent_traits_b) == "table") and parent_traits_b or nil

  if not a and not b then return {} end
  if a and not b then return copy_traits(a) end
  if b and not a then return copy_traits(b) end

  local out = {}
  for k, v in pairs(a) do
    out[k] = v
  end
  for k, v in pairs(b) do
    if out[k] == nil then
      out[k] = v
    else
      out[k] = max(out[k], v)
    end
  end
  return out
end

-- ----------------------------
-- Stage 2: mutate each existing trait strength (keep negative)
-- ----------------------------
local function stage2_mutate_strengths(traits, force, parent_count, cfg)
  local out = copy_traits(traits)
  local amp = (cfg and cfg.per_trait_amplitude) or DEFAULTS.per_trait_amplitude

  if amp == 0 then
    return out
  end

  local drift = get_force_drift(force or FORCE_ENEMY, cfg) + get_parent_drift(parent_count, cfg)
  local mean_shift = amp * drift

  for k, v in pairs(out) do
    if type(v) == "number" then
      local delta = rand_unit_symmetric() * amp
      out[k] = v + delta + mean_shift
    end
  end

  return out
end

-- ----------------------------
-- Stage 2: maybe add new trait
-- ----------------------------
local function stage2_maybe_add_trait(traits, trait_pool, cfg)
  local out = copy_traits(traits)

  local p = (cfg and cfg.add_trait_probability) or DEFAULTS.add_trait_probability
  if p <= 0 then return out end
  if DRand.random() >= p then return out end

  if type(trait_pool) ~= "table" or #trait_pool == 0 then
    return out
  end

  local idx = DRand.random(1, #trait_pool)
  local trait_id = trait_pool[idx]
  if trait_id == nil then return out end

  local minv = (cfg and cfg.add_trait_strength_min) or DEFAULTS.add_trait_strength_min
  local maxv = (cfg and cfg.add_trait_strength_max) or DEFAULTS.add_trait_strength_max
  local addv = rand_float(minv, maxv)

  if out[trait_id] == nil then
    out[trait_id] = addv
  else
    out[trait_id] = out[trait_id] + addv
  end

  return out
end

-- ------------------------------------------------------------
-- Public API
-- ------------------------------------------------------------
function R.inherit_two_stage(parent_traits_a, parent_traits_b, parent_count, force, trait_pool, cfg)
  local pc = parent_count or (parent_traits_b and 2 or 1)

  local t1 = stage1_union_max(parent_traits_a, parent_traits_b, pc)
  local t2 = stage2_mutate_strengths(t1, force, pc, cfg)
  local t3 = stage2_maybe_add_trait(t2, trait_pool, cfg)

  return t3
end

R.DEFAULTS = DEFAULTS
R.FORCE_ENEMY = FORCE_ENEMY
R.FORCE_DEMOLISHERS = FORCE_DEMOLISHERS
R.FORCE_PLAYER = FORCE_PLAYER

return R