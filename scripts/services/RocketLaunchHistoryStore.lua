-- scripts/services/RocketLaunchHistoryStore.lua
-- ----------------------------
-- Responsibility:
--   Vulcanusのロケット発射履歴（サイロ座標）を storage に記録し、
--   「今回分」を取り出して消去する（consume）APIを提供する。
--   storage.bd_rocket_histories をこのモジュールが所有し、他から直アクセスさせない。
-- ----------------------------
local Store = {}

local STORAGE_KEY = "bd_rocket_histories"

local function ensure_root()
  storage[STORAGE_KEY] = storage[STORAGE_KEY] or {}
  return storage[STORAGE_KEY]
end

-- position: {x=number, y=number}
function Store.add(surface_name, position)
  local root = ensure_root()
  root[surface_name] = root[surface_name] or {}
  table.insert(root[surface_name], { x = position.x, y = position.y })
end

-- returns positions array or nil
function Store.get_positions(surface_name)
  local root = storage[STORAGE_KEY]
  if not root then return nil end
  return root[surface_name]
end

-- returns positions array (or nil) and removes it from storage
function Store.consume_positions(surface_name)
  local root = storage[STORAGE_KEY]
  if not root then return nil end

  local positions = root[surface_name]
  root[surface_name] = nil
  return positions
end

return Store