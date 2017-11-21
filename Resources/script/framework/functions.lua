local tonumber_ = tonumber

function tonumber(v, base)
    return tonumber_(v, base) or 0
end

function toint(v)
    return math.round(tonumber(v))
end

function tobool(v)
    return (v ~= nil and v ~= false)
end

function totable(v)
    if type(v) ~= "table" then v = {} end
    return v
end

function clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

function class(classname, super)
    local superType = type(super)
    local cls

    if superType ~= "function" and superType ~= "table" then
        superType = nil
        super = nil
    end

    if superType == "function" or (super and super.__ctype == 1) then
        -- inherited from native C++ Object
        cls = {}

        if superType == "table" then
            -- copy fields from super
            for k,v in pairs(super) do cls[k] = v end
            cls.__create = super.__create
            cls.super    = super
        else
            cls.__create = super
            cls.ctor = function() end
        end

        cls.__cname = classname
        cls.__ctype = 1

        function cls.new(...)
            local instance = cls.__create(...)
            -- copy fields from class to native object
            for k,v in pairs(cls) do instance[k] = v end
            instance.class = cls
            instance:ctor(...)
            return instance
        end

    else
        -- inherited from Lua Object
        if super then
            cls = {}
            setmetatable(cls, {__index = super})
            cls.super = super
        else
            cls = {ctor = function() end}
        end

        cls.__cname = classname
        cls.__ctype = 2 -- lua
        cls.__index = cls

        function cls.new(...)
            local instance = setmetatable({}, cls)
            instance.class = cls
            instance:ctor(...)
            return instance
        end
    end

    return cls
end

function import(moduleName, currentModuleName)
    local currentModuleNameParts
    local moduleFullName = moduleName
    local offset = 1

    while true do
        if string.byte(moduleName, offset) ~= 46 then -- .
            moduleFullName = string.sub(moduleName, offset)
            if currentModuleNameParts and #currentModuleNameParts > 0 then
                moduleFullName = table.concat(currentModuleNameParts, ".") .. "." .. moduleFullName
            end
            break
        end
        offset = offset + 1

        if not currentModuleNameParts then
            if not currentModuleName then
                local n,v = debug.getlocal(3, 1)
                currentModuleName = v
            end

            currentModuleNameParts = string.split(currentModuleName, ".")
        end
        table.remove(currentModuleNameParts, #currentModuleNameParts)
    end

    return require(moduleFullName)
end

function handler(target, method)
    return function(...) return method(target, ...) end
end

function math.round(num)
    return math.floor(num + 0.5)
end

function io.exists(path)
    local file = io.open(path, "r")
    if file then
        io.close(file)
        return true
    end
    return false
end

function io.readfile(path)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        file:close()
        return content
    end
    return nil
end


function io.writefile(path, content, mode)
    mode = mode or "w+b"
    local file = io.open(path, mode)
    if file then
        if file:write(content) == nil then return false end
        io.close(file)
        return true
    else
        return false
    end
end

function io.pathinfo(path)
    local pos = string.len(path)
    local extpos = pos + 1
    while pos > 0 do
        local b = string.byte(path, pos)
        if b == 46 then -- 46 = char "."
            extpos = pos
        elseif b == 47 then -- 47 = char "/"
            break
        end
        pos = pos - 1
    end

    local dirname = string.sub(path, 1, pos)
    local filename = string.sub(path, pos + 1)
    extpos = extpos - pos
    local basename = string.sub(filename, 1, extpos - 1)
    local extname = string.sub(filename, extpos)
    return {
        dirname = dirname,
        filename = filename,
        basename = basename,
        extname = extname
    }
end

function io.filesize(path)
    local size = false
    local file = io.open(path, "r")
    if file then
        local current = file:seek()
        size = file:seek("end")
        file:seek("set", current)
        io.close(file)
    end
    return size
end

function table.nums(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

function table.keys(t)
    local keys = {}
    for k, v in pairs(t) do
        keys[#keys + 1] = k
    end
    return keys
end

function table.values(t)
    local values = {}
    for k, v in pairs(t) do
        values[#values + 1] = v
    end
    return values
end

function table.merge(dest, src)
    for k, v in pairs(src) do
        dest[k] = v
    end
end

--[[--

insert list.

**Usage:**

    local dest = {1, 2, 3}
    local src  = {4, 5, 6}
    table.insertList(dest, src)
    -- dest = {1, 2, 3, 4, 5, 6}
	dest = {1, 2, 3}
	table.insertList(dest, src, 5)
    -- dest = {1, 2, 3, nil, 4, 5, 6}


@param table dest
@param table src
@param table beginPos insert position for dest
]]
function table.insertList(dest, src, beginPos)
	beginPos = tonumber_(beginPos)
	if beginPos == nil then
		beginPos = #dest + 1
	end
	
	local len = #src
	for i = 0, len - 1 do
		dest[i + beginPos] = src[i + 1]
	end
end

--[[
search target index at list.

@param table list
@param * target
@param int from idx, default 1
@param bool useNaxN, the len use table.maxn(true) or #(false) default:false
@param return index of target at list, if not return -1
]]
function table.indexOf(list, target, from, useMaxN)
	local len = (useMaxN and #list) or table.maxn(list)
	if from == nil then
		from = 1
	end
	for i = from, len do
		if list[i] == target then
			return i
		end
	end
	return -1
end

function table.indexOfKey(list, key, value, from, useMaxN)
	local len = (useMaxN and #list) or table.maxn(list)
	if from == nil then
		from = 1
	end
	local item = nil
	for i = from, len do
		item = list[i]
		if item ~= nil and item[key] == value then
			return i
		end
	end
	return -1
end

function table.removeItem(list, item, removeAll)
    local rmCount = 0
    for i = 1, #list do
        if list[i - rmCount] == item then
            table.remove(list, i - rmCount)
            if removeAll then
                rmCount = rmCount + 1
            else 
                break
            end
        end
    end
end

function string.htmlspecialchars(input)
    for k, v in pairs(string._htmlspecialchars_set) do
        input = string.gsub(input, k, v)
    end
    return input
end
string._htmlspecialchars_set = {}
string._htmlspecialchars_set["&"] = "&amp;"
string._htmlspecialchars_set["\""] = "&quot;"
string._htmlspecialchars_set["'"] = "&#039;"
string._htmlspecialchars_set["<"] = "&lt;"
string._htmlspecialchars_set[">"] = "&gt;"

function string.nl2br(input)
    return string.gsub(input, "\n", "<br />")
end

function string.text2html(input)
    input = string.gsub(input, "\t", "    ")
    input = string.htmlspecialchars(input)
    input = string.gsub(input, " ", "&nbsp;")
    input = string.nl2br(input)
    return input
end

function string.split(str, delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(str, delimiter, pos, true) end do
        table.insert(arr, string.sub(str, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(str, pos))
    return arr
end

function string.ltrim(str)
    return string.gsub(str, "^[ \t\n\r]+", "")
end

function string.rtrim(str)
    return string.gsub(str, "[ \t\n\r]+$", "")
end

function string.trim(str)
    str = string.gsub(str, "^[ \t\n\r]+", "")
    return string.gsub(str, "[ \t\n\r]+$", "")
end

function string.ucfirst(str)
    return string.upper(string.sub(str, 1, 1)) .. string.sub(str, 2)
end

--[[--
@ignore
]]
local function urlencodeChar(char)
    return "%" .. string.format("%02X", string.byte(c))
end

function string.urlencode(str)
    -- convert line endings
    str = string.gsub(tostring(str), "\n", "\r\n")
    -- escape all characters but alphanumeric, '.' and '-'
    str = string.gsub(str, "([^%w%.%- ])", urlencodeChar)
    -- convert spaces to "+" symbols
    return string.gsub(str, " ", "+")
end

function string.utf8len(str)
    local len  = #str
    local left = len
    local cnt  = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local tmp = string.byte(str, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end

function string.formatNumberThousands(num)
    local formatted = tostring(tonumber(num))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

--设置锚点与位置,x,y默认为0，锚点默认为0
function setAnchPos(node,x,y,anX,anY)
	local posX , posY , aX , aY = x or 0 , y or 0 , anX or 0 , anY or 0
	node:setAnchorPoint(ccp(aX,aY))
	node:setPosition(ccp(posX,posY))
end


--Usage
--string.format("your name is %{1.name}s age is %{1.age}d \n level is %{1.level}d,%{-2} the value is %d,%{1:getfun}s",
--                      {name="abc",age=13,level=1,getfun=function() return "test" end},9)
--%{-n} native means reset arguments in output order {-1}, after this , parameter restart from 1
--%{set}flag flag same as native format.
--   set can be an int combine with an member, ex: {1.memberValue}s means using the memberValue of first parameter, and output as string.
--   also you may just using the index as {1}s 
--{n@default} {n.xx@defaultValue} {n:xx@defaultValue}
string.format =(function(format)
	string.raw_format = format
	local function _tran(fmt)
		return localization and localization.currentLanguage and localization.currentLanguage[fmt] or type(fmt)=="number" and ""..fmt or fmt
	end
	string.raw_format_tran=function(fmt,...)
		fmt = _tran(fmt)
		return format(fmt,...)
	end
	string._tran = _tran

	local map={}

    return function(fmt,...)
        local args={...}
		fmt= _tran(fmt)

        local fmtstr = ""
        local argslist={}
        local last=1
        local fmt_idxorder = 1
        local recall_start = 1
        local _arglist_idx=1
        function _arglist_insert_item(v,defaultValue)
            if (type(v) == "table" and type(v.toString) == "function") then
                v=v:toString()
            end
            if(not defaultValue or defaultValue=="") then
                defaultValue = "(nil)"
            end
            argslist[_arglist_idx]=v or defaultValue
            _arglist_idx=_arglist_idx+1
        end
        function _checkBeforeCount(str,idx,start)
            local count=0
            for n=idx-1,start,-1 do
                if(str:sub(n,n)=="%") then
                    count=count+1
                else
                    n=start
                end
            end
            return math.mod(count,2)==0
        end       
        function _recallargs(str,start)
            local recall_end = string.len(str)
            while(start <= recall_end) do
                local idx= string.find(str,"%%[^%%]",start)
                if(idx) then
                    if (_checkBeforeCount(str,idx,start)) then
                        _arglist_insert_item(args[fmt_idxorder])
                        fmt_idxorder = fmt_idxorder+1
                    end
                    start =  idx+1
                else
                    start = recall_end+1
                end            
            end
        end

        while(last<=string.len(fmt)) do
            local strstart, strend,value_f,value_op,value_s,defaultValue = string.find(fmt,"%%{(%-?%d*)([%.:]?)([%w_%d]*)@?(.-)}" ,last)
			if(not strstart) then
				strstart, strend,value_s,defaultValue = string.find(fmt,"%%{([%w_%d]*)@?(.-)}" ,last)
				value_f="0"
				value_op="."
			end
            if (strstart) then
                if (_checkBeforeCount(fmt,last,strstart)) then
                    local argidx = tonumber(value_f)
                    fmtstr = fmtstr .. string.sub(fmt,last,strstart-1)
                    _recallargs(fmtstr,recall_start)
                    if(argidx>0) then
                        fmtstr = fmtstr .. "%" 
                        recall_start =  string.len(fmtstr)+2          
                        local arg =args[argidx]                
                        local val=nil
                        if (arg) then
                            local argidx2 = tonumber(value_s) or value_s
                            if (string.len(argidx2)>0) then
                                val = value_op=="." and arg[argidx2] or value_op==":" and arg[argidx2](arg) or nil
                            else
                                val = arg
                            end
                        else
                            val = nil
                        end
                        _arglist_insert_item(val,defaultValue)
                    elseif(argidx<0) then
                        fmt_idxorder = -argidx
                    else
                        -- equ to zero
                    end
                else
                    fmtstr = fmtstr .. string.sub(fmt,last,strend)
                    _recallargs(fmtstr,recall_start) 
                end
                last = strend+1
            else
                fmtstr = fmtstr .. string.sub(fmt,last,string.len(fmt))
                _recallargs(fmtstr,recall_start) 
                last = string.len(fmt)+1
            end
        end

        return format(fmtstr,unpack(argslist)) 
    end
end)(string.format)