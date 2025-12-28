-- scripts/services/VulcanusDemolisherMovePlanner.lua
-- ----------------------------
-- Responsibility:
--   30分イベントで MovePlan を作成する。
--   - generated chunk の min/max を取得（chunk座標）
--   - タイル座標AABBへ変換（×32）
--   - 長方形AABBの横幅/縦幅で 2x10 / 10x2 を決める（同値は2x10）
--   - セル順をシャッフルして保存
-- ----------------------------
local P = {}

local DRand = require("scripts.util.DeterministicRandom")

local SURFACE_NAME = "vulcanus"

local function get_generated_chunk_bounds(surface)
  local min_cx, min_cy, max_cx, max_cy = nil, nil, nil, nil
  for chunk in surface.get_chunks() do
    local x, y = chunk.x, chunk.y
    if min_cx == nil or x < min_cx then min_cx = x end
    if max_cx == nil or x > max_cx then max_cx = x end
    if min_cy == nil or y < min_cy then min_cy = y end
    if max_cy == nil or y > max_cy then max_cy = y end
  end
  if min_cx == nil then
    return nil
  end
  return { min_cx = min_cx, min_cy = min_cy, max_cx = max_cx, max_cy = max_cy }
end

local function chunk_bounds_to_tile_rect(b)
  return {
    left_top = { x = b.min_cx * 32, y = b.min_cy * 32 },
    right_bottom = { x = (b.max_cx + 1) * 32, y = (b.max_cy + 1) * 32 }
  }
end

local function shuffled_order(cell_count)
  local order = {}
  for i = 1, cell_count do order[i] = i end
  for i = cell_count, 2, -1 do
    local j = DRand.random(1, i)
    order[i], order[j] = order[j], order[i]
  end
  return order
end

function P.build_plan(planned_total, positions)
  local surface = game.surfaces[SURFACE_NAME]
  if not surface then return nil end
  if not positions or #positions == 0 then return nil end
  if not planned_total or planned_total <= 0 then return nil end

  local cb = get_generated_chunk_bounds(surface)
  if not cb then return nil end

  local rect = chunk_bounds_to_tile_rect(cb)
  local w = rect.right_bottom.x - rect.left_top.x
  local h = rect.right_bottom.y - rect.left_top.y

  -- 同値は縦2横10（rows=2, cols=10）に倒す
  local rows, cols
  if w >= h then
    rows, cols = 2, 10
  else
    rows, cols = 10, 2
  end

  local cell_count = rows * cols

  return {
    surface_name = SURFACE_NAME,
    positions = positions,              -- ロケットサイロ履歴（座標配列）
    rect = rect,                        -- タイル座標AABB
    rows = rows,
    cols = cols,
    order = shuffled_order(cell_count),
    step = 1,                           -- 次に処理するセルの順序index（1..cell_count）
    planned_total = planned_total,
    moved_so_far = 0,
    created_tick = game.tick
  }
end

return P