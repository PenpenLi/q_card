Object = Object or {}

function Object.Extend(obj,extobj)
	local _ext = extobj or {}
	local ret=setmetatable(_ext, {__index=function(self,key)
		return obj[key]
	end})

	return ret  
end
function Object.getInstance(self)
  if self._instance == nil then
     self._instance = self.new()
  end
  return self._instance
end

function Object.FunctionBinder(fun,obj,...)
	local args= obj ==nil and {...} or {obj,...} 
	return function(...)
		local args1 = {...} or {}
		for n,v in ipairs(args) do
			table.insert(args1,n,v)
		end
		return fun(unpack(args1))
	end
end



NumberHelp={
	greateThanZero =function(n)
		return n>0 and n or 0
	end,
	autoCountString = function (n,sub,range,name)
		range = range and range or 10000
		name = name and name or "wan"
		if(n>=range) then
			sub = sub and sub or 0
			if (sub>0) then
				if (n%range==0) then
					sub=0
				end
			end
			return string.raw_format("%."..sub.."f"..string._tran(name), n/range)
		end
		return n
	end,
	toString=function (n)
		return n..""
	end

}
