-- __BreedingDemolisher__/scripts/services/PetIdentityService.lua
-- ----------------------------
-- Responsibility:
--   Resolve pet identity for demolishers.
--   - Primary: entity reference equality (best during selection/hover)
--   - Secondary: linked_unit_number (legacy bridge)
--   - Recovery: relink by home proximity when link is lost
-- Notes:
--   - pet_id is the stable identity.
--   - linked_unit_number may change; do not treat it as truth.
-- ----------------------------

local S = {}

-- Tunables (can be promoted to config later)
local RELINK_RADIUS_TILES = 80  -- small radius for "near home" relink (tiles)

local function sqr(x) return x * x end

local function ensure_storage()
  storage.my_demolishers = storage.my_demolishers or {}
end

-- Find by entity reference (strongest signal)
local function find_by_entity_ref(entity)
  if not (entity and entity.valid) then return nil end
  for _, pet in pairs(storage.my_demolishers) do
    local cp = pet.customparam
    if cp and cp.get_entity then
      local e = cp:get_entity()
      if e and e.valid and e == entity then
        return pet
      end
    end
  end
  return nil
end

-- Find by linked_unit_number (legacy bridge)
local function find_by_linked_unit_number(entity)
  if not (entity and entity.valid and entity.unit_number) then return nil end
  for _, pet in pairs(storage.my_demolishers) do
    if pet.linked_unit_number == entity.unit_number then
      return pet
    end
  end
  return nil
end

-- Attempt relink by home proximity
local function relink_by_home(entity)
  if not (entity and entity.valid) then return nil end
  ensure_storage()

  local sx = entity.position.x
  local sy = entity.position.y
  local surf_name = entity.surface.name
  local r2 = sqr(RELINK_RADIUS_TILES)

  for _, pet in pairs(storage.my_demolishers) do
    if pet.home_surface_name == surf_name and pet.home_pos then
      local dx = sx - pet.home_pos.x
      local dy = sy - pet.home_pos.y
      if (dx * dx + dy * dy) <= r2 then
        -- Relink
        pet.linked_unit_number = entity.unit_number
        if pet.customparam and pet.customparam.set_entity then
          pet.customparam:set_entity(entity)
        end
        return pet
      end
    end
  end

  return nil
end

-- Public: resolve pet for an entity
function S.resolve(entity)
  ensure_storage()

  -- 1) entity ref (best)
  local pet = find_by_entity_ref(entity)
  if pet then return pet end

  -- 2) linked unit_number (bridge)
  pet = find_by_linked_unit_number(entity)
  if pet then
    -- ensure entity ref is refreshed
    if pet.customparam and pet.customparam.set_entity then
      pet.customparam:set_entity(entity)
    end
    return pet
  end

  -- 3) relink by home
  return relink_by_home(entity)
end

return S