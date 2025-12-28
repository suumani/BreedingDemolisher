-- scripts/services/VulcanusDemolisherMoveExecutor.lua
local E = {}

local DemolisherQuery = require("__Manis_lib__/scripts/queries/DemolisherQuery")
local NormalClusterProbe = require("scripts.services.NormalClusterProbe")
local mover = require("scripts.services.combat_demolisher_mover")
local util  = require("scripts.common.util")

local function cell_index_to_area(plan, idx)
  local lt = plan.rect.left_top
  local rb = plan.rect.right_bottom
  local w = rb.x - lt.x
  local h = rb.y - lt.y

  local cell_w = w / plan.cols
  local cell_h = h / plan.rows

  local r = math.floor((idx - 1) / plan.cols)  -- 0-based row
  local c = (idx - 1) % plan.cols              -- 0-based col

  local x1 = lt.x + c * cell_w
  local y1 = lt.y + r * cell_h
  local x2 = lt.x + (c + 1) * cell_w
  local y2 = lt.y + (r + 1) * cell_h

  return { { x = x1, y = y1 }, { x = x2, y = y2 } }
end

local function compute_cap(plan)
  local remaining = plan.planned_total - plan.moved_so_far
  if remaining <= 0 then return 0 end

  local cell_count = plan.rows * plan.cols
  local remaining_cells = cell_count - (plan.step - 1)
  if remaining_cells <= 0 then
    return remaining
  end

  local cap = math.floor(remaining / remaining_cells)
  if cap < 1 then cap = 1 end -- 残予算がある限り最低1
  return cap
end

function E.execute_one_step(plan)
  local surface = game.surfaces[plan.surface_name]
  if not surface then return 0 end

  local cell_count = plan.rows * plan.cols
  if plan.step > cell_count then
    return 0
  end

  local idx = plan.order[plan.step]
  local area = cell_index_to_area(plan, idx)

  -- セル内のデモリッシャーを取得（軽量）
  local cell_demolishers = DemolisherQuery.find_neighbor_demolishers(surface, area)

  local normal = {}
  local unnormal = {}

  for _, e in pairs(cell_demolishers) do
    if e.quality.name == "normal" then
      table.insert(normal, e)
    else
      table.insert(unnormal, e)
    end
  end

  -- non-normal優先
  local move_targets = unnormal

  -- 例外normal（セル内normalからランダム→近傍150で4以上なら選ぶ）
  local extra = NormalClusterProbe.pick_one(surface, normal)
  if extra then
    table.insert(move_targets, extra)
  end

  local cap = compute_cap(plan)
  if cap <= 0 then
    plan.step = plan.step + 1
    return 0
  end

  if #move_targets > cap then
    local sliced = {}
    for i = 1, cap do sliced[i] = move_targets[i] end
    move_targets = sliced
  end

  local evo = game.forces.enemy.get_evolution_factor(surface)
  local move_rate = #plan.positions
  if move_rate > 3 then move_rate = 3 end

  local moved = mover.move(move_targets, evo, move_rate, plan.positions)

  plan.moved_so_far = plan.moved_so_far + moved
  plan.step = plan.step + 1

  if moved > 0 then
    util.debug({"", "[BossDemolisher][", plan.surface_name, "] moved=", moved, " step=", plan.step - 1, "/", cell_count})
  else
    util.debug({"", "[BossDemolisher][", plan.surface_name, "] moved=", no moved, " step=", plan.step - 1, "/", cell_count})
  end

  return moved
end

return E