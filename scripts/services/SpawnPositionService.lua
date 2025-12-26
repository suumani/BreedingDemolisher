local SpawnPositionService = {}
local DRand = require("scripts.util.DeterministicRandom")
-- ----------------------------
-- デモリッシャー拡散先座標
-- ----------------------------
function SpawnPositionService.getSpawnPosition(surface, evolution_factor, demolisher_position, town_center_pos)
	local spawn_area_radius =  math.floor(100*evolution_factor) -- スポーンエリア最大100マス

	local dx, dy, pos_a, pos_b

	pos_a = {x = demolisher_position.x - spawn_area_radius, y = demolisher_position.y - spawn_area_radius}
	pos_b = {x = demolisher_position.x + spawn_area_radius, y = demolisher_position.y + spawn_area_radius}

	-- 中心部に寄せる場合
	if town_center_pos == nil then town_center_pos = {x = 0, y = 0} end
	dx = town_center_pos.x - demolisher_position.x
	dy = town_center_pos.y - demolisher_position.y
	local length = math.sqrt(dx^2 + dy^2)
	if length ~= 0 then
		dx = spawn_area_radius * dx / length
		dy = spawn_area_radius * dy / length

		pos_a.x = pos_a.x + dx
		pos_a.y = pos_a.y + dy
		pos_b.x = pos_b.x + dx
		pos_b.y = pos_b.y + dy
	end


	-- 周辺座標取得
	local positions = surface.find_tiles_filtered{
		area = {pos_a, pos_b},
		has_hidden_tile = false}
	-- 周辺座標が存在し、hidden_tileでないならば存在
	if #positions > 0 then
		local index = DRand.random(#positions)
		local spawn_position = {x = positions[index].position.x, y = positions[index].position.y}
		-- チャンク生成済み判定を取得（念のため）
		if surface.is_chunk_generated({x = math.floor(spawn_position.x / 32), y = math.floor(spawn_position.y / 32)}) then
			return spawn_position
		end
	end
	-- なんらか処理に失敗した場合、nilを返す
	return nil
end

return SpawnPositionService