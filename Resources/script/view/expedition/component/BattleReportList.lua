require("view.expedition.component.BattleReportItem")
BattleReportList = class("BattleReportList",BaseView)

function BattleReportList:ctor()
  BattleReportList.super.ctor(self)
  self._lastSelectedIdx = 0
  self.listContainer = display.newNode()
  self.listContainer:setContentSize(CCSizeMake(590,560))
  self:addChild(self.listContainer)
  self._listArray = {}
end

function BattleReportList:setReports(reports)
   if reports ~= nil then
      self._listArray = reports
      if self.tableView ~= nil then
         self.tableView:reloadData()
      end
   else
      self._listArray = {}
   end
   self:getDelegate():setEmptyImgVisible(#self._listArray < 1)
end

function BattleReportList:enter()
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
  
   local function tableCellAtIndex(tableView, idx)
      local cell = tableView:dequeueCell()
      if nil == cell then
        cell = CCTableViewCell:new()  
      else
        cell:removeAllChildrenWithCleanup(true)
        cell:reset()
      end
      
      local item = BattleReportItem.new(self._listArray[#self._listArray-idx])
      --the templete select before make sure btn
      if idx == self._lastSelectedIdx then
        item:setSelected(true)
      else 
        item:setSelected(false)
      end
      
      cell:setIdx(idx)
      cell:addChild(item)
      
      local cellNum = math.ceil(tableView:getViewSize().height/ConfigListCellHeight)
      UIHelper.showScrollListView({object=item, totalCount=cellNum, index =idx})
      
      return cell
  end
  
  local function numberOfCellsInTableView(val)
     local length = table.getn(self._listArray)
     return length
  end
  

  local mSize = self:getDelegate():getCanvasContentSize()
  local tableView = CCTableView:create(mSize)
  tableView:setDirection(kCCScrollViewDirectionVertical)
  tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  tableView:setClippingToBounds(true)
  
  
  
  
  --tableView:setBounceable(false)
  self.listContainer:addChild(tableView)
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

return BattleReportList