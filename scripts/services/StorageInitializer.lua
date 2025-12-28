-- scripts/services/StorageInitializer.lua
-- ----------------------------
-- Responsibility:
--   init() 時に必要な storage の初期化を行う。
--   現行仕様を踏襲し、storage.eggs は毎回初期化する（旧仕様領域のため）。
-- ----------------------------
local S = {}

function S.init_all()
  if storage == nil then
    storage = {}
  end

  storage.respawn_queue = storage.respawn_queue or {}

  -- ペットのデモリッシャー追加枠
  storage.my_demolishers = storage.my_demolishers or {}

  -- 卵管理(古いので毎回初期化)
  storage.eggs = {}

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
  end

  -- 遺伝管理テスト
  if storage.genetic_data == nil then
    --[[
    storage.genetic_data = {
      {id = 1, trait = "dammy"},{id = 2, trait = "dammy"},{id = 3, trait = "dammy"},{id = 4, trait = "dammy"},
      {id = 11, trait = "dammy"},{id = 12, trait = "dammy"},{id = 13, trait = "dammy"},{id = 14, trait = "dammy"},
      {id = 21, trait = "dammy"},{id = 22, trait = "dammy"},{id = 23, trait = "dammy"},{id = 24, trait = "dammy"},
      {id = 31, trait = "dammy"},{id = 32, trait = "dammy"},{id = 33, trait = "dammy"},{id = 34, trait = "dammy"},
      {id = 41, trait = "dammy"},{id = 42, trait = "dammy"},{id = 43, trait = "dammy"},{id = 44, trait = "dammy"}
    }
      ]]
  end
end

return S