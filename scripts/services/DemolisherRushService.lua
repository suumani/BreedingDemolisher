-- __BreedingDemolisher__/scripts/services/DemolisherRushService.lua
-- ----------------------------
-- Responsibility:
--   Execute one "demolisher rush" on a surface:
--   - Evaluate cap (counted population vs cap)
--   - Select parent candidates and enqueue conceptual eggs (respawn_queue)
--   - Eggs hatch later by 1-min hatch service (DemolisherEggHatchService)
--
-- Notes:
--   - counted population excludes default small/medium/big (quality nil/normal) by policy
--   - cap counts: physical(all mods) + virtual(only this mod via Manis_lib VirtualMgr)
--   - respawn_tick must be within the current 30-min window because respawn_queue is reset every 30 minutes
-- ----------------------------
local DemolisherRushService = {}

local DRand = require("scripts.util.DeterministicRandom")
local DemolisherQuery = require("__Manis_lib__/scripts/queries/DemolisherQuery")
local VirtualMgr      = require("__Manis_lib__/scripts/managers/VirtualEntityManager")
local SpawnPositionService = require("scripts.services.SpawnPositionService")
local util  = require("scripts.common.util")
local EggMutationPolicy = require("scripts.policies.EggMutationPolicy")
local Logger = require("scripts.services.Logger")
local DemolisherNames = require("__Manis_definitions__/scripts/definition/DemolisherNames")

local function normalize_egg_entity_name_for_surface(surface, entity_name)
  if not surface or not surface.valid then
    return entity_name
  end

  -- Vulcanus: default eggs must be Manis-series (spec decision)
  if surface.name == "vulcanus" then
    if entity_name == DemolisherNames.SMALL then return DemolisherNames.MANIS_SMALL end
    if entity_name == DemolisherNames.MEDIUM then return DemolisherNames.MANIS_MEDIUM end
    if entity_name == DemolisherNames.BIG then return DemolisherNames.MANIS_BIG end
  end

  return entity_name
end

-- Cap calculator (pure)
local CapCalculator = require("__Manis_lib__/scripts/logic/DemolisherCapCalculator")

-- ---------------------------------------------------------------------
-- Tunables & Policy
-- ---------------------------------------------------------------------
local MAX_EGGS_PER_RUSH = 100
local MIN_PARENTS = 3
local P_MIN = 0.15
local MIN_EGGS_TWO_RATE = 0.45

-- Cap research policy
local CAP_POLICY = {
  TECH_NAME = "manis-demolisher-cap-down",
  REDUCTION_STEP = 0.05, -- 5% per level
  CAP_FLOOR = 50         -- absolute minimum
}

-- respawn_queue reset policy: every 30 minutes
local TICK_30MIN = 108000

-- ---------------------------------------------------------------------
-- cap: evolution_factor -> {cap, floor_applied}
-- ---------------------------------------------------------------------
local function calc_cap_meta(evo)
  local base_cap = 200

  if evo <= 0.05 then base_cap = 40
  elseif evo <= 0.15 then base_cap = 55
  elseif evo <= 0.25 then base_cap = 70
  elseif evo <= 0.35 then base_cap = 85
  elseif evo <= 0.45 then base_cap = 100
  elseif evo <= 0.55 then base_cap = 115
  elseif evo <= 0.65 then base_cap = 130
  elseif evo <= 0.75 then base_cap = 145
  elseif evo <= 0.85 then base_cap = 160
  elseif evo <= 0.95 then base_cap = 175
  elseif evo <= 0.98 then base_cap = 190
  end

  local force = game.forces.player
  local level = 0
  if force and force.technologies then
    local tech = force.technologies[CAP_POLICY.TECH_NAME]
    if tech then
      level = math.max(0, tech.level)
    end
  end

  return CapCalculator.calculate_with_meta(base_cap, level, CAP_POLICY.REDUCTION_STEP, CAP_POLICY.CAP_FLOOR)
end

-- ---------------------------------------------------------------------
-- Virtual count filter (true => counted)
-- ---------------------------------------------------------------------
local function virtual_count_filter(entry)
  local data = entry.data
  if not data then return false end

  -- Exclude default small/medium/big normal (delegate to DemolisherQuery)
  if DemolisherQuery.is_default_small_medium_big_normal_virtual(data.name, data.quality) then
    return false
  end
  return true
end

-- ---------------------------------------------------------------------
-- Counted population (physical + this mod's virtual)
-- ---------------------------------------------------------------------
local function count_counted_population(surface)
  local cnt = 0

  -- 1) Physical
  local all = DemolisherQuery.find_demolishers(surface)
  for _, e in pairs(all) do
    if e and e.valid then
      if not DemolisherQuery.is_default_small_medium_big_normal(e) then
        cnt = cnt + 1
      end
    end
  end

  -- 2) Virtual (this mod only; via shared store)
  cnt = cnt + VirtualMgr.count(surface, virtual_count_filter)

  return cnt
end

-- ---------------------------------------------------------------------
-- Minimum eggs guarantee since first kill tick
-- ---------------------------------------------------------------------
local function calc_min_eggs_since_first_kill()
  local t0 = storage.bd_demolisher_first_kill_tick
  if not t0 then
    return 0
  end

  local dt = game.tick - t0
  if dt < 0 then
    return 0
  end

  local hours = dt / (60 * 60 * 60)

  if hours < 2 then
    return 1
  elseif hours < 4 then
    return 2
  elseif hours < 8 then
    return 3
  elseif hours < 16 then
    return 4
  elseif hours < 32 then
    return 5
  elseif hours < 128 then
    return 6
  else
    return 2
  end
end

-- Candidate count: 5..(about 20)
local function calc_candidate_count(evo)
  local k = 5 + (evo * 10)
  if evo >= 0.99 then
    k = k + 5
  end
  return math.ceil(k)
end

-- Max eggs per parent: ceil(1 + evo*4)
local function calc_max_eggs_per_parent(evo)
  return math.ceil(1 + (evo * 4))
end

-- Choose k candidates by partial shuffle
local function choose_candidates(all_demolishers, k)
  local n = #all_demolishers
  if k > n then k = n end
  if k <= 0 then return {} end

  local tmp = {}
  for i = 1, n do tmp[i] = all_demolishers[i] end

  local candidates = {}
  for i = 1, k do
    local j = DRand.random(i, n)
    tmp[i], tmp[j] = tmp[j], tmp[i]
    candidates[i] = tmp[i]
  end
  return candidates
end

-- Parent min eggs roll: 1 or 2
local function roll_min_eggs()
  return (DRand.random() < MIN_EGGS_TWO_RATE) and 2 or 1
end

-- Pick spawn parents with minimum guarantee
local function pick_spawn_parents(candidates, spawn_prob)
  local spawn_parents = {}
  for _, parent in pairs(candidates) do
    if DRand.random() < spawn_prob then
      spawn_parents[#spawn_parents + 1] = parent
    end
  end

  while #spawn_parents < math.min(MIN_PARENTS, #candidates) do
    spawn_parents[#spawn_parents + 1] = candidates[DRand.random(1, #candidates)]
  end

  return spawn_parents
end

-- Nearest silo to (0,0)
local function find_nearest_silo_pos(surface)
  local nearest = { x = 0, y = 0 }
  local silos = surface.find_entities_filtered{ type = "rocket-silo" }
  if not silos or #silos == 0 then
    return nearest
  end

  local min_length
  for _, silo in pairs(silos) do
    local p = silo.position
    local len = p.x ^ 2 + p.y ^ 2
    if min_length == nil or len < min_length then
      min_length = len
      nearest = p
    end
  end
  return nearest
end

-- ---------------------------------------------------------------------
-- Hatch timing policy (P0):
--   - min: immediate (0)
--   - max: strictly before next 30-min tick (because respawn_queue is reset every 30 min)
-- ---------------------------------------------------------------------
local function calc_hatch_delay_ticks(now_tick)
  local next_boundary = (math.floor(now_tick / TICK_30MIN) + 1) * TICK_30MIN
  local max_delay = next_boundary - now_tick - 1
  if max_delay < 0 then
    max_delay = 0
  end
  return DRand.random(0, max_delay)
end

-- Enqueue one egg if spawn position exists.
-- Returns true if enqueued.
local function try_enqueue_egg(surface, evolution_factor, parent, nearest_silo_pos, queue)
  local spawn_position = SpawnPositionService.getSpawnPosition(
    surface,
    evolution_factor,
    parent.position,
    nearest_silo_pos
  )
  if spawn_position == nil then
    return false
  end

  local delay = calc_hatch_delay_ticks(game.tick)

  local raw_name = EggMutationPolicy.pick_egg_entity_name(parent.name, evolution_factor)
  local egg_name = normalize_egg_entity_name_for_surface(surface, raw_name)

  queue[#queue + 1] = {
    surface = parent.surface,
    entity_name = EggMutationPolicy.pick_egg_entity_name(egg_name, evolution_factor),
    position = spawn_position,
    evolution_factor = evolution_factor,
    force = parent.force,
    respawn_tick = game.tick + delay
  }

  return true
end

-- ---------------------------------------------------------------------
-- Entry
-- ---------------------------------------------------------------------
function DemolisherRushService.demolisher_rush(surface, evolution_factor)
  storage.respawn_queue = storage.respawn_queue or {}

  -- cap (evo + research)
  local capm = calc_cap_meta(evolution_factor)
  local cap = capm.cap
  local cap_floor_applied = capm.floor_applied == true

  -- counted population
  local counted = count_counted_population(surface)

  -- OBS-POP-001 (required)
  local outcome, reason
  if counted >= cap then
    outcome = "SKIP"
    reason = "CAP_REACHED"
  else
    outcome = "OK"
    reason = cap_floor_applied and "FLOOR_APPLIED" or "BELOW_CAP"
  end

  Logger.info({
    "[BreedingDemolisher][POP][CapGate][" .. outcome .. "]",
    " reason=", reason,
    " evo=", evolution_factor,
    " counted_population=", counted,
    " cap=", cap,
    " cap_floor_applied=", tostring(cap_floor_applied),
  })

  -- cap reached -> suppress egg creation
  if counted >= cap then
    util.print("[vulcanus] demolishers abound... (Pop:" .. counted .. " / Cap:" .. cap .. ")")
    return
  end

  -- max increase per rush
  local remaining_capacity = cap - counted
  local egg_budget = math.min(MAX_EGGS_PER_RUSH, remaining_capacity)
  if egg_budget <= 0 then
    util.print("[vulcanus] demolishers abound... (Pop:" .. counted .. " / Cap:" .. cap .. ")")
    return
  end

  local nearest_silo_pos = find_nearest_silo_pos(surface)

  -- parent pool (physical only)
  local parent_pool = DemolisherQuery.find_breeding_parent_demolishers(surface)
  if not parent_pool or #parent_pool == 0 then
    return
  end

  -- candidates
  local k = calc_candidate_count(evolution_factor)
  local candidates = choose_candidates(parent_pool, k)
  if #candidates == 0 then
    return
  end

  -- probability curve
  local spawn_prob = math.max(P_MIN, (evolution_factor ^ 0.7) / 2)
  local max_eggs = calc_max_eggs_per_parent(evolution_factor)

  -- selected parents (min guarantee)
  local spawn_parents = pick_spawn_parents(candidates, spawn_prob)

  local enqueued_eggs = 0

  -- normal spawn
  for _, parent in pairs(spawn_parents) do
    if enqueued_eggs >= egg_budget then break end

    local rolled = DRand.random(1, max_eggs)
    local egg_n = math.max(roll_min_eggs(), rolled)

    for _ = 1, egg_n do
      if enqueued_eggs >= egg_budget then break end

      if try_enqueue_egg(surface, evolution_factor, parent, nearest_silo_pos, storage.respawn_queue) then
        enqueued_eggs = enqueued_eggs + 1
      end
    end
  end

  -- minimum guarantee
  local min_eggs = calc_min_eggs_since_first_kill()
  if min_eggs > egg_budget then
    min_eggs = egg_budget
  end

  if enqueued_eggs < min_eggs then
    local need = min_eggs - enqueued_eggs

    for _ = 1, need do
      if enqueued_eggs >= egg_budget then break end

      local parent = candidates[DRand.random(1, #candidates)]
      if try_enqueue_egg(surface, evolution_factor, parent, nearest_silo_pos, storage.respawn_queue) then
        enqueued_eggs = enqueued_eggs + 1
      end
    end
  end

  if enqueued_eggs ~= 0 then
    util.print("[vulcanus] demolishers are multiplying... more than " .. enqueued_eggs .. " eggs are missing...")
  else
    util.print("[vulcanus] demolishers are multiplying... but nothing happened...")
  end
end

return DemolisherRushService