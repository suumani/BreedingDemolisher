-- scripts/services/DemolisherRushService.lua

-- ----------------------------
-- デモリッシャーラッシュ用
-- 初期配置のデモリッシャー(normal品質のデモリッシャー)を母集団とし、
-- そのうち一部(進化度に応じて5～20体)を「抽選対象」として選ぶ。
-- 抽選対象の各個体は確率で産卵し、産卵する場合は進化度に応じて1～5個の卵を産む。
-- 卵は親の周辺に配置され、respawn_queueに登録される。
-- ラッシュ1回あたりの増加は最大100（ただし残り枠まで）。
-- ----------------------------
local DemolisherRushService = {}
local DRand = require("scripts.util.DeterministicRandom")
local DemolisherQuery = require("__Manis_lib__/scripts/queries/DemolisherQuery")
local SpawnPositionService = require("scripts.services.SpawnPositionService")
local TableUtil = require("scripts.util.TableUtil")

-- normal品質フィルター
local function is_normal_quality_demolisher(entity)
  return entity.quality.name == "normal"
end

-- 進化度に応じた抽選対象数 k を決める（5～20想定）
-- k = 5 + evo*10 + (evo >= 0.99 ? 5 : 0)
-- ※整数化は ceil で行い、0.99のとき 19.9 -> 20 となるようにする
local function calc_candidate_count(evo)
  local k = 5 + (evo * 10)
  if evo >= 0.99 then
    k = k + 5
  end
  return math.ceil(k)
end

-- 卵数上限：1 + evo*4（整数化は ceil で、0.99のとき 4.96 -> 5）
local function calc_max_eggs_per_parent(evo)
  return math.ceil(1 + (evo * 4))
end

-- normal_demolishers から k 体を「抽選対象」として非復元で選ぶ（部分シャッフル）
local function choose_candidates(normal_demolishers, k)
  local n = #normal_demolishers
  if k > n then k = n end
  if k <= 0 then return {} end

  -- shallow copy
  local tmp = {}
  for i = 1, n do
    tmp[i] = normal_demolishers[i]
  end

  -- partial Fisher–Yates: i..n からランダムに選んで先頭へ
  local candidates = {}
  for i = 1, k do
    local j = DRand.random(i, n)
    tmp[i], tmp[j] = tmp[j], tmp[i]
    candidates[i] = tmp[i]
  end
  return candidates
end

local function extract_unnormal_demolishers(all_demolishers)
	local unnormal_demolishers = {}
	for _, e in pairs(all_demolishers) do
		if not is_normal_quality_demolisher(e) then
		table.insert(unnormal_demolishers, e)
		end
 	end
	
	return unnormal_demolishers
end

local function extract_normal_demolishers(all_demolishers)

	local normal_demolishers = {}
	for _, e in pairs(all_demolishers) do
		if is_normal_quality_demolisher(e) then
		table.insert(normal_demolishers, e)
		end
 	end
	
	return normal_demolishers
end

function DemolisherRushService.demolisher_rush(surface, evolution_factor)

	-- 全てのデモリッシャーの取得
	local all_demolishers = DemolisherQuery.find_all_demolishers(surface) 

	-- result_count が200以上ならラッシュしない
	local unnormal_demolishers = extract_unnormal_demolishers(all_demolishers)
	local result_count = #unnormal_demolishers
	if #unnormal_demolishers >= 200 then
		game_print.message("[vulcanus] demolishers abound...")
		return
	end

	-- ラッシュ1回あたりの増加は最大100（ただし残り枠まで）
	local remaining_capacity = 200 - result_count
	local egg_budget = math.min(100, remaining_capacity)
	if egg_budget <= 0 then
		game_print.message("[vulcanus] demolishers abound...")
		return
	end

  -- 中心地に向けて繁殖地が拡大する（最も(0,0)に近いロケットサイロ）
  local nearest_silo_pos = {x = 0, y = 0}
  local silos = surface.find_entities_filtered{type = "rocket-silo"}

  if silos ~= nil and #silos ~= 0 then
    local min_length
    for _, silo in pairs(silos) do
      if min_length == nil then
        nearest_silo_pos = silo.position
        min_length = nearest_silo_pos.x ^ 2 + nearest_silo_pos.y ^ 2
      elseif min_length > (silo.position.x ^ 2 + silo.position.y ^ 2) then
        min_length = (silo.position.x ^ 2 + silo.position.y ^ 2)
        nearest_silo_pos = silo.position
      end
    end
  end

  -- デモリッシャーの取得（normalのみを母集団とする）
  local normal_demolishers = {}
  for _, e in pairs(DemolisherQuery.find_all_demolishers(surface)) do
    if is_normal_quality_demolisher(e) then
      table.insert(normal_demolishers, e)
    end
  end

  -- normal demolisherが居ない（ゲーム上のイレギュラー例外状態）
  if #normal_demolishers == 0 then
    return
  end

  -- source_count に依存せず、sourceのデモリッシャー5～20体を抽選対象として選ぶ（evolution依存）
  local k = calc_candidate_count(evolution_factor)
  local candidates = choose_candidates(normal_demolishers, k)

  -- 抽選対象が0体（イレギュラー）
  if #candidates == 0 then
    return
  end

  -- 抽選対象の各sourceが確率で産卵（産卵率は進化度の半分）
  local spawn_prob = evolution_factor / 2
  local max_eggs = calc_max_eggs_per_parent(evolution_factor)

  local enqueued_eggs = 0
  local egg_seq = 0 -- respawn_tick用（キュー投入順に1分刻み）

  for _, parent in pairs(candidates) do
    if enqueued_eggs >= egg_budget then
      break
    end

    if DRand.random() < spawn_prob then
      local egg_n = DRand.random(1, max_eggs) -- 1～(1+evo*4) ※整数上限

      for _ = 1, egg_n do
        if enqueued_eggs >= egg_budget then
          break
        end

        local parent_pos = parent.position
        local spawn_position = SpawnPositionService.getSpawnPosition(
          surface,
          evolution_factor,
          parent_pos,
          nearest_silo_pos
        )

        if spawn_position ~= nil then
          egg_seq = egg_seq + 1
          table.insert(storage.respawn_queue, {
            surface = parent.surface,
            entity_name = parent.name,
            position = spawn_position,
            evolution_factor = evolution_factor,
            force = parent.force,
            respawn_tick = game.tick + 18000 + 3600 * egg_seq -- 5分後から1分間隔で孵化
          })
          enqueued_eggs = enqueued_eggs + 1
        end
      end
    end
  end

  if enqueued_eggs ~= 0 then
    game_print.message("[vulcanus]demolishers are multiplying... more than " .. enqueued_eggs .. " eggs are missing...")
  else
    game_print.message("[vulcanus]demolishers are multiplying... but nothing happen...")
  end
end

return DemolisherRushService