-- ----------------------------
-- requires
-- ----------------------------
require("scripts.defines.constant_demolisher_parameters")
require("scripts.defines.constant_demolisher_traits")
require("scripts.defines.constant_entity_name")
require("scripts.defines.constant_item_name")
require("scripts.defines.constant_quality")

require("scripts.common.customparam")
require("scripts.common.choose_quality")
require("scripts.common.demolisher_rush")
require("scripts.common.game_print")

require("scripts.events.on_entity_died")
require("scripts.events.on_gui_opened")
require("scripts.events.on_player_used_capsule")
require("scripts.events.on_selected_entity_changed")
require("scripts.events.on_nth_tick_1min")
require("scripts.events.on_nth_tick_30min")

require("scripts.gui.selected_demolisher_gui")
require("scripts.updates.ver_0_1_9_save_update")
-- ----------------------------
-- 開始
-- ----------------------------
script.on_init(function()
	init()
	storage = storage or {}
	storage.teststr = storage.teststr or "teststr2"
end)

-- ----------------------------
-- ロード
-- ----------------------------
script.on_load(function()

    -- Customparamのmetatableを設定する関数
    local function restore_customparam_metatable(data_table)
        for _, item in pairs(data_table) do
            if item and type(item) == "table" then
				if item.customparam and type(item.customparam) == "table" and getmetatable(item.customparam) == nil then
	                setmetatable(item.customparam, Customparam)
				end
            end
        end
    end

    -- 保存されたデータ構造の復元処理
    if storage.my_demolishers then
        restore_customparam_metatable(storage.my_demolishers)
    end
	
	if storage.my_eggs then
		for _, demolisher_quality_list in pairs (storage.my_eggs) do -- my_eggs はまず、各デモリッシャーサイズごとに、品質別リストが入っている
			for _2, demolisher_egg_list in pairs (demolisher_quality_list) do -- 各品質別リストには、各卵が入っている
				for _3, egg in pairs(demolisher_egg_list) do
					if egg.customparam and type(egg.customparam) == "table" and getmetatable(egg.customparam) == nil then
						setmetatable(egg.customparam, Customparam)
					end
				end
			end
		end
	end

end)

-- ----------------------------
-- 構成変更
-- ----------------------------
script.on_configuration_changed(function(event)
	init()
	local vulcanus_surface = game.surfaces["vulcanus"]
	if vulcanus_surface ~= nil then
		-- vulcanusのデモリッシャーを検索
		local all_demolishers = find_all_vulcanus_demolisher(vulcanus_surface)
		
		-- デモリッシャー配列から、検索でかからないデモリッシャーを削除
		delete_unfound_demolishers(all_demolishers)
		
		-- すべてのデモリッシャーのうち、周辺50マスにデモリッシャー配列に属さないデモリッシャーが6体以上いる場合に寿命を付与
		add_demolishers_life(all_demolishers)
	end
end)

-- ----------------------------
-- 初期化共通
-- ----------------------------
function init()
	if storage == nil then
		storage = {}
	end
	if storage.teststr == nil then
		storage.teststr = "teststr1"
	end
	if storage.respawn_queue == nil then
		storage.respawn_queue = {}
	end
	-- vulcanusのデモリッシャー追加枠
	if storage.additional_demolishers == nil then
		storage.additional_demolishers = {}
		storage.additional_demolishers["count"] = 0
	end
	-- fulgoraのデモリッシャー追加枠
	if storage.fulgora_demolishers == nil then
		storage.fulgora_demolishers = {}
		storage.fulgora_demolishers["count"] = 0
	end
	-- ペットのデモリッシャー追加枠
	if storage.my_demolishers == nil then
		storage.my_demolishers = {}
	end

	-- 卵管理(古いので初期化)
	if storage.eggs == nil then
		storage.eggs = {}
	else
		storage.eggs = {}
	end
	-- 卵管理(正式仕様:ペット分 - 3次元)
	if storage.my_eggs == nil then
		storage.my_eggs = {}

		storage.my_eggs[CONST_ITEM_NAME.DEMOLISHER_EGG] = {}
		storage.my_eggs[CONST_ITEM_NAME.NEW_SPIECES_DEMOLISHER_EGG] = {}
		storage.my_eggs[CONST_ITEM_NAME.FRIEND_DEMOLISHER_EGG] = {}

		storage.my_eggs[CONST_ITEM_NAME.DEMOLISHER_EGG_MIDDLE] = {}
		storage.my_eggs[CONST_ITEM_NAME.NEW_SPIECES_DEMOLISHER_EGG_MIDDLE] = {}
		storage.my_eggs[CONST_ITEM_NAME.FRIEND_DEMOLISHER_EGG_MIDDLE] = {}
		
		storage.my_eggs[CONST_ITEM_NAME.DEMOLISHER_EGG_BIG] = {}
		storage.my_eggs[CONST_ITEM_NAME.NEW_SPIECES_DEMOLISHER_EGG_BIG] = {}
		storage.my_eggs[CONST_ITEM_NAME.FRIEND_DEMOLISHER_EGG_BIG] = {}

		for _, value in pairs(storage.my_eggs) do
			value[CONST_QUALITY.NORMAL] = {}
			value[CONST_QUALITY.UNCOMMON] = {}
			value[CONST_QUALITY.RARE] = {}
			value[CONST_QUALITY.EPIC] = {}
			value[CONST_QUALITY.LEGENDARY] = {}
		end

		-- debug_print("type = " .. type(storage.my_eggs["demolisher-egg"]["normal"]))
	end
	-- 遺伝管理テスト
	if storage.genetic_data == nil then
		storage.genetic_data = {
			{id = 1, trait = "dammy"},{id = 2, trait = "dammy"},{id = 3, trait = "dammy"},{id = 4, trait = "dammy"}
			,{id = 11, trait = "dammy"},{id = 12, trait = "dammy"},{id = 13, trait = "dammy"},{id = 14, trait = "dammy"}
			,{id = 21, trait = "dammy"},{id = 22, trait = "dammy"},{id = 23, trait = "dammy"},{id = 24, trait = "dammy"}
			,{id = 31, trait = "dammy"},{id = 32, trait = "dammy"},{id = 33, trait = "dammy"},{id = 34, trait = "dammy"}
			,{id = 41, trait = "dammy"},{id = 42, trait = "dammy"},{id = 43, trait = "dammy"},{id = 44, trait = "dammy"}
		}
	end
	-- 第三勢力デモリッシャー
	if not game.forces["demolishers"] then
		local new_force = game.create_force("demolishers")
		-- 敵対関係の設定
		new_force.set_cease_fire("player", false) -- プレイヤーと敵対
		new_force.set_cease_fire("enemy", false) -- バイターと敵対
		new_force.set_cease_fire("neutral", true) -- 中立と停戦
		demolisher_print("[mod:BreedingDemolisher] initialize forces")
	end
	
	-- セーブデータ対応(ver.0.1.9)
	if is_before_save_data(old_version) then
		adding_demolisher_life()
	end
end

-- ----------------------------
-- 構成変更確認 before save data
-- ----------------------------
function is_before_save_data(old_version)
	if old_version == "0.0.1" or
		old_version == "0.0.2" or
		old_version == "0.0.3" or
		old_version == "0.0.4" or
		old_version == "0.0.5" or
		old_version == "0.0.6" or
		old_version == "0.0.7" or
		old_version == "0.0.8" or
		old_version == "0.0.9" or
		old_version == "0.1.0" or
		old_version == "0.1.1" or
		old_version == "0.1.2" or
		old_version == "0.1.3" or
		old_version == "0.1.4" or
		old_version == "0.1.5" or
		old_version == "0.1.6" or
		old_version == "0.1.7" or
		old_version == "0.1.8" or
		old_version == "0.1.9" or
		old_version == "0.2.0" then
		return true
	else
		return false
	end
end
