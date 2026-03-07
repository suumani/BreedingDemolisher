-- __BreedingDemolisher__/scripts/services/SaveRestoreService.lua
-- ------------------------------------------------------------
-- Responsibility:
--   on_load 時に、保存済みデータ構造の metatable（Customparam）を復元する。
--
-- Scope:
--   - storage.my_demolishers[*].customparam 復元
--   - storage.bd_genes[*].customparam 復元
--
-- Notes:
--   - nil/欠落は黙って補修しない
--   - Customparam は control.lua 側で require 済み前提
-- ------------------------------------------------------------
local SaveRestoreService = {}

local function restore_customparam_metatable_from_list(data_list)
  for _, item in pairs(data_list) do
    if item and type(item) == "table" then
      if item.customparam and type(item.customparam) == "table" and getmetatable(item.customparam) == nil then
        setmetatable(item.customparam, Customparam)
      end
    end
  end
end

local function restore_customparam_metatable_from_map(data_map)
  for _, item in pairs(data_map) do
    if item and type(item) == "table" then
      if item.customparam and type(item.customparam) == "table" and getmetatable(item.customparam) == nil then
        setmetatable(item.customparam, Customparam)
      end
    end
  end
end

function SaveRestoreService.on_load_restore()
  if storage.my_demolishers then
    restore_customparam_metatable_from_list(storage.my_demolishers)
  end

  if storage.bd_genes then
    restore_customparam_metatable_from_map(storage.bd_genes)
  end
end

return SaveRestoreService