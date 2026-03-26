-- __BreedingDemolisher__/scripts/core/services/DeterministicRandom.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Factorio 公式の同期乱数 (LuaRandomGenerator) を使い、
--   math.random 互換 API を提供する。
--
-- Policy:
--   - グローバル RNG は map seed に依存させる。
--   - RNG は storage.bd 配下に保持する。
--   - init() は bootstrap で必ず呼ばれる。
--   - runtime は missing init / missing storage root を自己修復しない。
--     前提違反として error() する。
-- ------------------------------------------------------------
local DeterministicRandom = {}

local function expect_bd_root()
  if storage == nil then
    error("DeterministicRandom: storage is not available.")
  end
  if storage.bd == nil then
    error("DeterministicRandom: storage.bd is nil. Call StorageBootstrap.bootstrap() before DeterministicRandom.init().")
  end
  return storage.bd
end

--- init()
--- Responsibility:
---   bootstrap 時に同期乱数生成器を初期化する。
function DeterministicRandom.init()
  local bd = expect_bd_root()

  if bd._det_rand_rng == nil then
    bd._det_rand_rng = game.create_random_generator()
  end
end

--- _rng()
--- Responsibility:
---   初期化済みの RNG を取得する。
---   未初期化は前提違反として error() する。
local function _rng()
  local bd = expect_bd_root()

  if bd._det_rand_rng == nil then
    error("DeterministicRandom: RNG is not initialized. Call BreedingDemolisherBootstrap.run_full_bootstrap() first.")
  end
  return bd._det_rand_rng
end

--- create_generator(seed)
--- Responsibility:
---   seed 指定のローカル RNG (LuaRandomGenerator) を生成して返す。
--- Notes:
---   - storage は変更しない。
function DeterministicRandom.create_generator(seed)
  return game.create_random_generator(seed)
end

--- random([min], [max])
--- Responsibility:
---   math.random 互換。
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