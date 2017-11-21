
require("view.BaseView")


ActivityExchangeListItem = class("ActivityExchangeListItem", BaseView)

function ActivityExchangeListItem:ctor()
  ActivityExchangeListItem.super.ctor(self)

  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("exchangeCallback",ActivityExchangeListItem.exchangeCallback)
  pkg:addFunc("touchTargetCallback",ActivityExchangeListItem.touchTargetCallback)
  pkg:addProperty("node_container","CCNode")
  pkg:addProperty("node_target","CCNode")
  pkg:addProperty("label_name","CCLabelTTF")  
  pkg:addProperty("label_leftTimes","CCLabelTTF") 
  pkg:addProperty("label_targetNum","CCLabelBMFont")
  pkg:addProperty("bn_exchange","CCControlButton")

  local layer,owner = ccbHelper.load("ActivityExchangeListItem.ccbi","ActivityExchangeListItemCCB","CCLayer",pkg)
  self:addChild(layer)
end

function ActivityExchangeListItem:onEnter()
  -- echo("ActivityExchangeListItem:onEnter")
end

function ActivityExchangeListItem:onExit()
  -- echo("ActivityExchangeListItem:onExit")
end

function ActivityExchangeListItem:exchangeCallback()
  echo("exchangeCallback", self._touchInViewDelegate)
  _playSnd(SFX_CLICK)

  if self._touchInViewDelegate ~= nil then 
    if self._touchInViewDelegate() == false then
      echo("invalid touch region1..")
      return
    end
  end

  local player = GameData:Instance():getCurrentPlayer() 
  --check condition  
  local canExchange = true 
  local canExchangeNumMax = 99999
  for k, v in pairs(self.itemArray) do 
    local expNum = v[3]
    local hasNum = 0 

    if v[1] == 4 then --coin 
      hasNum = player:getCoin()
    elseif v[1] == 5 then --money
      hasNum = player:getMoney()
    elseif v[1] == 6 then 
      hasNum = GameData:Instance():getCurrentPackage():getPropsNumByConfigId(v[2])
    elseif v[1] == 20 then --card soul 
      hasNum = player:getCardSoul()
    end 

    if hasNum < expNum then 
      canExchange = false 
      break 
    else 
      canExchangeNumMax = math.min(canExchangeNumMax, math.floor(hasNum/expNum))
    end 
  end 
  
  if canExchange == false then 
    Toast:showString(self, _tr("not enough material"), ccp(display.width/2, display.height*0.4))
    return 
  else 
    local tbl = Activity:instance():getExchangeTimesLimit(false)
    if tbl[self.item.id].totalCount > 0 and tbl[self.item.id].leftCount <= 0 then 
      Toast:showString(self, _tr("has no times"), ccp(display.width/2, display.height*0.4))
      return 
    elseif tbl[self.item.id].leftCount > 0 then 
      canExchangeNumMax = math.min(canExchangeNumMax, tbl[self.item.id].leftCount)
    end 
  end 
  
  if self:checkHasEnoughCell() == false then 
    return 
  end 

  local function confirmCallback1()
    self:getDelegate():startExchange(self:getIndex(), 1)
  end  

  local function confirmCallback2(num)
    echo("======canExchangeNumMax:", num)
    self:getDelegate():startExchange(self:getIndex(), num)
  end 

 
  if canExchangeNumMax == 1 then 
    local str = _tr("confirm to exchange?") 
    if self.item ~= nil then 
      str = _tr("confirm to exchange %{name}?", {name=self.item.exchange_name})
    end 

    local pop = PopupView:createTextPopup(str, confirmCallback1)
    self:getDelegate():addChild(pop)
  else 
    local pop = PopupView:createInputPopup(PopupType.INPUT_NUMBER_EXCHANGE, self.item.exchange_name, 0, canExchangeNumMax, confirmCallback2)                 
    self:getDelegate():addChild(pop)
    pop:setScale(0.2)
    pop:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6) )       
  end 
end


function ActivityExchangeListItem:touchTargetCallback()
  if self._touchInViewDelegate ~= nil then 
    if self._touchInViewDelegate() == false then
      echo("invalid touch region..")
      return
    end
  end

  if self.item ~= nil then 
    local targetItem = self.item.bonus[1].array 
    local _type = targetItem[1]
    if _type >= 6 and _type <= 8 then 
      TipsInfo:showTip(self.node_target, targetItem[2], nil, ccp(0, 60))
    end 
  end 
end 

function ActivityExchangeListItem:setItem(item)
  self.item = item 

  if self.item ~= nil then 
    self.itemArray = {}
    for k, v in pairs(self.item.exchange_item) do  --group
      table.insert(self.itemArray, v.array)
    end 

    self:showSourceList(self.itemArray)

    --name
    self.label_name:setString(self.item.exchange_name)

    --show left exchage-times
    local tbl = Activity:instance():getExchangeTimesLimit(false)

    if tbl[self.item.id].totalCount > 0 then 
      local str = _tr("today_left_times")..tbl[self.item.id].leftCount
      self.label_leftTimes:setString(str)
    else 
      self.label_leftTimes:setVisible(false)
    end  

    --target icon 
    local targetItem = self.item.bonus[1].array
    local node = GameData:Instance():getCurrentPackage():getItemSprite(nil, targetItem[1], targetItem[2], targetItem[3])
    if node ~= nil then 
      self.node_target:addChild(node)
    end 
  end
end

function ActivityExchangeListItem:setIndex(idx)
  self.index = idx
end 

function ActivityExchangeListItem:getIndex()
  return self.index
end


function ActivityExchangeListItem:showSourceList(itemArray)

  local function tableCellTouched(tbView,cell)
    if self._touchInViewDelegate ~= nil then 
      if self._touchInViewDelegate() == false then
        echo("invalid touch region2..")
        return
      end
    end

    local idx = cell:getIdx()
    local x = idx*self.cellWidth + tbView:getContentOffset().x + self.cellWidth/2
    local configId = itemArray[idx+1][2]
    TipsInfo:showTip(self.node_container, configId, nil, ccp(x, self.cellHeight+10))
  end

  local function cellSizeForTable(tbView,idx)
    return self.cellHeight,self.cellWidth
  end
  
  local function numberOfCellsInTableView(tbView)
    return self.totalCells
  end

  local function tableCellAtIndex(tbView, idx)
    local cell = tbView:dequeueCell()
    if child == nil then 
      cell = CCTableViewCell:new()
    else 
      cell:removeAllChildrenWithCleanup(true)
    end
    local itemType = itemArray[idx+1][1]
    local configId = itemArray[idx+1][2]
    local expectNum = itemArray[idx+1][3]
    local node = GameData:Instance():getCurrentPackage():getItemSprite(nil, itemType, configId, 1)
    if node ~= nil then 
      local ownNum = 0
      if itemType == 4 then --coin 
        ownNum = GameData:Instance():getCurrentPlayer():getCoin()
      elseif itemType == 5 then --money 
        ownNum = GameData:Instance():getCurrentPlayer():getMoney()
      elseif itemType == 6 then --props
        ownNum = GameData:Instance():getCurrentPackage():getPropsNumByConfigId(configId)
      end 

      local str1 = ""..ownNum 
      local str2 = ""..expectNum 
      if ownNum > 10000 then 
        if ownNum%10000 >= 1000 then 
          str1 = string.format("%.1f", ownNum/10000).._tr("wan")
        else 
          str1 = string.format("%d", ownNum/10000).._tr("wan")
        end 
      end
      if expectNum > 10000 then 
        if expectNum%10000 >= 1000 then 
          str2 = string.format("%.1f", expectNum/10000).._tr("wan")
        else         
          str2 = string.format("%d", expectNum/10000).._tr("wan")
        end 
      end

      local strNum = str1.."/"..str2
      local label = CCLabelBMFont:create(strNum, "client/widget/words/card_name/number_skillup.fnt")
      label:setAlignment(kCCTextAlignmentRight)
      local labelSize = label:getContentSize()
      local iconWidth = node:getContentSize().width 

      if labelSize.width > iconWidth then 
        strNum = str1.."\n".."/"..str2 
        label:setString(strNum)
        labelSize = label:getContentSize()
      end 
      label:setPosition(ccp(iconWidth/2-labelSize.width/2, -iconWidth/2+labelSize.height/2+7))
      node:addChild(label)

      local pos = ccp(self.cellWidth/2, self.cellHeight/2)
      node:setPosition(pos)
      cell:addChild(node)
    end

    return cell
  end
  
  self.node_container:removeAllChildrenWithCleanup(true)
  self.cellWidth = self.node_container:getContentSize().width/4
  self.cellHeight = self.node_container:getContentSize().height
  self.totalCells = table.getn(itemArray)
  local size = self.node_container:getContentSize()
  -- if self.totalCells < 4 and self.totalCells > 0 then
  --   size.width = self.totalCells * self.cellWidth
  -- end
  local tableView = CCTableView:create(size)
  tableView:setDirection(kCCScrollViewDirectionHorizontal)
  -- tbView:setTouchPriority(-200) --for tip menu
  -- tbView:setBounceable(false)
  self.node_container:addChild(tableView)

  --registerScriptHandler functions must be before the reloadData function
  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  tableView:reloadData()
end

function ActivityExchangeListItem:setTouchCheckDelegate(delegate)
  self._touchInViewDelegate = delegate
end

function ActivityExchangeListItem:checkHasEnoughCell()
  --check bag/cardbag is full or not
  local isEnough1 = true 
  local isEnough2 = true  
  local str = ""
  local hasEnoughCell = true 
  local targetItem = self.item.bonus[1].array
  local iType = targetItem[1] 
  if iType == 6 then 
    isEnough1 = GameData:Instance():getCurrentPackage():checkItemBagEnoughSpace(1)
    str = _tr("bag is full,clean up?")
  elseif iType == 8 then 
    isEnough2 = GameData:Instance():getCurrentPackage():checkCardBagEnoughSpace(1)
    str = _tr("card bag is full,clean up?")
  end  
  if (isEnough1 == false) or (isEnough2 == false) then
    local pop = PopupView:createTextPopupWithPath({leftNorBtn = "button-nor-zhengli.png",
                                                   leftSelBtn = "button-sel-zhengli.png",
                                                   text = str,
                                                   leftCallBack = function()
                                                      if isEnough1 == false then
                                                        return self:getDelegate():goToItemView()
                                                      end 
                                                      if isEnough2 == false then 
                                                        return self:getDelegate():goToCardBagView()
                                                      end
                                                  end})
    self:getDelegate():addChild(pop,100)

    hasEnoughCell = false 
  end 

  return hasEnoughCell 
end 