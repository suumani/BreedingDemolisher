-- __BreedingDemolisher__/scripts/services/HatchMessageService.lua
-- ----------------------------
-- Responsibility:
--   Print consistent hatch/shatter messages.
-- ----------------------------
local M = {}

function M.shattered()
  game_print.message("shattered...")
end

function M.hatched(genes_id)
  if genes_id ~= nil then
    game_print.message("Hatched (genetic: " .. tostring(genes_id) .. ")")
  else
    game_print.message("Hatched (wild)")
  end
end

return M
