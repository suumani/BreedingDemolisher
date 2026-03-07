-- __BreedingDemolisher__/scripts/services/StorageInitializer.lua
-- ------------------------------------------------------------
-- Responsibility:
--   init() 時に必要な storage の初期化を行う。
--
-- Scope:
--   - pet state 用 storage 初期化
--   - bd root / runtime root 初期化
--   - pet destroyed registration mapping 初期化
-- ------------------------------------------------------------
local StorageInitializer = {}

function StorageInitializer.init_all()
  storage.my_demolishers = storage.my_demolishers or {}

  storage.bd = storage.bd or {}
  storage.bd.runtime = storage.bd.runtime or {}

  -- register_on_object_destroyed の registration_number -> pet_id 対応
  storage.bd.pet_destroy_reg_to_pet_id = storage.bd.pet_destroy_reg_to_pet_id or {}

  -- pet_id -> registration_number 対応
  storage.bd.pet_id_to_destroy_reg = storage.bd.pet_id_to_destroy_reg or {}
end

return StorageInitializer