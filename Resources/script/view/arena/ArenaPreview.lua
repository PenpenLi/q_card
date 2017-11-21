
ArenaPreview = class("ArenaPreview",BaseView)

function ArenaPreview:ctor()
	self:setNodeEventEnabled(true)
	self.UNIT_TAG = 156
	
	self._allMenuItems = {}
	self._lastSelectedIdx = 0
end


function ArenaPreview:onEnter()
  CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self,handler(self,ArenaPreview.notifyUpdate),ArenaConfig.UPDATE_EVENT)
 
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("node_enter","CCNode")
  pkg:addProperty("node_next","CCNode")
  pkg:addProperty("label_timer","CCLabelTTF")
  pkg:addProperty("btn_enter","CCControlButton")
  
  --rank list
  pkg:addProperty("rankListContainer","CCNode")
  pkg:addProperty("nodeTabContainer","CCNode")

  pkg:addFunc("event_enter",ArenaPreview.onClickEnterHandler)
  pkg:addFunc("helpHandler",ArenaPreview.helpHandler)
  

  local layer,owner = ccbHelper.load("Contest_home.ccbi","Contest_homeCCB","CCLayer",pkg)
  self:addChild(layer)
  
  self.node_enter:setVisible(false)
  self.node_next:setVisible(false)
  
  self:updateView()
end


function ArenaPreview:helpHandler()
  local help = HelpView.new()
  help:addHelpBox(1048,nil,true)
  GameData:Instance():getCurrentScene():addChildView(help,1000)
end

function ArenaPreview:onClickEnterHandler()
--	if(ArenaConfig.CurrentRankInfo == nil) then
--		Toast:showString(GameData:Instance():getCurrentScene(),string._tran("player_level_limit"), ccp(display.cx, display.cy))
--		return
--	end

  if ControllerFactory:Instance():getCurrentControllerType() == ControllerType.ARENA_CONTROLLER then
    if self:getDelegate() ~= nil then 
      self:getDelegate():enterArenaView()
      return
    end 
  end

  --create arena controller
  local controller = ControllerFactory:Instance():create(ControllerType.ARENA_CONTROLLER)
  controller:enter()
end

function ArenaPreview:notifyUpdate()
  self:updateView()
end

function ArenaPreview:onExit()
  CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(self,ArenaConfig.UPDATE_EVENT)
  self.tableView = nil
end

function ArenaPreview:updateView()
  self:stopAllActions()
  --[[enum ArenaState{
  ARENA_OPEN = 1;
  ARENA_CLOSE = 2;
  }]]
  
  

  local arena = Arena:Instance()
  
  print("arena sever state:",arena:getSeverState())
  local leftTime = arena:getLeftTime()
  self.label_timer:setString(Clock.format(leftTime,Clock.Type.NODAY))
   
  if arena:getSeverState() == "ARENA_OPEN" then
  	self.node_enter:setVisible(true)
  	self.node_next:setVisible(false)
  else
  	self.node_enter:setVisible(false)
  	self.node_next:setVisible(true)
      leftTime = arena:getLeftTime()
  
      -- update time remain show
      self:schedule(function()
        leftTime = leftTime - 1
        if leftTime <= 0 then
          self:stopAllActions()
      		self.node_enter:setVisible(true)
      		self.node_next:setVisible(false)
          return
        end
        self.label_timer:setString(Clock.format(leftTime,Clock.Type.NODAY))
      end,1)
  end
  
  --self:buildLastRankList()
  self:buildTapList()
  self:buildLastRankList(self._lastSelectedIdx + 1)
end

function ArenaPreview:buildTapList()
    local lastRankLists = Arena:Instance():getLastRankLists()
    
    local function scrollViewDidScroll(tableView)
      local item = self._allMenuItems[self._lastSelectedIdx+1]
      if item ~= nil then
        item:setSelected(true)
      end
    end
    
    local function tableCellTouched(table,cell)
      self:buildLastRankList(cell:getIdx() + 1)
      local idx = cell:getIdx()
      
      local item = self._allMenuItems[self._lastSelectedIdx+1]
      if item ~= nil then
        item:setSelected(false)
      end
      
      item = self._allMenuItems[idx+1]
      if item ~= nil then
        item:setSelected(true)
      end
      
      self._lastSelectedIdx = idx
    end
    
    local function cellSizeForTable(table,idx) 
        return 65,170
    end
    
    local function tableCellHighLight(table, cell)
      local idx = cell:getIdx()
      local item = self._allMenuItems[idx+1]
      if item ~= nil then
        item:setSelected(true)
      end
    end 
  
    local function tableCellUnhighLight(table, cell)
      local idx = cell:getIdx()
      local item = self._allMenuItems[idx+1]
      if item ~= nil then
        item:setSelected(false)
      end
    end
    
    local function tableCellAtIndex(tableview, idx)
      local menuItem = nil 
      local cell = tableview:dequeueCell()
      if nil == cell then
        cell = CCTableViewCell:new()
      else
        cell:removeAllChildrenWithCleanup(true)
      end
      self._allMenuItems[idx+1] = nil
      
      local menuItem = TabControlItem.new()
      cell:addChild(menuItem)
      menuItem:setPositionX(170/2)
      menuItem:setPositionY(65/2)
      menuItem:stopAllActions()
      menuItem:setTag(self.UNIT_TAG)
      
      local nor = display.newSprite("#arena_rank_list_btn.png")
      local highlighted = display.newSprite("#arena_rank_list_btn1.png")
      menuItem:setHighlightedTexture(highlighted)   
      menuItem:setNormalTexture(nor)
      menuItem:setSelected(false)
      
      assert(lastRankLists ~= nil)
      print(#lastRankLists)
      
      local rankId = lastRankLists[idx+1].rankId
      local arenaRankData = AllConfig.arena_rank[rankId]
      local str = arenaRankData.rank_min_lv.."-"..arenaRankData.rank_max_lv
      print("STR:",str)
      local scoreShow = CCLabelTTF:create(str,"Courier-Bold",22,CCSizeMake(200,0),kCCTextAlignmentCenter)
      cell:addChild(scoreShow)
      scoreShow:setPositionX(170/2)
      scoreShow:setPositionY(65/2)
      
      cell:setIdx(idx)
      self._allMenuItems[idx+1] = menuItem
      return cell
    end
    
    local function numberOfCellsInTableView(val)
       return #lastRankLists
    end
    
    local tabTableView = CCTableView:create(self.nodeTabContainer:getContentSize())
    self._tabTableView = tabTableView
    tabTableView:setDirection(kCCScrollViewDirectionHorizontal)
    self.nodeTabContainer:addChild(tabTableView)
  --registerScriptHandler functions must be before the reloadData function
    tabTableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
    tabTableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
    tabTableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    tabTableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
    tabTableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
    tabTableView:registerScriptHandler(tableCellHighLight,CCTableView.kTableCellHighLight)
    tabTableView:registerScriptHandler(tableCellUnhighLight,CCTableView.kTableCellUnhighLight)
    tabTableView:reloadData()
end

function ArenaPreview:buildLastRankList(idx)

  if Arena:Instance():getLastRankLists() == nil 
  or Arena:Instance():getLastRankLists()[idx] == nil then
    return
  end
  
  local list = Arena:Instance():getLastRankLists()[idx].rankList
  self._list = list
  dump(list)
  if list == nil or #list <= 0 then
    return
  end

  if self.tableView ~= nil then
    self.tableView:reloadData()
    return
  end
  
  local function scrollViewDidScroll(view)
    --print("scrollViewDidScroll")
  end
  
  local function scrollViewDidZoom(view)
      print("scrollViewDidZoom")
  end
  
  local function tableCellTouched(table,cell)
      print("cell touched at index: " .. cell:getIdx())
   end
  
   local function cellSizeForTable(table,idx) 
      return 95,280
   end
  
   local function tableCellAtIndex(tableView, idx)
      local cell = tableView:dequeueCell()
      if nil == cell then
        cell = CCTableViewCell:new()  
      else
        cell:removeAllChildrenWithCleanup(true)
      end
      cell:setIdx(idx)
      
      local item = self:buildRankListItem(idx + 1,self._list)
      
      if item ~= nil then
        cell:addChild(item)
        item:setPositionX(70)
        item:setPositionY(50)
      end
      return cell
  end
  
  local function numberOfCellsInTableView(val)
     local length = #self._list
     return length
  end
  
  local mSize = self.rankListContainer:getContentSize()
  local tableView = CCTableView:create(mSize)
  tableView:setDirection(kCCScrollViewDirectionVertical)
  tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  tableView:setClippingToBounds(true)
  
  --tableView:setBounceable(false)
  self.rankListContainer:addChild(tableView)
  --registerScriptHandler functions must be before the reloadData function
  --tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  --tableView:registerScriptHandler(scrollViewDidZoom,CCTableView.kTableViewZoom)
  --tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)  
  tableView:reloadData()
  self.tableView = tableView
end

function ArenaPreview:buildRankListItem(rank,list)
  local playerData = list[rank]
  assert(playerData ~= nil)
  local con = display.newNode()
  
  --rank show
  local rankIcon = nil
  if rank <= 3 then
    rankIcon = display.newSprite("#contest_list_"..rank..".png")
  end
  if rankIcon ~= nil then
     con:addChild(rankIcon)
  else
     local rankShow = CCLabelTTF:create(rank.."","Courier-Bold",22,CCSizeMake(50,0),kCCTextAlignmentCenter)
     con:addChild(rankShow)
  end
  
  --portrait
  local playerPortaitId = playerData:getHeadId()
  local portraitX = 105
  if playerPortaitId > 0 then
    local unitId = toint(playerPortaitId.."01")
    local portraitResId = AllConfig.unit[unitId].unit_head_pic
    local portrait = _res(portraitResId)
    if portrait ~= nil then
       portrait:setScale(0.575)
       con:addChild(portrait)
       portrait:setPositionX(portraitX)
    end
  end
  
  --name
  local nameShow = CCLabelTTF:create(playerData:getName(),"Courier-Bold",22,CCSizeMake(200,0),kCCTextAlignmentCenter)
  con:addChild(nameShow)
  local nameX = portraitX + 155
  nameShow:setPositionX(nameX)
  
  --score
  local scoreShow = CCLabelTTF:create(playerData:getScore().."","Courier-Bold",22,CCSizeMake(200,0),kCCTextAlignmentCenter)
  con:addChild(scoreShow)
  local scoreX = nameX + 145
  scoreShow:setPositionX(scoreX)
  
  return con
end


return ArenaPreview
