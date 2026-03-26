-- __BreedingDemolisher__/scripts/boundary/bootstrap/ForceBootstrap.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Breeding Demolisher の force 関連 bootstrap を担当する。
--   - "demolishers" force が未作成なら作成する。
--   - bootstrap 時に demolishers と player / enemy / neutral の関係を設定する。
-- ------------------------------------------------------------
local ForceBootstrap = {}

local Logger = require("scripts.infrastructure.logging.Logger")

local DEMOLISHERS_FORCE_NAME = "demolishers"

local function get_or_create_demolishers_force()
  local force = game.forces[DEMOLISHERS_FORCE_NAME]
  if force ~= nil then
    return force, false
  end

  force = game.create_force(DEMOLISHERS_FORCE_NAME)
  return force, true
end

local function apply_force_relations(force)
  force.set_cease_fire("player", false)
  force.set_cease_fire("enemy", false)
  force.set_cease_fire("neutral", true)
end

function ForceBootstrap.bootstrap()
  local demolishers_force, created = get_or_create_demolishers_force()
  apply_force_relations(demolishers_force)

  if created == true then
    Logger.info({
      event = "FORCE_INITIALIZED",
      force_name = DEMOLISHERS_FORCE_NAME,
    })
  end
end

return ForceBootstrap