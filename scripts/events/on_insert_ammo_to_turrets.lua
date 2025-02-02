script.on_event("on_insert_ammo_to_turrets", function(event)
    local player = game.get_player(event.player_index)
    if not player or not player.character then return end

    local inventory = player.get_main_inventory()
    if not inventory then return end

    -- 補給可能な弾薬の種類
    local ammo_types = {
        "firearm-magazine",
        "piercing-rounds-magazine",
        "uranium-rounds-magazine"
    }

    if player.cursor_stack == nil or not player.cursor_stack.valid_for_read then return end

    local ammo = player.cursor_stack.name
    if ammo ~= ammo_types[1] and ammo ~= ammo_types[2] and ammo ~= ammo_types[3] then return end

    -- game_print.debug("Selected Ammo: " .. ammo)  -- 選択された弾薬を確認

    -- プレイヤーの位置と検索範囲
    local position = player.position
    local radius = 15  -- 半径15タイル以内のタレットを対象にする

    -- 周囲のガンタレットを取得
    local turrets = player.surface.find_entities_filtered{
        area = {{position.x - radius, position.y - radius}, {position.x + radius, position.y + radius}},
        type = "ammo-turret"
    }

    if #turrets == 0 then
        game_print.debug("No turrets found nearby.")
        return
    end

    -- **メインインベントリから優先的に消費**
    local inventory_ammo = inventory.get_item_count(ammo)  -- インベントリの弾薬数
    local cursor_ammo = player.cursor_stack.valid_for_read and player.cursor_stack.count or 0  -- 手持ちの弾薬数
    local total_ammo = inventory_ammo + cursor_ammo  -- 総弾薬数

    -- game.print("Total Ammo Available: " .. total_ammo)  -- 総弾薬数を確認

    if total_ammo == 0 then
        game_print.debug("No ammo available to insert.")
        return
    end

    local inserted_any = false

    -- **各タレットに1発ずつ入れる**
    for _, turret in ipairs(turrets) do
        local turret_inv = turret.get_inventory(defines.inventory.turret_ammo)
        if turret_inv then
            local inserted = turret_inv.insert{name = ammo, count = 1}  -- 1発だけ入れる
            if inserted > 0 then
                -- **メインインベントリから優先的に消費**
                if inventory_ammo > 0 then
                    inventory.remove{name = ammo, count = 1}
                    inventory_ammo = inventory_ammo - 1
                elseif cursor_ammo > 0 and player.cursor_stack.valid_for_read then
                    player.cursor_stack.count = player.cursor_stack.count - 1
                    cursor_ammo = cursor_ammo - 1
                end

                -- game_print.debug("Turret at (" .. turret.position.x .. ", " .. turret.position.y .. ") received 1 ammo.")
                inserted_any = true
            end
        end
    end

    if not inserted_any then
    	game_print.debug("No ammo was inserted. Make sure there is room in the turrets.")
	else
		-- game_print.message(ammo .. " was inserted.")
		player.play_sound{path = "utility/inventory_move", position = player.position, volume_modifier = 1.0}

    end
end)