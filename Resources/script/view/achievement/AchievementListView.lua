
require("view.achievement.AchievementListCellView")

AchievementListView = class("AchievementListView", BaseView)


function AchievementListView:ctor()
end

function AchievementListView:setData(Data)
	self._listArray =  {}
  if Data == nil then
    return
  end
dump(Data, "=========Data")

  --剔除掉已完成项
  local count = 1
  for i=1, #Data do 
    if Data[i].data.isGet < 1 then 
      self._listArray[count] = Data[i]
      count = count + 1 
    end 
  end 

  if self._tableView == nil then
    self:buildTableView()
  end
  self._tableView:reloadData()
end

function AchievementListView:getData()
	return self._listArray
end

function AchievementListView:buildTableView()
  
  local function tableCellTouched(tableview,cell)

  end

  local function cellSizeForTable(table,idx)
    return 175, 640
  end
  
  local function tableCellAtIndex(tableView, idx)
    local item = nil   
    local cell = tableView:dequeueCell()
    if nil == cell then
      cell = CCTableViewCell:new() 
      item = AchievementListCellView.new()
      item:setDelegate(self:getDelegate())
      item:setData(self._listArray[idx+1].data)
      item:setIdx(idx)
      item:setTag(100)
      cell:addChild(item) 
    else 
      item = cell:getChildByTag(100)
      if item ~= nil then
        item:setIdx(idx) 
        item:setData(self._listArray[idx+1].data)
        item:updateInfos()
      end      
    end
    
    return cell
  end

  local function numberOfCellsInTableView(val)
    local length = 0
    if #self._listArray > 0 then
      length = #self._listArray
    end
    return length
  end


  local parent = self:getDelegate()
  if #self._listArray == 0 then
    parent:setEmptyImgVisible(true)
  else
    parent:setEmptyImgVisible(false)
  end

  self._listContainer = display.newNode()
  self._listContainer:setPosition(ccp((display.width-640)/2.0,175))
  self:addChild(self._listContainer)
  local mSize = parent:getCanvasContentSize()
  self._listContainer:setContentSize(CCSizeMake(640,mSize.height-45))
  self._firstShowCellNum = math.ceil((mSize.height-45) /ConfigListCellHeight )
  self._tableView = CCTableView:create(self._listContainer:getContentSize())
  self._listContainer:addChild(self._tableView)
  self._tableView:setVerticalFillOrder(kCCTableViewFillTopDown)

  self._tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  self._tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  self._tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  self._tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  self._tableView:reloadData()
end

function AchievementListView:buildAwardDetailViewByTask(data)
  local detail = QuestAwardDetailView.new()
  detail:setPosition(ccp(ConfigListCellWidth/2,detail.spriteBg:getContentSize().height/2 + 15))
  local dropDatas = data:getDropItemDatas()
   local configIdArr = {}
   local function tableCellTouched(tableView,cell)
      local target = cell:getChildByTag(123)
      if target ~= nil then 
        --local size = target:getContentSize()
        local posOffset = ccp(45, 100)
        if target ~= nil then
           TipsInfo:showTip(cell,configIdArr[cell:getIdx()+1], nil, posOffset)
        end
      end
    end
  
    local function cellSizeForTable(tableView,idx)
      return 100,100
    end
  
    local function tableCellAtIndex(tableView, idx)
      local cell = tableView:cellAtIndex(idx)
      if nil == cell then
        cell = CCTableViewCell:new()
      else
        cell:removeAllChildrenWithCleanup(true)
      end

      local type = dropDatas[idx + 1].array[1]
      local configId = dropDatas[idx + 1].array[2]
      local count = dropDatas[idx + 1].array[3]
      
      local dropItemView = DropItemView.new(configId,count,type)
      configIdArr[idx+1] = configId

      if dropItemView ~= nil then
       dropItemView:setPositionX(50)
       dropItemView:setPositionY(50)
       dropItemView:setTag(123)
       cell:addChild(dropItemView)
      end
         
      return cell
    end
  
    local function numberOfCellsInTableView(tableView)
      return #dropDatas
    end

    --build tableview
    local size = detail.tableViewCon:getContentSize()
    self._scrollView = CCTableView:create(size)
    self._scrollView:setDirection(kCCScrollViewDirectionHorizontal)
    self._scrollView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
    self._scrollView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    self._scrollView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
    self._scrollView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
    self._scrollView:reloadData()
    --self._scrollView:setTouchPriority(-999)
    detail.tableViewCon:addChild(self._scrollView)
    return detail
end

function AchievementListView:onExit()
  self._listArray = nil
end

return AchievementListView
