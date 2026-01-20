-- __BreedingDemolisher__/scripts/commands/bd_debug_commands.lua
-- ----------------------------
-- Responsibility:
--   Debug commands for BreedingDemolisher development/testing.
--   - Give a genetic egg (item-with-tags) with bd_genes_id attached.
-- Notes:
--   - Uses EggGenesStore (genes payload stored in storage).
--   - Does NOT delete genes (no GC).
-- ----------------------------

local EggGenesStore   = require("scripts.services.EggGenesStore")
local DemolisherNames = require("__Manis_definitions__/scripts/definition/DemolisherNames")

-- Load customparam module (it defines global Customparam in this codebase).
local ok_customparam, customparam_mod = pcall(require, "scripts.common.customparam")

local function get_player(cmd)
  return cmd.player_index and game.get_player(cmd.player_index) or nil
end

local function resolve_customparam_module()
  -- Some modules return a table; some define a global. Support both.
  if type(customparam_mod) == "table" then return customparam_mod end
  if type(_G.Customparam) == "table" then return _G.Customparam end
  return nil
end

local function give_stack(player, item_name, quality_name)
  local inv = player.get_main_inventory()
  if not inv then return nil end

  local inserted = inv.insert({
    name = item_name,
    count = 1,
    quality = quality_name,
  })
  if inserted ~= 1 then return nil end

  -- stack_size=1 前提なので単純走査でOK
  for i = 1, #inv do
    local s = inv[i]
    if s and s.valid_for_read and s.name == item_name
       and (not s.tags or not s.tags.bd_genes_id) then
      return s
    end
  end
  return nil
end

-- /bd_debug_give_genetic_egg [item_name]
-- If item_name omitted -> friend demolisher egg (base)
commands.add_command(
  "bd_debug_give_genetic_egg",
  "Give a genetic demolisher egg with tags (debug).",
  function(cmd)
    local player = get_player(cmd)
    if not (player and player.valid) then return end

    player.print(
      "ok_customparam=" .. tostring(ok_customparam) ..
      " type(require_ret)=" .. type(customparam_mod) ..
      " type(_G.Customparam)=" .. type(_G.Customparam)
    )

    if not ok_customparam then
      player.print("require error: " .. tostring(customparam_mod))
      return
    end

    local Customparam = resolve_customparam_module()
    if not (Customparam and Customparam.new) then
      player.print("Customparam.new is not available.")
      return
    end

    local item_name = cmd.parameter
    if item_name == nil or item_name == "" then
      item_name = CONST_ITEM_NAME.FRIEND_DEMOLISHER_EGG
    end

    local q = CONST_QUALITY.NORMAL

    local customparam = Customparam.new(
      nil,                    -- entity (will be set on hatch)
      DemolisherNames.SMALL,
      nil, nil, nil, nil, nil,
      (CONST_DEMOLISHER_PARAMETER
        and CONST_DEMOLISHER_PARAMETER.DEFAULT_MAX_GROWTH) or 100,
      (CONST_DEMOLISHER_PARAMETER
        and CONST_DEMOLISHER_PARAMETER.DEFAULT_MAX_SATIETY) or 100,
      nil,
      game.tick
    )

    if customparam == nil then
      player.print("Customparam is nil. Cannot create a genetic egg.")
      return
    end

    local genes_id = EggGenesStore.register(customparam)

    local stack = give_stack(player, item_name, q)
    if not (stack and stack.valid_for_read) then
      player.print("Failed to give egg: " .. tostring(item_name))
      return
    end

    local tags = stack.tags or {}
    tags.bd_ver = 1
    tags.bd_genes_id = genes_id
    tags.bd_born_tick = game.tick
    stack.tags = tags

    player.print("Given genetic egg: " .. item_name .. " genes_id=" .. tostring(genes_id))
  end
)