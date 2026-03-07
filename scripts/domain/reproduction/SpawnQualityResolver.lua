-- __BreedingDemolisher__/scripts/domain/reproduction/SpawnQualityResolver.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Wild Reproduction における spawn quality id を決定する。
--
-- Scope:
--   - base quality steps から QualityID を解決する
--   - prototypes.quality に基づく quality chain を構築する
--   - quality chain をキャッシュする
--
-- Notes:
--   - base steps の抽選自体は QualityRoller が担当する
--   - extension mod や quality shift は扱わない
--   - 返却値は create_segmented_unit に渡せる QualityID(string) である
-- ------------------------------------------------------------
local QualityRoller = require("scripts.domain.reproduction.QualityRoller")

local SpawnQualityResolver = {}

local _cached_quality_chain = nil

local function clamp(value, min_value, max_value)
  if value < min_value then
    return min_value
  end
  if value > max_value then
    return max_value
  end
  return value
end

local function build_default_quality_chain()
  return { "normal", "uncommon", "rare", "epic", "legendary" }
end

local function build_quality_chain_uncached()
  local chain = {}
  local seen = {}

  if prototypes == nil or prototypes.quality == nil then
    return build_default_quality_chain()
  end

  local quality_prototype = prototypes.quality["normal"]
  if quality_prototype == nil then
    return build_default_quality_chain()
  end

  local limit = 512
  for _ = 1, limit do
    if quality_prototype == nil then
      break
    end
    if seen[quality_prototype.name] == true then
      break
    end

    seen[quality_prototype.name] = true
    chain[#chain + 1] = quality_prototype.name
    quality_prototype = quality_prototype.next
  end

  if #chain <= 0 then
    return build_default_quality_chain()
  end

  return chain
end

local function get_quality_chain()
  if _cached_quality_chain ~= nil then
    return _cached_quality_chain
  end

  local chain = build_quality_chain_uncached()
  if type(chain) ~= "table" or #chain <= 0 then
    chain = build_default_quality_chain()
  end

  _cached_quality_chain = chain
  return _cached_quality_chain
end

--- clear_cache
--- Responsibility:
---   quality chain cache を明示的にクリアする。
function SpawnQualityResolver.clear_cache()
  _cached_quality_chain = nil
end

--- resolve_spawn_quality_id
--- Responsibility:
---   enemy evolution factor と乱数値から spawn quality id を決定する。
--- @param evolution_factor number
--- @param roll_value number
--- @return string quality_id
function SpawnQualityResolver.resolve_spawn_quality_id(evolution_factor, roll_value)
  local quality_steps = QualityRoller.choose_quality_steps(evolution_factor, roll_value)
  if type(quality_steps) ~= "number" then
    error("SpawnQualityResolver.resolve_spawn_quality_id: quality_steps must be a number")
  end
  if quality_steps < 0 then
    error("SpawnQualityResolver.resolve_spawn_quality_id: quality_steps must be >= 0")
  end

  local quality_chain = get_quality_chain()
  local quality_index = clamp(quality_steps + 1, 1, #quality_chain)
  local quality_id = quality_chain[quality_index]

  if type(quality_id) ~= "string" or quality_id == "" then
    error("SpawnQualityResolver.resolve_spawn_quality_id: resolved quality_id must be a non-empty string")
  end

  return quality_id
end

return SpawnQualityResolver