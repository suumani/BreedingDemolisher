-- __BreedingDemolisher__/scripts/services/EggThrowHatchService.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Use-case: Throw an egg (cursor_stack) to hatch a demolisher.
--
-- Scope:
--   - Resolve egg info (tags/quality/frozen)
--   - Resolve genetic payload (EggGenesStore)
--   - Spawn pet demolisher and register pet
--   - Consume egg and print result message
--
-- Notes:
--   - tags 無し卵は「遺伝子なし孵化」として扱う
--   - legacy queue fallback は持たない
-- ------------------------------------------------------------
local EggGenesStore = require("scripts.services.EggGenesStore")
local EggStackResolver = require("scripts.services.EggStackResolver")
local PetHatchSpawnService = require("scripts.domain.hatch.PetHatchSpawnService")
local HatchMessageService = require("scripts.services.HatchMessageService")

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

  local ok = PetHatchSpawnService.spawn_from_throw(player, egg, customparam)
  if not ok then
    return
  end

  HatchMessageService.hatched(egg.genes_id)
  cursor_stack.clear()
end

return EggThrowHatchService