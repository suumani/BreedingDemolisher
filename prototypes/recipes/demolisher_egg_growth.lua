-- __BreedingDemolisher__/prototypes/recipes/demolisher_egg_growth.lua
-- ----------------------------
-- Responsibility:
--   Defines organic growth recipes for demolisher eggs:
--   - dummy recipes (2 eggs -> 1 egg)
--   - grow recipes (10 eggs -> next stage egg)
--   UI grouping uses subgroup "breeding-demolisher-egg-growth".
-- ----------------------------
local D = require("prototypes._shared.demolisher_egg_defs")

local recipes = {}

local function make_growth_recipe(args)
  return {
    type = "recipe",
    name = args.name,
    category = "organic",
    enabled = false,
    energy_required = args.energy_required or 60,
    result_is_always_fresh = false,

    subgroup = "breeding-demolisher-egg-growth",
    order = args.order,

    ingredients = args.ingredients,
    results = args.results,
    surface_conditions = args.surface_conditions or D.pressure_4000(),
  }
end

local function growth_ingredients(input_egg, egg_amount)
  return {
    {type="item", name=input_egg, amount=egg_amount},
    {type="item", name="tungsten-ore", amount=200},
    {type="item", name="calcite", amount=200},
    {type="item", name="uranium-235", amount=200},
    {type="fluid", name="lava", amount=500},
    {type="fluid", name="sulfuric-acid", amount=500},
  }
end

-- Dummy: 2 -> 1 (per stage, per variant)
for _, st in ipairs(D.STAGES) do
  for _, v in ipairs(D.VARIANTS) do
    local egg = D.egg_name(v.prefix, st.suffix)

    recipes[#recipes + 1] = make_growth_recipe({
      name = v.prefix .. "demolisher-egg" .. st.suffix .. "-dummy-recipe",
      order = ("z[dummy]-%s-%s"):format(st.order, D.variant_order_key(v.key)),
      ingredients = growth_ingredients(egg, 2),
      results = {{type="item", name=egg, amount=1}},
    })
  end
end

-- Grow: base -> medium, medium -> big (per variant)
local by_key = {}
for _, st in ipairs(D.STAGES) do by_key[st.key] = st end

local function add_grow(from_key, to_key)
  local from = by_key[from_key]
  local to = by_key[to_key]
  for _, v in ipairs(D.VARIANTS) do
    local in_egg = D.egg_name(v.prefix, from.suffix)
    local out_egg = D.egg_name(v.prefix, to.suffix)

    recipes[#recipes + 1] = make_growth_recipe({
      name = v.prefix .. "demolisher-egg" .. from.suffix .. "-grow-recipe",
      order = D.growth_order(from.order, D.variant_order_key(v.key)),
      ingredients = growth_ingredients(in_egg, 10),
      results = {{type="item", name=out_egg, amount=1}},
    })
  end
end

add_grow("base", "medium")
add_grow("medium", "big")

data:extend(recipes)