require("controller.BaseController")  
require("view.battle.BattleView")  
require("model.battle.Battle")  
require("model.scenario.ScenarioStage")
require("view.battle.BattleTestView")  
require("view.guide.TroopIntroductionView")  

BattleController = class("BattleController",BaseController)

function BattleController:ctor()
  BattleController.super.ctor(self, "BattleController")
  echo("BattleScene:ctor")
end

function BattleController:enter(isLocalFight,isTestView,isLocalPlay)
  BattleController.super.enter(self)
  
  self:getScene():getNoticeView():setVisible(false)
  CONFIG_DEFAULT_ANIM_DELAY_RATIO = 1/1.30
  if isLocalFight == nil then
    isLocalFight = false
  end
  if isTestView == nil then
    isTestView = false
  end  
  if isTestView == true then
    self.view = BattleTestView.new()
    self.view:setDelegate(self)
    self:getScene():replaceView(self.view,true,false)
  else
    self.view = BattleView.new(isLocalFight,isLocalPlay)
    self.view:setDelegate(self)
    self:getScene():replaceView(self.view,true,false)
    
    self.battle = Battle.new(isLocalFight,isLocalPlay)
    self.battle:setBattleView(self.view)
    self:setBattle(self.battle)
    
    local function getFile(filename)
      local f = assert(io.open(filename , "rb"))
      local buffer = f:read "*a"
      f:close()
      return buffer
    end
    
    if isLocalFight == true then
      self.battle:reqBattle()
    else
      -- for test 
  --    local scenarioStage = ScenarioStage.new()
  --    scenarioStage:setStageId(101001)
  --    self.battle:reqEmbattle(scenarioStage)
    end
    
    if isLocalPlay == true then
      local stringbuffer = getFile(CCFileUtils:sharedFileUtils():fullPathForFilename("img/battle_play.dat"))
      print("stringbuffer:",stringbuffer)
      local result = PbRegist.unpackStruct("NormalBattleResult", stringbuffer)
      print("result~",result)
      if result ~= false then
         --dump(result)
         self.battle:onBattleResult(result)
      end
    end
    
  end
  
end

------
--  Getter & Setter for
--      BattleController._Battle 
-----
function BattleController:setBattle(Battle)
	self._Battle = Battle
end

function BattleController:getBattle()
	return self._Battle
end


function BattleController:getBattleView()
   return self.view
end

function BattleController:goToScenario() --PVE
    local scenarioController = ControllerFactory:Instance():create(ControllerType.SCENARIO_CONTROLLER)
    scenarioController:enter()
end

function BattleController:goToExpedition() --PVP
    local expeditionController = ControllerFactory:Instance():create(ControllerType.EXPEDITION_CONTROLLER)
    expeditionController:setIsChallenge(self._isChallenge)
    expeditionController:enter()
end

function BattleController:goToActivityStage()
    local activityController = ControllerFactory:Instance():create(ControllerType.ACTIVITY_STAGE_CONTROLLER)
    activityController:enter()
end

function BattleController:goToArena()
    local controller = ControllerFactory:Instance():create(ControllerType.ARENA_CONTROLLER)
    controller:enter()
end

function BattleController:goToActivity()
    local activityController = ControllerFactory:Instance():create(ControllerType.ACTIVITY_CONTROLLER)
    activityController:setBackToBossFightView(true)
    activityController:enter()
end

function BattleController:goToRankMatch()
    local controller = ControllerFactory:Instance():create(ControllerType.PVP_RANK_MATCH_CONTROLLER)
    controller:enter()
end

function BattleController:goToGuild()
   local controller = ControllerFactory:Instance():create(ControllerType.GUILD_CONTROLLER)
   controller:enter()
end

function BattleController:goToBable()
    local controller = ControllerFactory:Instance():create(ControllerType.BABEL_CONTROLLER)
    controller:enter()
end

function BattleController:startPVEBattle(msg,stage)
     if self.view ~= nil then
      self.view:resetToTouch()
     end
     
     if self.battle ~= nil then
       self.battle:setStage(stage)
       self.battle:prepareBattle(msg)
     end
     
end

function BattleController:showNewCardWithPos(pos)
    local anim,offsetX,offsetY,long = _res(5020155)
    anim:getAnimation():play("default")
    self.view:addChild(anim,1000)
    anim:setPosition(self.view:getPosByIndex(pos))
    self._newCardPosNode = anim
    
    return long
end

function BattleController:hideNewCardWith()
    if self._newCardPosNode ~= nil then
       self._newCardPosNode:removeFromParentAndCleanup(true)
       self._newCardPosNode = nil
    end
end

function BattleController:startReviewBattleWithResult(result)
  if self.battle ~= nil then
    self.battle:setIsPlayingReview(true)
    self.battle:onBattleResult(result)
  end
end

function BattleController:startPVPBattle(msg,isChallenge)
  if self.battle ~= nil then
    self.battle:prepareBattle(msg)
    self._isChallenge = isChallenge
  end
end

function  BattleController:startPVPRankMatch(msg)
   if self.battle ~= nil then
    self.battle:prepareBattle(msg)
  end
end

function BattleController:startArenaBattle(msg)
  if self.battle ~= nil then
    self.battle:prepareArenaBattle(msg)
  end
end

function BattleController:startPVEActivityStageBattle(msg,stage)
  if self.battle ~= nil then
    self.battle:setStage(stage)
    self.battle:prepareBattle(msg)
  end
end

function BattleController:startBossBattle(msg,boss,isQuickFight)
  if self.battle ~= nil then
    --self.battle:setBossId(boss:getId())
    self.battle:setBossFromActivity(boss)
    self.battle:prepareBattle(msg)
    if isQuickFight == true then
       --self.battle:reqBattle()
       self.view:onStartBattle(self.battle)
    end
  end
end

function BattleController:startPVEGuildBattle(msg)
  self.battle:prepareBattle(msg)
end

function BattleController:startPVEBableBattle(msg)
  self.battle:prepareBattle(msg)
end

function BattleController:startBattle()
     if self.battle ~= nil then
       if self._guideTroop ~= nil and self._guideTroop:getParent() ~= nil then
          self._guideTroop:removeFromParentAndCleanup(true)
       end
       self.battle:reqBattle()
     end
end

function BattleController:exit()
  BattleController.super.exit(self)
  self.battle:destory()
  self.battle = nil
  self.view = nil
  self:setBattle(nil)
  CONFIG_DEFAULT_ANIM_DELAY_RATIO = 1.0
  CCDirector:sharedDirector():getScheduler():setTimeScale(1.0)
   -- play bgm
  _playBgm(BGM_MAIN)
  self:getScene():getNoticeView():setVisible(true)
end

return BattleController