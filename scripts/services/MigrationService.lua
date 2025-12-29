-- __BreedingDemolisher__/scripts/services/MigrationService.lua
-- ----------------------------
-- Responsibility:
--   旧セーブデータ/旧storage構造から新構造への移行を実行する。
-- ----------------------------
local M = {}

local DemolisherQuery = require("__Manis_lib__/scripts/queries/DemolisherQuery")


local function find_demolisher_entity(all_demolishers, unit_number)
  for _, value in pairs(all_demolishers) do
    if value.unit_number == unit_number then
      return value
    end
  end
  return nil
end

-- new_vulcanus_demolishers / new_fulgora_demolishers の構造互換を維持する
-- tbl[entity.unit_number] = { entity = entity, life = nil }
local function register_new_wild_demolisher(tbl, entity)
  if tbl[entity.unit_number] == nil then
    tbl[entity.unit_number] = { entity = entity, life = nil }
  else
    -- 既存がある場合は entity 参照だけ更新（life は今後使わない前提）
    tbl[entity.unit_number].entity = entity
  end
end

return M