-- ----------------------------
-- Responsibility:
--   Store and retrieve egg genetic payloads addressed by genes_id.
--   Egg items carry only genes_id in item tags (item-with-tags).
-- ----------------------------
local M = {}

local function ensure()
  storage.bd_genes = storage.bd_genes or {}
  storage.bd_next_genes_seq = storage.bd_next_genes_seq or 1
end

local function new_genes_id()
  ensure()
  local seq = storage.bd_next_genes_seq
  storage.bd_next_genes_seq = seq + 1
  return "G" .. tostring(game.tick) .. "-" .. tostring(seq)
end

function M.register(customparam)
  ensure()
  local id = new_genes_id()
  storage.bd_genes[id] = {
    created_tick = game.tick,
    customparam = customparam, -- 現行運用のまま保持
  }
  return id
end

function M.get_customparam(genes_id)
  ensure()
  local e = storage.bd_genes[genes_id]
  return e and e.customparam or nil
end

function M.delete(genes_id)
  if not genes_id then return end
  if not storage.bd_genes then return end
  storage.bd_genes[genes_id] = nil
end

return M