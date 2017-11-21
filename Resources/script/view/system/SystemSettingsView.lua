require("view.system.SystemSettingsListItem")
SystemSettingsView = class("SystemSettingsView",BaseView)

function SystemSettingsView:ctor(delegate)
  SystemSettingsView.super.ctor(self)
  self:setNodeEventEnabled(true)
  self:setDelegate(delegate)
  self.listContainer = delegate:getListContainer() 

  local data = nil
  
  
  --if ChannelManager:getCurrentLoginChannel() == 'uc' then  
    data = {5,2,3}
  --else
    --data = {5,1,2,3}
  --end
  --
  if device.platform == "ios" then
  else
     table.insert(data,1,7) -- screen lock
  end
  
  if CDK_ENABLED > 0 then
     table.insert(data,1,4) --cdk
  end
  
  if GameData:Instance():getLanguageType() == LanguageType.JPN then
    table.insert(data,1,9)
    table.insert(data,1,8)
  end
  
--  if device.platform == "ios" then
--  else
--     table.insert(data,1,4)
--  end

  self:setData(data)
end

function SystemSettingsView:onExit()
  if self.tableView ~= nil then
     self.tableView:unregisterAllScriptHandler()
     self.tableView:removeFromParentAndCleanup(true)
  end
  SystemSettingsView.super:onExit()
end

function SystemSettingsView:setData(Data)
  self._listArray = Data
  if self._listArray ~= nil then
     if  self.tableView == nil then
      self:buildTableView()
     end
     self.tableView:reloadData()
  else
     self._listArray = {}
  end
end

function SystemSettingsView:buildTableView()
   self.tableView = nil
   local function scrollViewDidScroll(view)
   -- print("scrollViewDidScroll")
  end
  
  local function scrollViewDidZoom(view)
      print("scrollViewDidZoom")
  end
  
  local function tableCellTouched(table,cell)
      print("cell touched at index: " .. cell:getIdx())

   end
  
   local function cellSizeForTable(table,idx) 
      return 105,550
   end
  
   local function tableCellAtIndex(tableView, idx)
   --echo("CELL:",idx)
      local cell = tableView:dequeueCell()
      if nil == cell then
        cell = CCTableViewCell:new()  
      else
        cell:removeAllChildrenWithCleanup(true)
        cell:reset()
      end
      
      local item = SystemSettingsListItem.new(self._listArray[idx + 1])
      item:setDelegate(self:getDelegate())
  
      cell:setIdx(idx)
      cell:addChild(item)
      return cell
  end
  
   local function numberOfCellsInTableView(val)
     local length = table.getn(self._listArray)
     return length
  end
  
  local mSize = CCSizeMake(self.listContainer:getContentSize().width,self:getDelegate():getDelegate():getScene():getMiddleContentSize().height-self:getDelegate():getEaveContentSize().height -30)

  local tableView = CCTableView:create(mSize)
  tableView:setDirection(kCCScrollViewDirectionVertical)
  tableView:setClippingToBounds(true)
  --tableView:setBounceable(false)
  self.listContainer:addChild(tableView)
  --registerScriptHandler functions must be before the reloadData function
  --tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  tableView:registerScriptHandler(scrollViewDidZoom,CCTableView.kTableViewZoom)
  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)  
  self.tableView = tableView
end

return SystemSettingsView