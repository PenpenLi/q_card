GuideStep = class("GuideStep")
function GuideStep:ctor(stepId)
   self:setStepId(stepId)
end

------
--  Getter & Setter for
--      GuideStep._StepId 
-----
function GuideStep:setStepId(StepId)
	self._StepId = StepId
	self:setDesc(AllConfig.course[StepId].desciption)
  self:setTips(AllConfig.course[StepId].desciption2)
  --self:setFlag(AllConfig.course[StepId].flag)
  self:setEffectType(AllConfig.course[StepId].effect)
  self:setFrameType(AllConfig.course[StepId].frame_type)
  self:setPopIcon(AllConfig.course[StepId].newsystem_icon)
  self:setPopTitle(AllConfig.course[StepId].newsystem_title)
  self:setPopContent(AllConfig.course[StepId].newsystem_text)
  self:setPopCloseType(AllConfig.course[StepId].newsystem_jump)
  self:setComponentId(AllConfig.course[StepId].component_id)
  self:setRangeType(AllConfig.course[StepId].range_type)
  self:setGlobalRangeId(AllConfig.course[StepId].global_range_id)
  self:setTouchSize(AllConfig.course[StepId].touch_size)
  self:setRangePosOffset(AllConfig.course[StepId].range_pos_offset)
  self:setSkipUiId(AllConfig.course[StepId].skip_ui_id)
  self:setTriggerUiIds(AllConfig.course[StepId].ui_id)
  self:setIsWeakStep(AllConfig.course[StepId].is_weak > 0)
end

function GuideStep:getStepId()
	return self._StepId
end

------
--  Getter & Setter for
--      GuideStep._TriggerUiIds 
-----
function GuideStep:setTriggerUiIds(TriggerUiIds)
	self._TriggerUiIds = TriggerUiIds
end

function GuideStep:getTriggerUiIds()
	return self._TriggerUiIds
end

------
--  Getter & Setter for
--      GuideStep._IsWeakStep 
-----
function GuideStep:setIsWeakStep(IsWeakStep)
	self._IsWeakStep = IsWeakStep
end

function GuideStep:getIsWeakStep()
	return self._IsWeakStep
end

------
--  Getter & Setter for
--      GuideStep._SkipUiId 
-----
function GuideStep:setSkipUiId(SkipUiId)
	self._SkipUiId = SkipUiId
end

function GuideStep:getSkipUiId()
	return self._SkipUiId
end

------
--  Getter & Setter for
--      GuideStep._RangeType 
-----
function GuideStep:setRangeType(RangeType)
	self._RangeType = RangeType
end

function GuideStep:getRangeType()
	return self._RangeType
end

------
--  Getter & Setter for
--      GuideStep._GlobalRangeId 
-----
function GuideStep:setGlobalRangeId(GlobalRangeId)
	self._GlobalRangeId = GlobalRangeId
end

function GuideStep:getGlobalRangeId()
	return self._GlobalRangeId
end

------
--  Getter & Setter for
--      GuideStep._TouchSize 
-----
function GuideStep:setTouchSize(TouchSize)
	self._TouchSize = TouchSize
end

function GuideStep:getTouchSize()
	return self._TouchSize
end

------
--  Getter & Setter for
--      GuideStep._RangePosOffset 
-----
function GuideStep:setRangePosOffset(RangePosOffset)
	self._RangePosOffset = RangePosOffset
end

function GuideStep:getRangePosOffset()
	return self._RangePosOffset
end

------
--  Getter & Setter for
--      GuideStep._PopCloseType 
-----
function GuideStep:setPopCloseType(PopCloseType)
	self._PopCloseType = PopCloseType
end

function GuideStep:getPopCloseType()
	return self._PopCloseType
end

------
--  Getter & Setter for
--      GuideStep._PopContent 
-----
function GuideStep:setPopContent(PopContent)
	self._PopContent = PopContent
end

function GuideStep:getPopContent()
	return self._PopContent
end

------
--  Getter & Setter for
--      GuideStep._ComponentId 
-----
function GuideStep:setComponentId(ComponentId)
	self._ComponentId = ComponentId
end

function GuideStep:getComponentId()
	return self._ComponentId
end

------
--  Getter & Setter for
--      GuideStep._PopTitle 
-----
function GuideStep:setPopTitle(PopTitle)
	self._PopTitle = PopTitle
end

function GuideStep:getPopTitle()
	return self._PopTitle
end

------
--  Getter & Setter for
--      Guide._PopIcon 
-----
function GuideStep:setPopIcon(PopIcon)
	self._PopIcon = PopIcon
end

function GuideStep:getPopIcon()
	return self._PopIcon
end
------
--  Getter & Setter for
--      Guide._FrameType 
-----
function GuideStep:setFrameType(FrameType)
	self._FrameType = FrameType
end

function GuideStep:getFrameType()
	return self._FrameType
end

------
--  Getter & Setter for
--      GuideStep._EffectType 
-----
function GuideStep:setEffectType(EffectType)
	self._EffectType = EffectType
end

function GuideStep:getEffectType()
	return self._EffectType
end

------
--  Getter & Setter for
--      GuideStep._Flag 
-----
function GuideStep:setFlag(Flag)
	self._Flag = Flag
end

function GuideStep:getFlag()
	return self._Flag
end

------
--  Getter & Setter for
--      GuideStep._Type 
-----
function GuideStep:setType(Type)
	self._Type = Type
end

function GuideStep:getType()
	return self._Type
end

------
--  Getter & Setter for
--      GuideStep._TypeValue 
-----
function GuideStep:setTypeValue(TypeValue)
	self._TypeValue = TypeValue
end

function GuideStep:getTypeValue()
	return self._TypeValue
end

------
--  Getter & Setter for
--      GuideStep._OpenTask 
-----
function GuideStep:setOpenTask(OpenTask)
	self._OpenTask = OpenTask
end

function GuideStep:getOpenTask()
	return self._OpenTask
end

------
--  Getter & Setter for
--      GuideStep._Desc 
-----
function GuideStep:setDesc(Desc)
	self._Desc = Desc
end

function GuideStep:getDesc()
	return self._Desc
end

------
--  Getter & Setter for
--      GuideStep._Tips 
-----
function GuideStep:setTips(Tips)
	self._Tips = Tips
end

function GuideStep:getTips()
	return self._Tips
end

------
--  Getter & Setter for
--      GuideStep._GuideInfo 
-----
function GuideStep:setGuideInfo(GuideInfo)
	self._GuideInfo = GuideInfo
	if GuideInfo ~= nil then
	 self:setType(GuideInfo:getConditionType())
   self:setTypeValue(GuideInfo:getConditionValue())
  end
end

function GuideStep:getGuideInfo()
	return self._GuideInfo
end

return GuideStep