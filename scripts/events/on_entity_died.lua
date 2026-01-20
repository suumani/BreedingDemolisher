-- __BreedingDemolisher__/scripts/events/on_entity_died.lua

local SpawnPositionService = require("scripts.services.SpawnPositionService")
local DemolisherNames = require("__Manis_definitions__/scripts/definition/DemolisherNames")
local DRand = require("__BreedingDemolisher__/scripts/util/DeterministicRandom")
local EggGenesStore = require("scripts.services.EggGenesStore")
local QualityUtil = require("scripts.util.QualityUtil")
local PetIdentityService = require("scripts.services.PetIdentityService")
local NotificationService = require("scripts.services.NotificationService")

-- Demolisher判定用の高速セット（ロード時に一度だけ構築）
local DEMOLISHER_NAME_SET = {}
do
  for _, n in ipairs(DemolisherNames.ALL) do
    DEMOLISHER_NAME_SET[n] = true
  end
end

local function is_demolisher(entity)
  return entity ~= nil and entity.valid and DEMOLISHER_NAME_SET[entity.name] == true
end

-- ----------------------------
-- デモリッシャー以外のすべての破壊イベント
-- （ペットが近くで敵を倒したら成長/空腹を回復）
-- ----------------------------
local function enemy_except_demolisher_dead(event, entity)
  if entity == nil or not entity.valid then
    return
  end

  -- ペットが居なければ終了
  if not storage.my_demolishers or #storage.my_demolishers == 0 then
    return
  end

  local nearest_pet = nil
  local nearest_dist2 = 900 -- 最大食事距離は30 => 30^2

  for _, pet in pairs(storage.my_demolishers) do
    local cp = pet.customparam
    if cp and cp.get_entity then
      local pet_entity = cp:get_entity()
      if pet_entity and pet_entity.valid then
        local dx = entity.position.x - pet_entity.position.x
        local dy = entity.position.y - pet_entity.position.y
        local d2 = dx*dx + dy*dy
        if d2 < nearest_dist2 then
          nearest_dist2 = d2
          nearest_pet = pet
        end
      end
    end
  end

  if not nearest_pet then
    return
  end

  -- ここは unit_number に依存せず、見つけた pet の customparam を直接更新する
  if nearest_pet.customparam then
    nearest_pet.customparam:grow(entity.max_health / 20000)
    nearest_pet.customparam:eat(0.1)
    return
  end

  game_print.message("enemy_except_demolisher_dead error")
end

-- ----------------------------
-- アイテムドロップ
-- ----------------------------
function drop_item(entity, item_name, drop_rate, customparam, quality)
  local surface = entity.surface
  local position = entity.position

  if quality == nil or type(quality) ~= "number" then
    quality = 0
  end

  local r = DRand.random()
  if r >= drop_rate then
    return false
  end

  local str_quality = QualityUtil.to_item_quality_name(quality)

  -- genes_id は customparam がある時だけ発行
  local genes_id = nil
  if customparam ~= nil then
    genes_id = EggGenesStore.register(customparam)
  end

  local dropped = surface.spill_item_stack{
    position = position,
    stack = { name = item_name, count = 1, quality = str_quality },
  }

  if genes_id ~= nil and dropped and #dropped > 0 then
    for _, item_ent in ipairs(dropped) do
      if item_ent and item_ent.valid and item_ent.stack and item_ent.stack.valid_for_read then
        local tags = item_ent.stack.tags or {}
        tags.bd_ver = 1
        tags.bd_genes_id = genes_id
        tags.bd_born_tick = game.tick
        item_ent.stack.tags = tags
      end
    end
  end

  if customparam == nil then
    game_print.message("["..surface.name.."] demolisher defeated, you can find egg somewhere!")
  else
    game_print.message("["..surface.name.."] demolisher lay eggs, you can find egg somewhere!")
  end

  return true
end

-- ----------------------------
-- ペットのデモリッシャーが死んだ（PetIdentityServiceで特定）
-- ----------------------------
local function dead_my_demolisher(event, entity)
  if not storage.my_demolishers or #storage.my_demolishers == 0 then
    return false
  end

  -- 1) まず死んだentityからペットを解決（unit_number依存排除）
  local pet = PetIdentityService.resolve(entity)
  if not pet then
    return false
  end

  NotificationService.pet_killed(entity.surface, entity.position, pet.pet_id)

  -- 2) 卵ドロップ条件（旧仕様を維持）
  local cp = pet.customparam
  if cp and cp.get_growth and cp:get_growth() > 20 then
    local r2 = DRand.random()
    local item = CONST_ITEM_NAME.DEMOLISHER_EGG
    local drop_rate = 0

    local fname = entity.force and entity.force.name or ""

    if fname == "enemy" then
      drop_rate = 0.5
      if r2 < 0.2 then
        item = CONST_ITEM_NAME.NEW_SPIECES_DEMOLISHER_EGG
      end
      local egg_cp = cp:mutate(fname, nil)
      drop_item(entity, item, drop_rate, egg_cp, egg_cp:get_quality())

    elseif fname == "demolishers" then
      drop_rate = 0.7
      if r2 < 0.2 then
        item = CONST_ITEM_NAME.FRIEND_DEMOLISHER_EGG
      elseif r2 < 0.7 then
        item = CONST_ITEM_NAME.NEW_SPIECES_DEMOLISHER_EGG
      end
      local egg_cp = cp:mutate(fname, nil)
      drop_item(entity, item, drop_rate, egg_cp, egg_cp:get_quality())

    elseif fname == "player" then
      drop_rate = 0.9
      if r2 < 0.9 then
        item = CONST_ITEM_NAME.FRIEND_DEMOLISHER_EGG
      else
        item = CONST_ITEM_NAME.NEW_SPIECES_DEMOLISHER_EGG
      end
      local egg_cp = cp:mutate(fname, nil)
      drop_item(entity, item, drop_rate, egg_cp, egg_cp:get_quality())
    end
  end

  -- 3) storageから削除（pet_id優先、なければ参照一致で落とす）
  for i = #storage.my_demolishers, 1, -1 do
    local v = storage.my_demolishers[i]
    if (pet.pet_id and v.pet_id == pet.pet_id) or (v == pet) then
      table.remove(storage.my_demolishers, i)
      break
    end
  end

  return true
end

-- ----------------------------
-- デモリッシャー死亡イベント
-- ----------------------------
local function demolisher_dead_event(event, entity)
  storage.respawn_queue = storage.respawn_queue or {}

  -- ペット処理
  local result = dead_my_demolisher(event, entity)
  if result == true then return end

  -- 野良デモリッシャー
  local drop_rate = 0.05
  local item = CONST_ITEM_NAME.DEMOLISHER_EGG
  local drop = drop_item(entity, item, drop_rate)

  if drop == true then
    return
  end

  local r = DRand.random()
  local r2 = DRand.random()

  local evolution_factor = game.forces["enemy"].get_evolution_factor(entity.surface)

  if ((r < evolution_factor/4) or (evolution_factor < 0.3 and r < 0.15)) then
    local spawn_position = SpawnPositionService.getSpawnPosition(entity.surface, evolution_factor, entity.position)
    if spawn_position ~= nil then
      game_print.message("["..entity.surface.name.."]".. entity.quality.name .. " " .. entity.name .. " defeated, but egg is missing... would hatch within 10 minutes...")
      table.insert(storage.respawn_queue, {
        surface = entity.surface,
        entity_name = entity.name,
        position = entity.position,
        evolution_factor = evolution_factor,
        force = entity.force,
        respawn_tick = game.tick + 18000 + 18000*r2
      })
    else
      game_print.message("["..entity.surface.name.."] ".. entity.quality.name .. " " .. entity.name .. " defeated, egg was rotten...")
    end
  else
    game_print.message("["..entity.surface.name.."] ".. entity.quality.name .. " ".. entity.name .. " defeated, egg destroyed.")
  end
end

-- ----------------------------
-- エンティティの死亡イベントを捕捉
-- ----------------------------
script.on_event(defines.events.on_entity_died, function(event)
  local entity = event.entity
  if not entity or not entity.valid or not entity.surface then return end

  local demolisher = is_demolisher(entity)

  if demolisher and entity.surface.name == "vulcanus" then
    storage.bd_demolisher_first_kill_tick = storage.bd_demolisher_first_kill_tick or game.tick
  end

  if demolisher then
    demolisher_dead_event(event, entity)
  else
    enemy_except_demolisher_dead(event, entity)
  end
end)