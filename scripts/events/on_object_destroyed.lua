-- __BreedingDemolisher__/scripts/events/on_object_destroyed.lua
-- ------------------------------------------------------------
-- Responsibility:
--   register_on_object_destroyed により登録された pet demolisher の
--   destroy 通知を受け、pet 死亡処理を行う。
--
-- Scope:
--   - registration_number -> pet_id 解決
--   - pet killed notification
--   - storage.my_demolishers からの削除
--   - destroyed registration mapping の掃除
--   - event boundary protection by pcall
--
-- Notes:
--   - on_entity_died の代替として pet 死亡を扱う。
--   - old egg drop / old respawn は扱わない。
--   - pcall は event boundary にのみ配置し、失敗は Logger へ明示記録する。
--   - storage shape は bootstrap 済み前提で扱い、この境界では自動生成しない。
-- ------------------------------------------------------------
local NotificationService = require("scripts.boundary.notification.NotificationService")
local Logger = require("scripts.infrastructure.logging.Logger")

local function expect_destroy_storage()
  if storage == nil then
    error("on_object_destroyed: storage is nil")
  end
  if storage.bd == nil then
    error("on_object_destroyed: storage.bd is nil. Call StorageBootstrap.bootstrap() first.")
  end
  if storage.bd.pet_destroy_reg_to_pet_id == nil then
    error("on_object_destroyed: storage.bd.pet_destroy_reg_to_pet_id is nil. Call StorageBootstrap.bootstrap() first.")
  end
  if storage.bd.pet_id_to_destroy_reg == nil then
    error("on_object_destroyed: storage.bd.pet_id_to_destroy_reg is nil. Call StorageBootstrap.bootstrap() first.")
  end
  if storage.my_demolishers == nil then
    error("on_object_destroyed: storage.my_demolishers is nil. Call StorageBootstrap.bootstrap() first.")
  end
end

local function resolve_pet_by_id(pet_id)
  local pets = storage.my_demolishers
  for _, pet in ipairs(pets) do
    if pet and pet.pet_id == pet_id then
      return pet
    end
  end
  return nil
end

local function remove_pet_from_storage(pet_id)
  local pets = storage.my_demolishers
  for i = #pets, 1, -1 do
    local pet = pets[i]
    if pet and pet.pet_id == pet_id then
      table.remove(pets, i)
      return pet
    end
  end
  return nil
end

local function cleanup_destroy_mapping(registration_number, pet_id)
  storage.bd.pet_destroy_reg_to_pet_id[registration_number] = nil
  if pet_id ~= nil then
    storage.bd.pet_id_to_destroy_reg[pet_id] = nil
  end
end

local function on_object_destroyed_handler(event)
  expect_destroy_storage()

  local registration_number = event.registration_number
  local pet_id = storage.bd.pet_destroy_reg_to_pet_id[registration_number]
  if pet_id == nil then
    return
  end

  local pet = resolve_pet_by_id(pet_id)
  if pet ~= nil and pet.home_surface_name ~= nil and pet.home_pos ~= nil then
    local surface = game.surfaces[pet.home_surface_name]
    if surface ~= nil then
      NotificationService.pet_killed(surface, pet.home_pos, pet_id)
    end
  end

  remove_pet_from_storage(pet_id)
  cleanup_destroy_mapping(registration_number, pet_id)
end

script.on_event(defines.events.on_object_destroyed, function(event)
  local ok, err = pcall(on_object_destroyed_handler, event)
  if not ok then
    Logger.error({
      event = "ON_OBJECT_DESTROYED_FAILED",
      error = tostring(err),
      tick = game and game.tick or nil,
      registration_number = event and event.registration_number or nil,
    })
  end
end)