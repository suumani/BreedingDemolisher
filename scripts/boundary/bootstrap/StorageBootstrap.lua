-- __BreedingDemolisher__/scripts/boundary/bootstrap/StorageBootstrap.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Breeding Demolisher の persistent storage schema を成立させる。
--   - pet state 用 storage を初期化する。
--   - bd root / runtime root を初期化する。
--   - pet destroyed registration mapping を初期化する。
--   - pet id sequence を初期化する。
--   - pet chart job queue を初期化する。
--   - egg genes store 用 storage を初期化する。
--   - wild reproduction 30分統計領域を初期化する。
--   - delayed wild respawn queue を初期化する。
--
-- Notes:
--   - このクラスは persistent schema の成立責務のみを持つ。
--   - runtime-only な再登録や event 接続は扱わない。
-- ------------------------------------------------------------
local StorageBootstrap = {}

function StorageBootstrap.bootstrap()
  storage.my_demolishers = storage.my_demolishers or {}
  storage.bd_next_pet_id = storage.bd_next_pet_id or 1
  storage.bd_pet_chart_jobs = storage.bd_pet_chart_jobs or {}

  storage.bd_genes = storage.bd_genes or {}
  storage.bd_next_genes_seq = storage.bd_next_genes_seq or 1

  storage.bd = storage.bd or {}
  storage.bd.runtime = storage.bd.runtime or {}

  storage.bd.pet_destroy_reg_to_pet_id = storage.bd.pet_destroy_reg_to_pet_id or {}
  storage.bd.pet_id_to_destroy_reg = storage.bd.pet_id_to_destroy_reg or {}

  storage.bd.wild_reproduction_stats = storage.bd.wild_reproduction_stats or {}
  storage.bd.wild_reproduction_stats.hatched_count = storage.bd.wild_reproduction_stats.hatched_count or 0

  storage.bd.delayed_wild_respawn_queue = storage.bd.delayed_wild_respawn_queue or {}
end

return StorageBootstrap