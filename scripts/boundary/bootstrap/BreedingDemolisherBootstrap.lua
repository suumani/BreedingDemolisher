-- __BreedingDemolisher__/scripts/boundary/bootstrap/BreedingDemolisherBootstrap.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Breeding Demolisher の control stage bootstrap 手順を統括する。
--   - full bootstrap を実行する。
--   - load bootstrap を実行する。
--   - 個別 bootstrap 処理の実装詳細は下位クラスへ委譲する。
-- ------------------------------------------------------------
local BreedingDemolisherBootstrap = {}

local DeterministicRandom = require("scripts.core.services.DeterministicRandom")
local ForceBootstrap = require("scripts.boundary.bootstrap.ForceBootstrap")
local StorageBootstrap = require("scripts.boundary.bootstrap.StorageBootstrap")
local BreedingDemolisherTjcGateway = require("scripts.boundary.tjc.BreedingDemolisherTjcGateway")

function BreedingDemolisherBootstrap.run_full_bootstrap()
  DeterministicRandom.init()
  StorageBootstrap.bootstrap()
  ForceBootstrap.bootstrap()
  BreedingDemolisherTjcGateway.bootstrap()
end

function BreedingDemolisherBootstrap.run_load_bootstrap()
  BreedingDemolisherTjcGateway.bootstrap()
end

return BreedingDemolisherBootstrap