require("view.quest.QuestListItem")
QuestNormalList = class("QuestNormalList",BaseView)
function QuestNormalList:ctor(delegate,data)
   self:setDelegate(delegate)
   self.listContainer = delegate:getListContainer()
   self:setData(data)

   GameData:Instance():pushViewType(ViewType.quest, 0)
end

function QuestNormalList:setData(Data)
  self._listArray =  nil
  if Data == nil then
    self._listArray = {}
    return
  end
	self._listArray = clone(Data)
	echo("QuestNormalListData:",Data,table.getn(Data))

  if  self.tableView == nil then
    self:buildTableView()
  end
  self.tableView:reloadData()
end

function QuestNormalList:buildTableView()
   self.tableView = nil
   local function scrollViewDidScroll(view)
   -- print("scrollViewDidScroll")
  end
  
  local function scrollViewDidZoom(view)
      print("scrollViewDidZoom")
  end
  
  local function tableCellTouched(tableview,cell)
      print("cell touched at index: " .. cell:getIdx())
      local sliderV = tableview:getContentOffset().y
      if self._listArray[cell:getIdx() + 1].isDetail == true then
        printf("click detail")
      else
        if self._listArray[cell:getIdx() + 1].isOpen == true then
          --printf("remove element")
          self._listArray[cell:getIdx() + 1].isOpen = false
          table.remove(self._listArray,cell:getIdx() + 2)
          --print(#self._listArray)
          --tableview:removeCellAtIndex(cell:getIdx() + 1)
          sliderV = sliderV + ConfigListCellHeight
        else
          local taskData = self._listArray[cell:getIdx() + 1]
          if #taskData:getDropItemDatas() <= 0 then
             return
          end
          --printf("add element")
          self._listArray[cell:getIdx() + 1].isOpen = true 
          table.insert(self._listArray,cell:getIdx() + 2,{isDetail = true,taskData = taskData })
          --print(#self._listArray)
          --tableview:insertCellAtIndex(cell:getIdx() + 1)
          sliderV = sliderV - ConfigListCellHeight
        end
        tableview:reloadData()
        tableview:setContentOffset(ccp(0,sliderV))
      end
  end
  
   local function cellSizeForTable(table,idx) 
      return ConfigListCellHeight,ConfigListCellWidth
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
      
      local itemData = self._listArray[idx + 1]
      local item = nil
      if itemData.isDetail == true then
        item = self:getDelegate():buildAwardDetailViewByTask(itemData.taskData)
      else
        item = QuestListItem.new(itemData,idx)
        item:setDelegate(self:getDelegate():getDelegate())
      end
      
      cell:setIdx(idx)
      if item ~= nil then
         cell:addChild(item)
      end
      return cell
  end 
  
   local function numberOfCellsInTableView(val)
     local length = #self._listArray
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
  self.tableView = tableView
   
end 


return QuestNormalList