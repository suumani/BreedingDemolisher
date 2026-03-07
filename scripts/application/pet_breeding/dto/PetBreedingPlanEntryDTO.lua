-- __BreedingDemolisher__/scripts/application/pet_breeding/dto/PetBreedingPlanEntryDTO.lua
-- ------------------------------------------------------------
-- class PetBreedingPlanEntryDTO
-- Responsibility:
--   Pet Breeding execution 1 step 分の plan entry 契約を表現する。
--
-- Scope:
--   - immutable contract data
--   - constructor validation
--   - copy-on-write update API
--   - instance check
--
-- Notes:
--   - Planner → Store → Executor 間で共有される ContractDTO。
--   - top-level immutable を強制する。
-- ------------------------------------------------------------
local PetBreedingPlanEntryDTO = {}

local INTERNAL_KEY = "__pet_breeding_plan_entry_dto_internal__"

local function validate_string(value, field_name)
  if type(value) ~= "string" or value == "" then
    error("PetBreedingPlanEntryDTO.new: " .. field_name .. " must be a non-empty string")
  end
end

local function validate_args(args)
  if type(args) ~= "table" then
    error("PetBreedingPlanEntryDTO.new: args must be a table")
  end

  validate_string(args.pet_id, "pet_id")
end

local INSTANCE_MT = {
  __index = function(self, key)
    if PetBreedingPlanEntryDTO[key] ~= nil then
      return PetBreedingPlanEntryDTO[key]
    end

    local internal = rawget(self, INTERNAL_KEY)
    if internal ~= nil then
      return internal[key]
    end

    return nil
  end,
  __newindex = function()
    error("PetBreedingPlanEntryDTO is immutable")
  end,
  __metatable = "locked",
}

--- new
--- Responsibility:
---   validated immutable ContractDTO を生成する。
--- @param args table
--- @return PetBreedingPlanEntryDTO
function PetBreedingPlanEntryDTO.new(args)
  validate_args(args)

  local self = {}
  rawset(self, INTERNAL_KEY, {
    pet_id = args.pet_id,
  })

  return setmetatable(self, INSTANCE_MT)
end

--- is_instance
--- Responsibility:
---   ContractDTO instance であることを判定する。
--- @param value any
--- @return boolean
function PetBreedingPlanEntryDTO.is_instance(value)
  if type(value) ~= "table" then
    return false
  end

  return rawget(value, INTERNAL_KEY) ~= nil
end

--- with_pet_id
--- Responsibility:
---   pet_id を更新した copy-on-write DTO を返す。
--- @param self PetBreedingPlanEntryDTO
--- @param pet_id string
--- @return PetBreedingPlanEntryDTO
function PetBreedingPlanEntryDTO.with_pet_id(self, pet_id)
  return PetBreedingPlanEntryDTO.new({
    pet_id = pet_id,
  })
end

return PetBreedingPlanEntryDTO