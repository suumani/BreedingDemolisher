-- __BreedingDemolisher__/scripts/tests/packs/reproduction/PackEggHatchVir.lua
-- ------------------------------------------------------------
-- Responsibility:
--   PACK-EGG-HATCH-VIR:
--   Verify that an egg in respawn_queue hatches into a VIRTUAL demolisher
--   when the target chunk is NOT generated.
--
-- Primary oracle:
--   - respawn_queue entry is consumed (removed)
--   - VirtualEntityManager count increases on that surface
--
-- Notes:
--   - Command-based pack (not always-on automation).
--   - Does NOT assert log existence; world state is primary.
-- ------------------------------------------------------------

local Bootstrap = require("scripts.tests.infrastructure.TestBootstrap")
local Deferred  = require("scripts.tests.infrastructure.DeferredTestRunner")

local DemolisherEggHatchService = require("scripts.services.DemolisherEggHatchService")
local DemolisherNames = require("__Manis_definitions__/scripts/definition/DemolisherNames")
local VirtualMgr = require("__Manis_lib__/scripts/managers/VirtualEntityManager")

local function ensure_surface(name)
  local s = game.surfaces[name]
  if s then return s end
  return game.create_surface(name, {})
end

local function run_suite()
  local suite = {}

  suite["HATCH-VIR-001: egg hatches into virtual entry on ungenerated chunk"] = function(T)
    Bootstrap.start_pack("PACK-EGG-HATCH-VIR", {
      clear_virtual = true,
      clear_respawn_queue = true,
    })

    local surface = ensure_surface("vulcanus")

    -- Choose a far position likely to be ungenerated.
    -- (Do NOT request chunk generation here.)
    local pos = { x = 50000, y = 50000 }

    -- Precondition: chunk should be ungenerated for this test to be meaningful
    T.assert(surface.is_chunk_generated(pos) == false, "Precondition: target chunk must be ungenerated")

    local before_v = VirtualMgr.count(surface)

    -- Seed one egg (immediate hatch)
    storage.respawn_queue[#storage.respawn_queue + 1] = {
      surface = surface,
      entity_name = DemolisherNames.MANIS_SMALL,
      position = pos,
      evolution_factor = 0.10,
      force = "enemy",
      respawn_tick = game.tick
    }

    -- Act
    DemolisherEggHatchService.spawn_wild_demolishers(surface)

    -- Assert: queue consumed
    T.assert(#storage.respawn_queue == 0, "respawn_queue must be empty after hatching due egg")

    -- Assert: virtual count increased (at least +1)
    local after_v = VirtualMgr.count(surface)
    T.assert(after_v >= before_v + 1, ("Virtual count must increase (before=%d after=%d)"):format(before_v, after_v))

    Bootstrap.end_pack()
  end

  Deferred.run_suite("BD.PACK_EGG_HATCH_VIR", suite)
end

commands.add_command("bd-pack-egg-hatch-vir", "Run PACK-EGG-HATCH-VIR (egg -> virtual hatch)", run_suite)