require("model.guide.GuideStep")
GuideInfo = class("GideInfo")

function GuideInfo:ctor(guideId)
    self:setIsFinished(false)
    self:setCloseStateWithGuideId(guideId)
    
    --self:setTrigerUIs(AllConfig.guide[guideId].ui_id) -- type:arrays
    self:setConditionType(AllConfig.guide[guideId].condition_type)
    self:setConditionValue(AllConfig.guide[guideId].value)
    self:setGuideId(guideId)
    self:setCurrentStepIdex(1)
end

------
--  Getter & Setter for
--      GuideInfo._GuideId 
-----
function GuideInfo:setGuideId(GuideId)
	self._GuideId = GuideId
	local steps = {}
	local stepIds = AllConfig.guide[GuideId].stepid
	for key, stepId in pairs(stepIds) do
		 local guideStep = Guide:Instance():getAllGuideSteps()[stepId]
		 assert(guideStep ~= nil,"guideStep "..stepId.." error")
		 guideStep:setGuideInfo(self)
		 table.insert(steps,guideStep)
	end
	self:setGuideSteps(steps)
end

function GuideInfo:getGuideId()
	return self._GuideId
end

------
--  Getter & Setter for
--      Guide._TrigerUIs 
-----
--function GuideInfo:setTrigerUIs(TrigerUIs)
--	self._TrigerUIs = TrigerUIs
--end
--
--function GuideInfo:getTrigerUIs()
--	return self._TrigerUIs
--end

------
--  Getter & Setter for
--      GuideInfo._ConditionType 
-----
function GuideInfo:setConditionType(ConditionType)
	self._ConditionType = ConditionType
end

function GuideInfo:getConditionType()
	return self._ConditionType
end

------
--  Getter & Setter for
--      GuideInfo._ConditionValue 
-----
function GuideInfo:setConditionValue(ConditionValue)
	self._ConditionValue = ConditionValue
end

function GuideInfo:getConditionValue()
	return self._ConditionValue
end

function GuideInfo:goNextStep()
   local guideId = self:getGuideId()
   if self:getCloseState() == 1 then
      print("---------------------------------------send guideId to server: close == 1",guideId)
      local data = PbRegist.pack(PbMsgId.SaveNewBirdStep,{step = guideId})
      net.sendMessage(PbMsgId.SaveNewBirdStep,data)
   end
   
   local currentStepIdx = self:getCurrentStepIdex() + 1
   if currentStepIdx > #self:getGuideSteps() then
      self:setIsFinished(true)
      Guide:Instance():jumpToNextGuideInfo()
   else
      self:setCurrentStepIdex(currentStepIdx)
   end
   
   
end



------
--  Getter & Setter for
--      GuideInfo._GuideSteps 
-----
function GuideInfo:setGuideSteps(GuideSteps)
	self._GuideSteps = GuideSteps
end

function GuideInfo:getGuideSteps()
	return self._GuideSteps
end

------
--  Getter & Setter for
--      GuideInfo._CurrentStepIdex 
-----
function GuideInfo:setCurrentStepIdex(CurrentStepIdex)
	self._CurrentStepIdex = CurrentStepIdex
	self:setCurrentStep(self:getGuideSteps()[CurrentStepIdex])
end

function GuideInfo:getCurrentStepIdex()
	return self._CurrentStepIdex
end

------
--  Getter & Setter for
--      GuideInfo._CurrentStep 
-----
function GuideInfo:setCurrentStep(CurrentStep)
	self._CurrentStep = CurrentStep
end

function GuideInfo:getCurrentStep()
	return self._CurrentStep
end

------
--  Getter & Setter for
--      GuideInfo._IsFinished 
-----
function GuideInfo:setIsFinished(IsFinished)
	self._IsFinished = IsFinished
end

function GuideInfo:getIsFinished()
	return self._IsFinished
end

function GuideInfo:setCloseStateWithGuideId(guideId)
	self.closeState = AllConfig.guide[guideId].close
end

function GuideInfo:getCloseState()
	return self.closeState
end


return GuideInfo