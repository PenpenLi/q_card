require("view.arena.ArenaPortraitView")
ArenaEnterEffectAnimation = class("ArenaEnterEffectAnimation",BaseView)
function ArenaEnterEffectAnimation:ctor(isAttacker)
  self:setNodeEventEnabled(true)
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("label_attacker_name","CCLabelTTF")
  pkg:addProperty("label_defender_name","CCLabelTTF")
  pkg:addProperty("label_attacker_up","CCLabelTTF")
  pkg:addProperty("label_defender_up","CCLabelTTF")
  pkg:addProperty("label_attacker_keepwin","CCLabelTTF")
  pkg:addProperty("label_defender_keepwin","CCLabelTTF")
  local layer,owner = ccbHelper.load("Contest_wudoudahui01.ccbi","WuDouTopBannerCCB","CCLayer",pkg)
  self:addChild(layer,100)
  self._topBanner = layer
  self._topBanner:setVisible(false)
  self._flagPosY = display.cy
  self._subNode = display.newNode()
  self:addChild(self._subNode)
  self._portraitCon = display.newNode()
  self._subNode:addChild(self._portraitCon,100)
  self._portraitCon:setVisible(false)
  self._targetCards = {}
  self._isAttacker = isAttacker


  if (isAttacker) then
	local size = CCDirector:sharedDirector():getWinSize()
    self._subNode:setPosition(ccp(0,size.height/2-50))
  end

end

function ArenaEnterEffectAnimation:onEnter()
  
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("mAnimationManager","CCBAnimationManager")
  pkg:addProperty("nodeAtk","CCSprite")
  pkg:addProperty("nodeDef","CCSprite")
  pkg:addFunc("play_end",ArenaEnterEffectAnimation.playEndHandler)
  local layer,owner = ccbHelper.load("anim_Wudou01.ccbi","WuDouStartCCB","CCLayer",pkg)
  self:addChild(layer)
  self._enterAnimation = layer
  
  -- delegate is battle view
  if self:getDelegate() ~= nil then
    self:getDelegate():removeArenaCloud()
  end
  
end

function ArenaEnterEffectAnimation:playEndHandler()
  --self:removeFromParentAndCleanup(true)
  if self._enterAnimation ~= nil then
     self._enterAnimation:removeFromParentAndCleanup(true)
     self._enterAnimation = nil
  end
  
  self._topBanner:setVisible(true)
  
  --[[ --not use now
  local flag_pkg = ccbRegisterPkg.new(self)
  flag_pkg:addProperty("mAnimationManager","CCBAnimationManager")
  flag_pkg:addProperty("nodeFlag","CCNode")
  flag_pkg:addFunc("p_end",function()  end)
  local flag_layer,_owner = ccbHelper.load("anim_Wudou02_a.ccbi","FlagBgCCB","CCLayer",flag_pkg)
  self:addChild(flag_layer)
  self._flagAnimation = flag_layer
  
  self.nodeFlag:setPositionY(self._flagPosY)
  ]]
  
  ---FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  --cards enter animation
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("mAnimationManager","CCBAnimationManager")
  for i = 1, 8 do
    pkg:addProperty("card_front_"..i,"CCSprite")
  end
  pkg:addFunc("cards_enter_end",function()

    for i = 1, 8 do
		pkg:addProperty("card_front_"..i,"CCSprite")
	end
  end)
  local layer,owner = ccbHelper.load("anim_Wudou04.ccbi","CardsEnterAnimationCCB","CCLayer",pkg)
  self._subNode:addChild(layer)
  
  
  for i = 1, 8 do
    local arenaPortraitView = ArenaPortraitView.new()
    arenaPortraitView:setCard(self._targetCards[i])
    local size = arenaPortraitView:getContentSize()
    self['card_front_'..i]:addChild(arenaPortraitView)
    arenaPortraitView:setPosition(ccp(size.width/2,size.height/2))
    
  end
  
  self._portraitCon:setPositionY(self._flagPosY)
  self._portraitCon:setVisible(true)
  --self._portraitCon:addChild(layer)
  
--  -- delegate is battle view
--  if self:getDelegate() ~= nil then
--    self:getDelegate():startTimeCountDown()
--  end
  
end

function ArenaEnterEffectAnimation:playLeaveHandler(callback)
  if self._leaveAnimation then
		return
  end
  self._subNode:removeAllChildrenWithCleanup(true)
  
  --cards enter animation
  local owerObjects={}
  local pkg = ccbRegisterPkg.new(owerObjects)
  pkg:addProperty("mAnimationManager","CCBAnimationManager")
  for i = 1, 8 do
    pkg:addProperty("card_front_"..i,"CCSprite")
  end
  local layer,owner
  pkg:addFunc("cards_leave_end",function()
  	--if(callback) then callback() end
  	layer:removeFromParentAndCleanup(true)
  	self:removeFromParentAndCleanup(true)
  	
  	-- delegate is battle view
    if self:getDelegate() ~= nil then
      self:getDelegate():setArenaView(nil)
    end
  end)
  layer,owner = ccbHelper.load("anim_Wudou04_b.ccbi","CardsLeaveAnimationCCB","CCLayer",pkg)
  for i = 1, 8 do
    local arenaPortraitView = ArenaPortraitView.new()
    arenaPortraitView:setCard(self._targetCards[i])
    local size = arenaPortraitView:getContentSize()
    owerObjects['card_front_'..i]:addChild(arenaPortraitView)
    arenaPortraitView:setPosition(ccp(size.width/2,size.height/2))
  end
  self._subNode:addChild(layer)  
  self._leaveAnimation = true

end

function ArenaEnterEffectAnimation:updateView(arenaFightInfo)
  
  local targetPlayer = arenaFightInfo:getTargetPlayer()
  local selfPlayer = Arena:Instance():getSelfPlayer()
  
  assert(targetPlayer:getId() ~= selfPlayer:getId())
  
  if targetPlayer:getIsAttacker() == false then
     self:setPortraitsAndInfos(selfPlayer,targetPlayer)
     self._flagPosY = display.cy  + 200
  else
     self:setPortraitsAndInfos(targetPlayer,selfPlayer)
     self._flagPosY = display.cy  -200
  end
  
--  if self.nodeFlag ~= nil then
--    self.nodeFlag:setPositionY(self._flagPosY)
--  end
  
  self._portraitCon:removeAllChildrenWithCleanup(true)
  
  local cards = arenaFightInfo:getTargetCards()
  self._targetCards = cards
  
  self._portraitCon:setPositionY(self._flagPosY)
end

function ArenaEnterEffectAnimation:setPortraitsAndInfos(attacker,defender)
  
     self.label_attacker_name:setString(attacker:getName().."")
     self.label_defender_name:setString(defender:getName().."")
     
	 local diff = attacker:getKeepWin() - defender:getKeepWin()
     self.label_attacker_up:setString("x"..(diff>=0 and 0 or -diff))
     self.label_defender_up:setString("x"..(diff<=0 and 0 or diff))
     
     self.label_attacker_keepwin:setString("x"..attacker:getKeepWin())
     self.label_defender_keepwin:setString("x"..defender:getKeepWin())
     
     --set large portraits
     if self.nodeAtk ~= nil and attacker:getHeadId() > 0 then
        local unitId = toint(attacker:getHeadId().."01")
        local portraitId = AllConfig.unit[unitId].unit_pic
        local portrait = _res(portraitId)
        if portrait ~= nil and self.nodeAtk:getParent() ~= nil then
           local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("empty.png")
           self.nodeAtk:setDisplayFrame(frame)
           self.nodeAtk:addChild(portrait)
        end
     end
      
     if self.nodeDef ~= nil and defender:getHeadId() > 0 then
        local unitId = toint(defender:getHeadId().."01")
        local portraitId = AllConfig.unit[unitId].unit_pic
        local portrait = _res(portraitId)
        if portrait ~= nil and self.nodeDef:getParent() ~= nil then
           local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("empty.png")
           self.nodeDef:setDisplayFrame(frame)
           self.nodeDef:addChild(portrait)
        end
     end
end

function ArenaEnterEffectAnimation:onExit()
 
end

return ArenaEnterEffectAnimation