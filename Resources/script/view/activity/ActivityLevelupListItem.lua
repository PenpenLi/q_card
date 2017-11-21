require("view.BaseView")

ActivityLevelupListItem = class("ActivityLevelupListItem", function() return CCNode:create() end)

function ActivityLevelupListItem:ctor(level, playerLevel, hasRewarded, bonusTbl)

  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("fetchCallback",ActivityLevelupListItem.fetchCallback)
  
  pkg:addProperty("node_container","CCNode")
  pkg:addProperty("label_name","CCLabelTTF")
  pkg:addProperty("bn_fetch","CCControlButton")
  
  pkg:addProperty("sprite9_sel","CCScale9Sprite")
  pkg:addProperty("sprite9_nor","CCScale9Sprite")

  local layer,owner = ccbHelper.load("ActivityLevelupListItem.ccbi","ActivityLevelupListItemCCB","CCLayer",pkg)
  self:addChild(layer)

  local str = _tr("level_gift%{lv}", {lv=level})
  self.label_name:setString("")
  local outlineLabel = ui.newTTFLabelWithOutline( {
                                            text = str,
                                            font = self.label_name:getFontName(),
                                            size = self.label_name:getFontSize(),
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

  outlineLabel:setPosition(ccp(self.label_name:getPosition()))
  self.label_name:getParent():addChild(outlineLabel)  

  if hasRewarded == true then 
    local disFrame = display.newSpriteFrame("bn_act_yilingqu.png")
    self.bn_fetch:setBackgroundSpriteFrameForState(disFrame,CCControlStateDisabled)
    self.bn_fetch:setEnabled(false)
  else 
    if level > playerLevel then 
      local disFrame = display.newSpriteFrame("bn_act_lingqu2.png")
      self.bn_fetch:setBackgroundSpriteFrameForState(disFrame,CCControlStateDisabled)
      self.bn_fetch:setEnabled(false) 
    end
  end
  self:showBonusInfo(bonusTbl) 
end

function ActivityLevelupListItem:setDelegate(delegate)
  self._delegate = delegate
end

function ActivityLevelupListItem:getDelegate()
  return self._delegate
end

function ActivityLevelupListItem:setListIndex(idx)
  self._index = idx
  _registNewBirdComponent(116201 + self._index,self.bn_fetch)
end 

function ActivityLevelupListItem:getListIndex()
  return self._index
end 

function ActivityLevelupListItem:showBonusInfo(bonusGroup)

  
  local function tableCellTouched(tableview,cell)
    local idx = cell:getIdx()
    local itype = bonusGroup[idx+1][1]
    if itype == 6 or itype == 8 then 
      if self._touchRectDelegate ~= nil then 
        if self._touchRectDelegate() == false then
          echo("invalid bn delegate...")
          return
        end
      end

      TipsInfo:showTip(cell, bonusGroup[idx+1][2], nil, ccp(self.cellWidth/2, self.cellHeight))
    end 
  end
  
  local function cellSizeForTable(tableview,idx)
    return self.cellHeight,self.cellWidth
  end
  
  local function numberOfCellsInTableView(tableview)
    return self.totalCells
  end

  local function tableCellAtIndex(tableview, idx)
    -- echo("cell index= ", idx)
    local cell = tableview:dequeueCell()
    if cell == nil then 
      cell = CCTableViewCell:new()
    else 
      cell:removeAllChildrenWithCleanup(true)
    end

    local item = bonusGroup[idx+1]
    local node = GameData:Instance():getCurrentPackage():getItemSprite(nil, item[1], item[2], item[3])
    node:setPosition(ccp(self.cellWidth/2, self.cellHeight/2))
    cell:addChild(node)

    return cell
  end
  
  if bonusGroup == nil then 
    return 
  end

  self.node_container:removeAllChildrenWithCleanup(true)

  self.cellWidth = self.node_container:getContentSize().width/3
  self.cellHeight = self.node_container:getContentSize().height
  self.totalCells = #bonusGroup

  local tableView = CCTableView:create(self.node_container:getContentSize())
  tableView:setDirection(kCCScrollViewDirectionHorizontal)
  self.node_container:addChild(tableView)

  --tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  tableView:reloadData()
end

function ActivityLevelupListItem:fetchCallback()
  _playSnd(SFX_CLICK)
  if self:getDelegate() ~= nil then 
    self:getDelegate():fetchCallback(self:getListIndex())
  end
  _executeNewBird()
end

function ActivityLevelupListItem:setTouchRectDelegate(delegate)
  self._touchRectDelegate = delegate
end

