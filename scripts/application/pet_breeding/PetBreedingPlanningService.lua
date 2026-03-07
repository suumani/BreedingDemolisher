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
--   - execution step count 返却
-- ------------------------------------------------------------
local PetBreedingPlanningService = {}

local PetBreedingPlanStore = require("scripts.infrastructure.runtime.PetBreedingPlanStore")

local function get_sorted_pet_entries()
  local pets = storage.my_demolishers or {}
  local entries = {}

  for _, pet in ipairs(pets) do
    if pet and type(pet.pet_id) == "string" and pet.pet_id ~= "" then
      entries[#entries + 1] = {
        pet_id = pet.pet_id,
      }
    end
  end

  table.sort(entries, function(a, b)
    return a.pet_id < b.pet_id
  end)

  return entries
end

function PetBreedingPlanningService.plan(cycle_tick)
  if type(cycle_tick) ~= "number" then
    error("PetBreedingPlanningService.plan: cycle_tick must be a number")
  end

  local entries = get_sorted_pet_entries()
  PetBreedingPlanStore.replace_plan(cycle_tick, entries)

  return #entries
end

return PetBreedingPlanningService