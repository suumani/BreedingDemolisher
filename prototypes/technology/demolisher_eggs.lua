-- __BreedingDemolisher__/prototypes/technology/demolisher_eggs.lua
-- ----------------------------
-- Responsibility:
--   Defines technologies that unlock demolisher egg processing recipes and infinite upgrades.
--   (Logic/values are kept the same as the original file; this is only a relocation/refactor.)
-- ----------------------------

data:extend({
  {
    type = "technology",
    name = "demolisher-egg-unlock",
    icon_size = 256,
    icon = "__BreedingDemolisher__/graphics/technology/demolisher-egg-tech.png",
    prerequisites = {"captive-biter-spawner"},
    unit = {
      count = 8000,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
        {"metallurgic-science-pack", 1},
        {"electromagnetic-science-pack", 1},
        {"agricultural-science-pack", 1},
        {"cryogenic-science-pack", 1}
      },
      time = 60
    },
    effects = {
      {
        type = "unlock-recipe",
        recipe = "new-spieces-demolisher-egg-recipe",
        effect_description = {"technology-effect-description.new-spieces-demolisher-egg-recipe"}
      }
    },
    order = "z"
  },

  {
    type = "technology",
    name = "demolisher-egg-freeze",
    icon_size = 256,
    icon = "__BreedingDemolisher__/graphics/technology/demolisher-egg-freeze.png",
    prerequisites = {"demolisher-egg-unlock"},
    unit = {
      count = 16000,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
        {"metallurgic-science-pack", 1},
        {"electromagnetic-science-pack", 1},
        {"agricultural-science-pack", 1},
        {"cryogenic-science-pack", 1}
      },
      time = 60
    },
    effects = {
      {
        type = "unlock-recipe",
        recipe = "demolisher-egg-freeze-recipe",
        effect_description = {"technology-effect-description.new-spieces-demolisher-egg-freeze-recipe"}
      },
      {
        type = "unlock-recipe",
        recipe = "new-spieces-demolisher-egg-freeze-recipe",
        effect_description = {"technology-effect-description.new-spieces-demolisher-egg-freeze-recipe"}
      },
      {
        type = "unlock-recipe",
        recipe = "friend-demolisher-egg-freeze-recipe",
        effect_description = {"technology-effect-description.new-spieces-demolisher-egg-freeze-recipe"}
      },
    },
    order = "z"
  },

  {
    type = "technology",
    name = "demolisher-egg-unfreeze",
    icon_size = 256,
    icon = "__BreedingDemolisher__/graphics/technology/demolisher-egg-unfreeze.png",
    prerequisites = {"demolisher-egg-freeze"},
    unit = {
      count = 20000,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
        {"metallurgic-science-pack", 1},
        {"electromagnetic-science-pack", 1},
        {"agricultural-science-pack", 1},
        {"cryogenic-science-pack", 1}
      },
      time = 60
    },
    effects = {
      {
        type = "unlock-recipe",
        recipe = "demolisher-egg-unfreeze-recipe",
        effect_description = {"technology-effect-description.new-spieces-demolisher-egg-unfreeze-recipe"}
      },
      {
        type = "unlock-recipe",
        recipe = "new-spieces-demolisher-egg-unfreeze-recipe",
        effect_description = {"technology-effect-description.new-spieces-demolisher-egg-unfreeze-recipe"}
      },
      {
        type = "unlock-recipe",
        recipe = "friend-demolisher-egg-unfreeze-recipe",
        effect_description = {"technology-effect-description.new-spieces-demolisher-egg-unfreeze-recipe"}
      },
    },
    order = "z"
  },

  {
    type = "technology",
    name = "infinite-demolisher-quality",
    icon_size = 256,
    icon = "__BreedingDemolisher__/graphics/technology/infinite-demolisher-quality.png",
    prerequisites = {"demolisher-egg-unlock"},
    unit = {
      count_formula = "4000*(L^1.5)",
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
        {"metallurgic-science-pack", 1},
        {"electromagnetic-science-pack", 1},
        {"agricultural-science-pack", 1},
        {"cryogenic-science-pack", 1}
      },
      time = 60
    },
    max_level = "infinite",
    effects = {
      {
        type = "nothing",
        effect_description = {"technology-effect-quality.nothing"}
      }
    },
    order = "z-a"
  },

  {
    type = "technology",
    name = "infinite-demolisher-life",
    icon_size = 256,
    icon = "__BreedingDemolisher__/graphics/technology/infinite-demolisher-life.png",
    prerequisites = {"demolisher-egg-unlock"},
    unit = {
      count_formula = "4000*(L^1.5)",
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
        {"metallurgic-science-pack", 1},
        {"electromagnetic-science-pack", 1},
        {"agricultural-science-pack", 1},
        {"cryogenic-science-pack", 1}
      },
      time = 60
    },
    max_level = "infinite",
    effects = {
      {
        type = "nothing",
        effect_description = {"technology-effect-life.nothing"}
      }
    },
    order = "z-a"
  },

  {
    type = "technology",
    name = "technology-breeding-demolisher-clear",
    icon_size = 256,
    icon = "__BreedingDemolisher__/graphics/technology/technology-breeding-demolisher-clear.png",
    prerequisites = {"demolisher-egg-unfreeze"},
    unit = {
      count_formula = "1000000",
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
        {"metallurgic-science-pack", 1},
        {"electromagnetic-science-pack", 1},
        {"agricultural-science-pack", 1},
        {"cryogenic-science-pack", 1},
        {"promethium-science-pack", 1}
      },
      time = 60
    },
    effects = {
      {
        type = "nothing",
        effect_description = {"technology-effect-quality.nothing"}
      }
    },
    order = "z-a"
  },
})