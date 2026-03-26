-- __BreedingDemolisher__/scripts/domain/pet/PetIdentityService.lua
-- ------------------------------------------------------------
-- Responsibility:
--   demolisher entity から pet identity を解決する。
--   - 第一優先で entity 参照一致により解決する。
--   - 次に linked_unit_number により解決する。
--   - link 消失時は home 近傍により relink を試みる。
--
-- Notes:
--   - pet_id が stable identity である。
--   - linked_unit_number は変化しうるため、真の identity として扱わない。
--   - storage shape は bootstrap 済み前提で扱い、このクラスでは自動生成しない。
-- ------------------------------------------------------------
local PetIdentityService = {}

local RELINK_RADIUS_TILES = 80

local function sqr(x)
  return x * x
end

local function expect_storage()
  if storage == nil then
    error("PetIdentityService: storage is nil")
  end
  if storage.my_demolishers == nil then
    error("PetIdentityService: storage.my_demolishers is nil. Call StorageBootstrap.bootstrap() first.")
  end
end

local function find_by_entity_ref(entity)
  if not (entity and entity.valid) then
    return nil
  end

  for _, pet in pairs(storage.my_demolishers) do
    local cp = pet.customparam
    local e = cp and cp.entity
    if e and e.valid and e == entity then
      return pet
    end
  end

  return nil
end

local function find_by_linked_unit_number(entity)
  if not (entity and entity.valid and entity.unit_number) then
    return nil
  end

  for _, pet in pairs(storage.my_demolishers) do
    if pet.linked_unit_number == entity.unit_number then
      return pet
    end
  end

  return nil
end

local function relink_by_home(entity)
  if not (entity and entity.valid) then
    return nil
  end

  expect_storage()

  local sx = entity.position.x
  local sy = entity.position.y
  local surf_name = entity.surface.name
  local r2 = sqr(RELINK_RADIUS_TILES)

  for _, pet in pairs(storage.my_demolishers) do
    if pet.home_surface_name == surf_name and pet.home_pos then
      local dx = sx - pet.home_pos.x
      local dy = sy - pet.home_pos.y
      if (dx * dx + dy * dy) <= r2 then
        pet.linked_unit_number = entity.unit_number
        if pet.customparam then
          pet.customparam.entity = entity
        end
        return pet
      end
    end
  end

  return nil
end

function PetIdentityService.resolve(entity)
  expect_storage()

  local pet = find_by_entity_ref(entity)
  if pet then
    return pet
  end

  pet = find_by_linked_unit_number(entity)
  if pet then
    if pet.customparam then
      pet.customparam.entity = entity
    end
    return pet
  end

  return relink_by_home(entity)
end

return PetIdentityService