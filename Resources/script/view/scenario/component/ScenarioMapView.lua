require("view.scenario.component.MapFlag")
require("model.scenario.ScenarioStage")
ScenarioMapView = class("ScenarioMapView",BaseView)
function ScenarioMapView:ctor(delegate,chapter,isElite,touchIdx)
  ScenarioMapView.super.ctor(self)
  self:setDelegate(delegate)
  self:setChapter(chapter)
  self:setIsElite(isElite)
  self._touchIdx = touchIdx
  
  self:setNodeEventEnabled(true)
--  self.enabledAlert = true
--  local currentStepId = Guide:Instance():getCurrentGuideInfo():getCurrentStep():getStepId()
--  if currentStepId == 11802 or currentStepId == 10602 or currentStepId ==  10902 or currentStepId == 11202 then
--     self.enabledAlert = false
--  end
  
  self.enabledAlert = false
  
  self:performWithDelay(function()
    self.enabledAlert = true
  end,0.1)
    
  
  

  local checkPointNumber = 1
  if isElite == true then
     checkPointNumber = table.getn(chapter:getEliteCheckPoints())
  else
     checkPointNumber = table.getn(chapter:getNormalCheckPoints())
  end
  self:setAnchorPoint(ccp(0,0))  
  self.background = _res(AllConfig.chapter[chapter:getId()].map_res)
  print("chapter:getId():",chapter:getId())
  assert(self.background ~= nil,"Chapter map background res can't be find:"..AllConfig.chapter[chapter:getId()].map_res)
  self.background:setAnchorPoint(ccp(0,0))  
  self:addChild(self.background)
  self:setContentSize(self.background:getContentSize())
  
  if AllConfig.chapter[chapter:getId()].map_line_res > 0 then
     local lineSpr = _res(AllConfig.chapter[chapter:getId()].map_line_res)
     assert(lineSpr ~= nil,"Chapter map line res can't be find")
     lineSpr:setAnchorPoint(ccp(0,0))
     self:addChild(lineSpr)
  end
  
  local mapWidth = self:getContentSize().width
  local mapHeight = self:getContentSize().height
  local cavansHeight = self:getDelegate():getCanvasContentSize().height
  --local mscale = cavansHeight/mapHeight
  self:setPositionY(self:getDelegate():getScrollView():getViewSize().height/2 - mapHeight / 2)
  local mscale = 1
  self:setScale(mscale)
  
  self._mapFlagArray = {}

  self:buildMapFlags()

end

-- build map flags
function ScenarioMapView:buildMapFlags()
    local checkPoints = {}
    if self:getIsElite() == false then
       checkPoints = self:getChapter():getNormalCheckPoints()
    else
       checkPoints = self:getChapter():getEliteCheckPoints()
    end
    
    echo("buildMapFlags",#checkPoints)
    
    for idx, checkPoint in pairs(checkPoints) do
  	  self._mapFlagArray[idx] = MapFlag.new(checkPoint,self._touchIdx)
  	  self._mapFlagArray[idx]:setDelegate(self:getDelegate())
  	  self:addChild(self._mapFlagArray[idx])
  	  _registNewBirdComponent(108100 + idx,self._mapFlagArray[idx])
    end
    
end

function ScenarioMapView:updateMapFlags()
    local checkPoints = {}
    if self:getIsElite() == false then
       checkPoints = self:getChapter():getNormalCheckPoints()
    else
       checkPoints = self:getChapter():getEliteCheckPoints()
    end
    
    echo("updateMapFlags",#checkPoints)
    
    for idx, checkPoint in pairs(checkPoints) do
        self._mapFlagArray[idx]:setData(checkPoint)
    end
end

-- make the flag at center of screen
function ScenarioMapView:lookAtMapFlagByStage(stage,isTween,showEffect,isAutoAlert)
    self._nowLookingAtStage = stage
    local m_isTween = isTween or false
    
    if stage == nil or stage:getCheckPointIndex() == nil then 
      echo("nil stage to look at")
      return nil
    end
    
    local stageIdx = stage:getCheckPointIndex()
    local mScale = 1
    echo("stageIdx:",stageIdx)
    
    local mapFlag = self._mapFlagArray[stageIdx]
    local targetPosX = -(mapFlag:getPositionX()*mScale-self:getDelegate():getScrollView():getViewSize().width/2)

    if targetPosX < -(self:getContentSize().width*mScale - self:getDelegate():getScrollView():getViewSize().width) then
       targetPosX = -((self:getContentSize().width)*mScale - self:getDelegate():getScrollView():getViewSize().width)
    end
    if targetPosX > 0 then
       targetPosX = 0
    end
    
    if showEffect == true then
       mapFlag:forceShowMarkEffect()
    end
    
    if isAutoAlert == true then
       mapFlag:alertPop(stage)
    end
    
    if m_isTween == true then
      self:stopAllActions()
      self:runAction(CCMoveTo:create(0.2,ccp(targetPosX,self:getPositionY())))
    else
      self:setPositionX(targetPosX)
    end
    
    print("LookAtMapFlag,offset:X",targetPosX)
    
    return targetPosX
      
end

------
--  Getter & Setter for
--      ScenarioMapView._Chapter 
-----
function ScenarioMapView:setChapter(Chapter)
	self._Chapter = Chapter
end

function ScenarioMapView:getChapter()
	return self._Chapter
end

------
--  Getter & Setter for
--      ScenarioMapView._IsElite 
-----
function ScenarioMapView:setIsElite(IsElite)
	self._IsElite = IsElite
end

function ScenarioMapView:getIsElite()
	return self._IsElite
end

return ScenarioMapView