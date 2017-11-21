BattleFormationCardView = class("BattleFormationCardView",function()
  return display.newNode()
end)
function BattleFormationCardView:ctor(card,battleFormationIdx)
  self:setNodeEventEnabled(true)
  self:setSelected(false)
  self._battleFormationIdx = battleFormationIdx
  --self:setAnchorPoint(ccp(0,0))
  if card ~= nil then
    self:setCard(card)
  end
end
------
--  Getter & Setter for
--      BattleFormationCardView._Card 
-----
function BattleFormationCardView:setCard(Card)
	self._Card = Card
	
	self:removeAllChildrenWithCleanup(true)
	
	local cardHeadView = CardHeadView.new(Card)
  self:addChild(cardHeadView)
  local headSize = cardHeadView:getContentSize()
  --cardHeadView:setPosition(headSize.width/2,headSize.height/2 + 10)
  self:setContentSize(headSize)
  cardHeadView:setLvFadeEnabled(false)
  
  local card = Card

  if self._battleFormationIdx == BattleFormation.BATTLE_INDEX_BABLE then
    -- add hp bar node
    local nodeHp = display.newNode()
    nodeHp:setCascadeOpacityEnabled(true)
    self:addChild(nodeHp)
    self._nodeHp = nodeHp
    nodeHp:setPositionY(-50)
    
    -- hp outframe
    local sptHpFrame = _res(3025002)
    nodeHp:addChild(sptHpFrame)
    
    -- hp bar
    local sptHp = _res(3025001) --  _res(3025003)
    sptHp:setAnchorPoint(ccp(0.0,0.5))
    nodeHp:addChild(sptHp)
    sptHp:setPositionX(-44)
    
    local hpper = Card:getCardHpperByHpType(Card.CardHpTypeBable)
    local percent = hpper/10000
    sptHp:setScaleX(percent)
    
    if hpper <= 0 then
      local deadMark = display.newSprite("#battle_formation_dead_mark.png")
      deadMark:setPosition(ccp(25,30))
      self:addChild(deadMark)
    end
    
  else
    --stars
    local starsNode = display.newNode()
    self:addChild(starsNode)
    starsNode:setPositionY(-56 + 5)
    
    local finalOffsetX = 0
    
    
    local grade = card:getMaxGrade()
    local currentGrade = card:getGrade()
    local starWidth = 0
    local starHeight = 0
    local distance = -9
    for i = 1, grade do
      local star = nil
      if i > currentGrade then
       star = display.newSprite("#battle_formation_star_gray.png")
      else
       star = display.newSprite("#battle_formation_star.png")
      end
      starsNode:addChild(star,grade - i)
      starWidth = star:getContentSize().width + distance
      starHeight = star:getContentSize().height
      star:setPositionX((i-1) * starWidth)
    end
    starsNode:setPositionX(-(starWidth * (grade-1))/2 + finalOffsetX)
  
  end
  
  
  
  
  local countryIcon = display.newSprite("#battle_formation_country_"..card:getCountry()..".png")
  if countryIcon ~= nil then
    self:addChild(countryIcon)
    countryIcon:setPosition(ccp(-35,32))
  end
  self._countryIcon = countryIcon
  
  local selectedIcon = display.newSprite("#battle_formation_selected.png")
  self:addChild(selectedIcon)
  selectedIcon:setPosition(ccp(-30,30))
  selectedIcon:setVisible(self:getSelected())
  self._selectedIcon = selectedIcon
  
  local labelCardName = CCLabelTTF:create(card:getName(), "Courier-Bold",22)
  labelCardName:setColor( ccc3(255,255,255))
  self:addChild(labelCardName)
  labelCardName:setPositionY(-75)
  
end

function BattleFormationCardView:getCard()
	return self._Card
end

------
--  Getter & Setter for
--      BattleFormationCardView._Selected 
-----
function BattleFormationCardView:setSelected(Selected)
  if Selected == nil then
    Selected = false
  end

	self._Selected = Selected
	if self._selectedIcon ~= nil then
	 self._selectedIcon:setVisible(Selected)
	end
	if self._countryIcon ~= nil then
	 self._countryIcon:setVisible(not Selected)
	end
	
	local card = self:getCard()
	if card ~= nil then
	 local tempSelected = 0
	 if Selected == true then
	   tempSelected = 1
	 end
	 card.tempSelected = tempSelected
	end
end

function BattleFormationCardView:getSelected()
	return self._Selected
end

return BattleFormationCardView