-- scripts/util/TableUtil.lua
--[[
責務:
  Luaテーブルのキー数を数えるユーティリティを提供する。
  グローバル汚染を避け、require経由で利用する。
--]]
local TableUtil = {}

function TableUtil.count_keys(tbl)
  local count = 0
  for _ in pairs(tbl) do
    count = count + 1
  end
  return count
end

return TableUtil