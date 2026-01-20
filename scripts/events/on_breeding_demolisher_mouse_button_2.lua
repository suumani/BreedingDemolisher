-- __BreedingDemolisher__/scripts/events/on_breeding_demolisher_mouse_button_2.lua
-- ----------------------------
-- Responsibility:
--   Bind custom input event to EggThrowHatchService.
-- ----------------------------
local EggThrowHatchService = require("scripts.services.EggThrowHatchService")

script.on_event("on_breeding_demolisher_mouse_button_2", function(event)
  EggThrowHatchService.handle(event)
end)