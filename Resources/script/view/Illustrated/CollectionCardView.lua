CollectionCardView = class("CollectionCardView",function ()
  return display.newNode()
end)
function CollectionCardView:ctor(data)
    self:setCascadeOpacityEnabled(true)
    self:setData(data)
end

function CollectionCardView:setData(Data)
	  self._Data = Data
	  local head = CardHeadView.new()
    --head:setScale(0.8)
    head:setCard(Data)
    head:setLvVisible(false)
    head.portraitNode:removeAllChildrenWithCleanup(true)
    CCNodeExtend.extend(head)
    local cardHeadImg = _res(Data:getUnitHeadPic())
    cardHeadImg:setCascadeOpacityEnabled(true)
    cardHeadImg:setScale(0.7)
    head.portraitNode:addChild(cardHeadImg)
    
    --head:hideCardDetails()
    --head:setIsHideBoard(true)
    self:addChild(head)
    local headSize = CCSizeMake(head:getWidth(),head:getHeight())
   
--    self.head = _res(Data:getUnitHeadPic())
--    local scale = 0.65
--    self.head:setScale(scale)
--    self:addChild(self.head)
--    self:setContentSize(CCSizeMake(self.head:getContentSize().width*scale,self.head:getContentSize().height*scale))
    local cardName = Data:getName() or ""
    if self._nameTtf == nil then
      local fontSize = 24
      local nameTtf = CCLabelTTF:create(cardName,"Courier-Bold",fontSize)
      self:addChild(nameTtf)
      nameTtf:setPositionY(-headSize.height/2 - 5)
      self._nameTtf = nameTtf
      self:setContentSize(CCSizeMake(head:getWidth(),head:getHeight() + fontSize))
    else
      self._nameTtf:setString(cardName)
    end
    
    --echo("getState:",Data:getState())
    if Data:getState() == "HasMeeted" then
       cardHeadImg:setOpacity(100)
       --assert(false)
    elseif Data:getState() == "HasOwned" then
       cardHeadImg:setOpacity(255)
    else
       --self:setOpacity(120)
       local unMeetSprite = display.newSprite("#gallery-imgage-wenhao.png")
       unMeetSprite:setScale(0.8)
       head.portraitNode:removeAllChildrenWithCleanup(true)
       head.portraitNode:addChild(unMeetSprite)
       head:hideCardDetails()
    end
end

function CollectionCardView:getData()
  return self._Data
end

return CollectionCardView