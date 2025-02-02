local function get_shifted_underground_pipe_picture(direction, shift)
	local underground_pipe_pictures = data.raw["pipe-to-ground"]["pipe-to-ground"].pictures
	local picture = table.deepcopy(underground_pipe_pictures[direction])
	picture.shift = shift
	return picture
end
data:extend({
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
})