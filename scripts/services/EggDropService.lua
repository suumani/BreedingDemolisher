-- __BreedingDemolisher__/scripts/services/EggDropService.lua
-- ----------------------------
-- Responsibility:
--   Drop an egg item onto the ground and attach genes_id via item-with-tags.
--   - If customparam is provided, register it in EggGenesStore and write bd_genes_id tag.
--   - If customparam is nil, drop a genetics-less egg (no tags).
-- Notes:
--   - Does not delete genes (GC is out of scope).
-- ----------------------------
local EggGenesStore = require("scripts.services.EggGenesStore")

local M = {}

function M.drop_egg(surface, position, item_name, item_quality, customparam)
  -- genes_id is issued only when genetics exists
  local genes_id = nil
  if customparam ~= nil then
    genes_id = EggGenesStore.register(customparam)
  end

  local dropped = surface.spill_item_stack{
    position = position,
    stack = { name = item_name, count = 1, quality = item_quality },
  }

  if genes_id ~= nil and dropped and #dropped > 0 then
    for _, item_ent in ipairs(dropped) do
      if item_ent and item_ent.valid and item_ent.stack and item_ent.stack.valid_for_read then
        local tags = item_ent.stack.tags or {}
        tags.bd_ver = 1
        tags.bd_genes_id = genes_id
        tags.bd_born_tick = game.tick
        item_ent.stack.tags = tags
      end
    end
  end

  return true, genes_id
end

return M