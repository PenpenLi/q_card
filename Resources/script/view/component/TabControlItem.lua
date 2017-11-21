require("view.component.TipPic")

TabControlItem = class("TabControlItem",function()
  return display.newNode()
end)

function TabControlItem:ctor(menuItemCfg)
	--TabControlItem.super.ctor(self)
	self._menuItemCfg=menuItemCfg
	self._isSelected = false
	self:setAnchorPoint(ccp(0.5,0.5))
	if self:getHighlightedTexture() ~= nil then
	 self:getHighlightedTexture():setVisible(false)
	end
end


------
--  Getter & Setter for
--      TabControlItem._normalTexture 
-----
function TabControlItem:setNormalTexture(normalTexture,style)
	if self._normalTexture ~= nil then
		self:removeChild(self._normalTexture,true)
	end
	self._normalTexture = normalTexture
	self:addChild(self._normalTexture,1)
	if self._isSelected == true then 
		self._normalTexture:setVisible(false)
	end
	
	--add tip img by default
	
	self:initNewPic()
	self:initTipPic(style)
end

function TabControlItem:getNormalTexture()
	return self._normalTexture
end

------
--  Getter & Setter for
--      TabControlItem._highlightedTexture 
-----
function TabControlItem:setHighlightedTexture(highlightedTexture)
  --echo("highLighted:",highlightedTexture)
  if self._highlightedTexture ~= nil then
    self:removeChild(self._highlightedTexture,true)
  end
	
	if highlightedTexture ~= nil then
	   self:addChild(highlightedTexture,1)
	end
	self._highlightedTexture = highlightedTexture
	if self._isSelected == true then 
	 self._highlightedTexture:setVisible(true)
	end
end

function TabControlItem:getHighlightedTexture()
	return self._highlightedTexture
end

------
--  Getter & Setter for
--      TabControlItem._isSelected 
-----
function TabControlItem:setSelected(isSelected)
	self._isSelected = isSelected
	if self._isSelected == true then 
	 self._normalTexture:setVisible(false)
	 self._highlightedTexture:setVisible(true)
	else
	  self._normalTexture:setVisible(true)
    self._highlightedTexture:setVisible(false)
	end
end

function TabControlItem:getSelected()
	return self._isSelected
end

function TabControlItem:initNewPic(style)
  if self.newtipImg ~= nil then 
    self.newtipImg:removeFromParentAndCleanup(true)
  end
  local size = self:getNormalTexture():getContentSize()
  self.newtipImg = display.newSprite("#common_new_tip.png")
  self.newtipImg:setPosition(ccp(13,size.height - 15))
  self:addChild(self.newtipImg, 4, 101)
  self.newtipImg:setVisible(self:getNewTipImgVisible())
end

------
--  Getter & Setter for
--      TabControlItem._NewTipImgVisible 
-----
function TabControlItem:setNewTipImgVisible(NewTipImgVisible)
	if (self._menuItemCfg) then
    self._menuItemCfg[8] = NewTipImgVisible
  end
  self.newtipImg:setVisible(NewTipImgVisible)
  self.newtipImg:stopAllActions()
  if NewTipImgVisible == true then
    local strength = 5.0
    local times = 2

    local array = CCArray:create()
    local s_duration = 0.6/(times * 2)

    for i=1, times do
      local s_x =  0 --strength + math.random(strength * 100)/100.0
      local s_y =  strength + math.random(strength * 100)/100.0
      array:addObject(CCMoveBy:create(s_duration,ccp(s_x,s_y)))
      array:addObject(CCMoveBy:create(s_duration,ccp(-s_x,-s_y)))
    end
    array:addObject(CCDelayTime:create(3.0))
    local action = CCSequence:create(array)
    self.newtipImg:runAction(CCRepeatForever:create(action))
  end
end

function TabControlItem:getNewTipImgVisible()
  if (self._menuItemCfg) then
    return self._menuItemCfg[8] or false
  end
	return false
end

function TabControlItem:initTipPic(style)
	if self.tipImg ~= nil then 
		self.tipImg:removeFromParentAndCleanup(true)
	end
	local size = self:getNormalTexture():getContentSize()
	
	self.tipImg = TipPic.new(nil,style)
	if style == true then
	  --self.tipImg:setPosition(ccp(-135/2,-140/2))
	  self:addChild(self.tipImg, 0, 100)
	else
  	self.tipImg:setPosition(ccp(size.width-5,size.height-10))
  	self:addChild(self.tipImg, 3, 100)
  end
	--self.tipImg:setVisible(false) --default invisible
	self:setTipVisible(self:isTipVisible())
end

function TabControlItem:setTipVisible(isVisible)
	if (self._menuItemCfg) then
		self._menuItemCfg[6]=isVisible
	end
	self.tipImg:setVisible(isVisible)
end
function TabControlItem:isTipVisible()
	if (self._menuItemCfg) then
		return self._menuItemCfg[6] or false
	end
	return false
end
function TabControlItem:getTipImg()
	return self.tipImg
end

function TabControlItem:getNewTipImg()
  return self.newtipImg
end

function TabControlItem:onExit()
  -- echo("TabControlItem:onExit()")
end

return TabControlItem