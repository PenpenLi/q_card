

require("model.Achievement.Achievement")
require("view.achievement.AchievementListCellView")
require("view.achievement.OfficeAchievementView")

AchievementView = class("AchievementView",ViewWithEave)

function AchievementView:ctor()
  AchievementView.super.ctor(self)

  self.priority = -200 

end

function AchievementView:onEnter()
  echo("=== AchievementView:onEnter")
  net.registMsgCallback(PbMsgId.AskForAchievementDropResult,self,AchievementView.fetchBonusResult)
  CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("img/Achievement/achievement.plist")
  local menuArray = {
                      {"#friend-button-nor-guanzhi.png","#friend-button-sel-guanzhi.png"},
                      {"#achievements-button-nor-zonghechengjiu.png","#achievements-button-sel-zonghechengjiu.png"},
                      {"#achievements-button-nor-zhanyichengjiu.png","#achievements-button-sel-zhanyichengjiu.png"} ,
                      {"#achievements-button-nor-zhengzhanchengjiu.png","#achievements-button-sel-zhengzhanchengjiu.png"},
                      {"#achievements-button-nor-shoujichengjiu.png","#achievements-button-sel-shoujichengjiu.png"},
                      {"#0VIP.png","#0VIP1.png"}
                    }
  self:setMenuArray(menuArray)
  self:setTitleTextureName("achievements-image-paibian.png")
  self:getEaveView().btnHelp:setVisible(false)


  self:initLabel()

  --show list
  self:showViewByType(self:getDelegate():getCurViewType())

  --综合成就引导
  local cell = self:getTabMenu():getTableView():cellAtIndex(1)
  if cell ~= nil then 
    cell:setContentSize(CCSizeMake(135, 60))
    _registNewBirdComponent(120102, cell)
    _executeNewBird()
  end 
end

function AchievementView:onExit()
  CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("img/Achievement/achievement.plist")
  net.unregistAllCallback(self)
end

function AchievementView:tabControlOnClick(idx)
  _playSnd(SFX_CLICK) 

  local result = true
  if idx == 0 then
    result = self:showViewByType(AchievementType.Official)
  elseif idx == 1 then 
    result = self:showViewByType(AchievementType.Comprehensive)
  elseif idx == 2 then
    result = self:showViewByType(AchievementType.PVE)
  elseif idx == 3 then
    result = self:showViewByType(AchievementType.PVP)
  elseif idx == 4 then
    result = self:showViewByType(AchievementType.COLLECT)
  elseif idx == 5 then
    result = self:showViewByType(AchievementType.VIP)      
  end
  
  return result
end

function AchievementView:onBackHandler()
  AchievementView.super:onBackHandler()
  self:getDelegate():goBackView()
end

function AchievementView:showViewByType(achType) 
  -- if Achievement:instance():checkEntryCondition(achType) == false then 
  --   return false 
  -- end 

  echo("=== showViewByType:", achType)

  self:resetViewByType(achType)
  self:getDelegate():setCurViewType(achType)
  GameData:Instance():pushViewType(ViewType.achievement, achType)

  if achType == AchievementType.Official then 
    self.officialView = OfficeAchievementView.new()
    self.officialView:setDelegate(self:getDelegate())
    self:getNodeContainer():addChild(self.officialView)
  else 
    self.curListData = Achievement:instance():getAchDataByType(achType) 
    self:showListView()
  end 
  
  self:highlightMenuItem(achType)
  self:showMenuTips()

  return true 
end 

function AchievementView:highlightMenuItem(achType)
  local menuIdx = 1 

  if achType == AchievementType.Official then 
    menuIdx = 1 
  elseif achType == AchievementType.Comprehensive then 
    menuIdx = 2 
  elseif achType == AchievementType.PVE then 
    menuIdx = 3 
  elseif achType == AchievementType.PVP then 
    menuIdx = 4 
  elseif achType == AchievementType.COLLECT then 
    menuIdx = 5 
  elseif achType == AchievementType.VIP then 
    menuIdx = 6 
  end 

  self:getTabMenu():setItemSelectedByIndex(menuIdx) 
end 

function AchievementView:resetViewByType(achType)
  if self.officialView ~= nil then 
    self.officialView:removeFromParentAndCleanup(true)
    self.officialView = nil 
  end   

  if achType == AchievementType.Official then 
    self.listContainer:removeAllChildrenWithCleanup(true)
    self.preTotalPoint:setVisible(false)
    self.totalPoint:setVisible(false)
  else 
    self.preTotalPoint:setVisible(true)
    self.totalPoint:setVisible(true)
    self.totalPoint:setString(""..Achievement:instance():getCurAchievementPoint())
  end 
end 

function AchievementView:initLabel()
  --create list node & label 
  self.listContainer = display.newNode()
  self:addChild(self.listContainer)
  self.preTotalPoint = CCLabelTTF:create(_tr("achievement_points"),"Courier-Bold",24)
  self.totalPoint = CCLabelTTF:create("","Courier-Bold",24)
  self:addChild(self.preTotalPoint)
  self:addChild(self.totalPoint)

  --set size & pos  
  local labelHeight = 40 
  local bottomHeight = self:getDelegate():getScene():getBottomContentSize().height
  local list_h = self:getCanvasContentSize().height - labelHeight
  self.listContainer:setPosition(ccp((display.width-640)/2, bottomHeight+labelHeight))
  self.listContainer:setContentSize(CCSizeMake(640, list_h))

  self.preTotalPoint:setHorizontalAlignment(kCCTextAlignmentRight)
  self.preTotalPoint:setAnchorPoint(ccp(1.0, 0.5))
  self.preTotalPoint:setPosition(ccp(display.cx+200, bottomHeight+labelHeight/2))
  self.totalPoint:setHorizontalAlignment(kCCTextAlignmentLeft)
  self.totalPoint:setAnchorPoint(ccp(0, 0.5))        
  self.totalPoint:setPosition(ccp(display.cx+200, bottomHeight+labelHeight/2))
end 

function AchievementView:showMenuTips()
  local flag 
  local curtype = self:getDelegate():getCurViewType()
  for iType=1, AchievementType.TypeMax do  
    if iType-1 ~= curtype then 
      flag = Achievement:instance():hasNewEvent(iType-1)
      self:getTabMenu():setTipImgVisible(iType, flag)
    else 
      self:getTabMenu():setTipImgVisible(iType, false)
    end 
  end 
end 


function AchievementView:showListView()

  local function tableCellTouched(tableview,cell)
    echo("tableCellTouched")
    self:setIsValidTouch(true)
  end

  local function cellSizeForTable(table,idx)
    return self.cellHeight, self.cellWidth
  end
  
  local function tableCellAtIndex(tableView, idx)
    local item = nil   
    local cell = tableView:dequeueCell()
    if nil == cell then
      cell = CCTableViewCell:new() 
      item = AchievementListCellView.new()
      item:setDelegate(self)
      item:setData(self.curListData[idx+1])
      item:updateInfos()
      item:setIdx(idx)
      item:setTag(100)
      cell:addChild(item) 
    else 
      item = cell:getChildByTag(100)
      if item ~= nil then
        item:setIdx(idx) 
        item:setData(self.curListData[idx+1])
        item:updateInfos()
      end      
    end
    
    return cell
  end

  local function numberOfCellsInTableView(val)
    return #self.curListData
  end

  self.cellWidth = 640 
  self.cellHeight = 175

  self:setEmptyImgVisible(self.totalCells == 0)

  self.listContainer:removeAllChildrenWithCleanup(true)

  self.tableView = CCTableView:create(self.listContainer:getContentSize())
  self.listContainer:addChild(self.tableView)
  self.tableView:setTouchPriority(self.priority) 
  self.tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  self.tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  self.tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  self.tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  self.tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  self.tableView:reloadData()

  self.totalPoint:setString(""..Achievement:instance():getCurAchievementPoint())
end

function AchievementView:fetchBonusReq(idx, configId)
  echo("====fetchBonusReq:", configId)
  self.touchIdx = idx 
  local data = PbRegist.pack(PbMsgId.AskForAchievementDrop,{config_id = configId})
  net.sendMessage(PbMsgId.AskForAchievementDrop,data)

  self:addMaskLayer()
end 

function AchievementView:fetchBonusResult(action,msgId,msg)
  echo("fetchBonusResult", msg.state)
  
  if msg.state == "Ok" then 
    --toast bonus
    local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client_sync)
    for i = 1,table.getn(gainItems) do
      local str = string.format("+%d", gainItems[i].count)
      Toast:showIconNumWithDelay(str, gainItems[i].iconId, gainItems[i].iType, gainItems[i].configId, ccp(display.cx,display.cy-i*40), 0.3*(i-1))
    end

    --update state
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
    self.curListData[self.touchIdx+1]:setIsAwarded(true)

    if self.tableView ~= nil then 
      -- self.tableView:updateCellAtIndex(self.touchIdx)
      self.curListData = Achievement:instance():getAchDataByType(self:getDelegate():getCurViewType()) 
      self.tableView:reloadData()
    end 
  else 
    Achievement:instance():handleErrorCode(msg.state)
  end 

  self:removeMaskLayer()
end 

function AchievementView:setIsValidTouch(isValidTouch)
  self._isTouchInView = isValidTouch
end 

function AchievementView:getIsValidTouch()
  return self._isTouchInView 
end

function AchievementView:addMaskLayer()
  echo("=== addMaskLayer")
  self:removeMaskLayer()

  self.maskLayer = Mask.new({opacity=0, priority = -1000})
  self:addChild(self.maskLayer)

  self.maskAction = self:performWithDelay(handler(self, AchievementView.removeMaskLayer), 6.0)
end 

function AchievementView:removeMaskLayer()
  echo("=== removeMaskLayer")
  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
    self.maskLayer = nil

    if self.maskAction ~= nil then 
      self:stopAction(self.maskAction)
      self.maskAction = nil 
    end 
  end 
end 

return AchievementView