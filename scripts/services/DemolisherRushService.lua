-- __BreedingDemolisher__/scripts/services/DemolisherRushService.lua

-- ----------------------------
-- デモリッシャーラッシュ用
--
-- 概要:
-- - 親候補から一部（進化度に応じて5～20体）を抽選対象として選ぶ
-- - 抽選対象の各個体は確率で産卵し、進化度に応じて卵数が増える
-- - 卵は親の周辺に配置され、respawn_queue に登録される
-- - ラッシュ1回あたりの増加は最大100（ただし残り枠まで）
--
-- 重要:
-- - cap は進化度依存（段階テーブル）
-- - cap計算対象から「標準3種（small/medium/big）かつ quality=nil/normal」を除外する
--   （広大開拓により自然配置されるオリジナル個体が、繁殖イベント遭遇を阻害しないため）
-- - 親候補は DemolisherNames.ALL_BREEDING_PARENTS（default3種 + breeding + 非致命boss）を使用する
-- ----------------------------
local DemolisherRushService = {}

local DRand = require("scripts.util.DeterministicRandom")
local DemolisherQuery = require("__Manis_lib__/scripts/queries/DemolisherQuery")
local SpawnPositionService = require("scripts.services.SpawnPositionService")
local util  = require("scripts.common.util")
local EggMutationPolicy = require("scripts.policies.EggMutationPolicy")

-- ---------------------------------------------------------------------
-- Tunables（今回の合意値）
-- ---------------------------------------------------------------------
local MAX_EGGS_PER_RUSH = 100
local MIN_PARENTS = 3
local P_MIN = 0.15
local MIN_EGGS_TWO_RATE = 0.45

-- ---------------------------------------------------------------------
-- cap: evolution_factor -> cap
-- ---------------------------------------------------------------------
local function calc_cap(evo)
  -- 段階テーブル（穴なし）
  if evo <= 0.05 then return 40 end
  if evo <= 0.15 then return 55 end
  if evo <= 0.25 then return 70 end
  if evo <= 0.35 then return 85 end
  if evo <= 0.45 then return 100 end
  if evo <= 0.55 then return 115 end
  if evo <= 0.65 then return 130 end
  if evo <= 0.75 then return 145 end
  if evo <= 0.85 then return 160 end
  if evo <= 0.95 then return 175 end
  if evo <= 0.98 then return 190 end
  return 200
end

-- ---------------------------------------------------------------------
-- cap計算対象数（counted population）
-- - DemolisherQuery.is_default_small_medium_big_normal(entity) を使い除外判定する
-- ---------------------------------------------------------------------
local function count_counted_population(surface)
  local all = DemolisherQuery.find_demolishers(surface)
  local cnt = 0
  for _, e in pairs(all) do
    if e and e.valid then
      -- 標準3種×quality nil/normal は cap 対象外
      if not DemolisherQuery.is_default_small_medium_big_normal(e) then
        cnt = cnt + 1
      end
    end
  end
  return cnt
end

-- ---------------------------------------------------------------------
-- 最低保証（卵数）：経過時間（時間）に応じて増える
-- ---------------------------------------------------------------------
local function calc_min_eggs_since_first_kill()
  local t0 = storage.bd_demolisher_first_kill_tick
  if not t0 then
    return 0
  end

  local dt = game.tick - t0
  if dt < 0 then
    return 0
  end

  local hours = dt / (60 * 60 * 60)

  if hours < 2 then
    return 1
  elseif hours < 4 then
    return 2
  elseif hours < 8 then
    return 3
  elseif hours < 16 then
    return 4
  elseif hours < 32 then
    return 5
  elseif hours < 128 then
    return 6
  else
    return 2 -- ゲーム攻略上の最終ラッシュはせいぜい128時間までと想定
  end
end

-- 進化度に応じた抽選対象数 k（5～20想定）
-- k = 5 + evo*10 + (evo >= 0.99 ? 5 : 0)
local function calc_candidate_count(evo)
  local k = 5 + (evo * 10)
  if evo >= 0.99 then
    k = k + 5
  end
  return math.ceil(k)
end

-- 卵数上限：1 + evo*4（ceil）
local function calc_max_eggs_per_parent(evo)
  return math.ceil(1 + (evo * 4))
end

-- all_demolishers から k 体を「抽選対象」として非復元で選ぶ（部分シャッフル）
local function choose_candidates(all_demolishers, k)
  local n = #all_demolishers
  if k > n then k = n end
  if k <= 0 then return {} end

  local tmp = {}
  for i = 1, n do tmp[i] = all_demolishers[i] end

  local candidates = {}
  for i = 1, k do
    local j = DRand.random(i, n)
    tmp[i], tmp[j] = tmp[j], tmp[i]
    candidates[i] = tmp[i]
  end
  return candidates
end

-- 親ごとの最低卵数（1 or 2 抽選）
local function roll_min_eggs()
  return (DRand.random() < MIN_EGGS_TWO_RATE) and 2 or 1
end

-- 親当選：最低保証つき
local function pick_spawn_parents(candidates, spawn_prob)
  local spawn_parents = {}
  for _, parent in pairs(candidates) do
    if DRand.random() < spawn_prob then
      spawn_parents[#spawn_parents + 1] = parent
    end
  end

  while #spawn_parents < math.min(MIN_PARENTS, #candidates) do
    spawn_parents[#spawn_parents + 1] = candidates[DRand.random(1, #candidates)]
  end

  return spawn_parents
end

-- 中心地に向けて繁殖地が拡大する（最も(0,0)に近いロケットサイロ）
local function find_nearest_silo_pos(surface)
  local nearest = { x = 0, y = 0 }
  local silos = surface.find_entities_filtered{ type = "rocket-silo" }
  if not silos or #silos == 0 then
    return nearest
  end

  local min_length
  for _, silo in pairs(silos) do
    local p = silo.position
    local len = p.x ^ 2 + p.y ^ 2
    if min_length == nil or len < min_length then
      min_length = len
      nearest = p
    end
  end
  return nearest
end

function DemolisherRushService.demolisher_rush(surface, evolution_factor)
  -- respawn_queueがないケースの保険（運用次第で不要なら消してOK）
  storage.respawn_queue = storage.respawn_queue or {}

  -- cap（進化度依存）
  local cap = calc_cap(evolution_factor)

  -- cap計算対象数（除外ルール込み）
  local counted = count_counted_population(surface)
  if counted >= cap then
    util.print("[vulcanus] demolishers abound...")
    return
  end

  -- ラッシュ1回あたりの増加は最大100（ただし残り枠まで）
  local remaining_capacity = cap - counted
  local egg_budget = math.min(MAX_EGGS_PER_RUSH, remaining_capacity)
  if egg_budget <= 0 then
    util.print("[vulcanus] demolishers abound...")
    return
  end

  local nearest_silo_pos = find_nearest_silo_pos(surface)

  -- 親候補（default3種 + breeding + 非致命boss）
  local parent_pool = DemolisherQuery.find_breeding_parent_demolishers(surface)
  if not parent_pool or #parent_pool == 0 then
    return
  end

  -- 抽選対象
  local k = calc_candidate_count(evolution_factor)
  local candidates = choose_candidates(parent_pool, k)
  if #candidates == 0 then
    return
  end

  -- 確率カーブ調整（序盤底上げ）
  local spawn_prob = math.max(P_MIN, (evolution_factor ^ 0.7) / 2)
  local max_eggs = calc_max_eggs_per_parent(evolution_factor)

  -- 親当選（最低3体保証）
  local spawn_parents = pick_spawn_parents(candidates, spawn_prob)

  local enqueued_eggs = 0
  local egg_seq = 0 -- respawn_tick用（キュー投入順に1分刻み）

  -- 通常分の産卵
  for _, parent in pairs(spawn_parents) do
    if enqueued_eggs >= egg_budget then break end

    local rolled = DRand.random(1, max_eggs)
    local egg_n = math.max(roll_min_eggs(), rolled)

    for _ = 1, egg_n do
      if enqueued_eggs >= egg_budget then break end

      local spawn_position = SpawnPositionService.getSpawnPosition(
        surface,
        evolution_factor,
        parent.position,
        nearest_silo_pos
      )

      if spawn_position ~= nil then
        egg_seq = egg_seq + 1
        storage.respawn_queue[#storage.respawn_queue + 1] = {
          surface = parent.surface,
          entity_name = EggMutationPolicy.pick_egg_entity_name(parent.name, evolution_factor),
          position = spawn_position,
          evolution_factor = evolution_factor,
          force = parent.force,
          respawn_tick = game.tick + 18000 + 3600 * egg_seq
        }
        enqueued_eggs = enqueued_eggs + 1
      end
    end
  end

  -- 最低保証（長時間プレイで「連続0」を防ぐ）
  local min_eggs = calc_min_eggs_since_first_kill()
  if min_eggs > egg_budget then
    min_eggs = egg_budget
  end

  if enqueued_eggs < min_eggs then
    local need = min_eggs - enqueued_eggs

    for _ = 1, need do
      if enqueued_eggs >= egg_budget then break end

      local parent = candidates[DRand.random(1, #candidates)]
      local spawn_position = SpawnPositionService.getSpawnPosition(
        surface,
        evolution_factor,
        parent.position,
        nearest_silo_pos
      )

      if spawn_position ~= nil then
        egg_seq = egg_seq + 1
        storage.respawn_queue[#storage.respawn_queue + 1] = {
          surface = parent.surface,
          entity_name = EggMutationPolicy.pick_egg_entity_name(parent.name, evolution_factor),
          position = spawn_position,
          evolution_factor = evolution_factor,
          force = parent.force,
          respawn_tick = game.tick + 18000 + 3600 * egg_seq
        }
        enqueued_eggs = enqueued_eggs + 1
      end
    end
  end

  if enqueued_eggs ~= 0 then
    util.print("[vulcanus] demolishers are multiplying... more than " .. enqueued_eggs .. " eggs are missing...")
  else
    util.print("[vulcanus] demolishers are multiplying... but nothing happened...")
  end
end

return DemolisherRushService