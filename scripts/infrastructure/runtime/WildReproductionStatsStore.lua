-- __BreedingDemolisher__/scripts/infrastructure/runtime/WildReproductionStatsStore.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Wild Reproduction の30分統計を storage 上で管理する。
--   - 孵化成功件数の加算を行う。
--   - 現在件数の取得を行う。
--   - 30分表示後のリセットを行う。
--
-- Notes:
--   - 対象は enemy の wild reproduction で実際に spawn 成功した件数のみ。
--   - storage schema 自体の成立は StorageBootstrap が担当する。
-- ------------------------------------------------------------
local WildReproductionStatsStore = {}

local function get_stats_root()
  if storage == nil then
    error("WildReproductionStatsStore: storage is not available")
  end
  if storage.bd == nil then
    error("WildReproductionStatsStore: storage.bd is nil. Call StorageBootstrap.bootstrap() before use.")
  end

  storage.bd.wild_reproduction_stats = storage.bd.wild_reproduction_stats or {}
  storage.bd.wild_reproduction_stats.hatched_count = storage.bd.wild_reproduction_stats.hatched_count or 0

  return storage.bd.wild_reproduction_stats
end

--- add
--- Responsibility:
---   孵化成功件数を加算する。
--- @param count integer
function WildReproductionStatsStore.add(count)
  if type(count) ~= "number" then
    error("WildReproductionStatsStore.add: count must be a number")
  end
  if count < 0 then
    error("WildReproductionStatsStore.add: count must be >= 0")
  end

  local stats = get_stats_root()
  stats.hatched_count = stats.hatched_count + count
end

--- get_count
--- Responsibility:
---   現在の30分窓の孵化成功件数を返す。
--- @return integer
function WildReproductionStatsStore.get_count()
  local stats = get_stats_root()
  return stats.hatched_count
end

--- reset
--- Responsibility:
---   30分窓の孵化成功件数を0へ戻す。
function WildReproductionStatsStore.reset()
  local stats = get_stats_root()
  stats.hatched_count = 0
end

return WildReproductionStatsStore