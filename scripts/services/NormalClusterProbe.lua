-- scripts/services/NormalClusterProbe.lua
-- ----------------------------
-- Responsibility:
--   旧セーブ互換のための例外処理として、
--   normal demolisher のうちランダムに最大N体だけをサンプルし、
--   半径R（AABB）内に normal が閾値T以上いる場合、
--   そのクラスターから「移動対象として例外的に扱う normal」を最大1体返す。
--   （誤爆許容。確実性より低負荷・収束性を優先）
-- ----------------------------
local Probe = {}

local DRand = require("scripts.util.DeterministicRandom")
local DemolisherQuery = require("__Manis_lib__/scripts/queries/DemolisherQuery")

local DEFAULT_SAMPLES = 5
local DEFAULT_RADIUS = 150
local DEFAULT_THRESHOLD = 4

local function pick_unique_random(list, k)
  local n = #list
  if n == 0 or k <= 0 then return {} end
  if k > n then k = n end

  local tmp = {}
  for i = 1, n do tmp[i] = list[i] end

  local picked = {}
  for i = 1, k do
    local j = DRand.random(i, n)
    tmp[i], tmp[j] = tmp[j], tmp[i]
    picked[i] = tmp[i]
  end
  return picked
end

local function count_normal(neighbors)
  local c = 0
  for _, e in pairs(neighbors) do
    if e.quality.name == "normal" then
      c = c + 1
    end
  end
  return c
end

-- returns: entity or nil
function Probe.pick_one(surface, normal_demolishers, opts)
  if not normal_demolishers or #normal_demolishers == 0 then
    return nil
  end

  opts = opts or {}
  local samples = opts.samples or DEFAULT_SAMPLES
  local radius = opts.radius or DEFAULT_RADIUS
  local threshold = opts.threshold or DEFAULT_THRESHOLD

  local picked = pick_unique_random(normal_demolishers, samples)

  for _, e in pairs(picked) do
    local neighbors = DemolisherQuery.find_neighbor_demolishers(surface, {
      { x = e.position.x - radius, y = e.position.y - radius },
      { x = e.position.x + radius, y = e.position.y + radius }
    })

    local n = count_normal(neighbors)
    if n >= threshold then
      -- 最小仕様：サンプル本人を返す（クラスターから1体だけ動かす）
      return e
    end
  end

  return nil
end

return Probe