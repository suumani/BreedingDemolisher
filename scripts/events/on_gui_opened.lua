-- on_gui_openedイベント内でcreate_genetic_analysis_uiを呼び出す
script.on_event(defines.events.on_gui_opened, function(event)
	if event.entity and event.entity.name == "genetic-analysis-machine" then
		local player = game.get_player(event.player_index)
		create_genetic_analysis_ui(player, event.entity)
	end
end)

function create_genetic_analysis_ui(player, entity)
	-- 既存のUIがあれば削除
	if player.gui.screen["genetic_analysis_ui"] then
		player.gui.screen["genetic_analysis_ui"].destroy()
	end

	-- カスタムUIを作成
	local frame = player.gui.screen.add{
		type = "frame",
		name = "genetic_analysis_ui",
		caption = "Genetic Analysis Machine",
		direction = "vertical",
	}
    -- 閉じるボタンを追加
    local close_button = frame.add{
        type = "button",
        name = "close_genetic_analysis_ui",
        caption = "Close"
    }

	-- 遺伝情報のリストを表示
	frame.add{type = "label", caption = "Genetic Data List:"}
	local scroll_pane = frame.add{
		type = "scroll-pane",
		name = "genetic_data_list",
		vertical_scroll_policy = "auto",
		horizontal_scroll_policy = "never"
	}
	scroll_pane.style.maximal_height = 340 -- 必要に応じて高さを調整

	-- 遺伝情報を動的にリスト表示
	
	if storage.my_eggs then
		for size_key, demolisher_quality_list in pairs (storage.my_eggs) do -- my_eggs はまず、各デモリッシャーサイズごとに、品質別リストが入っている
			local flow_size = scroll_pane.add{
				type = "flow",
				direction = "horizontal",
				name = size_key
			}
			local flow_size_label = flow_size.add{type = "label", caption = "-" .. size_key .. "-"}
			flow_size_label.style.font = "default-large-bold"
			for quality_key, demolisher_egg_list in pairs (demolisher_quality_list) do -- 各品質別リストには、各卵が入っている
				local flow_quality = scroll_pane.add{
					type = "flow",
					direction = "horizontal",
					name = size_key .. "_" .. quality_key
				}
				local flow_quality_label = flow_quality.add{type = "label", caption = "--" .. size_key .. ":" .. quality_key .. "--"}
				flow_size_label.style.font = "default-bold"

				for egg_key, egg in pairs(demolisher_egg_list) do
					if egg.customparam then
						local flow = scroll_pane.add{
							type = "flow",
							direction = "horizontal",
							name = "egg_" .. size_key .. "_" .. quality_key .. "_" .. egg_key
						}
						flow.add{type = "label", caption = "Name: " .. egg.customparam:get_name()}
						flow.add{
							type = "button",
							name = "delete_genetic_data_" .. size_key .. "_" .. quality_key .. "_" .. egg_key,
							caption = "Delete"
						}
					end
				end
			end
		end
	end
end

-- 削除ボタンのクリックイベント処理
script.on_event(defines.events.on_gui_click, function(event)
	local player = game.get_player(event.player_index)

    -- 閉じるボタンがクリックされた場合
    if event.element.name == "close_genetic_analysis_ui" then
        if player.gui.screen["genetic_analysis_ui"] then
            player.gui.screen["genetic_analysis_ui"].destroy()
        end
    elseif event.element.name:find("^delete_genetic_data_") then
		local id = event.element.name:match("^delete_genetic_data_(%d+)")
		id = tonumber(id)

		if id and storage.genetic_data[id] then
			-- 遺伝情報を削除
			storage.genetic_data[id] = nil

			-- UIを再生成して更新
			create_genetic_analysis_ui(player, player.selected)
		end
	end
end)