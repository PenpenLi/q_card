require("view.BaseView")
require("view.component.Loading")
require("view.activity.ActivityBossListItem")

ActivityBossListView = class("ActivityBossListView", BaseView)


function ActivityBossListView:ctor()

  ActivityBossListView.super.ctor(self)

  --1. load levelup view ccbi
  local pkg = ccbRegisterPkg.new(self)

  pkg:addProperty("node_listContainer","CCNode")

  local layer,owner = ccbHelper.load("ActivityBossListView.ccbi","ActivityBossListViewCCB","CCLayer",pkg)
  self:addChild(layer)
end

function ActivityBossListView:init()
  echo("---ActivityBossListView:init---")

  net.registMsgCallback(PbMsgId.BossFightStateS2C, self, ActivityBossListView.updateBossListByState)
  
  
  --init list size
  local topHeight = self:getDelegate():getTopMenuSize().height
  local bottomHeight = self:getDelegate():getScene():getBottomContentSize().height
  local h3 = display.height - topHeight - bottomHeight
  self.node_listContainer:setContentSize(CCSizeMake(634, h3))
  self.node_listContainer:setPosition(ccp((display.width-634)/2, bottomHeight))


  --show boss list
  local bossArray = Activity:instance():getRecentBoss()
  UIHelper.setIsNeedScrollList(true)
  self:showBossList(bossArray)
end

function ActivityBossListView:onEnter()
  echo("---ActivityBossListView:onEnter---")
  self:init()
  CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self, handler(self,ActivityBossListView.enterForeground),"APP_WILL_ENTER_FOREGROUND")
  CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self, handler(self,ActivityBossListView.updateBossListByState), EventType.BOSS_UPDATE)
end

function ActivityBossListView:onExit()
  echo("---ActivityBossListView:onExit---")
  net.unregistAllCallback(self)
  CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(self, "APP_WILL_ENTER_FOREGROUND")
  CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(self, EventType.BOSS_UPDATE)
end

function ActivityBossListView:updateBossListByState(action,msgId,msg)
  echo("ActivityBossListView:updateBossListByState:")
  local boss = Activity:instance():getRecentBoss()
  self:showBossList(boss)
end

function ActivityBossListView:showBossList(bossArray)
  echo("showBossList")

  -- local function scrollViewDidScroll(view)
  -- end

  local function tableCellTouched(tableview,cell)
    local idx = cell:getIdx()
    echo("=======boss id", bossArray[idx+1]:getId(), bossArray[idx+1]:getName())
  end
  
  local function cellSizeForTable(tableview,idx)
    return self.cellHeight,self.cellWidth
  end
  
  local function tableCellAtIndex(tableview, idx)
    -- echo("cellAtIndex = "..idx)
    local cell = tableview:dequeueCell()
    if nil == cell then
      cell = CCTableViewCell:new()
    else
      cell:removeAllChildrenWithCleanup(true)
    end

    local node = ActivityBossListItem.new(bossArray[idx+1])
    node:setDelegate(self:getDelegate())
    cell:addChild(node)

    if self.cellNumPerPage > 0 then 
      UIHelper.showScrollListView({object=node, totalCount=self.cellNumPerPage, index = idx, totalCells = self.totalCells})
    end 

    return cell
  end
  
  local function numberOfCellsInTableView(tableview)
    return self.totalCells
  end


  if bossArray == nil then
    echo("empty list data !!!")
    return
  end

  local size = self.node_listContainer:getContentSize()
  self.cellWidth = size.width
  self.cellHeight = 190
  self.totalCells = table.getn(bossArray)

  echo("remove old tableview")
  self.node_listContainer:removeAllChildrenWithCleanup(true)
  
  self.cellNumPerPage = math.ceil(size.height/self.cellHeight)
  if self.cellNumPerPage == 0 then 
    UIHelper.setIsNeedScrollList(false)
  end
  
  -- if self.totalCells == 0 then 
  --   self:setEmptyImgVisible(true)
  -- else 
  --   self:setEmptyImgVisible(false)
  -- end

  self.tableView = CCTableView:create(size)
  self.tableView:setDirection(kCCScrollViewDirectionVertical)
  self.node_listContainer:addChild(self.tableView)

  -- self.tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  self.tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  self.tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  self.tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  self.tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)

  self.tableView:reloadData()
end

function ActivityBossListView:enterForeground()
  echo("---enterForeground---")

  local function timerCallback()
    local boss = Activity:instance():getRecentBoss()
    UIHelper.setIsNeedScrollList(false)
    self:showBossList(boss)
  end 
  self:performWithDelay(timerCallback, 0.5)
end
