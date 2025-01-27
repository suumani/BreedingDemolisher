
local function get_shifted_underground_pipe_picture(direction, shift)
	local underground_pipe_pictures = data.raw["pipe-to-ground"]["pipe-to-ground"].pictures
	local picture = table.deepcopy(underground_pipe_pictures[direction])
	picture.shift = shift
	return picture
end
data:extend({
	{
		type = "item",
		name = "demolisher-egg",
		localised_name = {"item-name.demolisher-egg"},
		localised_description = {"item-description.demolisher-egg"},
		icon = "__BreedingDemolisher__/graphics/icon/demolisher_egg.png",
		icon_size = 64,
		subgroup = "raw-material",
		order = "c[cryogenics]-a[_011-demolisher_egg]",
		stack_size = 1,
		spoil_ticks = 90000, -- 鮮度の維持時間（秒）
		spoil_result = "spoilage", -- 腐敗後に変換されるアイテム
		weight = 1000000,
	}
	,
	{
		type = "item",
		name = "demolisher-egg-frozen",
		localised_name = {"item-name.demolisher-egg-frozen"},
		localised_description = {"item-description.demolisher-egg-frozen"},
		icon = "__BreedingDemolisher__/graphics/icon/demolisher_egg_frozen.png",
		icon_size = 64,
		subgroup = "raw-material",
		order = "c[cryogenics]-a[_111-demolisher_egg_frozen]",
		stack_size = 1,
		spoil_ticks = 1080000, -- 鮮度の維持時間（秒）
		spoil_result = "demolisher-egg", -- 腐敗後に変換されるアイテム
		weight = 1000000,
	}
	,
	{
		type = "item",
		name = "new-spieces-demolisher-egg",
		localised_name = {"item-name.new-spieces-demolisher-egg"},
		localised_description = {"item-description.new-spieces-demolisher-egg"},
		icon = "__BreedingDemolisher__/graphics/icon/new_spieces_demolisher_egg.png",
		icon_size = 64,
		subgroup = "raw-material",
		order = "c[cryogenics]-a[_021-new_spieces_demolisher_egg]",
		stack_size = 1,
		spoil_ticks = 90000, -- 鮮度の維持時間（秒）
		spoil_result = "spoilage", -- 腐敗後に変換されるアイテム
		weight = 1000000,
	}
	,
	{
		type = "item",
		name = "new-spieces-demolisher-egg-frozen",
		localised_name = {"item-name.new-spieces-demolisher-egg-frozen"},
		localised_description = {"item-description.new-spieces-demolisher-egg-frozen"},
		icon = "__BreedingDemolisher__/graphics/icon/new_spieces_demolisher_egg_frozen.png",
		icon_size = 64,
		subgroup = "raw-material",
		order = "c[cryogenics]-a[_121-new_spieces_demolisher_egg_frozen]",
		stack_size = 1,
		spoil_ticks = 1080000, -- 鮮度の維持時間（秒）
		spoil_result = "new-spieces-demolisher-egg", -- 腐敗後に変換されるアイテム
		weight = 1000000,
	}
	,
	{
		type = "item",
		name = "friend-demolisher-egg",
		localised_name = {"item-name.friend-demolisher-egg"},
		localised_description = {"item-description.friend-demolisher-egg"},
		icon = "__BreedingDemolisher__/graphics/icon/friend_demolisher_egg.png",
		icon_size = 64,
		subgroup = "raw-material",
		order = "c[cryogenics]-a[_031-friend_demolisher_egg]",
		stack_size = 1,
		spoil_ticks = 90000, -- 鮮度の維持時間（秒）
		spoil_result = "spoilage", -- 腐敗後に変換されるアイテム
		weight = 1000000,
	}
	,
	{
		type = "item",
		name = "friend-demolisher-egg-frozen",
		localised_name = {"item-name.friend-demolisher-egg-frozen"},
		localised_description = {"item-description.friend-demolisher-egg-frozen"},
		icon = "__BreedingDemolisher__/graphics/icon/friend_demolisher_egg_frozen.png",
		icon_size = 64,
		subgroup = "raw-material",
		order = "c[cryogenics]-a[_131-friend_demolisher_egg_frozen]",
		stack_size = 1,
		spoil_ticks = 1080000, -- 鮮度の維持時間（秒）
		spoil_result = "friend-demolisher-egg", -- 腐敗後に変換されるアイテム
		weight = 1000000,
	}
	,
	{
		type = "recipe",
		name = "new-spieces-demolisher-egg-recipe",
		result_is_always_fresh = true,
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
		result_is_always_fresh = true,
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
	}
	,
	{
		type = "recipe",
		name = "new-spieces-demolisher-egg-freeze-recipe",
		result_is_always_fresh = true,
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
	}
	,
	{
		type = "recipe",
		name = "friend-demolisher-egg-freeze-recipe",
		result_is_always_fresh = true,
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
		result_is_always_fresh = true,
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
		result_is_always_fresh = true,
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
		result_is_always_fresh = true,
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
		result_is_always_fresh = true,
		category = "organic",
		subgroup = "agriculture-products",
		enabled = false,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "demolisher-egg", amount = 2},
			{type = "item", name = "tungsten-ore", amount = 200},
			{type = "item", name = "calcite", amount = 200},
			{type = "item", name = "uranium-235", amount = 200},
			{type = "fluid", name = "lava", amount = 500},
			{type = "fluid", name = "sulfuric-acid", amount = 500},

		},
		results = {
			{type = "item", name = "demolisher-egg", amount = 1}
		},
		surface_conditions = {
			{
				property = "pressure",
				min = 4000,
				max = 4000
			}
		},
		result_is_always_fresh = false,
	}
	,
	{
		type = "recipe",
		name = "demolisher-egg-grow-recipe",
		result_is_always_fresh = true,
		category = "organic",
		subgroup = "agriculture-products",
		enabled = false,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "demolisher-egg", amount = 10},
			{type = "item", name = "tungsten-ore", amount = 200},
			{type = "item", name = "calcite", amount = 200},
			{type = "item", name = "uranium-235", amount = 200},
			{type = "fluid", name = "lava", amount = 500},
			{type = "fluid", name = "sulfuric-acid", amount = 500},

		},
		results = {
			{type = "item", name = "demolisher-egg-medium", amount = 1}
		},
		surface_conditions = {
			{
				property = "pressure",
				min = 4000,
				max = 4000
			}
		},
		result_is_always_fresh = false,
	}
	,
	{
		type = "recipe",
		name = "new-spieces-demolisher-egg-dummy-recipe",
		result_is_always_fresh = true,
		category = "organic",
		subgroup = "agriculture-products",
		enabled = false,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "new-spieces-demolisher-egg", amount = 2},
			{type = "item", name = "tungsten-ore", amount = 200},
			{type = "item", name = "calcite", amount = 200},
			{type = "item", name = "uranium-235", amount = 200},
			{type = "fluid", name = "lava", amount = 500},
			{type = "fluid", name = "sulfuric-acid", amount = 500},
		},
		results = {
			{type = "item", name = "new-spieces-demolisher-egg", amount = 1}
		},
		surface_conditions = {
			{
				property = "pressure",
				min = 4000,
				max = 4000
			}
		},
	}
	,
	{
		type = "recipe",
		name = "new-spieces-demolisher-egg-grow-recipe",
		result_is_always_fresh = true,
		category = "organic",
		subgroup = "agriculture-products",
		enabled = false,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "new-spieces-demolisher-egg", amount = 10},
			{type = "item", name = "tungsten-ore", amount = 200},
			{type = "item", name = "calcite", amount = 200},
			{type = "item", name = "uranium-235", amount = 200},
			{type = "fluid", name = "lava", amount = 500},
			{type = "fluid", name = "sulfuric-acid", amount = 500},
		},
		results = {
			{type = "item", name = "new-spieces-demolisher-egg-medium", amount = 1}
		},
		surface_conditions = {
			{
				property = "pressure",
				min = 4000,
				max = 4000
			}
		},
	}
	,
	{
		type = "recipe",
		name = "friend-demolisher-egg-dummy-recipe",
		result_is_always_fresh = true,
		category = "organic",
		subgroup = "agriculture-products",
		enabled = false,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "friend-demolisher-egg", amount = 2},
			{type = "item", name = "tungsten-ore", amount = 200},
			{type = "item", name = "calcite", amount = 200},
			{type = "item", name = "uranium-235", amount = 200},
			{type = "fluid", name = "lava", amount = 500},
			{type = "fluid", name = "sulfuric-acid", amount = 500},
		},
		results = {
			{type = "item", name = "friend-demolisher-egg", amount = 1}
		},
		surface_conditions = {
			{
				property = "pressure",
				min = 4000,
				max = 4000
			}
		},
	}
	,
	{
		type = "recipe",
		name = "friend-demolisher-egg-grow-recipe",
		result_is_always_fresh = true,
		category = "organic",
		subgroup = "agriculture-products",
		enabled = false,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "friend-demolisher-egg", amount = 10},
			{type = "item", name = "tungsten-ore", amount = 200},
			{type = "item", name = "calcite", amount = 200},
			{type = "item", name = "uranium-235", amount = 200},
			{type = "fluid", name = "lava", amount = 500},
			{type = "fluid", name = "sulfuric-acid", amount = 500},
		},
		results = {
			{type = "item", name = "friend-demolisher-egg-medium", amount = 1}
		},
		surface_conditions = {
			{
				property = "pressure",
				min = 4000,
				max = 4000
			}
		},
	}
	,
	{
		type = "item",
		name = "demolisher-egg-medium",
		localised_name = {"item-name.demolisher-egg-medium"},
		localised_description = {"item-description.demolisher-egg-medium"},
		icon = "__BreedingDemolisher__/graphics/icon/demolisher_egg_medium.png",
		icon_size = 64,
		subgroup = "raw-material",
		order = "c[cryogenics]-a[_012-demolisher_egg_medium]",
		stack_size = 1,
		spoil_ticks = 90000, -- 鮮度の維持時間（秒）
		spoil_result = "spoilage", -- 腐敗後に変換されるアイテム
		weight = 1000000,
	}
	,
	{
		type = "item",
		name = "demolisher-egg-medium-frozen",
		localised_name = {"item-name.demolisher-egg-medium-frozen"},
		localised_description = {"item-description.demolisher-egg-medium-frozen"},
		icon = "__BreedingDemolisher__/graphics/icon/demolisher_egg_medium_frozen.png",
		icon_size = 64,
		subgroup = "raw-material",
		order = "c[cryogenics]-a[_112-demolisher_egg_medium_frozen]",
		stack_size = 1,
		spoil_ticks = 1080000, -- 鮮度の維持時間（秒）
		spoil_result = "demolisher-egg-medium", -- 腐敗後に変換されるアイテム
		weight = 1000000,
	}
	,
	{
		type = "item",
		name = "new-spieces-demolisher-egg-medium",
		localised_name = {"item-name.new-spieces-demolisher-egg-medium"},
		localised_description = {"item-description.new-spieces-demolisher-egg-medium"},
		icon = "__BreedingDemolisher__/graphics/icon/new_spieces_demolisher_egg_medium.png",
		icon_size = 64,
		subgroup = "raw-material",
		order = "c[cryogenics]-a[_022-new_spieces_demolisher_egg_medium]",
		stack_size = 1,
		spoil_ticks = 90000, -- 鮮度の維持時間（秒）
		spoil_result = "spoilage", -- 腐敗後に変換されるアイテム
		weight = 1000000,
	}
	,
	{
		type = "item",
		name = "new-spieces-demolisher-egg-medium-frozen",
		localised_name = {"item-name.new-spieces-demolisher-egg-medium-frozen"},
		localised_description = {"item-description.new-spieces-demolisher-egg-medium-frozen"},
		icon = "__BreedingDemolisher__/graphics/icon/new_spieces_demolisher_egg_medium_frozen.png",
		icon_size = 64,
		subgroup = "raw-material",
		order = "c[cryogenics]-a[_122-new-spieces-demolisher-egg-medium-frozen]",
		stack_size = 1,
		spoil_ticks = 1080000, -- 鮮度の維持時間（秒）
		spoil_result = "new-spieces-demolisher-egg-medium", -- 腐敗後に変換されるアイテム
		weight = 1000000,
	}
	,
	{
		type = "item",
		name = "friend-demolisher-egg-medium",
		localised_name = {"item-name.friend-demolisher-egg-medium"},
		localised_description = {"item-description.friend-demolisher-egg-medium"},
		icon = "__BreedingDemolisher__/graphics/icon/friend_demolisher_egg_medium.png",
		icon_size = 64,
		subgroup = "raw-material",
		order = "c[cryogenics]-a[_032-friend-demolisher-egg-medium]",
		stack_size = 1,
		spoil_ticks = 90000, -- 鮮度の維持時間（秒）
		spoil_result = "spoilage", -- 腐敗後に変換されるアイテム
		weight = 1000000,
	}
	,
	{
		type = "item",
		name = "friend-demolisher-egg-medium-frozen",
		localised_name = {"item-name.friend-demolisher-egg-medium-frozen"},
		localised_description = {"item-description.friend-demolisher-egg-medium-frozen"},
		icon = "__BreedingDemolisher__/graphics/icon/friend_demolisher_egg_medium_frozen.png",
		icon_size = 64,
		subgroup = "raw-material",
		order = "c[cryogenics]-a[_132_friend-demolisher-egg-medium-frozen]",
		stack_size = 1,
		spoil_ticks = 1080000, -- 鮮度の維持時間（秒）
		spoil_result = "friend-demolisher-egg-medium", -- 腐敗後に変換されるアイテム
		weight = 1000000,
	}
	,
	{
		type = "recipe",
		name = "new-spieces-demolisher-egg-medium-recipe",
		result_is_always_fresh = true,
		category = "cryogenics",
		enabled = false,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "demolisher-egg-medium", amount = 1},
			{type = "item", name = "captive-biter-spawner", amount = 10},
			{type = "item", name = "biochamber", amount = 20},
			{type = "item", name = "pentapod-egg", amount = 200},
			{type = "item", name = "biter-egg", amount = 200},
			{type = "fluid", name = "sulfuric-acid", amount = 200},
			{type = "fluid", name = "molten-iron", amount = 200},
			{type = "fluid", name = "fluoroketone-hot", amount = 200}
		},
		results = {
			{type = "item", name = "new-spieces-demolisher-egg-medium", amount = 1}
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
		name = "demolisher-egg-medium-freeze-recipe",
		result_is_always_fresh = true,
		category = "cryogenics",
		enabled = false,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "demolisher-egg-medium", amount = 1},
			{type = "item", name = "captive-biter-spawner", amount = 10},
			{type = "item", name = "biochamber", amount = 20},
			{type = "fluid", name = "sulfuric-acid", amount = 200},
			{type = "fluid", name = "fluorine", amount = 200},
			{type = "fluid", name = "fluoroketone-cold", amount = 200}
		},
		results = {
			{type = "item", name = "demolisher-egg-medium-frozen", amount = 1}
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
		name = "new-spieces-demolisher-egg-medium-freeze-recipe",
		result_is_always_fresh = true,
		category = "cryogenics",
		enabled = false,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "demolisher-egg-medium", amount = 1},
			{type = "item", name = "captive-biter-spawner", amount = 10},
			{type = "item", name = "biochamber", amount = 20},
			{type = "fluid", name = "sulfuric-acid", amount = 200},
			{type = "fluid", name = "fluorine", amount = 200},
			{type = "fluid", name = "fluoroketone-cold", amount = 200}
		},
		results = {
			{type = "item", name = "new-spieces-demolisher-egg-medium-frozen", amount = 1}
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
		name = "friend-demolisher-egg-medium-freeze-recipe",
		result_is_always_fresh = true,
		category = "cryogenics",
		enabled = false,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "demolisher-egg-medium", amount = 1},
			{type = "item", name = "captive-biter-spawner", amount = 10},
			{type = "item", name = "biochamber", amount = 20},
			{type = "fluid", name = "sulfuric-acid", amount = 200},
			{type = "fluid", name = "fluorine", amount = 200},
			{type = "fluid", name = "fluoroketone-cold", amount = 200}
		},
		results = {
			{type = "item", name = "friend-demolisher-egg-medium-frozen", amount = 1}
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
		name = "demolisher-egg-medium-unfreeze-recipe",
		result_is_always_fresh = true,
		category = "cryogenics",
		enabled = false,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "demolisher-egg-medium-frozen", amount = 1},
			{type = "item", name = "captive-biter-spawner", amount = 10},
			{type = "item", name = "biochamber", amount = 20},
			{type = "fluid", name = "sulfuric-acid", amount = 200},
			{type = "fluid", name = "fluorine", amount = 200},
			{type = "fluid", name = "fluoroketone-cold", amount = 200}
		},
		results = {
			{type = "item", name = "demolisher-egg-medium", amount = 1}
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
		name = "new-spieces-demolisher-egg-medium-unfreeze-recipe",
		result_is_always_fresh = true,
		category = "cryogenics",
		enabled = false,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "new-spieces-demolisher-egg-medium-frozen", amount = 1},
			{type = "item", name = "captive-biter-spawner", amount = 10},
			{type = "item", name = "biochamber", amount = 20},
			{type = "fluid", name = "sulfuric-acid", amount = 200},
			{type = "fluid", name = "fluorine", amount = 200},
			{type = "fluid", name = "fluoroketone-cold", amount = 200}
		},
		results = {
			{type = "item", name = "new-spieces-demolisher-egg-medium", amount = 1}
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
		name = "friend-demolisher-egg-medium-unfreeze-recipe",
		result_is_always_fresh = true,
		category = "cryogenics",
		enabled = false,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "friend-demolisher-egg-medium-frozen", amount = 1},
			{type = "item", name = "captive-biter-spawner", amount = 10},
			{type = "item", name = "biochamber", amount = 20},
			{type = "fluid", name = "sulfuric-acid", amount = 200},
			{type = "fluid", name = "fluorine", amount = 200},
			{type = "fluid", name = "fluoroketone-cold", amount = 200}
		},
		results = {
			{type = "item", name = "friend-demolisher-egg-medium", amount = 1}
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
		name = "demolisher-egg-medium-grow-recipe",
		result_is_always_fresh = true,
		category = "organic",
		subgroup = "agriculture-products",
		enabled = false,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "demolisher-egg-medium", amount = 10},
			{type = "item", name = "tungsten-ore", amount = 200},
			{type = "item", name = "calcite", amount = 200},
			{type = "item", name = "uranium-235", amount = 200},
			{type = "fluid", name = "lava", amount = 500},
			{type = "fluid", name = "sulfuric-acid", amount = 500},
		},
		results = {
			{type = "item", name = "demolisher-egg-big", amount = 1}
		},
		surface_conditions = {
			{
				property = "pressure",
				min = 4000,
				max = 4000
			}
		},
	}
	,
	{
		type = "recipe",
		name = "new-spieces-demolisher-egg-medium-grow-recipe",
		result_is_always_fresh = true,
		category = "organic",
		subgroup = "agriculture-products",
		enabled = false,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "new-spieces-demolisher-egg-medium", amount = 10},
			{type = "item", name = "tungsten-ore", amount = 200},
			{type = "item", name = "calcite", amount = 200},
			{type = "item", name = "uranium-235", amount = 200},
			{type = "fluid", name = "lava", amount = 500},
			{type = "fluid", name = "sulfuric-acid", amount = 500},
		},
		results = {
			{type = "item", name = "new-spieces-demolisher-egg-big", amount = 1}
		},
		surface_conditions = {
			{
				property = "pressure",
				min = 4000,
				max = 4000
			}
		},
	}
	,
	{
		type = "recipe",
		name = "friend-demolisher-egg-medium-grow-recipe",
		result_is_always_fresh = true,
		category = "organic",
		subgroup = "agriculture-products",
		enabled = false,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "friend-demolisher-egg-medium", amount = 10},
			{type = "item", name = "tungsten-ore", amount = 200},
			{type = "item", name = "calcite", amount = 200},
			{type = "item", name = "uranium-235", amount = 200},
			{type = "fluid", name = "lava", amount = 500},
			{type = "fluid", name = "sulfuric-acid", amount = 500},
		},
		results = {
			{type = "item", name = "friend-demolisher-egg-big", amount = 1}
		},
		surface_conditions = {
			{
				property = "pressure",
				min = 4000,
				max = 4000
			}
		},
	}
	,
	{
		type = "item",
		name = "demolisher-egg-big",
		localised_name = {"item-name.demolisher-egg-big"},
		localised_description = {"item-description.demolisher-egg-big"},
		icon = "__BreedingDemolisher__/graphics/icon/demolisher_egg_big.png",
		icon_size = 64,
		subgroup = "raw-material",
		order = "c[cryogenics]-a[_013_demolisher-egg-big]",
		stack_size = 1,
		spoil_ticks = 90000, -- 鮮度の維持時間（秒）
		spoil_result = "spoilage", -- 腐敗後に変換されるアイテム
		weight = 1000000,
	}
	,
	{
		type = "item",
		name = "demolisher-egg-big-frozen",
		localised_name = {"item-name.demolisher-egg-big-frozen"},
		localised_description = {"item-description.demolisher-egg-big-frozen"},
		icon = "__BreedingDemolisher__/graphics/icon/demolisher_egg_big_frozen.png",
		icon_size = 64,
		subgroup = "raw-material",
		order = "c[cryogenics]-a[_113_demolisher-egg-big-frozen]",
		stack_size = 1,
		spoil_ticks = 1080000, -- 鮮度の維持時間（秒）
		spoil_result = "demolisher-egg-big", -- 腐敗後に変換されるアイテム
		weight = 1000000,
	}
	,
	{
		type = "item",
		name = "new-spieces-demolisher-egg-big",
		localised_name = {"item-name.new-spieces-demolisher-egg-big"},
		localised_description = {"item-description.new-spieces-demolisher-egg-big"},
		icon = "__BreedingDemolisher__/graphics/icon/new_spieces_demolisher_egg_big.png",
		icon_size = 64,
		subgroup = "raw-material",
		order = "c[cryogenics]-a[_023_new-spieces-demolisher-egg-big]",
		stack_size = 1,
		spoil_ticks = 90000, -- 鮮度の維持時間（秒）
		spoil_result = "spoilage", -- 腐敗後に変換されるアイテム
		weight = 1000000,
	}
	,
	{
		type = "item",
		name = "new-spieces-demolisher-egg-big-frozen",
		localised_name = {"item-name.new-spieces-demolisher-egg-big-frozen"},
		localised_description = {"item-description.new-spieces-demolisher-egg-big-frozen"},
		icon = "__BreedingDemolisher__/graphics/icon/new_spieces_demolisher_egg_big_frozen.png",
		icon_size = 64,
		subgroup = "raw-material",
		order = "c[cryogenics]-a[_123_new-spieces-demolisher-egg-big-frozen]",
		stack_size = 1,
		spoil_ticks = 1080000, -- 鮮度の維持時間（秒）
		spoil_result = "new-spieces-demolisher-egg-big", -- 腐敗後に変換されるアイテム
		weight = 1000000,
	}
	,
	{
		type = "item",
		name = "friend-demolisher-egg-big",
		localised_name = {"item-name.friend-demolisher-egg-big"},
		localised_description = {"item-description.friend-demolisher-egg-big"},
		icon = "__BreedingDemolisher__/graphics/icon/friend_demolisher_egg_big.png",
		icon_size = 64,
		subgroup = "raw-material",
		order = "c[cryogenics]-a[_033_friend-demolisher-egg-big]",
		stack_size = 1,
		spoil_ticks = 90000, -- 鮮度の維持時間（秒）
		spoil_result = "spoilage", -- 腐敗後に変換されるアイテム
		weight = 1000000,
	}
	,
	{
		type = "item",
		name = "friend-demolisher-egg-big-frozen",
		localised_name = {"item-name.friend-demolisher-egg-big-frozen"},
		localised_description = {"item-description.friend-demolisher-egg-big-frozen"},
		icon = "__BreedingDemolisher__/graphics/icon/friend_demolisher_egg_big_frozen.png",
		icon_size = 64,
		subgroup = "raw-material",
		order = "c[cryogenics]-a[_133_friend-demolisher-egg-big-frozen]",
		stack_size = 1,
		spoil_ticks = 1080000, -- 鮮度の維持時間（秒）
		spoil_result = "friend-demolisher-egg-big", -- 腐敗後に変換されるアイテム
		weight = 1000000,
	}
	,
	{
		type = "recipe",
		name = "new-spieces-demolisher-egg-big-recipe",
		result_is_always_fresh = true,
		category = "cryogenics",
		enabled = false,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "demolisher-egg-big", amount = 1},
			{type = "item", name = "captive-biter-spawner", amount = 10},
			{type = "item", name = "biochamber", amount = 20},
			{type = "item", name = "pentapod-egg", amount = 200},
			{type = "item", name = "biter-egg", amount = 200},
			{type = "fluid", name = "sulfuric-acid", amount = 200},
			{type = "fluid", name = "molten-iron", amount = 200},
			{type = "fluid", name = "fluoroketone-hot", amount = 200}
		},
		results = {
			{type = "item", name = "new-spieces-demolisher-egg-big", amount = 1}
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
		name = "demolisher-egg-big-freeze-recipe",
		result_is_always_fresh = true,
		category = "cryogenics",
		enabled = false,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "demolisher-egg-big", amount = 1},
			{type = "item", name = "captive-biter-spawner", amount = 10},
			{type = "item", name = "biochamber", amount = 20},
			{type = "fluid", name = "sulfuric-acid", amount = 200},
			{type = "fluid", name = "fluorine", amount = 200},
			{type = "fluid", name = "fluoroketone-cold", amount = 200}
		},
		results = {
			{type = "item", name = "demolisher-egg-big-frozen", amount = 1}
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
		name = "new-spieces-demolisher-egg-big-freeze-recipe",
		result_is_always_fresh = true,
		category = "cryogenics",
		enabled = false,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "demolisher-egg-big", amount = 1},
			{type = "item", name = "captive-biter-spawner", amount = 10},
			{type = "item", name = "biochamber", amount = 20},
			{type = "fluid", name = "sulfuric-acid", amount = 200},
			{type = "fluid", name = "fluorine", amount = 200},
			{type = "fluid", name = "fluoroketone-cold", amount = 200}
		},
		results = {
			{type = "item", name = "new-spieces-demolisher-egg-big-frozen", amount = 1}
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
		name = "friend-demolisher-egg-big-freeze-recipe",
		result_is_always_fresh = true,
		category = "cryogenics",
		enabled = false,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "demolisher-egg-big", amount = 1},
			{type = "item", name = "captive-biter-spawner", amount = 10},
			{type = "item", name = "biochamber", amount = 20},
			{type = "fluid", name = "sulfuric-acid", amount = 200},
			{type = "fluid", name = "fluorine", amount = 200},
			{type = "fluid", name = "fluoroketone-cold", amount = 200}
		},
		results = {
			{type = "item", name = "friend-demolisher-egg-big-frozen", amount = 1}
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
		name = "demolisher-egg-big-unfreeze-recipe",
		result_is_always_fresh = true,
		category = "cryogenics",
		enabled = false,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "demolisher-egg-big-frozen", amount = 1},
			{type = "item", name = "captive-biter-spawner", amount = 10},
			{type = "item", name = "biochamber", amount = 20},
			{type = "fluid", name = "sulfuric-acid", amount = 200},
			{type = "fluid", name = "fluorine", amount = 200},
			{type = "fluid", name = "fluoroketone-cold", amount = 200}
		},
		results = {
			{type = "item", name = "demolisher-egg-big", amount = 1}
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
		name = "new-spieces-demolisher-egg-big-unfreeze-recipe",
		result_is_always_fresh = true,
		category = "cryogenics",
		enabled = false,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "new-spieces-demolisher-egg-big-frozen", amount = 1},
			{type = "item", name = "captive-biter-spawner", amount = 10},
			{type = "item", name = "biochamber", amount = 20},
			{type = "fluid", name = "sulfuric-acid", amount = 200},
			{type = "fluid", name = "fluorine", amount = 200},
			{type = "fluid", name = "fluoroketone-cold", amount = 200}
		},
		results = {
			{type = "item", name = "new-spieces-demolisher-egg-big", amount = 1}
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
		name = "friend-demolisher-egg-big-unfreeze-recipe",
		result_is_always_fresh = true,
		category = "cryogenics",
		enabled = false,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "friend-demolisher-egg-big-frozen", amount = 1},
			{type = "item", name = "captive-biter-spawner", amount = 10},
			{type = "item", name = "biochamber", amount = 20},
			{type = "fluid", name = "sulfuric-acid", amount = 200},
			{type = "fluid", name = "fluorine", amount = 200},
			{type = "fluid", name = "fluoroketone-cold", amount = 200}
		},
		results = {
			{type = "item", name = "friend-demolisher-egg-big", amount = 1}
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
		icon_size = 64,
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
	}
	,
	{
		type = "technology",
		name = "demolisher-egg-freeze",
		icon_size = 64,
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
	}
	,
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
	}
	,
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
		icon_size = 64,
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
		icon = "__BreedingDemolisher__/graphics/icon/genetic-analysis-machine.png",
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
        icon = "__BreedingDemolisher__/graphics/icon/genetic-analysis-machine.png",
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
	}
	,
    {
        type = "custom-input",
        name = "on_breeding_demolisher_mouse_button_2",
        key_sequence = "mouse-button-2", -- 右クリック
		consuming = "none" -- イベントを消費しない
    }
})