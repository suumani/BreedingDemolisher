-- __BreedingDemolisher__/prototypes/recipe-categories/breeding_demolisher_biochamber.lua
-- ----------------------------
-- Responsibility:
--   Define a custom recipe category for BreedingDemolisher biochamber processing
--   and register it to the vanilla Biochamber.
-- ----------------------------

local CAT = "breeding-demolisher-biochamber"

-- 1) define recipe category
data:extend({
  { type = "recipe-category", name = CAT }
})

-- 2) add category to vanilla biochamber
local bio = data.raw["assembling-machine"]
  and data.raw["assembling-machine"]["biochamber"]

if bio and bio.crafting_categories then
  local exists = false
  for _, c in ipairs(bio.crafting_categories) do
    if c == CAT then
      exists = true
      break
    end
  end
  if not exists then
    table.insert(bio.crafting_categories, CAT)
  end
end