-- __BreedingDemolisher__/scripts/core/services/DeterministicRandom.lua
-- ------------------------------------------------------------
-- 責務:
--   Factorio公式の同期乱数(LuaRandomGenerator)を使い、
--   math.random互換APIを提供する。
--
-- 方針:
--   - グローバルRNGは map seed に依存させる。
--   - storage は Mod ごとに独立だが、bd 内の一貫性のため
--     RNG は storage.bd 配下に保持する。
--
-- Policy alignment:
--   - init() is mandatory in bootstrap (ImmediateInitializer).
--   - Runtime must NOT silently self-heal missing init; missing init is a precondition violation (error()).
-- ------------------------------------------------------------
local DeterministicRandom = {}

local function bd_root()
  if not storage then
    error("DeterministicRandom: storage is not available.")
  end
  storage.bd = storage.bd or {}
  return storage.bd
end

--- init()
--- 責務:
---   storage に同期乱数生成器を確実に用意する
---   （on_init/on_configuration_changedから呼ぶ）
function DeterministicRandom.init()
  local bd = bd_root()

  if not bd._det_rand_rng then
    -- seed無し → map seed に基づく RNG
    bd._det_rand_rng = game.create_random_generator()
  end
end

--- _rng()
--- 責務:
---   初期化済みの RNG を取得する。
---   未初期化は前提違反として error()（黙って生成しない）。
local function _rng()
  local bd = bd_root()

  if not bd._det_rand_rng then
    error("DeterministicRandom: RNG is not initialized. Call DeterministicRandom.init() in ImmediateInitializer.")
  end
  return bd._det_rand_rng
end

--- create_generator(seed)
--- 責務:
---   seed 指定のローカルRNG(LuaRandomGenerator)を生成して返す。
--- Notes:
---   - storage を汚さない（局所用途）。
---   - rng() は [0,1) の実数を返す。
function DeterministicRandom.create_generator(seed)
  return game.create_random_generator(seed)
end

--- random([min], [max])
--- 責務:
---   math.random互換。
---   - random() -> [0, 1) の実数
---   - random(max) / random(min,max) -> 整数（両端含む）
function DeterministicRandom.random(a, b)
  local rng = _rng()

  if a == nil and b == nil then
    return rng()
  end

  if b == nil then
    local max = tonumber(a)
    if not max then
      error("DeterministicRandom.random(max): max must be a number")
    end
    if max < 1 then
      error("DeterministicRandom.random(max): max must be >= 1")
    end
    return 1 + math.floor(rng() * max)
  end

  local min = tonumber(a)
  local max = tonumber(b)
  if not min or not max then
    error("DeterministicRandom.random(min,max): args must be numbers")
  end
  if max < min then
    error("DeterministicRandom.random(min,max): max must be >= min")
  end

  return min + math.floor(rng() * (max - min + 1))
end

return DeterministicRandom