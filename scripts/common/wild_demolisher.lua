-- ----------------------------
-- wild_demolisherの追加
-- ----------------------------

function add_new_wild_demolisher(tbl, entity, life)

    if tbl == nil then tbl = {} end
    tbl[entity.unit_number] = {entity = entity, life = life}

end

