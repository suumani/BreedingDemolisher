-- __BreedingDemolisher__/scripts/services/DemolisherSelector.lua
-- ----------------------------
-- Responsibility:
--   指定surface上のデモリッシャーを取得し、品質(normal / non-normal)で分離して返す。
--   取得対象のエンティティ名セット（DemolisherNames.LIST）の知識をこのモジュールに閉じる。
-- ----------------------------
local Selector = {}

local DemolisherQuery = require("__Manis_lib__/scripts/queries/DemolisherQuery")

function Selector.split_by_quality(surface)
  local all = DemolisherQuery.find_all_demolishers(surface)

  local normal = {}
  local unnormal = {}

  for _, entity in pairs(all) do
    if entity.quality.name == "normal" then
      table.insert(normal, entity)
    else
      table.insert(unnormal, entity)
    end
  end

  return {
    all = all,
    normal = normal,
    unnormal = unnormal
  }
end

return Selector