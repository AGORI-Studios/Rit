function table.findID(tbl, val)
    for i, v in ipairs(tbl) do
        if v == val then
            return i
        end
    end
end
