-- __BreedingDemolisher__/scripts/domain/pet_breeding/PetBreedingEvaluator.lua
-- ------------------------------------------------------------
-- Responsibility:
--   1 pet を評価し、Pet Breeding の結果を決定する。
--
-- Scope:
--   - 成熟度判定
--   - breeding stage 判定
--   - chance 消費可否判定
--   - partner 探索
--   - 最も近い partner 選択
--   - breeding result 決定
--
-- Result:
--   - immature
--   - no_new_chance
--   - parthenogenesis
--   - reproduction
--
-- Notes:
--   - execution step は 1 pet = 1 step
--   - partner 不在時は parthenogenesis
--   - growth stage は 20 刻み
--   - pets は辞書 table を許容する
-- ------------------------------------------------------------
local PetBreedingEvaluator = {}

local BREED_MIN_GROWTH = 20
local BREED_STAGE_STEP = 20
local BREED_RANGE_SQ = 57600 -- 240 tiles radius squared

PetBreedingEvaluator.RESULT_IMMATURE = "immature"
PetBreedingEvaluator.RESULT_NO_NEW_CHANCE = "no_new_chance"
PetBreedingEvaluator.RESULT_PARTHENOGENESIS = "parthenogenesis"
PetBreedingEvaluator.RESULT_REPRODUCTION = "reproduction"

local function is_mature(cp)
  return cp ~= nil and (cp.growth or 0) >= BREED_MIN_GROWTH
end

local function get_entity(cp)
  if cp == nil then
    return nil
  end

  local entity = cp.entity
  if entity and entity.valid then
    return entity
  end

  return nil
end

local function get_growth(cp)
  if cp == nil then
    return 0
  end
  return cp.growth or 0
end

local function stage_index(growth)
  return math.floor(growth / BREED_STAGE_STEP)
end

local function resolve_last_breed_stage(subject_pet, current_stage)
  if subject_pet.last_breed_stage == nil then
    return current_stage - 1
  end
  return subject_pet.last_breed_stage
end

local function find_nearest_partner(pets, subject_pet, subject_entity)
  local best_pet = nil
  local best_cp = nil
  local best_entity = nil
  local best_d2 = BREED_RANGE_SQ + 1

  for _, candidate_pet in pairs(pets) do
    if type(candidate_pet) == "table" and candidate_pet ~= subject_pet then
      local candidate_cp = candidate_pet.customparam
      if is_mature(candidate_cp) then
        local candidate_entity = get_entity(candidate_cp)
        if candidate_entity then
          local dx = subject_entity.position.x - candidate_entity.position.x
          local dy = subject_entity.position.y - candidate_entity.position.y
          local d2 = dx * dx + dy * dy
          if d2 <= BREED_RANGE_SQ and d2 < best_d2 then
            best_d2 = d2
            best_pet = candidate_pet
            best_cp = candidate_cp
            best_entity = candidate_entity
          end
        end
      end
    end
  end

  return best_pet, best_cp, best_entity
end

--- evaluate
--- Responsibility:
---   subject pet と pets 全体から breeding 結果を決定する。
--- @param subject_pet table
--- @param pets table
--- @return table
function PetBreedingEvaluator.evaluate(subject_pet, pets)
  if type(subject_pet) ~= "table" then
    error("PetBreedingEvaluator.evaluate: subject_pet must be a table")
  end
  if type(pets) ~= "table" then
    error("PetBreedingEvaluator.evaluate: pets must be a table")
  end

  local subject_cp = subject_pet.customparam
  if not is_mature(subject_cp) then
    return {
      result = PetBreedingEvaluator.RESULT_IMMATURE,
      subject_pet = subject_pet,
      subject_cp = subject_cp,
      subject_entity = nil,
      partner_pet = nil,
      partner_cp = nil,
      partner_entity = nil,
      current_stage = nil,
      last_breed_stage = nil,
    }
  end

  local subject_entity = get_entity(subject_cp)
  if not subject_entity then
    return {
      result = PetBreedingEvaluator.RESULT_IMMATURE,
      subject_pet = subject_pet,
      subject_cp = subject_cp,
      subject_entity = nil,
      partner_pet = nil,
      partner_cp = nil,
      partner_entity = nil,
      current_stage = nil,
      last_breed_stage = nil,
    }
  end

  local current_growth = get_growth(subject_cp)
  local current_stage = stage_index(current_growth)
  local last_breed_stage = resolve_last_breed_stage(subject_pet, current_stage)

  if current_stage <= last_breed_stage then
    return {
      result = PetBreedingEvaluator.RESULT_NO_NEW_CHANCE,
      subject_pet = subject_pet,
      subject_cp = subject_cp,
      subject_entity = subject_entity,
      partner_pet = nil,
      partner_cp = nil,
      partner_entity = nil,
      current_stage = current_stage,
      last_breed_stage = last_breed_stage,
    }
  end

  local partner_pet, partner_cp, partner_entity = find_nearest_partner(pets, subject_pet, subject_entity)
  if partner_pet == nil then
    return {
      result = PetBreedingEvaluator.RESULT_PARTHENOGENESIS,
      subject_pet = subject_pet,
      subject_cp = subject_cp,
      subject_entity = subject_entity,
      partner_pet = nil,
      partner_cp = nil,
      partner_entity = nil,
      current_stage = current_stage,
      last_breed_stage = last_breed_stage,
    }
  end

  return {
    result = PetBreedingEvaluator.RESULT_REPRODUCTION,
    subject_pet = subject_pet,
    subject_cp = subject_cp,
    subject_entity = subject_entity,
    partner_pet = partner_pet,
    partner_cp = partner_cp,
    partner_entity = partner_entity,
    current_stage = current_stage,
    last_breed_stage = last_breed_stage,
  }
end

return PetBreedingEvaluator