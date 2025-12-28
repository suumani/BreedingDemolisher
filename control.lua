-- ----------------------------
-- requires
-- ----------------------------
require("scripts.defines.constant_demolisher_parameters")
require("scripts.defines.constant_demolisher_traits")
require("scripts.defines.constant_item_name")
require("scripts.defines.constant_quality")

require("scripts.common.customparam")
require("scripts.common.game_print")
require("scripts.common.util")

require("scripts.events.on_breeding_demolisher_mouse_button_2")

require("scripts.events.on_entity_died")
require("scripts.events.on_gui_opened")
require("scripts.events.on_selected_entity_changed")
require("scripts.events.on_nth_tick_1min")
require("scripts.events.on_nth_tick_30min")
require("scripts.events.on_rocket_launched")

require("scripts.gui.selected_demolisher_gui")

local SaveRestoreService = require("scripts.services.SaveRestoreService")
local ForceInitializer = require("scripts.services.ForceInitializer")
local StorageInitializer = require("scripts.services.StorageInitializer")
local MigrationService = require("scripts.services.MigrationService")

local DRand = require("scripts.util.DeterministicRandom")

-- ----------------------------
-- 開始
-- ----------------------------
script.on_init(function()
  init()
end)

-- ----------------------------
-- ロード
-- ----------------------------
script.on_load(function()
  SaveRestoreService.on_load_restore()
end)

-- ----------------------------
-- 構成変更
-- ----------------------------
script.on_configuration_changed(function(event)
  init()
end)

-- ----------------------------
-- 初期化共通
-- ----------------------------
function init()
  -- 乱数初期化
  DRand.init(1234567)

  -- storage 初期化
  StorageInitializer.init_all()

  -- 第三勢力デモリッシャー
  ForceInitializer.ensure_demolishers_force()
end
