-- __BreedingDemolisher__/scripts/core/ImmediateInitializer.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Breeding Demolisher の即時初期化を担当する。
--   - persistent storage schema を成立させる。
--   - force/bootstrap 系の即時初期化を行う。
--   - deterministic random の初期化を行う。
--
-- Notes:
--   - storage を変更する責務はこの層に置く。
--   - on_load からは呼ばない。
-- ------------------------------------------------------------
local ImmediateInitializer = {}

local DeterministicRandom = require("scripts.core.services.DeterministicRandom")
local ForceBootstrap = require("scripts.boundary.bootstrap.ForceBootstrap")
local StorageBootstrap = require("scripts.boundary.bootstrap.StorageBootstrap")

function ImmediateInitializer.run()
    StorageBootstrap.bootstrap()
    DeterministicRandom.init()
    ForceBootstrap.bootstrap()
end

return ImmediateInitializer