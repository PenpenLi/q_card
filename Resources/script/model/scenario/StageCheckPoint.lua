require("model.scenario.ScenarioStage")
require("model.guild.Guild")
StageCheckPoint = class("StageCheckPoint")
function StageCheckPoint:ctor()
end
------
--  Getter & Setter for
--      StageCheckPoint._Index 
--      index of the check point
-----
function StageCheckPoint:setIndex(Index)
	self._Index = Index
end

function StageCheckPoint:getIndex()
	return self._Index
end

------
--  Getter & Setter for
--      StageCheckPoint._ReqLevel 
--      enter this check point need level
-----
function StageCheckPoint:setReqLevel(ReqLevel)
	self._ReqLevel = ReqLevel
end

function StageCheckPoint:getReqLevel()
	return self._ReqLevel
end

------
--  Getter & Setter for
--      StageCheckPoint._Position 
-----
function StageCheckPoint:setPosition(Position)
	self._Position = Position
end

function StageCheckPoint:getPosition()
	return self._Position
end

------
--  Getter & Setter for
--      StageCheckPoint._Chapter 
--      the chapter which this check point at
-----
function StageCheckPoint:setChapter(Chapter)
	self._Chapter = Chapter
end

function StageCheckPoint:getChapter()
	return self._Chapter
end

------
--  Getter & Setter for
--      StageCheckPoint._SelectedStage 
-----
function StageCheckPoint:setSelectedStage(SelectedStage)
	self._SelectedStage = SelectedStage
end

function StageCheckPoint:getSelectedStage()
	return self._SelectedStage
end

------
--  Getter & Setter for
--      StageCheckPoint._StageType 
--      the stages's stage type at this check point
-----
function StageCheckPoint:setStageType(StageType)
	self._StageType = StageType
	if StageType == StageConfig.StageTypeNormal or StageType == StageConfig.StageTypeNormalHide then
     self:setIsElite(false)
  elseif StageType == StageConfig.StageTypeElite or StageType == StageConfig.StageTypeEliteHide then
     self:setIsElite(true)
  else
     self:setIsElite(false)
  end
end

function StageCheckPoint:getStageType()
	return self._StageType
end

function StageCheckPoint:setIsElite(IsElite)
  self._IsElite = IsElite
end

function StageCheckPoint:getIsElite()
  return self._IsElite
end

------
--  Getter & Setter for
--      StageCheckPoint._Stages 
--     stages a this check point
-----
function StageCheckPoint:setStages(Stages)
	self._Stages = Stages
	if self._Stages ~= nil then
	   self:setMaxGrade(#self._Stages)
	   if #self._Stages > 0 then
	      --self:setStageType(self._Stages[1]:getStageType())
	      self:setReqLevel(self:getStages()[1]:getRequiredCharLevel())
	   end
	end
end

function StageCheckPoint:getStages()
	return self._Stages
end

------
--      state: type of state pls look at StageConfig.lua
-----

function StageCheckPoint:getState()
	local state = StageConfig.CheckPointStateClose
  if self:getStages() ~= nil then
    if #self:getStages() > 0 then
      local guildStage = self:getStages()[1]
      if guildStage:getStageType() == StageConfig.StageTypeGuild then
        local guildStageInstance = Guild:Instance():getGuildStageInstance()
        if guildStageInstance ~= nil then
          if guildStage:getStageId() == guildStageInstance:getCurrentStageId() then
            state = StageConfig.CheckPointStateOpen
          else
            state = StageConfig.CheckPointStateClose
          end
        end
      else
        local preStage = self:getStages()[1]:getPreStage()
        if preStage ~= nil then
            --echo("PreStageIsPassed",preStage:getIsPassed())
            if preStage:getIsPassed() == true then  -- check if pre stage is passed
               if GameData:Instance():getCurrentPlayer():getLevel() >= self:getStages()[1]:getRequiredCharLevel() then
                  state = StageConfig.CheckPointStateOpen
                  
                  --check normal hide state
                  if self:getStageType() == StageConfig.StageTypeNormalHide then
                     local chapter = self:getChapter()
                     local checkPoints = chapter:getNormalCheckPoints()
                     for key, checkPoint in pairs(checkPoints) do
                         if checkPoint:getStageType() == StageConfig.StageTypeNormal then
                            if checkPoint:getState() ~= StageConfig.CheckPointStateFinished then
                               state = StageConfig.CheckPointStateClose
                               break
                            end
                         end
                     end
                  end
               end
            end
        else
            echo("first stage")
            state = StageConfig.CheckPointStateOpen --first stage
        end
        
        local finishedCount = 0
        for key, stage in pairs(self:getStages()) do
        	 if stage:getIsPassed() == true then
        	    finishedCount = finishedCount + 1
        	    state = StageConfig.CheckPointStateInProgress
        	 end
        end
        
        if finishedCount == #self:getStages() then
           state = StageConfig.CheckPointStateFinished
        end
        
        print("finishedCount:",finishedCount)
        
      end
    end
  end
  
  return state
end

------
--      how many stages has passed at this check point
-----
function StageCheckPoint:getGrade()
  local grade = 0
  for key, stage in pairs(self:getStages()) do
  	  if stage:getIsPassed() == true then
  	    grade = grade + 1
  	  end
  end
	return grade
end

------
--  Getter & Setter for
--      StageCheckPoint._MaxGrade 
--      how many stages at this check points
-----
function StageCheckPoint:setMaxGrade(MaxGrade)
	self._MaxGrade = MaxGrade
end

function StageCheckPoint:getMaxGrade()
	return self._MaxGrade
end


return StageCheckPoint