
require("view.BaseView")


ActivityVipListItem = class("ActivityVipListItem", BaseView)

function ActivityVipListItem:ctor()

  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("fetchCallback",ActivityVipListItem.fetchCallback)
  pkg:addProperty("node_list","CCNode") 
  pkg:addProperty("label_desc","CCLabelTTF")
  pkg:addProperty("bn_fetch","CCControlButton")

  local layer,owner = ccbHelper.load("ActivityVipListItem.ccbi","ActivityVipListItemCCB","CCLayer",pkg)
  self:addChild(layer)

  self.dscInfoArray = {_tr("day_1"), _tr("day_2"),_tr("day_3"),_tr("day_4"),_tr("day_5"),_tr("day_6"),_tr("day_7")}
end



function ActivityVipListItem:onEnter()
  echo("ActivityVipListItem:onEnter")
end

function ActivityVipListItem:onExit()
  echo("ActivityVipListItem:onExit")
end

function ActivityVipListItem:fetchCallback()
  _playSnd(SFX_CLICK)

  local isEnough1 = true 
  local isEnough2 = true 
  local isEnough3 = true 
  for k, v in pairs(self.itemArray) do 
    if v[1] == 6 then 
      isEnough1 = GameData:Instance():getCurrentPackage():checkItemBagEnoughSpace(1) 
      if isEnough1 == false then 
        Toast:showString(self, _tr("bag is full"), ccp(display.width/2, display.height*0.4))
        return false 
      end 
    elseif v[1] == 7 then 
      isEnough2 = GameData:Instance():getCurrentPackage():checkEquipBagEnoughSpace(1) 
      if isEnough2 == false then 
        Toast:showString(self, _tr("equip bag is full"), ccp(display.width/2, display.height*0.4))
        return false 
      end
    elseif v[1] == 8 then
      isEnough3 = GameData:Instance():getCurrentPackage():checkCardBagEnoughSpace(1) 
      if isEnough3 == false then 
        Toast:showString(self, _tr("card bag is full"), ccp(display.width/2, display.height*0.4))
        return false 
      end
    end
  end

  if self:getDelegate() ~= nil then
    self:getDelegate():fetchVipBonus(self:getDayIndex())
  end
end

function ActivityVipListItem:setBonus(planItem)
  self:showItemsList(planItem)
end

function ActivityVipListItem:setDayIndex(day)
  self.dayIndex = day

  if day <= table.getn(self.dscInfoArray) then 
    self.label_desc:setString(self.dscInfoArray[day])
  end
end 

function ActivityVipListItem:getDayIndex()
  return self.dayIndex
end

function ActivityVipListItem:setIsFetched(fteched)
  self.fteched = fteched
  if fteched == true then 
    local disFrame = display.newSpriteFrame("bn_act_yilingqu.png")
    self.bn_fetch:setBackgroundSpriteFrameForState(disFrame,CCControlStateDisabled)
    self.bn_fetch:setEnabled(false)
  else 
    -- local disFrame = display.newSpriteFrame("bn_act_lingqu2.png")
    -- self.bn_fetch:setBackgroundSpriteFrameForState(disFrame,CCControlStateDisabled)
    self.bn_fetch:setEnabled(true)
  end
end

function ActivityVipListItem:getIsFetched()
  return self.fteched
end

function ActivityVipListItem:setCanFetch(canFetch)
  self.bn_fetch:setEnabled(canFetch)
end 


function ActivityVipListItem:showItemsList(itemArray)
  --for tip menu
  self.itemArray = itemArray

  local function tableCellTouched(tableview,cell)
    if self:getDelegate() ~= nil then 
      local isTouch = self:getDelegate():getIsTouch()
      if isTouch == true then 
        local x = cell:getIdx()*self.cellWidth + tableview:getContentOffset().x + self.cellWidth/2
        local index = cell:getIdx() + 1
        local item = self.itemArray[index]
        local configId = item[2]
        TipsInfo:showTip(self.node_list, configId, nil, ccp(x, self.cellHeight+10))
      end
      self:getDelegate():setIsTouch(false)
    end
  end

  local function cellSizeForTable(tableview,idx)
    return self.cellHeight,self.cellWidth
  end
  
  local function numberOfCellsInTableView(tableview)
    return self.totalCells
  end

  local function tableCellAtIndex(tableview, idx)
    echo("cell index= ", idx)

    local cell = tableview:dequeueCell()
    if child == nil then 
      cell = CCTableViewCell:new()
    else 
      cell:removeAllChildrenWithCleanup(true)
    end
    
    local itemInfo = itemArray[idx+1]
    local node = GameData:Instance():getCurrentPackage():getItemSprite(nil, itemInfo[1], itemInfo[2], itemInfo[3])
    if node ~= nil then 
      local pos = ccp(self.cellWidth/2, self.cellHeight/2)
      node:setPosition(pos)
      cell:addChild(node)
    end

    return cell
  end
  
  self.node_list:removeAllChildrenWithCleanup(true)

  self.cellWidth = self.node_list:getContentSize().width/4
  self.cellHeight = self.node_list:getContentSize().height
  
  self.totalCells = table.getn(itemArray)

  local size = self.node_list:getContentSize()
  if self.totalCells < 4 and self.totalCells > 0 then
    size.width = self.totalCells * self.cellWidth
  end

  local tbView = CCTableView:create(size)
  tbView:setDirection(kCCScrollViewDirectionHorizontal)
  -- tbView:setTouchPriority(-200) --for tip menu
  -- tbView:setBounceable(false)
  self.node_list:addChild(tbView)

  --registerScriptHandler functions must be before the reloadData function
  tbView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tbView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tbView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tbView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  tbView:reloadData()
end

