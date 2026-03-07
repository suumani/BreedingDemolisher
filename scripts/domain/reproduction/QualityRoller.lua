-- __BreedingDemolisher__/scripts/domain/reproduction/QualityRoller.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Wild Reproduction における base quality window の段数を決定する。
--
-- Scope:
--   - enemy evolution factor と乱数値から base quality steps を返す
--   - base window (normal..legendary) の抽選規則を保持する
--
-- Notes:
--   - 本クラスは steps の決定のみを担当する
--   - QualityID（quality prototype name）への変換は担当しない
--   - deterministic random の生成自体は担当しない
-- ------------------------------------------------------------
local QualityRoller = {}

--- choose_quality_steps
--- Responsibility:
---   enemy evolution factor と乱数値に基づき base quality steps を返す。
--- @param evolution_factor number
--- @param roll_value number
--- @return integer quality_steps
function QualityRoller.choose_quality_steps(evolution_factor, roll_value)
  if type(evolution_factor) ~= "number" then
    error("QualityRoller.choose_quality_steps: evolution_factor must be a number")
  end
  if type(roll_value) ~= "number" then
    error("QualityRoller.choose_quality_steps: roll_value must be a number")
  end
  if roll_value < 0 or roll_value >= 1 then
    error("QualityRoller.choose_quality_steps: roll_value must be in [0, 1)")
  end

  if evolution_factor < 0.1 then
    if roll_value < 0.01 then
      return 2 -- rare
    elseif roll_value < 0.1 then
      return 1 -- uncommon
    end

  elseif evolution_factor < 0.2 then
    if roll_value < 0.05 then
      return 2 -- rare
    elseif roll_value < 0.2 then
      return 1 -- uncommon
    end

  elseif evolution_factor < 0.3 then
    if roll_value < 0.1 then
      return 2 -- rare
    elseif roll_value < 0.3 then
      return 1 -- uncommon
    end

  elseif evolution_factor < 0.4 then
    if roll_value < 0.01 then
      return 3 -- epic
    elseif roll_value < 0.16 then
      return 2 -- rare
    elseif roll_value < 0.4 then
      return 1 -- uncommon
    end

  elseif evolution_factor < 0.5 then
    if roll_value < 0.05 then
      return 3 -- epic
    elseif roll_value < 0.25 then
      return 2 -- rare
    elseif roll_value < 0.5 then
      return 1 -- uncommon
    end

  elseif evolution_factor < 0.6 then
    if roll_value < 0.10 then
      return 3 -- epic
    elseif roll_value < 0.3 then
      return 2 -- rare
    elseif roll_value < 0.6 then
      return 1 -- uncommon
    end

  elseif evolution_factor < 0.7 then
    if roll_value < 0.01 then
      return 4 -- legendary
    elseif roll_value < 0.16 then
      return 3 -- epic
    elseif roll_value < 0.41 then
      return 2 -- rare
    elseif roll_value < 0.7 then
      return 1 -- uncommon
    end

  elseif evolution_factor < 0.8 then
    if roll_value < 0.05 then
      return 4 -- legendary
    elseif roll_value < 0.25 then
      return 3 -- epic
    elseif roll_value < 0.55 then
      return 2 -- rare
    elseif roll_value < 0.8 then
      return 1 -- uncommon
    end

  elseif evolution_factor < 0.9 then
    if roll_value < 0.1 then
      return 4 -- legendary
    elseif roll_value < 0.35 then
      return 3 -- epic
    elseif roll_value < 0.65 then
      return 2 -- rare
    elseif roll_value < 0.9 then
      return 1 -- uncommon
    end

  elseif evolution_factor < 0.95 then
    if roll_value < 0.2 then
      return 4 -- legendary
    elseif roll_value < 0.5 then
      return 3 -- epic
    elseif roll_value < 0.75 then
      return 2 -- rare
    elseif roll_value < 0.95 then
      return 1 -- uncommon
    end

  elseif evolution_factor < 0.98 then
    if roll_value < 0.34 then
      return 4 -- legendary
    elseif roll_value < 0.64 then
      return 3 -- epic
    elseif roll_value < 0.84 then
      return 2 -- rare
    elseif roll_value < 0.99 then
      return 1 -- uncommon
    end

  else
    if roll_value < 0.5 then
      return 4 -- legendary
    elseif roll_value < 0.85 then
      return 3 -- epic
    elseif roll_value < 0.95 then
      return 2 -- rare
    else
      return 1 -- uncommon
    end
  end

  return 0 -- normal
end

return QualityRoller