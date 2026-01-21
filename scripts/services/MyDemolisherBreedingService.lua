-- __BreedingDemolisher__/scripts/services/MyDemolisherBreedingService.lua

local EggDropService = require("scripts.services.EggDropService")
local QualityUtil = require("scripts.util.QualityUtil")
local NotificationService = require("scripts.services.NotificationService")

local MyDemolisherBreedingService = {}

local BREED_MIN_GROWTH = 20
local BREED_STAGE_STEP = 20
local BREED_RANGE_SQ   = 57600  -- 240 tiles radius squared

local function is_mature(cp)
  return cp ~= nil and cp:get_growth() >= BREED_MIN_GROWTH
end

local function get_entity(cp)
  if not cp then return nil end
  local e = cp:get_entity()
  if e and e.valid then return e end
  return nil
end

local function is_within_range(a, b)
  local dx = a.position.x - b.position.x
  local dy = a.position.y - b.position.y
  return (dx * dx + dy * dy) <= BREED_RANGE_SQ
end

local function decide_egg_item_name(parent_entity)
  local fname = parent_entity.force and parent_entity.force.name or ""
  if fname == "enemy" then
    return CONST_ITEM_NAME.DEMOLISHER_EGG
  elseif fname == "demolishers" then
    return CONST_ITEM_NAME.NEW_SPIECES_DEMOLISHER_EGG
  else
    return CONST_ITEM_NAME.FRIEND_DEMOLISHER_EGG
  end
end

local function decide_egg_item_name_by_force_name(force_name)
  if force_name == "enemy" then
    return CONST_ITEM_NAME.DEMOLISHER_EGG
  elseif force_name == "demolishers" then
    return CONST_ITEM_NAME.NEW_SPIECES_DEMOLISHER_EGG
  else
    return CONST_ITEM_NAME.FRIEND_DEMOLISHER_EGG
  end
end

local function stage_index(growth)
  return math.floor(growth / BREED_STAGE_STEP)
end

local function find_mature_partner(pets, parent_pet, parent_entity)
  local best_pet = nil
  local best_cp = nil
  local best_entity = nil
  local best_d2 = BREED_RANGE_SQ + 1

  for _, partner_pet in pairs(pets) do
    if partner_pet ~= parent_pet then
      local partner_cp = partner_pet.customparam
      if is_mature(partner_cp) then
        local partner_entity = get_entity(partner_cp)
        if partner_entity then
          local dx = parent_entity.position.x - partner_entity.position.x
          local dy = parent_entity.position.y - partner_entity.position.y
          local d2 = dx*dx + dy*dy
          if d2 <= BREED_RANGE_SQ and d2 < best_d2 then
            best_d2 = d2
            best_pet = partner_pet
            best_cp = partner_cp
            best_entity = partner_entity
          end
        end
      end
    end
  end

  return best_pet, best_cp, best_entity
end

function MyDemolisherBreedingService.my_demolisher_breeding()
  local pets = storage.my_demolishers
  local pet_count = (pets and #pets) or 0
  game_print.debug("[Breeding] tick=" .. game.tick .. " pets=" .. tostring(pet_count))
  if pet_count == 0 then return end

  for _, parent_pet in pairs(pets) do
    local parent_cp = parent_pet.customparam
    local parent_tag = "pet_id=" .. tostring(parent_pet.pet_id or "?")

    if not is_mature(parent_cp) then
      -- optional debug
      -- game_print.debug("[Breeding] skip:not_mature " .. parent_tag)
    else
      local parent_entity = get_entity(parent_cp)
      if not parent_entity then
        game_print.debug("[Breeding] skip:entity_missing " .. parent_tag)
      else
        local growth = parent_cp:get_growth()
        local stage = stage_index(growth)

        -- initialize: treat "first time reaching stage>=1" as a chance
        if parent_pet.last_breed_stage == nil then
          parent_pet.last_breed_stage = stage - 1
        end

        if stage <= parent_pet.last_breed_stage then
          game_print.debug("[Breeding] skip:stage_already_used " .. parent_tag ..
            " growth="..tostring(growth).." stage="..tostring(stage).." last="..tostring(parent_pet.last_breed_stage))
        else
          local _, partner_cp, partner_entity = find_mature_partner(pets, parent_pet, parent_entity)
          if not partner_cp then
            game_print.debug("[Breeding] skip:no_partner " .. parent_tag ..
              " growth="..tostring(growth).." stage="..tostring(stage))
          else
            local egg_customparam, child_force = parent_cp:mutate(parent_entity.force.name, partner_cp)

            local item_name = decide_egg_item_name_by_force_name(child_force or parent_entity.force.name)
            local item_quality = QualityUtil.to_item_quality_name(egg_customparam:get_quality())

            NotificationService.breeding_egg_laid(parent_entity.surface, parent_entity.position)
            EggDropService.drop_egg(parent_entity.surface, parent_entity.position, item_name, item_quality, egg_customparam)

            parent_pet.last_breed_stage = stage

            game_print.debug("[Breeding] OK:laid_egg " .. parent_tag ..
              " growth="..tostring(growth).." stage="..tostring(stage)..
              " partner_unit="..tostring(partner_entity and partner_entity.unit_number or "nil"))

            return
          end
        end
      end
    end
  end
end

return MyDemolisherBreedingService