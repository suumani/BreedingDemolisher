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
script.on_event("on_breeding_demolisher_mouse_button_2", function(event)

  local player = game.get_player(event.player_index)
  if not player or not player.character then return end

  local cursor_stack = player.cursor_stack
  if not cursor_stack or not cursor_stack.valid_for_read then return end

  -- egg判定
  if not cursor_stack.name:find("demolisher%-egg") then
    return
  end

  -- Quality取得（環境差分で cursor_stack.quality が無い可能性に備える）
  local quality = (cursor_stack.quality and cursor_stack.quality.name) or CONST_QUALITY.NORMAL

  -- frozen egg は砕けて終了
  if cursor_stack.name:find("frozen") then
    game_print.message("shattered...")
    cursor_stack.clear()
    return
  end

  -- spawn position
  local position = player.position
  local direction = player.character.direction or defines.direction.north

  local offset = SPAWN_OFFSET[direction] or SPAWN_OFFSET[defines.direction.north]
  local spawn_position = {
    x = position.x + offset.x,
    y = position.y + offset.y,
  }

  -- force決定
  local force
  if cursor_stack.name:find("new%-spieces") then
    force = "demolishers"
  elseif cursor_stack.name:find("friend") then
    force = player.force
  else
    force = "enemy"
  end

  -- 遺伝子の抽出（qualityをキーにする：cursor_stack.quality.name 直参照を廃止）
  local customparam = nil
  if storage.my_eggs
    and storage.my_eggs[cursor_stack.name]
    and storage.my_eggs[cursor_stack.name][quality]
    and #storage.my_eggs[cursor_stack.name][quality] > 0
  then
    customparam = storage.my_eggs[cursor_stack.name][quality][1].customparam
    table.remove(storage.my_eggs[cursor_stack.name][quality], 1)
  end

  -- サイズ判定
  local name = DemolisherNames.SMALL
  if cursor_stack.name:find("medium") then
    name = DemolisherNames.MEDIUM
  elseif cursor_stack.name:find("big") then
    name = DemolisherNames.BIG
  end

  -- spawn
  spawn_my_demolisher(player.surface, name, spawn_position, force, customparam, quality)

  cursor_stack.clear()
end)

-- ----------------------------
-- ペットデモリッシャーの生成
-- ----------------------------
spawn_my_demolisher = function(surface, entity_name, position, force, customparam, strquality)

  -- 初期化（nilで落ちないように）
  storage.my_demolishers = storage.my_demolishers or {}

  local entity = surface.create_entity({
    name = entity_name,
    position = position,
    force = force,
    quality = strquality,
  })

  if customparam ~= nil then
    customparam:set_entity(entity)
  end

  -- (ここは元コード尊重：内部パラメータ生成)
  local name = nil
  local size = nil
  local quality = nil
  local speed = nil
  local traits = nil

  if strquality == CONST_QUALITY.NORMAL then
    quality = 1
  elseif strquality == CONST_QUALITY.UNCOMMON then
    quality = 2
  elseif strquality == CONST_QUALITY.RARE then
    quality = 3
  elseif strquality == CONST_QUALITY.EPIC then
    quality = 4
  elseif strquality == CONST_QUALITY.LEGENDARY then
    quality = 5
  end

  table.insert(storage.my_demolishers,
    {
      surface = entity.surface,
      entity_name = entity.name,
      force = entity.force,
      unit_number = entity.unit_number,
      customparam = customparam or Customparam.new(
        entity,
        entity_name,
        name,
        size,
        quality,
        speed,
        life,
        CONST_DEMOLISHER_PARAMETER.DEFAULT_MAX_GROWTH,
        CONST_DEMOLISHER_PARAMETER.DEFAULT_MAX_SATIETY,
        traits,
        game.tick
      )
    }
  )
end