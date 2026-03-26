-- __BreedingDemolisher__/scripts/domain/pet/DemolisherParamsFactory.lua
-- ------------------------------------------------------------
-- Responsibility:
--   DemolisherParams の用途別生成入口を提供する。
--   - 旧 Customparam.new(...) の補完規則を維持する。
--   - 乱数デフォルト、default name、egg 用 name 補完を一元管理する。
--
-- Scope:
--   - size / quality / speed の乱数初期値
--   - traits の乱数初期値
--   - default name 未指定時の name 決定
--   - egg 状態用 name 補完
--   - born_tick 引き継ぎ
--
-- Out of scope:
--   - 遺伝計算そのもの
--   - spawn 後の clamp
--   - storage 登録
--
-- Notes:
--   - DeterministicRandom 依存はこのクラスへ閉じ込める。
--   - 旧 Customparam.new(...) と等価な生成を行う。
-- ------------------------------------------------------------
local DemolisherParamsFactory = {}

local DemolisherNames = require("__Manis_definitions__/scripts/definition/DemolisherNames")
local DRand = require("scripts.core.services.DeterministicRandom")
local DemolisherParams = require("scripts.domain.pet.DemolisherParams")
local DemolisherDefaultNameService = require("scripts.domain.pet.DemolisherDefaultNameService")
local CONST_DEMOLISHER_TRAIT = require("scripts.defines.constant_demolisher_traits")

local function copy_fields(fields)
  local out = {}
  if fields ~= nil then
    for k, v in pairs(fields) do
      out[k] = v
    end
  end
  return out
end

local function build_default_traits()
  return {
    [CONST_DEMOLISHER_TRAIT.SHORT_WARP] = 1 + DRand.random(0, 4) / 10,
    [CONST_DEMOLISHER_TRAIT.EMERGENCY_FOOD] = 1 + DRand.random(0, 4) / 10,
    [CONST_DEMOLISHER_TRAIT.BONUS_GROWTH] = 1 + DRand.random(0, 4) / 10
  }
end

local function build_egg_name(resolved)
  return "egg: size, quality, speed, max_life, max_satiety, max_growth = "
    .. tostring(resolved.size)
    .. ", " .. tostring(resolved.quality)
    .. ", " .. tostring(resolved.speed)
    .. ", " .. tostring(resolved.max_life)
    .. ", " .. tostring(resolved.max_satiety)
    .. ", " .. tostring(resolved.max_growth)
end

local function resolve_like_legacy_ctor(fields)
  local resolved = copy_fields(fields)
  local entity = resolved.entity

  resolved.entity_name = resolved.entity_name or (entity and entity.name) or DemolisherNames.SMALL
  resolved.name = resolved.name or DemolisherDefaultNameService.resolve(entity)

  if resolved.size == nil then
    resolved.size = DRand.random(100, 500)
  end

  if resolved.quality == nil then
    resolved.quality = DRand.random(1, 4) / 10
  end

  if resolved.speed == nil then
    resolved.speed = 1 + DRand.random(1, 4) / 10
  end

  if resolved.max_life == nil then
    resolved.max_life = 180
  end
  resolved.life = resolved.max_life

  if resolved.max_growth == nil then
    resolved.max_growth = 50
  end
  resolved.growth = 0

  if resolved.max_satiety == nil then
    resolved.max_satiety = 100
  end
  resolved.satiety = resolved.max_satiety

  resolved.lv = 1

  if resolved.traits == nil then
    resolved.traits = build_default_traits()
  end

  -- 旧実装は tick をそのまま代入していた。未指定なら nil のまま。
  resolved.born_tick = resolved.born_tick

  if resolved.name == "unknown" then
    resolved.name = build_egg_name(resolved)
  end

  return resolved
end

function DemolisherParamsFactory.new_randomized(fields)
  return DemolisherParams.new(resolve_like_legacy_ctor(fields))
end

function DemolisherParamsFactory.new_egg_params(fields)
  local resolved = copy_fields(fields)
  resolved.entity = nil
  return DemolisherParamsFactory.new_randomized(resolved)
end

function DemolisherParamsFactory.new_child_params(fields)
  local resolved = copy_fields(fields)
  resolved.entity = nil
  return DemolisherParamsFactory.new_randomized(resolved)
end

function DemolisherParamsFactory.new_pet_params(fields)
  return DemolisherParamsFactory.new_randomized(fields)
end

return DemolisherParamsFactory