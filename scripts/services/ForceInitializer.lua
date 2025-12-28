-- scripts/services/ForceInitializer.lua
-- ----------------------------
-- Responsibility:
--   Modが必要とする force を作成し、敵対関係を設定する。
--   現行仕様では "demolishers" force を作り、player/enemy と敵対、neutral と停戦にする。
-- ----------------------------
local util  = require("scripts.common.util")

local F = {}

function F.ensure_demolishers_force()
  if not game.forces["demolishers"] then
    local new_force = game.create_force("demolishers")
    -- 敵対関係の設定
    new_force.set_cease_fire("player", false)  -- プレイヤーと敵対
    new_force.set_cease_fire("enemy", false)   -- バイターと敵対
    new_force.set_cease_fire("neutral", true)  -- 中立と停戦
    util.print("[mod:BreedingDemolisher] initialize forces")
  end
end

return F