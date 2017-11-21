
DataRecord = class("DataRecord")

DataRecord._instance = nil

function DataRecord:ctor()
	
end

function DataRecord:sharedRecord()
	--return self:sharedRecord()
	if self._instance == nil then 
		self._instance = DataRecord:new()
	end
	return self._instance
end

function DataRecord:setBoolForKey(key, val)
	IoRecord:sharedRecord():setBoolForKey(key,val)
end

function DataRecord:getBoolForKey(key)
	return IoRecord:sharedRecord():getBoolForKey(key)
end

function DataRecord:setIntegerForKey(key, val)
	IoRecord:sharedRecord():setIntegerForKey(key,val)
end

function DataRecord:getIntegerForKey(key)
	return IoRecord:sharedRecord():getIntegerForKey(key)
end

function DataRecord:setFloatForKey(key, val)
	IoRecord:sharedRecord():setFloatForKey(key,val)
end

function DataRecord:getFloatForKey(key)
	return IoRecord:sharedRecord():getFloatForKey(key)
end

function DataRecord:setStringForKey(key, val)
	return IoRecord:sharedRecord():setStringForKey(key,val)
end

function DataRecord:getStringForKey(key)
	return IoRecord:sharedRecord():getStringForKey(key)
end


local function serialize(obj)  
    local lua = ""  
    local t = type(obj)  
    if t == "number" then  
        lua = lua .. obj  
    elseif t == "boolean" then  
        lua = lua .. tostring(obj)  
    elseif t == "string" then  
        lua = lua .. string.format("%q", obj)  
    elseif t == "table" then  
        lua = lua .. "{\n"  
    for k, v in pairs(obj) do  
        lua = lua .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ",\n"  
    end  
    local metatable = getmetatable(obj)  
        if metatable ~= nil and type(metatable.__index) == "table" then  
        for k, v in pairs(metatable.__index) do  
            lua = lua .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ",\n"  
        end  
    end  
        lua = lua .. "}"  
    elseif t == "nil" then  
        return nil  
    else  
        error("can not serialize a " .. t .. " type.")  
    end  
    return lua  
end  


local function unserialize(lua)  
    local t = type(lua)  
    if t == "nil" or lua == "" then  
        return nil  
    elseif t == "number" or t == "string" or t == "boolean" then  
        lua = tostring(lua)  
    else  
        error("can not unserialize a " .. t .. " type.")  
    end  
    lua = "return " .. lua  
    local func = loadstring(lua)  
    if func == nil then  
        return nil  
    end  
    return func()  
end


function DataRecord:setTableForKey(key, tbl)
	local str = serialize(tbl)	
	IoRecord:sharedRecord():setStringForKey(key, str)
end

function DataRecord:getTableForKey(key)
	local str = IoRecord:sharedRecord():getStringForKey(key)
	return unserialize(str)	
end



--------------------------------------
--[[
example:

local function hlbIoTest()
	local tab = {}
	tab["old_1"] = "dddddddd"
	tab["old_2"] = "kkkkkkkk"

	DataRecord:sharedRecord():setBoolForKey(1, false)
	DataRecord:sharedRecord():setIntegerForKey(2,1234)
	DataRecord:sharedRecord():setFloatForKey(3,0.987)
	DataRecord:sharedRecord():setStringForKey(4,"hahahahahaha")
	DataRecord:sharedRecord():setTableForKey(5, tab)
	
	local ret  = DataRecord:sharedRecord():getBoolForKey(1)
	local ret2 = DataRecord:sharedRecord():getIntegerForKey(2)
	local ret3 = DataRecord:sharedRecord():getFloatForKey(3)
	local ret4 = DataRecord:sharedRecord():getStringForKey(4)
	local ret5 = DataRecord:sharedRecord():getTableForKey(5)
			
	hlbLog("ret2 = %d", ret2)	
	hlbLog("ret3 = %f", ret3)
	hlbLog("ret4 = %s", ret4)	
	hlbLog("ret5 = %s", ret5["old_1"])	
end			
--]]
--------------------------------------
