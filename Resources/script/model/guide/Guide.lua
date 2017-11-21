require("model.guide.GuideInfo")
require("model.guide.GuideStep")
require("model.guide.GuideConfig")
require("view.guide.GuidePopup")
require("view.BaseScene")

Guide = class("Guide",BaseScene)

local playerGuideBgTag = 1243
function Guide:ctor()
	Guide.super.ctor(self)
end

function Guide:Instance() 
  if Guide._Instance == nil then
    Guide._Instance = Guide.new()
    Guide._Instance:init()
  end
  return Guide._Instance
end

function Guide:init() 
   self:initGuideManager()
   self:initGuideSteps()
   self:initGuides()
   CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self, handler(self,Guide.sendGuideId2Server),GuideConfig.SendGuideId2Server)
   --self:initStageGuides()
end

function Guide:initGuideSteps()
  local guideSteps = {}
  assert(AllConfig.course ~= nil,"Course Error")
  for key, step in pairs(AllConfig.course) do
    local guideStep = GuideStep.new(key)
  	guideSteps[key] = guideStep
  	
  	local ui_ids = guideStep:getTriggerUiIds()
  	local guideManagerTable = self:getGuideManagerTable()
    for key, ui_id in pairs(ui_ids) do
      table.insert(guideManagerTable[ui_id][GuideConfig.GuideManagerTypeStepModuleGroup],1,guideStep)
    end
    
  end
  self:setAllGuideSteps(guideSteps)
end

function Guide:initGuideManager()
  local guideManagerTable = {}
  local max = ControllerFactory:Instance():getControllerCount()
  for i = 0, max do
    guideManagerTable[i] = {}
  	guideManagerTable[i][GuideConfig.GuideManagerTypeComponent] = {}
  	guideManagerTable[i][GuideConfig.GuideManagerTypeStepModuleGroup]     = {}
  end
  self:setGuideManagerTable(guideManagerTable)
end

------
--  Getter & Setter for
--      Guide._GuideManagerTable 
-----
function Guide:setGuideManagerTable(GuideManagerTable)
	self._GuideManagerTable = GuideManagerTable
end

function Guide:getGuideManagerTable()
	return self._GuideManagerTable
end

function Guide:registComponent(componentId,componentObject,controllerType)
  local guideManagerTable = self:getGuideManagerTable()
  if controllerType == nil then
    controllerType = ControllerFactory:Instance():getCurrentControllerType()
  end
  if guideManagerTable[controllerType][GuideConfig.GuideManagerTypeComponent][componentId] ~= nil then
    guideManagerTable[controllerType][GuideConfig.GuideManagerTypeComponent][componentId] = nil
  end
  guideManagerTable[controllerType][GuideConfig.GuideManagerTypeComponent][componentId] = componentObject
end

function Guide:unregistAllComponent(controllerType)
  local guideManagerTable = self:getGuideManagerTable()
  local controllerManagerTable = guideManagerTable[controllerType][GuideConfig.GuideManagerTypeComponent]
  assert(controllerManagerTable ~= nil)
  for key, component in pairs(controllerManagerTable) do
  	controllerManagerTable[key] = nil
  end
  guideManagerTable[controllerType][GuideConfig.GuideManagerTypeComponent] = nil
  guideManagerTable[controllerType][GuideConfig.GuideManagerTypeComponent] = {}
end

------
--  Getter & Setter for
--      Guide._GuideStepIdWhenOffLine 
-----
function Guide:setGuideStepIdWhenOffLine(GuideStepIdWhenOffLine)
	self._GuideStepIdWhenOffLine = GuideStepIdWhenOffLine
end

function Guide:getGuideStepIdWhenOffLine()
	return self._GuideStepIdWhenOffLine
end

function Guide:initGuides()
  self._guideLayer = nil
  self._mGuides = {}
  
  local function sortTables(a, b)
     return a < b
  end
  
  local guideIds = {}
  for guideId, guide in pairs(AllConfig.guide) do
      table.insert(guideIds,guideId)
      --echo("guideId:",guideId)
  end
  table.sort(guideIds,sortTables)
  for key , guideId in pairs(guideIds) do
      local guideInfo = GuideInfo.new(guideId)
  	  table.insert(self._mGuides,guideInfo)
  end
end


function Guide:getGuideStepByStepId(stepId)
	return self:getAllGuideSteps()[stepId]
end

function Guide:isMatchConditionByGuideStepId(stepId)
  local step = self:getGuideStepByStepId(stepId)
  return self:isMatchConditionByGuideStep(step)
end

function Guide:isMatchConditionByGuideStep(guideStep)
  local meetConditions = false
  if guideStep:getType() == GuideConfig.GuideTypeLevel then
      local playerLevel = GameData:Instance():getCurrentPlayer():getLevel()
      if guideStep:getTypeValue() <=  playerLevel then
         meetConditions = true
      end
  elseif guideStep:getType() == GuideConfig.GuideTypeMission then
      if Quest:Instance():checkTaskIsFinishById(guideStep:getTypeValue()) == true then
         meetConditions = true
      end
  elseif guideStep:getType() == GuideConfig.GuideTypeEnterStage then
  
  elseif guideStep:getType() == GuideConfig.GuideTypeFinishedStage then
      --local stage = Scenario:Instance():getCurrentStage()
      local stage = Scenario:Instance():getStageById(guideStep:getTypeValue())
      assert(stage ~= nil)
      if stage:getIsPassed() == true then
        meetConditions = true
      end
  end
  
  return meetConditions
end

function Guide:getGuideStepsByStepType(stepType)
  local steps = {}
  for key, m_stageStep in pairs(self:getAllGuideSteps()) do
  	  if m_stageStep:getType() == stepType then
  	     table.insert(steps,m_stageStep)
  	  end
  end
  return steps
end


------
--  Getter & Setter for
--      Guide._AllGuideSteps 
-----
function Guide:setAllGuideSteps(AllGuideSteps)
	self._AllGuideSteps = AllGuideSteps
end

function Guide:getAllGuideSteps()
	return self._AllGuideSteps
end


------
--  Getter & Setter for
--      Guide._CurrentGuideInfo 
-----
function Guide:setCurrentGuideInfo(CurrentGuideInfo)
  assert(CurrentGuideInfo)
--  if self._CurrentGuideInfo ~= nil then
--   self:setLastGuideInfo(clone(self._CurrentGuideInfo))
--  end
	self._CurrentGuideInfo = CurrentGuideInfo
end

function Guide:getCurrentGuideInfo()
	return self._CurrentGuideInfo
end

function Guide:setLastGuideInfo(lastGuideInfo)
  self._lastGuideInfo = nil
  self._lastGuideInfo = lastGuideInfo
end

function Guide:getLastGuideInfo()
	return self._lastGuideInfo
end

function Guide:removeGuideLayer()
	GameData:Instance():getCurrentScene():getBottomBlock():setIsScrollLock(false)
	local oldLayer = self:getGuideLayer()
	if oldLayer~= nil then
		oldLayer:removeFromParentAndCleanup(true)
		self:setGuideLayer(nil)
	end
end

function Guide:createGuideLayer(currentGuideStep,guidRect)
  local guideLayer = nil 
  local frameType = currentGuideStep:getFrameType()
  if frameType == 0 then
    guideLayer = self:createNormalGuideLayer(currentGuideStep,guidRect)
  elseif frameType == 1 then
    guideLayer = GuidePopup.new(currentGuideStep)
  elseif frameType == 2 then
    guideLayer = self:createLoadImgGuideLayer(currentGuideStep)
  else
    assert(false,"unexpected frame type: "..currentGuideStep:getFrameType())
  end
  return guideLayer
end

function Guide:createLoadImgGuideLayer(currentGuideStep)
  local guideLayer = CCLayerColor:create(ccc4(0,0,0,125), display.width, display.height)
  guideLayer:setTouchEnabled(true)
  local priority = -300
  guideLayer:addTouchEventListener(function(event, x, y)
                                    if event == "began" then
                                      return true
                                    elseif event == "ended" then
                                      Guide:Instance():removeGuideLayer()
                                      CCNotificationCenter:sharedNotificationCenter():postNotification(GuideConfig.SendGuideId2Server)
                                      CCNotificationCenter:sharedNotificationCenter():postNotification(GuideConfig.GuideLayerRemoved)
                                    end
                                  end,
                              false, priority, true)
                              
   local resId = currentGuideStep:getPopIcon()
   local img = _res(resId)
   if img ~= nil then
    guideLayer:addChild(img)
    img:setPosition(display.cx,display.cy)
   end
   
   return guideLayer
end

function Guide:createNormalGuideLayer(currentGuideStep,guidRect)
  local offsetx = 0
  local offsety = 0

  local guideLayer = GuideLayer:createGuideLayer()
  local m_bIsHideArrowsw = false
  local m_fGirlPosY = 0
  guideLayer.stepId = currentGuideStep:getStepId()
  guideLayer.isWeak = currentGuideStep:getIsWeakStep()
  
  local function initBgPos()
    local winSize = CCDirector:sharedDirector():getWinSize()
    if (guidRect.size.width >= winSize.width and guidRect.size.height >= winSize.height) or (guidRect.size.width == 0 and guidRect .size.height == 0) then
      m_bIsHideArrowsw = true
    else
      m_bIsHideArrowsw = false
    end

    local  midHeight = guidRect.origin.y + guidRect.size.height/2.0
    if midHeight <= winSize.height/2 and midHeight >0 then
      m_fGirlPosY = midHeight+ guidRect.size.height/2.0 + 120
    elseif midHeight > winSize.height/2 and midHeight <winSize.height then
      m_fGirlPosY = midHeight - guidRect.size.height/2.0 - 220
    else
      m_fGirlPosY = winSize.height/3.0
    end
    
    m_fGirlPosY = m_fGirlPosY + 85
  end

  local function setMaskPicturePath(strDesc,tips,poxPoint)
    local winSize = CCDirector:sharedDirector():getWinSize()
    local tipArrow = CCSprite:create("img/guide/guide_finger.png")
    tipArrow:setAnchorPoint(ccp(0,0.5))
    if m_bIsHideArrowsw == true then
      tipArrow:setVisible(false)
    end

    local tipIconNode = CCLayerColor:create(ccc4(0,0,0,0))
    tipIconNode:setContentSize(CCSizeMake(310,150))

    local playerGuideBg 
    playerGuideBg = CCSprite:create("img/guide/guide_bg.png")
    playerGuideBg:setAnchorPoint(ccp(0,0.5))

    playerGuideBg:setScale(0.3)
    playerGuideBg:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5, 1.0),0.6))
    if poxPoint.y ~= 0 then
      playerGuideBg:setPosition(ccp(20.0,poxPoint.y ))
    else
      playerGuideBg:setPosition(ccp(20.0,m_fGirlPosY ))
    end
    guideLayer:addChild(playerGuideBg,10,playerGuideBgTag)
    local m_ArrowPos =  ccp(CCDirector:sharedDirector():getWinSize().width/2.0,CCDirector:sharedDirector():getWinSize().height/2.0)
    local pos= CCPointZero
    --tipArrow:setAnchorPoint(ccp(0.5,0.5))
    tipArrow:setPosition(m_ArrowPos)
    pos = CCPointMake(guidRect.origin.x + guidRect.size.width/2,guidRect.origin.y + guidRect.size.height/2-tipArrow:getContentSize().height/2.0)
    m_ArrowPos = pos
    
    local scaleX = 1
    if pos.x > display.width - tipArrow:getContentSize().width then
       scaleX = -1
    end
    tipArrow:setScaleX(scaleX)

    local action = CCMoveTo:create(0.6,pos)
    tipArrow:runAction(action)

    --  TODO:手指运动
    tipArrow:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCScaleBy:create(0.3, 0.95),CCScaleTo:create(0.325, scaleX,1))))
    guideLayer:addChild(tipArrow,100)

    local tipsIcon = CCSprite:create("img/guide/arrow.png")
    tipsIcon:setPosition(ccp(playerGuideBg:getContentSize().width - 45.0,58))
    local actionUp = CCJumpBy:create(2, CCPointMake(0,0), 5, 4)
    tipsIcon:runAction(CCRepeatForever:create(actionUp))
    playerGuideBg:addChild(tipsIcon,10)

    -- // 计算文字框的背景用图以及位置
    tipIconNode:setAnchorPoint(ccp(0,0))
    tipIconNode:setPosition(ccp(275,25))
    playerGuideBg:addChild(tipIconNode,0)

    if string.len(strDesc) == 0 and string.len(tips) == 0 then
      playerGuideBg:removeFromParentAndCleanup(true)
    else

      local label = RichLabel:create(strDesc, "Courier-Bold", 22, CCSizeMake(295, 110),true,false)
      label:setPosition(ccp(20,48))
      label:setColor(ccc3(69,20,1))

      local tipsLabel = RichLabel:create(tips,"Courier-Bold",22,CCSizeMake(255, 25),true,false)
      tipsLabel:setPosition(ccp(20,28))
      tipIconNode:addChild(label)
      tipIconNode:addChild(tipsLabel)
    end

  end

  guideLayer:setMaskRect(guidRect)
  --guideLayer:setMaskPicturePath(currentGuideStep:getDesc(),currentGuideStep:getTips(),ccp(0,0),leftOrRight,arrowUpOrDown) --
  initBgPos()
  setMaskPicturePath(currentGuideStep:getDesc(),currentGuideStep:getTips(),ccp(0,0)) --,leftOrRight,arrowUpOrDown

  local  resId = nil
  if currentGuideStep:getEffectType()  == GuideConfig.GuideEffectTypeCyle then
    resId = 5020133
  end

  if currentGuideStep:getEffectType()  == GuideConfig.GuideEffectTypeRect then
    resId = 5020134
  end
  
  if resId ~= nil 
  and guidRect.size.height ~= 0 and guidRect.size.width ~= 0 
  and guidRect.size.width ~= display.width and guidRect.size.height ~= display.height
  then
    local guideAnimation,offsetX,offsetY,duration = _res(resId)
    guideAnimation:setPosition(ccp(offsetX + guidRect.origin.x + guidRect.size.width/2 + offsetx,offsetY + guidRect.origin.y + guidRect.size.height/2 + offsety))
    guideLayer:addChild(guideAnimation,99)
    guideAnimation:getAnimation():play("default")
  end
  
  if self:getGuideLayerTouchEnabled() ~= nil then
     guideLayer:setTouchEnabled(self:getGuideLayerTouchEnabled())
  end
  
  return guideLayer
end

------
--  Getter & Setter for
--      Guide._GuideLayerTouchEnabled 
-----
function Guide:setGuideLayerTouchEnabled(GuideLayerTouchEnabled)
	self._GuideLayerTouchEnabled = GuideLayerTouchEnabled
	if self:getGuideLayer() ~= nil then
     self:getGuideLayer():setTouchEnabled(GuideLayerTouchEnabled)
  end
end

function Guide:getGuideLayerTouchEnabled()
	return self._GuideLayerTouchEnabled
end

function Guide:setGuideLayer(guideLayer)

  self._guideLayer = guideLayer
  if guideLayer ~= nil then
     GameData:Instance():getCurrentScene():addChild(self._guideLayer,99999)
     GameData:Instance():getCurrentScene():getBottomBlock():tipScenario()
  end
end

function Guide:getGuideLayer()
  return self._guideLayer
end

function Guide:getGuides()
  return self._mGuides
end

function Guide:getGuideInfoByGuideId(guideId)
  local  guide = nil 
   for i = 1, #self:getGuides() do
      if self:getGuides()[i]:getGuideId() == guideId then
         guide = self:getGuides()[i]
         break
      end
   end
  return guide
end

function Guide:setCurGuideInfoById(guideId)
  --print("guideId",guideId)
  --print(self:getGuides()[#self:getGuides()]:getGuideId())
  --assert(false)
  
  if self:getGuideStepIdWhenOffLine() ~= nil then
     self:setGuideStepIdWhenOffLine(nil)
     return
  end
  
  self:init()
  if guideId == 0 then
     local firstGuideInfo = self:getGuides()[1]
     self:setCurrentGuideInfo(firstGuideInfo) -- set current guideInfo
     return
  end
  
  local guideInfo = nil
  for i = 1, #self:getGuides() do
  	  guideInfo = self:getGuides()[i]
  	  if guideInfo:getGuideId() <= guideId then
         guideInfo:setIsFinished(true)
         --echo("Finished Guide:",guideInfo:getGuideId())
         --Guide:Instance():setLastGuideInfo(guideInfo)
      else
--         if guideId <= self:getGuides()[1]:getGuideId() then
--            self:setCurrentGuideInfo(self:getGuides()[1]) -- set current guideInfo
--         end
         break
      end
  end
  
  -- force skip guide with an enough large guide id
  if guideId >= self:getGuides()[#self:getGuides()]:getGuideId() then
     --self:getGuides()[#self:getGuides()]:getGuideSteps
     local maxlength = #self:getGuides()[#self:getGuides()]:getGuideSteps()
     --print(maxlength)
     --assert(false)
     self:getGuides()[#self:getGuides()]:setCurrentStep(self:getGuides()[#self:getGuides()]:getGuideSteps()[maxlength])
     self:setCurrentGuideInfo(self:getGuides()[#self:getGuides()])
     return
  end
  
  
  local currentGuideInfo = self:getGuideInfoByGuideId(guideId)
  assert(currentGuideInfo ~= nil,"Invaild guide info :"..guideId)
  self:setCurrentGuideInfo(currentGuideInfo) -- set current guideInfo
  
  self:jumpToNextGuideInfo()
end

function Guide:goNextStep()
  self:getCurrentGuideInfo():goNextStep()
end

------
--  Getter & Setter for
--      Guide._CurrentGuideInfo 
-----
--function Guide:setCurrentGuideInfo(CurrentGuideInfo)
--	self._CurrentGuideInfo = CurrentGuideInfo
--end
--
--function Guide:getCurrentGuideInfo()
--	return self._CurrentGuideInfo
--end

function Guide:jumpToNextGuideInfo() -- when a guideInfo was finished get an new guideInfo
  
  Guide:Instance():setLastGuideInfo(self:getCurrentGuideInfo())
  
  local guide = nil
  for i = 1, #self:getGuides() do
      guide = self:getGuides()[i]
      if guide:getIsFinished() == false then
         self:setCurrentGuideInfo(guide) -- set current guideInfo
         break
      end
  end
  
  if guide == nil then -- the last step
     
  end
  
end

function Guide:sendGuideId2Server()
  --cleanup weak step
  local currentGuideLayer = Guide:Instance():getGuideLayer()
  if currentGuideLayer ~= nil then
     print("currentGuideLayerInfo: isWeak:",currentGuideLayer.isWeak,"stepId:",currentGuideLayer.stepId)
     if currentGuideLayer.isWeak == true then
       Guide:Instance():removeGuideLayer()
     end
  end
	local lastGuideInfo = Guide:Instance():getLastGuideInfo()
	if lastGuideInfo ~= nil then
		print("lastGuideInfo",lastGuideInfo)
		print("lastGuideInfo:getCloseState() ", lastGuideInfo:getCloseState() )
		print("---------------------lastGuideInfo:getGuideId()",lastGuideInfo:getGuideId())
		print("lastGuideInfo:getIsFinished()",lastGuideInfo:getIsFinished())
	end

	if lastGuideInfo ~= nil and lastGuideInfo:getCloseState() == 0 and lastGuideInfo:getIsFinished() == true then
		local guideInfoId = lastGuideInfo:getGuideId()
		print("send guideId to server:",guideInfoId)
    if self:getCurrentGuideInfo():getCloseState() == 1 then
       guideInfoId = self:getCurrentGuideInfo():getGuideId()
    end
    
    local data = PbRegist.pack(PbMsgId.SaveNewBirdStep,{step = guideInfoId})
    net.sendMessage(PbMsgId.SaveNewBirdStep,data)
	end
end

--function Guide:guideNextStepAtHome()
--  echo(" === Guide:guideNextStepAtHome ===")
--  if ControllerFactory:Instance():getCurrentControllerType() == ControllerType.HOME_CONTROLLER then
--    local homeController = ControllerFactory:Instance():getCurController()
--    if homeController ~= nil then
--      homeController:getHomeView():triggerNewBird()
--    end
--  end
--end

return Guide