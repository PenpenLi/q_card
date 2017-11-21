require("view.card_levelup.ExpItemAddView")
require("model.bag.BagPropsData")
CardLevelUpView = class("CardLevelUpView",BaseView)
function CardLevelUpView:ctor(card,priority)
  assert(card ~= nil,"must create with an card!")
  CardLevelUpView.super.ctor(self)
  self._priority = priority or - 128
  self:setTouchEnabled(true)
  self:addTouchEventListener(handler(self,self.onTouch),false,self._priority + 1,true)
  self:setCard(card)
  self:setIsPlayingAnim(false)
end

------
--  Getter & Setter for
--      name._IsPlayingAnim 
-----
function CardLevelUpView:setIsPlayingAnim(IsPlayingAnim)
	self._IsPlayingAnim = IsPlayingAnim
end

function CardLevelUpView:getIsPlayingAnim()
	return self._IsPlayingAnim
end

function CardLevelUpView:getAddedExp()
  local addedExp = 0
  for key, addedItemView in pairs(self._itemViewConArray) do
    print("getSelectedExp:",addedItemView:getSelectedExp())
  	addedExp = addedExp + addedItemView:getSelectedExp()
  end
  return addedExp
end

function CardLevelUpView:reduceCount(targetItemView)
  self:addCount(targetItemView,-1)
end

function CardLevelUpView:addCount(targetItemView,step)

  local playerLevel = GameData:Instance():getCurrentPlayer():getLevel()
  local card = self:getCard()
  local targetLevel = math.min(card:getMaxLevel(),playerLevel)
  
  --print("targetLevel:",targetLevel)
  local levelupExp,totalExp = card:getExpByLeve(targetLevel)
  --print("totalExp:",totalExp)
  
  local allAddedExp = self:getAddedExp()
--  print("allAddedExp:",allAddedExp)
--  print("cardExp:",card:getExperience())
--  print("finalExp",allAddedExp + card:getExperience())
--  print("each exp:",targetItemView:getEachExp())
  
  local maxLevelCount = math.ceil((totalExp - card:getExperience())/targetItemView:getEachExp())
  local max = math.min(maxLevelCount,targetItemView:getCount())
--  print("maxLevelCount:",maxLevelCount,targetItemView:getCount())
--  print("max:",max)
  
  local selectedCount = targetItemView:getSelectedCount()
  --print("lastCount:",selectedCount)
  if step ~= nil then
    selectedCount = selectedCount + step
  else
    selectedCount = math.ceil(selectedCount*1.2)
  end
  
  if selectedCount < 0 then
    selectedCount = 0
  end
  
  if selectedCount > max then
    selectedCount = max
  end
  
  if selectedCount >= 0 then
    targetItemView:setSelectedCount(selectedCount)
  end
  
  local nextPercent = 0
  local nextExp = card:getExperience() + self:getAddedExp()
  local nextLevel = card:getLevelByExp(nextExp)
  self.levelLabel:setString(string.format("%d", nextLevel))
  print("nextLevel > card:getLevel():",nextLevel , card:getLevel())
  nextPercent = card:getExpPercentByLeve(nextLevel, nextExp)
  if nextLevel > card:getLevel() then
    self._progressBar:setPercent(0, 2)
  end
  self._progressBar:setPercent(nextPercent, 1)
  
  self._startPercent = card:getExpPercentByLeve(card:getLevel(),card:getExperience())
  self._endPercent = nextPercent
  self._startLevel = card:getLevel()
  self._endLevel = nextLevel
  self._levelShow = self._startLevel

  self:setAfterInfoByLv(nextLevel)
end

function CardLevelUpView:onTouch(event, x, y)

  if self:getIsPlayingAnim() == true then
    return true
  end

  if event == "began" then
   
    self._touchStepX = x
    self._touchStepY = y
    self:stopAllActions()
    self._startItem = nil
    self._startItemId = -1
    
    local targetItem = UIHelper.getTouchedNode(self._itemViewConArray,x,y)
    
    if targetItem ~= nil then
      print("targetItem:",targetItem:getConfigId())
      
--     if self:getCard():getLevel() >= self:getCard():getMaxLevel() then
--      targetItem:setSelectedCount(0)
--     end
     _executeNewBird()
      
     if self:getCard():getLevel() >= self:getCard():getMaxLevel() then
      Toast:showString(self,_tr("upgrade_card_first"), ccp(display.cx, display.cy))
      return true
     end
     
     if self:getCard():getLevel() >= GameData:Instance():getCurrentPlayer():getLevel() then
      Toast:showString(self,_tr("level_up_player_level_first"), ccp(display.cx, display.cy))
      return true
     end
     
     if self._endLevel ~= nil then
       if  self._endLevel >= self:getCard():getMaxLevel()
       or  self._endLevel >= GameData:Instance():getCurrentPlayer():getLevel()
       then
        return true
       end
     end

     self:addCount(targetItem,1)
     --targetCard:setCountString("+"..self._addSpeed)
     self._addTimer = self:schedule(function() self:addCount(targetItem) end,0.25)
     self._startItemId = targetItem:getConfigId()
     self._startItem = targetItem
      return true
    end
    
    return true
  elseif event == "moved" then
    if math.abs(self._touchStepX-x) > 25 or math.abs(self._touchStepY-y) > 25 then
      self:stopAllActions()
--      if self._startItem ~= nil then
--        self._startItem:setCountString("")
--      end
    end
  elseif event == "ended" then
    self:stopAllActions()
--    if math.abs(self._touchStepX-x) < 30 and math.abs(self._touchStepY-y) < 30 then
--       local targetItem = UIHelper.getTouchedNode(self._itemViewConArray,x,y)
--       if targetItem ~= nil and self._startItemId == targetItem:getConfigId() then
--         
--       end
--    end
    local size = self.sprite_bg:getContentSize()
    local pos = self.sprite_bg:convertToNodeSpace(ccp(x, y))
    if pos.x < 0 or pos.x > size.width or pos.y < 0 or pos.y > size.height then 
      self:closeHandler()
      return false
    end
    
  end
end 

------
--  Getter & Setter for
--      CardLevelUpView._Card 
-----
function CardLevelUpView:setCard(Card)
	self._Card = Card
end

function CardLevelUpView:getCard()
	return self._Card
end

function CardLevelUpView:onEnter()
  self._dataInstance = BagPropsData.new(self)
  
  print("CardLevelUpView:onEnter()")
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("sprite_bg","CCScale9Sprite")
  pkg:addProperty("closeMenu","CCMenu")
  pkg:addProperty("closeMenuItem","CCMenuItemSprite")
  pkg:addProperty("label_son_title","CCLabelTTF")
  pkg:addProperty("sprite_son_bg","CCScale9Sprite")
  pkg:addProperty("levelLabel","CCLabelBMFont")
  pkg:addProperty("nodeProgressBar","CCNode")
  pkg:addProperty("btn_level_up","CCMenu")
  pkg:addProperty("btnLevelUpItem","CCMenuItemSprite")
  pkg:addProperty("card_level_up_view","CCSprite")
  
  
  local strs = {"Atk","Hp","Int","Dom","Str"}
  for i=1, #strs do
  	pkg:addProperty("labelTitle"..strs[i],"CCLabelTTF")
  	pkg:addProperty("labelBefore"..strs[i],"CCLabelTTF")
  	pkg:addProperty("labelAfter"..strs[i],"CCLabelTTF")
  end
  
  
  pkg:addFunc("levelUpHandler",CardLevelUpView.levelUpHandler)
  pkg:addFunc("closeHandler",CardLevelUpView.closeHandler)
  
  --color layer
  local layerScale = 2
  local layerColor = CCLayerColor:create(ccc4(0,0,0,185), display.width*layerScale, display.height*layerScale)
  self:addChild(layerColor)
  layerColor:setPosition(-(display.width*layerScale - display.width)/2,-(display.height*layerScale - display.height)/2)

  local layer,owner = ccbHelper.load("card_level_up_view.ccbi","card_level_up_view","CCLayer",pkg)
  self:addChild(layer)
  self._ccbLayer = layer 
  
  
  self.labelTitleAtk:setString(_tr("k_property_atk_fix"))
  self.labelTitleStr:setString(_tr("k_property_str_fix"))
  self.labelTitleDom:setString(_tr("k_property_dom_fix"))
  self.labelTitleInt:setString(_tr("k_property_int_fix"))
  self.labelTitleHp:setString(_tr("k_property_hp_fix"))
  
  self.label_son_title:setString(_tr("current_have"))
  
  self.closeMenu:setTouchPriority(self._priority)
  self.btn_level_up:setTouchPriority(self._priority)
  
  
  _registNewBirdComponent(106016,self.closeMenuItem)
  _registNewBirdComponent(106014,self.btnLevelUpItem)
  
  local card = self:getCard()
  self.levelLabel:setString(card:getLevel().."")
  self:buildList()
  
  if self._progressBar == nil then
  local progressBar_bg = display.newSprite("#pg_bg.png")
  local progressBar_green = display.newSprite("#pg_green.png")
  local progressBar_yellow = display.newSprite("#pg_yellow.png")
  assert(progressBar_bg ~= nil)
  assert(progressBar_green ~= nil)
  assert(progressBar_yellow ~= nil)
  self._progressBar = ProgressBarView.new(progressBar_bg, progressBar_yellow,progressBar_green)
  self._progressBar:setPercent(0, 1)
  local card = self:getCard()
  self._progressBar:setPercent(card:getExpPercentByLeve(card:getLevel(),card:getExperience()), 2)
  self._progressBar:setBreathAnim(1)
  self.nodeProgressBar:addChild(self._progressBar)
  self._progressBar:setPositionX(85)
   
  self._progressBar:setFullPercentCallback(function() self:fullPercent() end)
  
  end 
  
--  function Card:getPropertyByTypeAndLevel(type,level)
--  local isPer = false
--  if type ==  k_property_hp_fix then
--    return toint(self:getHpByLevel(level)),isPer
--  elseif type == k_property_atk_fix then
--    return toint(self:getAttackByLevel(level)),isPer
--  elseif type == k_property_str_fix then
--    return toint(self:getStrengthByLevel(level)),isPer
--  elseif type == k_property_int_fix then
--    return toint(self:getIntelligenceByLevel(level)),isPer
--  elseif type == k_property_dom_fix then
--    return toint(self:getDominanceByLevel(level)),isPer
--  end

  local startLevel = card:getLevel()
  
  self:setBeforeInfosByLv(startLevel)
  self:setAfterInfoByLv(startLevel)

  _executeNewBird()
end

function CardLevelUpView:setBeforeInfosByLv(startLevel)
  local card = self:getCard()
  self.labelBeforeHp:setString(card:getPropertyByTypeAndLevel(k_property_hp_fix,startLevel).."")
  self.labelBeforeAtk:setString(card:getPropertyByTypeAndLevel(k_property_atk_fix,startLevel).."")
  self.labelBeforeStr:setString(card:getPropertyByTypeAndLevel(k_property_str_fix,startLevel).."")
  self.labelBeforeInt:setString(card:getPropertyByTypeAndLevel(k_property_int_fix,startLevel).."")
  self.labelBeforeDom:setString(card:getPropertyByTypeAndLevel(k_property_dom_fix,startLevel).."")
  
end

function CardLevelUpView:setAfterInfoByLv(startLevel)
  local card = self:getCard()
  self.labelAfterHp:setString(card:getPropertyByTypeAndLevel(k_property_hp_fix,startLevel).."")
  self.labelAfterAtk:setString(card:getPropertyByTypeAndLevel(k_property_atk_fix,startLevel).."")
  self.labelAfterStr:setString(card:getPropertyByTypeAndLevel(k_property_str_fix,startLevel).."")
  self.labelAfterInt:setString(card:getPropertyByTypeAndLevel(k_property_int_fix,startLevel).."")
  self.labelAfterDom:setString(card:getPropertyByTypeAndLevel(k_property_dom_fix,startLevel).."")
  
end

function CardLevelUpView:fullPercent()
  self._levelShow = self._levelShow + 1
  self.levelLabel:setString(string.format("%d", self._levelShow))
  self._progressBar:setPercent(1,1)
  self:setAfterInfoByLv(self._levelShow)
end


function CardLevelUpView:updateCardView(cardId)
--  self._startPercent = card:getExpPercentByLeve(card:getLevel(),card:getExperience())
--  self._endPercent = nextPercent
--  self._startLevel = card:getLevel()
--  self._endLevel = nextLevel
--  self._levelShow = self._startLevel
  
  for key, addedItemView in pairs(self._itemViewConArray) do
    local item = GameData:Instance():getCurrentPackage():getPropsByConfigId(addedItemView:getConfigId())
    if item ~= nil then
      addedItemView:setCount(item:getCount())
    else
      addedItemView:setCount(0)
    end
    addedItemView:setSelectedCount(0)
  end
  
  
  local addLv = self._endLevel - self._startLevel
  --lv up
  if addLv > 0 then
    
  end
  
  self._progressBar:setFullPercentCallback(function() self:fullPercent() end)
  
  self.levelLabel:setString(string.format("%d", self._startLevel))
  local function progressBarEnd ()
  
    local card = self:getCard()
    local currentLevel = card:getLevel()
    self._endLevel = currentLevel
    
    self._progressBar:stopProgressBar()
    self.levelLabel:setString(string.format("%d", self._endLevel))
    self:setIsPlayingAnim(false)
    
    
    self:setBeforeInfosByLv(currentLevel)
    self:setAfterInfoByLv(currentLevel)
  end

  self:setIsPlayingAnim(true)
  self._progressBar:startProgressing(progressBarEnd,self._startPercent,self._endPercent + addLv*100,2)
  
end

function CardLevelUpView:onExit()
  self._dataInstance:exit()
  self._dataInstance = nil
  if self._progressBar ~= nil then 
    self._progressBar:stopProgressBar()
  end  

  if self:getDelegate() then 
    if self._LevelupDone == true then 
      self:getDelegate():updateView()
    end 
  end   
end

function  CardLevelUpView:buildList()
  self._itemViewConArray = {}
  self._itemList = display.newNode()
  self._itemList:setAnchorPoint(ccp(0,0))
  self._scrollView = CCScrollView:create()
  self._scrollView:setViewSize(self.sprite_son_bg:getContentSize())
  self._scrollView:setDirection(kCCScrollViewDirectionVertical)
  self._scrollView:setClippingToBounds(true)
  self._scrollView:setBounceable(true)
  self._scrollView:setContainer(self._itemList)
  self._scrollView:setTouchPriority(-256)
  self.sprite_son_bg:addChild(self._scrollView)
  self:updateList()
end

function CardLevelUpView:updateList()

  local itemToShow = {22401001,22401004,22401008,22401009}
  
  
  self._itemViewConArray = {}
  self._itemList:removeAllChildrenWithCleanup(true)
  
  local columnNumber = 4
  local lineNumber = 0
  local totalNumber = #itemToShow
  if totalNumber <= columnNumber then
    lineNumber = 1
  else
    lineNumber = math.ceil(totalNumber/columnNumber)
  end 

  self._scrollView:setTouchEnabled(#itemToShow > columnNumber )
  
  local distanceW = self._scrollView:getViewSize().width/columnNumber
  local distanceH = 45
  local idx = 0
  local itemView = nil 
  for i = lineNumber, 0,-1 do
     for j = 0, columnNumber-1 do
        if idx < totalNumber then
          local configId = itemToShow[idx+1]
          --local item = GameData:Instance():getCurrentPackage():getPropsByConfigId(configId)
          --if item ~= nil then
              local count = 0
              local item = GameData:Instance():getCurrentPackage():getPropsByConfigId(configId)
              if item ~= nil then
                count = item:getCount()
              end
              itemView = ExpItemAddView.new(configId,count)
              itemView:setDelegate(self)
              self._itemList:addChild(itemView)
--              if i == lineNumber and j == 0 then
--                _registNewBirdComponent(111101,itemView)
--              end
              distanceW = (self._scrollView:getViewSize().width - itemView:getContentSize().width*columnNumber)/(columnNumber + 1)
              itemView:setPositionX((itemView:getContentSize().width+distanceW)*j+itemView:getContentSize().width/2+distanceW)
              itemView:setPositionY((itemView:getContentSize().height+distanceH)*i+itemView:getContentSize().height/2-distanceH)
              
              idx = idx + 1
              table.insert(self._itemViewConArray,itemView)
              _registNewBirdComponent(106700 + idx,itemView)
         -- end
        end
     end
  end
  
  echo("columnNumber:",columnNumber,"lineNumber:", lineNumber)
  --set list content size
  if itemView ~= nil then
      self._itemList:setContentSize(CCSizeMake(self._scrollView:getViewSize().width,(itemView:getContentSize().height+distanceH)*lineNumber+itemView:getContentSize().height))
      echo("headListContentSize:",self._itemList:getContentSize().width,self._itemList:getContentSize().height)
      --self._scrollView:reloadData()
       -- scroll to top
      self._itemList:setPosition(ccp(0, self._scrollView:getViewSize().height - self._itemList:getContentSize().height))
      self._scrollView:setContentSize(self._itemList:getContentSize())
      
  end
  
end

function CardLevelUpView:levelUpHandler()
  printf("levelUpHandler")
  _executeNewBird()
  local items = {}
  for key, addedItemView in pairs(self._itemViewConArray) do
    if addedItemView:getSelectedCount() > 0 then
      for i = 1, addedItemView:getSelectedCount() do
       local itemData = GameData:Instance():getCurrentPackage():getPropsByConfigId(addedItemView:getConfigId())
       if itemData ~= nil then
         local item = {}
         item.id = itemData:getId()
         item.count = 1
         table.insert(items,item)
       end
      end
    end
  end
  
  if #items > 0 then
    self._LevelupDone = true
    self._dataInstance:useExpProp(items,self:getCard():getId(),self)
  else
    Toast:showString(self,_tr("select_add_exp_item_first"), ccp(display.cx, display.cy))
  end
end


function CardLevelUpView:closeHandler()
  printf("closeHandler")
  self:removeFromParentAndCleanup(true)
  _executeNewBird()
end

return CardLevelUpView