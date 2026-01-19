-- __BreedingDemolisher__/scripts/services/VulcanusDemolisherMoveExecutor.lua
-- ----------------------------
-- Responsibility:
--   Lib側の共通実行器（DemolisherMoveStepExecutor）に対して、
--   繁殖Mod固有の「移動対象抽選」と「ポリシー」を注入して1ステップ実行する。
--   乱数状態（LuaRandomGenerator）は本Modのstorageで所有し、deps.get_rngで注入する。
-- ----------------------------
local E = {}

-- Lib共通実行器
local StepExecutor = require("__Manis_lib__/scripts/domain/demolisher/move/DemolisherMoveStepExecutor")

-- 共通クエリ（Lib）
local DemolisherQuery = require("__Manis_lib__/scripts/queries/DemolisherQuery")

-- Mod固有ロジック
local NormalClusterProbe = require("scripts.services.NormalClusterProbe")
local MovePolicy = require("scripts.policies.vulcanus_demolisher_move_policy")
local ModRandomProvider = require("scripts.services.ModRandomProvider")

local util  = require("scripts.common.util")

-- ----------------------------
-- Mod固有：移動対象抽選
--   - 通常：BreedingDemolisher（manis-small/medium/big）のみ
--   - 追加（掃除）：default demolisher が半径50に5体以上で密集している場合、
--     その塊からランダムで1体だけ追加で移動させる（品質は不問）
-- ----------------------------
local function build_move_targets(surface, area, ctx)
  -- 通常の移動対象（このModの守備範囲）
  local move_targets = DemolisherQuery.find_breeding_demolishers_range(surface, area)

  -- 掃除はヴルカヌス限定
  if surface.name ~= "vulcanus" then
    return move_targets
  end

  -- rng（Factorio LuaRandomGenerator：rng(1,n)形式）
  local rng = (ctx and ctx.get_rng) and ctx.get_rng() or nil
  local function pick_index(n)
    if n <= 1 then return 1 end
    if rng then return rng(1, n) end
    return math.random(1, n)
  end

  -- default demolisher を取得（ここでDefinition参照はDemolisherQueryが担当）
  local defaults = DemolisherQuery.find_default_demolishers(surface)
  if not defaults or #defaults == 0 then
    return move_targets
  end

  -- validなものだけに絞る（念のため）
  local valid_defaults = {}
  for _, e in pairs(defaults) do
    if e and e.valid then
      valid_defaults[#valid_defaults + 1] = e
    end
  end
  if #valid_defaults == 0 then
    return move_targets
  end

  -- ランダムサンプル → 密集判定（配列同士の距離判定で完結）
  local SAMPLE    = math.min(5, #valid_defaults)
  local RADIUS    = 50
  local R2        = RADIUS * RADIUS
  local THRESHOLD = 5

  local function count_neighbors(center)
    local cx, cy = center.position.x, center.position.y
    local cnt = 0
    for _, other in pairs(valid_defaults) do
      if other.valid then
        local dx = other.position.x - cx
        local dy = other.position.y - cy
        if (dx*dx + dy*dy) <= R2 then
          cnt = cnt + 1
          if cnt >= THRESHOLD then
            return cnt
          end
        end
      end
    end
    return cnt
  end

  local function collect_cluster(center)
    local cx, cy = center.position.x, center.position.y
    local cluster = {}
    for _, other in pairs(valid_defaults) do
      if other.valid then
        local dx = other.position.x - cx
        local dy = other.position.y - cy
        if (dx*dx + dy*dy) <= R2 then
          cluster[#cluster + 1] = other
        end
      end
    end
    return cluster
  end

  for _ = 1, SAMPLE do
    local seed = valid_defaults[pick_index(#valid_defaults)]
    if seed and seed.valid then
      local c = count_neighbors(seed)
      if c >= THRESHOLD then
        local cluster = collect_cluster(seed)
        if #cluster > 0 then
          local picked = cluster[pick_index(#cluster)]

          -- move_targetsに既に同じentityが入っていなければ追加（掃除は1体だけ）
          local exists = false
          for _, t in pairs(move_targets) do
            if t == picked then
              exists = true
              break
            end
          end
          if not exists then
            move_targets[#move_targets + 1] = picked
          end
        end

        break -- 掃除は最大1体
      end
    end
  end

  return move_targets
end

-- planからロケット候補座標配列を取得（互換: rocket_positions / positions）
local function get_rocket_positions(plan)
  return plan.rocket_positions or plan.positions
end

function E.execute_one_step(plan)
  return StepExecutor.execute_one_step(plan, {
    get_surface = function(surface_name) return game.surfaces[surface_name] end,
    get_rocket_positions = get_rocket_positions,
    build_move_targets = build_move_targets,
    compute_move_rate = MovePolicy.compute_move_rate,
    can_move = MovePolicy.can_move,
    get_rng = function() return ModRandomProvider.get() end,
    mod_name = "BreedingDemolisher",
    log = util.debug
  })
end

return E