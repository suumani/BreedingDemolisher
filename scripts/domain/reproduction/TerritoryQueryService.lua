-- __BreedingDemolisher__/scripts/domain/reproduction/TerritoryQueryService.lua
-- ------------------------------------------------------------
-- Responsibility:
--   Wild Reproduction に必要な territory / chunk / segmented unit の
--   取得と再解決を担当する。
--
-- Scope:
--   - target surface 取得
--   - territory 一覧取得
--   - representative chunk 決定
--   - representative chunk から territory 再解決
--   - territory 内 segmented unit 取得
--
-- Notes:
--   - LuaTerritory / LuaChunk を保存してはならない。
--   - representative chunk は territory.get_chunks() の
--     辞書順最小 (x, y) を採用する。
-- ------------------------------------------------------------
local TerritoryQueryService = {}

local TARGET_SURFACE_NAME = "vulcanus"

local function compare_chunk_pos(a, b)
  if a.x ~= b.x then
    return a.x < b.x
  end
  return a.y < b.y
end

--- get_target_surface
--- Responsibility:
---   Wild Reproduction 対象 surface を返す。
--- @return LuaSurface|nil
function TerritoryQueryService.get_target_surface()
  return game.surfaces[TARGET_SURFACE_NAME]
end

--- get_representative_chunk
--- Responsibility:
---   territory の representative chunk を返す。
--- @param territory LuaTerritory
--- @return ChunkPosition|nil
function TerritoryQueryService.get_representative_chunk(territory)
  if not territory or not territory.valid then
    return nil
  end

  local chunks = territory.get_chunks()
  if not chunks or #chunks == 0 then
    return nil
  end

  local best = nil
  for _, chunk_info in ipairs(chunks) do
    local pos = chunk_info.position
    if pos then
      if best == nil or compare_chunk_pos(pos, best) then
        best = { x = pos.x, y = pos.y }
      end
    end
  end

  return best
end

--- get_sorted_territory_entries
--- Responsibility:
---   target surface 上の territory 一覧を representative chunk 基準で
---   安定ソートし、planning 用 entry を返す。
--- @param surface LuaSurface
--- @return table[]
function TerritoryQueryService.get_sorted_territory_entries(surface)
  if not surface or not surface.valid then
    return {}
  end

  local territories = surface.get_territories()
  local entries = {}

  for _, territory in ipairs(territories) do
    if territory and territory.valid then
      local rep = TerritoryQueryService.get_representative_chunk(territory)
      if rep then
        entries[#entries + 1] = {
          surface_name = surface.name,
          representative_chunk_x = rep.x,
          representative_chunk_y = rep.y,
        }
      end
    end
  end

  table.sort(entries, function(a, b)
    if a.surface_name ~= b.surface_name then
      return a.surface_name < b.surface_name
    end
    if a.representative_chunk_x ~= b.representative_chunk_x then
      return a.representative_chunk_x < b.representative_chunk_x
    end
    return a.representative_chunk_y < b.representative_chunk_y
  end)

  return entries
end

--- resolve_territory_from_representative_chunk
--- Responsibility:
---   representative chunk 座標から territory を再解決する。
--- @param surface LuaSurface
--- @param chunk_x integer
--- @param chunk_y integer
--- @return LuaTerritory|nil
function TerritoryQueryService.resolve_territory_from_representative_chunk(surface, chunk_x, chunk_y)
  if not surface or not surface.valid then
    return nil
  end
  if type(chunk_x) ~= "number" or type(chunk_y) ~= "number" then
    error("TerritoryQueryService.resolve_territory_from_representative_chunk: chunk_x/chunk_y must be numbers")
  end

  return surface.get_territory_for_chunk({ x = chunk_x, y = chunk_y })
end

--- get_segmented_units
--- Responsibility:
---   territory に属する segmented unit 一覧を返す。
--- @param territory LuaTerritory
--- @return LuaSegmentedUnit[]
function TerritoryQueryService.get_segmented_units(territory)
  if not territory or not territory.valid then
    return {}
  end

  return territory.get_segmented_units() or {}
end

return TerritoryQueryService