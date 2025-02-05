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
require("scripts.common.wild_demolisher")
require("scripts.common.util")

require("scripts.events.on_breeding_demolisher_mouse_button_2")

require("scripts.events.on_entity_died")
require("scripts.events.on_gui_opened")
require("scripts.events.on_selected_entity_changed")
require("scripts.events.on_nth_tick_1min")
require("scripts.events.on_nth_tick_30min")

require("scripts.gui.selected_demolisher_gui")
require("scripts.updates.ver_0_1_9_save_update")
-- ----------------------------
-- �J�n
-- ----------------------------
script.on_init(function()
	init()
	storage = storage or {}
	storage.teststr = storage.teststr or "teststr2"
end)

-- ----------------------------
-- ���[�h
-- ----------------------------
script.on_load(function()

    -- Customparam��metatable��ݒ肷��֐�
    local function restore_customparam_metatable(data_table)
        for _, item in pairs(data_table) do
            if item and type(item) == "table" then
				if item.customparam and type(item.customparam) == "table" and getmetatable(item.customparam) == nil then
	                setmetatable(item.customparam, Customparam)
				end
            end
        end
    end

    -- �ۑ����ꂽ�f�[�^�\���̕�������
    if storage.my_demolishers then
        restore_customparam_metatable(storage.my_demolishers)
    end
	
	if storage.my_eggs then
		for _, demolisher_quality_list in pairs (storage.my_eggs) do -- my_eggs �͂܂��A�e�f�����b�V���[�T�C�Y���ƂɁA�i���ʃ��X�g�������Ă���
			for _2, demolisher_egg_list in pairs (demolisher_quality_list) do -- �e�i���ʃ��X�g�ɂ́A�e���������Ă���
				for _3, egg in pairs(demolisher_egg_list) do
					if egg.customparam and type(egg.customparam) == "table" and getmetatable(egg.customparam) == nil then
						setmetatable(egg.customparam, Customparam)
					end
				end
			end
		end
	end

end)

local function find_demolisher_entity(all_demolishers, unit_number)
	for _, value in pairs(all_demolishers) do
		if value.unit_number == unit_number then
			return value
		end
	end
	return nil
end

local function is_old_data_0_3_2(old_version)
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
		old_version == "0.2.0" or
		old_version == "0.2.1" or
		old_version == "0.2.2" or
		old_version == "0.2.3" or
		old_version == "0.2.4" or
		old_version == "0.2.5" or
		old_version == "0.2.6" or
		old_version == "0.2.7" or
		old_version == "0.2.8" or
		old_version == "0.2.9" or
		old_version == "0.3.0" or
		old_version == "0.3.1" or
		old_version == "0.3.2" then
		return true
	else
		return false
	end
end

-- ----------------------------
-- �\���ύX
-- ----------------------------
script.on_configuration_changed(function(event)
	init()
	local vulcanus_surface = game.surfaces["vulcanus"]
	
	-- vulcanus ������ΑΏ��Ȃ�
	if vulcanus_surface == nil then return end

	-- vulcanus�̃f�����b�V���[������
	local all_demolishers = find_all_demolishers(vulcanus_surface)
	
	-- �f�����b�V���[�z�񂩂�A�����ł�����Ȃ��f�����b�V���[���폜
	delete_unfound_demolishers(all_demolishers)
	
	-- ���ׂẴf�����b�V���[�̂����A����50�}�X�Ƀf�����b�V���[�z��ɑ����Ȃ��f�����b�V���[��6�̈ȏア��ꍇ�Ɏ�����t�^
	-- if is_old_data_0_3_2(old_version) then add_demolishers_life(all_demolishers) end
	-- ���
	add_demolishers_life(all_demolishers)
		
	-- vulcanus�̃f�����b�V���[�ǉ��g(old)
	if storage.additional_demolishers == nil then
		storage.additional_demolishers = {}
	end
	
	-- vulcanus ������ΑΏ��Ȃ�
	if vulcanus_surface ~= nil then
		-- vulcanus�̃f�����b�V���[������
		local all_demolishers = find_all_demolishers(vulcanus_surface)
		-- vulcanus�̃f�����b�V���[�ǉ��g�ւ̈ڍs(new)
		if storage.additional_demolishers ~= nil then

			storage.new_vulcanus_demolishers = storage.new_vulcanus_demolishers or {}
			for key, value in pairs(storage.additional_demolishers) do
				if key ~= "count" then
					local entity = find_demolisher_entity(all_demolishers, key)
					if entity ~= nil then
						add_new_wild_demolisher(storage.new_vulcanus_demolishers, entity, value + 180 * 3600)
					end
				end
			end
			storage.additional_demolishers = {}
		end
	end

	local fulgora_surface = game.surfaces["fulgora"]
	-- fulgora ������ΑΏ��Ȃ�
	if fulgora_surface ~= nil then
		-- vulcanus�̃f�����b�V���[������
		local all_demolishers = find_all_demolishers(fulgora_surface)
		-- fulgora�̃f�����b�V���[�ǉ��g�ւ̈ڍs(new)
		if storage.fulgora_demolishers ~= nil then
			storage.new_fulgora_demolishers = storage.new_fulgora_demolishers or {}
			for key, value in pairs(storage.fulgora_demolishers) do
				if key ~= "count" then
					local entity = find_demolisher_entity(all_demolishers, key)
					if entity ~= nil then
						add_new_wild_demolisher(storage.new_fulgora_demolishers, entity, value + 180 * 3600)
					end
				end
			end
			storage.fulgora_demolishers = {}
		end
	end

end)

-- ----------------------------
-- ����������
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

	-- vulcanus�̃f�����b�V���[�ǉ��g(old)
	storage.additional_demolishers = storage.additional_demolishers or {}

	-- vulcanus�̃f�����b�V���[�ǉ��g(new)
	storage.new_vulcanus_demolishers = storage.new_vulcanus_demolishers or {}

	-- fulgora�̃f�����b�V���[�ǉ��g(old)
	storage.fulgora_demolishers = storage.fulgora_demolishers or {}
	-- fulgora�̃f�����b�V���[�ǉ��g(new)
	storage.new_fulgora_demolishers = storage.new_fulgora_demolishers or {}

	-- �y�b�g�̃f�����b�V���[�ǉ��g
	storage.my_demolishers = storage.my_demolishers or {}

	-- ���Ǘ�(�Â��̂ŏ�����)
	storage.eggs = {}

	-- ���Ǘ�(�����d�l:�y�b�g�� - 3����)
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
	-- ��`�Ǘ��e�X�g
	if storage.genetic_data == nil then
		storage.genetic_data = {
			{id = 1, trait = "dammy"},{id = 2, trait = "dammy"},{id = 3, trait = "dammy"},{id = 4, trait = "dammy"}
			,{id = 11, trait = "dammy"},{id = 12, trait = "dammy"},{id = 13, trait = "dammy"},{id = 14, trait = "dammy"}
			,{id = 21, trait = "dammy"},{id = 22, trait = "dammy"},{id = 23, trait = "dammy"},{id = 24, trait = "dammy"}
			,{id = 31, trait = "dammy"},{id = 32, trait = "dammy"},{id = 33, trait = "dammy"},{id = 34, trait = "dammy"}
			,{id = 41, trait = "dammy"},{id = 42, trait = "dammy"},{id = 43, trait = "dammy"},{id = 44, trait = "dammy"}
		}
	end

	-- ��O���̓f�����b�V���[
	if not game.forces["demolishers"] then
		local new_force = game.create_force("demolishers")
		-- �G�Ί֌W�̐ݒ�
		new_force.set_cease_fire("player", false) -- �v���C���[�ƓG��
		new_force.set_cease_fire("enemy", false) -- �o�C�^�[�ƓG��
		new_force.set_cease_fire("neutral", true) -- �����ƒ��
		game_print.message("[mod:BreedingDemolisher] initialize forces")
	end
	
	-- �Z�[�u�f�[�^�Ή�(ver.0.1.9)
	if is_before_save_data(old_version) then
		adding_demolisher_life()
	end

	local vulcanus_surface = game.surfaces["vulcanus"]
	
	-- vulcanus ������ΑΏ��Ȃ�
	if vulcanus_surface ~= nil then
		-- vulcanus�̃f�����b�V���[������
		local all_demolishers = find_all_demolishers(vulcanus_surface)
		-- vulcanus�̃f�����b�V���[�ǉ��g�ւ̈ڍs(new)
		if storage.additional_demolishers ~= nil then

			storage.new_vulcanus_demolishers = storage.new_vulcanus_demolishers or {}
			for key, value in pairs(storage.additional_demolishers) do
				if key ~= "count" then
					local entity = find_demolisher_entity(all_demolishers, key)
					if entity ~= nil then
						if type(value) == "table" then
							add_new_wild_demolisher(storage.new_vulcanus_demolishers, entity, value.life + 180 * 3600)
						else
							add_new_wild_demolisher(storage.new_vulcanus_demolishers, entity, value + 180 * 3600)
						end
					end
				end
			end
			storage.additional_demolishers = {}
		end
	end

	local fulgora_surface = game.surfaces["fulgora"]
	-- fulgora ������ΑΏ��Ȃ�
	if fulgora_surface ~= nil then
		-- vulcanus�̃f�����b�V���[������
		local all_demolishers = find_all_demolishers(fulgora_surface)
		-- fulgora�̃f�����b�V���[�ǉ��g�ւ̈ڍs(new)
		if storage.fulgora_demolishers ~= nil then
			storage.new_fulgora_demolishers = storage.new_fulgora_demolishers or {}
			for key, value in pairs(storage.fulgora_demolishers) do
				if key ~= "count" then
					local entity = find_demolisher_entity(all_demolishers, key)
					if entity ~= nil then
						add_new_wild_demolisher(storage.new_fulgora_demolishers, entity, value + 180 * 3600)
					end
				end
			end
			storage.fulgora_demolishers = {}
		end
	end
end

-- ----------------------------
-- �\���ύX�m�F before save data
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
