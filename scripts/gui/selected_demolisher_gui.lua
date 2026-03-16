-- __BreedingDemolisher__/scripts/gui/selected_demolisher_gui.lua
-- ----------------------------
-- Responsibility:
--   Show a small info panel for the demolisher currently under the player's cursor
--   (player.selected) or selected entity.
--   - If the entity matches a pet entry, show pet details.
--   - Otherwise show wild details.
--
-- Notes:
--   - This GUI is rebuilt on selection change for simplicity and reliability.
--   - Pet identification is delegated to PetIdentityService (unit_number may change).
--   - Demolisher判定はロード時に集合化した名前セットで O(1) 判定を行う。
-- ----------------------------

local M = {}

local DemolisherNames = require("__Manis_definitions__/scripts/definition/DemolisherNames")
local PetIdentityService = require("scripts.services.PetIdentityService")

-- traits table -> localization key mapping
local trait_locale_keys = {
  ["short_warp"]     = "trait.short_warp",
  ["emergency_food"] = "trait.emergency_food",
  ["bonus_growth"]   = "trait.bonus_growth",
}

-- Demolisher name set for O(1) lookup
local DEMOLISHER_NAME_SET = {}
do
  for _, name in ipairs(DemolisherNames.ALL) do
    DEMOLISHER_NAME_SET[name] = true
  end
end

local function destroy_frame(player)
  local root = player.gui.left
  local frame = root and root["demolisher_info_frame"]
  if frame then
    frame.destroy()
  end
end

local function is_demolisher_entity(entity)
  if not (entity and entity.valid) then
    return false
  end

  return DEMOLISHER_NAME_SET[entity.name] == true
end

local function get_entity_quality_name(entity)
  if not (entity and entity.valid) then
    return "normal"
  end

  local q = entity.quality
  if type(q) == "string" then
    return q
  end
  if type(q) == "table" and q.name then
    return q.name
  end

  return "normal"
end

local function get_life_text(_entity)
  return "Infinity"
end

local function get_default_name_surface(cp)
  local e = cp and cp.entity
  if e and e.valid then
    return e.surface.name
  end
  return "unknown"
end

local function get_default_name_size(cp)
  local e = cp and cp.entity
  if not (e and e.valid) then
    return "U"
  end

  if e.name == DemolisherNames.BIG then
    return "S"
  elseif e.name == DemolisherNames.MEDIUM then
    return "A"
  elseif e.name == DemolisherNames.SMALL then
    return "B"
  else
    return "U"
  end
end

local function get_default_name_quality(cp)
  local e = cp and cp.entity
  if not (e and e.valid) then
    return "--"
  end

  local qname = get_entity_quality_name(e)
  if qname == "legendary" then
    return "++"
  elseif qname == "epic" then
    return "+"
  elseif qname == "rare" then
    return ""
  elseif qname == "uncommon" then
    return "-"
  else
    return "--"
  end
end

local function get_default_name_unit_number(cp)
  local e = cp and cp.entity
  if e and e.valid and e.unit_number then
    return e.unit_number
  end
  return 0
end

local function wild_demolisher_frame(main_frame, entity)
  local life = get_life_text(entity)
  local qname = get_entity_quality_name(entity)

  local name_label = main_frame.add{
    type = "label",
    caption = "name: wild #" .. tostring(entity.unit_number or "nil"),
  }
  name_label.style.font = "default-large-bold"

  local force_label = main_frame.add{
    type = "label",
    caption = "force: " .. tostring(entity.force and entity.force.name or "nil"),
  }
  force_label.style.font = "default-large-bold"

  local basic_info_label = main_frame.add{
    type = "label",
    caption = {"item-name.demolisher-basic-info"},
  }
  basic_info_label.style.font = "default-bold"

  main_frame.add{ type = "label", caption = "type: wild" }
  main_frame.add{ type = "label", caption = "life: " .. life }
  main_frame.add{ type = "label", caption = "quality: " .. qname }

  local detail_label = main_frame.add{
    type = "label",
    caption = {"item-name.demolisher-detail-info"},
  }
  detail_label.style.font = "default-bold"

  main_frame.add{ type = "label", caption = "unknown" }
end

local function my_demolisher_frame(main_frame, entity, my_demolisher)
  local cp = my_demolisher.customparam
  if not cp then
    wild_demolisher_frame(main_frame, entity)
    return
  end

  local name_label = main_frame.add{
    type = "label",
    caption = {
      "item-description.demolisher-default-name",
      get_default_name_surface(cp),
      get_default_name_size(cp),
      get_default_name_quality(cp),
      get_default_name_unit_number(cp),
    }
  }
  name_label.style.font = "default-large-bold"

  local force_label = main_frame.add{
    type = "label",
    caption = {"item-description.demolisher-force", entity.force.name},
  }
  force_label.style.font = "default-large-bold"

  local basic_info_label = main_frame.add{
    type = "label",
    caption = {"item-name.demolisher-basic-info"},
  }
  basic_info_label.style.font = "default-bold"

  local basic_info_table = main_frame.add{
    type = "table",
    name = "info_table",
    column_count = 2
  }

  local life = cp.life or 0
  local quality = cp.quality or 0
  local satiety = cp.satiety or 0
  local speed = cp.speed or 0
  local growth = cp.growth or 0
  local lv = cp.lv or 0
  local size = cp.size or 0
  local traits = cp.traits

  basic_info_table.add{ type = "label", caption = {"item-description.demolisher-lifetime", life} }
  basic_info_table.add{ type = "label", caption = {"item-description.demolisher-quality", quality} }

  basic_info_table.add{ type = "label", caption = {"item-description.demolisher-satiety", satiety, 100} }
  basic_info_table.add{ type = "label", caption = {"item-description.demolisher-speed", speed} }

  if growth > 20 then
    basic_info_table.add{ type = "label", caption = {"item-description.demolisher-growth-breedable", growth, 50} }
  else
    basic_info_table.add{ type = "label", caption = {"item-description.demolisher-growth-immature", growth, 50} }
  end
  basic_info_table.add{ type = "label", caption = {"item-description.demolisher-lv", lv} }

  basic_info_table.add{ type = "label", caption = {"item-description.demolisher-size", entity.max_health + size} }

  main_frame.add{ type = "label", caption = {"item-description.demolisher-growth-description"} }
  main_frame.add{ type = "label", caption = {"item-description.demolisher-hangry-description"} }

  local traits_label = main_frame.add{
    type = "label",
    caption = {"item-name.demolisher-info"},
  }
  traits_label.style.font = "default-bold"

  if traits then
    for key, value in pairs(traits) do
      local locale_key = trait_locale_keys[key]
      if locale_key then
        local localized_name = {"", {locale_key}, " Lv." .. tostring(value)}
        main_frame.add{ type = "label", caption = localized_name }
      else
        main_frame.add{ type = "label", caption = "Unknown Trait: " .. tostring(key) .. " Lv." .. tostring(value) }
      end
    end
  end
end

local function create_frame(player, entity)
  local main_frame = player.gui.left.add{
    type = "frame",
    name = "demolisher_info_frame",
    caption = {"item-name.demolisher-info"},
    direction = "vertical",
  }

  local pet = PetIdentityService.resolve(entity)
  if pet then
    my_demolisher_frame(main_frame, entity, pet)
  else
    wild_demolisher_frame(main_frame, entity)
  end
end

function M.update(player, entity)
  destroy_frame(player)

  if not (player and player.valid) then
    return
  end
  if not is_demolisher_entity(entity) then
    return
  end

  create_frame(player, entity)
end

return M