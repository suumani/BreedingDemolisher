-- __BreedingDemolisher__/scripts/application/reproduction/WildReproductionExecutionService.lua
-- ------------------------------------------------------------
-- Responsibility:
--   1 territory 分の Wild Reproduction execution を実行する。
--
-- Scope:
--   - step_index -> plan entry 解決
--   - representative chunk -> territory 再解決
--   - territory 内 segmented units 安定ソート
--   - reproduction roll
--   - mutation roll
--   - population suppress 判定
--   - spawn orchestration
--   - observability 出力
--
-- Notes:
--   - execution step は 1 territory = 1 step
--   - 1 unit からの生成は最大1体
--   - 1 territory step 内では複数 spawn 可
--   - cap 到達時は territory step を早期打ち切る
--   - LuaSegmentedUnit の識別は prototype.name を使用する。
-- ------------------------------------------------------------
local WildReproductionExecutionService = {}

local DeterministicRandom = require("scripts.core.services.DeterministicRandom")
local Logger = require("scripts.services.Logger")

local WildReproductionPlanStore = require("scripts.infrastructure.runtime.WildReproductionPlanStore")
local TerritoryQueryService = require("scripts.domain.reproduction.TerritoryQueryService")
local PopulationControlService = require("scripts.domain.reproduction.PopulationControlService")
local SpawnEntityResolver = require("scripts.domain.reproduction.SpawnEntityResolver")
local SpawnPlacementService = require("scripts.domain.reproduction.SpawnPlacementService")
local SpawnExecutor = require("scripts.domain.reproduction.SpawnExecutor")

local P_MIN = 1 -- 0.05 testmode

local function resolve_surface(entry)
  if entry == nil then
    return nil
  end
  return game.surfaces[entry.surface_name]
end

local function resolve_enemy_evolution_factor(surface)
  local enemy_force = game.forces["enemy"]
  if enemy_force == nil then
    error("WildReproductionExecutionService: game.forces['enemy'] is not available")
  end
  return enemy_force.get_evolution_factor(surface)
end

local function resolve_force_name()
  return "enemy"
end

local function calc_reproduction_rate(evolution_factor)
  return math.max(P_MIN, (evolution_factor ^ 0.7) / 6)
end

local function calc_mutation_rate(evolution_factor, threshold)
  if type(evolution_factor) ~= "number" then
    error("WildReproductionExecutionService.calc_mutation_rate: evolution_factor must be a number")
  end
  if type(threshold) ~= "number" then
    error("WildReproductionExecutionService.calc_mutation_rate: threshold must be a number")
  end

  if evolution_factor < threshold then
    return 0
  end
  if threshold >= 1.0 then
    return 0
  end

  local x = (evolution_factor - threshold) / (1.0 - threshold)
  local p = 0.10 + (0.30 - 0.10) * x

  if p < 0.10 then p = 0.10 end
  if p > 0.30 then p = 0.30 end
  return p
end

local function reproduction_roll(evolution_factor)
  local p = calc_reproduction_rate(evolution_factor)
  return DeterministicRandom.random() < p
end

local function mutation_roll(parent_unit, evolution_factor)
  if not SpawnEntityResolver.has_mutation_candidate(parent_unit, evolution_factor) then
    return false
  end

  local threshold = SpawnEntityResolver.get_mutation_threshold(parent_unit, evolution_factor)
  if threshold == nil then
    return false
  end

  local p = calc_mutation_rate(evolution_factor, threshold)
  if p <= 0 then
    return false
  end

  return DeterministicRandom.random() < p
end

local function get_unit_sort_key(unit)
  if unit.unit_number ~= nil then
    return unit.unit_number
  end
  return 0
end

local function get_unit_entity_name(unit)
  if unit == nil or unit.valid == false then
    return ""
  end
  if unit.prototype == nil then
    return ""
  end

  local name = unit.prototype.name
  if type(name) ~= "string" then
    return ""
  end

  return name
end

local function get_sorted_units(territory)
  local units = TerritoryQueryService.get_segmented_units(territory)
  if units == nil or #units == 0 then
    return {}
  end

  local copied = {}
  for i, unit in ipairs(units) do
    copied[i] = unit
  end

  table.sort(copied, function(a, b)
    local ak = get_unit_sort_key(a)
    local bk = get_unit_sort_key(b)
    if ak ~= bk then
      return ak < bk
    end
    return get_unit_entity_name(a) < get_unit_entity_name(b)
  end)

  return copied
end

local function log_step_start(entry, unit_count)
  Logger.info({
    "[BreedingDemolisher][WILD][Step][START]",
    " surface=", tostring(entry.surface_name),
    " representative_chunk={", tostring(entry.representative_chunk_x), ",", tostring(entry.representative_chunk_y), "}",
    " unit_count=", tostring(unit_count),
  })
end

local function log_step_end(entry, spawned_count)
  Logger.info({
    "[BreedingDemolisher][WILD][Step][END]",
    " surface=", tostring(entry.surface_name),
    " representative_chunk={", tostring(entry.representative_chunk_x), ",", tostring(entry.representative_chunk_y), "}",
    " spawned_count=", tostring(spawned_count),
  })
end

local function log_suppress(reason_code, entry)
  Logger.info({
    "[BreedingDemolisher][WILD][Suppress][OK]",
    " reason=", tostring(reason_code),
    " surface=", tostring(entry.surface_name),
    " representative_chunk={", tostring(entry.representative_chunk_x), ",", tostring(entry.representative_chunk_y), "}",
  })
end

local function log_mutation_success(parent_name, spawned_name, evolution_factor)
  Logger.info({
    "[BreedingDemolisher][WILD][Mutation][OK]",
    " parent_entity=", tostring(parent_name),
    " spawned_entity=", tostring(spawned_name),
    " evolution_factor=", tostring(evolution_factor),
  })
end

local function log_spawn_success(surface_name, spawned_name)
  Logger.info({
    "[BreedingDemolisher][WILD][Spawn][OK]",
    " surface=", tostring(surface_name),
    " entity_name=", tostring(spawned_name),
  })
end

--- execute_step
--- Responsibility:
---   step_index に対応する 1 territory 分の execution を行う。
--- @param step_index uint
function WildReproductionExecutionService.execute_step(step_index)
  if type(step_index) ~= "number" then
    error("WildReproductionExecutionService.execute_step: step_index must be a number")
  end

  local entry = WildReproductionPlanStore.get_entry(step_index)
  if entry == nil then
    return
  end

  local surface = resolve_surface(entry)
  if surface == nil or surface.valid == false then
    return
  end

  local territory = TerritoryQueryService.resolve_territory_from_representative_chunk(
    surface,
    entry.representative_chunk_x,
    entry.representative_chunk_y
  )
  if territory == nil then
    return
  end

  local units = get_sorted_units(territory)
  log_step_start(entry, #units)

  if #units == 0 then
    log_step_end(entry, 0)
    return
  end

  local evolution_factor = resolve_enemy_evolution_factor(surface)
  local spawned_count = 0

  for _, unit in ipairs(units) do
    if unit ~= nil and unit.valid ~= false then
      if reproduction_roll(evolution_factor) == true then
        local mutation_roll_result = mutation_roll(unit, evolution_factor)

        local entity_name = SpawnEntityResolver.resolve_spawn_entity(
          unit,
          evolution_factor,
          mutation_roll_result
        )

        local parent_entity_name = SpawnEntityResolver.get_parent_entity_name(unit)
        if mutation_roll_result == true and entity_name ~= parent_entity_name then
          log_mutation_success(parent_entity_name, entity_name, evolution_factor)
        end

        local suppress, reason_code = PopulationControlService.should_suppress_spawn(territory, surface)
        if suppress == true then
          log_suppress(reason_code, entry)
          break
        end

        local spawn_position = SpawnPlacementService.resolve_spawn_position(territory, unit, entity_name)
        if spawn_position ~= nil then
          local success, _spawned_unit = SpawnExecutor.spawn(
            surface,
            territory,
            entity_name,
            spawn_position,
            resolve_force_name()
          )
          if success == true then
            spawned_count = spawned_count + 1
            log_spawn_success(surface.name, entity_name)
          end
        end
      end
    end
  end

  log_step_end(entry, spawned_count)
end

return WildReproductionExecutionService