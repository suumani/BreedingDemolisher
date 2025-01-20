
local function get_shifted_underground_pipe_picture(direction, shift)
	local underground_pipe_pictures = data.raw["pipe-to-ground"]["pipe-to-ground"].pictures
	local picture = table.deepcopy(underground_pipe_pictures[direction])
	picture.shift = shift
	return picture
end
data:extend({
	{
		type = "capsule",
		name = "demolisher-egg",
		localised_name = {"item-name.demolisher-egg"},
		localised_description = {"item-description.demolisher-egg"},
		icon = "__BreedingDemolisher__/graphics/icon_demolisher_egg.png",
		icon_size = 64,
		subgroup = "capsule",
		order = "a[new-item]",
		stack_size = 1,
		spoil_ticks = 90000, -- 鮮度の維持時間（秒）
		spoil_result = "spoilage", -- 腐敗後に変換されるアイテム
		weight = 1000000,
		capsule_action = {
			type = "throw",
			attack_parameters = {
				type = "projectile",
				ammo_category = "capsule",
				cooldown = 30, -- クールダウンタイム
				range = 15, -- 投擲可能距離
				ammo_type = {
					category = "capsule",
					target_type = "position",
					action = {
						{
							type = "direct",
							action_delivery = {
								type = "instant"
							}
						}
					}
				}
			}
		},
	},
	{
		type = "capsule",
		name = "demolisher-egg-frozen",
		localised_name = {"item-name.demolisher-egg-frozen"},
		localised_description = {"item-description.demolisher-egg-frozen"},
		icon = "__BreedingDemolisher__/graphics/icon_demolisher_egg-frozen.png",
		icon_size = 64,
		subgroup = "capsule",
		order = "a[new-item]",
		stack_size = 1,
		spoil_ticks = 1080000, -- 鮮度の維持時間（秒）
		spoil_result = "demolisher-egg", -- 腐敗後に変換されるアイテム
		weight = 1000000,
		capsule_action = {
			type = "throw",
			attack_parameters = {
				type = "projectile",
				ammo_category = "capsule",
				cooldown = 30, -- クールダウンタイム
				range = 15, -- 投擲可能距離
				ammo_type = {
					category = "capsule",
					target_type = "position",
					action = {
						{
							type = "direct",
							action_delivery = {
								type = "instant"
							}
						}
					}
				}
			}
		},
	},
	{
		type = "capsule",
		name = "new-spieces-demolisher-egg",
		localised_name = {"item-name.new-spieces-demolisher-egg"},
		localised_description = {"item-description.new-spieces-demolisher-egg"},
		icon = "__BreedingDemolisher__/graphics/icon_new_spieces_demolisher_egg.png",
		icon_size = 64,
		subgroup = "capsule",
		order = "a[new-item]",
		stack_size = 1,
		spoil_ticks = 90000, -- 鮮度の維持時間（秒）
		spoil_result = "spoilage", -- 腐敗後に変換されるアイテム
		weight = 1000000,
		capsule_action = {
			type = "throw",
			attack_parameters = {
				type = "projectile",
				ammo_category = "capsule",
				cooldown = 30, -- クールダウンタイム
				range = 15, -- 投擲可能距離
				ammo_type = {
					category = "capsule",
					target_type = "position",
					action = {
						{
							type = "direct",
							action_delivery = {
								type = "instant"
							}
						}
					}
				}
			}
		},
	},
	{
		type = "capsule",
		name = "new-spieces-demolisher-egg-frozen",
		localised_name = {"item-name.new-spieces-demolisher-egg-frozen"},
		localised_description = {"item-description.new-spieces-demolisher-egg-frozen"},
		icon = "__BreedingDemolisher__/graphics/icon_new_spieces_demolisher_egg-frozen.png",
		icon_size = 64,
		subgroup = "capsule",
		order = "a[new-item]",
		stack_size = 1,
		spoil_ticks = 1080000, -- 鮮度の維持時間（秒）
		spoil_result = "new-spieces-demolisher-egg", -- 腐敗後に変換されるアイテム
		weight = 1000000,
		capsule_action = {
			type = "throw",
			attack_parameters = {
				type = "projectile",
				ammo_category = "capsule",
				cooldown = 30, -- クールダウンタイム
				range = 15, -- 投擲可能距離
				ammo_type = {
					category = "capsule",
					target_type = "position",
					action = {
						{
							type = "direct",
							action_delivery = {
								type = "instant"
							}
						}
					}
				}
			}
		},
	},
	{
		type = "capsule",
		name = "friend-demolisher-egg",
		localised_name = {"item-name.friend-demolisher-egg"},
		localised_description = {"item-description.friend-demolisher-egg"},
		icon = "__BreedingDemolisher__/graphics/icon_friend_demolisher_egg.png",
		icon_size = 64,
		subgroup = "capsule",
		order = "a[new-item]",
		stack_size = 1,
		spoil_ticks = 90000, -- 鮮度の維持時間（秒）
		spoil_result = "spoilage", -- 腐敗後に変換されるアイテム
		weight = 1000000,
		capsule_action = {
			type = "throw",
			attack_parameters = {
				type = "projectile",
				ammo_category = "capsule",
				cooldown = 30, -- クールダウンタイム
				range = 15, -- 投擲可能距離
				ammo_type = {
					category = "capsule",
					target_type = "position",
					action = {
						{
							type = "direct",
							action_delivery = {
								type = "instant"
							}
						}
					}
				}
			}
		},
	},
	{
		type = "capsule",
		name = "friend-demolisher-egg-frozen",
		localised_name = {"item-name.friend-demolisher-egg-frozen"},
		localised_description = {"item-description.friend-demolisher-egg-frozen"},
		icon = "__BreedingDemolisher__/graphics/icon_friend_demolisher_egg-frozen.png",
		icon_size = 64,
		subgroup = "capsule",
		order = "a[new-item]",
		stack_size = 1,
		spoil_ticks = 1080000, -- 鮮度の維持時間（秒）
		spoil_result = "friend-demolisher-egg", -- 腐敗後に変換されるアイテム
		weight = 1000000,
		capsule_action = {
			type = "throw",
			attack_parameters = {
				type = "projectile",
				ammo_category = "capsule",
				cooldown = 30, -- クールダウンタイム
				range = 15, -- 投擲可能距離
				ammo_type = {
					category = "capsule",
					target_type = "position",
					action = {
						{
							type = "direct",
							action_delivery = {
								type = "instant"
							}
						}
					}
				}
			}
		},
	}
	,
	{
		type = "recipe",
		name = "new-spieces-demolisher-egg-recipe",
		category = "cryogenics",
		enabled = false,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "demolisher-egg", amount = 1},
			{type = "item", name = "captive-biter-spawner", amount = 10},
			{type = "item", name = "biochamber", amount = 20},
			{type = "item", name = "pentapod-egg", amount = 200},
			{type = "item", name = "biter-egg", amount = 200},
			{type = "fluid", name = "sulfuric-acid", amount = 200},
			{type = "fluid", name = "molten-iron", amount = 200},
			{type = "fluid", name = "fluoroketone-hot", amount = 200}
		},
		results = {
			{type = "item", name = "new-spieces-demolisher-egg", amount = 1}
		},
		surface_conditions = {
			{
				property = "pressure",
				min = 100,
				max = 600
			}
		},
	}
	,
	{
		type = "recipe",
		name = "demolisher-egg-freeze-recipe",
		category = "cryogenics",
		enabled = false,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "demolisher-egg", amount = 1},
			{type = "item", name = "captive-biter-spawner", amount = 10},
			{type = "item", name = "biochamber", amount = 20},
			{type = "fluid", name = "sulfuric-acid", amount = 200},
			{type = "fluid", name = "fluorine", amount = 200},
			{type = "fluid", name = "fluoroketone-cold", amount = 200}
		},
		results = {
			{type = "item", name = "demolisher-egg-frozen", amount = 1}
		},
		surface_conditions = {
			{
				property = "pressure",
				min = 100,
				max = 600
			}
		},
	},
	{
		type = "recipe",
		name = "new-spieces-demolisher-egg-freeze-recipe",
		category = "cryogenics",
		enabled = false,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "demolisher-egg", amount = 1},
			{type = "item", name = "captive-biter-spawner", amount = 10},
			{type = "item", name = "biochamber", amount = 20},
			{type = "fluid", name = "sulfuric-acid", amount = 200},
			{type = "fluid", name = "fluorine", amount = 200},
			{type = "fluid", name = "fluoroketone-cold", amount = 200}
		},
		results = {
			{type = "item", name = "new-spieces-demolisher-egg-frozen", amount = 1}
		},
		surface_conditions = {
			{
				property = "pressure",
				min = 100,
				max = 600
			}
		},
	},
	{
		type = "recipe",
		name = "friend-demolisher-egg-freeze-recipe",
		category = "cryogenics",
		enabled = false,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "demolisher-egg", amount = 1},
			{type = "item", name = "captive-biter-spawner", amount = 10},
			{type = "item", name = "biochamber", amount = 20},
			{type = "fluid", name = "sulfuric-acid", amount = 200},
			{type = "fluid", name = "fluorine", amount = 200},
			{type = "fluid", name = "fluoroketone-cold", amount = 200}
		},
		results = {
			{type = "item", name = "friend-demolisher-egg-frozen", amount = 1}
		},
		surface_conditions = {
			{
				property = "pressure",
				min = 100,
				max = 600
			}
		},
	}
	,
	{
		type = "recipe",
		name = "demolisher-egg-unfreeze-recipe",
		category = "cryogenics",
		enabled = false,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "demolisher-egg-frozen", amount = 1},
			{type = "item", name = "captive-biter-spawner", amount = 10},
			{type = "item", name = "biochamber", amount = 20},
			{type = "fluid", name = "sulfuric-acid", amount = 200},
			{type = "fluid", name = "fluorine", amount = 200},
			{type = "fluid", name = "fluoroketone-cold", amount = 200}
		},
		results = {
			{type = "item", name = "demolisher-egg", amount = 1}
		},
		surface_conditions = {
			{
				property = "pressure",
				min = 100,
				max = 600
			}
		},
	}
	,
	{
		type = "recipe",
		name = "new-spieces-demolisher-egg-unfreeze-recipe",
		category = "cryogenics",
		enabled = false,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "new-spieces-demolisher-egg-frozen", amount = 1},
			{type = "item", name = "captive-biter-spawner", amount = 10},
			{type = "item", name = "biochamber", amount = 20},
			{type = "fluid", name = "sulfuric-acid", amount = 200},
			{type = "fluid", name = "fluorine", amount = 200},
			{type = "fluid", name = "fluoroketone-cold", amount = 200}
		},
		results = {
			{type = "item", name = "new-spieces-demolisher-egg", amount = 1}
		},
		surface_conditions = {
			{
				property = "pressure",
				min = 100,
				max = 600
			}
		},
	}
	,
	{
		type = "recipe",
		name = "friend-demolisher-egg-unfreeze-recipe",
		category = "cryogenics",
		enabled = false,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "friend-demolisher-egg-frozen", amount = 1},
			{type = "item", name = "captive-biter-spawner", amount = 10},
			{type = "item", name = "biochamber", amount = 20},
			{type = "fluid", name = "sulfuric-acid", amount = 200},
			{type = "fluid", name = "fluorine", amount = 200},
			{type = "fluid", name = "fluoroketone-cold", amount = 200}
		},
		results = {
			{type = "item", name = "friend-demolisher-egg", amount = 1}
		},
		surface_conditions = {
			{
				property = "pressure",
				min = 100,
				max = 600
			}
		},
	}
	,
	{
		type = "recipe",
		name = "demolisher-egg-dummy-recipe",
		category = "crafting",
		enabled = true,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "demolisher-egg", amount = 10}
		},
		results = {
			{type = "item", name = "demolisher-egg", amount = 1}
		},
		surface_conditions = {
			{
				property = "pressure",
				min = 100,
				max = 600
			}
		},
	}
	,
	{
		type = "recipe",
		name = "new-spieces-demolisher-egg-dummy-recipe",
		category = "crafting",
		enabled = true,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "new-spieces-demolisher-egg", amount = 10}
		},
		results = {
			{type = "item", name = "new-spieces-demolisher-egg", amount = 1}
		},
		surface_conditions = {
			{
				property = "pressure",
				min = 100,
				max = 600
			}
		},
	}
	,
	{
		type = "recipe",
		name = "friend-demolisher-egg-dummy-recipe",
		category = "crafting",
		enabled = true,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "friend-demolisher-egg", amount = 10}
		},
		results = {
			{type = "item", name = "friend-demolisher-egg", amount = 1}
		},
		surface_conditions = {
			{
				property = "pressure",
				min = 100,
				max = 600
			}
		},
	}
	,
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
		icon_size = 64,
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
		icon_size = 64,
		icon = "__BreedingDemolisher__/graphics/technology/infinite-demolisher-quality.png",
		prerequisites = {"demolisher-egg-unlock"},	-- Previous research as a prerequisite
		unit = {
			count_formula = "4000*(L^1.5)",	-- Formula for increasing cost per level
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
		max_level = "infinite",	-- Infinite research
		effects = {
			{
			type = "nothing",
			effect_description = {"technology-effect-quality.nothing"}
			}
		},
		order = "z-a"
	}
	,
	{
		type = "technology",
		name = "infinite-demolisher-life",
		icon_size = 256,
		icon = "__BreedingDemolisher__/graphics/technology/infinite-demolisher-life.png",
		prerequisites = {"demolisher-egg-unlock"},	-- Previous research as a prerequisite
		unit = {
			count_formula = "4000*(L^1.5)",	-- Formula for increasing cost per level
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
		max_level = "infinite",	-- Infinite research
		effects = {
			{
			type = "nothing",
			effect_description = {"technology-effect-life.nothing"}
			}
		},
		order = "z-a"
	}
	,
	{
		type = "item",
		name = "genetic-analysis-machine",
		icon = "__BreedingDemolisher__/graphics/icons/genetic-analysis-machine.png",
		icon_size = 64,
		subgroup = "production-machine",
		order = "a[genetic-analysis-machine]",
		place_result = "genetic-analysis-machine",
		stack_size = 10
	}
	,
    {
        type = "container",
        name = "genetic-analysis-machine",
        icon = "__BreedingDemolisher__/graphics/icons/genetic-analysis-machine.png",
        icon_size = 64,
        flags = {"placeable-neutral", "placeable-player", "player-creation"},
        minable = {mining_time = 0.5, result = "genetic-analysis-machine"},
        max_health = 300,
        corpse = "small-remnants",
        collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
        selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
        render_layer = "object",
        inventory_size = 1, -- チェストのスロット数
        picture = {
            filename = "__BreedingDemolisher__/graphics/entity/genetic-analysis-machine.png",
            width = 128,
            height = 128,
            shift = {0, 0}
        }
    }
    ,
	{
		type = "recipe-category",
		name = "genetic-analysis"
	},

})