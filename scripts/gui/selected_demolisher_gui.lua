local DemolisherNames = require("__Manis_lib__/scripts/definition/DemolisherNames")

-- ----------------------------
-- traitsテーブルをローカライズキーでマッピング
-- ----------------------------
local trait_locale_keys = {
    ["short_warp"] = "trait.short_warp",
    ["emergency_food"] = "trait.emergency_food",
    ["bonus_growth"] = "trait.bonus_growth",
}

-- ----------------------------
-- GUI更新
-- ----------------------------
function update_selected_demolisher_gui(player, entity)
	local frame = player.gui.left["demolisher_info_frame"]
	if frame then
		frame.destroy() -- 既存のGUIがあれば削除
	end
	
	if entity and (entity.name == DemolisherNames.SMALL_DEMOLISHER or entity.name == DemolisherNames.MEDIUM_DEMOLISHER or entity.name == DemolisherNames.BIG_DEMOLISHER) then
		local success, result = pcall(function()
			create_frame(player, entity)
		end)
		if not success then
			print("Error: create_frame")
		end
	end
end

-- ----------------------------
-- デモリッシャーGUI更新
-- ----------------------------
function create_frame(player, entity)
	-- 寿命
	local life = get_life(entity)
	-- 品質
	local quality = get_quality(entity)
	
	-- 新しいGUIフレームを作成
	main_frame = player.gui.left.add{
		type = "frame"
		, name = "demolisher_info_frame"
		, caption = {"item-name.demolisher-info"}
		, direction = "vertical"}
	
	-- ペット判別
	local my_demolisher = nil
	if storage.my_demolishers ~= nil then
		for _, value in pairs(storage.my_demolishers) do
			if value.unit_number == entity.unit_number then
				my_demolisher = value
				break
			end
		end
	end
	
	if my_demolisher == nil then
		wild_demolisher_frame(main_frame, entity, life)
	else
		my_demolisher_frame(main_frame, entity, my_demolisher)
	end
end

-- ----------------------------
-- 野生のデモリッシャー
-- ----------------------------
function wild_demolisher_frame(main_frame, entity, life)
	-- 個体名
	local name_label = main_frame.add{type = "label", caption = "name: Vulcanus_typeB+_#" .. entity.unit_number}
	name_label.style.font = "default-large-bold"
	-- 勢力
	local force_label = main_frame.add{type = "label", caption = "force: "..entity.force.name}
	force_label.style.font = "default-large-bold"
	-- 基本情報テーブル見出し
	local basic_info_label = main_frame.add{type = "label", caption = {"item-name.demolisher-basic-info"}}
	basic_info_label.style.font = "default-bold"

	-- 追加デモリッシャーリストに居れば、追記
	main_frame.add{type = "label", caption = "type: wild"}
	-- 寿命の記載
	main_frame.add{type = "label", caption = "life: " .. life}

	-- 詳細情報テーブル見出し
	local basic_info_label = main_frame.add{type = "label", caption = {"item-name.demolisher-detail-info"}}
	basic_info_label.style.font = "default-bold"

	main_frame.add{type = "label", caption = "unknown"}
end

-- ----------------------------
-- ペットのデモリッシャー
-- ----------------------------
function my_demolisher_frame(main_frame, entity, my_demolisher)
	
	-- customparamの存在チェック
	if my_demolisher.customparam == nil then
		wild_demolisher_frame(main_frame, entity)
		return
	end
	
	local name_label = main_frame.add{
		type = "label", caption = {
			"item-description.demolisher-default-name"
			, my_demolisher.customparam:get_dafault_name_surface()
			, my_demolisher.customparam:get_dafault_name_size()
			, my_demolisher.customparam:get_dafault_name_quality()
			, my_demolisher.customparam:get_dafault_name_unit_number()
		}
	}
	name_label.style.font = "default-large-bold"
	
	-- 勢力
	local force_label = main_frame.add{type = "label", caption = {"item-description.demolisher-force", entity.force.name}}
	force_label.style.font = "default-large-bold"
	
	-- 基本情報テーブル見出し
	local basic_info_label = main_frame.add{type = "label", caption = {"item-name.demolisher-basic-info"}}
	basic_info_label.style.font = "default-bold"
	
	-- 基本情報テーブル
	local basic_info_table = main_frame.add{
		type = "table",
		name = "info_table",
		column_count = 2
	}
	
	-- 寿命
	basic_info_table.add{type = "label", caption = {"item-description.demolisher-lifetime", my_demolisher.customparam:get_life()}}
	-- 品質
	basic_info_table.add{type = "label", caption = {"item-description.demolisher-quality", my_demolisher.customparam:get_quality()}}
	
	basic_info_table.add{type = "label", caption = {"item-description.demolisher-satiety", my_demolisher.customparam:get_satiety(),100}}
	basic_info_table.add{type = "label", caption = {"item-description.demolisher-speed", 1}}
	
	local growth = my_demolisher.customparam:get_growth()
	if growth > 20 then
		basic_info_table.add{type = "label", caption = {"item-description.demolisher-growth-breedable", my_demolisher.customparam:get_growth(),50}}
	else
		basic_info_table.add{type = "label", caption = {"item-description.demolisher-growth-immature", my_demolisher.customparam:get_growth(),50}}
	end
	basic_info_table.add{type = "label", caption = {"item-description.demolisher-lv", my_demolisher.customparam:get_lv()}}

	basic_info_table.add{type = "label", caption = {"item-description.demolisher-size", entity.max_health + my_demolisher.customparam:get_size()}}
	
	-- 解説
	main_frame.add{type = "label", caption = {"item-description.demolisher-growth-description"}}
	main_frame.add{type = "label", caption = {"item-description.demolisher-hangry-description"}}
	
	-- 特性
	local additional_traits_label = main_frame.add{type = "label", caption = {"item-name.demolisher-info"}}
	additional_traits_label.style.font = "default-bold"
	
	for key, value in pairs(my_demolisher.customparam:get_traits()) do
		local locale_key = trait_locale_keys[key]
	    if locale_key then
	        -- ローカライズキーを直接使用して文字列を生成
	        local localized_name = {"", {locale_key}, " Lv." .. value}
	        main_frame.add{type = "label", caption = localized_name}
	    else
	        -- ローカライズが存在しない場合の処理
	        main_frame.add{type = "label", caption = "Unknown Trait: " .. key .. " Lv." .. value}
	    end
	end
end



-- ----------------------------
-- 品質
-- ----------------------------
function get_quality(entity)
	
	-- 未定義の場合、標準値
	if entity.quality == "legendary" then
		return "5.0"
	elseif entity.quality == "epic" then
		return "4.0"
	elseif entity.quality == "rare" then
		return "3.0"
	elseif entity.quality == "uncommon" then
		return "2.0"
	else
		return "1.0"
	end
end

-- ----------------------------
-- 寿命
-- ----------------------------
function get_life(entity)
	return "Infinity"
end
