require("prototypes.demolisher-eggs")
require("prototypes.genetic-analysis-machine")


data:extend({
    {
        type = "custom-input",
        name = "on_breeding_demolisher_mouse_button_2",
        key_sequence = "mouse-button-2", -- 右クリック
		consuming = "none" -- イベントを消費しない
    }
	,
    {
        type = "custom-input",
        name = "on_insert_ammo_to_turrets",
        key_sequence = "I",
        consuming = "none" -- イベントを消費しない
    }
})