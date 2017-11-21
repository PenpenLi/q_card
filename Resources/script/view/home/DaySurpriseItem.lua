
require("view.BaseView")


DaySurpriseItem = class("DaySurpriseItem", BaseView)

function DaySurpriseItem:ctor()
  DaySurpriseItem.super.ctor(self)

  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("fetchCallback",DaySurpriseItem.fetchCallback)
  pkg:addProperty("node_list","CCNode") 
  pkg:addProperty("node_arrow","CCNode")
  pkg:addProperty("node_day","CCNode") 
  pkg:addProperty("sprite_hasFetched","CCSprite")
  pkg:addProperty("bn_fetch","CCControlButton")

  local layer,owner = ccbHelper.load("Act_DaySurpriseItem.ccbi","Act_DaySurpriseItemCCB","CCLayer",pkg)
  self:addChild(layer)

  self.priority = -201
  self.bn_fetch:setTouchPriority(self.priority)
end



function DaySurpriseItem:onEnter()
  echo("DaySurpriseItem:onEnter")
end

function DaySurpriseItem:onExit()
  echo("DaySurpriseItem:onExit")
end

function DaySurpriseItem:fetchCallback()
  if self:getDelegate() ~= nil and self:getDelegate():getIsTouchInViewRect() == false then 
    echo("=== outside view region")
    return
  end
  
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
    self:getDelegate():fetchBonus(self:getIndex())
  end
end

function DaySurpriseItem:setBonus(planItem)
  self:showItemsList(planItem)
end

function DaySurpriseItem:setIndex(idx)
  self.index = idx
  local name = string.format("day_%d.png", idx+1)
  local img = CCSprite:createWithSpriteFrameName(name)
  self.node_day:addChild(img)
end 

function DaySurpriseItem:getIndex()
  return self.index
end

function DaySurpriseItem:setFetchState(state)
  if state == 1 then --has fetch
    self.bn_fetch:setVisible(false)
    self.sprite_hasFetched:setVisible(true)
  elseif state == 2 then --disable fetch
    self.bn_fetch:setEnabled(false)
  end
end

function DaySurpriseItem:showItemsList(itemArray)
  --for tip menu
  self.itemArray = itemArray

  local function tableCellTouched(tableview,cell)
    if self:getDelegate() ~= nil and self:getDelegate():getIsTouchInViewRect() == true then 
      local x = cell:getIdx()*self.cellWidth + tableview:getContentOffset().x + self.cellWidth/2
      local index = cell:getIdx() + 1
      local item = self.itemArray[index]
      local configId = item[2]
      TipsInfo:showTip(self.node_list, configId, nil, ccp(x, self.cellHeight+10))
    end 
  end 

  local function cellSizeForTable(tableview,idx)
    return self.cellHeight,self.cellWidth
  end
  
  local function numberOfCellsInTableView(tableview)
    return self.totalCells
  end

  local function tableCellAtIndex(tableview, idx)
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
  self.cellWidth = self.node_list:getContentSize().width/3
  self.cellHeight = self.node_list:getContentSize().height
  self.totalCells = table.getn(itemArray)

  local size = self.node_list:getContentSize()
  local tbView = CCTableView:create(size)
  tbView:setDirection(kCCScrollViewDirectionHorizontal)
  tbView:setTouchPriority(self.priority)
  -- tbView:setBounceable(false)
  self.node_list:addChild(tbView)

  --registerScriptHandler functions must be before the reloadData function
  tbView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tbView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tbView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tbView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  tbView:reloadData()
end

