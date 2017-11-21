require("view.component.ProgressBarView")
require("view.player_info.PlayerInfoView")
GameTopBlock = class("GameTopBlock",BaseView)
GameTopBlock.enabledOpenPlayerInfo = true
function GameTopBlock:ctor()
  GameTopBlock.super.ctor(self)

  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("containerMessage","CCNode")
  pkg:addProperty("containerPortrait","CCNode")
  pkg:addProperty("progressBarCon","CCNode")
  pkg:addProperty("containerPlayerInfo","CCNode")
  pkg:addProperty("containerPortrait","CCSprite")
  pkg:addProperty("spriteTalentIcon","CCSprite")
  pkg:addProperty("spriteTiLi","CCSprite")
  pkg:addProperty("spriteVipIcon","CCSprite")
  pkg:addProperty("containerSize","CCNode")
  pkg:addProperty("lableNickName","CCLabelTTF")
  pkg:addProperty("levelLable","CCLabelTTF")
  pkg:addProperty("moneyLable","CCLabelTTF")
  pkg:addProperty("coinLable","CCLabelTTF")
  pkg:addProperty("loyaltyLable","CCLabelTTF")
  
  pkg:addProperty("labelJinNang","CCLabelTTF")
  pkg:addProperty("labelMinxin","CCLabelTTF")
  pkg:addProperty("labelSoul","CCLabelTTF")
    
  pkg:addProperty("nodeJinNang","CCNode")
  pkg:addProperty("nodeTongQian","CCNode")
  pkg:addProperty("nodeYuanBao","CCNode")
  pkg:addProperty("nodeLingPai","CCNode")
  pkg:addProperty("nodeMinXin","CCNode")
  
  pkg:addProperty("nodeAllCon","CCNode")
  pkg:addProperty("nodeSoul","CCNode")

  pkg:addFunc("enterPlayerInfoHandler",GameTopBlock.enterPlayerInfoHandler)
  pkg:addFunc("goToPayHandler",GameTopBlock.goToPayHandler)
  
  
  --assert(false,"ASSETR MMM")
 
  local layer,owner = ccbHelper.load("GameTopBlockNode.ccbi","GameTopBlockCCB","CCNode",pkg)
  self:addChild(layer)
  
  self.progressBarCon:setPosition(ccp(-300,-42))
  self.spriteTalentIcon:setPositionX(self.spriteTalentIcon:getPositionX() - 30)
  --net.registMsgCallback(PbMsgId.ChangeAvatarResult,self,GameTopBlock.onChangeAvatarResult)
  
  --init scroll label to show coin/money
  local fontName = "Courier-Bold"
  local fontsize = self.coinLable:getFontSize()
  local color = self.coinLable:getColor()
  self.coinLable:setString("")
  self.scrollCoin = ScrollNumberl:createScrollLabel(fontName, fontsize, color, 9)
  self.scrollCoin:setPosition(ccp(self.coinLable:getPosition()))
  self.coinLable:getParent():addChild(self.scrollCoin)

  self.moneyLable:setString("")
--  self.scrollMoney = ScrollNumberl:createScrollLabel(fontName, fontsize, color, 9)
--  self.scrollMoney:setPosition(ccp(self.moneyLable:getPosition()))
--  self.moneyLable:getParent():addChild(self.scrollMoney) 

   
   -- create spirit progress bar
   local bg = CCSprite:createWithSpriteFrameName("progress_bg.png")
   local fg1 = CCSprite:createWithSpriteFrameName("progress_green.png")     
   self.progressBarSpirit = ProgressBarView.new(bg, fg1)
   self.progressBarSpirit:setAnchorPoint(ccp(0,0))
   self.progressBarCon:addChild(self.progressBarSpirit)
   self.progressBarSpirit:setLabelEnabled(true)
   
   --create talent progress bar
   local m_bg = CCSprite:createWithSpriteFrameName("progress_bg.png")
   local m_fg1 = CCSprite:createWithSpriteFrameName("progress_green.png")     
   self.progressBarTalent = ProgressBarView.new(m_bg, m_fg1)
   self.progressBarTalent:setAnchorPoint(ccp(0,0))
   self.progressBarCon:addChild(self.progressBarTalent)
   self.progressBarTalent:setType("talent")
   self.progressBarTalent:setPercent(0)
   self.progressBarTalent:setLabelEnabled(true)
   self._currentViewPosX = 0
   
   -- init avatar
   --self:setAvatar(0)

end
function GameTopBlock:onEnter()
  CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self,function() self:updateTopBar() end,EventType.PLAYER_UPDATE)
  --CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self,function()
	--echo("GameTopBlock EventType.TALENT_BANK")
	--self:updateTopBar()
  --end,EventType.TALENT_BANK)

  	Talent.Instance().SetEvent("TALENT_BANK_CHANGED",function()
		local mPlayer = GameData:Instance():getCurrentPlayer()
		local talentPoint = mPlayer:getTalentBankPoints()
		local talentMaxPoint = mPlayer:getTalentBankMaxPoint()
		local percent = (talentPoint/talentMaxPoint)*100
		self.progressBarTalent:setPercent(percent)
	end,self)

end
function GameTopBlock:onExit()
	--CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(self, EventType.TALENT_BANK)
	CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(self, EventType.PLAYER_UPDATE)
	Talent.Instance().SetEvent("TALENT_BANK_CHANGED",nil,self)
end
--ControllerType = enum({ "NONE","REGIST_CONTROLLER","HOME_CONTROLLER",
--"LEVELUP_CONTROLLER","MAIN_STAGE_CONTROLLER","BATTLE_CONTROLLER",
--"PLAY_STATES_CONTROLLER","SHOP_CONTROLLER","SCENARIO_CONTROLLER",
--"CREATE_PLAYER_NAME_CONTROLLER","EXPEDITION_CONTROLLER", 
--"BAG_CONTROLLER", "CARDBAG_CONTROLLER","FRIEND_CONTROLLER",
--"QUEST_CONTROLLER","CARD_ILLUSTRATED_CONTROLLER", "ACTIVITY_CONTROLLER",
--"MAIL_CONTROLLER","SYSTEM_CONTROLLER","MINING_CONTROLLER","ACHIEVEMENT_CONTROLLER",
--"LOTTERY_CONTROLLER"})

function GameTopBlock:updateInfo()
  local mPlayer = GameData:Instance():getCurrentPlayer()
    if mPlayer ~= nil then
      self.lableNickName:setString(mPlayer:getName())
      self.levelLable:setString(string.format("%d", mPlayer:getLevel()))      
      self.loyaltyLable:setString(string.format("%d", mPlayer:getToken()).."/"..mPlayer:getMaxToken()) --AllConfig.characterinitdata[15].data)

      -- self.coinLable:setString(string.format("%d", mPlayer:getCoin()))
      self.moneyLable:setString(string.format("%d", mPlayer:getMoney()))
      self.scrollCoin:setNumberExt(mPlayer:getCoin(), _tr("wan"))
      --self.scrollMoney:setNumberExt(mPlayer:getMoney(), "万")
     
      self.labelMinxin:setString(mPlayer:getLoyalty().."")
      
      local percent = 0
      local spirit = mPlayer:getSpirit()
      local maxSpirit = mPlayer:getMaxSpirit() --AllConfig.characterinitdata[4].data
      percent = (spirit/maxSpirit)*100
      self.progressBarSpirit:setPercent(percent)
      
      if mPlayer:isTalentInited() then
        local talentPoint = mPlayer:getTalentBankPoints()
        local talentMaxPoint = mPlayer:getTalentBankMaxPoint()
        local percent = (talentPoint/talentMaxPoint)*100
        self.progressBarTalent:setPercent(percent)
      end
      self.labelSoul:setString(string.format("%d", mPlayer:getCardSoul()))
    end
end

function GameTopBlock:goToPayHandler()
  if ControllerFactory:Instance():getCurrentControllerType() ~= ControllerType.SHOP_CONTROLLER then
     local shopController = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
     shopController:enter(ShopCurViewType.PAY)
  end
end

function GameTopBlock:updateTopBar()
      self.nodeJinNang:setVisible(false)
      self.nodeTongQian:setVisible(false)
      self.nodeYuanBao:setVisible(false)
      self.nodeLingPai:setVisible(false)
      self.nodeMinXin:setVisible(false)
      
      self.spriteTiLi:setVisible(false)
      self.spriteTalentIcon:setVisible(false)
      self.progressBarCon:setVisible(false)
      self.nodeSoul:setVisible(false)

      self:updateInfo()
      
      if GameData:Instance():getCurrentPackage() ~= nil then
        local costItemId  = AllConfig.guidebonus[1].item_id
        local costItemNum = GameData:Instance():getCurrentPackage():getPropsNumByConfigId(costItemId)
        if  costItemNum ~= nil then
          self.labelJinNang:setString(costItemNum.."")
        end
      end
      
      local ShowType = 1
      
      if ControllerFactory:Instance():getCurrentControllerType() == ControllerType.BAG_CONTROLLER then
         ShowType = 1
      elseif ControllerFactory:Instance():getCurrentControllerType() == ControllerType.LEVELUP_CONTROLLER
      or ControllerFactory:Instance():getCurrentControllerType() == ControllerType.MAIL_CONTROLLER
      or ControllerFactory:Instance():getCurrentControllerType() == ControllerType.CARD_ILLUSTRATED_CONTROLLER
      or ControllerFactory:Instance():getCurrentControllerType() == ControllerType.QUEST_CONTROLLER
      or ControllerFactory:Instance():getCurrentControllerType() == ControllerType.ACTIVITY_CONTROLLER
      or ControllerFactory:Instance():getCurrentControllerType() == ControllerType.FRIEND_CONTROLLER
      or ControllerFactory:Instance():getCurrentControllerType() == ControllerType.CARDBAG_CONTROLLER
      or ControllerFactory:Instance():getCurrentControllerType() == ControllerType.SYSTEM_CONTROLLER
      or ControllerFactory:Instance():getCurrentControllerType() == ControllerType.SCENARIO_CONTROLLER then
         ShowType = 2
      elseif ControllerFactory:Instance():getCurrentControllerType() == ControllerType.SHOP_CONTROLLER
      or ControllerFactory:Instance():getCurrentControllerType() == ControllerType. LOTTERY_CONTROLLER then
         ShowType = 3
      elseif ControllerFactory:Instance():getCurrentControllerType() == ControllerType.MINING_CONTROLLER then
         ShowType = 4
      elseif ControllerFactory:Instance():getCurrentControllerType() == ControllerType.EXPEDITION_CONTROLLER then
         ShowType = 5
      elseif ControllerFactory:Instance():getCurrentControllerType() == ControllerType.CARD_SOUL_CONTROLLER then
        ShowType = 6 
      end
      
      if ShowType == 1 then
         self.nodeAllCon:setPosition(ccp(0,0))
         self.nodeTongQian:setVisible(true)
         self.nodeYuanBao:setVisible(true)
         self.nodeLingPai:setVisible(true)
         self.progressBarCon:setVisible(true)
         self.spriteTalentIcon:setVisible(false)
         self.spriteTiLi:setVisible(true)
         self.progressBarSpirit:setVisible(true)
         self.progressBarTalent:setVisible(false)
      elseif ShowType == 2 then
         self.nodeAllCon:setPosition(ccp(-100,0))
         self.nodeTongQian:setVisible(true)
         self.nodeYuanBao:setVisible(true)

         self.progressBarCon:setVisible(true)
         self.spriteTalentIcon:setVisible(false)
         self.spriteTiLi:setVisible(true)
         self.progressBarSpirit:setVisible(true)
         self.progressBarTalent:setVisible(false)
      elseif ShowType == 3 then
         --self.nodeMinXin:setPosition(ccp(-213,-32))
         self.nodeJinNang:setPosition(ccp(-102,-32))
         self.nodeMinXin:setVisible(true)
         self.nodeJinNang:setVisible(true)
         self.nodeAllCon:setPosition(ccp(-55,0))
         self.nodeTongQian:setVisible(true)
         self.nodeYuanBao:setVisible(true)
      elseif ShowType == 4 then
         self.nodeMinXin:setVisible(true)
         self.nodeTongQian:setVisible(true)
         self.nodeYuanBao:setVisible(true)
         self.nodeLingPai:setVisible(true)
         self.nodeAllCon:setPosition(ccp(-55,0))
      elseif ShowType == 5 then
         self.nodeAllCon:setPosition(ccp(0,0))
         self.nodeTongQian:setVisible(true)
         self.nodeYuanBao:setVisible(true)
         self.nodeLingPai:setVisible(true)
         self.progressBarCon:setVisible(true)
         self.spriteTalentIcon:setVisible(true)
         self.spriteTiLi:setVisible(false)
         self.progressBarSpirit:setVisible(false)
         self.progressBarTalent:setVisible(true)
      elseif ShowType == 6 then
         self.nodeAllCon:setPosition(ccp(0,0))
         self.nodeTongQian:setVisible(true)
         self.nodeYuanBao:setVisible(true)
         self.progressBarCon:setVisible(true)
         self.spriteTalentIcon:setVisible(false)
         self.spriteTiLi:setVisible(true)
         self.progressBarSpirit:setVisible(true)
         self.progressBarTalent:setVisible(false)
         self.nodeSoul:setVisible(true)
      end
end


function GameTopBlock:setPlayerInfoVisible(playInfoVisible)
  self.containerPlayerInfo:setVisible(playInfoVisible)
end

function GameTopBlock:getPlayerInfoVisible()
	return self.containerPlayerInfo:isVisible()
end

function GameTopBlock:getPlayerInfoVisible()
  return self.containerPlayerInfo:isVisible()
end



function GameTopBlock:getSize()
  return self.containerSize:getContentSize()
end



return GameTopBlock