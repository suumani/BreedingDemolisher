-- __BreedingDemolisher__/prototypes/_shared/demolisher_egg_defs.lua
-- ----------------------------
-- Responsibility:
--   Shared definitions for BreedingDemolisher egg prototypes.
--   - naming (egg / frozen)
--   - UI order strings
--   - surface condition helpers
-- ----------------------------
local D = {}

D.VARIANTS = {
  { key = "normal", prefix = "" },
  { key = "new",    prefix = "new-spieces-" },
  { key = "friend", prefix = "friend-" },
}

D.STAGES = {
  { key = "base",   suffix = ""        , order = "a[base]"   },
  { key = "medium", suffix = "-medium" , order = "b[medium]" },
  { key = "big",    suffix = "-big"    , order = "c[big]"    },
}

function D.variant_order_key(vkey)
  if vkey == "normal" then return "a[normal]" end
  if vkey == "new" then return "b[new]" end
  return "c[friend]"
end

function D.egg_name(variant_prefix, stage_suffix)
  return ("%sdemolisher-egg%s"):format(variant_prefix, stage_suffix)
end

function D.frozen_egg_name(variant_prefix, stage_suffix)
  return ("%sdemolisher-egg%s-frozen"):format(variant_prefix, stage_suffix)
end

function D.icon_path(name)
  return "__BreedingDemolisher__/graphics/icon/" .. name:gsub("-", "_") .. ".png"
end

function D.pressure_100_600()
  return {{ property = "pressure", min = 100, max = 600 }}
end

function D.pressure_4000()
  return {{ property = "pressure", min = 4000, max = 4000 }}
end

function D.egg_item_order(stage_order, variant_order, state_order)
  return ("%s-%s-%s"):format(stage_order, variant_order, state_order) -- state: a[raw]/b[frozen]
end

function D.processing_order(action_order, stage_order, variant_order)
  return ("%s-%s-%s"):format(action_order, stage_order, variant_order) -- action: a[create]/b[freeze]/c[unfreeze]
end

function D.growth_order(stage_order, variant_order)
  return ("a[grow]-%s-%s"):format(stage_order, variant_order)
end

return D