GuildStageInstance = class("GuildStageInstance")
function GuildStageInstance:ctor(instance)
  self:setProgress(0)
  self:update(instance)
end

function GuildStageInstance:update(instance)
  if instance == nil then
    return
  end
  
  --[[
  message GuildInstanceBase{
  required int32 chepter = 1;       //副本章节
  optional int32 current_stage = 2;   //副本进度
  optional int32 close_time = 3;      //关闭时间
  optional int32 bosshp = 4;        //boss hp
  }
  ]]
  print("current_stage~~~~~~~~~~~~~~~~~~:",instance.current_stage)
  print("close_time:",instance.close_time)
  print("bosshp:",instance.bosshp)
  self:setCurrentStageId(instance.current_stage)
  self:setCloseTime(instance.close_time)
  self:setBossHp(10000 - instance.bosshp)
  
  --update chapter info
  self:setChapter(nil)
  self:setProgress(0)
  if instance.chepter > 0 then
    local chapter = Scenario:Instance():getChapterById(instance.chepter)
    assert(chapter ~= nil,"invaild chapter id:"..instance.chepter)
    
    self:setChapter(chapter)
    local chapterStages = {}
    for key, normalCheckPoint in pairs(chapter:getNormalCheckPoints()) do
      local stages = normalCheckPoint:getStages()
      for key, stage in pairs(stages) do
      	table.insert(chapterStages,stage)
      end
    end
    
    for key, eliteCheckPoint in pairs(chapter:getEliteCheckPoints()) do
    	local stages = eliteCheckPoint:getStages()
      for key, stage in pairs(stages) do
        table.insert(chapterStages,stage)
      end
    end
    
    local preStagesId = {}
    local currentStage = Scenario:Instance():getStageById(instance.current_stage)
    assert(currentStage ~= nil,"invaild stage id:"..instance.current_stage)
    currentStage:setProgress(10000 - instance.bosshp)
    currentStage:setIsOpen(true)
    
    local preStage = currentStage:getPreStage()
    while preStage ~= nil do
      table.insert(preStagesId,preStage:getStageId())
      preStage = preStage:getPreStage()
    end
    
    print("preStages:",#preStagesId)
    
    print("chapterStages:",#chapterStages)
    for key, stage in pairs(chapterStages) do
      if currentStage:getStageId() ~= stage:getStageId() then
        stage:setIsOpen(false)
        stage:setProgress(0)
       end
       
    	for key, stageId in pairs(preStagesId) do
    		if stage:getStageId() == stageId then
    		  stage:setProgress(10000)
    		end
    	end
       
    end
    
    local eachStagePercent = 100/#chapterStages
    local passedPercent = #preStagesId * eachStagePercent
    local currentPrecent = eachStagePercent * ((10000 - instance.bosshp)/10000)
    self:setProgress(math.floor(passedPercent + currentPrecent))
  end
  
end

------
--  Getter & Setter for
--      GuildStageInstance._Progress 
-----
function GuildStageInstance:setProgress(Progress)
	self._Progress = Progress
end

function GuildStageInstance:getProgress()
	return self._Progress
end

------
--  Getter & Setter for
--      GuildStageInstance._Chapter 
-----
function GuildStageInstance:setChapter(Chapter)
	self._Chapter = Chapter
end

function GuildStageInstance:getChapter()
	return self._Chapter
end

------
--  Getter & Setter for
--      GuildStageInstance._CurrentStageId 
-----
function GuildStageInstance:setCurrentStageId(CurrentStageId)
	self._CurrentStageId = CurrentStageId
end

function GuildStageInstance:getCurrentStageId()
	return self._CurrentStageId
end

------
--  Getter & Setter for
--      GuildStageInstance._CloseTime 
-----
function GuildStageInstance:setCloseTime(CloseTime)
	self._CloseTime = CloseTime
end

function GuildStageInstance:getCloseTime()
	return self._CloseTime
end

------
--  Getter & Setter for
--      GuildStageInstance._BossHp 
-----
function GuildStageInstance:setBossHp(BossHp)
	self._BossHp = BossHp
end

function GuildStageInstance:getBossHp()
	return self._BossHp
end

return GuildStageInstance