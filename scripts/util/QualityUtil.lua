-- __BreedingDemolisher__/scripts/util/QualityUtil.lua
-- ----------------------------
-- Responsibility:
--   Convert continuous genetic quality (number) into Factorio item quality name.
--   Current policy:
--     0-1: normal
--     2: uncommon
--     3: rare
--     4: epic
--     5+: legendary
-- ----------------------------
local Q = {}

function Q.to_item_quality_name(q)
  if type(q) ~= "number" then q = 0 end
  if q >= 5 then return CONST_QUALITY.LEGENDARY end
  if q >= 4 then return CONST_QUALITY.EPIC end
  if q >= 3 then return CONST_QUALITY.RARE end
  if q >= 2 then return CONST_QUALITY.UNCOMMON end
  return CONST_QUALITY.NORMAL
end

return Q