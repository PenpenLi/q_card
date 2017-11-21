
require("view.BaseView")


ActivityMissionItem = class("ActivityMissionItem", BaseView)

function ActivityMissionItem:ctor(priority)
  ActivityMissionItem.super.ctor(self)

  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("fetchCallback",ActivityMissionItem.fetchCallback)
  pkg:addFunc("gotoCallback",ActivityMissionItem.gotoCallback)
  pkg:addProperty("node_bonus","CCNode") 
  pkg:addProperty("menu_goto","CCMenu")
  pkg:addProperty("menu_fetch","CCMenu")
  pkg:addProperty("label_title","CCLabelTTF")
  pkg:addProperty("label_progress","CCLabelTTF")
  pkg:addProperty("sprite_finish","CCSprite") 

  local layer,owner = ccbHelper.load("ActivityMissionItem.ccbi","ActivityMissionItemCCB","CCLayer",pkg)
  self:addChild(layer) 

  self.priority = priority or -200 

  self.menu_goto:setTouchPriority(self.priority)
  self.menu_fetch:setTouchPriority(self.priority)
end

function ActivityMissionItem:onEnter()

end 

function ActivityMissionItem:onExit()
end 

function ActivityMissionItem:fetchCallback()
  if self._itemData then 
    if Activity:instance():checkHasEnoughSpace(self.bonusArray) == false  then 
      return 
    end 
    self:getDelegate():fetchBonus(self:getIndex(), self._itemData)
  end 
end 

function ActivityMissionItem:gotoCallback()
  if self._itemData and self.menu_goto:isVisible() then 
    GameData:Instance():pushViewType(ViewType.act_mission)

    GameData:Instance():gotoViewByJumpType(self._itemData.rawData.jump_type, self._itemData.rawData.jump_value)
  end 
end 

function ActivityMissionItem:setData(itemData)
  self._itemData = itemData
  --排行榜相反判断
  local isFinish = self._itemData.rawData.jump_type ~= 18 and self._itemData.progress >= self._itemData.rawData.var 
                or self._itemData.rawData.jump_type == 18 and (self._itemData.progress>0 and self._itemData.progress <= self._itemData.rawData.var) 
  if isFinish then 
    self.sprite_finish:setVisible(self._itemData.award_is_get > 0)
    self.menu_fetch:setVisible(self._itemData.award_is_get == 0)
    self.menu_goto:setVisible(false)
  else 
    self.sprite_finish:setVisible(false)
    self.menu_fetch:setVisible(false)
    self.menu_goto:setVisible(true)
  end 

  local str 
  if isFinish then 
    str = string.format("(%d/%d)", self._itemData.rawData.var, self._itemData.rawData.var)
  else 
    str = string.format("(%d/%d)", self._itemData.progress, self._itemData.rawData.var)
  end 
  self.label_title:setString(self._itemData.rawData.desciption)
  self.label_progress:setPositionX(self.label_title:getPositionX() + self.label_title:getContentSize().width + 20)
  self.label_progress:setString(str)
  self.label_progress:setColor(isFinish and ccc3(32,143,0) or ccc3(201,1,1))

  local drop_group 
  self.bonusArray = {}
  for n, dropId in pairs(self._itemData.rawData.bonus) do 
    drop_group = AllConfig.drop[dropId]
    if drop_group then 
      for k, v in pairs(drop_group.drop_data) do 
        table.insert(self.bonusArray, v.array)
      end 
    end 
  end 

  self:showBonusInfo(self.bonusArray)
end 

function ActivityMissionItem:setIndex(idx)
  self._idx = idx 
end 

function ActivityMissionItem:getIndex()
  return self._idx 
end 

function ActivityMissionItem:showBonusInfo(bonusArray)
  
  local function tableCellTouched(tableview,cell)
    if self:getDelegate():getIsValidTouch() then 
      self:getDelegate():setIsValidTouch(false)
      local configId = bonusArray[cell:getIdx()+1][2] < 100 and bonusArray[cell:getIdx()+1][1] or bonusArray[cell:getIdx()+1][2]
      TipsInfo:showTip(cell, configId, nil, ccp(self.cellWidth/2, self.cellHeight+10))
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
    if cell == nil then 
      cell = CCTableViewCell:new()
    else 
      cell:removeAllChildrenWithCleanup(true)
    end

    local item = bonusArray[idx+1]
    local node = GameData:Instance():getCurrentPackage():getItemSprite(nil, item[1], item[2], item[3])
    node:setScale(0.9)
    node:setPosition(ccp(self.cellWidth/2, self.cellHeight/2))
    cell:addChild(node)

    return cell
  end
  
  if bonusArray == nil then 
    return 
  end

  self.node_bonus:removeAllChildrenWithCleanup(true)

  self.cellWidth = 95
  self.cellHeight = self.node_bonus:getContentSize().height
  self.totalCells = #bonusArray

  local tableView = CCTableView:create(self.node_bonus:getContentSize())
  tableView:setDirection(kCCScrollViewDirectionHorizontal)
  tableView:setTouchPriority(self.priority)
  self.node_bonus:addChild(tableView)

  --tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  tableView:reloadData()
end
