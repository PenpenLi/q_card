CardExpInfoView = class("CardExpInfoView",BaseView)
function CardExpInfoView:ctor(card)
  self:setNodeEventEnabled(true)
  self:setCard(card)
  self:setOldCard(clone(card))
  self:setIsPlayingAnim(false)
  
  --card
  local cardView = CardHeadView.new()
  cardView:setLvFadeEnabled(false)
  cardView:setCard(card)
  
  self:addChild(cardView)
  self._cardView = cardView
  self:setContentSize(self._cardView:getContentSize())
  
  --stars
  local starsNode = display.newNode()
  self:addChild(starsNode)
  starsNode:setPositionY(-56)
  
  self._levelShow = 1
  
  local grade = card:getMaxGrade()
  local currentGrade = card:getGrade()
  local starWidth = 0
  local starHeight = 0
  local distance = -5
  for i = 1, grade do
  	local star = nil
  	if i > currentGrade then
  	 star = display.newSprite("#battle_result_star_gray.png")
  	else
  	 star = display.newSprite("#battle_result_star.png")
  	end
  	starsNode:addChild(star)
  	starWidth = star:getContentSize().width + distance
  	starHeight = star:getContentSize().height
  	star:setPositionX((i-1) * starWidth)
  end
  starsNode:setPositionX(-(starWidth * (grade-1))/2)
  
  local bg = display.newSprite("#battle_result_progress_card_bg.png")
  local fg1 = display.newSprite("#battle_result_progress_card.png")
  local fg2 = display.newSprite("#battle_result_progress_card2.png")
  
  local progressBarExp = ProgressBarView.new(bg, fg1,fg2)
  progressBarExp:setLabelEnabled(false)
  progressBarExp:setAnchorPoint(ccp(0,0))
  self:addChild(progressBarExp)
  progressBarExp:setPosition(-cardView:getContentSize().width/2 + 12, -78)
 
  self._progressBarExp = progressBarExp
  
  local countLabel = CCLabelBMFont:create("", "client/widget/words/card_name/level_number.fnt")
  self:addChild(countLabel)
  countLabel:setPositionY(65)
  self._countLabel = countLabel
  
  local hightLightBoader = display.newSprite("#card_select_hightlight.png")
  self:addChild(hightLightBoader)
  hightLightBoader:setVisible(false)
  self._hightLightBoader = hightLightBoader
  
  self:updateView()
end

function CardExpInfoView:setHightLighted(hightLight)
  hightLight = hightLight or false
  self._hightLightBoader:setVisible(hightLight)
end


------
--  Getter & Setter for
--      CardExpInfoView._IsPlayingAnim 
-----
function CardExpInfoView:setIsPlayingAnim(IsPlayingAnim)
	self._IsPlayingAnim = IsPlayingAnim
end

function CardExpInfoView:getIsPlayingAnim()
	return self._IsPlayingAnim
end

------
--  Getter & Setter for
--      CardExpInfoView._OldCard 
-----
function CardExpInfoView:setOldCard(OldCard)
	self._OldCard = OldCard
end

function CardExpInfoView:getOldCard()
	return self._OldCard
end

function CardExpInfoView:setCountString(countString)
	if countString ~= nil then
	 self._countLabel:setString(countString)
	end
end

function CardExpInfoView:updateView()
    
    self:setCard(GameData:Instance():getCurrentPackage():getCardById(self:getCard():getId()))
    
    if self:getIsPlayingAnim() == true then
      return
    end
    
   
    
    local card = self:getOldCard()
    local new_card = self:getCard()
    
    self._levelShow = card:getLevel()

    local oldLevel = card:getLevel()
    local newLevel = new_card:getLevel()
    
    local oldExp = card:getExperience()
    local newExp = new_card:getExperience()
    
    print("oldLevel:",oldLevel,"newLevel:",newLevel)
    assert(newLevel >= oldLevel)
 
    local oldPercent = 0
    local newPercent = 0
    
    local m_cardExp = nil
    local m_nextCardExp = nil
    
    local m_newLevelCardExp = nil
    local m_newLevelNextCardExp = nil
    
    for key, cardExp in pairs(AllConfig.cardlevelupexp) do
      local oldNextLevel =  math.min(oldLevel + 1,100)
      if --[[cardExp.card_max_rank == card:getMaxGrade() - 1 and]] cardExp.level == oldNextLevel then
        m_nextCardExp = cardExp
      end
      if --[[cardExp.card_max_rank == card:getMaxGrade() - 1 and]] cardExp.level == oldLevel then
        m_cardExp = cardExp
      end
      if --[[cardExp.card_max_rank == card:getMaxGrade() - 1 and]] cardExp.level == newLevel then
        m_newLevelCardExp = cardExp
      end
      
      local newNextLevel = math.min(newLevel + 1,100)
      if --[[cardExp.card_max_rank == card:getMaxGrade() - 1 and]] cardExp.level == newNextLevel then
        m_newLevelNextCardExp = cardExp
      end
      
    end
    
    assert(m_cardExp ~= nil)
    
    if m_nextCardExp == nil then
      oldPercent = 0
      newPercent = 0
    else
      local oldGetedExpThisLevel = oldExp - m_cardExp.total_exp
      oldPercent = (oldGetedExpThisLevel/m_nextCardExp.exp)*100
      if m_cardExp.exp == 0 then
        oldPercent = 0
      end
      
      local newGetedExpThisLevel = newExp - m_cardExp.total_exp
      --local newNextCardExp = AllConfig.cardlevelupexp[key + 1]
      newPercent = (newGetedExpThisLevel/m_nextCardExp.exp)*100
      if m_cardExp.exp == 0 then
        newPercent = 0
      end
      
      
      if newLevel > oldLevel then
        local newGetedExpThisLevel = newExp - m_newLevelCardExp.total_exp
        newPercent = (newGetedExpThisLevel/m_newLevelNextCardExp.exp)*100 + (newLevel - oldLevel)*100
      end
      
      --[[if newLevel > oldLevel then
        local newGetedExpThisLevel = newExp - m_newLevelCardExp.total_exp
        newPercent = (newGetedExpThisLevel/m_newLevelNextCardExp.exp)*100 + (newLevel - oldLevel)*100
         
        local level_str = display.newSprite("#battle_result_level_up.png")
        self:addChild(level_str,200)
        local array = CCArray:create()
        array:addObject(CCMoveBy:create(1.0, ccp(0, 30)))
        array:addObject(CCDelayTime:create(0.4))
        array:addObject(CCFadeOut:create(0.8))
        array:addObject(CCRemoveSelf:create())
        local action = CCSequence:create(array)
        level_str:runAction(action)
--      local levelup_icon = display.newSprite("#battle_result_level_up_arrow.png")
--      cardView:addChild(levelup_icon,200)
--      levelup_icon:setPosition(ccp(-cardView:getContentSize().width/2 + 25,-cardView:getContentSize().height/2 + 35))
  
      end]]
    end
    
  local function fullPercent()
     --cardView:setCard(self:getCard())
     self._levelShow = self._levelShow + 1
     self._cardView:setLvStr(self._levelShow.."")
     self._progressBarExp:setPercent(1,2)

      local level_str = display.newSprite("#battle_result_level_up.png")
      self:addChild(level_str,200)
      local array = CCArray:create()
      array:addObject(CCMoveBy:create(0.8, ccp(0, 30)))
      array:addObject(CCDelayTime:create(0.4))
      array:addObject(CCFadeOut:create(0.8))
      array:addObject(CCRemoveSelf:create())
      local action = CCSequence:create(array)
      level_str:runAction(action)
--      local levelup_icon = display.newSprite("#battle_result_level_up_arrow.png")
--      cardView:addChild(levelup_icon,200)
--      levelup_icon:setPosition(ccp(-cardView:getContentSize().width/2 + 25,-cardView:getContentSize().height/2 + 35))
  end
   
  local function progressBarEnd ()
    self._progressBarExp:stopProgressBar()
    self._cardView:setLvStr(new_card:getLevel().."")
    self:setIsPlayingAnim(false)
  end
  if oldPercent ~= newPercent then
    self:setIsPlayingAnim(true)
  end
  self._progressBarExp:setPercent(oldPercent,1)
  self._progressBarExp:setPercent(oldPercent,2)
  self._progressBarExp:setFullPercentCallback(fullPercent)
  self._progressBarExp:startProgressing(progressBarEnd,oldPercent,newPercent)
  self:setOldCard(nil)
  self:setOldCard(clone(new_card))
end

------
--  Getter & Setter for
--      CardExpInfoView._Card 
-----
function CardExpInfoView:setCard(Card)
	self._Card = Card
end

function CardExpInfoView:getCard()
	return self._Card
end

function CardExpInfoView:onEnter()
  
end

function CardExpInfoView:onExit()
  self:setIsPlayingAnim(false)
end

return CardExpInfoView