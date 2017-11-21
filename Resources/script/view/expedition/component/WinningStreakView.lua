require("view.expedition.component.KeepWinListItem")
WinningStreakView = class("WinningStreakView",BaseView)

function WinningStreakView:ctor()
	local pkg = ccbRegisterPkg.new(self)
  --pkg:addProperty("bottomSize","CCNode")
  --pkg:addProperty("nodeListContainer","CCNode")
  pkg:addProperty("btnGetKeepWin","CCMenuItemImage")
  pkg:addProperty("labelTip","CCLabelTTF")
  
  pkg:addFunc("onGetKeepWinHandler",WinningStreakView.onGetKeepWinHandler)
  local layer,owner = ccbHelper.load("ExpeditionWinningStreak.ccbi","WinningStreakCCB","CCLayer",pkg)
  self:addChild(layer)
  self._listArray = {}
  self._lastSelectedIdx = 0
  
  self.labelTip:setString("")
  self.btnGetKeepWin:setEnabled(false)
  
--  if GameData:Instance():getExpeditionInstance():getKeepAward() ~= nil and GameData:Instance():getExpeditionInstance():getKeepAward() > 0 then
--     self.labelTip:setString("")
--     self.btnGetKeepWin:setEnabled(true)
--  else
--     self.btnGetKeepWin:setEnabled(false)
--  end
  
end

function WinningStreakView:onGetKeepWinHandler()
   --self:getDelegate():getDelegate():reqAward()
end

function WinningStreakView:setKeepWinRanks(KeepWinRanks)
     echo("KeepWinRanks:",KeepWinRanks,table.getn(KeepWinRanks))
     if KeepWinRanks ~= nil then
        self._listArray = KeepWinRanks
     else
        self._listArray = {}
     end
     
     self:getDelegate():setEmptyImgVisible(#self._listArray < 1)
     
     if self.tableView ~= nil then
        self.tableView:unregisterAllScriptHandler()
     end
     self.nodeListContainer = self:getDelegate():getListContainer()
     self.nodeListContainer:removeAllChildrenWithCleanup(true)
     
     
     self:buildTableView()
end

function WinningStreakView:buildTableView()
  self.tableView = nil
  local function scrollViewDidScroll(view)
    --print("scrollViewDidScroll")
  end
  
  local function scrollViewDidZoom(view)
      print("scrollViewDidZoom")
  end
  
  local function tableCellTouched(table,cell)
      print("cell touched at index: " .. cell:getIdx())

      local lastcell = table:cellAtIndex(self._lastSelectedIdx)
      if nil ~= lastcell then
      end
      self._lastSelectedIdx = cell:getIdx()
   end
  
   local function cellSizeForTable(table,idx) 
      return ConfigListCellHeight,ConfigListCellWidth
   end
  
   local function tableCellAtIndex(tableview, idx)
      local cell = tableview:dequeueCell()
      if nil == cell then
        cell = CCTableViewCell:new()  
      else
        cell:removeAllChildrenWithCleanup(true)
      end

      local item = KeepWinListItem.new(self._listArray[idx+1],idx+1)
      --item:setRank(idx+1)
      item:setDelegate(self:getDelegate():getDelegate())
      cell:setIdx(idx)
      cell:addChild(item)
      
      local cellNum = math.ceil(tableview:getViewSize().height/ConfigListCellHeight)
      UIHelper.showScrollListView({object=item, totalCount=cellNum, index =idx})
      
      return cell
  end
  
   local function numberOfCellsInTableView(val)
     local length = table.getn(self._listArray)
     return length
  end
  
   local mSize = self:getDelegate():getCanvasContentSize()
--  local mSize = CCSizeMake(self.nodeListContainer:getContentSize().width,
--  self:getDelegate():getDelegate():getScene():getMiddleContentSize().height-self:getDelegate():getEaveContentSize().height-120-100)

  local tableView = CCTableView:create(mSize)
  tableView:setDirection(kCCScrollViewDirectionVertical)
  tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  tableView:setClippingToBounds(true)
  --tableView:setBounceable(false)
  self.nodeListContainer:addChild(tableView)
  --registerScriptHandler functions must be before the reloadData function
  tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  tableView:registerScriptHandler(scrollViewDidZoom,CCTableView.kTableViewZoom)
  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)  
  tableView:reloadData()
  self.tableView = tableView
end

return WinningStreakView