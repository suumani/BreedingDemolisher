-- __BreedingDemolisher__/prototypes/recipes/demolisher_egg_biochamber.lua
-- ----------------------------
-- Responsibility:
--   Biochamber route for creating new-species demolisher eggs.
--   - Heavy material cost
--   - Probabilistic result (20% success)
--   - Failure yields spoilage
-- Notes:
--   - Factorio requires recipe icon (icon or icons).
-- ----------------------------

local D = require("prototypes._shared.demolisher_egg_defs")

local CAT = "breeding-demolisher-biochamber"
local recipes = {}

local function make_recipe(args)
  return {
    type = "recipe",
    name = args.name,
    category = CAT,
    enabled = false,
    energy_required = args.energy_required or 120,
    result_is_always_fresh = true,

    -- REQUIRED in your environment
    icon = args.icon,
    icon_size = args.icon_size or 256,

    subgroup = "breeding-demolisher-egg-processing",
    order = args.order,

    ingredients = args.ingredients,
    results = args.results,
    surface_conditions = args.surface_conditions or D.pressure_4000(),
  }
end

local function new_species_biochamber_ingredients(input_egg)
  return {
    {type="item", name=input_egg, amount=2},

    {type="item", name="biter-egg", amount=40},
    {type="item", name="pentapod-egg", amount=40},
    {type="item", name="raw-fish", amount=40},

    {type="item", name="sulfur", amount=1000},
    {type="item", name="yumako", amount=1000},
    {type="item", name="jellynut", amount=1000},
  }
end

local SUCCESS_P = 0.20

for _, st in ipairs(D.STAGES) do
  local stage_suffix = st.suffix
  local in_name  = D.egg_name("", stage_suffix)
  local out_name = D.egg_name("new-spieces-", stage_suffix)

  local recipe_name =
    "new-spieces-demolisher-egg" .. stage_suffix .. "-biochamber-recipe"

  recipes[#recipes + 1] = make_recipe({
    name = recipe_name,

    -- Use output egg icon (matches stage: base/medium/big)
    icon = D.icon_path(out_name),
    icon_size = 256,

    order =
      D.processing_order("a[create]", st.order, D.variant_order_key("new"))
      .. "-b[biochamber]",

    ingredients = new_species_biochamber_ingredients(in_name),

    results = {
      {type="item", name=out_name, amount=1, probability=SUCCESS_P},
      {type="item", name="spoilage", amount=200, probability=1 - SUCCESS_P},
    },
  })
end

data:extend(recipes)