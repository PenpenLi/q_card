
--所有时间以服务器时间 (uct + time zone) 为准 
--注意: os.time() 和 os.date("!*t"...) 对应不考虑时区时对应的标准时间
-- os.date("*t"...) 对应本地时间(已考虑时区因素)

Clock = class("Clock")

Clock._Instance = nil

function Clock:ctor()
end

function Clock:Instance()
	if Clock._Instance == nil then
		Clock._Instance = Clock.new()
	end
	return Clock._Instance
end

-- 服务器与本地时间的差值
function Clock:setDeviationTime(serverTime)  
  self.serverTimeOffset = serverTime - os.time()
end

function Clock:getDeviationTime()
	return self.serverTimeOffset or 0 
end

function Clock:setTimeZone(zone)
  self._timeZone = zone 
end 

function Clock:getTimeZone()
  return self._timeZone or "MST+8"
end

function Clock:format_time(timestamp, tzname)
  local tzoffset = 0
  local sign = 1
  tzname = tzname or "MST+8"
  if tzname:sub(1, 3) == "MST" then
    if tzname:sub(4,4) == "-" then
      sign = -1
    end
    tzoffset = tzname:sub(5, -1)
    tzoffset = sign * tzoffset * 60 * 60
  end
  
  return timestamp + tzoffset
end



--获取当前服务器时间(正确的本地时间)
function Clock:getCurServerTime()
  return self:format_time(os.time()+self:getDeviationTime(), self:getTimeZone())
end

--获取当前服务器标准时间(时区为0)
function Clock:getCurServerUtcTime()
  return os.time() + self:getDeviationTime()
end

function Clock:getCurServerTimeAsTable()
  return os.date("!*t", self:getCurServerTime()) 
end

function Clock:setServerOpenTime(utcTime, zone)
  self._serverOpenTime = self:format_time(utcTime, zone)
end 

function Clock:getServerOpenTime(bTableType)
  if bTableType then 
    return os.date("!*t", self._serverOpenTime) 
  end   

  return self._serverOpenTime
end 

function Clock:getServerOpenTimeAsTable()
  return os.date("!*t", self._serverOpenTime) 
end 

function Clock:setPlayerCreateTime(utcTime)
  self._playerCreateTime = self:format_time(utcTime, self:getTimeZone())
end 

function Clock:getPlayerCreateTime(bTableType)
  if bTableType then 
    return os.date("!*t", self._playerCreateTime) 
  end 

  return self._playerCreateTime 
end 

function Clock:getTime(utcTime)
  return self:format_time(utcTime, self:getTimeZone())
end 

-- 20141011 --->utc second
function Clock:getTimeByDate(date)
  local yy = math.floor(date/10000)
  local mm = math.floor((date-yy*10000)/100)
  local dd = date - yy*10000 - mm*100
  local utcTime = os.time({year=yy, month=mm, day=dd, hour=0,min=0, sec=0})

  return self:getTime(utcTime)  
end 







function Clock:DiffWithServerTime(t)
	return t-self:getCurServerUtcTime()
end


Clock.Type = enum({"AUTO","AUTOMAXTYPE","AUTODAYORTIME","NODAY","ONLYDAY","ONLYHOURS","ONLYMINS","ONLYSECONDS","MINSSCONDS"})
function Clock.format(seconds,type)
	if (type == nil) then
		type = Clock.Type.AUTO
	end
	
	local clockTypeAuto = function()
      local min = math.floor(seconds/60)
      seconds =seconds- min*60
      local hour = math.floor(min/60)
      min =min- hour*60
      local day = math.floor(hour/24)
      hour =hour- day*24

      local ret
      if (day == 0) then
        return string.raw_format_tran(Consts.Strings.TimeShortFormat,hour,min,seconds)
      end
      return string.raw_format_tran(Consts.Strings.TimeShortFormatWithDay,day,hour,min,seconds)
  end
  
  
  local clockTypeNoDay = function()
      local min = math.floor(seconds/60)
      seconds =seconds- min*60
      local hour = math.floor(min/60)
      min =min- hour*60
      return string.raw_format_tran(Consts.Strings.TimeShortFormat,hour,min,seconds)
  end
  
  local clockTypeOnlyDay = function()
    local day = math.ceil(seconds/(60*60*24))

    return string.raw_format_tran(Consts.Strings.TimeOnlyDayFormat,day)
  end
  
  local clockTypeOnlyHours = function()
    local hours = math.ceil(seconds/(60*60))
    return string.raw_format_tran(Consts.Strings.TimeOnlyHoursFormat,hours)
  end
  
  local clockTypeOnlyMins = function()
    local mins = math.ceil(seconds/60)
    return string.raw_format_tran(Consts.Strings.TimeOnlyMinusFormat,mins)
  end
  
  local clockTypeOnlySeconds = function()
    return string.raw_format_tran(Consts.Strings.TimeOnlySecondsFormat,seconds)
  end 
	
	local clockTypeMinssconds = function()
    local mins = math.floor(seconds/60)
    local seconds = seconds - mins*60

    return string.raw_format_tran(Consts.Strings.TimeMinsSecondsFormat,mins,seconds)
  end 
  
  local clockTypeAutoMaxType = function()
      local min = math.floor(seconds/60)
      seconds =seconds- min*60
      local hour = math.floor(min/60)
      min =min- hour*60
      local day = math.floor(hour/24)
      hour =hour- day*24

      if(day>0) then
        return clockTypeOnlyDay()
      elseif(hour>0) then
        return clockTypeOnlyHours()
      elseif(min>0) then
        return clockTypeOnlyMins()
      end
      return clockTypeOnlySeconds()
  end
  
  local clockTypeAutoDayOrTime = function()
    local day = math.floor(seconds/(60*60*24))
    if(day>0) then
      return clockTypeOnlyDay()
    end
    return clockTypeNoDay()
  end
	
	local cfg = {
		[Clock.Type.AUTO] = clockTypeAuto,
		[Clock.Type.AUTOMAXTYPE] = clockTypeAutoMaxType,
		[Clock.Type.AUTODAYORTIME] = clockTypeAutoDayOrTime,
		[Clock.Type.NODAY] = clockTypeNoDay,
		[Clock.Type.ONLYDAY] = clockTypeOnlyDay,
		[Clock.Type.ONLYHOURS] = clockTypeOnlyHours,
		[Clock.Type.ONLYMINS] = clockTypeOnlyMins,
		[Clock.Type.ONLYSECONDS] = clockTypeOnlySeconds,
		[Clock.Type.MINSSCONDS] = clockTypeMinssconds
	}

	return cfg[type]()
end

return Clock