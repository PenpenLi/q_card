ActivityStageCheckPoint = class("ActivityStageCheckPoint")
function ActivityStageCheckPoint:ctor(configid)
   self:setIndex(configid)
   self:setOpenTimeStr(AllConfig.activity_stage[configid].open_week_show)
   self:setResouceId(AllConfig.activity_stage[configid].resource_id)
   self:setStageNameResId(AllConfig.activity_stage[configid].stage_name)
   
   local stages = {}
   local stageEasy = Scenario:Instance():getStageById(AllConfig.activity_stage[configid].stage_id_eary)
   local stageNormal = Scenario:Instance():getStageById(AllConfig.activity_stage[configid].stage_id_normal)
   local stageHard = Scenario:Instance():getStageById(AllConfig.activity_stage[configid].stage_id_hard)
   local stageLegend = Scenario:Instance():getStageById(AllConfig.activity_stage[configid].stage_id_higher)
   
   stageEasy:setActivityId(configid)
   stageNormal:setActivityId(configid)
   stageHard:setActivityId(configid)
   stageLegend:setActivityId(configid)
   
   stages[StageConfig.DifficultyTypeEasy] = stageEasy
   stages[StageConfig.DifficultyTypeNormal] = stageNormal
   stages[StageConfig.DifficultyTypeHard] = stageHard
   stages[StageConfig.DifficultyTypeLegend] = stageLegend
   self:setStages(stages)
   
   --set open/close date
   self:setOpenDate(AllConfig.activity_stage[configid].open_date)
   self:setCloseDate(AllConfig.activity_stage[configid].close_date)
   self:setValidWeekDay(AllConfig.activity_stage[configid].week_date)
   --set open/close time
   self:setValidDayTime(AllConfig.activity_stage[configid].open_time, AllConfig.activity_stage[configid].close_time)
end

------
--  Getter & Setter for
--      ActivityStageCheckPoint._Index 
-----
function ActivityStageCheckPoint:setIndex(Index)
	self._Index = Index
end

function ActivityStageCheckPoint:getIndex()
	return self._Index
end

------
--  Getter & Setter for
--      ActivityStageCheckPoint._LastSelectedDifficulty 
-----
function ActivityStageCheckPoint:setLastSelectedDifficulty(LastSelectedDifficulty)
	self._LastSelectedDifficulty = LastSelectedDifficulty
end

function ActivityStageCheckPoint:getLastSelectedDifficulty()
	return self._LastSelectedDifficulty
end

------
--  Getter & Setter for
--      ActivityStageCheckPoint._StageNameResId 
-----
function ActivityStageCheckPoint:setStageNameResId(StageNameResId)
  self._StageNameResId = StageNameResId
end

function ActivityStageCheckPoint:getStageNameResId()
  return self._StageNameResId
end

------
--  Getter & Setter for
--      ActivityStageCheckPoint._ResouceId 
-----
function ActivityStageCheckPoint:setResouceId(ResouceId)
	self._ResouceId = ResouceId
end

function ActivityStageCheckPoint:getResouceId()
	return self._ResouceId
end

------
--  Getter & Setter for
--      ActivityStageCheckPoint._Stages 
-----
function ActivityStageCheckPoint:setStages(Stages)
	self._Stages = Stages
end

function ActivityStageCheckPoint:getStages()
	return self._Stages
end

function ActivityStageCheckPoint:getStageByDiffculty(diffcultyType)
  return self:getStages()[diffcultyType]
end

------
--  Getter & Setter for
--      ActivityStageCheckPoint._OpenTimeStr 
-----
function ActivityStageCheckPoint:setOpenTimeStr(OpenTimeStr)
	self._OpenTimeStr = OpenTimeStr
end

function ActivityStageCheckPoint:getOpenTimeStr()
	return self._OpenTimeStr
end

------
--  Getter & Setter for
--      ActivityStageCheckPoint._OpenDate 
-----
function ActivityStageCheckPoint:setOpenDate(OpenDate)
	self._OpenDate = OpenDate
end

function ActivityStageCheckPoint:getOpenDate()
	return self._OpenDate
end

------
--  Getter & Setter for
--      ActivityStageCheckPoint._CloseDate 
-----
function ActivityStageCheckPoint:setCloseDate(CloseDate)
	self._CloseDate = CloseDate
end

function ActivityStageCheckPoint:getCloseDate()
	return self._CloseDate
end

------
--  Getter & Setter for
--      ActivityStageCheckPoint._ValidWeekDay 
-----
function ActivityStageCheckPoint:setValidWeekDay(ValidWeekDay)
	self._ValidWeekDay = ValidWeekDay
end

function ActivityStageCheckPoint:getValidWeekDay()
	return self._ValidWeekDay
end

function ActivityStageCheckPoint:setActivityStageCheckPointState(State)
  self._State = State
end

local function sortTables(a, b)
   return a < b
end

function ActivityStageCheckPoint:getRecentValidDayOffset()
  local found = false
  local dayOffset = 0

  --get current weekday and judge today's time region info
  local isBehindClosedTime = false
  local timeTable = Clock:Instance():getCurServerTimeAsTable()
  local currentSecond = timeTable.hour * 3600 + timeTable.min * 60 + timeTable.sec

  local currentWeekDay = timeTable.wday - 1
  if currentSecond > self.closeTime then
    isBehindClosedTime = true
  end
  
  table.sort(self._ValidWeekDay,sortTables)
  
  --calculate day offset
  --print("#self._ValidWeekDay",#self._ValidWeekDay)
  for i = 1, #self._ValidWeekDay do 
    --echo("self._ValidWeekDay["..i.."]:",self._ValidWeekDay[i],i)
    --echo("currentWeekDay:",currentWeekDay)
    if self._ValidWeekDay[i] >= currentWeekDay then 
      dayOffset = self._ValidWeekDay[i] - currentWeekDay
      --print("!@dayOffset:",dayOffset)
      if dayOffset == 0 and isBehindClosedTime == true then --当天但已超过有效时间段
      else
        found = true
        break
      end
    end
  end
  if found == false then
    dayOffset = 6 - currentWeekDay + self._ValidWeekDay[1] + 1
  end
  return dayOffset
end 

function ActivityStageCheckPoint:setValidDayTime(openMin, closeMin)
  self.openTime = openMin * 60
  self.closeTime = closeMin * 60
end

function ActivityStageCheckPoint:hasStageToChallenge()
  local hasStageToChallenge = false
  local stages = {} 
  if self:getLeftTime() > 0 then
     
  else
     local timeTable = Clock:Instance():getCurServerTimeAsTable()
     local curDate = timeTable.year * 10000 + timeTable.month * 100 + timeTable.day
     local currentSecond = timeTable.hour * 3600 + timeTable.min*60 + timeTable.sec
     for key, stage in pairs(self:getStages()) do
        local stg = Scenario:Instance():getStageById(stage:getStageId())
        local lastEnterTime = stg:getLastEnterTime()
        local lastTimeTable = os.date("!*t", lastEnterTime)
        local lastDate = lastTimeTable.year * 10000 + lastTimeTable.month * 100 + lastTimeTable.day
        local lastSecond = lastTimeTable.hour * 3600 + lastTimeTable.min*60 + lastTimeTable.sec
        if stg:getLastEnterTime() > 0 then
            local cdOpenTime = lastSecond + stg:getEnterCD()
            local leftOpenTime =  cdOpenTime - currentSecond
            if leftOpenTime <= 0 then
               if GameData:Instance():getCurrentPlayer():getLevel() >= stg:getRequiredCharLevel()
               and stg:getLeftTimesToday() > 0
               then
                  hasStageToChallenge = true
                  stage = stg
                  break
               end
            end
        else
           if GameData:Instance():getCurrentPlayer():getLevel() >= stg:getRequiredCharLevel()
           and stg:getLeftTimesToday() > 0
           then
              hasStageToChallenge = true
              table.insert(stages,stg)
           end
        end
     end
  end
  
  return hasStageToChallenge,stages
end

function ActivityStageCheckPoint:getLeftTime()
  local leftTime = 0
  local timeTable = Clock:Instance():getCurServerTimeAsTable()
  local curDate = timeTable.year * 10000 + timeTable.month * 100 + timeTable.day
  local currentSecond = timeTable.hour * 3600 + timeTable.min*60 + timeTable.sec

  --关闭时间
  if (curDate >= self._OpenDate and curDate < self._CloseDate) then --关闭时间少一天
  
    if currentSecond < self.openTime then        --"未开启"
      leftTime = self.openTime - currentSecond
      --print("!未开启:",leftTime)
    elseif currentSecond < self.closeTime then   --"开启中"
      --leftTime = self.closeTime - currentSecond
      --print("!开启中:",leftTime)
    else                                  
      --leftTime = -(currentSecond-self.openTime)  --"已关闭"
      --print("!已关闭")
    end

    --print("!day offset:",self:getRecentValidDayOffset())
    if self:getRecentValidDayOffset() == 1 then
       leftTime = self.openTime - currentSecond%(24*3600)
       --print("!day offset time:",leftTime)
    end
    
    local timeOffset = 24*3600*self:getRecentValidDayOffset()
    
    leftTime = leftTime + timeOffset
  end
  return leftTime
end

return ActivityStageCheckPoint