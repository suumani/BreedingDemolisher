-- __BreedingDemolisher__/prototypes/recipes/demolisher_egg_processing.lua
-- ----------------------------
-- Responsibility:
--   Defines cryogenics processing recipes for demolisher eggs:
--   - Create new species eggs (base/medium/big)
--   - Freeze / Unfreeze (all variants, all stages)
--   UI grouping uses subgroup "breeding-demolisher-egg-processing".
-- ----------------------------
local D = require("prototypes._shared.demolisher_egg_defs")

local recipes = {}

local function make_recipe(args)
  return {
    type = "recipe",
    name = args.name,
    category = "cryogenics",
    enabled = false,
    energy_required = args.energy_required or 60,
    result_is_always_fresh = true,

    subgroup = "breeding-demolisher-egg-processing",
    order = args.order,

    ingredients = args.ingredients,
    results = args.results,
    surface_conditions = args.surface_conditions or D.pressure_100_600(),
  }
end

local function freeze_ingredients(input_egg)
  return {
    {type="item", name=input_egg, amount=1},
    {type="item", name="ice", amount=200},
    {type="fluid", name="fluorine", amount=200},
    {type="fluid", name="fluoroketone-cold", amount=200},
  }
end

local function unfreeze_ingredients(input_egg)
  return {
    {type="item", name=input_egg, amount=1},
    {type="fluid", name="steam", amount=100},
    {type="fluid", name="lava", amount=200},
    {type="fluid", name="fluoroketone-hot", amount=200},
  }
end

local function new_species_create_ingredients(input_egg)
  return {
    {type="item", name=input_egg, amount=2},
    {type="item", name="captive-biter-spawner", amount=10},
    {type="item", name="biochamber", amount=20},
    {type="item", name="pentapod-egg", amount=20},
    {type="item", name="biter-egg", amount=20},
    {type="fluid", name="sulfuric-acid", amount=200},
    {type="fluid", name="molten-iron", amount=200},
    {type="fluid", name="fluoroketone-hot", amount=200},
  }
end

-- ----------------------------
-- Create new species eggs (base/medium/big)
-- name pattern matches your original:
--   new-spieces-demolisher-egg-recipe
--   new-spieces-demolisher-egg-medium-recipe
--   new-spieces-demolisher-egg-big-recipe
-- ----------------------------
for _, st in ipairs(D.STAGES) do
  local stage_suffix = st.suffix -- "", "-medium", "-big"
  local in_name = D.egg_name("", stage_suffix)                -- normal egg of that stage
  local out_name = D.egg_name("new-spieces-", stage_suffix)   -- new species egg of that stage

  local recipe_name = "new-spieces-demolisher-egg" .. stage_suffix .. "-recipe"
  recipes[#recipes + 1] = make_recipe({
    name = recipe_name,
    order = D.processing_order("a[create]", st.order, D.variant_order_key("new")),
    ingredients = new_species_create_ingredients(in_name),
    results = {{type="item", name=out_name, amount=1}},
  })
end

-- ----------------------------
-- Freeze / Unfreeze (all variants, all stages)
-- name pattern matches your originals, e.g.:
--   demolisher-egg-freeze-recipe
--   new-spieces-demolisher-egg-medium-unfreeze-recipe
-- ----------------------------
for _, st in ipairs(D.STAGES) do
  for _, v in ipairs(D.VARIANTS) do
    local raw = D.egg_name(v.prefix, st.suffix)
    local frozen = D.frozen_egg_name(v.prefix, st.suffix)

    local base = v.prefix .. "demolisher-egg" .. st.suffix

    recipes[#recipes + 1] = make_recipe({
      name = base .. "-freeze-recipe",
      order = D.processing_order("b[freeze]", st.order, D.variant_order_key(v.key)),
      ingredients = freeze_ingredients(raw),
      results = {{type="item", name=frozen, amount=1}},
    })

    recipes[#recipes + 1] = make_recipe({
      name = base .. "-unfreeze-recipe",
      order = D.processing_order("c[unfreeze]", st.order, D.variant_order_key(v.key)),
      ingredients = unfreeze_ingredients(frozen),
      results = {{type="item", name=raw, amount=1}},
    })
  end
end

data:extend(recipes)