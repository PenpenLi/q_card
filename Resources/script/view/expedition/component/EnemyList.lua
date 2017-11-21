require("view.expedition.component.EnemyListItem")
EnemyList = class("EnemyList",BaseView)

function EnemyList:ctor(expedtionView,enemys)
  EnemyList.super.ctor(self)
  self:setDelegate(expedtionView)
  self._lastSelectedIdx = 0
  self._listArray = {}
  self.listContainer = expedtionView:getListContainer()
  self:buildTableView()
  if enemys ~= nil then
     self:setEnemys(enemys)
  end
end

function EnemyList:setEnemys(enemys)
    if enemys ~= nil then
        self._listArray = enemys
     else
        self._listArray = {}
     end
     
     self:getDelegate():setEmptyImgVisible(#self._listArray < 1)
     
     if self.tableView ~= nil then
        self.tableView:unregisterAllScriptHandler()
     end
     self.listContainer:removeAllChildrenWithCleanup(true)
     
     self:buildTableView()
end

function EnemyList:getEnemys()
    return  self._listArray
end

function EnemyList:buildTableView()
   self.tableView = nil
   local function scrollViewDidScroll(view)
   -- print("scrollViewDidScroll")
  end
  
  local function scrollViewDidZoom(view)
      print("scrollViewDidZoom")
  end
  
  local function tableCellTouched(table,cell)
      print("cell touched at index: " .. cell:getIdx())

      local lastcell = table:cellAtIndex(self._lastSelectedIdx)
      if nil ~= lastcell then
        --lastcell:getChildByTag(123):setSelected(false)
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
        cell:reset()
      end
      
      local item = EnemyListItem.new(self._listArray[#self._listArray - idx])
      item:setDelegate(self:getDelegate():getDelegate())
      --the templete select before make sure btn
      if idx == self._lastSelectedIdx then
        item:setSelected(true)
      else 
        item:setSelected(false)
      end
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


return EnemyList