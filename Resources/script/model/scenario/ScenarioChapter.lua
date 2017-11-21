require("model.scenario.StageCheckPoint")
ScenarioChapter = class("ScenarioChapter")

function ScenarioChapter:ctor(scenario,chapterId)
   self._scenario = scenario
   self:setId(chapterId)
end

------
--  Getter & Setter for
--      ScenarioChapter._Id 
--      set chapter id
-----
function ScenarioChapter:setId(Id)
	self._Id = Id
	
	-- set chapter name
	self:setName(AllConfig.chapter[Id].chapter_name)
	self:setEffectType(AllConfig.chapter[Id].stage_effect)
	self:setChapterType(AllConfig.chapter[Id].stage_type)
	self:setChapterResId(AllConfig.chapter[Id].chapter_res)
	local stageCheckPoint = nil 
	
	local positionGroup = AllConfig.chapter[Id].checkpoint_pos
	-- create the normal check points at this chapter
	local normalCheckPointsData = AllConfig.chapter[Id].stage_type1_order
	local normalCheckPoints = {}
	for idx, checkPointData in pairs(normalCheckPointsData) do
		  stageCheckPoint = StageCheckPoint.new()
		  stageCheckPoint:setIndex(idx)
		  stageCheckPoint:setChapter(self)
		  
		  if positionGroup ~= nil and positionGroup[idx] ~= nil and positionGroup[idx].array~= nil then
         stageCheckPoint:setPosition(ccp(positionGroup[idx].array[1],positionGroup[idx].array[2]))
         --echo("checkPointPos:",positionGroup[idx].array[1],positionGroup[idx].array[2])
      end
      
		  local normalCheckPointStages = {}
		  for key, stageConfigId in pairs(checkPointData.array) do
		      --set stages to checkPoint from allstages
		      --echo(stageConfigId)
		      stageCheckPoint:setStageType(self._scenario:getAllStages()[stageConfigId]:getStageType())
		      self._scenario:getAllStages()[stageConfigId]:setCheckPointIndex(idx)
		      self._scenario:getAllStages()[stageConfigId]:setCheckPoint(stageCheckPoint)
		      --echo("normalStages:",self._scenario:getAllStages()[stageConfigId])
		  	  table.insert(normalCheckPointStages,self._scenario:getAllStages()[stageConfigId]) 
		  end
		  stageCheckPoint:setStages(normalCheckPointStages)
		  normalCheckPoints[idx] = stageCheckPoint
	end
	self:setNormalCheckPoints(normalCheckPoints)
	
	-- create the elite check points at this chapter
	local eliteCheckPointsData = AllConfig.chapter[Id].stage_type2_order
  local eliteCheckPoints = {}
  for idx, checkPointData in pairs(eliteCheckPointsData) do
      stageCheckPoint = StageCheckPoint.new()
      stageCheckPoint:setIndex(idx)
      stageCheckPoint:setChapter(self)
      
      if positionGroup ~= nil and positionGroup[idx] ~= nil and positionGroup[idx].array~= nil then
         stageCheckPoint:setPosition(ccp(positionGroup[idx].array[1],positionGroup[idx].array[2]))
         --echo("checkPointPos:",positionGroup[idx].array[1],positionGroup[idx].array[2])
      end
      
      local eliteCheckPointStages = {}
      for key, stageConfigId in pairs(checkPointData.array) do
          --set stages to checkPoint from allstages
          stageCheckPoint:setStageType(self._scenario:getAllStages()[stageConfigId]:getStageType())
          self._scenario:getAllStages()[stageConfigId]:setCheckPointIndex(idx)
          self._scenario:getAllStages()[stageConfigId]:setCheckPoint(stageCheckPoint)
          table.insert(eliteCheckPointStages,self._scenario:getAllStages()[stageConfigId]) 
      end
      stageCheckPoint:setStages(eliteCheckPointStages)
      eliteCheckPoints[idx] = stageCheckPoint
  end
  self:setEliteCheckPoints(eliteCheckPoints)
  
end

function ScenarioChapter:getId()
	return self._Id
end

------
--  Getter & Setter for
--      ScenarioChapter._ChapterResId 
-----
function ScenarioChapter:setChapterResId(ChapterResId)
	self._ChapterResId = ChapterResId
end

function ScenarioChapter:getChapterResId()
	return self._ChapterResId
end

------
--  Getter & Setter for
--      ScenarioChapter._ChapterType 
-----
function ScenarioChapter:setChapterType(ChapterType)
	self._ChapterType = ChapterType
end

function ScenarioChapter:getChapterType()
	return self._ChapterType
end

function ScenarioChapter:isNewChapter()
  local stage =  self:getNormalCheckPoints()[1]:getStages()[1]
  return stage:getCheckPoint():getState() == StageConfig.CheckPointStateOpen
end

function ScenarioChapter:checkHasAward()
  return Scenario:Instance():checkHasAwardOnChapter(self:getId())
end

function ScenarioChapter:checkEliteOpend()
  if self:getEliteCheckPoints() == nil or #self:getEliteCheckPoints() <=0 then
     return false
  end
  
  local eliteOpend = true
  for key, checkPoint in pairs(self:getNormalCheckPoints()) do
     if checkPoint:getStageType() == StageConfig.StageTypeNormal then
        if checkPoint:getState() == StageConfig.CheckPointStateClose or checkPoint:getState() == StageConfig.CheckPointStateOpen then
           eliteOpend = false
           break
        end
     end
  end
  return eliteOpend
end

------
--  Getter & Setter for
--      ScenarioChapter._EffectType 
-----
function ScenarioChapter:setEffectType(EffectType)
	self._EffectType = EffectType
end

function ScenarioChapter:getEffectType()
	return self._EffectType
end

------
--  Getter & Setter for
--      ScenarioChapter._Name 
-----
function ScenarioChapter:setName(Name)
	self._Name = Name
end

function ScenarioChapter:getName()
	return self._Name
end

function ScenarioChapter:getNewestCheckPointByIsElite(isElite)
  
  local m_checkPoint = nil
  
  local checkPoints = {}
  local stageType = nil
  if isElite == true then
     stageType = StageConfig.StageTypeElite
     checkPoints = self:getEliteCheckPoints()
  else
     stageType = StageConfig.StageTypeNormal
     checkPoints = self:getNormalCheckPoints()
  end
  
  local checkPointtmp = nil
  for key, checkPoint in pairs(checkPoints) do
     --echo("type:",checkPoint:getStageType(),stageType)
     if checkPoint:getStageType() == stageType then
        checkPointtmp = checkPoint
        if checkPoint:getState() == StageConfig.CheckPointStateOpen or checkPoint:getState() == StageConfig.CheckPointStateClose then
           m_checkPoint = checkPoint
           break
        end
     end
  end
  
  if m_checkPoint == nil then
     m_checkPoint = checkPointtmp
  end
  
  --echo("m_checkPoint:",m_checkPoint)
  
  return m_checkPoint
  
end



--------
----  Getter & Setter for
----      ScenarioChapter._LastestStageByStageType 
-------
--function ScenarioChapter:setLastestStageByStageType(LastestStageByStageType)
--	self._LastestStageByStageType = LastestStageByStageType
--end
--
--function ScenarioChapter:getLastestStageByStageType()
--	return self._LastestStageByStageType
--end


------
--  Getter & Setter for
--      ScenarioChapter._NormalCheckPoints 
-----
function ScenarioChapter:setNormalCheckPoints(NormalCheckPoints)
	self._NormalCheckPoints = NormalCheckPoints
end

function ScenarioChapter:getNormalCheckPoints()
	return self._NormalCheckPoints
end

------
--  Getter & Setter for
--      ScenarioChapter._EliteCheckPoints 
-----
function ScenarioChapter:setEliteCheckPoints(EliteCheckPoints)
	self._EliteCheckPoints = EliteCheckPoints
end

function ScenarioChapter:getEliteCheckPoints()
	return self._EliteCheckPoints
end

return ScenarioChapter