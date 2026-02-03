-- scripts/tests/packs/reproduction/PackEggHatchPhy.lua
-- ------------------------------------------------------------
-- Responsibility:
--   PACK-EGG-HATCH-PHY:
--   Verify that an egg in respawn_queue hatches into a PHYSICAL demolisher
--   when the target chunk is generated.
--
-- Primary oracle:
--   - respawn_queue entry is consumed (removed)
--   - a physical Manis demolisher entity is created on the surface
--
-- Notes:
--   - Command-based pack (not always-on automation).
--   - Does NOT assert log existence; world state is primary.
-- ------------------------------------------------------------

local Bootstrap = require("scripts.tests.infrastructure.TestBootstrap")
local Deferred  = require("scripts.tests.infrastructure.DeferredTestRunner")

local DemolisherEggHatchService = require("scripts.services.DemolisherEggHatchService")
local DemolisherNames = require("__Manis_definitions__/scripts/definition/DemolisherNames")

local function ensure_surface(name)
  local s = game.surfaces[name]
  if s then return s end
  return game.create_surface(name, {})
end

local function ensure_chunks(surface, pos, radius)
  surface.request_to_generate_chunks(pos, radius or 2)
  surface.force_generate_chunk_requests()
end

local function count_entities_near(surface, name, pos, r)
  local area = { {pos.x - r, pos.y - r}, {pos.x + r, pos.y + r} }
  return surface.count_entities_filtered{
    name = name,
    area = area
  }
end

local function run_suite()
  local suite = {}

  suite["HATCH-PHY-001: egg hatches into physical entity on generated chunk"] = function(T)
    Bootstrap.start_pack("PACK-EGG-HATCH-PHY", {
      clear_virtual = true,
      clear_respawn_queue = true,
    })

    local surface = ensure_surface("vulcanus")
    local pos = { x = 260, y = 80 }

    -- Ensure chunk is generated so hatch becomes physical
    ensure_chunks(surface, pos, 2)

    -- Pre-count
    local before = count_entities_near(surface, DemolisherNames.MANIS_SMALL, pos, 50)

    -- Seed one egg (immediate hatch)
    storage.respawn_queue[#storage.respawn_queue + 1] = {
      surface = surface,
      entity_name = DemolisherNames.MANIS_SMALL, -- eggs are already Manis-series by spec
      position = pos,
      evolution_factor = 0.10,
      force = "enemy",
      respawn_tick = game.tick
    }

    -- Act
    DemolisherEggHatchService.spawn_wild_demolishers(surface)

    -- Assert: queue consumed
    T.assert(#storage.respawn_queue == 0, "respawn_queue must be empty after hatching due egg")

    -- Assert: physical entity increased
    local after = count_entities_near(surface, DemolisherNames.MANIS_SMALL, pos, 80)
    T.assert(after >= before + 1, ("Physical Manis demolisher must increase (before=%d after=%d)"):format(before, after))

    Bootstrap.end_pack()
  end

  Deferred.run_suite("BD.PACK_EGG_HATCH_PHY", suite)
end

commands.add_command("bd-pack-egg-hatch-phy", "Run PACK-EGG-HATCH-PHY (egg -> physical hatch)", run_suite)