-- scripts/services/SaveRestoreService.lua
-- ----------------------------
-- Responsibility:
--   on_load 時に、保存済みデータ構造の metatable（Customparam）を復元する。
--   storage 構造の形は既存仕様を踏襲し、nil/欠落はそのまま（握りつぶさない方針に合わせる）。
-- ----------------------------
local S = {}

-- Customparam は control.lua 側で require("scripts.common.customparam") 済み前提
-- （＝Customparam がグローバルに存在する設計を踏襲）
local function restore_customparam_metatable(data_table)
  for _, item in pairs(data_table) do
    if item and type(item) == "table" then
      if item.customparam and type(item.customparam) == "table" and getmetatable(item.customparam) == nil then
        setmetatable(item.customparam, Customparam)
      end
    end
  end
end

function S.on_load_restore()
  -- my_demolishers
  if storage.my_demolishers then
    restore_customparam_metatable(storage.my_demolishers)
  end

  -- my_eggs: 3次元
  if storage.my_eggs then
    for _, demolisher_quality_list in pairs(storage.my_eggs) do
      for _, demolisher_egg_list in pairs(demolisher_quality_list) do
        for _, egg in pairs(demolisher_egg_list) do
          if egg.customparam and type(egg.customparam) == "table" and getmetatable(egg.customparam) == nil then
            setmetatable(egg.customparam, Customparam)
          end
        end
      end
    end
  end
end

return S