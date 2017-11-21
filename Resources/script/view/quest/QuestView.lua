require("view.quest.QuestNormalList")
require("view.quest.QuestDailyList")
QuestView = class("QuestView",ViewWithEave)
function QuestView:ctor(controller,quest)
  QuestView.super.ctor(self)
  self:setNodeEventEnabled(true)
  self:setDelegate(controller)
  self.quest = quest
  self._currentIdx = 0
  local dailyTaskOpend = GameData:Instance():checkSystemOpenCondition(2,false)  
  self._enterDailyTaskOpend = dailyTaskOpend
end

function QuestView:onEnter()
  --UIHelper.triggerGuide(10801,CCRectMake(0,0,105,105),emRight)
  QuestView.super:onEnter()
  display.addSpriteFramesWithFile("quest/quest.plist", "quest/quest.png")
  
  local menu1 = {"#mission-button-nor-putongrenwu.png","#mission-button-sel-putongrenwu.png"}
  local menu2 = {"#mission-button-nor-richangrenwu.png","#mission-button-sel-richangrenwu.png"}
  local menuArray = {menu1}
  
  local dailyTaskOpend = self._enterDailyTaskOpend
  if dailyTaskOpend == true then
      table.insert(menuArray,1,menu2)
  end
  
  self:setMenuArray(menuArray)
  
  self:setTitleTextureName("#mission-image-paibian.png")
  
  self._currentView = nil
  self._currentIdx = 0
  self:setScrollBgVisible(false)
  
  local tabMenu = self:getTabMenu():getTableView()
  for i = 1, 2 do
    local targetCell = tabMenu:cellAtIndex(i-1)
    if targetCell ~= nil then
      targetCell:setContentSize(CCSizeMake(135,60))
      _registNewBirdComponent(114000 + i,targetCell)
    end
  end
 
  self:tabControlOnClick(self._currentIdx)
   _executeNewBird()
end

function QuestView:onExit()
  display.removeSpriteFramesWithFile("quest/quest.plist", "quest/quest.png")
  QuestView.super:onExit()
end

function QuestView:buildAwardDetailViewByTask(taskData)
  local detail = QuestAwardDetailView.new()
  detail:setPosition(ccp(ConfigListCellWidth/2,detail.spriteBg:getContentSize().height/2 + 15))
  local dropDatas = taskData:getDropItemDatas()
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
      local dropItemView = DropItemView.new(configId,count)
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
    local scrollView = CCTableView:create(size)
    --scrollView:setContentSize(size)
    scrollView:setDirection(kCCScrollViewDirectionHorizontal)
    --registerScriptHandler functions must be before the reloadData function
    --scrollView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
    --scrollView:registerScriptHandler(scrollViewDidZoom,CCTableView.kTableViewZoom)
    scrollView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
    scrollView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    scrollView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
    scrollView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
    scrollView:reloadData()
    --scrollView:setTouchPriority(-999)
    detail.tableViewCon:addChild(scrollView)
    return detail
end

function QuestView:updateView()
  self:tabControlOnClick(self._currentIdx)
  local allShow = true
  for key, d_task in pairs(Quest:Instance():getDailyTasks()) do
    if d_task:getTaskState() ~= "Show" then
       allShow = false
       break
    end
  end
  if allShow == false then
    _executeNewBird()
  end
  
end

-- toast task award
function QuestView:toastAward(task)
   -- tip go home
   --UIHelper.triggerGuide(11408,CCRectMake(0,0,0,0),emRight)
   --UIHelper.triggerGuide(13410,CCRectMake(0,0,0,0),emLeft)

--   if task == nil then
--      return
--   end
--   
--   if task:getCoin() ~= nil and task:getCoin() > 0 then
--      Toast:showIconAndNum("#playstates-image-qian.png", nil, "+"..task:getCoin())
--   end
--   
--   if task:getCoin() ~= nil and task:getExp() > 0 then
--      Toast:showIconAndNum("#exp_str_icon.png", nil, "+"..task:getExp(),ccp(display.cx,display.cy-80))
--   end
end

function QuestView:onHelpHandler()
  QuestView.super:onHelpHandler()
  local help = HelpView.new()
  help:addHelpBox(1024,nil,true)
  help:addHelpItem(1025, self._currentView.btnRefresh, ccp(0,20), ArrowDir.RightDown)
  self:getDelegate():getScene():addChild(help, 1000)
end

function QuestView:onBackHandler()
  QuestView.super:onBackHandler()
  self:getDelegate():backHandler()
end

function QuestView:tabControlOnClick(idx)
  --UIHelper.triggerGuide(11805,CCRectMake(0,0,0,0),emRight) -- stage difficulty
   
  if self._currentIdx ~= idx then
     QuestView.super:tabControlOnClick(idx)
     --_executeNewBird()
  end
  
  local result = true
  if self._currentView ~= nil then
     self._currentView:removeFromParentAndCleanup(true)
     self._currentView = nil
  end
  
  local dailyTaskOpend = self._enterDailyTaskOpend
  if dailyTaskOpend ~= true then
    idx = idx + 1
    if idx > 1 then
      idx = 1
    end
  else
    if self:getMenuArray() ~= nil and #self:getMenuArray() > 1 then
      self:getTabMenu():setTipImgVisible(2,false)
    end
  end
  
  self:getTabMenu():setTipImgVisible(1,false)
 
  self:getTabMenu():setItemSelectedByIndex(idx + 1)
  
  local hasAward,hasNormalAward,hasDailyAward = self.quest:hasNewAward()

  
  if idx == 1 then
     self:getEaveView().btnHelp:setVisible(false)
     self:getListContainer():removeAllChildrenWithCleanup(true)
     local tasks = self.quest:getNormalTasks()
     local questNormalList = QuestNormalList.new(self,tasks)
     self:getListContainer():addChild(questNormalList)
     self._currentView = questNormalList
     
     if dailyTaskOpend == true then
      self:getTabMenu():setTipImgVisible(1,hasDailyAward)
     end
     
  elseif idx == 0 then
    echo("DailyTask",#self.quest:getDailyTasks())    
    if GameData:Instance():checkSystemOpenCondition(2, false) == false then 
      return 
    end 

     self:getEaveView().btnHelp:setVisible(true)
     
     self:getTabMenu():setTipImgVisible(2,hasNormalAward)
     
     self:getListContainer():removeAllChildrenWithCleanup(true)
     local tasksToShow = {}
     local allDailyTasks = self.quest:getDailyTasks()
     for key, currenTask in pairs(allDailyTasks) do
         local taskState = currenTask:getTaskState()
     	   if taskState == "Show" or taskState == "Accept" or taskState == "Finished" then
     	      table.insert(tasksToShow,currenTask)
     	   end
     end
     
     local questDailyList = QuestDailyList.new(self,tasksToShow,self.quest:getNextFreshTime())
     self:addChild(questDailyList)
     self._currentView = questDailyList
  else
    assert(false,"error idx:"..idx)
  end
  
  self._currentIdx = idx
  return result
end

return QuestView