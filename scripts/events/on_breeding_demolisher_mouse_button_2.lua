-- __BreedingDemolisher__/scripts/events/on_breeding_demolisher_mouse_button_2.lua

local DemolisherNames = require("__Manis_definitions__/scripts/definition/DemolisherNames")

-- プレイヤーの向きに応じた座標計算（20マス先）
local SPAWN_OFFSET = {
  [defines.direction.north]     = {x = 0,   y = -20},
  [defines.direction.northeast] = {x = 14,  y = -14},
  [defines.direction.east]      = {x = 20,  y = 0},
  [defines.direction.southeast] = {x = 14,  y = 14},
  [defines.direction.south]     = {x = 0,   y = 20},
  [defines.direction.southwest] = {x = -14, y = 14},
  [defines.direction.west]      = {x = -20, y = 0},
  [defines.direction.northwest] = {x = -14, y = -14},
}

-- ----------------------------
-- forward declaration
-- ----------------------------
local spawn_my_demolisher

-- ----------------------------
-- Throw to hatch
-- ----------------------------
-- __BreedingDemolisher__/scripts/events/on_breeding_demolisher_mouse_button_2.lua

script.on_event("on_breeding_demolisher_mouse_button_2", function(event)
  storage.my_eggs = storage.my_eggs or {}
  local player = game.get_player(event.player_index)
  if not player or not player.character then return end

  local cursor_stack = player.cursor_stack
  if not cursor_stack or not cursor_stack.valid_for_read then return end

  if not cursor_stack.name:find("demolisher%-egg") then
    return
  end

  local quality = (cursor_stack.quality and cursor_stack.quality.name) or CONST_QUALITY.NORMAL

  if cursor_stack.name:find("frozen") then
    game_print.message("shattered...")
    cursor_stack.clear()
    return
  end

  local position = player.position
  local direction = player.character.direction or defines.direction.north
  local offset = SPAWN_OFFSET[direction] or SPAWN_OFFSET[defines.direction.north]
  local spawn_position = { x = position.x + offset.x, y = position.y + offset.y }

  local force
  if cursor_stack.name:find("new%-spieces") then
    force = "demolishers"
  elseif cursor_stack.name:find("friend") then
    force = player.force
  else
    force = "enemy"
  end

  -- サイズ判定
  local name = DemolisherNames.SMALL
  if cursor_stack.name:find("medium") then
    name = DemolisherNames.MEDIUM
  elseif cursor_stack.name:find("big") then
    name = DemolisherNames.BIG
  end

  -- 遺伝子：peek（成功時のみ remove）
  local egg_entry = nil
  if storage.my_eggs
    and storage.my_eggs[cursor_stack.name]
    and storage.my_eggs[cursor_stack.name][quality]
    and #storage.my_eggs[cursor_stack.name][quality] > 0
  then
    egg_entry = storage.my_eggs[cursor_stack.name][quality][1]
  end

  local customparam = egg_entry and egg_entry.customparam or nil

  local ok = spawn_my_demolisher(player.surface, name, spawn_position, force, customparam, quality)
  if not ok then
    return
  end

  -- 成功した時だけ消費
  cursor_stack.clear()
  if egg_entry then
    table.remove(storage.my_eggs[cursor_stack.name][quality], 1)
  end
end)

-- ----------------------------
-- ペットデモリッシャーの生成
-- ----------------------------
spawn_my_demolisher = function(surface, entity_name, position, force, customparam, strquality)
  storage.my_demolishers = storage.my_demolishers or {}

  -- 衝突回避：近傍の空き座標を探す
  local safe_pos = surface.find_non_colliding_position(entity_name, position, 16, 0.5) or position

  local entity = surface.create_entity({
    name = entity_name,
    position = safe_pos,
    force = force,
    quality = strquality,
  })

  if not entity or not entity.valid then
    game_print.message("No space to hatch here.")
    return false
  end

  if customparam ~= nil then
    customparam:set_entity(entity)
  end

  table.insert(storage.my_demolishers, {
    surface = entity.surface,
    entity_name = entity.name,
    force = entity.force,
    unit_number = entity.unit_number,
    customparam = customparam or Customparam.new(
      entity,
      entity_name,
      nil, -- name
      nil, -- size
      nil, -- quality
      nil, -- speed
      nil, -- max_life
      CONST_DEMOLISHER_PARAMETER.DEFAULT_MAX_GROWTH,
      CONST_DEMOLISHER_PARAMETER.DEFAULT_MAX_SATIETY,
      nil, -- traits
      game.tick
    )
  })

  return true
end