require("model.activity_stage.ActivityStageCheckPoint")

ActivityStages = class("ActivityStages")
function ActivityStages:ctor()
	self:updateCheckPoints()
end

function ActivityStages:Instance()
	if ActivityStages._ActivityStage == nil then
		ActivityStages._ActivityStage = ActivityStages.new()
		ActivityStages._ActivityStage:registNetSever()
	end
	return ActivityStages._ActivityStage
end

function ActivityStages:registNetSever()
	net.registMsgCallback(PbMsgId.FightErrorBS2CS,self,ActivityStages.onFightCheckResult)
	net.registMsgCallback(PbMsgId.ReqForcibleBuyActivityStageResult,self,ActivityStages.onReqForcibleBuyActivityStageResult)
end

function ActivityStages:unregistNetSever()
	net.unregistAllCallback(self)
end


function ActivityStages:updateCheckPoints()
  local lastCheckPoint = self:getCurrentCheckPoint()
	local checkPoints = {}
--%U 
--Week of year as decimal number, with Sunday as first day of week (00 – 53) 

--%w 
--Weekday as decimal number (0 – 6; Sunday is 0) 
--
--%W 
--Week of year as decimal number, with Monday as first day of week (00 – 53) 
  local currentTime = Clock:Instance():getCurServerTime()
  local weekofyear = os.date("%W", currentTime) + 1
  
	--local timeTable = Clock:Instance():getCurServerTimeAsTable()
	local timeTable = os.date("!*t", currentTime)

	print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~weekofyear:",weekofyear)
	print("sever day now: yy--mm--dd", timeTable.year,timeTable.month,timeTable.day)
	print("sever time now:currentTime hh-mm-ss:",timeTable.hour,timeTable.min,timeTable.sec)
	local stageType = weekofyear % 4
	print("stageType:",stageType)
	if stageType == 0 then
		stageType = 4
	end
	local curDate = timeTable.year * 10000 + timeTable.month * 100 + timeTable.day
  
	print("stageType:",stageType)
  
	for key, var in pairs(AllConfig.activity_stage) do
		-- init stages at this week
		if AllConfig.activity_stage[key].stage_type == stageType or AllConfig.activity_stage[key].stage_type == 0 then
			if curDate >= AllConfig.activity_stage[key].open_date and curDate < AllConfig.activity_stage[key].close_date then --关闭时间少一天
				local checkPoint = ActivityStageCheckPoint.new(key)
			checkPoints[key] = checkPoint
			end
		end
	end
	
	--restore current check point
	if lastCheckPoint ~= nil then
	   for key, checkPoint in pairs(checkPoints) do
	   	 if checkPoint:getIndex() == lastCheckPoint:getIndex() then
	   	   checkPoint:setLastSelectedDifficulty(lastCheckPoint:getLastSelectedDifficulty())
	   	   self:setCurrentCheckPoint(checkPoint)
	   	   break
	   	 end
	   end
	end
  self:setCheckPoints(nil)
	self:setCheckPoints(checkPoints)
end

------
--  Getter & Setter for
--      ActivityStages._CurrentCheckPoint 
-----
function ActivityStages:setCurrentCheckPoint(CurrentCheckPoint)
	self._CurrentCheckPoint = CurrentCheckPoint
end

function ActivityStages:getCurrentCheckPoint()
	return self._CurrentCheckPoint
end

------
--  Getter & Setter for
--      ActivityStages._LastAngle 
-----
function ActivityStages:setLastAngle(LastAngle)
	self._LastAngle = LastAngle
end

function ActivityStages:getLastAngle()
	return self._LastAngle
end

function ActivityStages:reqForcibleBuyActivityStage(activityId,stageId,rightFight)
	print("send buy count: activityId:",activityId,"stageId:",stageId)
	self._rightFight = rightFight
	self:setCurrentCheckPoint(self:getCheckPointById(activityId))
	_showLoading()
	local data = PbRegist.pack(PbMsgId.ReqForcibleBuyActivityStage,{ activity_id = activityId,stage_id = stageId })
	net.sendMessage(PbMsgId.ReqForcibleBuyActivityStage,data)
end

function ActivityStages:onReqForcibleBuyActivityStageResult(action,msgId,msg)
	print("onReqForcibleBuyActivityStageResult:",msg.result)
	_hideLoading()
	if msg.result == "success" then
		GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
		if self._rightFight == true then
		  local stage = Scenario:Instance():getStageById(msg.stage_id)
		  if GameData:Instance():getCurrentPlayer():getSpirit() < stage:getCost() then
        Common.CommonFastBuySpirit()
      else
        self:reqActivityStageFightCheck(msg.activity_id,stage)
      end
		else
			self:getActivityStageView():updateInfoShow()
		end
	elseif msg.result == "money_limit" then
		Toast:showString(GameData:Instance():getCurrentScene(),_tr("not enough money"), ccp(display.cx, display.height*0.4))
	elseif msg.result == "daily_times_limit" then
		Toast:showString(GameData:Instance():getCurrentScene(),_tr("cannot_buy_challenge_again"), ccp(display.cx, display.height*0.4))
	end
	self._rightFight = nil
end

------
--  Getter & Setter for
--      ActivityStages._CurrentStage 
-----
function ActivityStages:setCurrentStage(CurrentStage)
	self._CurrentStage = CurrentStage
end

function ActivityStages:getCurrentStage()
	return self._CurrentStage
end

function ActivityStages:reqActivityStageFightCheck(activityId,stage)
	
	if activityId ~= nil and stage ~= nil then
	 self._stage = stage
	 self._stage:setActivityId(activityId)
	 self:setCurrentCheckPoint(self:getCheckPointById(activityId))
	 self:setCurrentStage(stage)
	end
	
	echo("ActivityStages:reqActivityStageFightCheck:  activityid:",self._stage:getActivityId(),"stage_id:",self._stage:getStageId())
	local fightTypes = "PVE_ACTIVITY"
	_showLoading()
	local data = PbRegist.pack(PbMsgId.ActivityFightReqCheckCS2BS,{ map = {map = self._stage:getStageId(),level = 1,fightType = fightTypes},activity_id = self._stage:getActivityId() })
	net.sendMessage(PbMsgId.ActivityFightReqCheckCS2BS,data)
end

function ActivityStages:onFightCheckResult(action,msgId,msg)
	echo("ActivityStageCheckPoint:onFightCheckResult:",msg.error)
  _hideLoading()
	if msg.info.fightType == "PVE_ACTIVITY" then
		if msg.error == "NO_ERROR_CODE" then
			if ControllerFactory:Instance():getCurrentControllerType() ~=  ControllerType.BATTLE_CONTROLLER then
         self:getActivityStageView():getDelegate():startActivityBattle(msg,self._stage)
      else
        ControllerFactory:Instance():getCurController():startPVEActivityStageBattle(msg,self._stage)
      end
		else
		  
		end
	end
end

------
--  Getter & Setter for
--      ActivityStages._ActivityBuyCount 
-----
function ActivityStages:setActivityBuyCount(ActivityBuyCount)
	self._ActivityBuyCount = ActivityBuyCount
end

function ActivityStages:getActivityBuyCount()
	return self._ActivityBuyCount
end

function ActivityStages:getCheckPointById(id)
	return self:getCheckPoints()[id]
end

function ActivityStages:hasStageToChallenge()
	local flag, str = GameData:Instance():checkSystemOpenCondition(19, false)
	if flag == false then 
		return false,nil
	end
	
	local hasStageToChallenge = false
	local checkPointsToChallenge = {}
	for key, checkPoint in pairs(self:getCheckPoints()) do
  		if checkPoint:hasStageToChallenge() == true then
  			hasStageToChallenge = true
  			table.insert(checkPointsToChallenge,checkPoint)
  		end
	end

	return hasStageToChallenge,checkPointsToChallenge
end

------
--  Getter & Setter for
--      ActivityStages._CheckPoints 
-----
function ActivityStages:setCheckPoints(CheckPoints)
	self._CheckPoints = CheckPoints
end

function ActivityStages:getCheckPoints()
	return self._CheckPoints
end

------
--  Getter & Setter for
--      ActivityStages._ActivityStageView 
-----
function ActivityStages:setActivityStageView(ActivityStageView)
	self._ActivityStageView = ActivityStageView
end

function ActivityStages:getActivityStageView()
	return self._ActivityStageView
end

return ActivityStages