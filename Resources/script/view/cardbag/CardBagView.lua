
require("view.play_states.PlayStatesCardListItem")
require("view.play_states.PlayStatesEquipmentListItem")
require("view.component.ViewWithEave")
require("view.component.PopupView")
require("view.component.Toast")

CardBagView = class("CardBagView", ViewWithEave)

CardBgalistType = enum({"NONE", "CARDS","EQUIPMENTS", "CARDS_SALE", "EQUIPMENTS_SALE"})

function CardBagView:ctor()
  CardBagView.super.ctor(self)
  --self:setTabControlEnabled(false)
  self:setScrollBgVisible(false)
  --1. load levelup view ccbi
  local pkg = ccbRegisterPkg.new(self)
  --pkg:addProperty("node_tabMenu","CCNode")
  pkg:addProperty("node_fileter","CCNode")
  pkg:addProperty("node_listContainer","CCNode")
  pkg:addProperty("node_bottom","CCNode")
  pkg:addProperty("node_sale","CCNode")

  pkg:addProperty("bn_card","CCControlButton")
  pkg:addProperty("bn_equipment","CCControlButton")
  pkg:addProperty("bn_saleCard","CCControlButton")
  pkg:addProperty("bn_saleEquipment","CCControlButton")
  pkg:addProperty("bn_confirm","CCControlButton")

  pkg:addProperty("label_preFilterType","CCLabelTTF")
  pkg:addProperty("label_filterType","CCLabelTTF")
  pkg:addProperty("label_selectAll","CCLabelTTF")
  pkg:addProperty("label_pricePre","CCLabelTTF")
  pkg:addProperty("label_salePrice","CCLabelTTF")
  pkg:addProperty("label_selectedNum","CCLabelTTF") 
  pkg:addProperty("label_tipCount","CCLabelTTF")
  pkg:addProperty("selectAllIcon","CCSprite") 
  
  pkg:addFunc("filterCallback",CardBagView.filterCallback)
  pkg:addFunc("confirmCallback",CardBagView.confirmCallback)
  pkg:addFunc("selectAllCallback",CardBagView.selectAllCallback)
  pkg:addFunc("saleCallback",CardBagView.saleCallback)

  local layer,owner = ccbHelper.load("CardBagView.ccbi","CardBagViewCCB","CCLayer",pkg)
  self:addChild(layer)

  --manul loading plist file
  CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("img/cardbag/cardbag.plist")

  self:setTitleTextureName("cardinventory-image-paibian.png")

  self:getEaveView().btnHelp:setVisible(false)
end

function CardBagView:init()
  self.label_preFilterType:setString(_tr("filter type"))
  self.label_selectAll:setString(_tr("select all"))
  self.label_pricePre:setString(_tr("sale price"))

  self.node_bottom:setVisible(false)
  self.selectAllIcon:setVisible(false)


  self:registerTouchEvent()

  self.bn_confirm:setTouchPriority(-200)

  local package = GameData:Instance():getCurrentPackage()
  self.allCardsArray = package:getAllCards()
  self.idleCardsArray = package:getIdleCardsExt()
  self.allEquipmentArray = package:getAllEquipments()
  self.idleEquipmentArray = package:getIdleEquipments()

  if self.allCardsArray == nil then 
    self.allCardsArray = {}
  end
  if self.idleCardsArray == nil then 
    self.idleCardsArray = {}
  end  
  if self.allEquipmentArray == nil then 
    self.allEquipmentArray = {}
  end  
  if self.idleEquipmentArray == nil then 
    self.idleEquipmentArray = {}
  end  

  self.dataArray = {}

  for i=1,table.getn(self.idleCardsArray) do
    self.idleCardsArray[i].isSelected = false
  end


  --sort by default
  package:sortCards(self.allCardsArray, SortType.LEVEL_UP, SortType.RARE_DOWN)
  package:sortCards(self.idleCardsArray, SortType.LEVEL_UP, SortType.RARE_UP)
  package:sortEquipments(self.allEquipmentArray)
  package:sortEquipments(self.idleEquipmentArray)

  self.cellWidth = 640
  self.cellHeight = 157
  self.selectedCount = 0
  self.totalSaledMoney = 0
  self.sellArray = {}

  UIHelper.setIsNeedScrollList(true)
  if self:getIsFirstEntryEquipView() == true then 
    self:showListView(self.allEquipmentArray, CardBgalistType.EQUIPMENTS)
  else 
    self:showListView(self.allCardsArray, CardBgalistType.CARDS)
  end
  --show tab menu
  self:showMenuByState(self.curListType)
end


function CardBagView:onEnter()
  echo("---CardBagView:onEnter---")
  net.registMsgCallback(PbMsgId.SellCardToSystemResult, self, CardBagView.sellToSystemCallback)
  net.registMsgCallback(PbMsgId.SellEquipmentToSystemResult, self, CardBagView.sellToSystemCallback)

  self:init()
end

function CardBagView:onExit()
  echo("---CardBagView:onExit---")
  CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("img/cardbag/cardbag.plist")

  net.unregistAllCallback(self)
end 

function CardBagView:setIsFirstEntryEquipView(flag)
  self._firstEntryEquipView = flag
end

function CardBagView:getIsFirstEntryEquipView()
  return self._firstEntryEquipView
end

function CardBagView:pointIsInListRect(touch_x, touch_y)

  local isInRect = false 

  local x, y = self.node_listContainer:getPosition()
  local width = self.node_listContainer:getContentSize().width
  local height = self.node_listContainer:getContentSize().height

  if touch_x > x and touch_x < x+width and touch_y > y and touch_y < y+height then
    isInRect = true
  end

  self:setListButtonEnable(isInRect)

  return isInRect
end

function CardBagView:setListButtonEnable(isEnable)
  self._isBnEnable = isEnable
end 

function CardBagView:getListButtonEnable()
  return self._isBnEnable
end 

function CardBagView:onHelpHandler()
  echo("helpCallback")

  local helpView = HelpView.new(1040)
  GameData:Instance():getCurrentScene():addChild(helpView)
  CardBagView.super:onHelpHandler()
end

function CardBagView:onBackHandler()
  echo("CardBagView:backCallback:", self.dataArray)
  CardBagView.super:onBackHandler()

  --reset data
  self.selectedCount = 0
  if self.dataArray == nil then 
    for i=1, table.getn(self.dataArray) do 
      self.dataArray[i].isSelected = false
    end

    self.dataArray = {}
  end

  UIHelper.setIsNeedScrollList(true)
  if self.curListType == CardBgalistType.CARDS_SALE then 
    self:showListView(self.allCardsArray, CardBgalistType.CARDS)
    self:showMenuByState(self.curListType)
  elseif self.curListType == CardBgalistType.EQUIPMENTS_SALE then 
    self:showListView(self.allEquipmentArray, CardBgalistType.EQUIPMENTS)
    self:showMenuByState(self.curListType)
  else
    -- self:getDelegate():displayHomeView()
    self:getDelegate():goBackView()
  end
end

function CardBagView:tabControlOnClick(idx)
  if self.curListType == CardBgalistType.CARDS_SALE or self.curListType == CardBgalistType.EQUIPMENTS_SALE then
    return
  end
  _playSnd(SFX_CLICK)  

  UIHelper.setIsNeedScrollList(true)
  if idx == 0 then 
    self:showListView(self.allCardsArray, CardBgalistType.CARDS)
  elseif idx == 1 then 
    self:showListView(self.allEquipmentArray, CardBgalistType.EQUIPMENTS)
  end

  self:showMenuByState(self.curListType)  
end


function CardBagView:saleCallback()
  if self.curListType == CardBgalistType.CARDS then 
    if GameData:Instance():checkSystemOpenCondition(42, true) == false then 
      return 
    end 

    self.curListType = CardBgalistType.CARDS_SALE
    self:resetData()

    self.selectAllIcon:setVisible(false)
    self.label_filterType:setString(_tr("default"))
    self:showListView(self.idleCardsArray, self.curListType)    
  elseif self.curListType == CardBgalistType.EQUIPMENTS then
    self.curListType = CardBgalistType.EQUIPMENTS_SALE
    self:resetData()

    self.selectAllIcon:setVisible(false)
    self.label_filterType:setString(_tr("default"))

    GameData:Instance():getCurrentPackage():sortEquipments(self.idleEquipmentArray, true)  

    self:showListView(self.idleEquipmentArray, self.curListType)
  end
  self:showMenuByState(self.curListType)
end

function CardBagView:registerTouchEvent()
    local function onTouch(eventType, x, y)
        if eventType == "began" then
          -- echo("---touch ", x, y)
          self:pointIsInListRect(x,y)
          return false
        end
    end
  
  self:addTouchEventListener(onTouch, false, -300, true)
  self:setTouchEnabled(true)
end



function CardBagView:resetData()
  if self.curListType == CardBgalistType.CARDS_SALE then 
    for k,v in pairs(self.allCardsArray) do
      v.isSelected = false
    end
  elseif self.curListType == CardBgalistType.EQUIPMENTS_SALE then 
    for k,v in pairs(self.allEquipmentArray) do
      v.isSelected = false
    end
  end

  self.selectedCount = 0
  self.totalSaledMoney = 0
  self.selectAllIcon:setVisible(false)
end 


function CardBagView:filterCallback()
  echo("filter callback")
  _playSnd(SFX_CLICK) 

    
  local function filterResult(index)
    if index < 0 then 
      return 
    end

    local tbl = { _tr("pop_star_%{count}", {count=1}),
                  _tr("pop_star_%{count}", {count=2}),
                  _tr("pop_star_%{count}", {count=3}),
                  _tr("pop_star_%{count}", {count=4}),
                  _tr("pop_star_%{count}", {count=5}),
                  _tr("pop_expCard")
                }
    local colorTbl = {ccc3(199,198,198), ccc3(167,232,0),ccc3(0,176,228),ccc3(222,1,255),ccc3(255,223,14),ccc3(255,239,165)}

    self.label_filterType:setString(tbl[index])
    self.label_filterType:setColor(colorTbl[index])

    local package = GameData:Instance():getCurrentPackage()
    --get data
    if self.curListType == CardBgalistType.CARDS_SALE then 
      self.dataArray = self.idleCardsArray
    elseif self.curListType == CardBgalistType.EQUIPMENTS_SALE then 
      self.dataArray = self.idleEquipmentArray
    end

    --reset data 
    self.selectedCount = 0
    self.totalSaledMoney = 0    
    for k, v in pairs(self.dataArray) do 
      v.isSelected = false
    end 

    --get selected filter data
    if index < 6 then  --get part of data by rare
      self.dataArray = package:getItemsByRare(self.dataArray, index)
    elseif index == 6 then 
      self.dataArray = Package:getExpCards(self.dataArray)
    end

    --show
    self.selectAllIcon:setVisible(false)
    self:showListView(self.dataArray, self.curListType)
  end
  
  local pop = PopupView:createFilterPopup(filterResult)
  if self.curListType == CardBgalistType.EQUIPMENTS_SALE then 
    pop.node4_expFilter:setVisible(false)
  end
  self:addChild(pop)
end


function CardBagView:removeItem(tbl, id)

  if tbl == nil then 
    echo("removeItem: nil table ")
    return
  end

  for i=1, table.getn(tbl) do 
    if tbl[i]:getId() == id then 
      table.remove(tbl, i)
      echo("---remove id:", id)
      break
    end
  end
end

function CardBagView:sellToSystemCallback(action,msgId,msg)
  echo("sell result:", msg.state)

--  if self.loading ~= nil then 
--    self.loading:remove()
--    self.loading = nil
--  end 
  _hideLoading()

  if msg.state == "Ok" then
    --GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
    --remove from self.dataArray  and  self.idleCardsArray/self.idleEquipmentArray
    for i=1, table.getn(self.sellArray) do
      local removedId = self.sellArray[i]:getId()
      self:removeItem(self.dataArray, removedId)

      if self.curListType == CardBgalistType.CARDS_SALE then
        self:removeItem(self.idleCardsArray, removedId)
        self:removeItem(self.allCardsArray, removedId)
      elseif self.curListType == CardBgalistType.EQUIPMENTS_SALE then
        self:removeItem(self.idleEquipmentArray, removedId)
        self:removeItem(self.allEquipmentArray, removedId)
      end
    end

    if msg.client_sync ~= nil then 
      if msg.client_sync.common ~= nil then
        --show gained bonus
        local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client_sync)
        for i=1,table.getn(gainItems) do
          echo("----gained:", gainItems[i].configId, gainItems[i].count)
          local str = string.format("+%d", gainItems[i].count)
          Toast:showIconNumWithDelay(str, gainItems[i].iconId, gainItems[i].iType, gainItems[i].configId, ccp(display.width/2,display.height*0.5-i*40), 0.3*(i-1))
        end
        
        --update 
        GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
      end
    end
    
    self.sellArray = {}
    self:resetData()
    self:showListView(self.dataArray, self.curListType)

  elseif msg.state == "NoSuchCard" then
    Toast:showString(self, _tr("no such card"), ccp(display.width/2, display.height*0.4))
  elseif msg.state == "HasEquipment" then
    Toast:showString(self, _tr("cannot sale card with equip"), ccp(display.width/2, display.height*0.4))
  elseif msg.state == "IsActiveCard" then
    Toast:showString(self, _tr("cannot sale battle card"), ccp(display.width/2, display.height*0.4))
  elseif msg.state == "CouldNotSell" then
    Toast:showString(self, _tr("cannot sale"), ccp(display.width/2, display.height*0.4))
  elseif msg.state == "SellAgain" then
    Toast:showString(self, _tr("sale card again"), ccp(display.width/2, display.height*0.4))
  elseif msg.state == "IsMineCard" then
    Toast:showString(self, _tr("cannot sale mining card"), ccp(display.width/2, display.height*0.4))
  else
    Toast:showString(self, _tr("fail to sale"), ccp(display.width/2, display.height*0.4))  
  end
end

function CardBagView:sellToSystem()

  local tmpTbl = {}
  for i=1, table.getn(self.sellArray) do 
    table.insert(tmpTbl, self.sellArray[i]:getId())
  end  

  if self.curListType == CardBgalistType.CARDS_SALE then
    _showLoading()
    local data = PbRegist.pack(PbMsgId.SellCardToSystem, {card_id = tmpTbl})
    net.sendMessage(PbMsgId.SellCardToSystem, data)
    --show waiting
    --self.loading = Loading:show()
  elseif self.curListType == CardBgalistType.EQUIPMENTS_SALE then
    _showLoading()
    local data = PbRegist.pack(PbMsgId.SellEquipmentToSystem, {equipment_id = tmpTbl})
    net.sendMessage(PbMsgId.SellEquipmentToSystem, data)
    --show waiting
    --self.loading = Loading:show()
  end
end

function CardBagView:confirmCallback()
  echo("confirmCallback")
  _playSnd(SFX_CLICK) 

  local needToPop = false 
  self.sellArray = {}  --clear array

  local tmpArray = nil
  if self.curListType == CardBgalistType.CARDS_SALE then
    tmpArray = self.allCardsArray
  elseif self.curListType == CardBgalistType.EQUIPMENTS_SALE then
    tmpArray = self.allEquipmentArray
  end

  --get selected items
  for k,v in pairs(tmpArray) do
    if v.isSelected == true then 
      table.insert(self.sellArray, v)
      if v:getMaxGrade() >= 3 then 
        needToPop = true
      end
    end
  end

  local allIsExpCards = true 
  if self.curListType == CardBgalistType.CARDS_SALE then
    for k,v in pairs(self.sellArray) do
      if v:getIsExpCard() == false then 
        allIsExpCards = false 
        break 
      end 
    end 
  end 

  --start to sale
  if table.getn(self.sellArray) >= 1 then
    local function popOkCallback()
      self:sellToSystem()
    end

    if needToPop == true and allIsExpCards == false then 
      local pop = PopupView:createTextPopup(_tr("sale high rank cards?"), popOkCallback)
      self:addChild(pop) 
    else 
      self:sellToSystem()
    end
  end
end

function CardBagView:selectAllCallback()
  echo("select all")

  local arrayLen = table.getn(self.dataArray)

  if arrayLen ~= self.selectedCount then 
    self.totalSaledMoney = 0
    for i=1, arrayLen do 
      self.dataArray[i].isSelected = true
      self.totalSaledMoney = self.totalSaledMoney + self.dataArray[i]:getSalePrice()        
    end 
    self.selectedCount = arrayLen
    self.selectAllIcon:setVisible(true)
  else 
    self:resetData()
  end 

  --local tableview = self.node_listContainer:getChildByTag(126)
  if self.tableView ~= nil then 
    self.tableView:reloadData()
  end

  self:updateToolBar()
end



function CardBagView:updateToolBar()
  echo("---updateToolBar:", self.selectedCount)
  if self.selectedCount >= 1 then 
    self:getDelegate():getScene():setBottomVisible(false)

    self.label_selectedNum:setString(string.format("%d", self.selectedCount))
    self.label_salePrice:setString(string.format("%d", self.totalSaledMoney))
    -- self.selectedNumOutlineLabel:setString(string.format("%d", self.selectedCount))
    -- self.priceOutlineLabel:setString(string.format("%d", self.totalSaledMoney))

    if self.node_bottom:isVisible() == false then 
      --show animation 
      self.node_bottom:setPosition(ccp(display.width/2, -self.node_bottom:getContentSize().height))
      self.node_bottom:setVisible(true)
      local moveto = CCMoveTo:create(0.6, ccp(display.width/2,0))
      local easeOut = CCEaseExponentialOut:create(moveto)
      self.node_bottom:runAction(easeOut)
    end
  else
    self:getDelegate():getScene():setBottomVisible(true)
    self.node_bottom:setVisible(false)
  end
end


function CardBagView:showListView(listData, listType)
  echo("showListView: listType=", listType)

  if listData == nil then 
    echo(" null list data.")
    return
  end

  self.dataArray = listData
  local totalCells = table.getn(listData)

  self.curListType = listType
  self:updateToolBar()

  -- local function scrollViewDidScroll(view)
  -- end

  local function tableCellTouched(tableview,cell)   
    echo("======tableCellTouched")
    local isSelected = 0
    local idx = cell:getIdx()
    local item = cell:getChildByTag(100)
    -- echo("touch idx =",idx)

    if item == nil then 
      return
    end

    if self.curListType == CardBgalistType.CARDS or self.curListType == CardBgalistType.EQUIPMENTS then 
      return
    end

    listData[idx+1].isSelected = not listData[idx+1].isSelected

    --highlight curIndex
    item:setSelectedIconVisible(listData[idx+1].isSelected)

    --update toolbar info
    if listData[idx+1].isSelected == true then 
      self.totalSaledMoney = self.totalSaledMoney + listData[idx+1]:getSalePrice()
      self.selectedCount = self.selectedCount + 1
    else 
      self.totalSaledMoney = self.totalSaledMoney - listData[idx+1]:getSalePrice()
      self.selectedCount = self.selectedCount - 1          
    end
    self:updateToolBar() 
  end
  
  -- local function tableCellHighLight(table, cell)
  --   local idx = cell:getIdx()
  --   local item = cell:getChildByTag(100)
  --   if item ~= nil then
  --     item:setSelectedHighlight(true)
  --   end
  -- end

  -- local function tableCellUnhighLight(table, cell)
  --   local idx = cell:getIdx()
  --   local item = cell:getChildByTag(100)
  --   if item ~= nil then
  --     item:setSelectedHighlight(false)
  --   end
  -- end


  local function cellSizeForTable(tableview,idx)
    return self.cellHeight,self.cellWidth
  end
  
  local function initCellItemWithCard(item, data)
    if listType == CardBgalistType.CARDS then
      local card = data
      item:setCard(card)
      item:setButtonEnableDelegate(function() return self:getListButtonEnable() end)
      item:setSelected(false)
      item:setSelectedVisible(false)
      -- item:setLevelPreName("等级:", ccc3(0, 255, 16))
      -- item:setLevelString(string.format("%d/%d", card:getLevel(),card:getMaxLevel())) 
      item:setLevelPreName(_tr("level")..string.format(":%d/%d", card:getLevel(),card:getMaxLevel()), ccc3(0, 255, 16))
      item:setLevelString("")
    
    elseif listType == CardBgalistType.CARDS_SALE then 
      local card = data
      item:setCard(card)
      item:setButtonEnableDelegate(function() return self:getListButtonEnable() end)
      item:setSelected(false)
      item:setSelectedVisible(true)
      local coin = item:getCointSprite()
      coin:setVisible(true)      
      item:setLevelPreName(_tr("sale"),ccc3(0, 255, 16))
      item:setLevelString(card:getSalePrice())
      item:setSelectedIconVisible(card.isSelected)

    elseif listType == CardBgalistType.EQUIPMENTS then 
      local equip = data
      item:setEquipmentData(equip) 
      item:setButtonEnableDelegate(function() return self:getListButtonEnable() end)  
      item:setSelected(false)
      item:setSelectedVisible(false)
    elseif listType == CardBgalistType.EQUIPMENTS_SALE then 
      local equip = data
      item:setEquipmentData(equip, true) 
      item:setButtonEnableDelegate(function() return self:getListButtonEnable() end)  
      item:setSelectedVisible(true)
      item:setSelectedIconVisible(equip.isSelected)
    end
  end

  local function tableCellAtIndex(tableview, idx)
    -- echo("=====cellAtIndex = "..idx)

    local cell = tableview:dequeueCell()
    local item = nil
    if nil == cell then
      cell = CCTableViewCell:new()
      
      if listType == CardBgalistType.CARDS or listType == CardBgalistType.CARDS_SALE then
        item = PlayStatesCardListItem.new()
      else 
        item = PlayStatesEquipmentListItem.new()
      end
      initCellItemWithCard(item, listData[idx+1])

      item:setTag(100)
      cell:addChild(item)
    else 
      item = cell:getChildByTag(100)
      if item ~= nil then
        initCellItemWithCard(item, listData[idx+1])
      end
    end

    if self.cellNumPerPage > 0 then 
      UIHelper.showScrollListView({object=item, totalCount=self.cellNumPerPage, index = idx})
    end 

    return cell
  end
  

  local function numberOfCellsInTableView(tableview)
    return totalCells
  end



  echo("remove old tableview")
  self.node_listContainer:removeAllChildrenWithCleanup(true)

  local size = self:getCanvasContentSize()
  local w = size.width
  local h = size.height
  local bottomHeight = self:getDelegate():getScene():getBottomContentSize().height
  local pos_y = bottomHeight

  if listType == CardBgalistType.CARDS_SALE or listType == CardBgalistType.EQUIPMENTS_SALE then 
    self.node_fileter:setVisible(true)
    self.node_sale:setVisible(false)

    local filterHeight = self.node_fileter:getContentSize().height
    self.node_fileter:setPositionY(bottomHeight+size.height - filterHeight+10)

    h = h - filterHeight
  else
    self.node_fileter:setVisible(false)
    self.node_sale:setVisible(true)
    self.node_sale:setPositionY(pos_y)

    local saleHeight = self.node_sale:getContentSize().height
    h = h - saleHeight
    pos_y = pos_y + saleHeight
  end

  
  self.node_listContainer:setContentSize(CCSizeMake(w, h))
  self.node_listContainer:setPosition(ccp((display.width-640)/2, pos_y))

  self.cellNumPerPage = math.ceil(h/self.cellHeight)
  if self.cellNumPerPage == 0 then 
    UIHelper.setIsNeedScrollList(false)
  end

  if totalCells == 0 then 
    self:setEmptyImgVisible(true)
  else 
    self:setEmptyImgVisible(false)
  end

  --create table view
  self.tableView = CCTableView:create(CCSizeMake(w, h))
  self.tableView:setDirection(kCCScrollViewDirectionVertical)
  self.tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  self.tableView:setTag(126)
  
  --tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  self.tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  self.tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  self.tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  self.tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)

  self.tableView:reloadData()
  self.node_listContainer:addChild(self.tableView)
  self:updateToolBar()
end

function CardBagView:showMenuByState(listType)
  CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("img/cardbag/cardbag.plist") --fixed bug1704
  if listType == CardBgalistType.CARDS then
    local menuArray = {
        {"#bn_wujiangkapai0.png","#bn_wujiangkapai1.png"},
        {"#bn_zhuangbeikapai0.png","#bn_zhuangbeikapai1.png"}
      }
    self:setMenuArray(menuArray)
    self:getTabMenu():setItemSelectedByIndex(1)

    local len = table.getn(self.allCardsArray)
    local limit = GameData:Instance():getCurrentPlayer():getMaxCardBagCount()

    local color = 16777215 --white
    if len > limit then 
      color = 16711680 --red
    end
    local str = _tr("own number").."<font><fontname>Courier-Bold</><color><value>"..color.."</>".. len .. "</></>/"..limit
    local pDispInfo = RichLabel:create(str,"Courier-Bold",24,CCSizeMake(240, 30),true,false)
    pDispInfo:setColor(ccc3(255,255,255))
    self.label_tipCount:removeAllChildrenWithCleanup(true)
    self.label_tipCount:addChild(pDispInfo)
    --local str = string.format("所持数:%d/%d", len,limit)
    --self.label_tipCount:setString(str)

  elseif listType == CardBgalistType.CARDS_SALE then 
    local menuArray = {
        {"#bn_chushouwujiang0.png","#bn_chushouwujiang0.png"}
      }
    self:setMenuArray(menuArray)
  elseif listType == CardBgalistType.EQUIPMENTS then
    local menuArray = {
        {"#bn_wujiangkapai0.png","#bn_wujiangkapai1.png"},
        {"#bn_zhuangbeikapai0.png","#bn_zhuangbeikapai1.png"}
      }
    self:setMenuArray(menuArray)
    self:getTabMenu():setItemSelectedByIndex(2)

    local len = table.getn(self.allEquipmentArray)
    local limit = GameData:Instance():getCurrentPlayer():getMaxEquipBagCount()
    -- local str = string.format("所持数:%d/%d", len,limit)
    -- self.label_tipCount:setString(str)
    local color = 16777215 --white
    if len > limit then 
      color = 16711680 --red
    end
    local str = _tr("own number").."<font><fontname>fzcyjt</><color><value>"..color.."</>".. len .. "</></>/"..limit
    local pDispInfo = RichLabel:create(str,"Courier-Bold",24,CCSizeMake(240, 30),true,false)
    pDispInfo:setColor(ccc3(255,255,255))
    self.label_tipCount:removeAllChildrenWithCleanup(true)
    self.label_tipCount:addChild(pDispInfo)

  elseif listType == CardBgalistType.EQUIPMENTS_SALE then
    menuArray = {
        {"#bn_chushouzhuangbei0.png","#bn_chushouzhuangbei0.png"}
      }
    self:setMenuArray(menuArray)
  end
end
