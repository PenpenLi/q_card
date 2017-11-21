
require("view.component.ViewWithEave")
require("view.component.Loading")
require("view.component.PopupView")
require("view.component.MiddleCardHeadView")

DismantleView = class("DismantleView", ViewWithEave)



function DismantleView:ctor()
  DismantleView.super.ctor(self)
  --self:setTabControlEnabled(false)
 
  --1. load levelup view ccbi
  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("selectCallback",DismantleView.selectCallback)
  pkg:addFunc("startDismantleCallback",DismantleView.startDismantleCallback)
  pkg:addFunc("bn_cailiao1",DismantleView.touchCailiao1)
  pkg:addFunc("bn_cailiao2",DismantleView.touchCailiao2)
  pkg:addFunc("bn_cailiao3",DismantleView.touchCailiao3)
  pkg:addFunc("bn_cailiao4",DismantleView.touchCailiao4)  

  --material info
  
  pkg:addProperty("node_cailiao","CCNode")
  pkg:addProperty("sprite_cailiao1","CCSprite")
  pkg:addProperty("sprite_cailiao2","CCSprite")
  pkg:addProperty("sprite_cailiao3","CCSprite")
  pkg:addProperty("sprite_cailiao4","CCSprite")
  pkg:addProperty("label_m1","CCLabelTTF")
  pkg:addProperty("label_m2","CCLabelTTF")
  pkg:addProperty("label_m3","CCLabelTTF")
  pkg:addProperty("label_m4","CCLabelTTF")
  pkg:addProperty("label_money","CCLabelTTF")

  --card node info1
  pkg:addProperty("node_info1","CCNode")
  pkg:addProperty("sprite_select","CCSprite")

  --card node info2
  pkg:addProperty("node_info2","CCNode")
  pkg:addProperty("label_selected_num","CCLabelTTF")
  -- pkg:addProperty("label_readme","CCLabelTTF")
  pkg:addProperty("label_cost","CCLabelTTF")
  pkg:addProperty("page_index1","CCSprite")
  pkg:addProperty("page_index2","CCSprite")
  pkg:addProperty("page_index3","CCSprite")
  pkg:addProperty("page_index4","CCSprite")
  pkg:addProperty("page_index5","CCSprite")
  pkg:addProperty("page_index6","CCSprite")
  pkg:addProperty("page_index7","CCSprite")
  pkg:addProperty("page_index8","CCSprite")
  pkg:addProperty("page_index9","CCSprite")
  pkg:addProperty("page_index10","CCSprite")
  pkg:addProperty("sprite_indexHighlight","CCSprite")
  pkg:addProperty("node_container2","CCNode")

  pkg:addProperty("bn_startDismantle","CCControlButton")

  local layer,owner = ccbHelper.load("DismantleView.ccbi","DismantleViewCCB","CCLayer",pkg)
  self:getEaveView():getNodeContainer():addChild(layer)
end

function DismantleView:init()
  echo("---DismantleView:init---")

  if self:getDelegate():getTabMenuVisible() == false then 
    self:setTitleTextureName("lv_title_ronglian.png")
    self:setTabControlEnabled(false)
  else 
    self:setTitleTextureName("cardlvup-image-paibian.png")
    local menuArray = {
        {"#bn_levelup_0.png","#bn_levelup_1.png"},
        {"#bn_surmount_0.png","#bn_surmount_1.png"},
        {"#bn_dismantle_0.png","#bn_dismantle_1.png"},
        {"#bn_skillUp0.png","#bn_skillUp1.png"}
      }
    self:setMenuArray(menuArray)
    self:getTabMenu():setItemSelectedByIndex(3)
  end 
  
  self.totalCells = 1
  self.curPage = -1
  self.cardsArray = {}
  self.cellWidth = 0
  self.cellHeight = 0
  self.totalCost = 0

  self.showEmptyList = false 

  -- self.label_readme:setString(_tr("dismantle_info"))
  self.label_cost:setString(_tr("cost"))

  net.registMsgCallback(PbMsgId.SmeltCardResult, self, DismantleView.SmeltCardResult)

  self:setIsDismantling(false)

  
  self.spriteArray = {self.sprite_cailiao1, self.sprite_cailiao2, self.sprite_cailiao3, self.sprite_cailiao4, 
                      self.label_m1, self.label_m2,self.label_m3,self.label_m4}

  self.eatCardArray = self:getDelegate():dataInstance():getDismantleCards()
  if table.getn(self.eatCardArray) < 1 then 

    local action = CCSequence:createWithTwoActions(CCFadeTo:create(1.0, 100),CCFadeTo:create(1.0, 255))
    self.sprite_select:runAction(CCRepeatForever:create(action))

    self:showCardInfo(0, nil)
    self:getDelegate():dataInstance():resetSelectedCards()
  else 
    self:registerTouchEvent()
    self:showCardInfo(1, self.eatCardArray)
  end
end 

function DismantleView:onEnter()
  echo("---DismantleView:onEnter---")
  self:init()
end 

function DismantleView:onExit()
  echo("---DismantleView:onExit---")
  net.unregistAllCallback(self)
end 

function DismantleView:onHelpHandler()
  echo("helpCallback")
  local help = HelpView.new()
  help:addHelpBox(1011)
  help:addHelpItem(1012, self.node_container2, ccp(240,0), ArrowDir.RightUp)
  help:addHelpItem(1013, self.bn_startDismantle, ccp(30,20), ArrowDir.RightDown)
  self:getDelegate():getScene():addChild(help, 1000)
end

function DismantleView:onBackHandler()
  echo("DismantleView:backCallback")
  DismantleView.super:onBackHandler()
  
  self:getDelegate():goBackView()
end

function DismantleView:tabControlOnClick(idx)
  _playSnd(SFX_CLICK)

  local result = true

  if idx == 0 then
    result = self:getDelegate():displayLevelUpView()
  elseif idx == 1 then
    result = self:getDelegate():displaySurmountView()
  elseif idx == 2 then
  elseif idx == 3 then
    result = self:getDelegate():displaySkillView()
  end

  return result
end

function DismantleView:selectCallback()
  echo("DismantleView:selectCallback")
  _playSnd(SFX_CLICK)  
  if self:getIsDismantling() == true then
    return
  end
  self:getDelegate():disPlayCardListForDismantle()
end

function DismantleView:registerTouchEvent()
    local function onTouch(eventType, x, y)
        if eventType == "began" then
          self.touch_x = x
          self.touch_y = y
          return false
        end
    end
  
  self:addTouchEventListener(onTouch)
  self:setTouchEnabled(true)
end

function DismantleView:playDismantleAnim()
  local duration_1 = 0
  local duration_2 = 0

  local function playGainedItemsAnim()
    if self.gaindMeterials ~= nil then 
        local offsetY = (table.getn(self.gaindMeterials) - 1) * 50
        for k,v in pairs(self.gaindMeterials) do 
          local numStr = string.format("+%d", v.count)                                                                   
          offsetY = offsetY-90
          Toast:showIconNumWithDelay(numStr, v.iconId, v.iType, v.configId, ccp(display.width/2, display.height*0.4 + offsetY), 0.5*(k-1))
        end
      end
      
      self.eatCardArray = {}
      self.showEmptyList = false

      self:showCardInfo(0, nil) 
      self:setIsDismantling(false)
      self:removeMaskLayer()
  end 


  --step 2. play meterials anim
  local function playMergeAnim()
    local meteNum  = math.min(4, table.getn(self.gaindMeterials))
    for i=1, meteNum do 
      local anim,offsetX,offsetY,duration = _res(5020101)
      if anim ~= nil then  
        duration_2 = duration

        local pos = ccp(self.spriteArray[i]:getPosition())
        anim:setPosition(pos)
        self.spriteArray[i]:getParent():addChild(anim)
        anim:getAnimation():play("default")
        self:performWithDelay(function ()
                                anim:removeFromParentAndCleanup(true)
                              end, duration)
      end
    end

    if duration_2 > 0 then 
      self:performWithDelay(playGainedItemsAnim, duration_2)
    else 
      self:removeMaskLayer()
      playGainedItemsAnim()
    end     
  end


  --step 1. play eat cards anim
    local curPageCardsNum = table.getn(self.eatCardArray)
    local maxNumPerCell = self.row*self.col
    if self.curPage > 1 then 
      curPageCardsNum = curPageCardsNum - (self.curPage-1)*maxNumPerCell
    end
    curPageCardsNum = math.min(maxNumPerCell, curPageCardsNum)

    for i=1, curPageCardsNum do
      local anim,offsetX,offsetY,duration = _res(5020147)
      if anim ~= nil then
        duration_1 = duration

        local headWidth = self.cellWidth/self.col
        local headHeight = self.cellHeight/self.row 
        local pos_x = (i-1)%self.col*headWidth + headWidth/2 - 10
        local pos_y = (self.row - 1 - math.floor((i-1)/self.col)) * headHeight + headHeight/2 - 15
        anim:setPosition(ccp(pos_x, pos_y))
        self.node_container2:addChild(anim)
        anim:getAnimation():play("default")
        self:performWithDelay(function ()
                                anim:removeFromParentAndCleanup(true)
                              end, duration)
      end
    end  

    if duration_1 > 0 then 
      self:addMaskLayer()
      self:performWithDelay(function ()
                              playMergeAnim()

                              self.showEmptyList = true 
                              self.tableView:updateCellAtIndex(self.curPage-1)                             
                              -- self:showCardsList(self.eatCardArray)
                              self:getDelegate():dataInstance():resetSelectedCards()
                            end, 
                            duration_1)
    else 
      playGainedItemsAnim()
    end 
end 


function DismantleView:SmeltCardResult(action,msgId,msg)
  echo("SmeltCardResult: ",msg.state)

--  if self.loading ~= nil then
--    self.loading:remove()
--    self.loading = nil
--  end 
  _hideLoading()

  if msg.state ~= "Ok" then 
    self:setIsDismantling(false)
  end

  if msg.state == "Ok" then 
    self.gaindMeterials = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client_sync)
    self:playDismantleAnim()

    -- self.eatCardArray = {}
    -- self:showCardInfo(0, nil)

    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
    self:getDelegate():dataInstance():setDismantleCards(nil)

  elseif msg.state == "NeedMoreBagCell" then
    Toast:showString(self, _tr("card bag is full"), ccp(display.width/2, display.height*0.4))
  elseif msg.state == "NoSuchCardId" then
    Toast:showString(self, _tr("no such card"), ccp(display.width/2, display.height*0.4))
  elseif msg.state == "IsActiveCard" then
    Toast:showString(self, _tr("battle_card_cannot_dismantled"), ccp(display.width/2, display.height*0.4))
  elseif msg.state == "HasEquipmentInCard" then
    Toast:showString(self, _tr("equip_card_cannot_dismantled"), ccp(display.width/2, display.height*0.4))
  elseif msg.state == "NotEnoughCurrency" then
    Toast:showString(self, _tr("not enough coin"), ccp(display.width/2, display.height*0.4))
  elseif msg.state == "IsMineCard" then
    Toast:showString(self, _tr("working_card_cannot_dismanted"), ccp(display.width/2, display.height*0.4))   
  elseif msg.state == "ErrorExpCard" then
    Toast:showString(self, _tr("exp_card_cannot_dismantled"), ccp(display.width/2, display.height*0.4))      
  else
    Toast:showString(self, msg.state, ccp(display.width/2, display.height*0.4))
  end
end

function DismantleView:startDismantleCallback()
  echo("=== startSurmountCallback ====")
  _playSnd(SFX_CLICK)
  if self:getIsDismantling() == true then
    return
  end
  local isEnough = GameData:Instance():getCurrentPackage():checkItemBagEnoughSpace(1)
  if isEnough == false then 
    -- Toast:showString(self, "行囊背包已满", ccp(display.width/2, display.height*0.4))
    local pop = PopupView:createTextPopupWithPath({leftNorBtn = "button-nor-zhengli.png",
                                                   leftSelBtn = "button-sel-zhengli.png",
                                                   text = _tr("bag is full,clean up?"),
                                                   leftCallBack = function()
                                                        self:getDelegate():goToItemView()
                                                  end})
    self:getDelegate():getScene():addChild(pop,100)
    return
  end

  local idArray, needToPop = self:getDelegate():dataInstance():getDismantleCardIdArray()

  if table.getn(idArray) >= 1 then 
    local coin = GameData:Instance():getCurrentPlayer():getCoin()
    --local totalCost = self:getDelegate():dataInstance():getTotalDismantleCost(idArray)
    if self.totalCost > coin then 
      Toast:showString(self, _tr("not enough coin"), ccp(display.width/2, display.height*0.4))
      return 
    end

    local function sendEatCardsMsg()
      echo(" sendEatCardsMsg ")
      _showLoading()
      local data = PbRegist.pack(PbMsgId.SmeltCard, {card_id=idArray})
      net.sendMessage(PbMsgId.SmeltCard, data)

      --show waiting
      --self.loading = Loading:show() 
      self:setIsDismantling(true)
    end 

    local function popOkCallback()
      sendEatCardsMsg()
    end

    if needToPop == true then 
        local pop = PopupView:createTextPopup(_tr("be_sure_dismantled_3_grade_card?"), popOkCallback)
        self:addChild(pop)
    else 
      sendEatCardsMsg()
    end
  else 
    Toast:showString(self, _tr("please select card"), ccp(display.width/2, display.height*0.4))
  end
end

function DismantleView:showCardInfo(index, cardTable)
  for i=1, 4 do
    -- self.spriteArray[i]:removeAllChildrenWithCleanup(true)
    -- self.node_cailiao:removeAllChildrenWithCleanup(true)
    local child = self.spriteArray[i]:getParent():getChildByTag(100+i)
    if child ~= nil then 
      self.spriteArray[i]:getParent():removeChild(child, true)
    end 
    self.spriteArray[4+i]:setString("")
  end

  self.materialArray = nil
  self.totalCost = self:getDelegate():dataInstance():getTotalDismantleCost(cardTable)
  
  if index == 0 then 
    self.node_info1:setVisible(true)
    self.node_info2:setVisible(false)
    self.label_money:setString("0")
  elseif index == 1 then
    self.node_info1:setVisible(false)
    self.node_info2:setVisible(true)
    self.label_money:setString(NumberHelp.toString(self.totalCost,1))
    if self.eatCardArray ~= nil then 
      local eatCardsNum = table.getn(self.eatCardArray)
      self.label_selected_num:setString(string.format("%d",eatCardsNum))
      
      local index = 0
      self.materialArray, self.matCount = self:getDelegate():dataInstance():getDismantleMaterials(cardTable)
      for k, v in pairs(self.materialArray) do 
        index = index + 1

        if index <= 4 then
          echo("====type, configid=", v.itype, v.configId)
          local sprite = GameData:Instance():getCurrentPackage():getItemSprite(nil, v.itype, v.configId, 1)
          if sprite ~= nil then 
            self.spriteArray[4+index]:setString(string.format("+%d", v.count))
            if v.rate < 10000 then --rate = v[2]/10000
              local rateSprite = CCSprite:createWithSpriteFrameName("cardlvup-image-gailvhuode.png")
              sprite:addChild(rateSprite)
              --twinkle action
              local seq = CCSequence:createWithTwoActions(CCFadeIn:create(1.0),CCFadeOut:create(1.0))
              rateSprite:runAction(CCRepeatForever:create(seq))
            end
          end 

          sprite:setPosition(ccp(self.spriteArray[index]:getPosition()))
          sprite:setTag(100+index)
          self.spriteArray[index]:getParent():addChild(sprite)
        end
      end
    else
      self.label_selected_num:setString("0")
    end
    self:showCardsList(cardTable)
  end
end


function DismantleView:setPageHighlightIndex(viewOffsetX)

  if self.totalCells ~= nil then
    local index = -math.floor( (viewOffsetX+self.cellWidth*0.66)/self.cellWidth ) + 1
    index = math.min(self.totalCells, math.max(1, index))

    if self.curPage ~= index then 
      self.curPage = index
      local idxWidth = math.max(20, self.page_index1:getContentSize().width)
      local pos_x = self.node_container2:getPositionX() + (self.node_container2:getContentSize().width - self.totalCells * idxWidth)/2

      for i=1, 10 do 
        if i<= self.totalCells then 
          self.pageIdxArray[i]:setVisible(true)
          self.pageIdxArray[i]:setPositionX(pos_x + (i-1)*idxWidth)
        else 
          self.pageIdxArray[i]:setVisible(false)
        end
      end

      self.sprite_indexHighlight:setPositionX(pos_x+(index-1)*idxWidth)
    end
  end 
end 

function DismantleView:showCardsList(cardTable)
  
  local function scrollViewDidScroll(view)  
    local offset_x = view:getContentOffset().x
    self:setPageHighlightIndex(offset_x)
  end
  
  local function getIndexAndPos(cellIdx, touchPoint, viewOffsetX)
    --convert to relative position in current page
    local pos_x = touchPoint.x - viewOffsetX - cellIdx*self.cellWidth
    local pos_y = touchPoint.y
    
    local itemWidth = self.cellWidth/self.col
    local itemHeight = self.cellHeight/self.row

    --row and col for current item, and the index of row is from top to bottom 
    local col = math.floor(pos_x/itemWidth)
    local row = self.row - math.floor(pos_y/itemHeight) - 1

    --the index of data array
    local index = cellIdx*(self.row*self.col) + row*self.col + col + 1

    --current item' center position 
    local pos = ccp(col*itemWidth + itemWidth/2, (self.row-row-1)*itemHeight + itemHeight/2)
    echo("index, row, col=", index, row, col)
    return index, pos
  end

  local function tableCellTouched(tableview,cell)
    local cellIndex = cell:getIdx()
    local touchPos = tolua.cast(self.node_container2:convertToNodeSpace(ccp(self.touch_x, self.touch_y)), "CCPoint")
    local offsetX = tableview:getContentOffset().x
    local itemIdx, itemPos = getIndexAndPos(cellIndex, touchPos, offsetX)
    if itemIdx > table.getn(cardTable) then
      echo("invalid intemIdx")
      return
    end

    -- local card = cardTable[itemIdx]
    -- local configId = card:getConfigId()
    -- TipsInfo:showTip(nil, configId, card)
  end
  
  local function cellSizeForTable(tableview,idx)
    return self.cellHeight,self.cellWidth
  end
  
  local function tableCellAtIndex(tableview, idx)
    echo("cell index= ", idx)
    --local cellBgZoomFactor = 1
    
    local maxNumPerCell = self.row * self.col 
    local curPageCardsNum = 0
    if cardTable ~= nil then 
      curPageCardsNum = table.getn(cardTable)
      if idx > 0 then 
        curPageCardsNum = curPageCardsNum - idx*maxNumPerCell
      end
      curPageCardsNum = math.min(maxNumPerCell, curPageCardsNum)
    end

    local cell = tableview:dequeueCell()
    if nil == cell then
      cell = CCTableViewCell:new()
    else 
      cell:removeAllChildrenWithCleanup(true)
    end


    --show cardHeader
    local headWidth = self.cellWidth/self.col
    local headHeight = self.cellHeight/self.row 
    local bg = CCSprite:createWithSpriteFrameName("card_bg.png")
    local bgSize = bg:getContentSize()
    local menu = nil 
    if curPageCardsNum < maxNumPerCell then 
      --breadth effect
      local selectImg = CCSprite:createWithSpriteFrameName("select_hero2.png")
      selectImg:setPosition(ccp(bgSize.width/2, bgSize.height/2))
      bg:addChild(selectImg, 1)
      local action = CCSequence:createWithTwoActions(CCFadeTo:create(1.0, 100),CCFadeTo:create(1.0, 255))
      selectImg:runAction(CCRepeatForever:create(action))

      menu = CCMenu:create()
      local menuItem = CCMenuItemSprite:create(bg, nil, nil)
      menuItem:registerScriptTapHandler(handler(self, DismantleView.selectCallback))
      menuItem:setPosition(ccp(bgSize.width/2, bgSize.height/2))
      menu:addChild(menuItem)
    end 

    --show heads
    if curPageCardsNum > 0 then 
      for i = 1, curPageCardsNum + 1 do 
        local node = nil
        if i <= curPageCardsNum then 
          if self.showEmptyList == true then 
            node = CCSprite:createWithSpriteFrameName("card_bg.png")
            node:setAnchorPoint(ccp(0,0))
          else 
            node = MiddleCardHeadView.new()
            node:setCard({card = cardTable[i+maxNumPerCell*idx]})
            -- node:setCard(cardTable[i+maxNumPerCell*idx])
            -- node:setTag(i+maxNumPerCell*idx)
            local scale = bg:getContentSize().width/node:getContentSize().width
            node:setScale(scale)
          end
        else 
          node = menu
        end 

        if node ~= nil then 
          local pos_x = (i-1)%self.col*headWidth -- + headWidth/2
          local pos_y = (self.row - 1 - math.floor((i-1)/self.col)) * headHeight -- + headHeight/2
          node:setPosition(ccp(pos_x, pos_y))
          cell:addChild(node)
        end 
      end
    else 
      if menu ~= nil then 
        -- menu:setPosition(ccp(headWidth/2, (self.row-1)*headHeight+ headHeight/2))
        menu:setPosition(ccp(0, (self.row-1)*headHeight))       
        cell:addChild(menu)
      end
    end


    return cell
  end
  
  local function numberOfCellsInTableView(tableview)
    return self.totalCells
  end



  --init tableview
  if cardTable == nil then 
    echo("empty card table !!")
    return
  end

  local viewSize = self.node_container2:getContentSize()
  self.col = 4 
  self.row = 2
  self.cellWidth = viewSize.width 
  self.cellHeight = viewSize.height
  local n = table.getn(cardTable)
  self.totalCells = math.max(1, math.ceil((n+1)/(self.row*self.col)))

  self.pageIdxArray = {self.page_index1, self.page_index2, self.page_index3, self.page_index4, self.page_index5,
                       self.page_index6, self.page_index7, self.page_index8, self.page_index9, self.page_index10}

  self:setPageHighlightIndex(0) 
                        

  echo("remove old tableview")
  self.showEmptyList = false
  self.node_container2:removeAllChildrenWithCleanup(true)

  self.tableView = CCTableView:create(viewSize)
  self.tableView:setDirection(kCCScrollViewDirectionHorizontal)
  -- tableView:setBounceable(false)
  self.node_container2:addChild(self.tableView)

  --registerScriptHandler functions must be before the reloadData function
  self.tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  self.tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  self.tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  self.tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  self.tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  self.tableView:reloadData()
end


function DismantleView:setIsDismantling(isDismantling)

  self.isDismantling = isDismantling
  echo("setIsDismantling:", isDismantling)

  local scheduler = CCDirector:sharedDirector():getScheduler()
  if self.scheduler ~= nil then 
    scheduler:unscheduleScriptEntry(self.scheduler)
    self.scheduler = nil
  end

  local function timerCallback(dt)
    echo("timer expire....")
    if self.scheduler ~= nil then
      scheduler:unscheduleScriptEntry(self.scheduler)
      self.scheduler = nil
    end
  end

  --strat timer
  if self.isDismantling == true then
    self.scheduler = scheduler:scheduleScriptFunc(timerCallback, 60, false)
  end
end

function DismantleView:getIsDismantling()
  return self.isDismantling
end

function DismantleView:touchCailiao1()
  if self.materialArray == nil then 
    return 
  end

  local index = 0
  for k, v in pairs(self.materialArray) do 
    index = index + 1
    if index == 1 then 
      TipsInfo:showTip(self.sprite_cailiao1, v.configId)
      return
    end 
  end
end

function DismantleView:touchCailiao2()
  if self.materialArray == nil then 
    return 
  end

  local index = 0
  for k, v in pairs(self.materialArray) do 
    index = index + 1
    if index == 2 then 
      TipsInfo:showTip(self.sprite_cailiao2, v.configId)
      return
    end 
  end
end

function DismantleView:touchCailiao3()
  if self.materialArray == nil then 
    return 
  end

  local index = 0
  for k, v in pairs(self.materialArray) do 
    index = index + 1
    if index == 3 then 
      TipsInfo:showTip(self.sprite_cailiao3, v.configId)
      return
    end 
  end
end

function DismantleView:touchCailiao4()
  if self.materialArray == nil then 
    return 
  end

  local index = 0
  for k, v in pairs(self.materialArray) do 
    index = index + 1
    if index == 4 then 
      TipsInfo:showTip(self.sprite_cailiao4, v.configId)
      return
    end 
  end
end

function DismantleView:addMaskLayer()
  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
  end 

  self.maskLayer = Mask.new({opacity=0, priority = -1000})
  self:addChild(self.maskLayer)
end 

function DismantleView:removeMaskLayer()
  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
    self.maskLayer = nil 
  end 
end 
