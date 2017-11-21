--[[
-- 一条成就数据
-- ]]--

AchievementData = class("AchievementData")

------------------ 固定属性 ---------------
function AchievementData:ctor(id)
	self:setAchievementId(id)

	local itemData = AllConfig.achievement[id] 
	self:setAchRootId(itemData.condition)
	self:setName(itemData.name) 
	self:setDesc(itemData.desc) 
	self:setAchievementType(itemData.sheet_type) 
	self:setAchTotalProgress(itemData.condition_para) 
	self:setJumpTypeVal(itemData.jump_type, itemData.jump_value) 
  self:setBonus(itemData.bonus) 
  --default val
  self:setIsFinish(false)
  self:setIsAwarded(false)
  self:setAchProgress(0)
end

function AchievementData:setAchievementId(id)
	self._achievementId = id 
end

function AchievementData:getAchievementId()
	return self._achievementId
end

function AchievementData:setAchRootId(id)
	self._achRootId = id 
end

function AchievementData:getAchRootId()
	return self._achRootId
end

function AchievementData:setName(name)
	self._name = name 
end

function AchievementData:getName()
	return self._name or ""
end

function AchievementData:setDesc(desc)
	self._desc = desc 
end

function AchievementData:getDesc()
	return self._desc or ""
end

function AchievementData:setAchievementType(achType)
	self._achType = achType
end

function AchievementData:getAchievementType()
	return self._achType
end

function AchievementData:setAchTotalProgress(var)
	self._achTotalProgress = var
end

function AchievementData:getAchTotalProgress()
	return self._achTotalProgress
end

function AchievementData:setJumpTypeVal(jumpType, jumpVal)
	self._jumpType = jumpType 
	self._jumpVal = jumpVal 
end

function AchievementData:getJumpTypeVal()
	return self._jumpType,self._jumpVal
end

function AchievementData:setBonus(bonusGroup)
	self._bonusData = {}
	for k, v in pairs(bonusGroup) do 
		table.insert(self._bonusData, v)
	end 
end

function AchievementData:getBonus()
  return self._bonusData or {}
end

------------------ 可变属性 ---------------
--是否已完成
function AchievementData:setIsFinish(isFinish)
	self._isFinished = isFinish
end

function AchievementData:getIsFinish()
	return self._isFinished
end

--是否已领取
function AchievementData:setIsAwarded(isGet)
	self._isAward = isGet
end

function AchievementData:getIsAwarded()
	return self._isAward 
end

function AchievementData:setAchProgress(var)
	self._achProgress = var
end

function AchievementData:getAchProgress()
	return self._achProgress or 0 
end

return AchievementData