-- __BreedingDemolisher__/scripts/domain/pet/DemolisherParams.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Demolisher 個体状態を表す plain table を生成する。
--   - 個体状態 shape を一箇所に集約する。
--   - Factory によって解決済みの値を plain table 化する。
--
-- Scope:
--   - entity
--   - entity_name
--   - name
--   - size / quality / speed
--   - max_life / life
--   - max_growth / growth
--   - max_satiety / satiety
--   - lv
--   - traits
--   - born_tick
--
-- Out of scope:
--   - 乱数による初期値決定
--   - default name 生成
--   - egg 用 name 補完
--   - 遺伝計算
--   - spawn clamp
-- ------------------------------------------------------------
local DemolisherParams = {}

function DemolisherParams.new(fields)
  fields = fields or {}

  return {
    entity = fields.entity,
    entity_name = fields.entity_name,
    name = fields.name,

    size = fields.size,
    quality = fields.quality,
    speed = fields.speed,

    max_life = fields.max_life,
    life = fields.life,

    max_growth = fields.max_growth,
    growth = fields.growth,

    max_satiety = fields.max_satiety,
    satiety = fields.satiety,

    lv = fields.lv,
    traits = fields.traits,
    born_tick = fields.born_tick,
  }
end

return DemolisherParams