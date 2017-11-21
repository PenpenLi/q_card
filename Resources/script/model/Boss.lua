--require("model.Item")
Boss = class("Boss")

BossState = enum({"CLOSE", "KILLED", "BEFORE_OPEN", "WAITING_FOR_OPEN", "FIGHTING"})

function Boss:ctor(bossInitData)
  --Boss.super.ctor(self)

  --local bossInitData = AllConfig.bossinitdata[id]
  self:setMap(bossInitData.stage)
  self:setHeadPicId(bossInitData.head_pic)
  self:setUnitPicId(bossInitData.unit_pic)
  self:setId(bossInitData.id)
  self:setName(bossInitData.event_name)
  self:setNameImgId(bossInitData.boss_name)
  self:setLevel(bossInitData.level)
  local hp = AllConfig.battle[bossInitData.level].boss_hp
  self:setHp(hp)
  self:setTotalHp(hp)

  --set open/close date
  self:setOpenDate(bossInitData.open_date)
  self:setCloseDate(bossInitData.close_date)
  self:setValidWeekDay(bossInitData.week_date)
  --set open/close time
  self:setValidDayTime(bossInitData.open_time, bossInitData.close_time)

  --default value
  self:setDamage(5100)
  self:setDamageForPlayer(0)
  self:setFrozenTime(0)
  self:setBossState(BossState.CLOSE) --默认关闭
  --echo("[Boss]:", bossInitData.id, bossInitData.open_time, bossInitData.close_time)
end

function Boss:setId(id)
  self._id = id
end

function Boss:getId()
  return self._id
end

function Boss:setName(str)
  self._name = str
end

function Boss:getName()
  return self._name
end

function Boss:setMap(stageId)
  self._stage = stageId
end 

function Boss:getMap()
  return self._stage
end

function Boss:setHeadPicId(resId)
  self._resId = resId
end 

function Boss:getHeadPicId()
  return self._resId
end

function Boss:setUnitPicId(resId)
  self._unitResId = resId
end 

function Boss:getUnitPicId()
  return self._unitResId
end 

function Boss:setLevel(level)
  self._level = level
end

function Boss:getLevel()
  return self._level
end

function Boss:setNameImgId(imgId)
  self._nameImgId = imgId
end

function Boss:getNameImgId()
  return self._nameImgId
end

function Boss:setOpenDate(openDate)
  -- local open_year = math.floor(openDate/10000)
  -- local open_month = math.floor((openDate - open_year*10000)/100)
  -- local open_day = openDate - open_year*10000 - open_month * 100
  -- --local tt = { year=open_year, month=open_month, day=open_day, hour=0, min=0, sec=0}
  -- --self.openDateTime = os.time(tt)
  -- self.openDateTime = (open_year-1970)*365*24*3600 + 
  -- echo("bossid, open_year, openDateTime=",self:getId(), open_year,self.openDateTime)
  self._openDate = openDate
end

function Boss:setCloseDate(closeDate)
  -- local close_year = math.floor(closeDate/10000)
  -- local close_month = math.floor((closeDate - close_year*10000)/100)
  -- local close_day = closeDate - close_year*10000 - close_month * 100
  -- local tt = {year=close_year, month=close_month, day=close_day, hour=23, min=59, sec=59}
  -- self.closeDateTime = os.time(tt) 
  -- echo("bossid, close_year, closeDateTime=",self:getId(), close_year,self.closeDateTime)
  self._closeDate = closeDate
end

function Boss:setValidWeekDay(dayArray)
  self._weekDay = {}

  for i=1, table.getn(dayArray) do
    if dayArray[i] == -1 then 
      self._weekDay = {0,1,2,3,4,5,6}
    else
      table.insert(self._weekDay, dayArray[i])
    end
  end
end

function Boss:getValidWeekDay()
  return self._weekDay
end


function Boss:setDamage(damage)
  self._damage = damage
end

function Boss:getDamage()
  return self._damage
end

function Boss:setDamageForPlayer(damage)
  self._playerDamage = damage
end

function Boss:getDamageForPlayer()
  return self._playerDamage
end

function Boss:setHp(hp)
  self._hp = hp
end

function Boss:getHp()
  return self._hp
end

function Boss:setTotalHp(hp)
  self._totalHp = hp
end

function Boss:getTotalHp()
  return self._totalHp
end

function Boss:setExtPlusCards(tbl)
  if tbl ==nil then 
    return
  end

  self.plusCards = {}
  for i=1, table.getn(tbl) do 
    local card = {configId = tbl[i].card*100+1, plus = tbl[i].per/100}
    table.insert(self.plusCards, card)
  end
end

function Boss:getExtPlusCards()
  if self.plusCards == nil then 
    self.plusCards = {}
  end

  return self.plusCards
end

function Boss:setFrozenTime(time)
  self._frozenTime = time
end

function Boss:getFrozenTime()
  return self._frozenTime
end

function Boss:updateTopPlayerRank(rankMsg)
  self._rank = {}

  if rankMsg == nil then 
    return
  end

  local count = math.min(3, table.getn(rankMsg))
  for i = 1, count do 
    local tmp = {name = rankMsg[i].name, hurt = rankMsg[i].damage}
    table.insert(self._rank, tmp)
  end
end

function Boss:getTopPlayerRank()
  return self._rank
end



function Boss:setBossState(state)
  self._state = state
end

--except fighting, other state should be check everytime
function Boss:getBossState(needRefresh, curDateInfo)
  
  if needRefresh == true then 
    if self._state ~= BossState.FIGHTING and self._state ~= BossState.WAITING_FOR_OPEN then --讨伐中和等待开启 不再进行状态调整.
      if curDateInfo == nil then 
        curDateInfo = Clock:Instance():getCurServerTimeAsTable()
      end 
      local curDate = curDateInfo.year * 10000 + curDateInfo.month * 100 + curDateInfo.day
      local curSec = curDateInfo.hour * 3600 + curDateInfo.min*60 + curDateInfo.sec

      if (curDate >= self._openDate and curDate <= self._closeDate) then

        local offsetDays = self:getRecentValidDayOffset(curDateInfo)
        if offsetDays == 0 then --today boss is on schedule
          local tt = curDateInfo.hour*3600 + curDateInfo.min*60 + curDateInfo.sec
          if tt < self.openTime then    --"未开启"
            self:setBossState(BossState.BEFORE_OPEN)
          elseif tt < self.closeTime - 10 then      --"已击杀"  即如果在有效时间内被关闭则意味被击杀,考虑到与服务器误差,这里减去10秒
            self:setBossState(BossState.KILLED)
          else 
            self:setBossState(BossState.CLOSE)      --"已关闭"
          end
        else
          self:setBossState(BossState.BEFORE_OPEN)  --非今天的Boss则设置 未开启
        end
      end
    end  
  end

  return self._state
end


function Boss:setValidDayTime(openMin, closeMin)
  self.openTime = openMin*60
  self.closeTime = closeMin*60
end


--最近一次的天数间隔
function Boss:getRecentValidDayOffset(curDateInfo)
  local found = false
  local dayOffset = 0

  --get current weekday and judge today's time region info
  local isBehindClosedTime = false
  local curSec = curDateInfo.hour*3600 + curDateInfo.min*60 + curDateInfo.sec

  curWeekDay = curDateInfo.wday - 1
  if curSec > self.closeTime then
    isBehindClosedTime = true
  end

  --calculate day offset
  for i=1, table.getn(self._weekDay) do 
    if self._weekDay[i] >= curWeekDay then 
      dayOffset = self._weekDay[i] - curWeekDay

      if dayOffset == 0 and isBehindClosedTime == true then --当天boss已超过有效时间段
        --echo("getRecentValidDayOffset: boss has been closed", self:getId())
      else
        found = true
        break
      end
    end
  end

  if found == false then
    dayOffset = 6 - curWeekDay + self._weekDay[1] + 1
  end

  --echo("--getRecentValidDayOffset:bossId, offset=", self:getId(), dayOffset, found)
  return dayOffset
end 

--最近一次的时间(秒)间隔
function Boss:updateLeftTime(curDateTable)
  local leftTime = 2*24*3600
  local curDate = curDateTable.year * 10000 + curDateTable.month * 100 + curDateTable.day
  local curSec = curDateTable.hour * 3600 + curDateTable.min*60 + curDateTable.sec

  if (curDate >= self._openDate and curDate < self._closeDate) then --关闭时间少一天
    if curSec < self.openTime then        --"未开启"
      leftTime = self.openTime - curSec
    elseif curSec < self.closeTime then   --"讨伐中/已击杀"
      leftTime = self.closeTime - curSec
    else                                  
      leftTime = -(curSec-self.openTime)  --"已关闭"
    end

    local timeOffset = 24*3600*self:getRecentValidDayOffset(curDateTable)
    leftTime = leftTime + timeOffset
  end

  self._leftTime = leftTime
  --echo("=====_leftTime=", leftTime)
  return leftTime
end

function Boss:getLeftTime(needRefresh, curDateInfo)
  if needRefresh == true then 
    if curDateInfo == nil then 
      curDateInfo = Clock:Instance():getCurServerTimeAsTable()
    end 
    self:updateLeftTime(curDateInfo)
  end

  return self._leftTime
end 

function Boss:setSpeedUpCount(count)
  self._speedUpCount = count
end 

function Boss:getSpeedUpCount()
  if self._speedUpCount == nil then 
    self._speedUpCount = 0
  end 
  
  return self._speedUpCount
end 

return Boss
