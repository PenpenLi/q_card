require("view.card_levelup.CardExpInfoView")
require("view.component.PopModule") 
PopupUseExpPropView = class("PopupUseExpPropView",PopModule)
function PopupUseExpPropView:ctor(item,dataInstance,size)
  PopupUseExpPropView.super.ctor(self,size)
  self:setNodeEventEnabled(true)
  self._isShowPlaystatesed = true
  self._addSpeed = 1
  self._item = item
  self._dataInstance = dataInstance
  self._maxCount = self._item:getCount()
 -- assert(item ~= nil)
  self:setTouchEnabled(true)
  self:addTouchEventListener(handler(self,self.onTouch),false, -128, true)
end

function PopupUseExpPropView:onEnter()
  PopupUseExpPropView.super.onEnter(self)
--  local pkg = ccbRegisterPkg.new(self)
--  
--  pkg:addProperty("node_container","CCNode")
--  pkg:addProperty("spriteArrow","CCSprite")
--  pkg:addProperty("btnPlaystate","CCMenuItemSprite")
--  pkg:addProperty("btnUnplaystate","CCMenuItemSprite")
--  pkg:addProperty("btnClose","CCMenuItemSprite")
--  
--  pkg:addFunc("playstatedHandler",PopupUseExpPropView.playstatedHandler)
--  pkg:addFunc("unplaystatedHandler",PopupUseExpPropView.unplaystatedHandler)
--  pkg:addFunc("closeHandler",PopupUseExpPropView.closeHandler)
--  
--  --color layer
--  local layerScale = 2
--  local layerColor = CCLayerColor:create(ccc4(0,0,0,185), display.width*layerScale, display.height*layerScale)
--  self:addChild(layerColor)
--  layerColor:setPosition(-(display.width*layerScale - display.width)/2,-(display.height*layerScale - display.height)/2)
--
--  local layer,owner = ccbHelper.load("PopupUseExpProp.ccbi","PopupUseExpProp","CCLayer",pkg)
--  self:addChild(layer)
--  self._ccbLayer = layer 
  
--  _registNewBirdComponent(111100,self.btnClose)
--  _registNewBirdComponent(111201,self.btnPlaystate)
--  _registNewBirdComponent(111202,self.btnUnplaystate)
  
  
--  local pos = ccp(self.spriteArrow:getPositionX(),self.spriteArrow:getPositionY())
--  local anim = CCSequence:createWithTwoActions(CCMoveTo:create(0.2, ccp(pos.x,pos.y + 8)), CCMoveTo:create(0.4, pos))
--  self.spriteArrow:runAction(CCRepeatForever:create(anim))

    
  display.addSpriteFramesWithFile("playstates/preview_playstates.plist", "playstates/preview_playstates.png")
  display.addSpriteFramesWithFile("battle_result/battle_result.plist", "battle_result/battle_result.png")
  local menu1 = {"#previrew_playstates_on.png","#previrew_playstates_on1.png"}
  local menu2 = {"#previrew_playstates_off.png","#previrew_playstates_off1.png"}
  local menuArray = {menu1,menu2}

  self:setMenuArray(menuArray)

  self:buildList()
  
  self._isShowPlaystatesed = true
  local cards = GameData:Instance():getCurrentPackage():getBattleCards()
  self:showCards(cards)
  _executeNewBird()
end

function PopupUseExpPropView:onExit()
  self._dataInstance = nil
  display.removeSpriteFramesWithFile("playstates/preview_playstates.plist", "playstates/preview_playstates.png")
  display.removeSpriteFramesWithFile("battle_result/battle_result.plist", "battle_result/battle_result.png")
end

function PopupUseExpPropView:buildList()
  self._cardViewConArray = {}
  self._menuHeight = 0

  self._headList = display.newNode()
  self._headList:setAnchorPoint(ccp(0,0))
  self._scrollView = CCScrollView:create()
  self._scrollView:setViewSize(self:getCanvasContentSize())
  --self._scrollView:setContentSize(CCSizeMake(570,self:getCanvasContentSize().height - self._menuHeight))
  self._scrollView:setDirection(kCCScrollViewDirectionVertical)
  self._scrollView:setClippingToBounds(true)
  self._scrollView:setBounceable(true)
  
  self._scrollView:setContainer(self._headList)

  self._scrollView:setTouchPriority(-256)
  self:getListContainer():addChild(self._scrollView)

end

function PopupUseExpPropView:tabControlOnClick(idx)
  if idx == 0 then
    self:playstatedHandler()
  elseif idx == 1 then
    self:unplaystatedHandler()
  end
  return true
end

function PopupUseExpPropView:playstatedHandler()
  if self._isShowPlaystatesed == true then
    return
  end
  
  self._isShowPlaystatesed = true
  local cards = GameData:Instance():getCurrentPackage():getBattleCards()
  self:showCards(cards)
end

function PopupUseExpPropView:unplaystatedHandler()
  if self._isShowPlaystatesed == false then
    return
  end
  _executeNewBird()
  self._isShowPlaystatesed = false
  local cards = GameData:Instance():getCurrentPackage():getIdleCards()
  self:showCards(cards)
end

function PopupUseExpPropView:onCloseHandler()
  PopupUseExpPropView.super.onCloseHandler(self)
  if self:getCloseCallBack() ~= nil then 
    self:getCloseCallBack()()
  end 
  _executeNewBird()
end

function PopupUseExpPropView:showCards(cardsToShow)
    
--    self.btnUnplaystate:setEnabled(true)
--    self.btnPlaystate:setEnabled(true)
--    if self._isShowPlaystatesed == true then
--      self.btnPlaystate:setEnabled(false)
--      self.btnUnplaystate:unselected()
--    else
--      self.btnPlaystate:unselected()
--      self.btnUnplaystate:setEnabled(false)
--    end
    
    self._cardViewConArray = {}
    self._headList:removeAllChildrenWithCleanup(true)
    
    local columnNumber = 4
    local lineNumber = 0
    
    local totalNumber = table.getn(cardsToShow)
    
    local function sortTables(a, b)
       if a:getMaxGrade() == b:getMaxGrade() then
          if a:getGrade() == b:getGrade() then
            if a:getLevel() == b:getLevel() then
              return a:getConfigId() < b:getConfigId()
            end
            return a:getLevel() > b:getLevel()
          end
          return a:getGrade() > b:getGrade()
       end
       return a:getMaxGrade() > b:getMaxGrade()
    end
    
    table.sort(cardsToShow,sortTables)

    if totalNumber <= columnNumber then
      lineNumber = 1
    else
      lineNumber = math.ceil(totalNumber/columnNumber)
    end 
    
    local distanceW = self._scrollView:getViewSize().width/columnNumber
    local distanceH = 20
    local idx = 0
    local cardView = nil 
    for i = lineNumber, 0,-1 do
       for j = 0, columnNumber-1 do
          if idx < totalNumber then
            local cardModel = cardsToShow[idx+1]
            if cardModel ~= nil then
                cardView = CardExpInfoView.new(cardModel)
                self._headList:addChild(cardView)
                if i == lineNumber and j == 0 then
                  _registNewBirdComponent(111101,cardView)
                end
                distanceW = (self._scrollView:getViewSize().width - cardView:getContentSize().width*columnNumber)/(columnNumber + 1)
                cardView:setPositionX((cardView:getContentSize().width+distanceW)*j+cardView:getContentSize().width/2+distanceW)
                cardView:setPositionY((cardView:getContentSize().height+distanceH)*i+cardView:getContentSize().height/2-distanceH)
                
                idx = idx + 1
                table.insert(self._cardViewConArray,cardView)
            end
          end
       end
    end
    
    echo("columnNumber:",columnNumber,"lineNumber:", lineNumber)
    --set list content size
    if cardView ~= nil then
        self._headList:setContentSize(CCSizeMake(self._scrollView:getViewSize().width,(cardView:getContentSize().height+distanceH)*lineNumber+cardView:getContentSize().height))
        echo("headListContentSize:",self._headList:getContentSize().width,self._headList:getContentSize().height)
        --self._scrollView:reloadData()
         -- scroll to top
        self._headList:setPosition(ccp(0, self._scrollView:getViewSize().height - self._headList:getContentSize().height))
        self._scrollView:setContentSize(self._headList:getContentSize())
        
    end
end

function PopupUseExpPropView:updateCardView(cardId)
  local item = GameData:Instance():getCurrentPackage():getPropsByConfigId(self._item:getConfigId())
  if item == nil then
    self._maxCount = 0
  else
    self._maxCount = item:getCount()
  end
  
  print("self._maxCount:",self._maxCount)

  local cardView = self:getCardViewById(cardId)
  if cardView ~= nil then
    cardView:updateView()
  end
end

function PopupUseExpPropView:getCardViewById(cardId)
  local mCardView = nil
  for key, cardView in pairs(self._cardViewConArray) do
    if cardView:getCard():getId() == cardId then
      mCardView = cardView
      break
    end
  end
  return mCardView
end


function PopupUseExpPropView:addCount(targetCard)
  
  local playerLevel = GameData:Instance():getCurrentPlayer():getLevel()
  local card = targetCard:getCard()
  local targetLevel = math.min(card:getMaxLevel(),playerLevel)
  local configId = self._item:getConfigId()
  local eachExp =  AllConfig.item[configId].bonus[3]
  local levelupExp,totalExp = card:getExpByLeve(targetLevel)
  print("each experience:",eachExp)
  print("card:getExperience():",card:getExperience())
  local maxLevelCount = math.ceil((totalExp - card:getExperience())/eachExp)
  print(maxLevelCount,self._maxCount)
  local max = math.min(maxLevelCount,self._maxCount)
  self._addSpeed = math.ceil(self._addSpeed*1.2)
  if self._addSpeed > max then
    self._addSpeed = max
  end
  
  if self._addSpeed > 0 then
    targetCard:setCountString("+"..self._addSpeed)
  end
end

function PopupUseExpPropView:onTouch(event, x,y)
  --echo(event,x,y)
  if event == "began" then
    self._touchStepX = x
    self._touchStepY = y
    self:stopAllActions()
    self._startCard = nil
    self._startCardId = -1
    
    local targetCard = UIHelper.getTouchedNode(self._cardViewConArray,x,y)
    if targetCard ~= nil then
       targetCard:setHightLighted(true)
       
       if targetCard:getIsPlayingAnim() == true then
        print("lving")
        return true
       end
       self._addSpeed = 1
       if targetCard:getCard():getLevel() >= targetCard:getCard():getMaxLevel() then
        self._addSpeed = 0
       end
       
       --targetCard:setCountString("+"..self._addSpeed)
       self._addTimer = self:schedule(function() self:addCount(targetCard) end,0.25)
       self._startCardId = targetCard:getCard():getId()
       self._startCard = targetCard
       
    end
    return true
  elseif event == "moved" then
    if math.abs(self._touchStepX-x) > 25 or math.abs(self._touchStepY-y) > 25 then
      self:stopAllActions()
      if self._startCard ~= nil then
        self._startCard:setCountString("")
      end
    end
  elseif event == "ended" then
    self:stopAllActions()
    if self._startCard ~= nil then
      self._startCard:setCountString("")
    end
    
    for key, cardView in pairs(self._cardViewConArray) do
      cardView:setHightLighted(false)
    end
    
    if math.abs(self._touchStepX-x) < 30 and math.abs(self._touchStepY-y) < 30 then
       local targetCard = UIHelper.getTouchedNode(self._cardViewConArray,x,y)
       if targetCard ~= nil and self._startCardId == targetCard:getCard():getId() then
          echo("tap:",targetCard:getCard():getName())
          --targetCard:setCountString("+"..self._addSpeed)
          if self._addSpeed > 0 then
            if self._addSpeed > self._maxCount then
             self._addSpeed = self._maxCount
            end
            print("use count:",self._addSpeed)
            
            local items = {}
            for i = 1, self._addSpeed do
               local item = {}
               item.id = self._item:getId()
               item.count = 1
               table.insert(items,item)
            end
            
            if #items > 0 then
              self._dataInstance:useExpProp(items,targetCard:getCard():getId(),self)
            else
              Toast:showString(self,_tr("not enough material"), ccp(display.cx, display.cy))
            end
          else
            local str = ""
            if targetCard:getCard():getLevel() >= targetCard:getCard():getMaxLevel() then
              if targetCard:getCard():getGrade() < targetCard:getCard():getMaxGrade() then
                str = "等级已到达上限，请先提升星级"
              else
                str = "等级已到达上限"
              end
            else
              
              if self._maxCount > 0 then
                str = _tr("can_not_beyond_player_lv")
              else
                str = _tr("not enough material")
              end
            end
           
            Toast:showString(self,str, ccp(display.cx, display.cy))
          end
            _executeNewBird()
       end
    end
  end
end

function PopupUseExpPropView:setCloseCallBack(func)
  self._closeCallback = func
end 

function PopupUseExpPropView:getCloseCallBack()
  return self._closeCallback
end 


return PopupUseExpPropView