-- __BreedingDemolisher__/scripts/domain/pet/MyDemolisherGettingHangryService.lua
-- ------------------------------------------------------------
-- Responsibility:
--   pet の hunger / aging 状態を定期更新し、
--   死亡条件に達した pet を死亡させる。
--
-- Notes:
--   - storage shape は bootstrap 済み前提で扱い、このクラスでは自動生成しない。
-- ------------------------------------------------------------
local MyDemolisherGettingHangryService = {}

function MyDemolisherGettingHangryService.my_demolisher_getting_hangry()
  if storage == nil then
    error("MyDemolisherGettingHangryService: storage is nil")
  end
  if storage.my_demolishers == nil then
    error("MyDemolisherGettingHangryService: storage.my_demolishers is nil. Call StorageBootstrap.bootstrap() first.")
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