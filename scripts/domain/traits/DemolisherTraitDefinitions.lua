-- __BreedingDemolisher__/scripts/domain/traits/DemolisherTraitDefinitions.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Central definition of demolisher traits (ì¡ê´).
--
-- Design:
--   - Traits are identified by stable string IDs.
--   - This file defines metadata only.
--   - No effect logic is implemented here.
--   - Actual activation/effects will be implemented in future releases.
--
-- Notes:
--   - Strength (numeric) is handled by genetics layer.
--   - Cooldowns and triggers are defined here for future use.
-- ------------------------------------------------------------
local T = {}

-- ------------------------------------------------------------
-- Trait categories (for UI / grouping)
-- ------------------------------------------------------------
T.CATEGORY = {
  SURVIVAL = "survival",
  ACTION   = "action",
  GROWTH   = "growth",
}

-- ------------------------------------------------------------
-- Trigger types (semantic only, not implemented yet)
-- ------------------------------------------------------------
T.TRIGGER = {
  PERIODIC        = "periodic",        -- time based
  LOW_HP          = "low_hp",           -- HP threshold
  NEAR_DEATH      = "near_death",       -- starvation / lethal state
  AFTER_KILL      = "after_kill",       -- enemy defeated
  MANUAL_INTERNAL = "manual_internal", -- internal decision (AI)
}

-- ------------------------------------------------------------
-- Trait definitions
-- ------------------------------------------------------------
T.DEFINITIONS = {

  short_warp = {
    id = "short_warp",
    display_name = "Short Warp",
    category = T.CATEGORY.ACTION,
    trigger = T.TRIGGER.PERIODIC,
    cooldown_sec = 600, -- once per 10 minutes
    description = "Teleports to a random nearby position. Triggered at most once every 10 minutes.",
  },

  emergency_food = {
    id = "emergency_food",
    display_name = "Emergency Food",
    category = T.CATEGORY.SURVIVAL,
    trigger = T.TRIGGER.NEAR_DEATH,
    cooldown_sec = 600,
    description = "Restores satiety by 30% when near starvation. Triggered at most once every 10 minutes.",
  },

  bonus_growth = {
    id = "bonus_growth",
    display_name = "Bonus Growth",
    category = T.CATEGORY.GROWTH,
    trigger = T.TRIGGER.AFTER_KILL,
    cooldown_sec = nil, -- passive
    description = "Grants additional growth when defeating enemies.",
  },

  great_heal = {
    id = "great_heal",
    display_name = "Great Heal",
    category = T.CATEGORY.SURVIVAL,
    trigger = T.TRIGGER.LOW_HP,
    cooldown_sec = 600,
    description = "Restores 30% HP when HP falls below 10%. Triggered at most once every 10 minutes.",
  },

  super_acceleration = {
    id = "super_acceleration",
    display_name = "Super Acceleration",
    category = T.CATEGORY.ACTION,
    trigger = T.TRIGGER.PERIODIC,
    cooldown_sec = 600,
    description = "Grants a 30% movement speed buff for 1 minute. Triggered at most once every 10 minutes.",
  },

  super_defense = {
    id = "super_defense",
    display_name = "Super Defense",
    category = T.CATEGORY.SURVIVAL,
    trigger = T.TRIGGER.LOW_HP,
    cooldown_sec = 600,
    description = "Creates a damage-nullifying shield equal to 30% of max HP. Shield recharge is limited to once every 10 minutes.",
  },
}

-- ------------------------------------------------------------
-- Utilities
-- ------------------------------------------------------------
function T.get(id)
  return T.DEFINITIONS[id]
end

function T.exists(id)
  return T.DEFINITIONS[id] ~= nil
end

function T.list_ids()
  local out = {}
  for k, _ in pairs(T.DEFINITIONS) do
    table.insert(out, k)
  end
  return out
end

return T