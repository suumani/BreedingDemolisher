-- __BreedingDemolisher__/scripts/tests/packs/population_control/PackEggEnqueueFromVulcanusParent.lua
-- ------------------------------------------------------------
-- Responsibility:
--   PACK-EGG-ENQUEUE:
--   Verify that a default parent demolisher on Vulcanus enqueues conceptual eggs.
--
-- Primary oracle:
--   - storage.respawn_queue has >= 1 entries after rush
--   - each entry.entity_name is Manis-series (default parents never replicate as-is)
--   - respawn_tick is strictly before next 30-min boundary (P0 hatch-window policy)
--
-- Covered specs:
--   - (later) 03_PopulationControl.md: BD-POP-060..065 (cap gate already observed)
--   - 90_Observability.md: OBS-POP-001 (log is not asserted here; world state is primary)
--
-- Notes:
--   - Command-based pack (not always-on automation).
--   - Uses DeferredTestRunner + centralized pump for deferred assertions.
-- ------------------------------------------------------------

local Bootstrap = require("scripts.tests.infrastructure.TestBootstrap")
local Deferred  = require("scripts.tests.infrastructure.DeferredTestRunner")

local DemolisherRushService = require("scripts.services.DemolisherRushService")
local DemolisherNames = require("__Manis_definitions__/scripts/definition/DemolisherNames")

local TICK_30MIN = 108000

local function ensure_surface(name)
  local s = game.surfaces[name]
  if s then return s end
  return game.create_surface(name, {})
end

local function ensure_chunks(surface, pos, radius)
  surface.request_to_generate_chunks(pos, radius or 2)
  surface.force_generate_chunk_requests()
end

local function next_30min_boundary(tick)
  return (math.floor(tick / TICK_30MIN) + 1) * TICK_30MIN
end

local function is_manis_series(name)
  return type(name) == "string" and name:find("^manis%-") == 1
end

local function spawn_default_parent(surface, pos)
  ensure_chunks(surface, pos, 2)
  return surface.create_entity{
    name = DemolisherNames.SMALL, -- "small-demolisher"
    position = pos,
    force = "enemy",
    quality = "normal",
    direction = defines.direction.north
  }
end

local function run_suite()
  local suite = {}

  suite["EGG-001: default parent on vulcanus enqueues Manis eggs"] = function(T)
    Bootstrap.start_pack("PACK-EGG-ENQUEUE", {
      clear_virtual = true,
      clear_respawn_queue = true,
    })

    local surface = ensure_surface("vulcanus")

    local parent = spawn_default_parent(surface, { x = 200, y = 50 })
    T.assert(parent and parent.valid, "Precondition: parent demolisher must exist on vulcanus")

    local evo = 0.10
    local start_tick = game.tick
    DemolisherRushService.demolisher_rush(surface, evo)

    local q = storage.respawn_queue or {}
    T.assert(#q >= 1, "respawn_queue must have >= 1 eggs after rush")

    local boundary = next_30min_boundary(start_tick)

    for i, e in ipairs(q) do
      T.assert(e.surface and e.surface.valid, "egg["..i.."] must have valid surface")
      T.assert(type(e.entity_name) == "string" and e.entity_name ~= "", "egg["..i.."] must have entity_name")
      T.assert(is_manis_series(e.entity_name), "egg["..i.."] must be Manis-series: "..tostring(e.entity_name))
      T.assert(e.position and type(e.position.x)=="number" and type(e.position.y)=="number", "egg["..i.."] must have position")
      T.assert(type(e.evolution_factor) == "number", "egg["..i.."] must have evolution_factor")
      T.assert(type(e.respawn_tick) == "number", "egg["..i.."] must have respawn_tick")
      T.assert(e.evolution_factor == evo, "egg["..i.."] evo must match input evo")
      T.assert(e.respawn_tick < boundary, "egg["..i.."] respawn_tick must be before next 30-min boundary")
    end

    Bootstrap.end_pack()
  end

  Deferred.run_suite("BD.PACK_EGG_ENQUEUE", suite)
end

commands.add_command("bd-pack-egg-enqueue", "Run PACK-EGG-ENQUEUE (egg enqueue from vulcanus parent)", run_suite)