-- __BreedingDemolisher__/scripts/infrastructure/runtime/EggGenesStore.lua
-- ----------------------------
-- Responsibility:
--   Store and retrieve egg genetic payloads addressed by genes_id.
--   Egg items carry only genes_id in item tags (item-with-tags).
--
-- Notes:
--   - storage shape is bootstrap-managed and must already exist.
--   - This class does not auto-create storage.
-- ----------------------------
local M = {}

local function expect_storage()
  if storage == nil then
    error("EggGenesStore: storage is nil")
  end
  if storage.bd_genes == nil then
    error("EggGenesStore: storage.bd_genes is nil. Call StorageBootstrap.bootstrap() first.")
  end
  if storage.bd_next_genes_seq == nil then
    error("EggGenesStore: storage.bd_next_genes_seq is nil. Call StorageBootstrap.bootstrap() first.")
  end
end

local function new_genes_id()
  expect_storage()
  local seq = storage.bd_next_genes_seq
  storage.bd_next_genes_seq = seq + 1
  return "G" .. tostring(game.tick) .. "-" .. tostring(seq)
end

function M.register(customparam)
  expect_storage()
  local id = new_genes_id()
  storage.bd_genes[id] = {
    created_tick = game.tick,
    customparam = customparam,
  }
  return id
end

function M.get_customparam(genes_id)
  expect_storage()
  local e = storage.bd_genes[genes_id]
  return e and e.customparam or nil
end

function M.delete(genes_id)
  if not genes_id then
    return
  end

  expect_storage()
  storage.bd_genes[genes_id] = nil
end

return M