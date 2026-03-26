-- __BreedingDemolisher__/scripts/application/pet_breeding/PetBreedingPlanningService.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Pet Breeding の planning を行い、
--   今 cycle の execution plan を生成する。
--
-- Scope:
--   - storage.my_demolishers 取得
--   - pet_id 列挙
--   - 安定ソート
--   - plan store への保存
--   - planning ResultDTO 返却
--
-- Notes:
--   - storage.my_demolishers は辞書 table を許容する。
--   - planning count は plan entry 数を意味する。
--   - storage shape は bootstrap 済み前提で扱い、この層では自動生成しない。
-- ------------------------------------------------------------
local PetBreedingPlanningService = {}

local PetBreedingPlanEntryDTO = require("scripts.application.pet_breeding.dto.PetBreedingPlanEntryDTO")
local PetBreedingPlanStore = require("scripts.infrastructure.runtime.PetBreedingPlanStore")

local function dto_ok(reason, detail)
  return {
    ok = true,
    result = "OK",
    reason = reason,
    detail = detail,
  }
end

local function dto_skip(reason, detail)
  return {
    ok = true,
    result = "SKIP",
    reason = reason,
    detail = detail,
  }
end

local function build_detail(cycle_tick, total_pet_count, planned_pet_count, count)
  return {
    cycle_tick = cycle_tick,
    total_pet_count = total_pet_count,
    planned_pet_count = planned_pet_count,
    count = count,
  }
end

local function expect_storage_shape()
  if storage == nil then
    error("PetBreedingPlanningService: storage is nil")
  end
  if storage.my_demolishers == nil then
    error("PetBreedingPlanningService: storage.my_demolishers is nil. Call StorageBootstrap.bootstrap() first.")
  end
end

local function get_sorted_pet_entries()
  expect_storage_shape()

  local pets = storage.my_demolishers
  local entries = {}
  local total_pet_count = 0
  local planned_pet_count = 0

  for _, pet in pairs(pets) do
    if type(pet) == "table" then
      total_pet_count = total_pet_count + 1

      if type(pet.pet_id) == "string" and pet.pet_id ~= "" then
        planned_pet_count = planned_pet_count + 1
        entries[#entries + 1] = PetBreedingPlanEntryDTO.new({
          pet_id = pet.pet_id,
        })
      end
    end
  end

  table.sort(entries, function(a, b)
    return a.pet_id < b.pet_id
  end)

  return entries, total_pet_count, planned_pet_count
end

--- plan
--- Responsibility:
---   cycle_tick に対応する Pet Breeding plan を生成し保存する。
--- @param cycle_tick uint
--- @return table dto
function PetBreedingPlanningService.plan(cycle_tick)
  if type(cycle_tick) ~= "number" then
    error("PetBreedingPlanningService.plan: cycle_tick must be a number")
  end

  local entries, total_pet_count, planned_pet_count = get_sorted_pet_entries()
  PetBreedingPlanStore.replace_plan(cycle_tick, entries)

  if total_pet_count == 0 then
    return dto_skip("PET:NO_PETS", build_detail(
      cycle_tick,
      total_pet_count,
      planned_pet_count,
      0
    ))
  end

  if #entries == 0 then
    return dto_skip("PET:NO_PLAN_ENTRIES", build_detail(
      cycle_tick,
      total_pet_count,
      planned_pet_count,
      0
    ))
  end

  return dto_ok("PET:PLAN_CREATED", build_detail(
    cycle_tick,
    total_pet_count,
    planned_pet_count,
    #entries
  ))
end

return PetBreedingPlanningService