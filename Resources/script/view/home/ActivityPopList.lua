
require("view.BaseView")



ActivityPopList = class("ActivityPopList", BaseView)

function ActivityPopList:ctor()
  ActivityPopList.super.ctor(self)

  CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("img/activity/pop_zhongqiu.plist")
end

function ActivityPopList:init(isAutoClose)

  local function closeCallback()
    self:removeFromParentAndCleanup(true)
  end 

  --bg img 
  self.bgImg = CCSprite:create("img/activity/act_pop_list_bg.png")
  if self.bgImg == nil then 
    return false 
  end

  --mask layer
  self.touchPriority = -600
  local colorLayer = CCLayerColor:create(ccc4(0, 0, 0, 200))
  self:addChild(colorLayer)

  self.bgImg:setPosition(display.cx, display.cy)
  self:addChild(self.bgImg)

  local size = self.bgImg:getContentSize()

  --top circle anim
  local imgCircle = _res(3022057)
  if imgCircle ~= nil then
    imgCircle:setPosition(ccp(size.width/2, size.height-40))
    local action = CCRotateBy:create(2.7, 360)
    imgCircle:runAction(CCRepeatForever:create(action))
    self.bgImg:addChild(imgCircle,-1)
  end 

  --top star anim
  local starAnim = _res(6010020)
  if starAnim ~= nil then 
    starAnim:setPosition(ccp(size.width/2, size.height-40))
    self.bgImg:addChild(starAnim, 10)
  end

  --close menu
  local menu = CCMenu:create()
  menu:setTouchPriority(self.touchPriority-1)
  menu:setAnchorPoint(ccp(0.5,0.5))
  local menuItem = CCMenuItemImage:create()
  local norFrame =  display.newSpriteFrame("pop_zhongqiu_close0.png")
  local selFrame =  display.newSpriteFrame("pop_zhongqiu_close1.png")
  menuItem:setNormalSpriteFrame(norFrame)
  menuItem:setSelectedSpriteFrame(selFrame)
  menuItem:registerScriptTapHandler(closeCallback)
  menu:addChild(menuItem)

  menu:setPosition(ccp(size.width-65, size.height-60))
  self.bgImg:addChild(menu, 1)

  --list
  self.actData = Activity:instance():getActivityPopList()
  self.cellWidth = 550
  self.cellHeight = 150
  self.totalCells = #self.actData
  echo("=== act len= ", self.totalCells)

  local listSize = CCSizeMake(self.cellWidth, size.height-108)
  self.node_container = CCNode:create()
  self.node_container:setContentSize(listSize)
  self.node_container:setPosition(ccp((size.width-listSize.width)/2+2, 12))
  self.bgImg:addChild(self.node_container, 10)

  self:showActList(self.actData)

  --reg touch event
  if isAutoClose == true then 
    self:addTouchEventListener(function(event, x, y)
                                  if event == "began" then
                                    self.preTouchFlag = self:checkTouchOutsideView(x, y)
                                    return true
                                  elseif event == "ended" then
                                    local curFlag = self:checkTouchOutsideView(x, y)
                                    if self.preTouchFlag == true and curFlag == true then
                                      echo(" touch out of region: close popup") 
                                      closeCallback()
                                    end 
                                  end
                              end,
                false, self.touchPriority, true)
    self:setTouchEnabled(true)
  end 

  return true 
end 

function ActivityPopList:create(isAutoClose)
  local pop = ActivityPopList.new()
  local result = pop:init(isAutoClose)
  if result then 
    -- pop.node_content:setScale(0.2)
    -- pop.node_content:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6))
    return pop 
  end 

  return nil 
end 

function ActivityPopList:onEnter()

end 

function ActivityPopList:onExit()
  echo("===ActivityPopList:onExit")
  GameData:Instance():setInitSysComplete(true) 
end 

function ActivityPopList:checkTouchOutsideView(x, y)
  --outside check 
  local size2 = self.bgImg:getContentSize()
  local pos2 = self.bgImg:convertToNodeSpace(ccp(x, y))
  if pos2.x < 0 or pos2.x > size2.width or pos2.y < 0 or pos2.y > size2.height then 
    return true 
  end

  return false  
end 

function ActivityPopList:showActList(itemArray)

  local function tableCellTouched(tbView,cell)
    local idx = cell:getIdx()
    local actId = itemArray[idx+1].activity_id
    echo(" tableCellTouched, idx, actId=", idx, actId)
    local ret = Activity:instance():gotoViewByActId(actId)
    if ret then 
      self:removeFromParentAndCleanup(true)
    end 
  end
  
  local function tableCellAtIndex(tbView, idx)
    local cell = tbView:dequeueCell()
    if nil == cell then
      cell = CCTableViewCell:new()
    else
      cell:removeAllChildrenWithCleanup(true)
    end
    local resId = itemArray[idx+1].activity_show[2]
    
    local img = _res(resId)
    echo("resId, img", resId, img)
    if img ~= nil then 
      img:setPosition(self.cellWidth/2, self.cellHeight/2)
      cell:addChild(img)
    end 

    return cell
  end

  local function cellSizeForTable(tbView,idx)
    return self.cellHeight, self.cellWidth
  end 

  local function numberOfCellsInTableView(tbView)
    return self.totalCells
  end

  echo("remove old tableview")
  self.node_container:removeAllChildrenWithCleanup(true)
  local size = self.node_container:getContentSize()

  --create tableview
  local tableView = CCTableView:create(size)
  tableView:setDirection(kCCScrollViewDirectionVertical)
  tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  tableView:setTouchPriority(self.touchPriority-1)
  self.node_container:addChild(tableView)

  --tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)

  tableView:reloadData()
end 

