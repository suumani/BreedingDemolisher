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
local VirtualMgr      = require("__Manis_lib__/scripts/managers/VirtualEntityManager")
-- 定義ライブラリ
local DemolisherNames = require("__Manis_definitions__/scripts/definition/DemolisherNames")

-- Mod固有ロジック
local NormalClusterProbe = require("scripts.services.NormalClusterProbe")
local MovePolicy = require("scripts.policies.vulcanus_demolisher_move_policy")
local ModRandomProvider = require("scripts.services.ModRandomProvider")

local util  = require("scripts.common.util")

local TestHooks = require("scripts.tests.infrastructure.TestHooks")
local Logger = require("scripts.services.Logger")

-- ■ Adapter Factory
local function create_adapter(surface, obj, is_virt)
    local adapter = {
        valid      = true,
        surface    = surface,
        is_virtual = is_virt
    }

    if is_virt then
        -- === Virtual Entity Case ===
        -- obj is "entry" { id=..., position=..., data=... }
        local d = obj.data
        
        adapter.name = d.name
        -- Positionのコピー (参照共有回避)
        adapter.position = {x = obj.position.x, y = obj.position.y}

        -- Force/Qualityの正規化 (String化 + デフォルト値)
        local f = d.force
        if type(f) == "userdata" then f = f.name end
        adapter.force = f or "enemy"

        local q = d.quality
        if type(q) == "userdata" then q = q.name end
        adapter.quality = q or "normal"

        adapter.direction = defines.direction.north
        
        -- ID保持
        adapter.virtual_id = obj.id 
        adapter.virtual_data = d
        adapter.inner_entity = nil

        -- IDがない仮想データは不正とみなして無効化 (Mover規約)
        if not adapter.virtual_id then
            adapter.valid = false
        end
    else
        -- === Physical Entity Case ===
        adapter.name = obj.name
        adapter.position = obj.position
        adapter.force = obj.force
        adapter.quality = obj.quality
        adapter.direction = obj.direction
        adapter.inner_entity = obj
        adapter.virtual_id = nil
        
        function adapter.to_virtual_data()
            -- 型統一 (UserDataをStringに変換して保存)
            local q_name = (type(obj.quality) == "userdata") and obj.quality.name or obj.quality
            if not q_name then q_name = "normal" end

            local f_name = (type(obj.force) == "userdata") and obj.force.name or obj.force
            if not f_name then f_name = "enemy" end

            return {
                name = obj.name,
                quality = q_name,
                force = f_name,
                category = "combat",
                town_center = nil,
                is_fatal = false
            }
        end
    end
    return adapter
end

-- エリア内判定ヘルパー
local function is_in_area(pos, area)
    local lt = area.left_top or area[1]
    local rb = area.right_bottom or area[2]
    if not lt or not rb then return false end
    return (pos.x >= lt.x and pos.x < rb.x and pos.y >= lt.y and pos.y < rb.y)
end

-- ----------------------------
-- Mod固有：移動対象抽選
-- ----------------------------
local function build_move_targets(surface, area, ctx)
  local adapters = {}

  -- 1. 実体
  local phys_targets = DemolisherQuery.find_breeding_demolishers_range(surface, area)
  for _, ent in pairs(phys_targets) do
      table.insert(adapters, create_adapter(surface, ent, false))
  end

  -- 2. 仮想 (Managerのエリア検索を使用)
  -- ★修正: 定義ライブラリからターゲット名マップを作成
  local target_names = {}
  if DemolisherNames.ALL_BREEDING then
      for _, n in pairs(DemolisherNames.ALL_BREEDING) do
          target_names[n] = true
      end
  end

  local virtual_entries = VirtualMgr.find_in_area(surface, area)
  for _, entry in ipairs(virtual_entries) do
      local t_name = entry.data and entry.data.name
      if t_name and target_names[t_name] then
          local adp = create_adapter(surface, entry, true)
          if adp.valid then
              table.insert(adapters, adp)
          end
      end
  end

  -- 掃除はヴルカヌス限定 (実体のみ対象とする既存ロジックを維持)
  if surface.name ~= "vulcanus" then
    return adapters
  end

  -- rng
  local rng = (ctx and ctx.get_rng) and ctx.get_rng() or nil
  local function pick_index(n)
    if n <= 1 then return 1 end
    if rng then return rng(1, n) end
    return math.random(1, n)
  end

  -- default demolisher (実体)
  local defaults = DemolisherQuery.find_default_demolishers(surface)
  if not defaults or #defaults == 0 then
    return adapters
  end

  local valid_defaults = {}
  for _, e in pairs(defaults) do
    if e and e.valid then
      valid_defaults[#valid_defaults + 1] = e
    end
  end
  if #valid_defaults == 0 then
    return adapters
  end

  -- 密集判定
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
          
          -- 重複チェック (Adaptersリストの中身と比較)
          -- Adapterは_objかinner_entityを持っているはずだが、
          -- create_adapterの構造上、inner_entity比較で判定する
          local exists = false
          for _, adp in pairs(adapters) do
            if not adp.is_virtual and adp.inner_entity == picked then
              exists = true
              break
            end
          end
          
          if not exists then
            -- 実体なので create_adapter でラップして追加
            table.insert(adapters, create_adapter(surface, picked, false))
          end
        end
        break -- 掃除は最大1体
      end
    end
  end

  return adapters
end

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
    get_evolution_factor = function(surface)
      local ov = TestHooks.try_get_move_evo_override()
      if type(ov) == "number" then return ov end
      return game.forces.enemy.get_evolution_factor(surface)
    end,
    get_rng = function() return ModRandomProvider.get() end,
    mod_name = "BreedingDemolisher",
    log = function(msg)
      Logger.debug(msg)
    end
  })
end

return E