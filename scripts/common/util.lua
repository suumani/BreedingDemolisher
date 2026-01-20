-- __BreedingDemolisher__/scripts/common/util.lua

-- ----------------------------
-- Responsibility:
--   Common print utilities for user messages and debug logs.
--   Supports both plain strings and LocalisedString ({"key", ...}).
-- ----------------------------

local util = {}

-- デバッグ出力フラグ（本番では false）
util.DEBUG_ENABLED = false

local function do_print(msg)
  if game and msg ~= nil then
    game.print(msg) -- msg can be string OR LocalisedString table
  end
end

function util.print(msg)
  do_print(msg)
end

function util.debug(msg)
  if not util.DEBUG_ENABLED then return end
  if type(msg) == "string" then
    do_print("[debug] " .. msg)
  else
    do_print(msg)
  end
end

return util