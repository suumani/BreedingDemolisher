-- __BreedingDemolisher__/prototypes/items/demolisher_eggs.lua
-- ----------------------------
-- Responsibility:
--   Defines all demolisher egg items (raw/frozen) for all variants and stages.
--   UI grouping uses subgroup "breeding-demolisher-eggs".
-- ----------------------------
local D = require("prototypes._shared.demolisher_egg_defs")

local items = {}

local function make_egg_item(args)
  return {
    type = "item-with-tags",
    name = args.name,
    localised_name = {"item-name." .. args.name},
    localised_description = {"item-description." .. args.name},
    icon = D.icon_path(args.name),
    icon_size = 256,

    subgroup = "breeding-demolisher-eggs",
    order = args.order,

    stack_size = 1,
    spoil_ticks = args.spoil_ticks,
    spoil_result = args.spoil_result,
    weight = 1000000,
  }
end

local SPOIL_TICKS_RAW = 90000
local SPOIL_TICKS_FROZEN = 1080000

for _, st in ipairs(D.STAGES) do
  for _, v in ipairs(D.VARIANTS) do
    local raw_name = D.egg_name(v.prefix, st.suffix)
    local frozen_name = D.frozen_egg_name(v.prefix, st.suffix)

    local stage_order = st.order
    local variant_order = D.variant_order_key(v.key)

    -- raw egg
    items[#items + 1] = make_egg_item({
      name = raw_name,
      spoil_ticks = SPOIL_TICKS_RAW,
      spoil_result = "spoilage",
      order = D.egg_item_order(stage_order, variant_order, "a[raw]"),
    })

    -- frozen egg
    items[#items + 1] = make_egg_item({
      name = frozen_name,
      spoil_ticks = SPOIL_TICKS_FROZEN,
      spoil_result = raw_name, -- thaw back
      order = D.egg_item_order(stage_order, variant_order, "b[frozen]"),
    })
  end
end

data:extend(items)