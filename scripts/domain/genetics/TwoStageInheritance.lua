-- __BreedingDemolisher__/scripts/domain/genetics/TwoStageInheritance.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Provide a unified two-stage inheritance model for numeric parameters.
--
-- Stage 1: Parental inheritance (within parent range)
--   - Choose a base parent per parameter (random A/B)
--   - Pull slightly toward the other parent (bounded by base parent's value ratio)
--   - Clamp within [min(parentA, parentB), max(parentA, parentB)]
--
-- Stage 2: Mutation (may exceed parent range)
--   - Symmetric +/- mutation
--   - Apply mean drift based on force (enemy/demolishers/player) and parent count
--   - No clamp here (spawn-time clamp is handled elsewhere)
--
-- Notes:
--   - Deterministic RNG via DRand (shared RNG stream).
--   - This module does NOT know about entity creation caps.
-- ------------------------------------------------------------
local T = {}

local DRand = require("scripts.util.DeterministicRandom")

-- ----------------------------
-- Force identifiers (strings)
-- ----------------------------
local FORCE_ENEMY = "enemy"
local FORCE_DEMOLISHERS = "demolishers"
local FORCE_PLAYER = "player"

-- ----------------------------
-- Helpers
-- ----------------------------
local function clamp(x, lo, hi)
  if x < lo then return lo end
  if x > hi then return hi end
  return x
end

local function min(a, b) return (a < b) and a or b end
local function max(a, b) return (a > b) and a or b end

local function num_or(x, fallback)
  return (type(x) == "number") and x or fallback
end

-- Deterministic float generation via integer RNG.
-- (Avoid relying on DRand.random() accepting floats.)
local FLOAT_SCALE = 1000000

local function rand_int(lo, hi)
  -- DRand.random(lo, hi): inclusive integer range (assumed by existing codebase)
  return DRand.random(lo, hi)
end

local function rand_float(lo, hi)
  lo = num_or(lo, 0)
  hi = num_or(hi, 0)
  if hi < lo then lo, hi = hi, lo end
  local ilo = math.floor(lo * FLOAT_SCALE)
  local ihi = math.floor(hi * FLOAT_SCALE)
  if ihi < ilo then ihi = ilo end
  return rand_int(ilo, ihi) / FLOAT_SCALE
end

local function rand_unit_symmetric()
  return rand_float(-1.0, 1.0)
end

-- ----------------------------
-- Drift policy
-- ----------------------------
-- Mean drift represents "advantage" by shifting expected mutation delta.
-- It does NOT widen the mutation range.
local DEFAULT_FORCE_DRIFT = {
  [FORCE_ENEMY] = 0.00,
  [FORCE_DEMOLISHERS] = 0.05,
  [FORCE_PLAYER] = 0.10,
}

local function get_force_drift(force, force_drift)
  local tbl = force_drift or DEFAULT_FORCE_DRIFT
  return tbl[force] or tbl[FORCE_ENEMY] or 0.00
end

local function get_parentcount_drift(parent_count, two_parent_bonus)
  if (parent_count or 1) >= 2 then
    return num_or(two_parent_bonus, 0.05)
  end
  -- single-parent disadvantage is controlled by cfg.single_parent_drift (optional)
  return 0.0
end

-- ----------------------------
-- Stage 1: parental inheritance (within parent range)
-- ----------------------------
-- Pull amount is bounded by "base parent magnitude ratio" rather than diff ratio:
--   huge x small should not explode due to diff%.
--
-- opts:
--   base_value_a (number) required
--   base_value_b (number|nil) optional
--   parent_count (1|2) optional
--   pull_ratio (number) e.g. 0.10 (max pull = |base| * pull_ratio)
--   pull_scale (number) optional multiplier
local function stage1_inherit(opts)
  local a = num_or(opts.base_value_a, 0)
  local b = opts.base_value_b
  local pc = opts.parent_count or ((type(b) == "number") and 2 or 1)

  if pc <= 1 or type(b) ~= "number" then
    return a
  end

  local bnum = b

  -- choose base parent
  local use_a = (DRand.random() < 0.5)
  local base = use_a and a or bnum
  local other = use_a and bnum or a

  local lo = min(a, bnum)
  local hi = max(a, bnum)

  local pull_ratio = num_or(opts.pull_ratio, 0.10)
  if pull_ratio < 0 then pull_ratio = 0 end

  local pull_scale = num_or(opts.pull_scale, 1.0)
  if pull_scale < 0 then pull_scale = 0 end

  local max_pull = math.abs(base) * pull_ratio * pull_scale
  if max_pull <= 0 then
    return base
  end

  -- pull direction toward other
  local dir = 0
  if other > base then dir = 1
  elseif other < base then dir = -1
  else dir = 0 end

  if dir == 0 then
    return base
  end

  -- pull amount in [0, max_pull]
  local pull = rand_float(0.0, max_pull)
  local v = base + dir * pull

  -- clamp within parent range for stage1
  v = clamp(v, lo, hi)
  return v
end

-- ----------------------------
-- Stage 2: mutation (symmetric +/-) + mean drift
-- ----------------------------
-- opts:
--   value (number) required
--   mutation_amplitude (number) required (e.g. +/-2, +/-1, +/-3)
--   force (string) optional
--   parent_count (1|2) optional
--   force_drift (table) optional
--   two_parent_bonus (number) optional
--   single_parent_drift (number) optional (negative or 0)
local function stage2_mutate(opts)
  local v = num_or(opts.value, 0)
  local amp = num_or(opts.mutation_amplitude, 0)

  if amp == 0 then
    return v
  end

  local force = opts.force or FORCE_ENEMY
  local pc = opts.parent_count or 1

  local force_drift = get_force_drift(force, opts.force_drift)
  local pc_drift = get_parentcount_drift(pc, opts.two_parent_bonus)

  local spd = opts.single_parent_drift
  if pc <= 1 and type(spd) == "number" then
    pc_drift = pc_drift + spd
  end

  -- symmetric delta in [-amp, +amp]
  local delta = rand_unit_symmetric() * amp

  -- mean drift: add (amp * drift_factor) as a gentle bias
  local drift = amp * (force_drift + pc_drift)

  return v + delta + drift
end

-- ------------------------------------------------------------
-- Public API
-- ------------------------------------------------------------

-- Inherit a numeric parameter via the unified 2-stage model.
--
-- a (number): parent A value
-- b (number|nil): parent B value (nil -> single-parent)
-- parent_count (1|2|nil): explicit parent count (if omitted inferred from b)
-- force (string): "enemy"|"demolishers"|"player"
-- cfg:
--   pull_ratio (number)
--   pull_scale (number)
--   mutation_amplitude (number)
--   force_drift (table)
--   two_parent_bonus (number)
--   single_parent_drift (number)
function T.inherit_two_stage(a, b, parent_count, force, cfg)
  cfg = cfg or {}

  local pc = parent_count or ((type(b) == "number") and 2 or 1)

  -- Stage 1
  local v1 = stage1_inherit({
    base_value_a = a,
    base_value_b = b,
    parent_count = pc,
    pull_ratio = cfg.pull_ratio,
    pull_scale = cfg.pull_scale,
  })

  -- Stage 2
  local v2 = stage2_mutate({
    value = v1,
    mutation_amplitude = cfg.mutation_amplitude,
    force = force,
    parent_count = pc,
    force_drift = cfg.force_drift,
    two_parent_bonus = cfg.two_parent_bonus,
    single_parent_drift = cfg.single_parent_drift,
  })

  return v2
end

-- Convenience: inherit a fixed-amplitude parameter (like max_* with ±d).
function T.inherit_fixed_amplitude(a, b, parent_count, force, amplitude, pull_ratio, opts)
  opts = opts or {}
  return T.inherit_two_stage(a, b, parent_count, force, {
    pull_ratio = pull_ratio or 0.10,
    pull_scale = opts.pull_scale,
    mutation_amplitude = amplitude or 0,
    force_drift = opts.force_drift,
    two_parent_bonus = opts.two_parent_bonus,
    single_parent_drift = opts.single_parent_drift,
  })
end

-- Expose constants (optional usage)
T.FORCE_ENEMY = FORCE_ENEMY
T.FORCE_DEMOLISHERS = FORCE_DEMOLISHERS
T.FORCE_PLAYER = FORCE_PLAYER

return T