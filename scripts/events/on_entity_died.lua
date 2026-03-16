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
--   - storage shape は bootstrap 済み前提で扱い、この境界では自動生成しない。
-- ------------------------------------------------------------
local DemolisherNames = require("__Manis_definitions__/scripts/definition/DemolisherNames")
local Logger = require("scripts.services.Logger")

local DEMOLISHER_NAME_SET = {}
do
  for _, n in ipairs(DemolisherNames.ALL) do
    DEMOLISHER_NAME_SET[n] = true
  end
end

local function expect_storage()
  if storage == nil then
    error("on_entity_died: storage is nil")
  end
  if storage.my_demolishers == nil then
    error("on_entity_died: storage.my_demolishers is nil. Call StorageInitializer.init_all() first.")
  end
end

local function is_demolisher(entity)
  return entity ~= nil and entity.valid and DEMOLISHER_NAME_SET[entity.name] == true
end

local function handle_enemy_except_demolisher_dead(entity)
  if entity == nil or entity.valid == false then
    return
  end

  local pets = storage.my_demolishers
  if #pets == 0 then
    return
  end

  local nearest_pet = nil
  local nearest_dist2 = 900 -- 30 tiles squared

  for _, pet in ipairs(pets) do
    local cp = pet.customparam
    local pet_entity = cp and cp.entity
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

  if nearest_pet and nearest_pet.customparam then
    local cp = nearest_pet.customparam
    cp.growth = (cp.growth or 0) + (entity.max_health / 20000)

    local max_growth = cp.max_growth
    if max_growth ~= nil and cp.growth > max_growth then
      cp.growth = max_growth
    end

    cp.satiety = (cp.satiety or 0) + 0.1

    local max_satiety = cp.max_satiety
    if max_satiety ~= nil and cp.satiety > max_satiety then
      cp.satiety = max_satiety
    end
  end
end

local function on_entity_died_handler(event)
  expect_storage()

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