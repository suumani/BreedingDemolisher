-- �����̌����Ƀ��V�s�����ǉ�
local target_technology = data.raw.technology["planet-discovery-vulcanus"]

if target_technology and target_technology.effects then
    table.insert(target_technology.effects, {type = "unlock-recipe", recipe = "demolisher-egg-dummy-recipe"})
    table.insert(target_technology.effects, {type = "unlock-recipe", recipe = "demolisher-egg-grow-recipe"})
    table.insert(target_technology.effects, {type = "unlock-recipe", recipe = "new-spieces-demolisher-egg-dummy-recipe"})
    table.insert(target_technology.effects, {type = "unlock-recipe", recipe = "new-spieces-demolisher-egg-grow-recipe"})
    table.insert(target_technology.effects, {type = "unlock-recipe", recipe = "friend-demolisher-egg-dummy-recipe"})
    table.insert(target_technology.effects, {type = "unlock-recipe", recipe = "friend-demolisher-egg-grow-recipe"})
    table.insert(target_technology.effects, {type = "unlock-recipe", recipe = "demolisher-egg-medium-grow-recipe"})
    table.insert(target_technology.effects, {type = "unlock-recipe", recipe = "new-spieces-demolisher-egg-medium-grow-recipe"})
    table.insert(target_technology.effects, {type = "unlock-recipe", recipe = "friend-demolisher-egg-medium-grow-recipe"})
end