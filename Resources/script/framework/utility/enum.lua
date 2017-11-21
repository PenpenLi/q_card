
function enum(tbl, index) 
--    assert(IsTable(tbl)) 
    local enumtbl = {} 
    local enumindex = index or 0 
    for i, v in pairs(tbl) do 
        enumtbl[v] = enumindex + i - 1
    end 
    return enumtbl 
end 
