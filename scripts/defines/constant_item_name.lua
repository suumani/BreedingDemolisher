-- __BreedingDemolisher__/scripts/defines/constant_item_name.lua
-- ------------------------------------------------------------
-- class ConstantItemName
-- Responsibility:
--   BreedingDemolisher で使用する item prototype name 定数を提供する。
--
-- Scope:
--   - demolisher egg item name 定義
--   - frozen / middle / big variation 定義
--
-- Notes:
--   - 読み取り専用の定数モジュールとして扱う。
--   - グローバル変数は定義しない。
--   - require() の戻り値として利用する。
-- ------------------------------------------------------------
local ConstantItemName = {
  DEMOLISHER_EGG = "demolisher-egg",
  NEW_SPIECES_DEMOLISHER_EGG = "new-spieces-demolisher-egg",
  FRIEND_DEMOLISHER_EGG = "friend-demolisher-egg",

  DEMOLISHER_EGG_MIDDLE = "demolisher-egg-middle",
  NEW_SPIECES_DEMOLISHER_EGG_MIDDLE = "new-spieces-demolisher-egg-middle",
  FRIEND_DEMOLISHER_EGG_MIDDLE = "friend-demolisher-egg-middle",

  DEMOLISHER_EGG_BIG = "demolisher-egg-big",
  NEW_SPIECES_DEMOLISHER_EGG_BIG = "new-spieces-demolisher-egg-big",
  FRIEND_DEMOLISHER_EGG_BIG = "friend-demolisher-egg-big",

  DEMOLISHER_EGG_FROZEN = "demolisher-egg-frozen",
  NEW_SPIECES_DEMOLISHER_EGG_FROZEN = "new-spieces-demolisher-egg-frozen",
  FRIEND_DEMOLISHER_EGG_FROZEN = "friend-demolisher-egg-frozen",

  DEMOLISHER_EGG_MIDDLE_FROZEN = "demolisher-egg-middle-frozen",
  NEW_SPIECES_DEMOLISHER_EGG_MIDDLE_FROZEN = "new-spieces-demolisher-egg-middle-frozen",
  FRIEND_DEMOLISHER_EGG_MIDDLE_FROZEN = "friend-demolisher-egg-middle-frozen",

  DEMOLISHER_EGG_BIG_FROZEN = "demolisher-egg-big-frozen",
  NEW_SPIECES_DEMOLISHER_EGG_BIG_FROZEN = "new-spieces-demolisher-egg-big-frozen",
  FRIEND_DEMOLISHER_EGG_BIG_FROZEN = "friend-demolisher-egg-big-frozen",
}

return ConstantItemName