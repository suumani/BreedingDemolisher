-- __BreedingDemolisher__/scripts/domain/genetics/GeneticsMutator.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Orchestrate v0.5.6 genetics for producing a child Customparam.
--   - Decide egg force via ForceTransitionPolicy
--   - Apply TwoStageInheritance to all numeric parameters
--   - Apply TraitsInheritance to traits (union+max, mutate, optional add)
--   - Keep demolisher line (normal/speedstar/gigantic/king) while evolving size class
--
-- Notes:
--   - Spawn-time clamps are handled elsewhere (SpawnClampPolicy).
--   - Research level is currently treated as 0 (wire later).
-- ------------------------------------------------------------
local M = {}

local TwoStage = require("scripts.domain.genetics.TwoStageInheritance")
local TraitsInherit = require("scripts.domain.genetics.TraitsInheritance")
local ForceTrans = require("scripts.domain.genetics.ForceTransitionPolicy")

local DemolisherNames = require("__Manis_definitions__/scripts/definition/DemolisherNames")
local TraitDefs = require("scripts.domain.traits.DemolisherTraitDefinitions")

-- ------------------------------------------------------------
-- internal helpers
-- ------------------------------------------------------------
local function resolve_research_level()
  return 0
end

local function safe_force_name_from_cp(cp)
  if not cp then return nil end
  local e = cp:get_entity()
  if e and e.valid and e.force then
    return e.force.name
  end
  return nil
end

-- Determine "line" by name (normal/speedstar/gigantic/king)
local function resolve_line(name)
  if name == nil then return "normal" end
  if name == DemolisherNames.MANIS_CRAZY_KING or name == DemolisherNames.MANIS_CRAZY_KING_ALT then
    return "king"
  end
  if name == DemolisherNames.MANIS_GIGANTIC_SMALL or name == DemolisherNames.MANIS_GIGANTIC_MEDIUM
    or name == DemolisherNames.MANIS_GIGANTIC_BIG or name == DemolisherNames.MANIS_GIGANTIC_BEHEMOTH
    or name == DemolisherNames.MANIS_GIGANTIC_SMALL_ALT or name == DemolisherNames.MANIS_GIGANTIC_MEDIUM_ALT
    or name == DemolisherNames.MANIS_GIGANTIC_BIG_ALT or name == DemolisherNames.MANIS_GIGANTIC_BEHEMOTH_ALT then
    return "gigantic"
  end
  if name == DemolisherNames.MANIS_SPEEDSTAR_SMALL or name == DemolisherNames.MANIS_SPEEDSTAR_MEDIUM
    or name == DemolisherNames.MANIS_SPEEDSTAR_BIG or name == DemolisherNames.MANIS_SPEEDSTAR_BEHEMOTH
    or name == DemolisherNames.MANIS_SPEEDSTAR_SMALL_ALT or name == DemolisherNames.MANIS_SPEEDSTAR_MEDIUM_ALT
    or name == DemolisherNames.MANIS_SPEEDSTAR_BIG_ALT or name == DemolisherNames.MANIS_SPEEDSTAR_BEHEMOTH_ALT then
    return "speedstar"
  end
  return "normal"
end

-- Replace size class within the same line.
-- target_class: "small"|"medium"|"big"|"behemoth"
local function map_name_by_line_and_class(line, target_class, is_alt)
  local alt = is_alt and true or false

  if line == "king" then
    return alt and DemolisherNames.MANIS_CRAZY_KING_ALT or DemolisherNames.MANIS_CRAZY_KING
  end

  if line == "gigantic" then
    if target_class == "small" then return alt and DemolisherNames.MANIS_GIGANTIC_SMALL_ALT or DemolisherNames.MANIS_GIGANTIC_SMALL end
    if target_class == "medium" then return alt and DemolisherNames.MANIS_GIGANTIC_MEDIUM_ALT or DemolisherNames.MANIS_GIGANTIC_MEDIUM end
    if target_class == "big" then return alt and DemolisherNames.MANIS_GIGANTIC_BIG_ALT or DemolisherNames.MANIS_GIGANTIC_BIG end
    return alt and DemolisherNames.MANIS_GIGANTIC_BEHEMOTH_ALT or DemolisherNames.MANIS_GIGANTIC_BEHEMOTH
  end

  if line == "speedstar" then
    if target_class == "small" then return alt and DemolisherNames.MANIS_SPEEDSTAR_SMALL_ALT or DemolisherNames.MANIS_SPEEDSTAR_SMALL end
    if target_class == "medium" then return alt and DemolisherNames.MANIS_SPEEDSTAR_MEDIUM_ALT or DemolisherNames.MANIS_SPEEDSTAR_MEDIUM end
    if target_class == "big" then return alt and DemolisherNames.MANIS_SPEEDSTAR_BIG_ALT or DemolisherNames.MANIS_SPEEDSTAR_BIG end
    return alt and DemolisherNames.MANIS_SPEEDSTAR_BEHEMOTH_ALT or DemolisherNames.MANIS_SPEEDSTAR_BEHEMOTH
  end

  -- normal line (default + manis + behemoth)
  if target_class == "small" then return alt and DemolisherNames.MANIS_SMALL_ALT or DemolisherNames.MANIS_SMALL end
  if target_class == "medium" then return alt and DemolisherNames.MANIS_MEDIUM_ALT or DemolisherNames.MANIS_MEDIUM end
  if target_class == "big" then return alt and DemolisherNames.MANIS_BIG_ALT or DemolisherNames.MANIS_BIG end
  return alt and DemolisherNames.MANIS_BEHEMOTH_ALT or DemolisherNames.MANIS_BEHEMOTH
end

local function is_alt_name(name)
  return name == DemolisherNames.MANIS_SMALL_ALT
      or name == DemolisherNames.MANIS_MEDIUM_ALT
      or name == DemolisherNames.MANIS_BIG_ALT
      or name == DemolisherNames.MANIS_BEHEMOTH_ALT
      or name == DemolisherNames.MANIS_SPEEDSTAR_SMALL_ALT
      or name == DemolisherNames.MANIS_SPEEDSTAR_MEDIUM_ALT
      or name == DemolisherNames.MANIS_SPEEDSTAR_BIG_ALT
      or name == DemolisherNames.MANIS_SPEEDSTAR_BEHEMOTH_ALT
      or name == DemolisherNames.MANIS_GIGANTIC_SMALL_ALT
      or name == DemolisherNames.MANIS_GIGANTIC_MEDIUM_ALT
      or name == DemolisherNames.MANIS_GIGANTIC_BIG_ALT
      or name == DemolisherNames.MANIS_GIGANTIC_BEHEMOTH_ALT
      or name == DemolisherNames.MANIS_CRAZY_KING_ALT
end

-- Decide target class based on size (keeps your legacy thresholds).
local function resolve_size_class_by_size(size)
  if size > 300000 then
    return "behemoth"
  end
  if size > 100000 then
    return "big"
  end
  if size > 30000 then
    return "medium"
  end
  return "small"
end

-- ------------------------------------------------------------
-- configs (centralized)
-- ------------------------------------------------------------
local CFG = {
  size = {
    pull_ratio = 0.10,
    mutation_amplitude = 1000, -- conservative; tune later
    force_drift = { enemy = 0.00, demolishers = 0.03, player = 0.06 },
    two_parent_bonus = 0.02,
    single_parent_drift = 0.00,
  },
  speed = {
    pull_ratio = 0.10,
    mutation_amplitude = 0.10,
    force_drift = { enemy = 0.00, demolishers = 0.02, player = 0.04 },
    two_parent_bonus = 0.01,
    single_parent_drift = 0.00,
  },
  quality = {
    pull_ratio = 0.10,
    mutation_amplitude = 0.20,
    force_drift = { enemy = 0.00, demolishers = 0.03, player = 0.06 },
    two_parent_bonus = 0.02,
    single_parent_drift = -0.02,
  },
  max_life = {
    pull_ratio = 0.10,
    mutation_amplitude = 2,
    force_drift = { enemy = 0.00, demolishers = 0.01, player = 0.02 },
    two_parent_bonus = 0.01,
    single_parent_drift = 0.00,
  },
  max_growth = {
    pull_ratio = 0.10,
    mutation_amplitude = 1,
    force_drift = { enemy = 0.00, demolishers = 0.01, player = 0.02 },
    two_parent_bonus = 0.01,
    single_parent_drift = 0.00,
  },
  max_satiety = {
    pull_ratio = 0.10,
    mutation_amplitude = 3,
    force_drift = { enemy = 0.00, demolishers = 0.01, player = 0.02 },
    two_parent_bonus = 0.01,
    single_parent_drift = 0.00,
  },
}

-- ------------------------------------------------------------
-- Public API
-- ------------------------------------------------------------

-- mutate_to_child(cp_a, parent_force_a, cp_b, opts)
-- opts:
--   trait_pool: array of trait ids for random addition (optional)
--   parent_force_b: override (optional)
function M.mutate_to_child(cp_a, parent_force_a, cp_b, opts)
  opts = opts or {}

  local parent_force_b = opts.parent_force_b or safe_force_name_from_cp(cp_b)
  local parent_count = (cp_b ~= nil) and 2 or 1
  local research_level = resolve_research_level()

  -- If partner force is unknown, fall back to same as parent A for stability.
  if parent_count >= 2 and parent_force_b == nil then
    parent_force_b = parent_force_a
  end

  local child_force = ForceTrans.choose_child_force(
    parent_force_a,
    parent_force_b,
    parent_count,
    research_level
  )

  -- base values
  local a_size = cp_a:get_size()
  local a_quality = cp_a:get_quality()
  local a_speed = cp_a:get_speed()
  local a_life = cp_a:get_max_life()
  local a_growth = cp_a:get_max_growth()
  local a_satiety = cp_a:get_max_satiety()
  local a_traits = cp_a:get_traits()
  local a_entity_name = cp_a.entity_name or DemolisherNames.SMALL

  local b_size, b_quality, b_speed, b_life, b_growth, b_satiety, b_traits
  if cp_b ~= nil then
    b_size = cp_b:get_size()
    b_quality = cp_b:get_quality()
    b_speed = cp_b:get_speed()
    b_life = cp_b:get_max_life()
    b_growth = cp_b:get_max_growth()
    b_satiety = cp_b:get_max_satiety()
    b_traits = cp_b:get_traits()
  end

  -- numeric parameters
  local child_size = TwoStage.inherit_two_stage(a_size, b_size, parent_count, child_force, CFG.size)
  local child_quality = TwoStage.inherit_two_stage(a_quality, b_quality, parent_count, child_force, CFG.quality)
  local child_speed = TwoStage.inherit_two_stage(a_speed, b_speed, parent_count, child_force, CFG.speed)

  local child_max_life = TwoStage.inherit_two_stage(a_life, b_life, parent_count, child_force, CFG.max_life)
  local child_max_growth = TwoStage.inherit_two_stage(a_growth, b_growth, parent_count, child_force, CFG.max_growth)
  local child_max_satiety = TwoStage.inherit_two_stage(a_satiety, b_satiety, parent_count, child_force, CFG.max_satiety)

  -- traits
  local child_traits = TraitsInherit.inherit_two_stage(
    a_traits,
    b_traits,
    parent_count,
    child_force,
    opts.trait_pool,
    nil
  )

  -- entity name evolution: keep line, change size class
  local line = resolve_line(a_entity_name)
  local alt = is_alt_name(a_entity_name)
  local target_class = resolve_size_class_by_size(child_size)
  local new_entity_name = map_name_by_line_and_class(line, target_class, alt)

  -- Construct child Customparam (entity=nil)
  local ctor = _G.Customparam and _G.Customparam.new
  if not ctor then
    error("Customparam.new is not available in _G.")
  end

  local child = ctor(
    nil,
    new_entity_name,
    nil,
    child_size,
    child_quality,
    child_speed,
    child_max_life,
    child_max_growth,
    child_max_satiety,
    child_traits,
    game.tick
  )

  return child, child_force
end

return M