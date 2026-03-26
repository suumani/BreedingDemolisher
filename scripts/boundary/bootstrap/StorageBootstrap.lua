-- __BreedingDemolisher__/scripts/boundary/bootstrap/StorageBootstrap.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Breeding Demolisher の storage 関連 bootstrap を担当する。
--   - pet state 用 storage を初期化する。
--   - bd root / runtime root を初期化する。
--   - pet destroyed registration mapping を初期化する。
--   - pet id sequence を初期化する。
--   - pet chart job queue を初期化する。
--   - egg genes store 用 storage を初期化する。
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
end

return StorageBootstrap