-- __BreedingDemolisher__/scripts/application/reproduction/dto/WildReproductionPlanEntryDTO.lua
-- ------------------------------------------------------------
-- class WildReproductionPlanEntryDTO
-- Responsibility:
--   Wild Reproduction execution 1 step 分の plan entry 契約を表現する。
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
local WildReproductionPlanEntryDTO = {}

local function validate_string(value, field_name, caller_name)
  if type(value) ~= "string" or value == "" then
    error(caller_name .. ": " .. field_name .. " must be a non-empty string")
  end
end

local function validate_integer(value, field_name, caller_name)
  if type(value) ~= "number" or value % 1 ~= 0 then
    error(caller_name .. ": " .. field_name .. " must be an integer")
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
---   WildReproductionPlanEntryDTO の契約 shape を検証する。
--- @param value table
function WildReproductionPlanEntryDTO.validate(value)
  local caller_name = "WildReproductionPlanEntryDTO.validate"

  if type(value) ~= "table" then
    error(caller_name .. ": value must be a table")
  end

  validate_string(value.surface_name, "surface_name", caller_name)
  validate_integer(value.representative_chunk_x, "representative_chunk_x", caller_name)
  validate_integer(value.representative_chunk_y, "representative_chunk_y", caller_name)

  validate_no_extra_keys(value, {
    surface_name = true,
    representative_chunk_x = true,
    representative_chunk_y = true,
  }, caller_name)
end

--- new
--- Responsibility:
---   validated plain-table ContractDTO を生成する。
--- @param args table
--- @return table
function WildReproductionPlanEntryDTO.new(args)
  if type(args) ~= "table" then
    error("WildReproductionPlanEntryDTO.new: args must be a table")
  end

  local dto = {
    surface_name = args.surface_name,
    representative_chunk_x = args.representative_chunk_x,
    representative_chunk_y = args.representative_chunk_y,
  }

  WildReproductionPlanEntryDTO.validate(dto)
  return dto
end

--- with_surface_name
--- Responsibility:
---   surface_name を更新した copy-on-write DTO を返す。
--- @param self table
--- @param surface_name string
--- @return table
function WildReproductionPlanEntryDTO.with_surface_name(self, surface_name)
  WildReproductionPlanEntryDTO.validate(self)

  return WildReproductionPlanEntryDTO.new({
    surface_name = surface_name,
    representative_chunk_x = self.representative_chunk_x,
    representative_chunk_y = self.representative_chunk_y,
  })
end

--- with_representative_chunk_x
--- Responsibility:
---   representative_chunk_x を更新した copy-on-write DTO を返す。
--- @param self table
--- @param representative_chunk_x integer
--- @return table
function WildReproductionPlanEntryDTO.with_representative_chunk_x(self, representative_chunk_x)
  WildReproductionPlanEntryDTO.validate(self)

  return WildReproductionPlanEntryDTO.new({
    surface_name = self.surface_name,
    representative_chunk_x = representative_chunk_x,
    representative_chunk_y = self.representative_chunk_y,
  })
end

--- with_representative_chunk_y
--- Responsibility:
---   representative_chunk_y を更新した copy-on-write DTO を返す。
--- @param self table
--- @param representative_chunk_y integer
--- @return table
function WildReproductionPlanEntryDTO.with_representative_chunk_y(self, representative_chunk_y)
  WildReproductionPlanEntryDTO.validate(self)

  return WildReproductionPlanEntryDTO.new({
    surface_name = self.surface_name,
    representative_chunk_x = self.representative_chunk_x,
    representative_chunk_y = representative_chunk_y,
  })
end

return WildReproductionPlanEntryDTO