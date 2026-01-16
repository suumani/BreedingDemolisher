-- __BreedingDemolisher__/scripts/policies/EggMutationPolicy.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Given a parent demolisher name and evolution factor, decide the egg entity name.
--
-- Design:
--   - Default: egg is same species as parent
--   - Mutation: at thresholds, eggs may mutate into main line
--   - Speedstar/Behemoth lines are enabled ONLY when ManisBossDemolisher is active
--   - Deterministic: uses DRand.random() only
--   - No prototype probing, no pcall
-- ------------------------------------------------------------
local P = {}

local DRand = require("scripts.util.DeterministicRandom")
local DemolisherNames = require("__Manis_definitions__/scripts/definition/DemolisherNames")

local HAS_BOSS = (script and script.active_mods and script.active_mods["ManisBossDemolisher"]) ~= nil
local HAS_SPEEDSTAR = HAS_BOSS
local HAS_BEHEMOTH  = HAS_BOSS

local function calc_mutation_rate(e, t)
  if e < t then return 0 end
  if t >= 1.0 then return 0 end

  local x = (e - t) / (1.0 - t)
  local p = 0.10 + (0.30 - 0.10) * x

  if p < 0.10 then p = 0.10 end
  if p > 0.30 then p = 0.30 end
  return p
end

local NEXT_MAIN = {
  [DemolisherNames.SMALL]  = DemolisherNames.MEDIUM,
  [DemolisherNames.MEDIUM] = DemolisherNames.BIG,
  [DemolisherNames.BIG]    = DemolisherNames.MANIS_BEHEMOTH,

  [DemolisherNames.MANIS_SMALL]  = DemolisherNames.MANIS_MEDIUM,
  [DemolisherNames.MANIS_MEDIUM] = DemolisherNames.MANIS_BIG,
  [DemolisherNames.MANIS_BIG]    = DemolisherNames.MANIS_BEHEMOTH,

  [DemolisherNames.MANIS_SMALL_ALT]  = DemolisherNames.MANIS_MEDIUM_ALT,
  [DemolisherNames.MANIS_MEDIUM_ALT] = DemolisherNames.MANIS_BIG_ALT,
  [DemolisherNames.MANIS_BIG_ALT]    = DemolisherNames.MANIS_BEHEMOTH_ALT,
}

local NEXT_SPEEDSTAR = {
  [DemolisherNames.MANIS_SPEEDSTAR_SMALL]      = DemolisherNames.MANIS_SPEEDSTAR_MEDIUM,
  [DemolisherNames.MANIS_SPEEDSTAR_MEDIUM]     = DemolisherNames.MANIS_SPEEDSTAR_BIG,
  [DemolisherNames.MANIS_SPEEDSTAR_SMALL_ALT]  = DemolisherNames.MANIS_SPEEDSTAR_MEDIUM_ALT,
  [DemolisherNames.MANIS_SPEEDSTAR_MEDIUM_ALT] = DemolisherNames.MANIS_SPEEDSTAR_BIG_ALT,
}

local ENTRY_SPEEDSTAR_SMALL = {
  [DemolisherNames.MEDIUM]           = DemolisherNames.MANIS_SPEEDSTAR_SMALL,
  [DemolisherNames.MANIS_MEDIUM]     = DemolisherNames.MANIS_SPEEDSTAR_SMALL,
  [DemolisherNames.MANIS_MEDIUM_ALT] = DemolisherNames.MANIS_SPEEDSTAR_SMALL_ALT,
}

local ENTRY_SPEEDSTAR_MEDIUM = {
  [DemolisherNames.BIG]           = DemolisherNames.MANIS_SPEEDSTAR_MEDIUM,
  [DemolisherNames.MANIS_BIG]     = DemolisherNames.MANIS_SPEEDSTAR_MEDIUM,
  [DemolisherNames.MANIS_BIG_ALT] = DemolisherNames.MANIS_SPEEDSTAR_MEDIUM_ALT,
}

local function build_candidates(parent_name, evo)
  local c = {}

  -- main evolution (behemoth is gated)
  do
    local to_main = NEXT_MAIN[parent_name]
    if to_main ~= nil then
      local t
      if parent_name == DemolisherNames.SMALL
        or parent_name == DemolisherNames.MANIS_SMALL
        or parent_name == DemolisherNames.MANIS_SMALL_ALT then
        t = 0.25
      elseif parent_name == DemolisherNames.MEDIUM
        or parent_name == DemolisherNames.MANIS_MEDIUM
        or parent_name == DemolisherNames.MANIS_MEDIUM_ALT then
        t = 0.50
      else
        t = 0.75
      end

      if t == 0.75 and not HAS_BEHEMOTH then
        -- skip
      elseif evo >= t then
        c[#c+1] = { t = t, to = to_main, weight = 80, kind = "main" }
      end
    end
  end

  if not HAS_SPEEDSTAR then
    return c
  end

  -- speedstar derived line
  do
    local to_ss = ENTRY_SPEEDSTAR_SMALL[parent_name]
    if to_ss ~= nil and evo >= 0.85 then
      c[#c+1] = { t = 0.85, to = to_ss, weight = 20, kind = "speedstar" }
    end
  end

  do
    local to_ss = ENTRY_SPEEDSTAR_MEDIUM[parent_name]
    if to_ss ~= nil and evo >= 0.95 then
      c[#c+1] = { t = 0.95, to = to_ss, weight = 20, kind = "speedstar" }
    end
  end

  do
    local to_ss = nil
    if parent_name == DemolisherNames.MANIS_BEHEMOTH then
      to_ss = DemolisherNames.MANIS_SPEEDSTAR_BIG
    elseif parent_name == DemolisherNames.MANIS_BEHEMOTH_ALT then
      to_ss = DemolisherNames.MANIS_SPEEDSTAR_BIG_ALT
    end

    if to_ss ~= nil and evo >= 0.98 then
      c[#c+1] = { t = 0.98, to = to_ss, weight = 20, kind = "speedstar" }
    end
  end

  -- speedstar internal progression
  do
    local to_ss_next = NEXT_SPEEDSTAR[parent_name]
    if to_ss_next ~= nil then
      local t_ss = (parent_name == DemolisherNames.MANIS_SPEEDSTAR_SMALL
                 or parent_name == DemolisherNames.MANIS_SPEEDSTAR_SMALL_ALT) and 0.95 or 0.98
      if evo >= t_ss then
        c[#c+1] = { t = t_ss, to = to_ss_next, weight = 80, kind = "speedstar" }
      end
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
    if r <= acc then return it end
  end
  return nil
end

function P.pick_egg_entity_name(parent_name, evolution_factor)
  if type(parent_name) ~= "string" or parent_name == "" then
    return parent_name
  end

  local candidates = build_candidates(parent_name, evolution_factor)
  if #candidates == 0 then
    return parent_name
  end

  local t_min = candidates[1].t
  for i = 2, #candidates do
    if candidates[i].t < t_min then t_min = candidates[i].t end
  end

  local p = calc_mutation_rate(evolution_factor, t_min)
  if p <= 0 or DRand.random() >= p then
    return parent_name
  end

  local picked = choose_weighted(candidates)
  return (picked and picked.to) or parent_name
end

return P