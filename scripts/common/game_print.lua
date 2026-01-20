-- __BreedingDemolisher__/scripts/common/game_print.lua

-- game_print compatibility bridge
local util = require("scripts.common.util")

game_print = game_print or {}

game_print.debug = function(msg)
  util.debug(msg)
end

game_print.message = function(msg)
  util.print(msg)
end