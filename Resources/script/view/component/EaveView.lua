require("view.BaseView")
EaveView = class("EaveView",BaseView)
function EaveView:ctor()
  EaveView.super.ctor(self)
  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("backHandler",EaveView.onBackHandler)
  pkg:addFunc("helpHandler",EaveView.onHelpHandler)
  pkg:addProperty("titleSprite","CCSprite")
  pkg:addProperty("spriteYelloBg","CCSprite")
  pkg:addProperty("sprite_largebg","CCSprite")
  pkg:addProperty("sprite_shortbg","CCSprite")
  pkg:addProperty("spriteEmpty","CCSprite")
  pkg:addProperty("scale9spriteBoader","CCScale9Sprite")
  pkg:addProperty("sizeContent","CCNode")
  pkg:addProperty("nodeContainer","CCNode")
  pkg:addProperty("nodeListViewContainer","CCNode")
  pkg:addProperty("btnHelp","CCMenuItemImage")
  pkg:addProperty("btnBack","CCMenuItemImage")
  
  local node,owner = ccbHelper.load("Eave.ccbi","EaveCCB","CCNode",pkg)
  self:addChild(node)
  self:setEmptyImgVisible(false)
  --self._bgHeight = self.spriteYelloBg:getContentSize().height
  
  local menuItem = self.btnHelp
  local strength = 5.0
  local times = 2
  local array = CCArray:create()
  local s_duration = 0.6/(times * 2)
  for i = 1, times do
    array:addObject(CCScaleTo:create(s_duration,1.15,1.10))
    array:addObject(CCScaleTo:create(s_duration,1.0,1.0))
  end
  array:addObject(CCDelayTime:create(3.0))
  local action = CCSequence:create(array)
  menuItem:runAction(CCRepeatForever:create(action))
                  
end

 --update title texture
function EaveView:setTitleTextureName(textureName)
	self._textureName = textureName
	local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(self._textureName)
	print(frame)
	if frame ~= nil then
		self.titleSprite:setDisplayFrame(frame)
	else
		local spriteTitle = display.newSprite(textureName)
		--local frame = CCSpriteFrame:create(textureName,CCRectZero)
		local parent = self.titleSprite:getParent()
		local posX,posY = self.titleSprite:getPosition()
		parent:addChild(spriteTitle)
		spriteTitle:setPosition(ccp(posX,posY))
		self.titleSprite:removeFromParentAndCleanup(true)
	end
end

function EaveView:getTitleTextureName()
  return self._textureName
end

------
--  Getter & Setter for
--      EaveView._backgroundVisible 
-----
function EaveView:setBackGroundVisible(backgroundVisible)
	 --self.spriteYelloBg:setVisible(backgroundVisible)
end

function EaveView:getBackGroundVisible()
	--return self.spriteYelloBg:isVisible()
end

function EaveView:onBackHandler()
  self:getDelegate():onBackHandler()
end

function EaveView:onHelpHandler()
  self:getDelegate():onHelpHandler()
end

function EaveView:getContentSize()
  return self.sizeContent:getContentSize()
end

function EaveView:getEaveBottomPositionY()
 local posx,posy = self.sizeContent:getPosition()
 --echo("pos y ---- ", posy)
 local newPos = tolua.cast(self.sizeContent:getParent():convertToWorldSpace(ccp(posx, posy)), "CCPoint")
 local ap = tolua.cast(self.sizeContent:getAnchorPoint(), "CCPoint")
 newPos.y = newPos.y - self:getContentSize().height * ap.y
 --echo("pos y === ", newPos.y,ap.y)
 return newPos.y 
end

function EaveView:getNodeContainer()
  return self.nodeContainer
end

function EaveView:getNodeListViewContainer()
  return self.nodeListViewContainer
end

--function EaveView:setBackgroundHeight(height)
--    self._bgHeight = height
--    local bgOriginalHeight = self.spriteYelloBg:getContentSize().height
--    local bgTargetHeight = height
--    self.spriteYelloBg:setScaleY(bgTargetHeight/bgOriginalHeight)
--    self.scale9spriteBoader:setContentSize(CCSizeMake(640,height))
--end

--function EaveView:getBackgroundHeight()
--  return self._bgHeight
--end

function EaveView:setEmptyImgVisible(isVisible)
  self.spriteEmpty:setVisible(isVisible)
end 

return EaveView