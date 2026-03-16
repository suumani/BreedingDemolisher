-- __BreedingDemolisher__/scripts/events/on_entity_died.lua
-- ------------------------------------------------------------
-- Responsibility:
--   on_entity_died を受け、
--   非 demolisher 撃破時の pet growth / satiety 更新を行う。
--
-- Scope:
--   - enemy kill による pet growth 更新
--   - enemy kill による pet satiety 更新
--   - event boundary protection by pcall
--
-- Notes:
--   - pet death handling は on_object_destroyed 側で扱う。
--   - wild demolisher 撃破時の旧 egg drop / old respawn は扱わない。
--   - pcall は event boundary にのみ配置し、失敗は Logger へ明示記録する。
-- ------------------------------------------------------------
local DemolisherNames = require("__Manis_definitions__/scripts/definition/DemolisherNames")
local Logger = require("scripts.services.Logger")

local DEMOLISHER_NAME_SET = {}
do
  for _, n in ipairs(DemolisherNames.ALL) do
    DEMOLISHER_NAME_SET[n] = true
  end
end

local function is_demolisher(entity)
  return entity ~= nil and entity.valid and DEMOLISHER_NAME_SET[entity.name] == true
end

local function handle_enemy_except_demolisher_dead(entity)
  if entity == nil or entity.valid == false then
    return
  end

  local pets = storage.my_demolishers or {}
  if #pets == 0 then
    return
  end

  local nearest_pet = nil
  local nearest_dist2 = 900 -- 30 tiles squared

  for _, pet in ipairs(pets) do
    local cp = pet.customparam
    if cp and cp.get_entity then
      local pet_entity = cp:get_entity()
      if pet_entity and pet_entity.valid then
        local dx = entity.position.x - pet_entity.position.x
        local dy = entity.position.y - pet_entity.position.y
        local d2 = dx * dx + dy * dy
        if d2 < nearest_dist2 then
          nearest_dist2 = d2
          nearest_pet = pet
        end
      end
    end
  end

  if nearest_pet and nearest_pet.customparam then
    nearest_pet.customparam:grow(entity.max_health / 20000)
    nearest_pet.customparam:eat(0.1)
  end
end

local function on_entity_died_handler(event)
  local entity = event.entity
  if not entity or not entity.valid or not entity.surface then
    return
  end

  if is_demolisher(entity) then
    return
  end

  handle_enemy_except_demolisher_dead(entity)
end

script.on_event(defines.events.on_entity_died, function(event)
  local ok, err = pcall(on_entity_died_handler, event)
  if not ok then
    Logger.error({
      event = "on_entity_died",
      error = tostring(err),
      tick = game and game.tick or nil,
      entity_name = event and event.entity and event.entity.valid and event.entity.name or nil,
      unit_number = event and event.entity and event.entity.valid and event.entity.unit_number or nil,
    })
  end
end)