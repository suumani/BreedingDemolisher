-- __BreedingDemolisher__/scripts/domain/genetics/ForceTransitionPolicy.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Decide the next generation force (egg force) from parent force(s),
--   using:
--     - Base transition matrix (two parents, research=0)
--     - Research convergence (infinite research, half-life=2)
--     - Single-parent penalty (explicit correction table)
--     - If parents have different forces: average their transition rows
--
-- Notes:
--   - "Force" here means the egg's force stage:
--       "enemy" | "demolishers" | "player"
--   - Post-hatch force change is out of scope.
--   - This module is deterministic via DRand (shared RNG stream).
-- ------------------------------------------------------------
local P = {}

local DRand = require("scripts.util.DeterministicRandom")

-- ----------------------------
-- Force identifiers (strings)
-- ----------------------------
local FORCE_ENEMY = "enemy"
local FORCE_DEMOLISHERS = "demolishers"
local FORCE_PLAYER = "player"

-- ----------------------------
-- Base transition matrix (two parents, research=0)
-- row[parent_force][child_force] = probability (0..1)
-- ----------------------------
local BASE_ROW = {
  [FORCE_ENEMY] = {
    [FORCE_ENEMY] = 0.60,
    [FORCE_DEMOLISHERS] = 0.40,
    [FORCE_PLAYER] = 0.00,
  },
  [FORCE_DEMOLISHERS] = {
    [FORCE_ENEMY] = 0.30,
    [FORCE_DEMOLISHERS] = 0.40,
    [FORCE_PLAYER] = 0.30,
  },
  [FORCE_PLAYER] = {
    [FORCE_ENEMY] = 0.10,
    [FORCE_DEMOLISHERS] = 0.30,
    [FORCE_PLAYER] = 0.60,
  },
}

-- ----------------------------
-- Single-parent correction table
-- This represents the "unfriendly direction" bias for single-parent breeding.
-- ----------------------------
local SINGLE_PARENT_ROW = {
  [FORCE_ENEMY] = {
    [FORCE_ENEMY] = 0.80,
    [FORCE_DEMOLISHERS] = 0.20,
    [FORCE_PLAYER] = 0.00,
  },
  [FORCE_DEMOLISHERS] = {
    [FORCE_ENEMY] = 0.55,
    [FORCE_DEMOLISHERS] = 0.30,
    [FORCE_PLAYER] = 0.15,
  },
  [FORCE_PLAYER] = {
    [FORCE_ENEMY] = 0.15,
    [FORCE_DEMOLISHERS] = 0.40,
    [FORCE_PLAYER] = 0.45,
  },
}

-- ----------------------------
-- Research convergence
-- Half-life is fixed to 2.
-- ----------------------------
local HALF_LIFE = 2.0
local LN2 = 0.6931471805599453

local function clamp01(x)
  if x < 0 then return 0 end
  if x > 1 then return 1 end
  return x
end

local function normalize_row(row)
  local a = (row[FORCE_ENEMY] or 0)
  local b = (row[FORCE_DEMOLISHERS] or 0)
  local c = (row[FORCE_PLAYER] or 0)
  local s = a + b + c
  if s <= 0 then
    row[FORCE_ENEMY] = 1
    row[FORCE_DEMOLISHERS] = 0
    row[FORCE_PLAYER] = 0
    return row
  end
  row[FORCE_ENEMY] = a / s
  row[FORCE_DEMOLISHERS] = b / s
  row[FORCE_PLAYER] = c / s
  return row
end

local function copy_row(src)
  return {
    [FORCE_ENEMY] = src[FORCE_ENEMY] or 0,
    [FORCE_DEMOLISHERS] = src[FORCE_DEMOLISHERS] or 0,
    [FORCE_PLAYER] = src[FORCE_PLAYER] or 0,
  }
end

local function average_rows(a, b)
  return {
    [FORCE_ENEMY] = ((a[FORCE_ENEMY] or 0) + (b[FORCE_ENEMY] or 0)) / 2,
    [FORCE_DEMOLISHERS] = ((a[FORCE_DEMOLISHERS] or 0) + (b[FORCE_DEMOLISHERS] or 0)) / 2,
    [FORCE_PLAYER] = ((a[FORCE_PLAYER] or 0) + (b[FORCE_PLAYER] or 0)) / 2,
  }
end

-- p(n) = p_inf - (p_inf - p0) * exp(-k*n), k = ln(2)/half_life
local function converge(p0, p_inf, n)
  if type(n) ~= "number" or n <= 0 then return p0 end
  local k = LN2 / HALF_LIFE
  local e = math.exp(-k * n)
  return p_inf - (p_inf - p0) * e
end

local function apply_research(parent_force, row, research_level)
  local n = research_level
  if type(n) ~= "number" or n < 0 then n = 0 end

  if parent_force == FORCE_ENEMY then
    local d0 = row[FORCE_DEMOLISHERS]
    local d_inf = 0.60
    local d = clamp01(converge(d0, d_inf, n))
    row[FORCE_DEMOLISHERS] = d
    row[FORCE_ENEMY] = 1.0 - d
    row[FORCE_PLAYER] = 0.0
    return normalize_row(row)
  end

  if parent_force == FORCE_DEMOLISHERS then
    local p0 = row[FORCE_PLAYER]
    local e0 = row[FORCE_ENEMY]
    local p_inf = 0.60
    local e_inf = 0.15
    local p = clamp01(converge(p0, p_inf, n))
    local e = clamp01(converge(e0, e_inf, n))
    local m = 1.0 - (p + e)
    if m < 0 then
      row[FORCE_PLAYER] = p
      row[FORCE_ENEMY] = e
      row[FORCE_DEMOLISHERS] = 0
      return normalize_row(row)
    end
    row[FORCE_PLAYER] = p
    row[FORCE_ENEMY] = e
    row[FORCE_DEMOLISHERS] = m
    return normalize_row(row)
  end

  -- FORCE_PLAYER
  do
    local e0 = row[FORCE_ENEMY]
    local m0 = row[FORCE_DEMOLISHERS]
    local e_inf = 0.05
    local m_inf = 0.15
    local e = clamp01(converge(e0, e_inf, n))
    local m = clamp01(converge(m0, m_inf, n))
    local p = 1.0 - (e + m)
    if p < 0 then
      row[FORCE_ENEMY] = e
      row[FORCE_DEMOLISHERS] = m
      row[FORCE_PLAYER] = 0
      return normalize_row(row)
    end
    row[FORCE_ENEMY] = e
    row[FORCE_DEMOLISHERS] = m
    row[FORCE_PLAYER] = p
    return normalize_row(row)
  end
end

-- Blend a research-applied row with the single-parent correction row.
-- alpha=0 -> keep research row, alpha=1 -> use single-parent row.
local function blend_rows(row_research, row_single, alpha)
  local a = alpha
  if type(a) ~= "number" then a = 1.0 end
  if a < 0 then a = 0 end
  if a > 1 then a = 1 end

  local out = {
    [FORCE_ENEMY] = (row_research[FORCE_ENEMY] or 0) * (1 - a) + (row_single[FORCE_ENEMY] or 0) * a,
    [FORCE_DEMOLISHERS] = (row_research[FORCE_DEMOLISHERS] or 0) * (1 - a) + (row_single[FORCE_DEMOLISHERS] or 0) * a,
    [FORCE_PLAYER] = (row_research[FORCE_PLAYER] or 0) * (1 - a) + (row_single[FORCE_PLAYER] or 0) * a,
  }
  return normalize_row(out)
end

-- Public: build transition probability row for given parent(s).
function P.build_transition_row(parent_force_a, parent_force_b, parent_count, research_level)
  local pf_a = parent_force_a or FORCE_ENEMY
  local pf_b = parent_force_b or pf_a
  local pc = parent_count or (parent_force_b and 2 or 1)

  -- Step 1: research-applied baseline rows
  local row_a = apply_research(pf_a, copy_row(BASE_ROW[pf_a] or BASE_ROW[FORCE_ENEMY]), research_level)
  local row = row_a

  if pc >= 2 then
    local row_b = apply_research(pf_b, copy_row(BASE_ROW[pf_b] or BASE_ROW[FORCE_ENEMY]), research_level)
    row = normalize_row(average_rows(row_a, row_b))
  end

  -- Step 2: single-parent penalty (after research)
  if pc <= 1 then
    local row_single = copy_row(SINGLE_PARENT_ROW[pf_a] or SINGLE_PARENT_ROW[FORCE_ENEMY])
    -- alpha close to 1 means strong single-parent penalty while still allowing research influence.
    row = blend_rows(row, row_single, 0.85)
  end

  return row
end

local function sample_from_row(row)
  local r = DRand.random()
  local p_enemy = row[FORCE_ENEMY] or 0
  local p_demo = row[FORCE_DEMOLISHERS] or 0
  if r < p_enemy then return FORCE_ENEMY end
  if r < (p_enemy + p_demo) then return FORCE_DEMOLISHERS end
  return FORCE_PLAYER
end

function P.choose_child_force(parent_force_a, parent_force_b, parent_count, research_level)
  local row = P.build_transition_row(parent_force_a, parent_force_b, parent_count, research_level)
  return sample_from_row(row)
end

return P