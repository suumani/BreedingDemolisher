-- __BreedingDemolisher__/scripts/application/reproduction/dto/WildReproductionPlanEntryDTO.lua
-- ------------------------------------------------------------
-- class WildReproductionPlanEntryDTO
-- Responsibility:
--   Wild Reproduction execution 1 step 分の plan entry 契約を表現する。
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
local WildReproductionPlanEntryDTO = {}

local INTERNAL_KEY = "__wild_reproduction_plan_entry_dto_internal__"

local function validate_string(value, field_name)
  if type(value) ~= "string" or value == "" then
    error("WildReproductionPlanEntryDTO.new: " .. field_name .. " must be a non-empty string")
  end
end

local function validate_integer(value, field_name)
  if type(value) ~= "number" or value % 1 ~= 0 then
    error("WildReproductionPlanEntryDTO.new: " .. field_name .. " must be an integer")
  end
end

local function validate_args(args)
  if type(args) ~= "table" then
    error("WildReproductionPlanEntryDTO.new: args must be a table")
  end

  validate_string(args.surface_name, "surface_name")
  validate_integer(args.representative_chunk_x, "representative_chunk_x")
  validate_integer(args.representative_chunk_y, "representative_chunk_y")
end

local INSTANCE_MT = {
  __index = function(self, key)
    if WildReproductionPlanEntryDTO[key] ~= nil then
      return WildReproductionPlanEntryDTO[key]
    end

    local internal = rawget(self, INTERNAL_KEY)
    if internal ~= nil then
      return internal[key]
    end

    return nil
  end,
  __newindex = function()
    error("WildReproductionPlanEntryDTO is immutable")
  end,
  __metatable = "locked",
}

--- new
--- Responsibility:
---   validated immutable ContractDTO を生成する。
--- @param args table
--- @return WildReproductionPlanEntryDTO
function WildReproductionPlanEntryDTO.new(args)
  validate_args(args)

  local self = {}
  rawset(self, INTERNAL_KEY, {
    surface_name = args.surface_name,
    representative_chunk_x = args.representative_chunk_x,
    representative_chunk_y = args.representative_chunk_y,
  })

  return setmetatable(self, INSTANCE_MT)
end

--- is_instance
--- Responsibility:
---   ContractDTO instance であることを判定する。
--- @param value any
--- @return boolean
function WildReproductionPlanEntryDTO.is_instance(value)
  if type(value) ~= "table" then
    return false
  end

  return rawget(value, INTERNAL_KEY) ~= nil
end

--- with_surface_name
--- Responsibility:
---   surface_name を更新した copy-on-write DTO を返す。
--- @param self WildReproductionPlanEntryDTO
--- @param surface_name string
--- @return WildReproductionPlanEntryDTO
function WildReproductionPlanEntryDTO.with_surface_name(self, surface_name)
  return WildReproductionPlanEntryDTO.new({
    surface_name = surface_name,
    representative_chunk_x = self.representative_chunk_x,
    representative_chunk_y = self.representative_chunk_y,
  })
end

--- with_representative_chunk_x
--- Responsibility:
---   representative_chunk_x を更新した copy-on-write DTO を返す。
--- @param self WildReproductionPlanEntryDTO
--- @param representative_chunk_x integer
--- @return WildReproductionPlanEntryDTO
function WildReproductionPlanEntryDTO.with_representative_chunk_x(self, representative_chunk_x)
  return WildReproductionPlanEntryDTO.new({
    surface_name = self.surface_name,
    representative_chunk_x = representative_chunk_x,
    representative_chunk_y = self.representative_chunk_y,
  })
end

--- with_representative_chunk_y
--- Responsibility:
---   representative_chunk_y を更新した copy-on-write DTO を返す。
--- @param self WildReproductionPlanEntryDTO
--- @param representative_chunk_y integer
--- @return WildReproductionPlanEntryDTO
function WildReproductionPlanEntryDTO.with_representative_chunk_y(self, representative_chunk_y)
  return WildReproductionPlanEntryDTO.new({
    surface_name = self.surface_name,
    representative_chunk_x = self.representative_chunk_x,
    representative_chunk_y = representative_chunk_y,
  })
end

return WildReproductionPlanEntryDTO