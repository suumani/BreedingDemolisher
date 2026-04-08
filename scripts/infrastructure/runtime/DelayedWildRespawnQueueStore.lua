-- __BreedingDemolisher__/scripts/infrastructure/runtime/DelayedWildRespawnQueueStore.lua
-- ------------------------------------------------------------
-- Responsibility:
--   撃破された wild demolisher の delayed respawn queue を管理する。
--   - pending entry の追加
--   - due 到来 entry の取り出し
--   - queue の残存 entry 保持
--
-- Entry shape:
--   {
--     surface_name = string,
--     entity_name = string,
--     chunk_x = integer,
--     chunk_y = integer,
--     position = {
--       x = number,
--       y = number,
--     },
--     due_tick = uint,
--   }
--
-- Notes:
--   - storage schema 自体の成立は StorageBootstrap が担当する。
--   - queue は persistent storage に保持する。
-- ------------------------------------------------------------
local DelayedWildRespawnQueueStore = {}

local function get_queue()
  if storage == nil then
    error("DelayedWildRespawnQueueStore: storage is not available")
  end

  storage.bd = storage.bd or {}
  storage.bd.delayed_wild_respawn_queue = storage.bd.delayed_wild_respawn_queue or {}

  return storage.bd.delayed_wild_respawn_queue
end

local function validate_position(position)
  if type(position) ~= "table" then
    error("DelayedWildRespawnQueueStore: entry.position must be a table")
  end
  if type(position.x) ~= "number" or type(position.y) ~= "number" then
    error("DelayedWildRespawnQueueStore: entry.position.x / entry.position.y must be numbers")
  end
end

local function validate_entry(entry)
  if type(entry) ~= "table" then
    error("DelayedWildRespawnQueueStore: entry must be a table")
  end
  if type(entry.surface_name) ~= "string" or entry.surface_name == "" then
    error("DelayedWildRespawnQueueStore: entry.surface_name must be a non-empty string")
  end
  if type(entry.entity_name) ~= "string" or entry.entity_name == "" then
    error("DelayedWildRespawnQueueStore: entry.entity_name must be a non-empty string")
  end
  if type(entry.chunk_x) ~= "number" or type(entry.chunk_y) ~= "number" then
    error("DelayedWildRespawnQueueStore: entry.chunk_x / entry.chunk_y must be numbers")
  end
  validate_position(entry.position)
  if type(entry.due_tick) ~= "number" then
    error("DelayedWildRespawnQueueStore: entry.due_tick must be a number")
  end
end

--- enqueue
--- Responsibility:
---   delayed respawn entry を queue に追加する。
--- @param entry table
function DelayedWildRespawnQueueStore.enqueue(entry)
  validate_entry(entry)

  local queue = get_queue()
  queue[#queue + 1] = {
    surface_name = entry.surface_name,
    entity_name = entry.entity_name,
    chunk_x = entry.chunk_x,
    chunk_y = entry.chunk_y,
    position = {
      x = entry.position.x,
      y = entry.position.y,
    },
    due_tick = entry.due_tick,
  }
end

--- pop_due
--- Responsibility:
---   current_tick までに期限到来した entry を返し、
---   未到来の entry のみ queue に残す。
--- @param current_tick uint
--- @return table[] due_entries
function DelayedWildRespawnQueueStore.pop_due(current_tick)
  if type(current_tick) ~= "number" then
    error("DelayedWildRespawnQueueStore.pop_due: current_tick must be a number")
  end

  local queue = get_queue()
  local due_entries = {}
  local future_entries = {}

  for _, entry in ipairs(queue) do
    if type(entry) == "table" and type(entry.due_tick) == "number" and entry.due_tick <= current_tick then
      due_entries[#due_entries + 1] = entry
    else
      future_entries[#future_entries + 1] = entry
    end
  end

  storage.bd.delayed_wild_respawn_queue = future_entries
  return due_entries
end

return DelayedWildRespawnQueueStore