local NewBirdGuideManager = {}

function NewBirdGuideManager.execute(currentUiId)

  if NEW_BIRD_SKIP_ENABLED > 0 then
    return
  end
  
  if Guide:Instance():getGuideLayerTouchEnabled() == false then
    return
  end
  
  if currentUiId ~= nil then
    local notError = false
    local max = ControllerFactory:Instance():getControllerCount()
    for i = 1, max do
      if currentUiId == i then
        notError = true
        break
      end
    end
    
    assert(notError,"Invaild CurrentControllerType:",currentUiId)
    
    if ControllerFactory:Instance():getCurrentControllerType() ~= currentUiId then
      return
    end
  else
    currentUiId = ControllerFactory:Instance():getCurrentControllerType()
  end
  
  if currentUiId == ControllerType.REGIST_CONTROLLER then
    return 
  end
  
  local guideManagerTable = Guide:Instance():getGuideManagerTable()

  local autoSkip = false
  local isBreak = false 
    
	local steps = guideManagerTable[currentUiId][GuideConfig.GuideManagerTypeStepModuleGroup]
	
	local currnetCommponentId = 0

	local currentGuideStep = Guide:Instance():getCurrentGuideInfo():getCurrentStep()
	for key, step in pairs(steps) do
		local stepId = step:getStepId()
		
	  assert(step:getRangeType() == GuideConfig.RangeTypeComponent 
	  or step:getRangeType() == GuideConfig.RangeTypeRectConfig 
	  or step:getRangeType() == GuideConfig.RangeTypeRectFullScreen
	  or step:getRangeType() == GuideConfig.RangeTypeBattleCardMove
	  or step:getRangeType() == GuideConfig.RangeTypeBattleFormationCardMove,
	  "Invalid range type: "..step:getRangeType()..", must be 0 , 1, 2 ,3 or 5")
	  echo("-----------------now trigger stepid:",stepId,"expect stepId:",currentGuideStep:getStepId())
	  if stepId == currentGuideStep:getStepId() then
	    print("now checking:"..stepId.."  rangeType:"..step:getRangeType())
  	  if step:getRangeType() == GuideConfig.RangeTypeComponent then
  	    
  	    local meetConditions = Guide:Instance():isMatchConditionByGuideStep(currentGuideStep)
  	    if currentGuideStep:getSkipUiId() == currentUiId and meetConditions == true then
  	      Guide:Instance():goNextStep()
  	      isBreak = true 
  	      autoSkip = true
  	    else
    	    local componentObject = guideManagerTable[currentUiId][GuideConfig.GuideManagerTypeComponent][step:getComponentId()]
    	    assert(componentObject ~= nil,"Invalid componentObject: "..step:getComponentId())
    	    local touchSize = nil
    	    if #step:getTouchSize() > 0 then
    	      assert(#step:getTouchSize() == 2,"Touch size must have two params,now has "..#step:getTouchSize().." param(s)")
    	      touchSize = CCSizeMake(step:getTouchSize()[1],step:getTouchSize()[2])
    	    end
    	    
    	    local posOffset = ccp(0,0)
    	    if #step:getRangePosOffset() > 0 then
    	      assert(#step:getRangePosOffset() == 2,"Touch range pos offset must have two params,now has "..#step:getRangePosOffset().." param(s)")
            posOffset = ccp(step:getRangePosOffset()[1],step:getRangePosOffset()[2])
    	    end
    	    
    	    if step:getComponentId() > 0 and currentUiId == ControllerType.HOME_CONTROLLER then
    	      ControllerFactory:Instance():getCurController():getHomeView():scrollToMenu(step:getComponentId())
    	    end
    	    
    	    isBreak,autoSkip = NewBirdGuideManager.triggerGuideWithComponent(stepId,componentObject,touchSize,posOffset,currentUiId)
  	    end
  	  elseif step:getRangeType() == GuideConfig.RangeTypeRectConfig then
  	    local globalRangeId = step:getGlobalRangeId()
  	    local rect = GuideConfig.RangeType[globalRangeId]
  	    assert(rect ~= nil,"Invalid global range id:"..globalRangeId)
  	    isBreak,autoSkip = NewBirdGuideManager.triggerGuide(stepId,rect,currentUiId)
  	  elseif step:getRangeType() == GuideConfig.RangeTypeRectFullScreen then
  	    isBreak,autoSkip = NewBirdGuideManager.triggerGuide(stepId,CCRectMake(0,0,0,0),currentUiId)
  	  elseif step:getRangeType() == GuideConfig.RangeTypeBattleCardMove 
  	  or step:getRangeType() == GuideConfig.RangeTypeBattleFormationCardMove then
  	    assert(#step:getRangePosOffset() == 2,"When range type is BattleCardMove or BattleFormationCardMove,must has two params")
  	    assert(step:getRangePosOffset()[1] ~= step:getRangePosOffset()[2],"Each param can't be same number")
  	    isBreak,autoSkip = NewBirdGuideManager.triggerBattleCardMoveGuide(stepId,step:getRangePosOffset()[1],step:getRangePosOffset()[2],currentUiId)
  	  end
  	end
  	  
	  if isBreak == true or autoSkip == true then
       break
    end
	end
	
	local triggered = isBreak
	
  if autoSkip == true then
     return NewBirdGuideManager.reExecute(currentUiId)
  else
     return triggered,currentGuideStep
  end
  
end

function NewBirdGuideManager.reExecute(currentUiId)
  return _executeNewBird(currentUiId)
end

function NewBirdGuideManager.registComponent(componentId,componentObject,controllerType)
  Guide:Instance():registComponent(componentId,componentObject,controllerType)
end

function NewBirdGuideManager.triggerBattleCardMoveGuide(stepId,from,to,currentUiId)
  local triggered = false
  local currentGuideStep = Guide:Instance():getCurrentGuideInfo():getCurrentStep()
  -- check if guide match conditions
  local meetConditions = Guide:Instance():isMatchConditionByGuideStep(currentGuideStep)
  local currentGuideStep = Guide:Instance():getCurrentGuideInfo():getCurrentStep()
  if stepId == currentGuideStep:getStepId() and meetConditions == true then
    Guide:Instance():removeGuideLayer()
    if currentGuideStep:getRangeType() == GuideConfig.RangeTypeBattleCardMove then
      if ControllerFactory:Instance():getCurrentControllerType() ==  ControllerType.BATTLE_CONTROLLER then
       local battleController = ControllerFactory:Instance():getCurController()
       if battleController ~= nil then
          local battleView = battleController:getBattleView()
          if battleView ~= nil then
            battleView:tipMoveCard(from,to)
          end
       end
       Guide:Instance():goNextStep()
       triggered = true
     end
    elseif currentGuideStep:getRangeType() == GuideConfig.RangeTypeBattleFormationCardMove then
      local battleFormationView = BattleFormation:Instance():getView()
      if battleFormationView ~= nil then
        battleFormationView:tipMoveCard(from,to)
        Guide:Instance():goNextStep()
        triggered = true
      end
    end
  end
  
  echo("-----------------now trigger step is match conditions(battle(formation) card move):",stepId,triggered)
  
  return triggered,false,stepId
end

function NewBirdGuideManager.triggerGuide(stepId,guidRect,currentUiId,goNextStep)
  local triggered = false
  local autoSkip = false
  
  goNextStep = goNextStep or true
  
  if Guide:Instance():getCurrentGuideInfo() == nil then
     return triggered
  end
  
  local showGuideLayer = function(guideStep,guidRect)
    Guide:Instance():removeGuideLayer()
    GameData:Instance():getCurrentScene():getBottomBlock():setIsScrollLock(true)
    GameData:Instance():getCurrentScene():getBottomBlock():scrollByIndex(1)
    local guideLayer = Guide:Instance():createGuideLayer(guideStep,guidRect)
    Guide:Instance():setGuideLayer(guideLayer)
  end
  
  if goNextStep == true then
    local currentGuideStep = Guide:Instance():getCurrentGuideInfo():getCurrentStep()
    -- check if guide match conditions
    local meetConditions = Guide:Instance():isMatchConditionByGuideStep(currentGuideStep)
    if stepId == currentGuideStep:getStepId() and meetConditions == true then
       local targetStep = Guide:Instance():getGuideStepByStepId(stepId)
       if targetStep:getSkipUiId() == currentUiId then
         Guide:Instance():goNextStep()
         autoSkip = true
       else
         showGuideLayer(currentGuideStep,guidRect)
         Guide:Instance():goNextStep()
         triggered = true
       end
    end
    echo("-----------------now trigger step is match conditions:",currentGuideStep:getStepId(),stepId,meetConditions,triggered)
  else
    local step = Guide:Instance():getGuideStepByStepId(stepId)
    showGuideLayer(step,guidRect)
  end
  
  return triggered,autoSkip,stepId
end

function NewBirdGuideManager.reshowGuideLayer(step,currentUiId)
  assert(step ~= nil)
  local stepId = step:getStepId()
  local componentId = step:getComponentId()
  if componentId <= 0 then
    print("Invailed component")
    return 
  end
   
  local currentUiId = currentUiId or ControllerFactory:Instance():getCurrentControllerType()
  local guideManagerTable = Guide:Instance():getGuideManagerTable()
  local step = Guide:Instance():getGuideStepByStepId(stepId)
  local componentObject = guideManagerTable[currentUiId][GuideConfig.GuideManagerTypeComponent][step:getComponentId()]
  assert(componentObject ~= nil,"Invalid componentObject: "..step:getComponentId())
  local touchSize = nil
  if #step:getTouchSize() > 0 then
    assert(#step:getTouchSize() == 2,"Touch size must have two params,now has "..#step:getTouchSize().." param(s)")
    touchSize = CCSizeMake(step:getTouchSize()[1],step:getTouchSize()[2])
  end
  
  local posOffset = ccp(0,0)
  if #step:getRangePosOffset() > 0 then
    assert(#step:getRangePosOffset() == 2,"Touch range pos offset must have two params,now has "..#step:getRangePosOffset().." param(s)")
    posOffset = ccp(step:getRangePosOffset()[1],step:getRangePosOffset()[2])
  end
  NewBirdGuideManager.triggerGuideWithComponent(stepId,componentObject,touchSize,posOffset,currentUiId,false)
end

function NewBirdGuideManager.triggerGuideWithComponent(stepId,object,guidSize,offsetPos,currentUiId,goNextStep)

  local arrowsWorldPos = ccp(0,0)
  local posX = 0
  local posY = 0
  if object ~= nil and object:getParent() ~= nil then
     posX = object:getPositionX()
     posY = object:getPositionY()
     arrowsWorldPos = object:getParent():convertToWorldSpace(ccp(posX,posY))
  else
     arrowsWorldPos = ccp(object:getPosition())
  end
  if offsetPos ~= nil then
    arrowsWorldPos = ccpAdd(arrowsWorldPos,offsetPos)
  end
  
  if guidSize == nil then
     guidSize = CCSizeMake(object:getContentSize().width,object:getContentSize().height)
  end

  local arrowsRect = nil
  local ap = object:getAnchorPoint()
  if (ap.x > 0 or ap.y > 0) and object:getParent() ~= nil then
      if object:isIgnoreAnchorPointForPosition() == true then
        arrowsRect = CCRectMake(arrowsWorldPos.x, arrowsWorldPos.y, guidSize.width, guidSize.height)
      else
        arrowsRect = CCRectMake(arrowsWorldPos.x-ap.x*guidSize.width, arrowsWorldPos.y-ap.y*guidSize.height, guidSize.width, guidSize.height)
      end
  else
    arrowsRect = CCRectMake(arrowsWorldPos.x, arrowsWorldPos.y, guidSize.width, guidSize.height)
  end
  
  return NewBirdGuideManager.triggerGuide(stepId,arrowsRect,currentUiId,goNextStep)
end

_executeNewBird = NewBirdGuideManager.execute
_registNewBirdComponent = NewBirdGuideManager.registComponent