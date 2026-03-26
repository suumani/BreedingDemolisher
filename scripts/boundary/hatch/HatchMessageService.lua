-- __BreedingDemolisher__/scripts/boundary/hatch/HatchMessageService.lua
-- ------------------------------------------------------------
-- Responsibility:
--   hatch / shatter メッセージの出力を統一する。
--   - shattered メッセージを出力する。
--   - hatched メッセージを出力する。
-- ------------------------------------------------------------
local HatchMessageService = {}

local util = require("scripts.common.util")

function HatchMessageService.shattered()
  util.print("shattered...")
end

function HatchMessageService.hatched(genes_id)
  if genes_id ~= nil then
    util.print("Hatched (genetic: " .. tostring(genes_id) .. ")")
  else
    util.print("Hatched (wild)")
  end
end

return HatchMessageService