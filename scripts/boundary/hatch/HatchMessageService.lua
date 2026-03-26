-- __BreedingDemolisher__/scripts/boundary/hatch/HatchMessageService.lua
-- ------------------------------------------------------------
-- Responsibility:
--   hatch / shatter メッセージの出力を統一する。
--   - shattered メッセージを出力する。
--   - hatched メッセージを出力する。
-- ------------------------------------------------------------
local HatchMessageService = {}

function HatchMessageService.shattered()
  game.print("shattered...")
end

function HatchMessageService.hatched(genes_id)
  if genes_id ~= nil then
    game.print("Hatched (genetic: " .. tostring(genes_id) .. ")")
  else
    game.print("Hatched (wild)")
  end
end

return HatchMessageService