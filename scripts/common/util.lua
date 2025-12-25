-- ----------------------------
-- 汎用テーブル長用
-- ----------------------------
function table_length(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end


-- ----------------------------
-- [public] デモリッシャー配列から、検索でかからないデモリッシャーを削除
-- ----------------------------
function delete_unfound_demolishers(all_demolishers)
	
	-- 検索で出てきた場合のみ、新しい配列に格納
	local additional_demolishers = {}
	for key, value in pairs(storage.new_vulcanus_demolishers) do
		for _, entity in pairs(all_demolishers) do
			if key == entity.unit_number then
				additional_demolishers[key] = value
				break
			end
		end
	end
	
	-- 新しい配列を古い配列に代入
	storage.new_vulcanus_demolishers = additional_demolishers
	
end