-- __BreedingDemolisher__/scripts/core/DeferredInitializer.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Breeding Demolisher の遅延初期化を担当する。
--   - load 後に再構築すべき runtime 側初期化を行う。
--   - TJC gateway の bootstrap を行う。
-- ------------------------------------------------------------
local DeferredInitializer = {}

local StorageBootstrap = require("scripts.boundary.bootstrap.StorageBootstrap")
local BreedingDemolisherTjcGateway = require("scripts.boundary.tjc.BreedingDemolisherTjcGateway")

function DeferredInitializer.run()
  BreedingDemolisherTjcGateway.bootstrap()
end

return DeferredInitializer