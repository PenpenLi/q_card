HomeTop = class("HomeTop",BaseView)
function HomeTop:ctor()
  HomeTop.super.ctor(self)
  self:setNodeEventEnabled(true)
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("nodeHead","CCNode")
  pkg:addProperty("progressBarCon","CCNode")
  pkg:addProperty("lableNickName","CCLabelTTF")
  pkg:addProperty("moneyLable","CCLabelTTF")
  pkg:addProperty("coinLable","CCLabelTTF")
  pkg:addProperty("loyaltyLable","CCLabelTTF")
  pkg:addProperty("telentPointLable","CCLabelTTF")
  pkg:addProperty("lableLeadship","CCLabelBMFont")
  pkg:addProperty("label_vipLevel","CCLabelBMFont")
  pkg:addProperty("lableLeadshipRed","CCLabelBMFont")
  pkg:addProperty("levelLabel","CCLabelBMFont")
  pkg:addProperty("label_zhandouli","CCLabelBMFont")
  pkg:addProperty("spriteVipIcon","CCSprite")
  pkg:addProperty("spriteExp","CCSprite")
  pkg:addProperty("spriteTalent","CCSprite")
  pkg:addFunc("headClickHandler",HomeTop.headClickHandler)
  --pkg:addFunc("addMoneyHandler",HomeTop.addMoneyHandler)
  pkg:addFunc("goToPayHandler",HomeTop.goToPayHandler)
  local layer,owner = ccbHelper.load("HomeTop.ccbi","HomeTopCCB","CCNode",pkg)
  self:addChild(layer)
  self._inited = false

   self.spriteExp:setPositionX(self.spriteExp:getPositionX()+2)
   self.spriteExp:setPositionY(self.spriteExp:getPositionY()-4)
   self.nodeHead:setPositionX(self.nodeHead:getPositionX() - 1)
   self._pHeight = self.spriteExp:getContentSize().height 
   self._pWidth = self.spriteExp:getContentSize().width 
   self._rect = self.spriteExp:getTextureRect()

   self:init()
 end

function HomeTop:onEnter()
	self:update()
	CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self,handler(self,self.update),EventType.UPDATE_LEADSHIP)
	CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self,handler(self,self.update),EventType.HOME_UPDATE)
	CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self,handler(self,self.update),EventType.PLAYER_UPDATE)
	--CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self,
	--function()
		--echo("HomeTop EventType.TALENT_BANK")
		--self:update()
	--end,EventType.TALENT_BANK)
	Talent.Instance().SetEvent("TALENT_BANK_CHANGED",function()
		self.scrollTelentPoint:setNumberExt(GameData:Instance():getCurrentPlayer():getTalentBankPoints(), _tr("wan"))
	end,self)
end

function HomeTop:onExit()
  self:closePlayerInfoHandler()
  CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(self,EventType.UPDATE_LEADSHIP)
  CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(self,EventType.HOME_UPDATE)
  CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(self,EventType.PLAYER_UPDATE)
  --CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(self,EventType.TALENT_BANK)
  Talent.Instance().SetEvent("TALENT_BANK_CHANGED",nil,self)

  net.unregistAllCallback(self)
end

function HomeTop:goToPayHandler()
  local shopController = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
  shopController:enter(ShopCurViewType.PAY)
end

function HomeTop:init()
  
  --init scroll label to show coin/money
  local fontName = "Courier-Bold"
  local fontsize = self.coinLable:getFontSize()
  local color = self.coinLable:getColor()
  self.coinLable:setString("")
  self.scrollCoin = ScrollNumberl:createScrollLabel(fontName, fontsize, color, 9)
  self.scrollCoin:setPosition(ccp(self.coinLable:getPosition()))
  self.coinLable:getParent():addChild(self.scrollCoin)

  self.moneyLable:setString("")
  
  fontName = "Courier-Bold"
  fontsize = self.telentPointLable:getFontSize()
  color = self.telentPointLable:getColor()
  self.telentPointLable:setString("")
  self.scrollTelentPoint = ScrollNumberl:createScrollLabel(fontName, fontsize, color, 9)
  self.scrollTelentPoint:setPosition(ccp(self.telentPointLable:getPosition()))
  self.telentPointLable:getParent():addChild(self.scrollTelentPoint)
 
   -- create progress bar
   local bg = CCSprite:createWithSpriteFrameName("progress_bg.png")
   local fg1 = CCSprite:createWithSpriteFrameName("progress_green.png")     
   self.progressBarSpirit = ProgressBarView.new(bg, fg1)
   self.progressBarSpirit:setAnchorPoint(ccp(0,0))
   self.progressBarCon:addChild(self.progressBarSpirit)
   --self.progressBarSpirit:setScale(0.9)
   self.progressBarSpirit:setPosition(ccp(-30,-8))
   self.progressBarSpirit:setLabelEnabled(true)
   self._inited = true
end

function HomeTop:update()
  local mPlayer = GameData:Instance():getCurrentPlayer()
	if(mPlayer==nil or self._inited ==false) then
		return
	end

	self.lableNickName:setString(mPlayer:getName())
	self.levelLabel:setString(string.format("%d", mPlayer:getLevel()))      
	self.loyaltyLable:setString(string.format("%d", mPlayer:getToken()).."/".. mPlayer:getMaxToken()) --AllConfig.characterinitdata[15].data)
	-- self.coinLable:setString(string.format("%d", mPlayer:getCoin()))
	self.moneyLable:setString(string.format("%d", mPlayer:getMoney()))
	self.scrollCoin:setNumberExt(mPlayer:getCoin(), _tr("wan"))
	--self.scrollMoney:setNumberExt(mPlayer:getMoney(), "万")
	if(mPlayer:isTalentInited()) then
		self.scrollTelentPoint:setNumberExt(mPlayer:getTalentBankPoints(), _tr("wan"))
	end

	self.spriteVipIcon:setVisible(mPlayer:isVipState())
  self.label_vipLevel:setVisible(mPlayer:isVipState())
  self.label_vipLevel:setString(""..mPlayer:getVipLevel())
  self.label_vipLevel:setPositionX(self.spriteVipIcon:getPositionX()+self.spriteVipIcon:getContentSize().width+5)

	if GameData:Instance():getCurrentPlayer():getAvatar() ~= self:getAvatar() then
		self:setAvatar(GameData:Instance():getCurrentPlayer():getAvatar())
	end
      
	local percent = 0
	local nowLevel = mPlayer:getLevel()
	if nowLevel ~= nil and nowLevel >= 1 then
		if AllConfig.charlevel[nowLevel+1] ~= nil then
			local currentExp =  mPlayer:getExperience() - AllConfig.charlevel[nowLevel].totalexp
			local needExp = AllConfig.charlevel[nowLevel+1].exp
			percent = (currentExp/needExp)*100
			if percent < 0 then
			percent = 0
			end
		end 
          
          
		print(self._rect.origin.x,self._rect.origin.y,self._rect.size.width,self._rect.size.height*percent/100)
		local percentH = self._pHeight*percent/100
		--assert(false)
		self.spriteExp:setTextureRect(CCRectMake(self._rect.origin.x,self._pHeight - percentH + self._rect.origin.y ,self._rect.size.width,percentH))
        
	end
      
	local spirit = mPlayer:getSpirit()
	local maxSpirit = mPlayer:getMaxSpirit() --AllConfig.characterinitdata[4].data
	percent = (spirit/maxSpirit)*100
	self.progressBarSpirit:setPercent(percent)
      
	local battleCards = GameData:Instance():getCurrentPackage():getBattleCards()
	local cost = 0
	for i = 1,#battleCards do
		cost = cost + battleCards[i]:getLeadCost()
	end
      
	local showText = cost.."/"..GameData:Instance():getCurrentPlayer():getLeadShip()
	self.lableLeadship:setString(showText)
	self.lableLeadshipRed:setString(showText)
      
	self.lableLeadshipRed:setVisible(true)
	self.lableLeadship:setVisible(true)
	if cost <= GameData:Instance():getCurrentPlayer():getLeadShip() then
		self.lableLeadshipRed:setVisible(false)
	else
		self.lableLeadship:setVisible(false)
	end

  local battleCards = GameData:Instance():getCurrentPackage():getBattleCards()
  local curVal = GameData:Instance():getBattleAbilityForCards(battleCards)
  self.label_zhandouli:setString(string.format("%d", curVal))
end

function HomeTop:enterPlayerInfoHandler()
  if self.enabledOpenPlayerInfo == false then
    return
  end
  
  self.enabledOpenPlayerInfo = false
  self.playerInfoView = PlayerInfoView.new()
  self.playerInfoView:setDelegate(self)
--  self._currentViewPosX = BaseController._lastController:getScene():getCurrentView():getPositionX()
--  BaseController._lastController:getScene():getCurrentView():setPositionX(display.size.width)
--  BaseController._lastController:getScene():getCurrentView():setVisible(false)
  GameData:Instance():getCurrentScene():addChildView(self.playerInfoView)
  self.playerInfoView:setScale(0.2)
  self.playerInfoView:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6) )
end

function HomeTop:closePlayerInfoHandler()
   self.enabledOpenPlayerInfo = true
   if self.playerInfoView == nil then
    return
   end 
   
--   BaseController._lastController:getScene():getCurrentView():setPositionX(self._currentViewPosX)
--   BaseController._lastController:getScene():getCurrentView():setVisible(true)
   self.playerInfoView:setDelegate(nil)
   --self.playerInfoView:unRegistNetSever()
   --self.playerInfoView:getParent():removeChild(self.playerInfoView,true)
   self.playerInfoView:removeFromParentAndCleanup(true)
   self.playerInfoView = nil
end

function HomeTop:headClickHandler()
  print("headClick")
  self:enterPlayerInfoHandler()
end

function HomeTop:addMoneyHandler()
  
end
--
--function HomeTop:onChangeAvatarResult(action,msgId,msg)
----     enum traits { value = 3780;}
----  enum State {
----    Ok = 0;
----    NoSuchAvatarOrNoChange = 1;
----  }
----  required State state = 1;
--    if msg.state == "Ok" then
--       self:setAvatar(GameData:Instance():getCurrentPlayer():getAvatar())
--    elseif msg.state == "NoSuchAvatarOrNoChange" then
--       echo(msg.state)
--    else
--       echo("changeAvatar Error")
--    end
--   
--end


------
--  Getter & Setter for
--      GameTopBlock._Avatar 
-----
function HomeTop:setAvatar(Avatar)
  self._Avatar = Avatar
 
  local unitRoot = Avatar
  local picId = 0
  if unitRoot  == nil or unitRoot <= 1 then
     picId = 3012502
  else
     local cardConfigId = tonumber(unitRoot.."01")
     picId = AllConfig.unit[cardConfigId].unit_head_pic
  end
  
  local head = _res(picId)
  if head~= nil then
     self.nodeHead:removeAllChildrenWithCleanup(true)
     local boader = display.newSprite("#home_head_bg.png")
     self.nodeHead:addChild(boader)
     boader:setScale(0.95)
     
     head:setScale(0.85)
     local mask = DrawCricleMask:create(46,head)
     self.nodeHead:addChild(mask)
  end
end

function HomeTop:getAvatar()
  return self._Avatar
end


return HomeTop