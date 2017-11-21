ArenaPortraitView = class("ArenaPortrait",function()
  return display.newNode()
end)
function ArenaPortraitView:ctor()
  self:setNodeEventEnabled(true)
  self:setAnchorPoint(ccp(0.5,0.5))
  display.addSpriteFramesWithFile("contest/arena_portrait.plist", "contest/arena_portrait.png")
  
end

------
--  Getter & Setter for
--      ArenaPortraitView._Card 
-----
function ArenaPortraitView:setCard(Card)
	if self._Card == Card and Card ~= nil then
    return
  end	
	
	self:removeAllChildrenWithCleanup(true)
	
	self._Card = Card
	if self._Card ~= nil then
	  
	  local head = _res(Card:getUnitPic())
	 
    if head ~= nil then
       local scale_x_y = AllConfig.unit[Card:getConfigId()].unit_xy
       local scale = scale_x_y[1]/10000
       local offsetX = scale_x_y[2]
       local offsetY = scale_x_y[3]
       
       print("scale,x,y:",scale,offsetX,offsetY)
       
       head:setScale(scale)
       local mask = DSMask:createMask(CCSizeMake(72,310))
       mask:setPosition(ccp(-72/2,-310/2))
       head:setPosition(ccp(72/2 + offsetX,310/2 - offsetY))
       mask:addChild(head)
       self:addChild(mask)
    end
    
    --local  shadow = display.newSprite("#contest_grade_mask.png")
    --self:addChild(shadow)
	
	  local card_grade = Card:getGrade()
	  local boader = display.newSprite("#const_boader_grade_"..card_grade..".png")
	  self:addChild(boader)
	  self._boader = boader
	  
	  local sptIcon = nil
    assert(Card:getType() ~= nil,"Invalid card:getType() should not be nil")
    sptIcon = _res(PbTroopSpt[Card:getType()])
    
    if sptIcon ~= nil then  
      self:addChild(sptIcon)
      sptIcon:setScale(0.4)
      sptIcon:setPosition(ccp(boader:getContentSize().width/2 - 18, -boader:getContentSize().height/2 + 25  -5))
    end
    
    local labelName = CCLabelBMFont:create("", "client/widget/words/card_name/name_card.fnt")
    self:addChild(labelName,255)
    labelName:setPosition(ccp(-20, -boader:getContentSize().height/2 + 15    +30))
    
    local s = AllConfig.unit[Card:getConfigId()].unit_cardname
    local name = ""
    local zh_idx = 1
    local zh_size = 3
    local zh_len = string.len(s)/zh_size
    for i= 1, zh_len do
      name = name..string.sub(s,zh_idx,string.len(s)/zh_len*i).."\n"
      zh_idx = zh_idx + zh_size
    end
    print("name:",s,name)
    labelName:setString(name)
    labelName:setScale(0.7)
	  
	else
	  local boader = display.newSprite("#contest_grade_default.png")
	  self._boader = boader
    self:addChild(boader)
	end
end

function ArenaPortraitView:getContentSize()
	return self._boader:getContentSize()
end

function ArenaPortraitView:getCard()
	return self._Card
end

return ArenaPortraitView