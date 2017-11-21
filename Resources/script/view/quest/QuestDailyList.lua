QuestDailyList = class("QuestDailyList",BaseView)
function QuestDailyList:ctor(delegate,data,nextFreshTime)
  QuestDailyList.super.ctor(self)
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("labelRemain","CCLabelTTF")
  pkg:addProperty("labelTime","CCLabelTTF")
  pkg:addProperty("labelFreeRefreshTimes","CCLabelTTF")
  pkg:addProperty("label_taskLeftTimes","CCLabelTTF")
  pkg:addProperty("label_taskRefreshTime","CCLabelTTF")
  pkg:addProperty("nodeBottomSize","CCNode")
  pkg:addProperty("nodeQuestListContainer","CCNode")
  pkg:addProperty("btnRefresh","CCMenuItemImage")
  pkg:addFunc("refreshHandler",QuestDailyList.refreshHandler)

  local layer,owner = ccbHelper.load("QuestDailyListView.ccbi","QuestDailyListViewCCB","CCLayer",pkg)
  self:addChild(layer)
  
  self:setDelegate(delegate)
  self:setData(data)
  self.labelRemain:setString((10 - Quest:Instance():getDailyTaskTimes()).."/10")
  echo("nextFreshTime:",nextFreshTime)
  self.label_taskLeftTimes:setString(_tr("task_left_times"))
  self.label_taskRefreshTime:setString(_tr("task_refresh_time"))
  self.labelTime:setString(_tr("counting"))
  self:startTimeCountDown(nextFreshTime)
  
  self.tipImg = TipPic.new()
  self.btnRefresh:getParent():getParent():addChild(self.tipImg)
  self.tipImg:setPosition(self.btnRefresh:getParent():getPositionX()+65,self.btnRefresh:getParent():getPositionY()+20)
  self.tipImg:setVisible(false)
  
  self._freeTimesLeft = 0
-- --remove free refresh
--  local isVip = GameData:Instance():getCurrentPlayer():isVipState()
--  if isVip == true then
--     self._freeTimesLeft = AllConfig.vipinitdata[2].daily_task_refresh - Quest:Instance():getFreeTaskRefreshTimes()
--  else
--     self._freeTimesLeft = AllConfig.vipinitdata[1].daily_task_refresh - Quest:Instance():getFreeTaskRefreshTimes()
--  end
--  self.labelFreeRefreshTimes:setString("剩余免费刷新次数:"..self._freeTimesLeft)
  
  self.labelFreeRefreshTimes:setString("")
  GameData:Instance():pushViewType(ViewType.quest, 1)
end

function QuestDailyList:onEnter()
  CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self, handler(self,QuestDailyList.enterBackground),"APP_ENTER_BACKGROUND")
  CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self, handler(self,QuestDailyList.enterFoceGround),"APP_WILL_ENTER_FOREGROUND")
end

function QuestDailyList:onExit()
  CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(self, "APP_ENTER_BACKGROUND")
  CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(self, "APP_WILL_ENTER_FOREGROUND")
end

function QuestDailyList:enterBackground()
  self:stopAllActions()
end

function QuestDailyList:enterFoceGround()
    -- self:getDelegate():updateView()
  local leftTime = Quest:Instance():getNextFreshTime()
  self:startTimeCountDown(leftTime)
end

function QuestDailyList:startTimeCountDown(nextFreshTime)
  local curTime = Clock:Instance():getCurServerUtcTime()
  self.leftTime = nextFreshTime - curTime
  echo("TimeLeft:",self.leftTime)
  local enabledCountDown = true
  local updateTimeShow = function()
      if enabledCountDown == false then
        return 
      end
      
      self.leftTime = self.leftTime - 1
      if self.leftTime < 0 then
         enabledCountDown = false
         self.labelTime:setString("00:00:00")
         if Quest:Instance():getDailyTaskTimes() < 10 then
          self.tipImg:setVisible(true)
         end
         
         if self._timerAction ~= nil then
          self:unschedule(self._timerAction)
          self._timerAction = nil
         end
      else 
          if self.leftTime > 86400 then --24*3600
            self.labelTime:setString(_tr("day %{count}", {count = math.ceil(self.leftTime/86400)}))
          else
            local hour = math.floor(self.leftTime/3600)
            local min = math.floor((self.leftTime%3600)/60)
            local sec = math.floor(self.leftTime%60)
            self.labelTime:setString(string.format("%02d:%02d:%02d", hour,min,sec))
          end
          self.tipImg:setVisible(false)
      end
  end

  local timerAction = self:schedule(updateTimeShow,1/1)
  self._timerAction = timerAction
end


function QuestDailyList:refreshHandler()
   _playSnd(SFX_CLICK)
   
   local pop = nil
   
   local tasksInProgressNum = 0
    for key, task in pairs(self:getData()) do
        if task.isDetail ~= true and task:getTaskState() == "Accept" then
           tasksInProgressNum = tasksInProgressNum + 1
        end
    end
 
    if tasksInProgressNum >= 3 then
       pop = PopupView:createTextPopup(_tr("pls_finish_pretask"), function()
          return
       end,true)
       GameData:Instance():getCurrentScene():addChildView(pop,100)
    else
       if Quest:Instance():getDailyTaskTimes() >= 10 then
          pop = PopupView:createTextPopup(_tr("task_all_finish"), function()
            return
          end,true)
          GameData:Instance():getCurrentScene():addChildView(pop,100)
       else
           
           if self.leftTime > 0 then
               if self._freeTimesLeft > 0 then
                  --self:getDelegate():getDelegate():refreshVipFreeDailyTaskTable() --remove free refresh
               else
                  pop = PopupView:createTextPopup(_tr("spent_to_refresh_task?"), function()
                      return self:getDelegate():getDelegate():refreshMoneyDailyTaskTable()
                  end)
                  GameData:Instance():getCurrentScene():addChildView(pop,100)
               end 
           else
               self:getDelegate():getDelegate():refreshFreeDailyTaskTable()
           end
           
       end
    end
    
    
end


function QuestDailyList:setData(Data)
  self._listArray =  nil
  if Data == nil then
    self._listArray = {}
    return
  end
  self._listArray = clone(Data)

  if  self.tableView == nil then
    self:buildTableView()
  end
  self.tableView:reloadData()
end

function QuestDailyList:getData()
  return self._listArray
end

--[[
function QuestDailyList:buildScrollView()

  local listContent = display.newNode()
  listContent:setAnchorPoint(ccp(0,0))
  
  local viewSize = CCSizeMake(self.nodeQuestListContainer:getContentSize().width,self:getDelegate():getCanvasContentSize().height-self.nodeBottomSize:getContentSize().height)
  local scrollView =  CCScrollView:create()
  listContent:setContentSize(viewSize)
  self.nodeQuestListContainer:addChild(scrollView)
  scrollView:setViewSize(viewSize)
  scrollView:setContentSize(listContent:getContentSize())
  scrollView:setDirection(kCCScrollViewDirectionVertical)
  scrollView:setClippingToBounds(true)
  scrollView:setBounceable(true)
  scrollView:setDelegate(self)
  scrollView:setContainer(listContent)
  scrollView:setTouchPriority(-300)
  self._scrollView = scrollView

  self._listContent = listContent
end

function QuestDailyList:updateList(data)
  local viewSize = CCSizeMake(self.nodeQuestListContainer:getContentSize().width,self:getDelegate():getCanvasContentSize().height-self.nodeBottomSize:getContentSize().height)
  self._listContent:removeAllChildrenWithCleanup(true)
  self._listContent:setContentSize(CCSizeMake(self._listContent:getContentSize().width,0))
  self._itemsArray = {}
  for i = 1, #data do
    local item = QuestListItem.new(data[i])
    item:setListDelegate(self)
    item:setDelegate(self:getDelegate():getDelegate())
    self._listContent:addChild(item)
    --item:setPositionY(item:getContentSize().height * (i - 1))
    self._itemsArray[i] = item
    if i == #data then
       item:setIsLastest(true)
    end
  end
  self:resortListPos()
  -- scroll to top
  self._listContent:setPosition(ccp(0, viewSize.height - self._listContent:getContentSize().height))
end

function QuestDailyList:resortListPos(offset)
  if offset == nil then
     offset = 0
  end
  
  self._listContent:setContentSize(CCSizeMake(self._listContent:getContentSize().width,0))
  local posY = 0
  for i = 1, #self._itemsArray do 
     local item = self._itemsArray[#self._itemsArray - (i-1) ]
     item:setPositionY(posY)
     posY = posY + item:getContentSize().height
  end
  self._listContent:setContentSize(CCSizeMake(self._listContent:getContentSize().width,posY))
  self._scrollView:setContentSize(self._listContent:getContentSize())
  self._listContent:setPositionY(self._listContent:getPositionY() + offset)
end

function QuestDailyList:sortLastest()
  local viewSize = CCSizeMake(self.nodeQuestListContainer:getContentSize().width,self:getDelegate():getCanvasContentSize().height-self.nodeBottomSize:getContentSize().height)
  if self._listContent:getContentSize().height > viewSize.height then
     self._listContent:runAction(CCMoveTo:create(0.25,ccp(self._listContent:getPositionX(),0)))
  end
end
]]

function QuestDailyList:buildTableView()
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
      
--      local length = table.getn(self._listArray)
--      local item = QuestListItem.new(self._listArray[length - idx])
--      item:setDelegate(self:getDelegate():getDelegate())
--      
--      
--  
--      cell:setIdx(idx)
--      cell:addChild(item)
--      echo(cell)
      return cell
  end
  
   local function numberOfCellsInTableView(val)
     local length = table.getn(self._listArray)
     return length
  end
  
  local mSize = CCSizeMake(self.nodeQuestListContainer:getContentSize().width,self:getDelegate():getCanvasContentSize().height-self.nodeBottomSize:getContentSize().height)

  local tableView = CCTableView:create(mSize)
  tableView:setDirection(kCCScrollViewDirectionVertical)
  tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  tableView:setClippingToBounds(true)
  --tableView:setBounceable(false)
  self.nodeQuestListContainer:addChild(tableView)
  --registerScriptHandler functions must be before the reloadData function
  tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  tableView:registerScriptHandler(scrollViewDidZoom,CCTableView.kTableViewZoom)
  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)  
  self.tableView = tableView
  
end 

return QuestDailyList