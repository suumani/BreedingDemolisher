-- __BreedingDemolisher__/scripts/domain/pet/DemolisherDefaultNameService.lua
-- ------------------------------------------------------------
-- Responsibility:
--   entity から Demolisher の default name を決定する。
--   - surface / size class / quality / unit_number を用いた命名規則を一元管理する。
--
-- Scope:
--   - entity=nil 時の扱い
--   - BIG / MEDIUM / SMALL / unknown の表現
--   - quality 表現
--   - unit_number 表現
--
-- Out of scope:
--   - 個体状態生成
--   - 乱数生成
--   - genetics
-- ------------------------------------------------------------
local DemolisherDefaultNameService = {}

local DemolisherNames = require("__Manis_definitions__/scripts/definition/DemolisherNames")

function DemolisherDefaultNameService.resolve(entity)
  if entity == nil then
    return "unknown"
  end

  local name = ""
  name = entity.surface.name

  if entity.name == DemolisherNames.BIG then
    name = name .. "_" .. "S"
  elseif entity.name == DemolisherNames.MEDIUM then
    name = name .. "_" .. "A"
  elseif entity.name == DemolisherNames.SMALL then
    name = name .. "_" .. "B"
  else
    name = name .. "_" .. "U"
  end

  if entity.quality == "legendary" then
    name = name .. "++"
  elseif entity.quality == "epic" then
    name = name .. "+"
  elseif entity.quality == "rare" then
    name = name .. ""
  elseif entity.quality == "uncommon" then
    name = name .. "-"
  else
    name = name .. "--"
  end

  name = name .. "型_#" .. entity.unit_number
  return name
end

return DemolisherDefaultNameService