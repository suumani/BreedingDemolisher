local DemolisherNames = require("__Manis_lib__/scripts/definition/DemolisherNames")
-- プレイヤーの向きに応じた座標計算（10マス先）
local SPAWN_OFFSET = {
  [defines.direction.north]     = {x = 0,  y = -20},
  [defines.direction.northeast] = {x = 14, y = -14},
  [defines.direction.east]      = {x = 20, y = 0},
  [defines.direction.southeast] = {x = 14, y = 14},
  [defines.direction.south]     = {x = 0,  y = 20},
  [defines.direction.southwest] = {x = -14,y = 14},
  [defines.direction.west]      = {x = -20,y = 0},
  [defines.direction.northwest] = {x = -14,y = -14},
}

script.on_event("on_breeding_demolisher_mouse_button_2", function(event)
	
    local player = game.get_player(event.player_index)
    if not player or not player.character then return end

    local cursor_stack = player.cursor_stack -- 手に持っているアイテム

	local quality = nil
    if cursor_stack then
		if cursor_stack.valid_for_read then
			-- game_print.debug("cursor_stack.name = " .. cursor_stack.name)
			if cursor_stack.name:find("demolisher%-egg") then
				quality = (cursor_stack.quality and cursor_stack.quality.name) or CONST_QUALITY.NORMAL -- Quality取得
				-- 氷なら砕けておしまい。遺伝子はロストしない（ロストすべきかも）
				if cursor_stack.name:find("frozen") then
					game_print.message("shattered...")
					-- 手にもっているアイテムを削除
					cursor_stack.clear()
					return
				end
			else
				return
			end
		else
			return
		end
	else
		return
	end

    local position = player.position -- プレイヤーの現在位置
    local direction = player.character and player.character.direction or defines.direction.north -- プレイヤーの向き


    local spawn_position = {
        x = position.x + spawn_offset[direction].x,
        y = position.y + spawn_offset[direction].y,
    }

	local force = nil
	-- 勢力の設定
	if cursor_stack.name:find("new%-spieces") then
		force = "demolishers"
	elseif cursor_stack.name:find("friend") then
		local player = game.get_player(event.player_index)
		force = player.force
	else
		force = "enemy"
	end

	local customparam = nil

	-- 遺伝子の抽出
	if  storage.my_eggs ~= nil
		and storage.my_eggs[cursor_stack.name] ~= nil
		and storage.my_eggs[cursor_stack.name][cursor_stack.quality.name] ~= nil 
		and #storage.my_eggs[cursor_stack.name][cursor_stack.quality.name] > 0 then
		customparam = storage.my_eggs[cursor_stack.name][cursor_stack.quality.name][1].customparam
		table.remove(storage.my_eggs[cursor_stack.name][cursor_stack.quality.name], 1)
	end

	local surface = player.surface
	local name = DemolisherNames.SMALL_DEMOLISHER
	if cursor_stack.name:find("medium") then
		name = DemolisherNames.MEDIUM_DEMOLISHER
	elseif cursor_stack.name:find("big") then
		name = DemolisherNames.BIG_DEMOLISHER
	end

	spawn_my_demolisher(surface, name, spawn_position, force, customparam, quality)

	-- 手にもっているアイテムを削除
	cursor_stack.clear()

end)


-- ----------------------------
-- ペットデモリッシャーの生成
-- ----------------------------
local function spawn_my_demolisher(surface, name, position, force, customparam, strquality)
	local entity = surface.create_entity({
		name = name,
		position = position,
		force = force,
		quality = strquality
	})

	if customparam ~= nil then
		customparam:set_entity(entity)
	end

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
			surface = entity.surface
			, entity_name = entity.name
			, force = entity.force
			, unit_number = entity.unit_number
			, customparam = customparam or Customparam.new(
				entity
				, entity_name
				, name
				, size
				, quality
				, speed
				, life
				, CONST_DEMOLISHER_PARAMETER.DEFAULT_MAX_GROWTH
				, CONST_DEMOLISHER_PARAMETER.DEFAULT_MAX_SATIETY
				, traits
				, game.tick
			)
		}
	)
end