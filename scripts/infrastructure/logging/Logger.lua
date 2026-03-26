-- __BreedingDemolisher__/scripts/infrastructure/logging/Logger.lua
-- ------------------------------------------------------------
-- 責務:
--   BreedingDemolisher 用の Logger ファサード。
--   - 本Modの TAG と SOURCE_KEY を固定する。
--   - debug / info / warn / error の呼び出しを Manis_Logger に委譲する。
--
-- 対象範囲:
--   - Manis_Logger への remote 委譲のみを行う。
--   - 本Mod内で log() / game.print() / game.write_file() を直接呼び出さない。
--
-- 補足:
--   - 本クラスはパターン①（委譲型 Logger）である。
--   - 本Mod側に runtime-global の logger 設定が存在する場合、
--       <source_key>-logger-*
--     形式のキーを Manis_Logger 側が参照する。
--   - 本Mod側に設定が存在しない場合は、
--     Manis_Logger の共通設定（manis-logger-*）が使用される。
--   - 本クラスは設定の有無を判定しない。
--   - Manis_Logger が利用できない場合、本クラスは何も出力しない。
-- ------------------------------------------------------------

local L = {}

local TAG = "BreedingDemolisher"
local SOURCE_KEY = "breedingdemolisher"

local function can_use_remote()
  return remote
    and remote.interfaces
    and remote.interfaces["manis_logger"] ~= nil
end

local function emit(level, msg, player_index)
  if not can_use_remote() then
    return
  end

  remote.call("manis_logger", level, TAG, msg, player_index, SOURCE_KEY)
end

function L.debug(msg, player_index)
  emit("debug", msg, player_index)
end

function L.info(msg, player_index)
  emit("info", msg, player_index)
end

function L.warn(msg, player_index)
  emit("warn", msg, player_index)
end

function L.error(msg, player_index)
  emit("error", msg, player_index)
end

return L