require("view.Illustrated.CollectionCardView") 
require("model.Illustrated.CollectionCard") 
LotteryPreview = class("LotteryPreview",BaseView)
function LotteryPreview:ctor(type)
  self:setNodeEventEnabled(true)
  self:setTouchEnabled(true)
  self._type = type or 1
  self:addTouchEventListener(handler(self,self.onTouch),false,-256,true)
end

function LotteryPreview:onEnter()
   --color layer
  local layerColor = CCLayerColor:create(ccc4(0,0,0,200), display.width*2.0, display.height*2.0)
  self:addChild(layerColor)
  
  local popSize = CCSizeMake(615,650)
  
  local bg = display.newScale9Sprite("#dianjiangtai_pop_bg.png",display.cx,display.cy,popSize)
  self:addChild(bg)
  self._popupBg = bg
  
  local titleBg = display.newScale9Sprite("#dianjiangtai_title_bg.png",0,0,CCSizeMake(popSize.width,67))
  self:addChild(titleBg)
  titleBg:setPosition(ccp(display.cx,display.cy + popSize.height/2 - titleBg:getContentSize().height/2 ))
  self._titleBg = titleBg
  
  local titleStr = nil
  
  if self._type == 1 then
    titleStr = display.newSprite("#minxindianjiang_name.png")
  else
    titleStr = display.newSprite("#jitiandianjiang_name.png")
  end
  titleBg:addChild(titleStr)
  titleStr:setPosition(titleBg:getContentSize().width/2,titleBg:getContentSize().height/2)

  
  
  local nor = display.newSprite("#dianjiangtai_close.png")
  local sel = display.newSprite("#dianjiangtai_close_sel.png")
  local dis = display.newSprite("#dianjiangtai_close.png")
  local closeBtn = UIHelper.ccMenuWithSprite(nor,sel,dis,
      function()
        self:removeFromParentAndCleanup(true)
      end)
  self:addChild(closeBtn)
  closeBtn:setPositionX(display.cx + popSize.width/2 - nor:getContentSize().width/2 + 10)
  closeBtn:setPositionY(display.cy + popSize.height/2 - nor:getContentSize().height/2 + 10)
  closeBtn:setTouchPriority(-256)
  
  self:buildTabMenus(popSize)
end

function LotteryPreview:onExit()
  
end


function LotteryPreview:buildTabMenus(popSize)
  --init tab menu 
  local menuArray = {
      {"#dianjiang_weiguo_2.png","#dianjiang_weiguo_1.png"},
      {"#dianjiang_shuguo_2.png","#dianjiang_shuguo_1.png"},
      {"#dianjiang_wuguo_2.png","#dianjiang_wuguo_1.png"},
      {"#dianjiang_qunguo_2.png","#dianjiang_qunguo_1.png"}
    }

  local menuSize = CCSizeMake(590, 74)
  local tabMenu = TabControlEx.new(menuSize, nil, -256)
  tabMenu:setDelegate(self)
  self:addChild(tabMenu)

  tabMenu:setMenuArray(menuArray)
  tabMenu:setItemSelectedByIndex(1)
  
  tabMenu:setPosition(display.cx - menuSize.width/2,display.cy + popSize.height/2 - 145)
  self._tabMenu = tabMenu
  
  
  --build scroll view
  self._headList = display.newNode()
  self._headList:setAnchorPoint(ccp(0,0))
  self._scrollView = CCScrollView:create()
  self._scrollView:setViewSize(CCSizeMake(popSize.width,popSize.height - 170))
  self._scrollView:setDirection(kCCScrollViewDirectionVertical)
  self._scrollView:setClippingToBounds(true)
  self._scrollView:setBounceable(true)
  
  self._scrollView:setContainer(self._headList)

  self._popupBg:addChild(self._scrollView)
  self._scrollView:setPosition(ccp(25,25))
  self._scrollView:setTouchPriority(-256)
  
  local drops = GameData:Instance():getItemsWithDropsArray(AllConfig.erniebonus[1].drop_data) --民心卡池
  if self._type == 2 then
    drops = GameData:Instance():getItemsWithDropsArray(AllConfig.guidebonus[1].drop_data)
  end
  local cardsToShow = {}
  for key, drop in pairs(drops) do
    if drop.type == 8 then
      local unitRoot = AllConfig.unit[drop.configId].unit_root
      assert(unitRoot ~= nil)
      if cardsToShow[unitRoot] == nil then
        local maxGrade = AllConfig.unit[drop.configId].card_max_rank + 1
        local card = CollectionCard.new()
        card:setState("HasOwned")
        card:initAttrById(toint(unitRoot.."0"..maxGrade))
        cardsToShow[unitRoot] = card
        
        if AllConfig.ernieshow ~= nil then
          for key, showInfo in pairs(AllConfig.ernieshow) do
            if showInfo.type == self._type and showInfo.card_show == unitRoot then
             cardsToShow[unitRoot].isSimple = true
             break
            end
          end
        end
        
      end
    end
  end
  self._allCards = cardsToShow
  
  self:tabControlOnClick(0)
end

function LotteryPreview:getCardsByCountry(country)
  local cards = {}
  for key, card in pairs(self._allCards) do
  	if card:getCountry() == country then
  	  table.insert(cards,card)
  	end
  end
  return cards
end

function LotteryPreview:showCards(cardsToShow)
    
    self._cardViewConArray = {}
    self._headList:removeAllChildrenWithCleanup(true)
    
    local columnNumber = 5
    local lineNumber = 0
    
    local totalNumber = table.getn(cardsToShow)
    
    local function sortTables(a, b)
       if a:getGrade() == b:getGrade() then
          return a:getConfigId() < b:getConfigId()
       end
       return a:getGrade() > b:getGrade()
    end

    table.sort(cardsToShow,sortTables)
   
    if totalNumber <= columnNumber then
      lineNumber = 1
    else
      lineNumber = math.ceil(totalNumber/columnNumber)
    end 
    
    local distanceX = 0
    local distanceY = 20
    local idx = 0
    local cardView = nil 
    for i = lineNumber, 0,-1 do
       for j = 0, columnNumber-1 do
          if idx < totalNumber then
              local cardModel = cardsToShow[idx+1]
              if cardModel ~= nil then
                cardView = CollectionCardView.new(cardModel)
                if cardModel.isSimple == true then
                  local icon = display.newSprite("#dianjiangzhuanshu.png")
                  cardView:addChild(icon)
                  icon:setPosition(ccp(-34,39))
                end
                
                cardView:setPositionX((cardView:getContentSize().width+distanceX)*j+cardView:getContentSize().width/2+distanceX)
                cardView:setPositionY((cardView:getContentSize().height+distanceY)*i+cardView:getContentSize().height/2-distanceY)
                self._headList:addChild(cardView)
                idx = idx + 1
                table.insert(self._cardViewConArray,cardView)
              end
          end
       end
    end
    
    echo("columnNumber:",columnNumber,"lineNumber:", lineNumber)
    --set list content size
    if cardView ~= nil then
        self._headList:setContentSize(CCSizeMake((cardView:getContentSize().width+distanceX)*(columnNumber-1)+cardView:getContentSize().width,(cardView:getContentSize().height+distanceY)*lineNumber+cardView:getContentSize().height))
        echo("headListContentSize:",self._headList:getContentSize().width,self._headList:getContentSize().height)
         -- scroll to top
        self._headList:setPosition(ccp(0, self._scrollView:getViewSize().height - self._headList:getContentSize().height))
        self._scrollView:setContentSize(self._headList:getContentSize())
        
    end
end

function LotteryPreview:onTouch(event, x,y)
  --echo(event,x,y)
  if event == "began" then
    self._touchStepX = x
    self._touchStepY = y
    return true
  elseif event == "moved" then
  elseif event == "ended" then
    local popSize = self._popupBg:getContentSize()
    if math.abs(self._touchStepX-x) < 20 and math.abs(self._touchStepY-y) < 10
     and y > display.cy - popSize.height/2
     and y < self._tabMenu:getPositionY()
     then
       local targetCard = UIHelper.getTouchedNode(self._cardViewConArray,x,y)
       if targetCard ~= nil then
         echo("tap:",targetCard:getData():getName())
         local cardDetail = OrbitCard.new({configId = targetCard:getData():getConfigId()})
         cardDetail:show()
       end
    end
  end
end

function LotteryPreview:tabControlOnClick(idx)
  local country = idx + 1
  local cardsToShow = self:getCardsByCountry(country)
  self:showCards(cardsToShow)
  
  return true
end

return LotteryPreview