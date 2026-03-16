-- __BreedingDemolisher__/scripts/services/MyDemolisherGettingHangryService.lua
-- ----------------------------
-- Responsibility:
--   Advance pet hunger/aging state once per tick cadence and kill pets that reach death conditions.
-- ----------------------------

local MyDemolisherGettingHangryService = {}

function MyDemolisherGettingHangryService.my_demolisher_getting_hangry()
  if storage == nil then
    error("MyDemolisherGettingHangryService: storage is nil")
  end
  if storage.my_demolishers == nil then
    error("MyDemolisherGettingHangryService: storage.my_demolishers is nil. Call StorageInitializer.init_all() first.")
  end

  if #storage.my_demolishers == 0 then
    return
  end

  for _, value in pairs(storage.my_demolishers) do
    local cp = value.customparam
    if cp == nil then
      error("MyDemolisherGettingHangryService: pet.customparam is nil")
    end

    cp.satiety = (cp.satiety or 0) - 1
    if cp.satiety < 0 then
      local entity = cp.entity
      if entity ~= nil and entity.valid then
        entity.die()
      end
    end

    cp.life = (cp.life or 0) - 1
    if cp.life < 0 then
      local entity = cp.entity
      if entity ~= nil and entity.valid then
        entity.die()
      end
    end
  end
end

return MyDemolisherGettingHangryService