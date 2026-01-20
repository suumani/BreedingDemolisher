-- __BreedingDemolisher__/scripts/services/EggThrowHatchService.lua
-- ----------------------------
-- Responsibility:
--   Use-case: Throw an egg (cursor_stack) to hatch a demolisher.
--   - Resolve egg info (tags/quality/frozen)
--   - Resolve genetic payload (EggGenesStore; legacy optional)
--   - Spawn demolisher and register pet
--   - Consume egg and print result message
-- ----------------------------
local EggGenesStore = require("scripts.services.EggGenesStore")
local EggStackResolver = require("scripts.services.EggStackResolver")
local DemolisherSpawnService = require("scripts.services.DemolisherSpawnService")
local HatchMessageService = require("scripts.services.HatchMessageService")
local LegacyEggQueueService = require("scripts.services.LegacyEggQueueService") -- optional: keep if you still want legacy

local S = {}

function S.handle(event)
  local player = game.get_player(event.player_index)
  if not (player and player.character) then return end

  local cursor_stack = player.cursor_stack
  local egg = EggStackResolver.try_resolve(cursor_stack)
  if not egg then return end

  if egg.is_frozen then
    HatchMessageService.shattered()
    cursor_stack.clear()
    return
  end

  local customparam = nil
  if egg.genes_id ~= nil then
    customparam = EggGenesStore.get_customparam(egg.genes_id)
  end

  -- tags無し卵は「遺伝子なし孵化」が仕様だが、旧互換を残すならここでだけ見る
  local legacy_used = false
  if customparam == nil and egg.genes_id == nil then
    local legacy = LegacyEggQueueService.try_peek(egg.item_name, egg.quality_name)
    if legacy then
      customparam = legacy.customparam
      legacy_used = true
    end
  end

  local ok = DemolisherSpawnService.spawn_from_throw(player, egg, customparam)
  if not ok then return end

  HatchMessageService.hatched(egg.genes_id)

  cursor_stack.clear()

  if legacy_used then
    LegacyEggQueueService.try_pop(egg.item_name, egg.quality_name)
  end
end

return S