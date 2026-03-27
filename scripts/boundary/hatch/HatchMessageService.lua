-- __BreedingDemolisher__/scripts/boundary/hatch/HatchMessageService.lua
-- ------------------------------------------------------------
-- Responsibility:
--   hatch / shatter メッセージの出力を統一する。
--   - shattered メッセージを出力する。
--   - hatched メッセージを出力する。
-- ------------------------------------------------------------
local HatchMessageService = {}

function HatchMessageService.shattered()
  game.print({ "bd.message.hatch_shattered" })
end

function HatchMessageService.hatched(genes_id)
  if genes_id ~= nil then
    game.print({ "bd.message.hatch_hatched_with_genes", tostring(genes_id) })
  else
    game.print({ "bd.message.hatch_hatched_unknown_genes" })
  end
end

return HatchMessageService