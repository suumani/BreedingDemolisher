-- __BreedingDemolisher__/scripts/services/BreedingDemolisherSpawner.lua
local Spawner = {}

local VirtualMgr = require("__Manis_lib__/scripts/managers/VirtualEntityManager")
local Logger = require("scripts.services.Logger")

-- BossDemolisherSpawner.process_virtual_queue と同等の実装
function Spawner.process_virtual_queue(event)
    local surface = event.surface
    if not surface or not surface.valid then return end
    
    local area = event.area

    -- エリア検索を使ってリスト取得
    local entries = VirtualMgr.find_in_area(surface, area)
    if #entries == 0 then return end

    for _, entry in ipairs(entries) do
        local data = entry.data
        
        -- Forceの正規化 (Userdata -> String -> Default)
        local f = data.force
        if type(f) == "userdata" then f = f.name end
        if not f then f = "enemy" end

        -- Qualityの正規化 (Userdata -> String -> Default)
        local q = data.quality
        if type(q) == "userdata" then q = q.name end
        if not q then q = "normal" end

        -- 実体化
        local entity = surface.create_entity{
            name      = data.name,
            position  = entry.position,
            force     = f,
            quality   = q,
            direction = defines.direction.north
        }

        if entity and entity.valid then
            -- OBS-VIRT-001: MATERIALIZE (virtual -> physical)
            Logger.info({
                "[BreedingDemolisher][VIRT][Update][OK]",
                " action=MATERIALIZE",
                " surface=", surface.name,
                " vid=", entry.id,
                " position={", entry.position.x, ",", entry.position.y, "}",
            })

            VirtualMgr.remove(surface, entry.id)

            -- OBS-VIRT-001: REMOVE (virtual entry removed)
            Logger.info({
                "[BreedingDemolisher][VIRT][Update][OK]",
                " action=REMOVE",
                " surface=", surface.name,
                " vid=", entry.id,
                " position={", entry.position.x, ",", entry.position.y, "}",
            })
        end
    end
end

return Spawner