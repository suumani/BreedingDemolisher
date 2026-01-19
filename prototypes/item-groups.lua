-- __BreedingDemolisher__/prototypes/item-groups.lua
-- ----------------------------
-- Responsibility:
--   Defines UI subgroups for BreedingDemolisher to keep items/recipes grouped.
-- ----------------------------
data:extend({
  {
    type = "item-subgroup",
    name = "breeding-demolisher-eggs",
    group = "intermediate-products",
    order = "z[breeding-demolisher]-a[eggs]"
  },
  {
    type = "item-subgroup",
    name = "breeding-demolisher-egg-processing",
    group = "intermediate-products",
    order = "z[breeding-demolisher]-b[processing]"
  },
  {
    type = "item-subgroup",
    name = "breeding-demolisher-egg-growth",
    group = "intermediate-products",
    order = "z[breeding-demolisher]-c[growth]"
  },
})