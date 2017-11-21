require("model.scenario.ScenarioChapter")
require("model.scenario.ScenarioStage")
require("model.scenario.StageConfig")
require("model.activity_stage.ActivityStages")
Scenario = class("Scenario")
function Scenario:ctor(scenarioData)
   self:update(scenarioData)
end

function Scenario:Instance()
  if Scenario._ScenarioInstance == nil then
     Scenario._ScenarioInstance = Scenario.new()
     Scenario._ScenarioInstance:registNetSever()
  end
  return Scenario._ScenarioInstance
end

function Scenario:init()
   self:initStages()
   self:initChapters()
end

function Scenario:initStages()
   --reset
   self:setAllStages(nil)

   local stageConfigs = AllConfig.stage
   assert(stageConfigs ~= nil,"StageConfig Error")
   local allStages = {}
   -- init stages
   for stageConfigId, stage in pairs(stageConfigs) do
   	   allStages[stageConfigId] = ScenarioStage.new()
   	   allStages[stageConfigId]:setStageId(stageConfigId)
   end
   
   -- init stages's pre stages
   for stageConfigId, stage in pairs(stageConfigs) do
       --echo(stageConfigId,"preStage:",allStages[allStages[stageConfigId]:getPreStageId()])
       allStages[stageConfigId]:setPreStage(allStages[allStages[stageConfigId]:getPreStageId()])
   end
   --self:setCurrentStage(allStages[1010011])
   self:setAllStages(allStages)
end

function Scenario:initChapters()
    --reset
    self:setAllChapters(nil)
    
    local chapterConfigs = AllConfig.chapter
    assert(chapterConfigs ~= nil,"ChapterConfig Error")
    local chapters = {}
    local chapter = nil
    for key, m_chapterConfig in pairs(chapterConfigs) do
    	  chapters[key] = ScenarioChapter.new(self,key)
    	  --echo("key",key)
    end
    self:setAllChapters(chapters)
    self:setMaxChapterId(1)
    --self:setCurrentChapter(self:getAllChapters()[1])
end

------
--  Getter & Setter for
--      Scenario._AllStages 
-----
function Scenario:setAllStages(AllStages)
	self._AllStages = AllStages
end

function Scenario:getAllStages()
	return self._AllStages
end

------
--  Getter & Setter for
--      Scenario._AllChapters 
-----
function Scenario:setAllChapters(AllChapters)
	self._AllChapters = AllChapters
end

function Scenario:getAllChapters()
	return self._AllChapters
end


function Scenario:getChapterCountByChapterType(chapterType)
  local count = 0
  local chapters = {}
  for key, chapter in pairs(self:getAllChapters()) do
  	if chapter:getChapterType() == chapterType then
  	 count = count + 1
  	 table.insert(chapters,chapter)
  	end
  end
	return count,chapters
end

--  count of geted stars 
function Scenario:getPassedStageStars()
	local startCount = 0
	for key, stage in pairs(self:getAllStages()) do
		  if stage:getIsPassed() == true then
		     startCount = startCount + 1
		  end
	end
	return startCount
end

------
--  Getter & Setter for
--      Scenario._BuyStageCount 
-----
function Scenario:setBuyStageCount(BuyStageCount)
	self._BuyStageCount = BuyStageCount
end

function Scenario:getBuyStageCount()
	return self._BuyStageCount
end

------
--  Getter & Setter for
--      Scenario._QuickFightCount 
-----
function Scenario:setQuickFightCount(QuickFightCount)
	self._QuickFightCount = QuickFightCount
end

function Scenario:getQuickFightCount()
	return self._QuickFightCount
end

function Scenario:getVipFreeQuickFightCount()
  local vipLevelId = GameData:Instance():getCurrentPlayer():getVipLevelId()
  assert(AllConfig.vipinitdata[vipLevelId] ~= nil,"VipInitData Error")
  local freeMaxCountToday = AllConfig.vipinitdata[vipLevelId].quick_stage
  local freeCountToday = 0
  if Scenario:Instance():getQuickFightCount() < freeMaxCountToday then
     freeCountToday = freeMaxCountToday - Scenario:Instance():getQuickFightCount()
  end
  return freeCountToday
end


function Scenario:getMaxQuickFightCountToday(stage)
	local maxCount = 0
  local stageCost = stage:getCost()
  
  local freeCountToday = self:getVipFreeQuickFightCount()
  maxCount = maxCount + freeCountToday
  
  local hookTickets = GameData:Instance():getCurrentPackage():getPropsByConfigId(StageConfig.HookTicketConfigId)
  local ticketCount = 0
  if hookTickets ~= nil then
    ticketCount = hookTickets:getCount()
  end
  maxCount = maxCount + ticketCount
  
  local currentSpirit = GameData:Instance():getCurrentPlayer():getSpirit()
  local spiritCount = math.floor(currentSpirit/stageCost)
  
  maxCount = math.min(maxCount,spiritCount)

  return maxCount
end

function Scenario:getChapterById(chapterId)
  return self:getAllChapters()[chapterId]
end

function Scenario:getStageById(stageId)
  return self:getAllStages()[stageId]
end

function Scenario:checkHasAwardOnChapter(chapterId)
  local starRanks = {}
  for key, chapterAward in pairs(AllConfig.chapter_award) do
    if chapterAward.chapter == chapterId then
     table.insert(starRanks,chapterAward)
    end
  end
  
  local chapter = self:getChapterById(chapterId)
  local passedCount = 0
  local maxCount = 0
  for key, checkPoint in pairs(chapter:getNormalCheckPoints()) do
    for key, stage in pairs(checkPoint:getStages()) do
      if stage:getStageType() == StageConfig.StageTypeNormal then
        if stage:getIsPassed() == true then
          passedCount = passedCount + 1
        end
        maxCount = maxCount + 1
      end
    end
  end
  
  local hasAwardToGet = false
  
  --local chapterAwards = GameData:Instance():getCurrentPlayer():getGetedAwardsByAwardType(AwardType.CHEPTER_AWARD)
  local chapterAwards = GameData:Instance():getCurrentPlayer():getAllGetedAwards().chepter
  for key, award in pairs(starRanks) do
    if passedCount >= award.star then
      local geted = false
      for key, m_award in pairs(chapterAwards) do
        if m_award.id == award.id then
          geted = true
          break
        end
      end
      
      if geted == false then
        hasAwardToGet = true
        break
      end
      
    end
  end
  
  return hasAwardToGet
  
end

function Scenario:registNetSever()
    net.registMsgCallback(PbMsgId.FightErrorBS2CS,self,Scenario.onFightCheckResult)
    net.registMsgCallback(PbMsgId.QuickFightInstanceResultS2C,self,Scenario.onQuickFightInstanceResultS2C)
    net.registMsgCallback(PbMsgId.ReqForcibleBuyStageResult,self,Scenario.onReqForcibleBuyStageResult)
    
end

function Scenario:unRegistNetSever()
    net.unregistAllCallback(self)
end

function Scenario:reqForcibleBuyMultiStages(stages)
  assert(#stages > 0)
  self._stagesToBuy = stages
  self:reqForcibleBuyStage(stages,false)
end

function Scenario:onForcibleBuyMultiStagesResult()
  local stageView = self:getView()
  if stageView ~= nil then
    stageView:updateView()
    if stageView:getPopQuickFightView() == nil then
      stageView:alertHookEliteChapter(self:getChapterById(self._stagesToBuy[1]:getStageChapterId()))
    end
  end
end

function Scenario:reqForcibleBuyStage(stages,isSigleBuy)
    assert(#stages >= 1)
    self._isSigleBuy = isSigleBuy
    if isSigleBuy == nil then
      self._isSigleBuy = true
    end
    local stageIds = {}
    for key, stage in pairs(stages) do
    	table.insert(stageIds,stage:getStageId())
    end
    _showLoading()
    local data = PbRegist.pack(PbMsgId.ReqForcibleBuyStage,{ stage_id = stageIds })
    net.sendMessage(PbMsgId.ReqForcibleBuyStage,data)
end

--function Scenario:reqForcibleBuyStage(stageId,isSigleBuy)
--    self._isSigleBuy = isSigleBuy
--    if isSigleBuy == nil then
--      self._isSigleBuy = true
--    end
--    local data = PbRegist.pack(PbMsgId.ReqForcibleBuyStage,{ stage_id = stageId })
--    net.sendMessage(PbMsgId.ReqForcibleBuyStage,data)
--end

function Scenario:onReqForcibleBuyStageResult(action,msgId,msg)
-- enum eresult{
--  success = 1;
--  money_limit = 2;
--  daily_times_limit = 3;
-- }
-- required int32 stage_id = 1;
-- required eresult result = 2;
-- optional ClientSync client_sync = 3;
    print("onReqForcibleBuyStageResult:",msg.result)
    _hideLoading()
    if msg.result == "success" then
       GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
       if self._isSigleBuy == true then
          self:reqPVEFightCheck(self:getStageById(msg.stage_id[1]))
       else
          Toast:showString(GameData:Instance():getCurrentScene(),_tr("buy_success"), ccp(display.cx, display.cy))
       end
    elseif msg.result == "money_limit" then
       Toast:showString(GameData:Instance():getCurrentScene(),_tr("not enough money"), ccp(display.cx, display.cy))
    elseif msg.result == "daily_times_limit" then
       Toast:showString(GameData:Instance():getCurrentScene(),_tr("cannot_buy_challenge_again"), ccp(display.cx, display.cy))
    end
    
    if self._isSigleBuy == false then
      self:onForcibleBuyMultiStagesResult()
    end
    
end

function Scenario:getEliteStagesToHookByChapter(chapter)
  local stages = {}
  for key, checkPoint in pairs(chapter:getEliteCheckPoints()) do
    for key, stage in pairs(checkPoint:getStages()) do
      if stage:getLeftTimesToday() > 0 and stage:getIsPassed() == true then
         for i = 1, stage:getLeftTimesToday() do
           table.insert(stages,stage)
         end
      end
    end
  end
  return stages
end

function Scenario:getEliteStagesToBuyByChapter(chapter)
  local stages = {}
  for key, checkPoint in pairs(chapter:getEliteCheckPoints()) do
    for key, stage in pairs(checkPoint:getStages()) do
      if stage:getIsCanBuyToday() == true and stage:getIsPassed() == true then
        table.insert(stages,stage)
      end
    end
  end
  return stages
end

function Scenario:reqQuickFight(stage,fightCount)
   self:checkStageAutoNextChapterEnabled(stage)
   self:setCurrentStage(stage)
   --self:setCurrentChapter(self:getAllChapters()[stage:getStageChapterId()])
   print("reqQuickFight: stageId:",stage:getStageId(),"count:",fightCount)
   
   local data = PbRegist.pack(PbMsgId.QuickFightInstanceC2S,{ instance = stage:getStageId() ,count = fightCount,item_id = StageConfig.HookTicketConfigId })
   net.sendMessage(PbMsgId.QuickFightInstanceC2S,data)
end

function Scenario:onQuickFightInstanceResultS2C(action,msgId,msg)
    echo("onQuickFightInstanceResultS2C:",msg.error)
    if msg.error == "NO_ERROR_CODE" then
       echo("Drop:",table.getn(msg.client))
       for key, clientSync in pairs(msg.client) do
          self:parseClientSync(clientSync)
          if self:getView() ~= nil and self:getView():getPopQuickFightView() ~= nil then
            self:getView():getPopQuickFightView():onhookOnceResult(clientSync)
          end
          GameData:Instance():getCurrentPackage():parseClientSyncMsg(clientSync)
       end
       --self:getView():updateTaskTips()
    elseif msg.error == "QUICK_ITEM_LIMIT" then
       self:getView():getPopQuickFightView():reset()
       Toast:showString(GameData:Instance():getCurrentScene(),_tr("not_enough_hook_ticket"), ccp(display.cx, display.cy))
    end
end

--------
----  Getter & Setter for
----      Scenario._LastEliteStage 
-------
--function Scenario:setLastEliteStage(LastEliteStage)
--	self._LastEliteStage = LastEliteStage
--end

function Scenario:getLastEliteCheckPoint()
  local lastElitePoint = nil
  for key, chapter in pairs(self:getAllChapters()) do
      if chapter:checkEliteOpend() == true then
          for key, checkPoint in pairs(chapter:getEliteCheckPoints()) do
          	 if  checkPoint:getStageType() == StageConfig.StageTypeElite 
          	 and checkPoint:getState()     ~= StageConfig.CheckPointStateClose
          	 then
          	    lastElitePoint = checkPoint
          	 end
          end
       end
  end
  if lastElitePoint ~= nil then
     print("has last elite:",lastElitePoint:getChapter():getId())
  else
     print("has not last elite")
  end
  return lastElitePoint
end

function Scenario:checkStageAutoNextChapterEnabled(stage)
   local totalNormalCheckPointCount = #stage:getCheckPoint():getChapter():getNormalCheckPoints()
   local isLastestNormalStage = false
   
   local lastNormalCheckPoint = nil 
   for key, m_checkPoint in pairs(stage:getCheckPoint():getChapter():getNormalCheckPoints()) do
     if m_checkPoint:getStageType() == StageConfig.StageTypeNormal then
       lastNormalCheckPoint = m_checkPoint
       print(m_checkPoint:getStageType(),m_checkPoint:getIndex())
     end
   end
 
   local lastCheckPointStages = lastNormalCheckPoint:getStages()
   local lastNormalStage = lastCheckPointStages[1] --the last normal check point first diffuculty stage
   isLastestNormalStage = (lastNormalStage:getStageId() == stage:getStageId())
   local enabled = (stage:getIsPassed() == false and isLastestNormalStage == true)
   stage:setEnabledAutoNextChapter(enabled)
   return enabled
   
   --[[local enabled = false
   local expectedStageId = AllConfig.chapter[stage:getCheckPoint():getChapter():getId()].auto_next_chapter
   if expectedStageId <= 0 then
    stage:setEnabledAutoNextChapter(enabled)
    return enabled
   end
   
   local expectedStage = self:getStageById(expectedStageId)
   assert(expectedStage ~= nil,"auto_next_chapter error")
   assert(expectedStage:getCheckPoint():getStageType() == StageConfig.StageTypeNormal or expectedStage:getCheckPoint():getStageType() == StageConfig.StageTypeNormalHide,"auto_next_chapter stage type must be "..StageConfig.StageTypeNormal)
   enabled = (stage:getIsPassed() == false and stage:getStageId() == expectedStageId)
   stage:setEnabledAutoNextChapter(enabled)
   return enabled]]
end

function Scenario:reqPVEFightCheck(stage)
  echo("Scenario:reqPVEFightCheck")
  self._stage = stage
  self:checkStageAutoNextChapterEnabled(stage)
  self:setCurrentStage(stage)
  --self:setCurrentChapter(self:getAllChapters()[stage:getStageChapterId()])
  _showLoading()
  local fightTypes = "PVE_NORMAL"
  local data = PbRegist.pack(PbMsgId.FightReqCheckCS2BS,{ map = {map = stage:getStageId(),level = 1 ,fightType = fightTypes} })
  net.sendMessage(PbMsgId.FightReqCheckCS2BS,data)
end

function Scenario:onFightCheckResult(action,msgId,msg)
   echo("Scenario:onFightCheckResult:",msg.error)
   _hideLoading()
   if msg.error == "NO_ERROR_CODE" and msg.info.fightType == "PVE_NORMAL" then
      if ControllerFactory:Instance():getCurrentControllerType() ~=  ControllerType.BATTLE_CONTROLLER then
--         local battleController = ControllerFactory:Instance():create(ControllerType.BATTLE_CONTROLLER)
--         battleController:enter()
--         battleController:startPVEBattle(msg,self._stage)
         if self:getView() ~= nil then
           self:getView():getDelegate():startBattle(msg,self._stage)
         end
      else
        ControllerFactory:Instance():getCurController():startPVEBattle(msg,self._stage)
      end
  
     
   --elseif msg.error == "STAGE_NEED_MORE_CHANCE" then
   else
      --echo(msg.error)
      --Toast:showString(GameData:Instance():getCurrentScene(),msg.error, ccp(display.cx, 200))
   end
end

function Scenario:setView(View)
	self._View = View
end

function Scenario:getView()
	return self._View
end

function Scenario:update(scenarioData)
  self:init()
  if scenarioData == nil then
      return
  end
  
  local function sortLevelNameAsc(a, b)
    return a.stage < b.stage
  end
  table.sort(scenarioData, sortLevelNameAsc)

  local stageLast = nil
  for key, scenarioStageData in pairs(scenarioData) do
  	 local stage = self:getAllStages()[scenarioStageData.stage]
  	 if stage == nil then
  	    stage = ScenarioStage.new(scenarioStageData)
  	    self:getAllStages()[scenarioStageData.stage] = stage
  	 else
  	    stage:setInstanceData(scenarioStageData)
  	 end
  	 
  	 if stage:getIsElite() == false 
  	 and stage:getStageType() ~= StageConfig.StageActivity 
  	 and stage:getStageType() ~= StageConfig.StageTypeGuild 
  	 then
  	    stageLast = stage
  	 end
  end
  self:setCurrentStage(stageLast)
end

function Scenario:isStageCanFightNow(stage)
  local canBuy = stage:getIsCanBuyToday()
  local pop = nil
  local canFight = false
  if stage:getLeftTimesToday() == 0 then
     if stage:getPermitBuy() == false then
        pop = PopupView:createTextPopup(_tr("challenge_times_used_out"), function() return end,true)
        GameData:Instance():getCurrentScene():addChildView(pop)
        return canFight
     elseif stage:getPermitBuy() == true then
        if canBuy == true then
            local forcibleCount = stage:getBoughtCountToday()
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
            
            if needMoney <= 0 then
               return 
            end
           pop = PopupView:createTextPopup(_tr("challenge_used_out_buy?_%{count}", {count = needMoney}), 
              function()
                if GameData:Instance():getCurrentPlayer():getMoney() >= needMoney then
                  self:reqForcibleBuyStage({stage})
                else
                  local pop = PopupView:createTextPopup(_tr("not enough money"), function() return end ,true)
                  GameData:Instance():getCurrentScene():addChildView(pop,100)
                end
              end)
           GameData:Instance():getCurrentScene():addChildView(pop)
           return canFight
        else
           local pop = PopupView:createTextPopupWithPath(
            {leftNorBtn = "goumai.png",
             leftSelBtn = "goumai1.png",
             text = _tr("add_buy_counts_after_vip_up"),
             leftCallBack = function()
             -- self:showView(ShopCurViewType.PAY)
             GameData:Instance():getCurrentScene():getDisplayContainer():removeAllChildrenWithCleanup(true)
             local shopController = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
             shopController:enter()
             shopController:gotoVipPrivilegeView()
           end}) 
            
           GameData:Instance():getCurrentScene():addChildView(pop)
           return canFight
        end
     end
  end
  
  echo("_selectStage:",stage:getStageId())
  if GameData:Instance():getCurrentPlayer():getSpirit() < stage:getCost() then
     Common.CommonFastBuySpirit()
     return false
  end
  
  canFight = true
  return canFight
end

------
--  Getter & Setter for
--      Scenario._MaxChapterId 
-----
function Scenario:setMaxChapterId(MaxChapterId)
	self._MaxChapterId = MaxChapterId
end

function Scenario:getMaxChapterId()
	return self._MaxChapterId
end

------
--  Getter & Setter for
--      Scenario._CurrentChapter 
-----
function Scenario:setCurrentChapter(CurrentChapter)
	self._CurrentChapter = CurrentChapter
	if CurrentChapter:getId() > self:getMaxChapterId() then
	   self:setMaxChapterId(CurrentChapter:getId())
	end
	
end

function Scenario:getCurrentChapter()
	return self._CurrentChapter
end

------
--  Getter & Setter for
--      Scenario._UnPassedLastStage 
-----
function Scenario:setUnPassedLastStage(UnPassedLastStage)
	self._UnPassedLastStage = UnPassedLastStage
end

function Scenario:getUnPassedLastStage()
	return self._UnPassedLastStage
end

------
--  Getter & Setter for
--      Scenario._CurrentStage 
-----
function Scenario:setCurrentStage(CurrentStage)
   
	self._CurrentStage = CurrentStage
	self:setUnPassedLastStage(CurrentStage)
	--echo("self._CurrentStage:",CurrentStage:getStageChapterId())
	 local stageLast = CurrentStage
	 if stageLast == nil then
	    stageLast = self:getAllStages()[1010011]
	    self:setCurrentStage(stageLast)
	    return
	 end
	 
	 if stageLast ~= nil 
--	 and stageLast:getStageType() ~= StageConfig.StageActivity
--   and stageLast:getStageType() ~= StageConfig.StageTypeGuild
   then
     if stageLast:getStageType() == StageConfig.StageTypeNormalHide or stageLast:getStageType() == StageConfig.StageTypeEliteHide then
        --self:setCurrentChapter(self:getAllChapters()[stageLast:getStageChapterId()+1])
        if stageLast:getEnabledAutoNextChapter() == true then
           local chapterId = stageLast:getStageChapterId() + 1
           if chapterId > self:getChapterCountByChapterType(StageConfig.ChapterTypeScenario) then
              chapterId = self:getChapterCountByChapterType(StageConfig.ChapterTypeScenario)
           end
           self:setCurrentChapter(self:getAllChapters()[chapterId])
        else
           self:setCurrentChapter(self:getAllChapters()[stageLast:getStageChapterId()])
        end
     else
        
        if stageLast:getStageChapterId() == 1 then
           if stageLast:getStageId() == 1010071 then
              if stageLast:getEnabledAutoNextChapter() == true then
                 local chapterId = stageLast:getStageChapterId() + 1
                 if chapterId > self:getChapterCountByChapterType(StageConfig.ChapterTypeScenario) then
                    chapterId = self:getChapterCountByChapterType(StageConfig.ChapterTypeScenario)
                 end
                 self:setCurrentChapter(self:getAllChapters()[chapterId])
              else
                 self:setCurrentChapter(self:getAllChapters()[stageLast:getStageChapterId()])
              end
              return
           end
        end
        
        local checkPoint = self:getAllChapters()[stageLast:getStageChapterId()]:getNewestCheckPointByIsElite(stageLast:getIsElite())
        if  checkPoint:getIndex() >= 10 then
            if checkPoint:getState() == StageConfig.CheckPointStateInProgress or checkPoint:getState() == StageConfig.CheckPointStateFinished then
               
               local currentChapter = self:getAllChapters()[stageLast:getStageChapterId()+1]
               if currentChapter ~= nil and stageLast:getEnabledAutoNextChapter() == true then
                  currentChapter = self:getAllChapters()[stageLast:getStageChapterId()+1]
               else
                  currentChapter = self:getAllChapters()[stageLast:getStageChapterId()]
               end
               
               if currentChapter == nil then
                  currentChapter = self:getAllChapters()[stageLast:getStageChapterId()]
               end
               self:setCurrentChapter(currentChapter)
               return
            end
        end
        
        self:setCurrentChapter(self:getAllChapters()[stageLast:getStageChapterId()])
     end
  end
  
end

function Scenario:getLastNormalStage()
	return self:getCurrentChapter():getNewestCheckPointByIsElite(false):getStages()[1]
end

function Scenario:getCurrentStage()
	return self._CurrentStage
end

function Scenario:parseClientSync(clientSync)
   echo("------parseClientSync")
   if clientSync.instance ~= nil then 
    local stage = nil
    for k,val in pairs(clientSync.instance) do 
      echo("instance: action=", val.action, val.object,val.object.stage)
      if val.action == "Add" then 
           stage = self._AllStages[val.object.stage]
           if stage == nil then
              stage = ScenarioStage.new(val.object)
              self._AllStages[val.object.stage] = stage
           else
              stage:setInstanceData(val.object)
           end
           
           print("val.objec.last_enter_time:",val.object.last_enter_time)
          -- assert(false)
           if stage:getStageType() ~= StageConfig.StageActivity and  
           stage:getStageType() ~= StageConfig.StageTypeGuild then
              self:setCurrentStage(stage)
           end    
           --self:setCurrentChapter(self:getAllChapters()[stage:getStageChapterId()])
      elseif val.action == "Remove" then 
           
      elseif val.action == "Update" then
           stage = self._AllStages[val.object.stage]
           if stage == nil then
              stage = ScenarioStage.new(val.object)
              self._AllStages[val.object.stage] = stage
           else
              stage:setInstanceData(val.object)
           end
           
           print("val.objec.last_enter_time:",val.object.last_enter_time)
           
           --assert(false)
           if stage:getStageType() ~= StageConfig.StageActivity
           and stage:getStageType() ~= StageConfig.StageTypeGuild
           then
              self:setCurrentStage(stage)
           end
      end
    end
  end
end

return Scenario