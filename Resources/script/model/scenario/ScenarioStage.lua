require("model.battle.BattleCard")
ScenarioStage = class("ScenarioStage")
--StageState = enum({ "STAGE_CLOSE","STAGE_OPEN","STAGE_STAR_1","STAGE_STAR_2","STAGE_STAR_3"})
function ScenarioStage:ctor(instanceData)
  self:setEnabledAutoNextChapter(true)
  self:setIsOpen(false)
  self:setGrade(0)
  self:setProgress(0)
  self:setPassedCount(0)
 
  self:setLastEnterTime(0)
  self:setActivityId(0)
  self:setEnterCD(0)
  self:setBoughtCountToday(0)
  
	self:setInstanceData(instanceData)
end

function ScenarioStage:setInstanceData(instanceData)
--  enum StageResult{
--    STAGE_CLOSE  = 0;
--    STAGE_OPEN   = 1;
--    STAGE_STAR_1 = 2;
--    STAGE_STAR_2 = 3;
--    STAGE_STAR_3 = 4;
--  }
--
--  required int32 stage = 1;
--  required int32 count = 3;   //每天可以打副本的次数
--  optional int32 star1 = 4;   //1星通过次数
--  optional int32 star2 = 5;   //2星通过次数
--  optional int32 star3 = 6;   //3星通过次数
--  optional int32 pass  = 7;   //总通过次数
--  optional int32 last_enter_time = 8; //最后一次进入副本时间
--  optional int32 buy_count = 9; //每日购买次数
--  required StageResult result = 2;
  
  self._instanceData = instanceData
	if self._instanceData ~= nil then
	   --echo(self._instanceData.result)
	   self:setStageId(self._instanceData.stage)
     self:setPassedCount(self._instanceData.pass)
     self:setLastEnterTime(self._instanceData.last_enter_time)
     self:setBoughtCountToday(self._instanceData.buy_count)
     
     if self:getLeftTimesToday() ~= -1 then
        if self._instanceData.count ~= -1 then
           self:setLeftTimesToday(self._instanceData.count)
        end
     end
     
	   if self._instanceData.result == "STAGE_CLOSE" then
	     self:setIsOpen(false)
	   elseif self._instanceData.result == "STAGE_OPEN" then
	     self:setIsOpen(true)
	     self:setGrade(0)
	   elseif self._instanceData.result == "STAGE_STAR_1" then -- passed but not geted star
	     self:setIsOpen(true)
	     self:setGrade(1)
	   elseif self._instanceData.result == "STAGE_STAR_2" then -- geted star
	     self:setIsOpen(true)
	     self:setGrade(2)
	     --1020011
	   elseif self._instanceData.result == "STAGE_STAR_3" then
	     self:setIsOpen(true)
       self:setGrade(3)
	   else
	     self:setIsOpen(false)
	     self:setGrade(0)
	   end
	end
end

------
--  Getter & Setter for
--      ScenarioStage._ReportInfo 
-----
function ScenarioStage:setReportInfo(ReportInfo)
	self._ReportInfo = ReportInfo
end

function ScenarioStage:getReportInfo()
	return self._ReportInfo
end

function ScenarioStage:getBuyCount()
  local vipLevelId = GameData:Instance():getCurrentPlayer():getVipLevelId()
  
  local vipPrivilegeId = self:getBuyCountId()
  local totalCanBuyCountToday = 0
  if AllConfig.vip_privilege[vipPrivilegeId] ~= nil then
     totalCanBuyCountToday = AllConfig.vip_privilege[vipPrivilegeId].privilege[vipLevelId]
  end
	return totalCanBuyCountToday
end

function ScenarioStage:getIsCanBuyToday()
  if self:getPermitBuy() == false then
    return false,0
  end
  return self:getBoughtCountToday() < self:getBuyCount(),self:getBuyCount() - self:getBoughtCountToday()
end

function ScenarioStage:getBuyPriceNow()
  local forcibleCount = self:getBoughtCountToday()
  local needMoney = 0
  for key, var in pairs(AllConfig.cost) do
     if var.type == 15 then
        --print(var.cost)
        if var.min_count == forcibleCount + 1 then
           needMoney = var.cost
           break
        end
     end
  end
  
  if needMoney < 0 then
     needMoney = 0
  end
  
  return needMoney
end

------
--  Getter & Setter for
--      ScenarioStage._EnterCD 
-----
function ScenarioStage:setEnterCD(EnterCD)
	self._EnterCD = EnterCD
end

function ScenarioStage:getEnterCD()
	return self._EnterCD
end

------
--  Getter & Setter for
--      ScenarioStage._BoughtCountToday 
-----
function ScenarioStage:setBoughtCountToday(BoughtCountToday)
	self._BoughtCountToday = BoughtCountToday
end

function ScenarioStage:getBoughtCountToday()
	return self._BoughtCountToday
end

------
--  Getter & Setter for
--      ScenarioStage._LastEnterTime 
-----
function ScenarioStage:setLastEnterTime(LastEnterTime)
	self._LastEnterTime = LastEnterTime
end

function ScenarioStage:getLastEnterTime()
	return self._LastEnterTime
end

------
--  Getter & Setter for
--      ScenarioStage._ActivityId 
-----
function ScenarioStage:setActivityId(ActivityId)
	self._ActivityId = ActivityId
end

function ScenarioStage:getActivityId()
	return self._ActivityId
end

------
--  Getter & Setter for
--      ScenarioStage._LeftTimesToday 
-----
function ScenarioStage:setLeftTimesToday(LeftTimesToday)
	self._LeftTimesToday = LeftTimesToday
end

function ScenarioStage:getLeftTimesToday()
	return self._LeftTimesToday
end

------
--  Getter & Setter for
--      ScenarioStage._StageState 
-----
function ScenarioStage:setStageState(StageState)
	self._StageState = StageState
end

function ScenarioStage:getStageState()
	return self._StageState
end

function ScenarioStage:getInstanceData()
  return self._instanceData
end

function ScenarioStage:setPassedCount(PassedCount)
	self._PassedCount = PassedCount
end

function ScenarioStage:getPassedCount()
	return self._PassedCount
end

function ScenarioStage:setStageId(stageId)
  self._stageId = stageId
  if AllConfig.stage[stageId] == nil then
    return
  end
  self:setStageName(AllConfig.stage[stageId].stage_name)
  self:setStageCharExp(AllConfig.stage[stageId].stage_char_exp)
  self:setStageChapterId(AllConfig.stage[stageId].chapter_id)
  self:setStageChapterName(AllConfig.stage[stageId].chapter_name)
  self:setPreStageId(AllConfig.stage[stageId].pre_stage)
  self:setNextStageId(AllConfig.stage[stageId].next_stage)
  self:setStageType(AllConfig.stage[stageId].stage_type)
  self:setCost(AllConfig.stage[stageId].cost)
  self:setRequiredCharLevel(AllConfig.stage[stageId].required_char_level)
  self:setGateHp(AllConfig.stage[stageId].gate_hp)
  self:setMonsterGroupId(AllConfig.stage[stageId].monster_group)
  self:setTerritory(AllConfig.stage[stageId].territory)
  self:setBackground(AllConfig.stage[stageId].background)
  self:setDropShow(AllConfig.stage[stageId].drop_show)
  self:setStageDesc(AllConfig.stage[stageId].stage_desc)
  self:setDifficultyType(AllConfig.stage[stageId].difficulty_type)
  self:setStageCoin(AllConfig.stage[stageId].stage_coin)
  self:setHeadRes(AllConfig.stage[stageId].unit_head_pic)
  self:setLeftTimesToday(AllConfig.stage[stageId].day_enter_limit)
  self:setPermitBuy((AllConfig.stage[stageId].permit_buy == 1))
  self:setEnterCD(AllConfig.stage[stageId].enter_cd)
  self:setStageConditionId(AllConfig.stage[stageId].condition)
  self:setBuyCountId(AllConfig.stage[stageId].vip_buy_count)
  self:setStageConditionDesc("")
  if AllConfig.stagecondition ~= nil then
     local conditionId = AllConfig.stage[stageId].condition
     if AllConfig.stagecondition[conditionId] ~= nil then
        self:setStageConditionDesc(AllConfig.stagecondition[conditionId].desc)
     end
  end
  
  -- stage day_enter_limit activity
  for key, activity in pairs(AllConfig.activity) do
    if activity.activity_id == 5004 then
        if Activity:instance():getActivityLeftTime(activity.activity_id) > 0 then 
         if self:getStageType() == activity.activity_drop[1] then
            self:setLeftTimesToday(activity.activity_drop[2])
            break
         end
       end
    end
  end
  
  -- stage spirit activity
  for key, activity in pairs(AllConfig.activity) do
    if activity.activity_id == 5002 then
       if Activity:instance():getActivityLeftTime(activity.activity_id) > 0 then 
         if self:getStageType() == activity.activity_drop[1] then
            self:setCost(activity.activity_drop[2])
            break
         end
       end
    end
  end
end

------
--  Getter & Setter for
--      ScenarioStage._BuyCountId 
-----
function ScenarioStage:setBuyCountId(BuyCountId)
	self._BuyCountId = BuyCountId
end

function ScenarioStage:getBuyCountId()
	return self._BuyCountId
end

function ScenarioStage:getStagePosStr()
  if self:getStageType() == StageConfig.StageActivity then
    return ""
  end
  return self:getStageChapterId().. "-"..self:getCheckPointIndex()
end

------
--  Getter & Setter for
--      ScenarioStage._PermitBuy 
-----
function ScenarioStage:setPermitBuy(PermitBuy)
	self._PermitBuy = PermitBuy
end

function ScenarioStage:getPermitBuy()
	return self._PermitBuy
end

------
--  Getter & Setter for
--      ScenarioStage._StageConditionId 
-----
function ScenarioStage:setStageConditionId(StageConditionId)
	self._StageConditionId = StageConditionId
end

function ScenarioStage:getStageConditionId()
	return self._StageConditionId
end

------
--  Getter & Setter for
--      ScenarioStage._HeadRes 
-----
function ScenarioStage:setHeadRes(HeadRes)
	self._HeadRes = HeadRes
end

function ScenarioStage:getHeadRes()
	return self._HeadRes
end

------
--  Getter & Setter for
--      ScenarioStage._StageConditionDesc 
-----
function ScenarioStage:setStageConditionDesc(StageConditionDesc)
	self._StageConditionDesc = StageConditionDesc
end

function ScenarioStage:getStageConditionDesc()
	return self._StageConditionDesc
end

function ScenarioStage:getStageId()
  return self._stageId
end

function ScenarioStage:setDropShow(DropShow)
	self._DropShow = DropShow
end

function ScenarioStage:getDropShow()
	return self._DropShow
end

------
--  Getter & Setter for
--      ScenarioStage._StageDesc 
-----
function ScenarioStage:setStageDesc(StageDesc)
	self._StageDesc = StageDesc
end

function ScenarioStage:getStageDesc()
	return self._StageDesc
end

------
--  Getter & Setter for
--      ScenarioStage._StageCoin 
-----
function ScenarioStage:setStageCoin(StageCoin)
	self._StageCoin = StageCoin
end

function ScenarioStage:getStageCoin()
	return self._StageCoin
end
------
--  Getter & Setter for
--      ScenarioStage._PreStage 
-----
function ScenarioStage:setPreStage(PreStage)
	self._PreStage = PreStage
end

function ScenarioStage:getPreStage()
	return self._PreStage
end

function ScenarioStage:setStageCharExp(StageCharExp)
	self._StageCharExp = StageCharExp
end

function ScenarioStage:setMonsterGroupId(MonsterGroupId)
	self._MonsterGroupId = MonsterGroupId
end

------
--  Getter & Setter for
--      ScenarioStage._CheckPointIndex 
-----
function ScenarioStage:setCheckPointIndex(CheckPointIndex)
	self._CheckPointIndex = CheckPointIndex
end

function ScenarioStage:getCheckPointIndex()
	return self._CheckPointIndex
end

------
--  Getter & Setter for
--      ScenarioStage._CheckPoint 
-----
function ScenarioStage:setCheckPoint(CheckPoint)
	self._CheckPoint = CheckPoint
end

function ScenarioStage:getCheckPoint()
	return self._CheckPoint
end

------
--  Getter & Setter for
--      ScenarioStage._DifficultyType 
-----
function ScenarioStage:setDifficultyType(DifficultyType)
	self._DifficultyType = DifficultyType
end

function ScenarioStage:getDifficultyType()
	return self._DifficultyType
end


function ScenarioStage:setTerritory(Territory)
	self._Territory = Territory
end

function ScenarioStage:getTerritory()
	return self._Territory
end

function ScenarioStage:getStageCharExp()
	return self._StageCharExp
end

function ScenarioStage:setRequiredCharLevel(RequiredCharLevel)
	self._RequiredCharLevel = RequiredCharLevel
end

function ScenarioStage:getRequiredCharLevel()
	return self._RequiredCharLevel
end

function ScenarioStage:setStageName(StageName)
	self._StageName = StageName
end

function ScenarioStage:getStageName(needShowIdx)
  if needShowIdx == nil then
    needShowIdx = true
  end
  if needShowIdx == true then
	  return self:getStagePosStr()..self._StageName
	else
	  return self._StageName
	end
end

function ScenarioStage:setGateHp(GateHp)
	self._GateHp = GateHp
end

function ScenarioStage:getGateHp()
	return self._GateHp
end

function ScenarioStage:setStageType(StageType)
	self._StageType = StageType
	if StageType == StageConfig.StageTypeNormal or StageType == StageConfig.StageTypeNormalHide then
	   self:setIsElite(false)
	elseif StageType == StageConfig.StageTypeElite or StageType == StageConfig.StageTypeEliteHide then
	   self:setIsElite(true)
	else
	   self:setIsElite(false)
	end
end

function ScenarioStage:getStageType()
	return self._StageType
end

function ScenarioStage:setIsElite(IsElite)
	self._IsElite = IsElite
end

function ScenarioStage:getIsElite()
	return self._IsElite
end

function ScenarioStage:setStageChapterId(StageChapterId)
	self._StageChapterId = StageChapterId
end

function ScenarioStage:getStageChapterId()
	return self._StageChapterId
end

function ScenarioStage:setStageChapterName(StageChapterName)
	self._StageChapterName = StageChapterName
end

function ScenarioStage:getStageChapterName()
	return self._StageChapterName
end

function ScenarioStage:setPreStageId(PreStageId)
	self._PreStageId = PreStageId
end

function ScenarioStage:getPreStageId()
	return self._PreStageId
end

------
--  Getter & Setter for
--      ScenarioStage._NextStageId 
-----
function ScenarioStage:setNextStageId(NextStageId)
	self._NextStageId = NextStageId
end

function ScenarioStage:getNextStageId()
	return self._NextStageId
end

function ScenarioStage:setIsOpen(IsOpen)
	self._IsOpen = IsOpen
end

function ScenarioStage:getIsOpen()
	return self._IsOpen
end

function ScenarioStage:setIsPassed(isPassed)
  if isPassed == true then
    self:setIsOpen(true)
    self:setGrade(2)
  end
end

function ScenarioStage:getIsPassed()
   local passed = false
   if self:getIsOpen() == true and self:getGrade() == 2 then
      passed = true
   end
   return passed
end

------
--  Getter & Setter for
--      ScenarioStage._EnabledAutoNextChapter 
-----
function ScenarioStage:setEnabledAutoNextChapter(EnabledAutoNextChapter)
	self._EnabledAutoNextChapter = EnabledAutoNextChapter
end

function ScenarioStage:getEnabledAutoNextChapter()
	return self._EnabledAutoNextChapter
end

function ScenarioStage:setCost(Cost)
	self._Cost = Cost
end

function ScenarioStage:getCost()
	return self._Cost
end

function ScenarioStage:setGrade(Grade)
	self._Grade = Grade
end

function ScenarioStage:getGrade()
	return self._Grade
end

------
--  Getter & Setter for
--      ScenarioStage._Background 
-----
function ScenarioStage:setBackground(Background)
	self._Background = Background
end

function ScenarioStage:getBackground()
	return self._Background
end

------
--  Getter & Setter for
--      ScenarioStage._Progress 
-----
function ScenarioStage:setProgress(Progress)
	self._Progress = Progress
end

function ScenarioStage:getProgress()
	return self._Progress
end


return ScenarioStage