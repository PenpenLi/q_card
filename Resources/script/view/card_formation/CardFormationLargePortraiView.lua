CardFormationLargePortraiView = class("CardFormationLargePortraiView",BaseView)
function CardFormationLargePortraiView:ctor()
  local portrai = display.newNode()
  self:addChild(portrai)
  self._portraiCon = portrai
end

------
--  Getter & Setter for
--      CardFormationLargePortraiView._Card 
-----
function CardFormationLargePortraiView:setCard(Card)
	self._Card = Card
	self._portraiCon:removeAllChildrenWithCleanup(true)
	if Card ~= nil then
  	local res = _res(Card:getUnitPic())
    res:setAnchorPoint(ccp(0.5,0))
    res:setScale(0.75)
    res:setPositionX(280)
    self._portraiCon:addChild(res)
  end
end

function CardFormationLargePortraiView:getCard()
	return self._Card
end

return CardFormationLargePortraiView