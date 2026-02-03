-- __BreedingDemolisher__/scripts/services/Logger.lua
-- ----------------------------
-- Responsibility:
--   Logging facade for BreedingDemolisher.
--   - Uses Manis_Logger via remote interface when available.
--   - Falls back to Factorio log() when Manis_Logger is not installed.
-- ----------------------------
local L = {}

local TAG = "BreedingDemolisher"
local SOURCE_KEY = "breedingdemolisher"

local function call_remote(level, msg, player_index)
  if remote.interfaces["manis_logger"] then
    remote.call("manis_logger", level, TAG, msg, player_index, SOURCE_KEY)
    return true
  end
  return false
end

local function fallback(level, msg)
  log("[" .. TAG .. "][" .. string.upper(level) .. "] " .. serpent.line(msg))
end

local function emit(level, msg, player_index)
  if not call_remote(level, msg, player_index) then
    fallback(level, msg)
  end
end

function L.debug(msg, player_index) emit("debug", msg, player_index) end
function L.info(msg, player_index)  emit("info",  msg, player_index) end
function L.warn(msg, player_index)  emit("warn",  msg, player_index) end
function L.error(msg, player_index) emit("error", msg, player_index) end

return L