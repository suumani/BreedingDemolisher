-- __BreedingDemolisher__/scripts/services/LegacyEggQueueService.lua
-- ----------------------------
-- Responsibility:
--   Legacy fallback for eggs without tags: storage.my_eggs[egg_item][quality] queue.
--   (Can be removed later when old saves are no longer supported.)
-- ----------------------------
local L = {}

function L.try_peek(egg_item_name, quality_name)
  if not storage.my_eggs then return nil end
  local by_item = storage.my_eggs[egg_item_name]
  if not by_item then return nil end
  local by_quality = by_item[quality_name]
  if not by_quality or #by_quality == 0 then return nil end
  return by_quality[1]
end

function L.try_pop(egg_item_name, quality_name)
  local by_item = storage.my_eggs and storage.my_eggs[egg_item_name]
  local by_quality = by_item and by_item[quality_name]
  if not by_quality or #by_quality == 0 then return end
  table.remove(by_quality, 1)
end

return L