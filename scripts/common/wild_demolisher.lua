-- ----------------------------
-- wild_demolisherの追加
-- ----------------------------

function add_new_wild_demolisher(tbl, entity, life)

    if tbl == nil then tbl = {} end
    tbl[#tbl + 1] = {entity = entity, life = life}

end

