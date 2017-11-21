
require("view.BaseView")


ActivityChargeListItem = class("ActivityChargeListItem", BaseView)

function ActivityChargeListItem:ctor(menuType)
  ActivityChargeListItem.super.ctor(self)

  local pkg = ccbRegisterPkg.new(self)

  pkg:addProperty("node_list","CCNode") 
  pkg:addProperty("label_prechargeCount","CCLabelTTF")
  pkg:addProperty("label_chargeCount","CCLabelTTF")
  pkg:addProperty("sprite_finish","CCSprite")
  pkg:addProperty("sprite_unfinish","CCSprite")

  local layer,owner = ccbHelper.load("ActivityChargeListItem.ccbi","ActivityChargeListItemCCB","CCLayer",pkg)
  self:addChild(layer)

  self.menuType = menuType
end


function ActivityChargeListItem:onEnter()
  -- echo("ActivityChargeListItem:onEnter")
  local str = ""
  if self.menuType == ActMenu.CHARGE_BONUS then 
    str= _tr("charge_count")
  elseif self.menuType == ActMenu.MONEY_CONSUME then 
    str= _tr("money_consume_count")
  end 
  self.label_prechargeCount:setString("")
  local outlineLabel = ui.newTTFLabelWithOutline( {
                                            text = str,
                                            font = self.label_prechargeCount:getFontName(),
                                            size = self.label_prechargeCount:getFontSize(),
                                            x = 0,
                                            y = 0,
                                            color = ccc3(255, 234, 0),
                                            align = ui.TEXT_ALIGN_LEFT,
                                            --valign = ui.TEXT_VALIGN_TOP,
                                            --dimensions = self.label_info:getContentSize(),
                                            outlineColor =ccc3(0,0,0),
                                            pixel = 2
                                            }
                                          )
  outlineLabel:setPosition(ccp(self.label_prechargeCount:getPosition()))
  self.label_prechargeCount:getParent():addChild(outlineLabel)

  local x = outlineLabel:getPositionX() + outlineLabel:getContentSize().width + 20
  self.label_chargeCount:setPositionX(x) 
end

function ActivityChargeListItem:onExit()
  -- echo("ActivityChargeListItem:onExit")
end

function ActivityChargeListItem:setBonus(dataArray, curProgress)
  -- local curProgress = 0
  if self.menuType == ActMenu.CHARGE_BONUS then 
    -- curProgress = Activity:instance():getActProgress(ACI_ID_CHARGE_BONUS)
  elseif self.menuType == ActMenu.MONEY_CONSUME then 
    -- curProgress = Activity:instance():getActProgress(ACI_ID_CONSUME_MONEY)
  end 
  
  if curProgress < dataArray.countCondition then 
    self.label_chargeCount:setColor(ccc3(201,1,1))
    self.sprite_finish:setVisible(false)
    self.sprite_unfinish:setVisible(true)
  else 
    self.label_chargeCount:setColor(ccc3(32,143,0))
    self.sprite_finish:setVisible(true)
    self.sprite_unfinish:setVisible(false)

    curProgress = dataArray.countCondition
  end 
  
  local str = string.format("%d/%d",curProgress, dataArray.countCondition)
  self.label_chargeCount:setString(str)

  self:showItemsList(dataArray.bonus)
end

function ActivityChargeListItem:setIndex(idx)
  self.index = idx
end 

function ActivityChargeListItem:getIndex()
  return self.index
end


function ActivityChargeListItem:showItemsList(itemArray)
  --for tip menu
  self.itemArray = itemArray

  local function tableCellTouched(tableview,cell)
    if self:getDelegate() ~= nil then 
      local isTouch = self:getDelegate():getIsTouch()
      if isTouch == true then 
        local idx = cell:getIdx()
        local x = idx*self.cellWidth + tableview:getContentOffset().x + self.cellWidth/2
        local configId = self.itemArray[idx+1][2]
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
    
    local itemInfo = self.itemArray[idx+1]
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
  
  self.totalCells = table.getn(self.itemArray)

  local size = self.node_list:getContentSize()
  -- if self.totalCells < 4 and self.totalCells > 0 then
  --   size.width = self.totalCells * self.cellWidth
  -- end

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
