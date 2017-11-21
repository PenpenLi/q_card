Task = class("Task")
function Task:ctor(taskmsg)
  self:setMoney(0)
  self._dropItemDatas = {}
  self:setProgressStr("")
  if taskmsg ~= nil then
     self:update(taskmsg)
  end
end

function Task:setDailyTaskMeta(dailyTaskMeta)
--     required int32 id = 1;
--     required int32 daily_task = 2;
--     enum State {
--       Show = 0;
--       Accept = 1;
--       Finished = 2;
--       Drop = 3;
--     }
--  optional State state = 3;
   --echo("DailyTaskMeta:   id:",dailyTaskMeta.id,"daily_task:",dailyTaskMeta.daily_task,"state:",dailyTaskMeta.state)
   self:setDailyTaskId(dailyTaskMeta.id)
   --echo("dailyTaskMeta.id:",dailyTaskMeta.id)
   --echo("TASK:~~~~~~",dailyTaskMeta.daily_task)
   self:setTaskId(dailyTaskMeta.daily_task)
   self:setTaskState(dailyTaskMeta.state)
   self._dailyTaskMeta = dailyTaskMeta
   
end

function Task:getDailyTaskMeta()
   return self._dailyTaskMeta
end

function Task:setTaskState(TaskState)
	self._TaskState = TaskState
end

function Task:getTaskState()
	return self._TaskState
end

function Task:setProgressStr(ProgressStr)
	self._ProgressStr = ProgressStr
end

function Task:getProgressStr()
	return self._ProgressStr
end

function Task:update(taskmsg)
--message SingleTask {
--  required int32 config_id = 2; // id in config table
--  optional int32 id = 1; // id of task in player. not used in main task and side task
--  repeated TaskConditionState condition = 3;
--}
  --echo("~~~~~~~~~~~~~",taskmsg.id)
  self:setDailyTaskId(taskmsg.id)
  self:setTaskId(taskmsg.config_id)
  --echo("DailyTaskId:",taskmsg.config_id)
  self:setTaskConditionstates(taskmsg.condition)
end

function Task:checkFinished()
  local taskConditionStates = self:getTaskConditionstates()
  local finished = true
  if taskConditionStates ~= nil then
    for key, taskConditionState in pairs(taskConditionStates) do
        --echo("TASK PROGRESS:",taskConditionState.current_state.."/"..taskConditionState.final_state)
        local currentState = taskConditionState.current_state
        local finalState = taskConditionState.final_state
        if currentState > finalState then
           currentState = finalState
        end
        self:setProgressStr("   ("..currentState.."/"..finalState..")")
        if taskConditionState.current_state < taskConditionState.final_state then
           finished = false
           break
        end
    end
  end
  return finished
end


--function Task:checkFinished()
--   local finished = false
--   local conditionId = AllConfig.task[self:getId()].complete_condition[1].array[1]
--   local wantedCount = AllConfig.task[self:getId()].complete_condition[1].array[2]
--   echo("conditionId:",conditionId,wantedCount)
--   if AllConfig.condition[conditionId].type == 5 then
--      local stageId = AllConfig.condition[conditionId].para[2]
--      local stage = Scenario:Instance():getStageById(stageId)
--      if stage ~= nil then
--         if stage:getPassedCount() >= wantedCount then
--            finished = true
--         end
--      end
--   end
--   
--   return finished
--end

function Task:setTaskConditionstates(TaskConditionstates)
	self._TaskConditionstates = TaskConditionstates
	self:checkFinished()
end

function Task:getTaskConditionstates()
	return self._TaskConditionstates
end

------
--  Getter & Setter for
--      Task._DailyTaskId 
-----
function Task:setDailyTaskId(DailyTaskId)
	self._DailyTaskId = DailyTaskId
end

function Task:getDailyTaskId()
	return self._DailyTaskId
end

function Task:setTaskId(TaskId)
  print(TaskId)
	self._TaskId = TaskId
	local allTask = AllConfig.task
--	local length = table.getn(allTask)
--	for i = 1, length do
  self._dropItemDatas = {}
  for i, m_taskConfig in pairs(allTask) do
		if allTask[i].task_id == TaskId then
		   self:setId(i)
		   local taskData = m_taskConfig
       if taskData ~= nil then
           self:setTaskType(taskData.task_type)
           self:setRarity(taskData.rarity)
           self:setName(taskData.name)
           --echo(taskData.name)
           self:setDesciption(taskData.desciption)
           self:setOpenTasks(taskData.open_task)
           self:setJumpTypeValue(taskData.jump_type, taskData.jump_value)

           if taskData.bonus ~= nil then
             if taskData.bonus ~= nil then
--                if taskData.bonus[1] ~= nil then
--                  self:setExp(taskData.bonus[1].array[2])
--                end
--                
--                if taskData.bonus[2] ~= nil then
--                  self:setCoin(taskData.bonus[2].array[2])
--                end
                
                for key, taskDataSon in pairs(taskData.bonus) do
                	  if taskDataSon.array[1] == 1 then
                	     self:setExp(taskDataSon.array[3])
                	  elseif taskDataSon.array[1] == 4 then
                	     self:setCoin(taskDataSon.array[3])
                	  elseif taskDataSon.array[1] == 5 then
                       self:setMoney(taskDataSon.array[3])
                    elseif taskDataSon.array[1] == 6 then
                       table.insert(self._dropItemDatas,taskDataSon)
                	  end
                end
                self:setDropItemDatas(self._dropItemDatas)
                
             end
           else
             self:setExp(0)
             self:setCoin(0)
             self:setMoney(0)
           end
       end
		   break
		end
	end
end

------
--  Getter & Setter for
--      Task._DropItemDatas 
-----
function Task:setDropItemDatas(DropItemDatas)
	self._dropItemDatas = DropItemDatas
end

function Task:getDropItemDatas()
	return self._dropItemDatas
end

function Task:getTaskId()
	return self._TaskId
end

function Task:setId(Id)
  self._Id = Id
end

function Task:getId()
  return self._Id
end

function Task:setTaskType(TaskType)
	self._TaskType = TaskType
end

function Task:getTaskType()
	return self._TaskType
end

function Task:setRarity(Rarity)
	self._Rarity = Rarity
end

function Task:getRarity()
	return self._Rarity
end

function Task:setName(Name)
	self._Name = Name
end

function Task:getName()
	return self._Name
end

function Task:setDesciption(Desciption)
	self._Desciption = Desciption
end

function Task:getDesciption()
	return self._Desciption
end

function Task:setOpenTasks(OpenTasks)
	self._OpenTasks = OpenTasks
end

function Task:getOpenTasks()
	return self._OpenTasks
end

function Task:setCoin(Coin)
  self._Coin = Coin
end

function Task:getCoin()
  return self._Coin
end

function Task:setExp(Exp)
  self._Exp = Exp
end

function Task:getExp()
  return self._Exp
end

------
--  Getter & Setter for
--      Task._Money 
-----
function Task:setMoney(Money)
	self._Money = Money
end

function Task:getMoney()
	return self._Money
end

function Task:setJumpTypeValue(_type,value)
  self._jumpType = _type
  self._jumpVal = value
end 

function Task:getJumpTypeValue()
  return self._jumpType, self._jumpVal
end 


return Task