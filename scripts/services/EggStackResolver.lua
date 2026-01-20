-- __BreedingDemolisher__/scripts/services/EggStackResolver.lua
-- ----------------------------
-- Responsibility:
--   Parse cursor_stack and return normalized egg info for hatching.
-- ----------------------------
local DemolisherNames = require("__Manis_definitions__/scripts/definition/DemolisherNames")

local R = {}

local SPAWN_OFFSET = {
  [defines.direction.north]     = {x = 0,   y = -20},
  [defines.direction.northeast] = {x = 14,  y = -14},
  [defines.direction.east]      = {x = 20,  y = 0},
  [defines.direction.southeast] = {x = 14,  y = 14},
  [defines.direction.south]     = {x = 0,   y = 20},
  [defines.direction.southwest] = {x = -14, y = 14},
  [defines.direction.west]      = {x = -20, y = 0},
  [defines.direction.northwest] = {x = -14, y = -14},
}

local function is_egg_item(item_name)
  return item_name and item_name:find("demolisher%-egg", 1, false) ~= nil
end

local function is_frozen_egg(item_name)
  return item_name and item_name:find("frozen", 1, true) ~= nil
end

local function resolve_size(item_name)
  local name = DemolisherNames.SMALL
  if item_name:find("medium", 1, true) then
    name = DemolisherNames.MEDIUM
  elseif item_name:find("big", 1, true) then
    name = DemolisherNames.BIG
  end
  return name
end

local function resolve_force(item_name, player)
  if item_name:find("new%-spieces", 1, false) then
    return "demolishers"
  elseif item_name:find("friend", 1, true) then
    return player.force
  else
    return "enemy"
  end
end

local function compute_spawn_position(player)
  local position = player.position
  local direction = (player.character and player.character.direction) or defines.direction.north
  local offset = SPAWN_OFFSET[direction] or SPAWN_OFFSET[defines.direction.north]
  return { x = position.x + offset.x, y = position.y + offset.y }
end

local function get_genes_id(stack)
  local tags = stack.tags
  if not tags then return nil end
  return tags.bd_genes_id
end

function R.try_resolve(cursor_stack)
  if not (cursor_stack and cursor_stack.valid_for_read) then return nil end
  local item_name = cursor_stack.name
  if not is_egg_item(item_name) then return nil end

  local quality_name = (cursor_stack.quality and cursor_stack.quality.name) or CONST_QUALITY.NORMAL

  return {
    item_name = item_name,
    is_frozen = is_frozen_egg(item_name),
    genes_id = get_genes_id(cursor_stack),
    quality_name = quality_name,
    -- spawn params resolved later with player context
    resolve_size = resolve_size,
    resolve_force = resolve_force,
    compute_spawn_position = compute_spawn_position,
  }
end

return R