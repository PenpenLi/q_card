require("controller.BaseController")
require("view.scenario.ScenarioView")
require("view.component.TabControl")
require("model.scenario.Scenario")
require("view.scenario.component.ScenarioDialogView")
require("view.scenario.component.CardTypeIntroductionView")
 
ScenarioController = class("ScenarioController",BaseController)
function ScenarioController:ctor()
   ScenarioController.super.ctor(self)
end

function ScenarioController:enter()
  -- GameData:Instance():pushViewType(ViewType.scenario)

  ScenarioController.super.enter(self)
  self:setScene(GameData:Instance():getCurrentScene())
  self.scenario = Scenario:Instance()
  --self.scenario:registNetSever()
  self:enterScenarioView()
end

function ScenarioController:gotoStageById(stageId,showEffect,isAutoAlert)
  local stage = self.scenario:getStageById(stageId)
  assert(stage ~= nil,"invaild stage Id:"..stageId)
  local checkPoint = stage:getCheckPoint()
  if checkPoint:getState() ~= StageConfig.CheckPointStateClose  then
     
     local passedMaxGrade = checkPoint:getGrade()
     local curStage = checkPoint:getStages()[passedMaxGrade + 1]
     if stage:getDifficultyType() <= passedMaxGrade + 1 then
        curStage = checkPoint:getStages()[stage:getDifficultyType()]
     else
        Toast:showString(GameData:Instance():getCurrentScene(),_tr("stage_grade_not_open"), ccp(display.cx, display.height*0.4))
     end
     self.scenario:setCurrentStage(curStage)
     local chapter = checkPoint:getChapter()
     self.scenarioView:goToChapter(chapter,stage:getIsElite(),showEffect,isAutoAlert)
  else
     Toast:showString(GameData:Instance():getCurrentScene(),_tr("stage_not_open"), ccp(display.cx, display.height*0.4))
  end
end

function ScenarioController:gotoChapterById(stageId)
  local stage = self.scenario:getStageById(stageId)
  assert(stage ~= nil,"invaild stage Id:"..stageId)
  local checkPoint = stage:getCheckPoint()
  local chapter = checkPoint:getChapter()
  if chapter:getId() <= self.scenario:getMaxChapterId() then
    self.scenarioView:goToChapter(chapter,stage:getIsElite(),false,false)
  else
    Toast:showString(GameData:Instance():getCurrentScene(),_tr("chapter_not_open"), ccp(display.cx, display.height*0.4))
  end
  
end

function ScenarioController:gotoEliteStage()
  local eliteCheckPoint = self.scenario:getLastEliteCheckPoint()
  if eliteCheckPoint ~= nil then
     self.scenario:setCurrentStage(eliteCheckPoint:getStages()[1])
     local chapter = eliteCheckPoint:getChapter()
     self.scenarioView:goToChapter(chapter,true)
  else
     Toast:showString(GameData:Instance():getCurrentScene(),_tr("elite_stage_not_open"), ccp(display.cx, display.height*0.4))
  end
end

function ScenarioController:enterScenarioView()
  local scenarioView = ScenarioView.new(self.scenario,self)
  self.scenarioView = scenarioView
  self.scenario:setView(scenarioView)
  self:getScene():replaceView(scenarioView)
end

function ScenarioController:setCurrentStage(stage)
  self.scenario:setCurrentStage(stage)
end

function ScenarioController:goToShopCollectView()
   local shopController = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
   shopController:enter(ShopCurViewType.PAY)
end

function ScenarioController:reqQuickFight(stageId,fightCount)
  local useTicket = false
  self.scenario:reqQuickFight(stageId,fightCount)
end

function ScenarioController:reqForcibleBuyStage(stageId,money)
   if GameData:Instance():getCurrentPlayer():getMoney() >= money then
      self._stage = self.scenario:getStageById(stageId)
      self.scenario:reqForcibleBuyStage(stageId)
   else
      local pop = PopupView:createTextPopup(_tr("not enough money"), function() return end ,true)
      GameData:Instance():getCurrentScene():addChildView(pop,100)
   end
  
end

function ScenarioController:reqPVEFightCheck(stage)
   self._stage = stage
   local battleCards = GameData:Instance():getCurrentPackage():getBattleCards()
   local pop = nil
   if table.getn(battleCards) > 0 then
      local hasLeaderCard = false
      for key, card in pairs(battleCards) do
        if card:getIsBoss() == true then
           hasLeaderCard = true
           break
        end
      end
      
      if hasLeaderCard == true then
        self.scenario:reqPVEFightCheck(stage)
      else
         pop = PopupView:createTextPopup(_tr("need_leader"), function() return self:enterPlaystates()  end)
         self:getScene():addChildView(pop,100)
      end
    else
      pop = PopupView:createTextPopup(_tr("need_more_card_on_battle"), function() return self:enterPlaystates() end)
      self:getScene():addChildView(pop,100)
    end
end

function ScenarioController:startBattle(msg,stage)
    self._stage = stage
    local battleController = ControllerFactory:Instance():create(ControllerType.BATTLE_CONTROLLER)
    battleController:enter()
    battleController:startPVEBattle(msg,self._stage)
    
    if self._stage:getCheckPoint():getState() == StageConfig.CheckPointStateOpen then
       assert(AllConfig.dialogue ~= nil,"dialogue config is nil")
       if AllConfig.dialogue[self._stage:getStageId()] ~= nil and AllConfig.dialogue[self._stage:getStageId()].type == 1 then
           --disabled touch
           --battleController.view.isLocked = true
           battleController.view._startBtn:setVisible(false)
           if battleController.view._backBtn ~= nil then
              battleController.view._backBtn:setVisible(false)
           end
           
           if battleController.view._skillRangeInfo ~= nil then
              battleController.view._skillRangeInfo:setVisible(false)
           end
          
           local text = AllConfig.dialogue[self._stage:getStageId()].desc
           local resId = AllConfig.dialogue[self._stage:getStageId()].portrait_pic
           local scenarioDialog = ScenarioDialogView.new(text,resId,StageConfig.DialogueTypeStage)
           scenarioDialog:setBattleController(battleController)
           scenarioDialog:setDelegate(self)
           self:getScene():addChildView(scenarioDialog)
           return
       end
    end
    
    self:checkNewCard(battleController)
    
--    UIHelper.triggerGuide(10306,CCRectMake(0,0,0,0),emRight,nil,false)
--    UIHelper.triggerGuide(10606,CCRectMake(0,0,0,0),emRight,nil,false)
--    UIHelper.triggerGuide(10906,CCRectMake(0,0,0,0),emRight,nil,false)
--    --UIHelper.triggerGuide(11206,CCRectMake(0,0,0,0),emRight)
--      
--    -- tip move card
--    UIHelper.triggerGuide(10304,CCRectMake(68,100,120,240),emRight,nil,false)
--    UIHelper.triggerGuide(10604,CCRectMake(68,100,120,240),emRight,nil,false)
--    UIHelper.triggerGuide(10904,CCRectMake(68,100,120,240),emRight,nil,false)
--    UIHelper.triggerGuide(11204,CCRectMake(68,100,120,240),emRight,nil,false)
    
    --
--    UIHelper.triggerGuide(10306,CCRectMake(0,0,0,0),emRight)
--    UIHelper.triggerGuide(10606,CCRectMake(0,0,0,0),emRight)
--    UIHelper.triggerGuide(10906,CCRectMake(0,0,0,0),emRight)
    
end

function ScenarioController:checkNewCard(battleController)
    
    if self._stage:getCheckPoint():getState() == StageConfig.CheckPointStateOpen then
       assert(AllConfig.newcard ~= nil,"newcard config is nil")
       if AllConfig.newcard[self._stage:getStageId()] ~= nil then
          print(AllConfig.newcard[self._stage:getStageId()].path)
          local showCard = function()
               battleController:hideNewCardWith()
               local cardtypeIntro = CardTypeIntroductionView.new(self,self._stage)
               cardtypeIntro:setBattleController(battleController)
               battleController.view:addChild(cardtypeIntro,3000)
          end
          
          local long = battleController:showNewCardWithPos(AllConfig.newcard[self._stage:getStageId()].pos)
          --disabled touch
          battleController.view.isLocked = true
          battleController.view._startBtn:setVisible(false)
          if battleController.view._backBtn ~= nil then
             battleController.view._backBtn:setVisible(false)
          end
          if battleController.view._skillRangeInfo ~= nil then
             battleController.view._skillRangeInfo:setVisible(false)
          end
        
          local function performWithDelay(node, callback, delay)
            local delay = CCDelayTime:create(delay)
            local callfunc = CCCallFunc:create(callback)
            local sequence = CCSequence:createWithTwoActions(delay, callfunc)
            node:runAction(sequence)
            return sequence
          end
     
          performWithDelay(battleController.view,showCard,long)
          return
       end
    end
    
    self:triggerStageTroopIntroduction(battleController)
end

function ScenarioController:triggerStageTroopIntroduction(battleController)
     local stage = Scenario:Instance():getCurrentStage()
     local stateId = stage:getStageId()
     local currentGuideStep = nil
     if stage:getCheckPoint():getState() == StageConfig.CheckPointStateOpen then
        for key, stageStepInfo in pairs(AllConfig.stage_guide) do
        	  if stateId == stageStepInfo.type_value then
        	     currentGuideStep = Guide:Instance():getGuideStepByStepId(stageStepInfo.stepid[1])
        	     break
        	  end
        end
     end
     
     if currentGuideStep ~= nil then
          Guide:Instance():removeGuideLayer()
          local guideLayer = Guide:Instance():createGuideLayer(currentGuideStep,CCRectMake(0,0,0,0))
          Guide:Instance():setGuideLayer(guideLayer)
     else
          battleController:getBattleView():battleGuideTrggier()
     end
end

function ScenarioController:enterPlaystates()
  local playstatesController  = ControllerFactory:Instance():create(ControllerType.PLAY_STATES_CONTROLLER)
  playstatesController:enter()
end
function ScenarioController:enterQuest()
  local questController = ControllerFactory:Instance():create(ControllerType.QUEST_CONTROLLER)
  questController:enter(ControllerType.SCENARIO_CONTROLLER)
end
function ScenarioController:exit()
   ScenarioController.super.exit(self)
   --self.scenario:unRegistNetSever()
   self.scenario:setView(nil)
   printf("ScenarioController exit")
end

return ScenarioController