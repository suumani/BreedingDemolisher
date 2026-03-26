-- __BreedingDemolisher__/scripts/application/hatch/EggThrowHatchService.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Use-case: Throw an egg (cursor_stack) to hatch a demolisher.
--
-- Scope:
--   - Resolve egg info (tags/quality/frozen)
--   - Resolve genetic payload (EggGenesStore)
--   - Spawn pet demolisher and register pet
--   - Enqueue pet chart job after successful hatch
--   - Consume egg and print result message
--
-- Notes:
--   - tags 無し卵は「遺伝子なし孵化」として扱う
--   - legacy queue fallback は持たない
-- ------------------------------------------------------------
local EggGenesStore = require("scripts.infrastructure.runtime.EggGenesStore")
local EggStackResolver = require("scripts.domain.hatch.EggStackResolver")
local PetHatchSpawnService = require("scripts.domain.hatch.PetHatchSpawnService")
local PetChartJobService = require("scripts.core.pet_chart.PetChartJobService")
local HatchMessageService = require("scripts.boundary.hatch.HatchMessageService")

local EggThrowHatchService = {}

function EggThrowHatchService.handle(event)
  local player = game.get_player(event.player_index)
  if not (player and player.character) then
    return
  end

  local cursor_stack = player.cursor_stack
  local egg = EggStackResolver.try_resolve(cursor_stack)
  if not egg then
    return
  end

  if egg.is_frozen then
    HatchMessageService.shattered()
    cursor_stack.clear()
    return
  end

  local customparam = nil
  if egg.genes_id ~= nil then
    customparam = EggGenesStore.get_customparam(egg.genes_id)
  end

  local entity = PetHatchSpawnService.spawn_from_throw(player, egg, customparam)
  if not entity then
    return
  end

  PetChartJobService.enqueue(entity.surface, entity.position, player.force.name, 640)

  HatchMessageService.hatched(egg.genes_id)
  cursor_stack.clear()
end

return EggThrowHatchService