--__BreedingDemolisher__/data.lua
require("prototypes.init")

require("prototypes.genetic-analysis-machine")


data:extend({
    {
        type = "custom-input",
        name = "on_breeding_demolisher_mouse_button_2",
        key_sequence = "mouse-button-2", -- 右クリック
		consuming = "none" -- イベントを消費しない
    }
})