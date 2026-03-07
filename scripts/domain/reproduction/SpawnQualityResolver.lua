-- __BreedingDemolisher__/scripts/domain/reproduction/SpawnQualityResolver.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Wild Reproduction における spawn quality を決定する。
--
-- Scope:
--   - evolution_factor と roll_value に基づく quality 決定
--   - quality rule の保持
--   - Factorio quality name の返却
--
-- Notes:
--   - deterministic random の生成自体は担当しない
--   - mutation / evolution による entity 決定は担当しない
--   - spawn 実行は担当しない
-- ------------------------------------------------------------
local SpawnQualityResolver = {}

--- resolve_spawn_quality
--- Responsibility:
---   evolution_factor と roll_value に基づいて spawn quality を決定する。
--- @param evolution_factor number
--- @param roll_value number
--- @return string quality_name
function SpawnQualityResolver.resolve_spawn_quality(evolution_factor, roll_value)
  if type(evolution_factor) ~= "number" then
    error("SpawnQualityResolver.resolve_spawn_quality: evolution_factor must be a number")
  end
  if type(roll_value) ~= "number" then
    error("SpawnQualityResolver.resolve_spawn_quality: roll_value must be a number")
  end
  if roll_value < 0 or roll_value >= 1 then
    error("SpawnQualityResolver.resolve_spawn_quality: roll_value must be in [0, 1)")
  end

  if evolution_factor < 0.1 then
    if roll_value < 0.01 then
      return "rare"
    elseif roll_value < 0.1 then
      return "uncommon"
    end

  elseif evolution_factor < 0.2 then
    if roll_value < 0.05 then
      return "rare"
    elseif roll_value < 0.2 then
      return "uncommon"
    end

  elseif evolution_factor < 0.3 then
    if roll_value < 0.1 then
      return "rare"
    elseif roll_value < 0.3 then
      return "uncommon"
    end

  elseif evolution_factor < 0.4 then
    if roll_value < 0.01 then
      return "epic"
    elseif roll_value < 0.16 then
      return "rare"
    elseif roll_value < 0.4 then
      return "uncommon"
    end

  elseif evolution_factor < 0.5 then
    if roll_value < 0.05 then
      return "epic"
    elseif roll_value < 0.25 then
      return "rare"
    elseif roll_value < 0.5 then
      return "uncommon"
    end

  elseif evolution_factor < 0.6 then
    if roll_value < 0.10 then
      return "epic"
    elseif roll_value < 0.3 then
      return "rare"
    elseif roll_value < 0.6 then
      return "uncommon"
    end

  elseif evolution_factor < 0.7 then
    if roll_value < 0.01 then
      return "legendary"
    elseif roll_value < 0.16 then
      return "epic"
    elseif roll_value < 0.41 then
      return "rare"
    elseif roll_value < 0.7 then
      return "uncommon"
    end

  elseif evolution_factor < 0.8 then
    if roll_value < 0.05 then
      return "legendary"
    elseif roll_value < 0.25 then
      return "epic"
    elseif roll_value < 0.55 then
      return "rare"
    elseif roll_value < 0.8 then
      return "uncommon"
    end

  elseif evolution_factor < 0.9 then
    if roll_value < 0.1 then
      return "legendary"
    elseif roll_value < 0.35 then
      return "epic"
    elseif roll_value < 0.65 then
      return "rare"
    elseif roll_value < 0.9 then
      return "uncommon"
    end

  elseif evolution_factor < 0.95 then
    if roll_value < 0.2 then
      return "legendary"
    elseif roll_value < 0.5 then
      return "epic"
    elseif roll_value < 0.75 then
      return "rare"
    elseif roll_value < 0.95 then
      return "uncommon"
    end

  elseif evolution_factor < 0.98 then
    if roll_value < 0.34 then
      return "legendary"
    elseif roll_value < 0.64 then
      return "epic"
    elseif roll_value < 0.84 then
      return "rare"
    elseif roll_value < 0.99 then
      return "uncommon"
    end

  else
    if roll_value < 0.5 then
      return "legendary"
    elseif roll_value < 0.85 then
      return "epic"
    elseif roll_value < 0.95 then
      return "rare"
    else
      return "uncommon"
    end
  end

  return "normal"
end

return SpawnQualityResolver