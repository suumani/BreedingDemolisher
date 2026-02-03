-- __BreedingDemolisher__/scripts/tests/packs/move/PackMoveSchedule.lua
-- ------------------------------------------------------------
-- Responsibility:
--   PACK-MOVE-SCHEDULE (BD / Vulcanus only):
--   - BD-MOVE-001: plan creation + step advance
--   - BD-MOVE-003A..003D: single-step distance constraint per transition type:
--       003A Phys->Phy
--       003B Phys->Vir
--       003C Vir ->Phy
--       003D Vir ->Vir
--
-- Notes:
--   - Fatal demolishers are OUT OF SCOPE for BreedingDemolisher move control.
--   - Rocket history code is shared (Manis_lib), but storage space is BD-owned by design.
--   - PlanStore is vulcanus-only store: get/set/clear (no surface_name).
--   - Command-based pack; relies on DeferredTestRunner + centralized pump.
-- ------------------------------------------------------------

local Bootstrap = require("scripts.tests.infrastructure.TestBootstrap")
local Deferred  = require("scripts.tests.infrastructure.DeferredTestRunner")
local Config    = require("scripts.tests.infrastructure.TestConfig")

local VirtualMgr = require("__Manis_lib__/scripts/managers/VirtualEntityManager")
local DemolisherNames = require("__Manis_definitions__/scripts/definition/DemolisherNames")

-- BD move orchestrator/runner (already used by on_nth_tick in BD)
local Orchestrator = require("scripts.services.VulcanusDemolisherMoveOrchestrator")
local Runner       = require("scripts.services.VulcanusDemolisherMovePlanRunner")

-- Rocket history store (code shared)
local RocketHistory = require("__Manis_lib__/scripts/domain/demolisher/move/RocketLaunchHistoryStore")

-- Vulcanus-only plan store
local PlanStore = require("scripts.services.VulcanusDemolisherMovePlanStore")

local SURFACE_NAME = "vulcanus"

-- ----------------------------
-- helpers
-- ----------------------------
local function ensure_surface(name)
  local s = game.surfaces[name]
  if s then return s end
  return game.create_surface(name, {})
end

local function ensure_chunks_generated(surface, center_pos, radius)
  surface.request_to_generate_chunks(center_pos, radius or 2)
  surface.force_generate_chunk_requests()
end

local function destroy_all_by_name(surface, name)
  local ents = surface.find_entities_filtered{ force = "enemy", name = name }
  for _, e in pairs(ents) do
    if e and e.valid then e.destroy() end
  end
end

local function destroy_all_by_names(surface, names)
  if not names then return end
  local ents = surface.find_entities_filtered{ force = "enemy", name = names }
  for _, e in pairs(ents) do
    if e and e.valid then e.destroy() end
  end
end

local function find_one(surface, name)
  local ents = surface.find_entities_filtered{ force = "enemy", name = name }
  for _, e in pairs(ents) do
    if e and e.valid then return e end
  end
  return nil
end

local function count_physical(surface, name)
  local ents = surface.find_entities_filtered{ force="enemy", name=name }
  local c = 0
  for _, e in pairs(ents) do
    if e and e.valid then c = c + 1 end
  end
  return c
end

local function count_virtual_by_name(surface, name)
  local list = VirtualMgr.get_all_as_list(surface)
  local c = 0
  for _, entry in pairs(list) do
    if entry and entry.data and entry.data.name == name then
      c = c + 1
    end
  end
  return c
end

local function euclid_dist(a, b)
  local dx = a.x - b.x
  local dy = a.y - b.y
  return math.sqrt(dx * dx + dy * dy)
end

-- Common maxd calculation (As-Is in DemolisherMover)
-- maxd = floor(30 * evo * move_rate) + 30
local function calc_maxd(evo, move_rate)
  return math.floor(30 * evo * move_rate) + 30
end

local function cleanup_surface_for_move_tests(surface)
  -- Clear existing plan
  PlanStore.clear()

  -- Clear move targets (Breeding scope: non-fatal only; Manis series as primary)
  destroy_all_by_names(surface, {
    DemolisherNames.MANIS_SMALL,
    DemolisherNames.MANIS_MEDIUM,
    DemolisherNames.MANIS_BIG,

    DemolisherNames.MANIS_SMALL_ALT,
    DemolisherNames.MANIS_MEDIUM_ALT,
    DemolisherNames.MANIS_BIG_ALT,

    DemolisherNames.MANIS_BEHEMOTH,
    DemolisherNames.MANIS_BEHEMOTH_ALT,

    DemolisherNames.MANIS_SPEEDSTAR_SMALL,
    DemolisherNames.MANIS_SPEEDSTAR_MEDIUM,
    DemolisherNames.MANIS_SPEEDSTAR_BIG,
    DemolisherNames.MANIS_SPEEDSTAR_BEHEMOTH,

    DemolisherNames.MANIS_SPEEDSTAR_SMALL_ALT,
    DemolisherNames.MANIS_SPEEDSTAR_MEDIUM_ALT,
    DemolisherNames.MANIS_SPEEDSTAR_BIG_ALT,
    DemolisherNames.MANIS_SPEEDSTAR_BEHEMOTH_ALT,
  })
end

local function add_rockets(surface_name, list)
  for _, p in ipairs(list) do
    RocketHistory.add(surface_name, p, game.tick)
  end
end

local function make_virtual_data(name)
  return { name = name, force = "enemy", quality = "normal" }
end

local function far_chunk_base(chunk_x, chunk_y)
  -- chunk -> tile origin
  return { x = chunk_x * 32, y = chunk_y * 32 }
end

local function near_chunk_edge(base)
  -- inside generated chunk, near +x boundary (x=31)
  return { x = base.x + 31, y = base.y }
end

local function ensure_only_start_chunk_generated(surface, pos)
  -- radius=0 => only the chunk containing pos is generated
  surface.request_to_generate_chunks(pos, 0)
  surface.force_generate_chunk_requests()
end

local function rocket_positions_far_from(pos)
  -- Far to +x so movement direction is toward ungenerated area.
  -- Do NOT generate chunks around these.
  return {
    { x = pos.x + 10000, y = pos.y },
    { x = pos.x + 10000, y = pos.y + 50 },
    { x = pos.x + 10000, y = pos.y - 50 },
    { x = pos.x + 10100, y = pos.y }, -- 4th just to make move_rate cap=3
  }
end

-- ----------------------------
-- suite
-- ----------------------------
local function run_suite()
  local suite = {}

  suite["BD-MOVE-001: plan is created and step advances when prerequisites are satisfied"] = function(T)
    Bootstrap.start_pack("PACK-MOVE-SCHEDULE", {
      clear_virtual = true,
      clear_respawn_queue = true,
    })

    Config.set_move_min_planned_total("PACK-MOVE-SCHEDULE", 1)
    Config.set_move_evo_override("PACK-MOVE-SCHEDULE", 1.0)

    local surface = ensure_surface(SURFACE_NAME)
    cleanup_surface_for_move_tests(surface)

    -- Precondition: rockets + one move-target exist
    add_rockets(SURFACE_NAME, { {x=0,y=0} })

    ensure_chunks_generated(surface, {x=40,y=0}, 12)
    surface.create_entity{ name = DemolisherNames.MANIS_SMALL, position = {x=40,y=0}, force="enemy", quality="normal" }

    -- Act: create plan
    Orchestrator.run_once()

    local plan = PlanStore.get()
    T.assert(plan ~= nil, "Plan must be created on vulcanus when rocket history and targets exist.")

    local before_step = plan.step
    local before_moved = plan.moved_so_far

    -- Act: consume one step
    Runner.run_one_step_if_present()

    local plan2 = PlanStore.get()
    if plan2 then
      T.assert(plan2.step == before_step + 1, "Plan step must advance by 1 after runner step.")
      T.assert(plan2.moved_so_far >= before_moved, "moved_so_far must not decrease.")
    else
      T.assert(true, "Plan finished and cleared after one step (allowed).")
    end

    Bootstrap.end_pack()
  end

  -- ------------------------------------------------------------
  -- BD-MOVE-003A: Phys -> Phy
  -- ------------------------------------------------------------
  suite["BD-MOVE-003A: distance constraint (Phys->Phy)"] = function(T)
    Bootstrap.start_pack("PACK-MOVE-SCHEDULE", {
      clear_virtual = true,
      clear_respawn_queue = true,
    })

    Config.set_move_min_planned_total("PACK-MOVE-SCHEDULE", 1)
    Config.set_move_evo_override("PACK-MOVE-SCHEDULE", 1.0)

    local surface = ensure_surface(SURFACE_NAME)
    cleanup_surface_for_move_tests(surface)

    local rockets = { {x=0,y=0}, {x=10,y=0}, {x=0,y=10} }
    for _, p in ipairs(rockets) do ensure_chunks_generated(surface, p, 12) end
    add_rockets(SURFACE_NAME, rockets)

    local name = DemolisherNames.MANIS_SMALL
    local start_pos = { x = 40, y = 0 }
    ensure_chunks_generated(surface, start_pos, 12)
    surface.create_entity{ name = name, position = start_pos, force="enemy", quality="normal" }

    Orchestrator.run_once()
    T.assert(PlanStore.get() ~= nil, "Plan must exist for Phys->Phy test.")

    local evo = 1.0
    local move_rate = 3
    local maxd = calc_maxd(evo, move_rate)
    local epsilon = 0.51

    local moved_observed = false

    for _ = 1, 40 do
      if not PlanStore.get() then break end

      local before = find_one(surface, name)
      T.assert(before ~= nil, "Physical entity must exist before move (Phys->Phy).")
      local bp = { x = before.position.x, y = before.position.y }

      Runner.run_one_step_if_present()

      local after = find_one(surface, name)
      if not after then
        local vcount = count_virtual_by_name(surface, name)
        T.assert(vcount == 0, "Phys->Phy precondition violated: entity became virtual.")
        T.assert(false, "Phys->Phy: physical entity disappeared unexpectedly.")
      end

      local ap = { x = after.position.x, y = after.position.y }
      local dist = euclid_dist(bp, ap)

      if dist > 0.1 then
        moved_observed = true
        T.assert(dist <= (maxd + epsilon),
          string.format("Phys->Phy delta must be <= maxd. dist=%.3f maxd=%d", dist, maxd))
        break
      end
    end

    T.assert(moved_observed, "A measurable Phys->Phy move must be observed within plan lifetime.")
    Bootstrap.end_pack()
  end

  -- ------------------------------------------------------------
  -- BD-MOVE-003B: Phys -> Vir
  -- ------------------------------------------------------------
suite["BD-MOVE-003B: distance constraint (Phys->Vir)"] = function(T)
  Bootstrap.start_pack("PACK-MOVE-SCHEDULE", {
    clear_virtual = true,
    clear_respawn_queue = true,
  })

  local surface = ensure_surface("vulcanus")
  cleanup_surface_for_move_tests(surface)

  -- Use a far unique region to avoid interference from other scenarios on the same surface.
  local base = far_chunk_base(20000, 0)
  local start_pos = near_chunk_edge(base)

  -- Generate ONLY the starting chunk.
  ensure_only_start_chunk_generated(surface, start_pos)

  -- Rockets far to +x; do NOT generate chunks around them.
  add_rockets("vulcanus", rocket_positions_far_from(start_pos))

  local name = DemolisherNames.MANIS_SMALL
  surface.create_entity{ name = name, position = start_pos, force="enemy", quality="normal" }

  local evo = 1.0
  local move_rate = 3
  local maxd = calc_maxd(evo, move_rate)
  local epsilon = 0.51

  local transitioned = false
  local delta_checked = false

  local K = 6
  for _ = 1, K do
    if transitioned and delta_checked then break end

    PlanStore.clear()
    Orchestrator.run_once()

    local plan = PlanStore.get()
    if plan then
      for _ = 1, 25 do
        if transitioned and delta_checked then break end
        if not PlanStore.get() then break end

        local before = find_one(surface, name)
        if before then
          local bp = { x = before.position.x, y = before.position.y }

          Runner.run_one_step_if_present()

          local after = find_one(surface, name)
          if not after then
            -- became virtual
            local list = VirtualMgr.get_all_as_list(surface)
            local found = nil
            for _, entry in pairs(list) do
              if entry and entry.data and entry.data.name == name then
                found = entry
                break
              end
            end

            if found then
              transitioned = true
              local vp = { x = found.position.x, y = found.position.y }

              local dist = euclid_dist(bp, vp)
              T.assert(dist <= (maxd + epsilon),
                string.format("Phys->Vir delta must be <= maxd. dist=%.3f maxd=%d", dist, maxd))

              delta_checked = true
              break
            end
          end
        else
          -- already virtual; keep stepping within this plan
          Runner.run_one_step_if_present()
        end
      end
    end
  end

  T.assert(transitioned and delta_checked, "Phys->Vir transition and delta check must occur within retries (K plans).")
  Bootstrap.end_pack()
end

  -- ------------------------------------------------------------
  -- BD-MOVE-003C: Vir -> Phy
  -- ------------------------------------------------------------
  suite["BD-MOVE-003C: distance constraint (Vir->Phy)"] = function(T)
    Bootstrap.start_pack("PACK-MOVE-SCHEDULE", {
      clear_virtual = true,
      clear_respawn_queue = true,
    })

    Config.set_move_min_planned_total("PACK-MOVE-SCHEDULE", 1)
    Config.set_move_evo_override("PACK-MOVE-SCHEDULE", 1.0)

    local surface = ensure_surface(SURFACE_NAME)
    cleanup_surface_for_move_tests(surface)

    local name = DemolisherNames.MANIS_SMALL

    local rockets = { {x=0,y=0}, {x=10,y=0}, {x=0,y=10} }
    for _, p in ipairs(rockets) do ensure_chunks_generated(surface, p, 12) end
    add_rockets(SURFACE_NAME, rockets)

    local vpos = { x = 40, y = 0 }
    ensure_chunks_generated(surface, vpos, 12)

    local vid = VirtualMgr.enqueue(surface, nil, vpos, make_virtual_data(name))
    T.assert(vid ~= nil, "Virtual id must be returned for Vir->Phy test.")

    local evo = 1.0
    local move_rate = 3
    local maxd = calc_maxd(evo, move_rate)
    local epsilon = 0.51

    local transitioned = false
    local delta_checked = false

    local K = 5
    for _ = 1, K do
      if transitioned and delta_checked then break end

      PlanStore.clear()
      Orchestrator.run_once()

      if PlanStore.get() then
        for _ = 1, 25 do
          if transitioned and delta_checked then break end
          if not PlanStore.get() then break end

          local before_entry = VirtualMgr.get(surface, vid)
          if before_entry then
            local bp = { x = before_entry.position.x, y = before_entry.position.y }

            Runner.run_one_step_if_present()

            local after_entry = VirtualMgr.get(surface, vid)
            local after_phys = find_one(surface, name)

            if (not after_entry) and after_phys then
              transitioned = true
              local ap = { x = after_phys.position.x, y = after_phys.position.y }
              local dist = euclid_dist(bp, ap)

              T.assert(dist <= (maxd + epsilon),
                string.format("Vir->Phy delta must be <= maxd. dist=%.3f maxd=%d", dist, maxd))

              delta_checked = true
              break
            end
          else
            Runner.run_one_step_if_present()
          end
        end
      end
    end

    T.assert(transitioned and delta_checked, "Vir->Phy transition and delta check must occur within retries (K plans).")
    Bootstrap.end_pack()
  end

  -- ------------------------------------------------------------
  -- BD-MOVE-003D: Vir -> Vir
  -- ------------------------------------------------------------
suite["BD-MOVE-003D: distance constraint (Vir->Vir)"] = function(T)
  Bootstrap.start_pack("PACK-MOVE-SCHEDULE", {
    clear_virtual = true,
    clear_respawn_queue = true,
  })

  local surface = ensure_surface("vulcanus")
  cleanup_surface_for_move_tests(surface)

  -- Use a different far region than 003B to avoid interference.
  local base = far_chunk_base(21000, 0)
  local vpos = near_chunk_edge(base)

  -- Generate ONLY the starting chunk.
  ensure_only_start_chunk_generated(surface, vpos)

  -- Rockets far to +x; do NOT generate chunks around them.
  add_rockets("vulcanus", rocket_positions_far_from(vpos))

  local name = DemolisherNames.MANIS_SMALL
  local vid = VirtualMgr.enqueue(surface, nil, vpos, make_virtual_data(name))
  T.assert(vid ~= nil, "Virtual id must be returned for Vir->Vir test.")

  local evo = 1.0
  local move_rate = 3
  local maxd = calc_maxd(evo, move_rate)
  local epsilon = 0.51

  local moved_observed = false
  local delta_checked = false

  local K = 6
  for _ = 1, K do
    if moved_observed and delta_checked then break end

    PlanStore.clear()
    Orchestrator.run_once()

    local plan = PlanStore.get()
    if plan then
      for _ = 1, 25 do
        if moved_observed and delta_checked then break end
        if not PlanStore.get() then break end

        local before_entry = VirtualMgr.get(surface, vid)
        T.assert(before_entry ~= nil, "Vir->Vir: virtual entry must exist before move.")

        local bp = { x = before_entry.position.x, y = before_entry.position.y }

        Runner.run_one_step_if_present()

        local after_entry = VirtualMgr.get(surface, vid)
        T.assert(after_entry ~= nil, "Vir->Vir: virtual entry disappeared unexpectedly (materialized/removed).")

        local ap = { x = after_entry.position.x, y = after_entry.position.y }
        local dist = euclid_dist(bp, ap)

        if dist > 0.1 then
          moved_observed = true
          T.assert(count_physical(surface, name) == 0, "Vir->Vir must not materialize to physical.")
          T.assert(dist <= (maxd + epsilon),
            string.format("Vir->Vir delta must be <= maxd. dist=%.3f maxd=%d", dist, maxd))
          delta_checked = true
          break
        end
      end
    end
  end

  T.assert(moved_observed and delta_checked, "A measurable Vir->Vir move must be observed within retries (K plans).")
  Bootstrap.end_pack()
end

  Deferred.run_suite("BD.PACK_MOVE_SCHEDULE", suite)
end

commands.add_command("bd-pack-move-schedule", "Run PACK-MOVE-SCHEDULE (BreedingDemolisher / Vulcanus)", run_suite)