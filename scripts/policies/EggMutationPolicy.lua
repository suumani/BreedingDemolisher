-- __BreedingDemolisher__/scripts/policies/EggMutationPolicy.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Given a parent demolisher name and evolution factor, decide the egg entity name.
--   - Default: egg is same species as parent
--   - Mutation: at specific evolution thresholds, egg species may mutate into
--     (a) the main evolution line (preferred), or
--     (b) speedstar derived line (if prototypes exist)
--   - Deterministic: uses DRand.random() only (same RNG stream as the mod logic)
--   - Safe: skips mutation targets whose prototypes do not exist in the current save/mod set
-- ------------------------------------------------------------
local P = {}

local DRand = require("scripts.util.DeterministicRandom")
local DemolisherNames = require("__Manis_definitions__/scripts/definition/DemolisherNames")

-- ----------------------------
-- mutation rate p(e,t):
--   e < t: 0
--   e == t: 0.10
--   e == 1.0: 0.30
--   linear between
-- ----------------------------
local function calc_mutation_rate(e, t)
  if e < t then return 0 end
  if t >= 1.0 then return 0 end

  local x = (e - t) / (1.0 - t)
  local p = 0.10 + (0.30 - 0.10) * x

  if p < 0.10 then p = 0.10 end
  if p > 0.30 then p = 0.30 end
  return p
end

local function is_supported_entity(name)
  -- runtime only
  return name ~= nil and game and game.entity_prototypes and game.entity_prototypes[name] ~= nil
end

-- ----------------------------
-- Evolution line mappings
--   (default / manis / alt / speedstar / speedstar_alt)
-- ----------------------------
local NEXT_MAIN = {
  [DemolisherNames.SMALL] = DemolisherNames.MEDIUM,
  [DemolisherNames.MEDIUM] = DemolisherNames.BIG,
  -- behemoth is added by this mod set (MANIS_BEHEMOTH); if missing, rule auto-skips by prototype check
  [DemolisherNames.BIG] = DemolisherNames.MANIS_BEHEMOTH,

  [DemolisherNames.MANIS_SMALL] = DemolisherNames.MANIS_MEDIUM,
  [DemolisherNames.MANIS_MEDIUM] = DemolisherNames.MANIS_BIG,
  [DemolisherNames.MANIS_BIG] = DemolisherNames.MANIS_BEHEMOTH,

  [DemolisherNames.MANIS_SMALL_ALT] = DemolisherNames.MANIS_MEDIUM_ALT,
  [DemolisherNames.MANIS_MEDIUM_ALT] = DemolisherNames.MANIS_BIG_ALT,
  [DemolisherNames.MANIS_BIG_ALT] = DemolisherNames.MANIS_BEHEMOTH_ALT,
}

local NEXT_SPEEDSTAR = {
  [DemolisherNames.MANIS_SPEEDSTAR_SMALL] = DemolisherNames.MANIS_SPEEDSTAR_MEDIUM,
  [DemolisherNames.MANIS_SPEEDSTAR_MEDIUM] = DemolisherNames.MANIS_SPEEDSTAR_BIG,

  [DemolisherNames.MANIS_SPEEDSTAR_SMALL_ALT] = DemolisherNames.MANIS_SPEEDSTAR_MEDIUM_ALT,
  [DemolisherNames.MANIS_SPEEDSTAR_MEDIUM_ALT] = DemolisherNames.MANIS_SPEEDSTAR_BIG_ALT,
}

-- speedstar entry from mainline
local ENTRY_SPEEDSTAR_SMALL = {
  [DemolisherNames.MEDIUM] = DemolisherNames.MANIS_SPEEDSTAR_SMALL,
  [DemolisherNames.MANIS_MEDIUM] = DemolisherNames.MANIS_SPEEDSTAR_SMALL,
  [DemolisherNames.MANIS_MEDIUM_ALT] = DemolisherNames.MANIS_SPEEDSTAR_SMALL_ALT,
}

local ENTRY_SPEEDSTAR_MEDIUM = {
  [DemolisherNames.BIG] = DemolisherNames.MANIS_SPEEDSTAR_MEDIUM,
  [DemolisherNames.MANIS_BIG] = DemolisherNames.MANIS_SPEEDSTAR_MEDIUM,
  [DemolisherNames.MANIS_BIG_ALT] = DemolisherNames.MANIS_SPEEDSTAR_MEDIUM_ALT,
}

local ENTRY_SPEEDSTAR_BIG = {
  [DemolisherNames.MANIS_BEHEMOTH] = DemolisherNames.MANIS_SPEEDSTAR_BIG,
  [DemolisherNames.MANIS_BEHEMOTH_ALT] = DemolisherNames.MANIS_SPEEDSTAR_BIG_ALT,
}

-- ----------------------------
-- Build mutation candidates (table)
-- Each entry: { t = threshold, to = target_name, weight = int }
-- ----------------------------
local function build_candidates(parent_name, evo)
  local c = {}

  -- Main evolution line (preferred)
  local to_main = NEXT_MAIN[parent_name]
  if to_main ~= nil then
    -- determine threshold by tier
    local t = nil
    if parent_name == DemolisherNames.SMALL or parent_name == DemolisherNames.MANIS_SMALL or parent_name == DemolisherNames.MANIS_SMALL_ALT then
      t = 0.25
    elseif parent_name == DemolisherNames.MEDIUM or parent_name == DemolisherNames.MANIS_MEDIUM or parent_name == DemolisherNames.MANIS_MEDIUM_ALT then
      t = 0.50
    else
      -- big -> behemoth
      t = 0.75
    end

    if evo >= t then
      c[#c+1] = { t = t, to = to_main, weight = 80, kind = "main" }
    end
  end

  -- Speedstar entry / progression (derived)
  local to_ss = nil
  local t_ss = nil

  -- entry: medium -> speedstar small
  to_ss = ENTRY_SPEEDSTAR_SMALL[parent_name]
  if to_ss ~= nil then
    t_ss = 0.85
    if evo >= t_ss then
      c[#c+1] = { t = t_ss, to = to_ss, weight = 20, kind = "speedstar" }
    end
  end

  -- entry: big -> speedstar medium
  to_ss = ENTRY_SPEEDSTAR_MEDIUM[parent_name]
  if to_ss ~= nil then
    t_ss = 0.95
    if evo >= t_ss then
      c[#c+1] = { t = t_ss, to = to_ss, weight = 20, kind = "speedstar" }
    end
  end

  -- entry: behemoth -> speedstar big
  to_ss = ENTRY_SPEEDSTAR_BIG[parent_name]
  if to_ss ~= nil then
    t_ss = 0.98
    if evo >= t_ss then
      c[#c+1] = { t = t_ss, to = to_ss, weight = 20, kind = "speedstar" }
    end
  end

  -- speedstar internal progression
  local to_ss_next = NEXT_SPEEDSTAR[parent_name]
  if to_ss_next ~= nil then
    -- small->medium at 0.95, medium->big at 0.98
    if parent_name == DemolisherNames.MANIS_SPEEDSTAR_SMALL or parent_name == DemolisherNames.MANIS_SPEEDSTAR_SMALL_ALT then
      t_ss = 0.95
    else
      t_ss = 0.98
    end

    if evo >= t_ss then
      c[#c+1] = { t = t_ss, to = to_ss_next, weight = 80, kind = "speedstar" }
    end
  end

  return c
end

local function choose_weighted(list)
  local total = 0
  for _, it in ipairs(list) do
    total = total + (it.weight or 1)
  end
  if total <= 0 then return nil end

  local r = DRand.random(1, total)
  local acc = 0
  for _, it in ipairs(list) do
    acc = acc + (it.weight or 1)
    if r <= acc then
      return it
    end
  end
  return nil
end

-- ----------------------------
-- Public API
-- ----------------------------
function P.pick_egg_entity_name(parent_name, evolution_factor)
  if type(parent_name) ~= "string" or parent_name == "" then
    return parent_name
  end

  -- build candidate rules
  local candidates = build_candidates(parent_name, evolution_factor)
  if #candidates == 0 then
    return parent_name
  end

  -- mutation decision is ONCE per egg: use the smallest threshold among applicable rules
  local t_min = candidates[1].t
  for i = 2, #candidates do
    if candidates[i].t < t_min then t_min = candidates[i].t end
  end

  local p = calc_mutation_rate(evolution_factor, t_min)
  if p <= 0 then
    return parent_name
  end

  if DRand.random() >= p then
    return parent_name
  end

  -- mutate: pick a target (skip unsupported targets deterministically)
  -- try up to N times by removing invalid entries
  local pool = candidates
  for _ = 1, 8 do
    local picked = choose_weighted(pool)
    if not picked then
      return parent_name
    end

    if is_supported_entity(picked.to) then
      return picked.to
    end

    -- remove this target and retry
    local next_pool = {}
    for _, it in ipairs(pool) do
      if it ~= picked then next_pool[#next_pool+1] = it end
    end
    pool = next_pool

    if #pool == 0 then
      return parent_name
    end
  end

  return parent_name
end

return P