-- __BreedingDemolisher__/scripts/application/pet_breeding/dto/PetBreedingPlanEntryDTO.lua
-- ------------------------------------------------------------
-- class PetBreedingPlanEntryDTO
-- Responsibility:
--   Pet Breeding execution 1 step 分の plan entry 契約を表現する。
--
-- Scope:
--   - plain-table ContractDTO
--   - constructor validation
--   - shape validation
--   - copy-on-write update API
--
-- Notes:
--   - Planner → Store → Executor 間で共有される ContractDTO。
--   - metatable には依存しない。
--   - 契約判定は validate() のみを基準とする。
-- ------------------------------------------------------------
local PetBreedingPlanEntryDTO = {}

local function validate_string(value, field_name, caller_name)
  if type(value) ~= "string" or value == "" then
    error(caller_name .. ": " .. field_name .. " must be a non-empty string")
  end
end

local function validate_no_extra_keys(value, allowed_keys, caller_name)
  for key, _ in pairs(value) do
    if not allowed_keys[key] then
      error(caller_name .. ": unexpected field '" .. tostring(key) .. "'")
    end
  end
end

--- validate
--- Responsibility:
---   PetBreedingPlanEntryDTO の契約 shape を検証する。
--- @param value table
function PetBreedingPlanEntryDTO.validate(value)
  local caller_name = "PetBreedingPlanEntryDTO.validate"

  if type(value) ~= "table" then
    error(caller_name .. ": value must be a table")
  end

  validate_string(value.pet_id, "pet_id", caller_name)

  validate_no_extra_keys(value, {
    pet_id = true,
  }, caller_name)
end

--- new
--- Responsibility:
---   validated plain-table ContractDTO を生成する。
--- @param args table
--- @return table
function PetBreedingPlanEntryDTO.new(args)
  if type(args) ~= "table" then
    error("PetBreedingPlanEntryDTO.new: args must be a table")
  end

  local dto = {
    pet_id = args.pet_id,
  }

  PetBreedingPlanEntryDTO.validate(dto)
  return dto
end

--- with_pet_id
--- Responsibility:
---   pet_id を更新した copy-on-write DTO を返す。
--- @param self table
--- @param pet_id string
--- @return table
function PetBreedingPlanEntryDTO.with_pet_id(self, pet_id)
  PetBreedingPlanEntryDTO.validate(self)

  return PetBreedingPlanEntryDTO.new({
    pet_id = pet_id,
  })
end

return PetBreedingPlanEntryDTO