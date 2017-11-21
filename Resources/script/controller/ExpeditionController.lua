require("view.expedition.ExpeditionView")
require("model.expedition.Expedition")
require("view.Common")
require("model.expedition.ExpeditionConfig")
ExpeditionController = class("ExpeditionController",BaseController)

function ExpeditionController:ctor()
	ExpeditionController.super.ctor(self,"ExpeditionController")  
end

function ExpeditionController:enter()
  printf("enter ExpeditionView")
  ExpeditionController.super.enter(self)
  
  self.expedition = GameData:Instance():getExpeditionInstance()
  if self.expedition == nil then
     self.expedition = Expedition.new()
     self.expedition:setDelegate(self)
     GameData:Instance():setExpeditionInstance(self.expedition)
     self.expedition:reqPVPQueryDataC2S()
  end
  self.expedition:reqPVPQueryDataC2S()
  
  self.expedition:setDelegate(self)
  self.expedition:stopTimeCountDown()
  --self.expedition:destory() -- destory net
  --self.expedition:registNetSever()
  self.expeditionView = ExpeditionView.new(self,self.expedition)
  self.expeditionView:enter()
  self.expeditionView:updateView(false)
  self.expedition:reqRanks()
  
  if self:getIsChallenge() ~= nil and self:getIsChallenge() == true then
--     self.expeditionView:getTabMenu():setItemSelectedByIndex(6)
--     self.expeditionView:tabControlOnClick(5)
    self.expeditionView:onClickHomeRankList()
  end
  
  self:getScene():replaceView(self.expeditionView)

  GameData:Instance():pushViewType(ViewType.expedition)
end

function ExpeditionController:checkPvpFight(targetId,challengeType)
  if challengeType == nil then
     challengeType = ExpeditionConfig.challengeTypeNormal
  end
  
  local pop = nil
  if challengeType == ExpeditionConfig.challengeTypeNormal then
     if GameData:Instance():getCurrentPlayer():getToken() < AllConfig.battleinitdata[1].battle_cost then
			 Common.CommonFastBuyToken()
       return
     end
  elseif challengeType == ExpeditionConfig.challengeTypeRank then
     if GameData:Instance():getCurrentPlayer():getToken() < AllConfig.battleinitdata[1].challenge then
		   Common.CommonFastBuyToken()
       return
     end
  elseif challengeType == ExpeditionConfig.challengeTypeEnemy then
      if GameData:Instance():getCurrentPlayer():getToken() < AllConfig.battleinitdata[1].revenge_cost then
       Common.CommonFastBuyToken()
       return
     end
  end
   
  if GameData:Instance():getCurrentPlayer():isEnabledEnterBattle() == true then
    self.expedition:checkPVPFight(targetId,challengeType)
  end
end

function ExpeditionController:getView()
    return self.expeditionView
end

------
--  Getter & Setter for
--      ExpeditionController._IsChallenge 
-----
function ExpeditionController:setIsChallenge(IsChallenge)
	self._IsChallenge = IsChallenge
end

function ExpeditionController:getIsChallenge()
	return self._IsChallenge
end

function ExpeditionController:startPvpBattle(msg,isChallenge)
----  enum FightReqError{
----    NO_ERROR_CODE = 0;
----    CARD_NOT_FOUND= 1;
----    CARD_NOT_ACTIVE = 2;
----    CARD_EQUIP_NOT_FOUND = 3;
----    CARD_EQUIP_ERROR = 4;
----    TARGET_DATA_ERROR = 5;
----    STAGE_NOT_FOUND = 6;
----    LEVEL_NOT_ALLOW = 7;
----    PRE_STAGE_NOT_COMPLETE = 8;
----    NEED_MORE_SPIRIT = 9;
----    SYSTEM_ERROR = 10;
----    NOT_COMPLETE_STAR = 11;
----    STAGE_CLOSE = 12;
----    STAGE_TIME_CLOSE = 13;
----    STAGE_NEED_MORE_CHANCE = 14;
----    NOT_FOUND_PVP_TARGET = 15;
----    SYSTEM_LOADING_DATA = 16;
----  }
----  required FightReqError  error = 1;
----  optional FightMapInfo   info = 2;
--  
    
    self:setIsChallenge(isChallenge)
    if msg.error == "NO_ERROR_CODE" then
       echo("PVPOK")
       local battleController = ControllerFactory:Instance():create(ControllerType.BATTLE_CONTROLLER)
       battleController:enter()
       battleController:startPVPBattle(msg,isChallenge)
    else
       echo(msg.error)
    end
    
    
end

function ExpeditionController:reqAward(rankNumber)
    self.expedition:reqPVPAwardC2S(rankNumber)
end

function ExpeditionController:searchPvpTarget()
    self.expedition:reSearchPvpTarget()
end

function ExpeditionController:exit()
   
   self.expedition:stopTimeCountDown()
   self.expedition:setDelegate(nil)
   ExpeditionController.super.exit(self)
   --self.expedition:destory()
end

function ExpeditionController:goBackView()
  GameData:Instance():gotoPreView()
end

return ExpeditionController