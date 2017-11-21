require("model.quest.Task")
require("view.quest.QuestPopAwardView")
Quest = class("Quest")
function Quest:ctor()
  self:initTasks()
  self:setIsAllMainTaskFinished(false)
  self:registNetSever()
end

function Quest:initTasks()
  local localTasks = {}
  for key, task in pairs(AllConfig.task) do
  	  localTasks[task.task_id] = task
  end
  self:setLocalTasks(localTasks)
end

------
--  Getter & Setter for
--      Quest._LocalTasks 
-----
function Quest:setLocalTasks(LocalTasks)
	self._LocalTasks = LocalTasks
end

function Quest:getLocalTasks()
	return self._LocalTasks
end

function Quest:checkTaskIsFinishById(taskId)

  if self:getIsAllMainTaskFinished() == true then
     return true
  end
  
  local mainTask = self:getMainTask()
  local mainTaskId = mainTask:getTaskId()
  local preTaskId = self._LocalTasks[mainTaskId].last_task
  local finished = false
  while self._LocalTasks[preTaskId] ~= nil do
     if preTaskId == taskId then
        finished = true
        preTaskId = -1
     else
        preTaskId = self._LocalTasks[preTaskId].last_task
     end
  end
  return finished
end

function Quest:getTaskById(taskId)
  return self._LocalTasks[taskId]
end 

function Quest:registNetSever()
  net.registMsgCallback(PbMsgId.TaskState,self,Quest.onTaskState)
  net.registMsgCallback(PbMsgId.AskForMainTaskAwardResult,self,Quest.onAskForMainTaskAwardResult)
  net.registMsgCallback(PbMsgId.AskForSideTaskAwardResult,self,Quest.onAskForSideTaskAwardResult)
 
  net.registMsgCallback(PbMsgId.AskForDailyTaskTableResult,self,Quest.onAskForDailyTaskTableResult)
  net.registMsgCallback(PbMsgId.ReceiveDailyTaskResult,self,Quest.onReceiveDailyTaskResult)
  net.registMsgCallback(PbMsgId.AskForDailyTaskRewardResult,self,Quest.onAskForDailyTaskRewardResult)
  net.registMsgCallback(PbMsgId.DropDailyTaskResult,self,Quest.onDropDailyTaskResult)
  net.registMsgCallback(PbMsgId.RefreshFreeDailyTaskTableResult,self,Quest.onRefreshFreeDailyTaskTableResult)
  net.registMsgCallback(PbMsgId.RefreshMoneyDailyTaskTableResult,self,Quest.onRefreshMoneyDailyTaskTableResult)
  net.registMsgCallback(PbMsgId.VipFreeRefreshDailyTaskTableResult,self,Quest.refreshVipFreeDailyTaskTableResult)
  net.registMsgCallback(PbMsgId.ReqForcibleDoneDailyTaskResult,self,Quest.onReqForcibleDoneDailyTaskResult)
  
end

function Quest:Instance()
  if Quest._QuestInstance == nil then
     Quest._QuestInstance = Quest.new()
  end
  return Quest._QuestInstance
end

function Quest:destory()
  net.unregistAllCallback(self)
end

function Quest:setQuestView(QuestView)
	self._QuestView = QuestView
end

function Quest:getQuestView()
	return self._QuestView
end

function Quest:setDailyTaskTimes(DailyTaskTimes)
  self._DailyTaskTimes = DailyTaskTimes
end

function Quest:getDailyTaskTimes()
  return self._DailyTaskTimes
end

------
--  Getter & Setter for
--      Quest._FreeTaskRefreshTimes 
-----
function Quest:setFreeTaskRefreshTimes(FreeTaskRefreshTimes)
  self._FreeTaskRefreshTimes = FreeTaskRefreshTimes
end

function Quest:getFreeTaskRefreshTimes()
  return self._FreeTaskRefreshTimes
end

------
--  Getter & Setter for
--      Quest._FreeTaskNextFreshTime 
-----
function Quest:setFreeTaskNextFreshTime(FreeTaskNextFreshTime)
  self._FreeTaskNextFreshTime = FreeTaskNextFreshTime
end

function Quest:getFreeTaskNextFreshTime()
  return self._FreeTaskNextFreshTime
end


------
--  Getter & Setter for
--      Quest._ForcibleDoneDailyTaskCount 
-----
function Quest:setForcibleDoneDailyTaskCount(ForcibleDoneDailyTaskCount)
  self._ForcibleDoneDailyTaskCount = ForcibleDoneDailyTaskCount
end

function Quest:getForcibleDoneDailyTaskCount()
  return self._ForcibleDoneDailyTaskCount
end

function Quest:reqForcibleDoneDailyTask(taskId)
  print("reqForcibleDoneDailyTask:",taskId)
  _showLoading()
  local data = PbRegist.pack(PbMsgId.ReqForcibleDoneDailyTask,{ task_id = taskId })
  net.sendMessage(PbMsgId.ReqForcibleDoneDailyTask,data)
end

function Quest:onReqForcibleDoneDailyTaskResult(action,msgId,msg)
--  message ReqForcibleDoneDailyTaskResult{
-- enum traits { value = 9903;}
-- enum eresult{
--  success = 1;
--  money_limit = 2;
-- }
-- required int32 task_id = 1;
-- required eresult result = 2;
-- optional ClientSync client_sync = 3;
  print("onReqForcibleDoneDailyTaskResult:",msg.result)
  _hideLoading()
  if msg.result == "success" then
     GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
  elseif msg.result == "money_limit" then
     Toast:showString(GameData:Instance():getCurrentScene(),_tr("not enough money"), ccp(display.cx, display.cy))
  end
end


function Quest:refreshVipFreeDailyTaskTable()
    --print("vipFreeRefresh")
    _showLoading()
    local data = PbRegist.pack(PbMsgId.VipFreeRefreshDailyTaskTable)
    net.sendMessage(PbMsgId.VipFreeRefreshDailyTaskTable,data)
end

function Quest:refreshVipFreeDailyTaskTableResult(action,msgId,msg)
    --print(msg.state)
    _hideLoading()
    if msg.state == "Ok" then
       self:updateDailyTask(msg.table)
       GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
       self:getQuestView():updateView()
       Toast:showString(GameData:Instance():getCurrentScene(),_tr("daily_task_refreshed"), ccp(display.cx, display.cy))
    else
       echo("refreshVipFreeDailyTaskTableResult:",msg.state)
       --Toast:showString(GameData:Instance():getCurrentScene(),msg.state, ccp(display.cx, display.cy))
    end
end

function Quest:refreshFreeDailyTaskTable()
    _showLoading()
    local data = PbRegist.pack(PbMsgId.RefreshFreeDailyTaskTable)
    net.sendMessage(PbMsgId.RefreshFreeDailyTaskTable,data)
end

function Quest:onRefreshFreeDailyTaskTableResult(action,msgId,msg)
    _hideLoading()
    if msg.state == "Ok" then
       self:updateDailyTask(msg.table)
       self:getQuestView():updateView()
       Toast:showString(GameData:Instance():getCurrentScene(),_tr("daily_task_refreshed"), ccp(display.cx, display.cy))
    else
       echo("onRefreshFreeDailyTaskTableResult:",msg.state)
       --Toast:showString(GameData:Instance():getCurrentScene(),msg.state, ccp(display.cx, display.cy))
    end
end

function Quest:refreshMoneyDailyTaskTable()
    echo("refreshMoneyDailyTaskTable")
    _showLoading()
    local data = PbRegist.pack(PbMsgId.RefreshMoneyDailyTaskTable)
    net.sendMessage(PbMsgId.RefreshMoneyDailyTaskTable,data)
end

function Quest:onRefreshMoneyDailyTaskTableResult(action,msgId,msg)
    echo("RefreshMoneyDailyTaskTableResult:",msg.state)
    _hideLoading()
    if msg.state == "Ok" then
       self:updateDailyTask(msg.table)
       self:getQuestView():updateView()
       GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
       Toast:showString(GameData:Instance():getCurrentScene(),_tr("daily_task_refreshed"), ccp(display.cx, display.cy))
    else
      -- echo("RefreshMoneyDailyTaskTableResult:",msg.state)
      --Toast:showString(GameData:Instance():getCurrentScene(),msg.state, ccp(display.cx, display.cy))
    end
end

function Quest:hasNewAward()
    local hasAward = false
    local hasDailyAward = false
    local hasNormalAward = false
    
    -- daily task open condition
    if GameData:Instance():checkSystemOpenCondition(2, false) == true then
        for key, d_task in pairs(self:getDailyTasks()) do
            if d_task:checkFinished() == true and d_task:getTaskState() == "Accept" then
               hasDailyAward = true
               break
            end
           -- print("checking daily task is Has Award:",d_task:checkFinished(),d_task:getTaskState())
        end
        
        if hasDailyAward == false then
           local curTime = Clock:Instance():getCurServerUtcTime()
           local leftTime = self:getNextFreshTime() - curTime
           if leftTime <= 0 and self:getDailyTaskTimes() < 10 then
              hasDailyAward = true
           end
        end
    end
    
    for key, m_task in pairs(self:getNormalTasks()) do
        if m_task:checkFinished() == true then
           hasNormalAward = true
           break
        end
        --print("checking normal task is Has Award:",m_task:checkFinished(),m_task:getTaskState())
    end
    
    if hasDailyAward == true or hasNormalAward == true then
       hasAward = true
    end
    
    return hasAward,hasNormalAward,hasDailyAward
end

function Quest:receiveDailyTask(dailyTaskId)
  _showLoading()
  local data = PbRegist.pack(PbMsgId.ReceiveDailyTask,{ id = dailyTaskId })
  net.sendMessage(PbMsgId.ReceiveDailyTask,data)
end

function Quest:onReceiveDailyTaskResult(action,msgId,msg)
--  enum traits { value = 3772;}
--  enum State {
--    Ok = 0;
--    IdNotExist = 1;
--    HasNoRightToday = 2;
--    IsAcceptTaskId = 3;
--    IsDropedTaskId = 4;
--    IsFinishedTaskId = 5;
--    TaskIsFull = 6;
--  }
--  required State state = 1;
--  optional ClientSync client_sync = 2;
    echo("onReceiveDailyTaskResult:",msg.state)
    _hideLoading()
    if msg.state == "Ok" then
       GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
    elseif msg.state == "HasNoRightToday" then
       Toast:showString(GameData:Instance():getCurrentScene(),_tr("has_no_daily_task_today"), ccp(display.cx, display.cy))
    elseif msg.state == "TaskIsFull" then
       Toast:showString(GameData:Instance():getCurrentScene(),_tr("task_is_full"), ccp(display.cx, display.cy))
    elseif msg.state == "IsDropedTaskId" then
       Toast:showString(GameData:Instance():getCurrentScene(),_tr("task_is_droped"), ccp(display.cx, display.cy))
    elseif msg.state == "IsFinishedTaskId" then
       Toast:showString(GameData:Instance():getCurrentScene(),_tr("task_is_finished"), ccp(display.cx, display.cy))
    elseif msg.state == "IsAcceptTaskId" then
       Toast:showString(GameData:Instance():getCurrentScene(),_tr("task_is_accepted"), ccp(display.cx, display.cy))
    else
       Toast:showString(GameData:Instance():getCurrentScene(),msg.state, ccp(display.cx, display.cy))
    end
end

-- req refresh task state
function Quest:reFreshTaskState()
  if GameData:Instance():getInitSysComplete() == true then 
    if ControllerFactory:Instance():getCurrentControllerType() == ControllerType.QUEST_CONTROLLER then
      _showLoading()
    end
    local data = PbRegist.pack(PbMsgId.AskForTaskState)
    net.sendMessage(PbMsgId.AskForTaskState,data)
  else 
    echo("=== Quest:reFreshTaskState: system not init complete, ")
  end 
end

-- refresh task result
function Quest:onTaskState(action,msgId,msg)
  self:update(msg)
  self:askForDailyTaskTable()
end

function Quest:dropDailyTask(dailyId)
   _showLoading()
   local data = PbRegist.pack(PbMsgId.DropDailyTask,{ id = dailyId })
  net.sendMessage(PbMsgId.DropDailyTask,data)
end

function Quest:onDropDailyTaskResult(action,msgId,msg)
  _hideLoading()
  if msg.state == "Ok" then
     self:reFreshTaskState()
  else
     echo("onDropDailyTaskResult:",msg.state)
     --Toast:showString(GameData:Instance():getCurrentScene(),"操作失败！", ccp(display.cx, display.cy))
  end
end

function Quest:askForDailyTaskTable()
  local data = PbRegist.pack(PbMsgId.AskForDailyTaskTable)
  net.sendMessage(PbMsgId.AskForDailyTaskTable,data)
end

function Quest:onAskForDailyTaskTableResult(action,msgId,msg)
--   enum traits { value = 3466;}
--  enum State {
--    Ok = 0;
--    NoRight = 1;
--  }
--  required State state = 1;
--  optional DailyTaskTable table = 2;
    echo("onAskForDailyTaskTableResult:",msg.state)
    if msg.state == "Ok" then
       self:updateDailyTask(msg.table)
       if self:getQuestView() ~= nil then
          self:getQuestView():updateView()
       end
    else
       --Toast:showString(GameData:Instance():getCurrentScene(),msg.state, ccp(display.cx, display.cy))
    end
    
    _hideLoading()
    
    if ControllerFactory:Instance():getCurrentControllerType() == ControllerType.SCENARIO_CONTROLLER then
      local scenarioView = Scenario:Instance():getView()
      if scenarioView ~= nil then
         scenarioView:refreshTaskTip()
      end
    end
end


function Quest:askForTaskAward(task)
  _showLoading()
  if task:getTaskType() == 1 then
    self:askForMainTaskAward()
  elseif task:getTaskType() == 2 then
    self:askForSideTaskAward(task:getTaskId())
  elseif task:getTaskType() == 3 then
    self:askForDailyTaskReward(task:getDailyTaskId())
  else
  end
end


function Quest:askForMainTaskAward()
  local data = PbRegist.pack(PbMsgId.AskForMainTaskAward)
  net.sendMessage(PbMsgId.AskForMainTaskAward,data)
end

function Quest:onAskForMainTaskAwardResult(action,msgId,msg)
  if self:getGlobalMainTaskAwardPopView() ~= nil then
     self:getGlobalMainTaskAwardPopView():removeFromParentAndCleanup(true)
     self:setGlobalMainTaskAwardPopView(nil)
  end
  _hideLoading()
  if msg.state == "Ok" then
    --local  task = Task.new()
    --task:setTaskId(msg.task_id)
    
    local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client_sync)
    for i = 1,table.getn(gainItems) do
      echo("----gained:", gainItems[i].configId, gainItems[i].count)
      local str = string.format("+%d", gainItems[i].count)
      Toast:showIconNumWithDelay(str, gainItems[i].iconId, gainItems[i].iType, gainItems[i].configId, ccp(display.width/2,display.height*0.5-i*40), 0.3*(i-1))
    end
    
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
    if self:getQuestView() ~= nil then
       self:getQuestView():toastAward()
    end
    _executeNewBird()
  else
    echo("onAskForMainTaskAwardResult:",msg.state)
    --Toast:showString(GameData:Instance():getCurrentScene(),"领取失败！", ccp(display.cx, display.cy))
  end
  
  --GameData:Instance():getCurrentScene():triggerGuideByLevel()
end

function Quest:alertMainTaskAwardPop()
  if Quest:Instance():getGlobalMainTaskAwardPopView() ~= nil then
     Quest:Instance():getGlobalMainTaskAwardPopView():removeFromParentAndCleanup(true)
     Quest:Instance():setGlobalMainTaskAwardPopView(nil)
  end
  
  local needPop = false
  local currentMainTask = Quest:Instance():getMainTask()
  local progressFinished = false
  if currentMainTask ~= nil and currentMainTask:getTaskConditionstates() ~= nil then
     progressFinished = currentMainTask:checkFinished()
  end
  if progressFinished == true then
    if ControllerFactory:Instance():getCurrentControllerType() ~= ControllerType.BATTLE_CONTROLLER 
    and ControllerFactory:Instance():getCurrentControllerType() ~= ControllerType.REGIST_CONTROLLER
    then
      local questAwardPop = QuestPopAwardView.new(currentMainTask)
      GameData:Instance():getCurrentScene():addChildView(questAwardPop)
      Quest:Instance():setGlobalMainTaskAwardPopView(questAwardPop)
      needPop = true
    end
  end
  
  return needPop
end


function Quest:askForSideTaskAward(taskId)
  local data = PbRegist.pack(PbMsgId.AskForSideTaskAward,{id = taskId})
  net.sendMessage(PbMsgId.AskForSideTaskAward,data)
end

function Quest:onAskForSideTaskAwardResult(action,msgId,msg)
  _hideLoading()
  if msg.state == "Ok" then
    --local  task = Task.new()
    --task:setTaskId(msg.task_id)
    local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client_sync)
    for i = 1,table.getn(gainItems) do
      echo("----gained:", gainItems[i].configId, gainItems[i].count)
      local str = string.format("+%d", gainItems[i].count)
      Toast:showIconNumWithDelay(str, gainItems[i].iconId, gainItems[i].iType, gainItems[i].configId, ccp(display.width/2,display.height*0.5-i*40), 0.3*(i-1))
    end
    
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
    self:getQuestView():toastAward()
  else
    --Toast:showString(GameData:Instance():getCurrentScene(),"领取失败！", ccp(display.cx, display.cy))
    echo("onAskForSideTaskAwardResult:",msg.state)
  end
end

function Quest:askForDailyTaskReward(dailyTaskId)
   local data = PbRegist.pack(PbMsgId.AskForDailyTaskReward,{id = dailyTaskId})
   net.sendMessage(PbMsgId.AskForDailyTaskReward,data)
end

function Quest:onAskForDailyTaskRewardResult(action,msgId,msg)
    echo("onAskForDailyTaskRewardResult:",msg.state)
    _hideLoading()
    if msg.state == "Ok" then
      --local  task = Task.new()
      --task:setTaskId(msg.config_id)
      local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client_sync)
      for i = 1,table.getn(gainItems) do
        local str = string.format("+%d", gainItems[i].count)
        Toast:showIconNumWithDelay(str, gainItems[i].iconId, gainItems[i].iType, gainItems[i].configId, ccp(display.width/2,display.height*0.5-i*40), 0.3*(i-1))
      end
    
      GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
      self:getQuestView():toastAward()
    elseif msg.state == "NeedCondition" then
      Toast:showString(GameData:Instance():getCurrentScene(),"get_award_faild_need_condition", ccp(display.cx, display.cy))
    elseif msg.state == "NoSuchTask" then
      Toast:showString(GameData:Instance():getCurrentScene(),"get_award_faild_no_such_task", ccp(display.cx, display.cy))
    else
      --echo("onAskForDailyTaskRewardResult:",msg.state)
      --Toast:showString(GameData:Instance():getCurrentScene(),msg.state, ccp(display.cx, display.cy))
    end
end

function Quest:setNextFreshTime(NextFreshTime)
	self._NextFreshTime = NextFreshTime
end

function Quest:getNextFreshTime()
	return self._NextFreshTime
end

function Quest:updateDailyTask(dailyTaskTable)
--   message DailyTaskTable {
--  optional int32 next_refresh_time = 1;
--  repeated DailyTaskMeta meta = 2;
--}
    echo("nextRefreshTime:",dailyTaskTable.next_refresh_time)
    self:setNextFreshTime(dailyTaskTable.next_refresh_time)
    
    for key, dailyTaskMeta in pairs(dailyTaskTable.meta) do
        --echo("DailyTaskMeta:   id:",dailyTaskMeta.id,"daily_task:",dailyTaskMeta.daily_task,"state:",dailyTaskMeta.state)
        local dailyTask = nil
        for key, acceptedTask in pairs(self._DailyTasks) do
        	  if dailyTaskMeta.id == acceptedTask:getDailyTaskId() then
        	    dailyTask = acceptedTask
        	    break
        	  end
        end
        
        if dailyTask == nil then
           local dailyTask = Task.new()
           dailyTask:setDailyTaskMeta(dailyTaskMeta)
           table.insert(self._DailyTasks,dailyTask)
        else
           dailyTask:setDailyTaskMeta(dailyTaskMeta)
        end
        
    end 
    
end

------
--  Getter & Setter for
--      Quest._IsAllMainTaskFinished 
-----
function Quest:setIsAllMainTaskFinished(IsAllMainTaskFinished)
	self._IsAllMainTaskFinished = IsAllMainTaskFinished
end

function Quest:getIsAllMainTaskFinished()
	return self._IsAllMainTaskFinished
end

function Quest:update(taskState)
--message TaskState {
--  enum traits { value = 3754;}
--  optional SingleTask main_task = 1;
--  repeated SingleTask side_task = 2;
--  repeated SingleTask daily_task = 4;
--  optional bool is_finished_all_main_task = 3;
--  optional int32 finished_main_task_count = 5;
--  optional int32 finished_side_task_count = 6;
--  optional int32 finished_daily_task_count = 7;
--}
    
    --echo("Quest:update(), is_finished_all_main_task:",taskState.is_finished_all_main_task)
    local mainTaskMsg = taskState.main_task
    local normalTasts = {}

    if taskState.is_finished_all_main_task == false then
      local mainTask = Task.new(mainTaskMsg)
      
      table.insert(normalTasts,mainTask)
      self:setMainTask(mainTask)
    else
      self:setMainTask(nil)
    end
    
    self:setIsAllMainTaskFinished(taskState.is_finished_all_main_task)
    
    local sideTask = nil
    for key, sideTaskMsg in pairs(taskState.side_task) do
    	 sideTask = Task.new(sideTaskMsg)
    	 table.insert(normalTasts,sideTask)
    end
    
    
    local function sortTables(a, b)
       if a:checkFinished() == b:checkFinished() then
          if a:getTaskType() == b:getTaskType() then
             return a:getTaskId() < b:getTaskId()
          end
          return a:getTaskType() < b:getTaskType()
       end
       return a:checkFinished() == true
    end
    table.sort(normalTasts,sortTables)
    
    self:setNormalTasks(normalTasts)
    
    local dailyTasks = {}
    local dailyTask = nil
    for key, dailyTaskMsg in pairs(taskState.daily_task) do
       dailyTask = Task.new(dailyTaskMsg)
       table.insert(dailyTasks,dailyTask)
    end
    self:setDailyTasks(dailyTasks)
    
    self:setFinishedMainTaskCount(taskState.finished_main_task_count)
    self:setFinishedSideTaskCount(taskState.finished_side_task_count)
    self:setFinishedDailyTaskCount(taskState.finished_daily_task_count)
    
end

------
--  Getter & Setter for
--      Quest._MainTask 
-----
function Quest:setMainTask(MainTask)
	self._MainTask = MainTask
	if ControllerFactory:Instance():getCurrentControllerType() ~= ControllerType.HOME_CONTROLLER
	and ControllerFactory:Instance():getCurrentControllerType() ~= ControllerType.REGIST_CONTROLLER
	then
     self:alertMainTaskAwardPop()
  end
end

function Quest:getMainTask()
	return self._MainTask
end

------
--  Getter & Setter for
--      Quest._GlobalMainTaskAwardPopView 
-----
function Quest:setGlobalMainTaskAwardPopView(GlobalMainTaskAwardPopView)
	self._GlobalMainTaskAwardPopView = GlobalMainTaskAwardPopView
end

function Quest:getGlobalMainTaskAwardPopView()
	return self._GlobalMainTaskAwardPopView
end

------
--  Getter & Setter for
--      Quest._FinishedMainTaskCount 
-----
function Quest:setFinishedMainTaskCount(FinishedMainTaskCount)
	self._FinishedMainTaskCount = FinishedMainTaskCount
end

function Quest:getFinishedMainTaskCount()
	return self._FinishedMainTaskCount
end

------
--  Getter & Setter for
--      Quest._FinishedSideTaskCount 
-----
function Quest:setFinishedSideTaskCount(FinishedSideTaskCount)
	self._FinishedSideTaskCount = FinishedSideTaskCount
end

function Quest:getFinishedSideTaskCount()
	return self._FinishedSideTaskCount
end

------
--  Getter & Setter for
--      Quest._FinishedDailyTaskCount 
-----
function Quest:setFinishedDailyTaskCount(FinishedDailyTaskCount)
	self._FinishedDailyTaskCount = FinishedDailyTaskCount
end

function Quest:getFinishedDailyTaskCount()
	return self._FinishedDailyTaskCount
end

function Quest:setNormalTasks(NormalTasks)
	self._NormalTasks = NormalTasks
end

function Quest:getNormalTasks()
	return self._NormalTasks
end

function Quest:setDailyTasks(DailyTasks)
	self._DailyTasks = DailyTasks
end

function Quest:getDailyTasks()
	return self._DailyTasks
end

function Quest:setDailyTaskRefreshTimes(DailyTaskRefreshTime)
  self._DailyTaskRefreshTime = DailyTaskRefreshTime
end

function Quest:getDailyTaskRefreshTimes()
  return self._DailyTaskRefreshTime
end

return Quest