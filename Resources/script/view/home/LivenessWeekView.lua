

require("view.BaseView")
require("model.home.Liveness")


LivenessWeekView = class("LivenessWeekView", BaseView)

function LivenessWeekView:ctor()
  LivenessWeekView.super.ctor(self)
  
  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("closeCallback",LivenessWeekView.closeCallback)
  pkg:addFunc("fetchCallback",LivenessWeekView.fetchCallback)
  pkg:addProperty("node_liveness","CCNode")
  pkg:addProperty("node_bonus1","CCNode")
  pkg:addProperty("node_bonus2","CCNode")
  pkg:addProperty("node_bonus3","CCNode")
  pkg:addProperty("node_bonus4","CCNode")
  pkg:addProperty("sprite_bg","CCSprite")
  pkg:addProperty("sprite_arrow","CCSprite")
  pkg:addProperty("label_value1","CCLabelTTF")
  pkg:addProperty("label_value2","CCLabelTTF")
  pkg:addProperty("label_value3","CCLabelTTF")
  pkg:addProperty("label_value4","CCLabelTTF")
  pkg:addProperty("label_preWeekLiveness","CCLabelTTF")
  pkg:addProperty("label_curWeekLiveness","CCLabelTTF")
  pkg:addProperty("label_preliveness","CCLabelTTF")
  pkg:addProperty("label_curliveness","CCLabelTTF")
  pkg:addProperty("bn_fetch","CCControlButton")
  pkg:addProperty("bn_close","CCControlButton")

  local layer,owner = ccbHelper.load("LivenessWeekView.ccbi","LivenessWeekViewCCB","CCLayer",pkg)
  self:addChild(layer)
end


function LivenessWeekView:createLivenessWeekView()
  local view = LivenessWeekView.new()
  view:init()

  return view
end 

function LivenessWeekView:init()
  echo("=== LivenessWeekView:init === ")
  self.bonusInfo = Liveness:instance():getWeekBonusInfo()

  self.label_preWeekLiveness:setString(_tr("last week liveness"))
  self.label_curWeekLiveness:setString(_tr("cur week liveness"))

  self.priority = -200
  self.node_liveness:setPositionX(display.cx)

  net.registMsgCallback(PbMsgId.AskForLivenessWeekPointGiftResult,self,LivenessWeekView.fetchBonusResutl)
  self.bn_fetch:setTouchPriority(self.priority-3)
  self.bn_close:setTouchPriority(self.priority-3)

  --top circle anim
  local bgSize = self.sprite_bg:getContentSize()
  local imgCircle = _res(3022057)
  if imgCircle ~= nil then
    imgCircle:setPosition(ccp(bgSize.width/2, bgSize.height-40))
    local action = CCRotateBy:create(2.7, 360)
    imgCircle:runAction(CCRepeatForever:create(action))
    self.sprite_bg:addChild(imgCircle,-1)
  end 

  --top star anim
  local starAnim = _res(6010020)
  if starAnim ~= nil then 
    starAnim:setPosition(ccp(bgSize.width/2, bgSize.height-40))
    self.sprite_bg:addChild(starAnim, 10)
  end

  local action = CCSequence:createWithTwoActions(CCFadeTo:create(0.8, 100),CCFadeTo:create(1.0, 255))
  self.sprite_arrow:runAction(CCRepeatForever:create(action))

  local awardFlag = GameData:Instance():getCurrentPlayer():getWeekLivenessAwarded()
  if awardFlag ~= nil and awardFlag > 0 then 
    self.bn_fetch:setEnabled(false)
  end 

  local prePoint = GameData:Instance():getCurrentPlayer():getPreWeekLivenessVal()
  local curPoint = GameData:Instance():getCurrentPlayer():getCurWeekLivenessVal()
  self.label_preliveness:setString(string.format("%d", prePoint))
  self.label_curliveness:setString(string.format("%d", curPoint))

  self:showBonusList()
end 


function LivenessWeekView:onExit()
  echo("=== LivenessWeekView:onExit")
  net.unregistAllCallback(self)
  _hideLoading()
end 

function LivenessWeekView:close()
  echo(" LivenessWeekView:close")
  -- net.unregistAllCallback(self)
  -- self:removeFromParentAndCleanup(true)
  -- if self.loading ~= nil then 
  --   self.loading:remove()
  --   self.loading = nil
  -- end  
  if self:getDelegate() ~= nil then 
    self:getDelegate():closeLivenessViews()
  end   
end

function LivenessWeekView:getTblViewRect()
  local size = self.sprite_bg:getContentSize()
  local ap = tolua.cast(self.sprite_bg:getAnchorPoint(), "CCPoint") 
  local pos = self.sprite_bg:getParent():convertToWorldSpace(ccp(self.sprite_bg:getPosition()))
  local x = pos.x - ap.x * size.width 
  local y = pos.y - ap.y * size.height 
  echo("============x, y", x, y) 
  
  return CCRectMake(x+220, y+250, 360, 350) 
end 

function LivenessWeekView:checkDisplayPopToCleanBag(bonusArray)
  local needClean = false 
  local isEnough1 = true 
  local isEnough2 = true
  local isEnough3 = true
  local str = " "


  for k, v in pairs(bonusArray) do
    if v.iType == 6 then 
      isEnough1 = GameData:Instance():getCurrentPackage():checkItemBagEnoughSpace(1)
      str = _tr("bag is full,clean up?")
    end 
    if v.iType == 8 then 
      isEnough2 = GameData:Instance():getCurrentPackage():checkCardBagEnoughSpace(1)
      str = _tr("card bag is full,clean up?")
    end 
    if v.iType == 7 then 
      isEnough3 = GameData:Instance():getCurrentPackage():checkEquipBagEnoughSpace(1)
      str = _tr("equip bag is full,clean up?")
    end     
  end 

  if (isEnough1 == false) or (isEnough2 == false) or (isEnough3 == false) then
    local pop = PopupView:createTextPopupWithPath({leftNorBtn = "button-nor-zhengli.png",
                                                   leftSelBtn = "button-sel-zhengli.png",
                                                   text = str,
                                                   leftCallBack = function()
                                                      if isEnough1 == false then
                                                        return self:goToItemView()
                                                      end 
                                                      if isEnough2 == false then 
                                                        return self:goToCardBagView()
                                                      end
                                                      if isEnough3 == false then 
                                                        return self:goToEquipBagView()
                                                      end
                                                  end})
    self:addChild(pop,100)
    needClean = true
  end 

  return needClean
end 

function LivenessWeekView:closeCallback()
  self:close()
end 

function LivenessWeekView:fetchCallback()
  local canFetch = self:canFetchBonus(true)
  if canFetch == false then 
    return canFetch 
  end 
  
   _showLoading()
  echo("=== send msg: AskForLivenessWeekPointGift")
  net.sendMessage(PbMsgId.AskForLivenessWeekPointGift)
  --self.loading = Loading:show()
end 

function LivenessWeekView:fetchBonusResutl(action,msgId,msg)
  echo("---LivenessWeekView:fetchBonusResutl:", msg.state)

--  if self.loading ~= nil then 
--    self.loading:remove()
--    self.loading = nil
--  end
  _hideLoading()

  if msg.state == "Ok" then 
    
    self.bn_fetch:setEnabled(false)

    local tbl = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client_sync)
    if tbl ~= nil then
      local offsetY = (table.getn(tbl) - 1) * 50
      for k,v in pairs(tbl) do 
        echo("---gain: ", v.configId)
        local numStr = string.format("+%d", v.count)
        offsetY = offsetY - 90
        Toast:showIconNumWithDelay(numStr, v.iconId, v.iType, v.configId, ccp(display.width/2, display.height*0.4 + offsetY), 0.5*(k-1))
      end
      
      _playSnd(SFX_ITEM_ACQUIRED)
    end
    GameData:Instance():getCurrentPlayer():setWeekLivenessAwarded(1)
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
    --update tips
    CCNotificationCenter:sharedNotificationCenter():postNotification(EventType.UPDATE_TIP)

  elseif msg.state == "HasReceived" then 
    Toast:showString(self, _tr("has award"), ccp(display.width/2, display.height*0.4))
  elseif msg.state == "NeedPoint" then 
    Toast:showString(self, _tr("not enought liveness"), ccp(display.width/2, display.height*0.4))
  end
end


function LivenessWeekView:goToItemView() -- 跳到行囊界面
  local controller = ControllerFactory:Instance():create(ControllerType.BAG_CONTROLLER)
  controller:enter()
end

function LivenessWeekView:goToCardBagView() -- 跳到卡牌背包界面
  local controller = ControllerFactory:Instance():create(ControllerType.CARDBAG_CONTROLLER)
  controller:enter(false)
end

function LivenessWeekView:goToEquipBagView() -- 跳到装备背包界面
  local controller = ControllerFactory:Instance():create(ControllerType.CARDBAG_CONTROLLER)
  controller:enter(true)
end

function LivenessWeekView:showBonusList()
  
  self.label_value1:setString(string.format("%d - %d", self.bonusInfo[1].minVal, self.bonusInfo[1].maxVal))
  self.label_value2:setString(string.format("%d - %d", self.bonusInfo[2].minVal, self.bonusInfo[2].maxVal))
  self.label_value3:setString(string.format("%d - %d", self.bonusInfo[3].minVal, self.bonusInfo[3].maxVal))
  self.label_value4:setString(string.format("%d - %d", self.bonusInfo[4].minVal, self.bonusInfo[4].maxVal))

  self:showBonusInfo1(self.bonusInfo[1].bonus)
  self:showBonusInfo2(self.bonusInfo[2].bonus)
  self:showBonusInfo3(self.bonusInfo[3].bonus)
  self:showBonusInfo4(self.bonusInfo[4].bonus)
end 


function LivenessWeekView:showBonusInfo1(dataArray)
  local cellWidth = self.node_bonus1:getContentSize().width/4
  local cellHeight = self.node_bonus1:getContentSize().height 
  local dataLen = #dataArray
  local totalCells = math.max(4, dataLen)

  local function tableCellTouched(tableview,cell)
    local idx = cell:getIdx()
    if idx+1 <= dataLen then 
      local configId = dataArray[idx+1].configId
      local x = idx*cellWidth + tableview:getContentOffset().x + cellWidth/2
      local pos = ccp(x, cellHeight+10)      
      TipsInfo:showTip(self.node_bonus1, configId, nil, pos)
    end 
  end
  
  local function cellSizeForTable(tableview,idx)
    return cellHeight,cellWidth
  end
  
  local function numberOfCellsInTableView(tableview)
    return totalCells
  end

  local function tableCellAtIndex(tableview, idx)
    echo("cell index= ", idx)

    local cell = tableview:dequeueCell()
    if cell == nil then 
      cell = CCTableViewCell:new()
    else 
      cell:removeAllChildrenWithCleanup(true)
    end
    if idx+1 <= dataLen then 
      local item = dataArray[idx+1]
      local node = GameData:Instance():getCurrentPackage():getItemSprite(item.iconId, item.iType, item.configId, item.count)
      node:setScale(78/node:getContentSize().width)
      node:setPosition(ccp(cellWidth/2, cellHeight/2))
      cell:addChild(node)
    else 
      local emptyImg = CCSprite:createWithSpriteFrameName("home_huoyuedukuang.png")
      if emptyImg ~= nil then 
        emptyImg:setPosition(ccp(cellWidth/2, cellHeight/2))
        cell:addChild(emptyImg)
      end 
    end 
    return cell
  end
  
  self.node_bonus1:removeAllChildrenWithCleanup(true)
  local tableView = CCTableView:create(self.node_bonus1:getContentSize())
  tableView:setDirection(kCCScrollViewDirectionHorizontal)
  tableView:setTouchPriority(self.priority-1)
  self.node_bonus1:addChild(tableView)

  --tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  tableView:reloadData()
end


function LivenessWeekView:showBonusInfo2(dataArray)
  local cellWidth = self.node_bonus2:getContentSize().width/4
  local cellHeight = self.node_bonus2:getContentSize().height 
  local dataLen = #dataArray
  local totalCells = math.max(4, dataLen)

  local function tableCellTouched(tableview,cell)
    local idx = cell:getIdx() 
    if idx+1 <= dataLen then 
      local configId = dataArray[idx+1].configId
      local x = idx*cellWidth + tableview:getContentOffset().x + cellWidth/2
      local pos = ccp(x, cellHeight+10)      
      TipsInfo:showTip(self.node_bonus2, configId, nil, pos)
    end 
  end
  
  local function cellSizeForTable(tableview,idx)
    return cellHeight,cellWidth
  end

  local function numberOfCellsInTableView(tableview)
    return totalCells
  end

  local function tableCellAtIndex(tableview, idx)
    echo("cell index= ", idx)

    local cell = tableview:dequeueCell()
    if cell == nil then 
      cell = CCTableViewCell:new()
    else 
      cell:removeAllChildrenWithCleanup(true)
    end
    if idx+1 <= dataLen then 
      local item = dataArray[idx+1]
      local node = GameData:Instance():getCurrentPackage():getItemSprite(item.iconId, item.iType, item.configId, item.count)
      node:setScale(78/node:getContentSize().width)
      node:setPosition(ccp(cellWidth/2, cellHeight/2))
      cell:addChild(node)
    else 
      local emptyImg = CCSprite:createWithSpriteFrameName("home_huoyuedukuang.png")
      if emptyImg ~= nil then 
        emptyImg:setPosition(ccp(cellWidth/2, cellHeight/2))
        cell:addChild(emptyImg)
      end 
    end 
    return cell
  end
  
  self.node_bonus2:removeAllChildrenWithCleanup(true)
  local tableView = CCTableView:create(self.node_bonus2:getContentSize())
  tableView:setDirection(kCCScrollViewDirectionHorizontal)
  tableView:setTouchPriority(self.priority-1)
  self.node_bonus2:addChild(tableView)

  --tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  tableView:reloadData()
end

function LivenessWeekView:showBonusInfo3(dataArray)
  local cellWidth = self.node_bonus3:getContentSize().width/4
  local cellHeight = self.node_bonus3:getContentSize().height 
  local dataLen = #dataArray
  local totalCells = math.max(4, dataLen)

  local function tableCellTouched(tableview,cell)
    local idx = cell:getIdx() 
    if idx+1 <= dataLen then 
      local configId = dataArray[idx+1].configId
      local x = idx*cellWidth + tableview:getContentOffset().x + cellWidth/2
      local pos = ccp(x, cellHeight+10)      
      TipsInfo:showTip(self.node_bonus3, configId, nil, pos)
    end 
  end
  
  local function cellSizeForTable(tableview,idx)
    return cellHeight,cellWidth
  end

  local function numberOfCellsInTableView(tableview)
    return totalCells
  end

  local function tableCellAtIndex(tableview, idx)
    echo("cell index= ", idx)

    local cell = tableview:dequeueCell()
    if cell == nil then 
      cell = CCTableViewCell:new()
    else 
      cell:removeAllChildrenWithCleanup(true)
    end
    if idx+1 <= dataLen then 
      local item = dataArray[idx+1]
      local node = GameData:Instance():getCurrentPackage():getItemSprite(item.iconId, item.iType, item.configId, item.count)
      node:setScale(78/node:getContentSize().width)
      node:setPosition(ccp(cellWidth/2, cellHeight/2))
      cell:addChild(node)
    else 
      local emptyImg = CCSprite:createWithSpriteFrameName("home_huoyuedukuang.png")
      if emptyImg ~= nil then 
        emptyImg:setPosition(ccp(cellWidth/2, cellHeight/2))
        cell:addChild(emptyImg)
      end 
    end 
    return cell
  end
  
  self.node_bonus3:removeAllChildrenWithCleanup(true)
  local tableView = CCTableView:create(self.node_bonus3:getContentSize())
  tableView:setDirection(kCCScrollViewDirectionHorizontal)
  tableView:setTouchPriority(self.priority-1)
  self.node_bonus3:addChild(tableView)

  --tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  tableView:reloadData()
end

function LivenessWeekView:showBonusInfo4(dataArray)
  local cellWidth = self.node_bonus4:getContentSize().width/4
  local cellHeight = self.node_bonus4:getContentSize().height 
  local dataLen = #dataArray
  local totalCells = math.max(4, dataLen)

  local function tableCellTouched(tableview,cell)
    local idx = cell:getIdx() 
    if idx+1 <= dataLen then 
      local configId = dataArray[idx+1].configId
      local x = idx*cellWidth + tableview:getContentOffset().x + cellWidth/2
      local pos = ccp(x, cellHeight+10)      
      TipsInfo:showTip(self.node_bonus4, configId, nil, pos)
    end 
  end
  
  local function cellSizeForTable(tableview,idx)
    return cellHeight,cellWidth
  end

  local function numberOfCellsInTableView(tableview)
    return totalCells
  end

  local function tableCellAtIndex(tableview, idx)
    echo("cell index= ", idx)

    local cell = tableview:dequeueCell()
    if cell == nil then 
      cell = CCTableViewCell:new()
    else 
      cell:removeAllChildrenWithCleanup(true)
    end
    if idx+1 <= dataLen then 
      local item = dataArray[idx+1]
      local node = GameData:Instance():getCurrentPackage():getItemSprite(item.iconId, item.iType, item.configId, item.count)
      node:setScale(78/node:getContentSize().width)
      node:setPosition(ccp(cellWidth/2, cellHeight/2))
      cell:addChild(node)
    else 
      local emptyImg = CCSprite:createWithSpriteFrameName("home_huoyuedukuang.png")
      if emptyImg ~= nil then 
        emptyImg:setPosition(ccp(cellWidth/2, cellHeight/2))
        cell:addChild(emptyImg)
      end 
    end 
    return cell
  end
  
  self.node_bonus4:removeAllChildrenWithCleanup(true)
  local tableView = CCTableView:create(self.node_bonus4:getContentSize())
  tableView:setDirection(kCCScrollViewDirectionHorizontal)
  tableView:setTouchPriority(self.priority-1)
  self.node_bonus4:addChild(tableView)

  --tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  tableView:reloadData()
end

function LivenessWeekView:canFetchBonus(bToastNotice)
  local flag = GameData:Instance():getCurrentPlayer():getWeekLivenessAwarded()
  echo("=== fetchCallback: flag=", flag)
  if flag ~= nil and flag > 0 then   
    return false 
  end 

  local prePoint = GameData:Instance():getCurrentPlayer():getPreWeekLivenessVal()
  if prePoint < self.bonusInfo[1].minVal then
    if bToastNotice then 
      Toast:showString(self, _tr("not enought pre-week liveness"), ccp(display.width/2, display.height*0.4))
    end 
    return false 
  end 

  return true 
end 
