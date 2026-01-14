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
--   - 追加（掃除）：default demolisher のうち quality が normal（またはquality無し）が
--     半径50に5体以上で密集している場合、その塊からランダムで1体だけ追加で移動させる
-- ----------------------------
local function build_move_targets(surface, area, ctx)
  -- 通常の移動対象（このModの守備範囲）
  local move_targets = DemolisherQuery.find_breeding_demolishers_range(surface, area)

  -- 掃除はヴルカヌス限定（不要ならこのifを消す）
  if surface.name ~= "vulcanus" then
    return move_targets
  end

  -- rng（FactorioのLuaRandomGenerator：rng(1,n)形式）
  local rng = (ctx and ctx.get_rng) and ctx.get_rng() or nil
  local function pick_index(n)
    if n <= 1 then return 1 end
    if rng then return rng(1, n) end
    return math.random(1, n)
  end

  local function is_normal_or_nil_quality(e)
    return (e.quality == nil) or (e.quality.name == nil) or (e.quality.name == "normal")
  end

  -- default demolisher を取得（個体数はせいぜい200想定なので全取得でOK）
  local defaults = DemolisherQuery.find_default_demolishers(surface)
  if not defaults or #defaults == 0 then
    return move_targets
  end

  -- quality normal(or nil)だけに絞る
  local normal_defaults = {}
  for _, e in pairs(defaults) do
    if e and e.valid and is_normal_or_nil_quality(e) then
      normal_defaults[#normal_defaults + 1] = e
    end
  end
  if #normal_defaults == 0 then
    return move_targets
  end

  -- ランダムサンプル → 密集判定
  local SAMPLE    = math.min(5, #normal_defaults)
  local RADIUS    = 50
  local THRESHOLD = 5

  for _ = 1, SAMPLE do
    local seed = normal_defaults[pick_index(#normal_defaults)]
    if seed and seed.valid then
      -- まず数だけ数える（軽量）
      local c = surface.count_entities_filtered{
        force    = "enemy",
        name     = DemolisherNames.ALL_DEFAULT,
        position = seed.position,
        radius   = RADIUS,
      }

      if c >= THRESHOLD then
        -- 当たり：実体を取って、normal(or nil)から1体選ぶ
        local cluster = surface.find_entities_filtered{
          force    = "enemy",
          name     = DemolisherNames.ALL_DEFAULT,
          position = seed.position,
          radius   = RADIUS,
        }

        local cluster_normal = {}
        for _, e in pairs(cluster) do
          if e and e.valid and is_normal_or_nil_quality(e) then
            cluster_normal[#cluster_normal + 1] = e
          end
        end

        if #cluster_normal > 0 then
          local picked = cluster_normal[pick_index(#cluster_normal)]

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
    get_surface = function(surface_name)
      return game.surfaces[surface_name]
    end,

    get_rocket_positions = get_rocket_positions,
    build_move_targets = build_move_targets,

    compute_move_rate = MovePolicy.compute_move_rate,
    can_move = MovePolicy.can_move,

    -- ★追加：rng注入（本Modのstorageに保持しているRNGを返す）
    get_rng = function()
      return ModRandomProvider.get()
    end,

    log = util.debug
  })
end

return E