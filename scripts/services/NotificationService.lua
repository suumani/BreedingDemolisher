-- __BreedingDemolisher__/scripts/services/NotificationService.lua
-- ----------------------------
-- Responsibility:
--   Centralized user-facing notifications (localized).
-- ----------------------------
local util = require("scripts.common.util")

local N = {}

local function pos_text(pos)
  return ("(%d,%d)"):format(math.floor(pos.x), math.floor(pos.y))
end

function N.breeding_egg_laid(surface, pos)
  util.print({
    "bd.message.breeding_egg_laid",
    tostring(surface.name),
    pos_text(pos)
  })
end

function N.pet_killed(surface, pos, pet_id)
  util.print({
    "bd.message.pet_killed",
    tostring(surface.name),
    pos_text(pos),
    tostring(pet_id or "")
  })
end

function N.egg_drop_generic(surface, pos)
  util.print({
    "bd.message.egg_drop_generic",
    tostring(surface.name),
    pos_text(pos)
  })
end

function N.egg_drop_pet(surface, pos)
  util.print({
    "bd.message.egg_drop_pet",
    tostring(surface.name),
    pos_text(pos)
  })
end

return N