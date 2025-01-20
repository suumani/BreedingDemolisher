-- ----------------------------
-- requires
-- ----------------------------
require("scripts.defines.constant_demolisher_parameters")
require("scripts.defines.constant_demolisher_traits")
require("scripts.defines.constant_entity_name")
require("scripts.defines.constant_item_name")

require("scripts.common.customparam")
require("scripts.common.choose_quality")
require("scripts.common.demolisher_rush")

require("scripts.events.on_player_used_capsule")
require("scripts.events.on_selected_entity_changed")
require("scripts.events.on_entity_died")
require("scripts.events.on_tick")

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
            if item and type(item) == "table" and getmetatable(item) == nil then
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
end)

-- ----------------------------
-- �\���ύX
-- ----------------------------
script.on_configuration_changed(function(event)
	init()
	local vulcanus_surface = game.surfaces["vulcanus"]
	if vulcanus_surface ~= nil then
		-- vulcanus�̃f�����b�V���[������
		local all_demolishers = find_all_vulcanus_demolisher(vulcanus_surface)
		
		-- �f�����b�V���[�z�񂩂�A�����ł�����Ȃ��f�����b�V���[���폜
		delete_unfound_demolishers(all_demolishers)
		
		-- ���ׂẴf�����b�V���[�̂����A����50�}�X�Ƀf�����b�V���[�z��ɑ����Ȃ��f�����b�V���[��6�̈ȏア��ꍇ�Ɏ�����t�^
		add_demolishers_life(all_demolishers)
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
	-- vulcanus�̃f�����b�V���[�ǉ��g
	if storage.additional_demolishers == nil then
		storage.additional_demolishers = {}
		storage.additional_demolishers["count"] = 0
	end
	-- fulgora�̃f�����b�V���[�ǉ��g
	if storage.fulgora_demolishers == nil then
		storage.fulgora_demolishers = {}
		storage.fulgora_demolishers["count"] = 0
	end
	-- �y�b�g�̃f�����b�V���[�ǉ��g
	if storage.my_demolishers == nil then
		storage.my_demolishers = {}
	end

	-- ���Ǘ�(�Â��̂ŏ�����)
	if storage.eggs == nil then
		storage.eggs = {}
	else
		storage.eggs = {}
	end
	-- ���Ǘ�(�����d�l)
	if storage.my_wild_eggs == nil then
		storage.eggs = {}
	end
	-- ���Ǘ�(�����d�l)
	if storage.my_new_spieces_eggs == nil then
		storage.eggs = {}
	end
	-- ���Ǘ�(�����d�l)
	if storage.my_friend_eggs == nil then
		storage.eggs = {}
	end
	-- ���Ǘ�
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
		game.print("[mod:BreedingDemolisher] initialize forces")
	end
	
	-- �Z�[�u�f�[�^�Ή�(ver.0.1.9)
	if is_before_save_data(old_version) then
		adding_demolisher_life()
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

function create_genetic_analysis_ui(player, entity)
	-- ������UI������΍폜
	if player.gui.relative["genetic_analysis_ui"] then
		player.gui.relative["genetic_analysis_ui"].destroy()
	end

	-- �J�X�^��UI���쐬
	local frame = player.gui.relative.add{
		type = "frame",
		name = "genetic_analysis_ui",
		caption = "Genetic Analysis Machine",
		direction = "vertical",
		anchor = {
			gui = defines.relative_gui_type.container_gui,
			position = defines.relative_gui_position.right
		}
	}

	-- ��`���̃��X�g��\��
	frame.add{type = "label", caption = "Genetic Data List:"}
	local scroll_pane = frame.add{
		type = "scroll-pane",
		name = "genetic_data_list",
		vertical_scroll_policy = "auto",
		horizontal_scroll_policy = "never"
	}
	scroll_pane.style.maximal_height = 340 -- �K�v�ɉ����č����𒲐�

	-- ��`���𓮓I�Ƀ��X�g�\��
	for id, data in pairs(storage.genetic_data) do
		local flow = scroll_pane.add{
			type = "flow",
			direction = "horizontal",
			name = "genetic_data_" .. id
		}
		flow.add{type = "label", caption = "ID: " .. id .. " | Trait: " .. data.trait}
		flow.add{
			type = "button",
			name = "delete_genetic_data_" .. id,
			caption = "Delete"
		}
	end
end

-- on_gui_opened�C�x���g����create_genetic_analysis_ui���Ăяo��
script.on_event(defines.events.on_gui_opened, function(event)
	if event.entity and event.entity.name == "genetic-analysis-machine" then
		local player = game.get_player(event.player_index)
		create_genetic_analysis_ui(player, event.entity)
	end
end)

-- �폜�{�^���̃N���b�N�C�x���g����
script.on_event(defines.events.on_gui_click, function(event)
	local player = game.get_player(event.player_index)

	-- �폜�{�^�����N���b�N���ꂽ�ꍇ
	if event.element.name:find("^delete_genetic_data_") then
		local id = event.element.name:match("^delete_genetic_data_(%d+)")
		id = tonumber(id)

		if id and storage.genetic_data[id] then
			-- ��`�����폜
			storage.genetic_data[id] = nil

			-- UI���Đ������čX�V
			create_genetic_analysis_ui(player, player.selected)
		end
	end
end)