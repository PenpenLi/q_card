
require("view.component.ViewWithEave")
require("view.card_soul.CardSoulChipListItem")
require("model.card_soul.CardSoul")

CardSoulChipListView = class("CardSoulChipListView", ViewWithEave)


function CardSoulChipListView:ctor()

  CardSoulChipListView.super.ctor(self)
  self:setTabControlEnabled(false)
  self:setScrollBgVisible(false)

  --1. load levelup view ccbi
  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("tabCallback1",CardSoulChipListView.tabCallback1)
  pkg:addFunc("tabCallback2",CardSoulChipListView.tabCallback2)
  pkg:addFunc("tabCallback3",CardSoulChipListView.tabCallback3)
  pkg:addFunc("tabCallback4",CardSoulChipListView.tabCallback4)
  pkg:addFunc("tabCallback5",CardSoulChipListView.tabCallback5)
  pkg:addFunc("tabCallback6",CardSoulChipListView.tabCallback6)
  pkg:addFunc("confirmCallback",CardSoulChipListView.confirmCallback)

  pkg:addProperty("node_tab","CCNode")
  pkg:addProperty("node_list","CCNode")
  pkg:addProperty("node_numInfo","CCNode")
  pkg:addProperty("node_bottom","CCNode")
  pkg:addProperty("label_coinCostPre","CCLabelTTF")
  pkg:addProperty("label_coinCost","CCLabelTTF")
  pkg:addProperty("label_PreGain","CCLabelTTF")
  pkg:addProperty("label_gainSoul","CCLabelTTF")
  pkg:addProperty("label_gainCoin","CCLabelTTF")
  pkg:addProperty("label_numInfo","CCLabelTTF")
  pkg:addProperty("label_grade1","CCLabelTTF")
  pkg:addProperty("label_grade2","CCLabelTTF")
  pkg:addProperty("label_grade3","CCLabelTTF")
  pkg:addProperty("label_grade4","CCLabelTTF")
  pkg:addProperty("label_grade5","CCLabelTTF")
  pkg:addProperty("label_all","CCLabelTTF")
  pkg:addProperty("sprite_grade1","CCSprite")
  pkg:addProperty("sprite_grade2","CCSprite")
  pkg:addProperty("sprite_grade3","CCSprite")
  pkg:addProperty("sprite_grade4","CCSprite")
  pkg:addProperty("sprite_grade5","CCSprite")
  pkg:addProperty("sprite_all","CCSprite")
  pkg:addProperty("sprite_arrow","CCSprite")
  pkg:addProperty("sprite_empty","CCSprite")

  local layer,owner = ccbHelper.load("CardSoulChipListView.ccbi","CardSoulChipListViewCCB","CCLayer",pkg)
  self:addChild(layer)
  
  self:setTitleTextureName("soul_xuanzesuipian.png")
  self:getEaveView().btnHelp:setVisible(false)
end


function CardSoulChipListView:onEnter()
  echo("---CardSoulChipListView:onEnter---")

  --set position of tab menu and list container 
  local tabHeight = self.node_tab:getContentSize().height
  local numInfoHeight = self.node_numInfo:getContentSize().height
  local bottomHeight = self:getDelegate():getScene():getBottomContentSize().height
  local list_w = 640 --size.width
  local list_h = self:getCanvasContentSize().height - tabHeight - numInfoHeight - 5
  self.node_numInfo:setPositionY(bottomHeight)
  self.node_list:setPosition(ccp((display.width-list_w)/2, bottomHeight+numInfoHeight))
  self.node_list:setContentSize(CCSizeMake(list_w, list_h))
  self.node_tab:setPositionY(bottomHeight+numInfoHeight+list_h)

  --string 
  self.label_grade1:setString(_tr("STAR_1"))
  self.label_grade2:setString(_tr("STAR_2"))
  self.label_grade3:setString(_tr("STAR_3"))
  self.label_grade4:setString(_tr("STAR_4"))
  self.label_grade5:setString(_tr("STAR_5"))
  self.label_all:setString(_tr("ALL"))
  self.label_coinCostPre:setString(_tr("pre_cost_desc"))
  self.label_PreGain:setString(_tr("will get"))

  self:setListButtonEnable(false)
  self:getDelegate():getScene():setBottomVisible(false)
  self:setLeftTypesForSelecte(self:getMaxTypesForSelecte())

  self:registerTouchEvent()

  --backup selected status for back 
  self.selectedBackup = {}
  local data = CardSoul:instance():getChipsForRefinedList(ChipGrade.GRADE_ALL)
  for k, v in pairs(data) do 
    self.selectedBackup[k] = v:getSelectedCount()
  end 

  self:handleTabMenu(ChipGrade.GRADE_ALL) 
  self:updateSelectedInfo()
end 

function CardSoulChipListView:onExit()
  echo("---CardSoulChipListView:onExit---")
end

function CardSoulChipListView:tabCallback1()
  self:handleTabMenu(ChipGrade.GRADE_1)
end 

function CardSoulChipListView:tabCallback2()
  self:handleTabMenu(ChipGrade.GRADE_2)
end 

function CardSoulChipListView:tabCallback3()
  self:handleTabMenu(ChipGrade.GRADE_3)
end 

function CardSoulChipListView:tabCallback4()
  self:handleTabMenu(ChipGrade.GRADE_4)
end 

function CardSoulChipListView:tabCallback5()
  self:handleTabMenu(ChipGrade.GRADE_5)
end 

function CardSoulChipListView:tabCallback6()
  self:handleTabMenu(ChipGrade.GRADE_ALL)
end 

function CardSoulChipListView:handleTabMenu(grade)
  grade = grade or ChipGrade.GRADE_ALL
  local dataArray = CardSoul:instance():getChipsForRefinedList(grade)
  local len = #dataArray
  if len > 0 then     
    GameData:Instance():getCurrentPackage():sortItems(dataArray, 1, len, SortType.RARE_UP)
    self:showListView(dataArray)
  else 
    echo("=== empty chip.")
    self:showListView({})
  end 

  local tbl = {self.sprite_grade1, self.sprite_grade2, self.sprite_grade3, self.sprite_grade4, self.sprite_grade5, self.sprite_all}
  for i=1, #tbl do 
    tbl[i]:setVisible(grade == i)
  end 
end 

function CardSoulChipListView:registerTouchEvent()
    local function onTouch(eventType, x, y)
        if eventType == "began" then
          self:pointIsInListRect(x,y)
          return false
        end
    end
  
  self:addTouchEventListener(onTouch, false, -300, true)
  self:setTouchEnabled(true)
end

function CardSoulChipListView:pointIsInListRect(touch_x, touch_y)
  local isInRect = false 
  local listSize = self.node_list:getContentSize()
  local pos = self.node_list:convertToNodeSpace(ccp(touch_x, touch_y))
  if pos.x > 0 and pos.x < listSize.width and pos.y > 0 and pos.y < listSize.height then 
    isInRect = true
  end 

  self:setListButtonEnable(isInRect)
end

function CardSoulChipListView:setListButtonEnable(isEnable)
  self._isBnEnable = isEnable
end 

function CardSoulChipListView:getListButtonEnable()
  return self._isBnEnable
end 

function CardSoulChipListView:onHelpHandler()
  CardSoulChipListView.super:onHelpHandler()

end

function CardSoulChipListView:onBackHandler()
  echo("CardSoulChipListView:backCallback")
  local dataArray = CardSoul:instance():getChipsForRefinedList(ChipGrade.GRADE_ALL)
  for i=1, #dataArray do 
    dataArray[i]:setSelectedCount(self.selectedBackup[i])
  end 

  self:getDelegate():displayPreView()
end

function CardSoulChipListView:confirmCallback()
  echo("confirmCallback")
  local dataArray = CardSoul:instance():getChipsForRefinedList(ChipGrade.GRADE_ALL)
  local tbl = {}
  for k, v in pairs(dataArray) do 
    if v:getSelectedCount() > 0 then 
      table.insert(tbl, v)
    end 
  end 
  CardSoul:instance():setRefinedChips(tbl)

  self:getDelegate():displayPreView()
end





function CardSoulChipListView:setIsUsedFor(val)
  self._isUsedFor = val
end

function CardSoulChipListView:getIsUsedFor()
  if self._isUsedFor == nil then 
    self._isUsedFor = 0
  end

  return self._isUsedFor
end

function CardSoulChipListView:setListScrollEnable(isEnabled)
  if isEnabled == false then
    self._lastY = 0
    if self.tableView ~= nil then 
      self._lastY = self.tableView:getContainer():getPositionY()
    end 
  end 

  self._listScrollEnable = isEnabled
end 

function CardSoulChipListView:getListScrollEnable()
  return self._listScrollEnable
end 


function CardSoulChipListView:showListView(listData)

  if listData == nil then 
    return
  end 
  
  echo("showListView")
  self.dataArray = listData
  self.dataLen = #listData

  -- local function scrollViewDidScroll(view)
  -- end

  local function tableCellTouched(tbView,cell)   
    self:setIsTouchEvent(true)
  end


  
  local function tableCellAtIndex(tbView, idx)
    echo("tableCellAtIndex = "..idx)
    local cell = tbView:dequeueCell()

    if nil == cell then
      cell = CCTableViewCell:new()
    else 
      cell:removeAllChildrenWithCleanup(true)
    end 

    local item = CardSoulChipListItem.new()
    if item ~= nil then 
      item:setButtonEnableDelegate(function() return self:getListButtonEnable() end)
      local data = {}
      local count = math.min(5, self.dataLen-idx*5)
      for i=1, count do 
        data[i] = self.dataArray[idx*5+i]
      end 
      item:setChips(data)
      item:setDelegate(self)
      cell:addChild(item)
    end 

    return cell
  end
  
  local function cellSizeForTable(tbView,idx)
    return self.cellHeight,self.cellWidth
  end

  local function numberOfCellsInTableView(tableview)
    return self.totalCells
  end



  self.node_list:removeAllChildrenWithCleanup(true)
  local listSize = self.node_list:getContentSize()
  self.cellWidth = listSize.width 
  self.cellHeight = 171
  self.totalCells = math.ceil(#self.dataArray/5)

  self.sprite_arrow:setVisible(self.totalCells >= 3)
  self.sprite_empty:setVisible(self.totalCells == 0)

  --create table view
  self.tableView = CCTableView:create(listSize)
  self.tableView:setDirection(kCCScrollViewDirectionVertical)
  self.tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  self.tableView:setTouchPriority(-200)

  -- self.tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  self.tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  self.tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  self.tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  self.tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  self.tableView:reloadData()
  self.node_list:addChild(self.tableView)
end

function CardSoulChipListView:getMaxTypesForSelecte()
  return 6 
end 

function CardSoulChipListView:setLeftTypesForSelecte(num)
  self._leftTypes = num
end 

function CardSoulChipListView:getLeftTypesForSelecte()
  return self._leftTypes
end 

function CardSoulChipListView:updateSelectedInfo()
  if self.dataArray == nil then 
    return 
  end 

  local selectedType = 0 
  local cost = 0 
  local gainSoul = 0 
  local gainCoin = 0 
  for k, v in pairs(self.dataArray) do 
    if v:getSelectedCount() > 0 then 
      selectedType = selectedType + 1 

      cost = cost + v:getRefinedPrice() * v:getSelectedCount()
      if v:getRefinedGainType() == CurrencyType.Soul then 
        gainSoul = gainSoul + v:getRefinedGain() * v:getSelectedCount() 
      else 
        gainCoin = gainCoin + v:getRefinedGain() * v:getSelectedCount() 
      end 
    end 
  end 

  self:setLeftTypesForSelecte(self:getMaxTypesForSelecte()-selectedType)
  self.label_numInfo:setString(string.format("%d/%d", selectedType, self:getMaxTypesForSelecte()))

  self.label_coinCost:setString(string.format("%d", cost))
  self.label_gainSoul:setString(string.format("%d", gainSoul))
  self.label_gainCoin:setString(string.format("%d", gainCoin))
end 


function CardSoulChipListView:setIsTouchEvent(isTouchEvent)
  self._isTouch = isTouchEvent
end 

function CardSoulChipListView:getIsTouchEvent()
  return self._isTouch
end 
