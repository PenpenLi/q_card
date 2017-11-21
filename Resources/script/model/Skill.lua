require("model.Item")

Skill = class("Skill",Item)

SkillType = { "INITIATIVE" , "PASSIVITY" }

function Skill:ctor(card)
  self:setCard(card)
end

function Skill:initBySkillId(skillId)
  local skillItem = AllConfig.cardskill[skillId]
  local skillName = skillItem.skill_name
  if skillName ~=nil then
    self:setName(skillName)
  end
  local skillRangeResId = skillItem.skill_range
  self:setRangeResId(skillRangeResId)
  local skillDesc = skillItem.skill_description
  if skillDesc ~= nil then
    self:setDescription(skillDesc)
  end
  self:setSkillRatio(skillItem.skill_ratio)
end

function Skill:update(cardConfigId, skillExp)
  -- echo("==== skill update ====",cardConfigId, skillExp)
  local maxlevel = AllConfig.unit[cardConfigId].skill_level_max 
  if self:getCard() ~= nil then 
    maxlevel = math.min(maxlevel, self:getCard():getLevel())
  end 
  self:setMaxLevel(maxlevel)
  
  self:setExperience(skillExp)

  local level = self:getLevel()
  self:setCurLevelTotalExp(AllConfig.skillexp[level].total_exp)
  self:setMaxLevelTotalExp(AllConfig.skillexp[self:getMaxLevel()].total_exp)

  local skillId = AllConfig.unit[cardConfigId].skill
  local skillItem = AllConfig.cardskill[skillId]

  local skillName = skillItem.skill_name
  if skillName ~=nil then
    self:setName(skillName)
  end
  
  local skillRangeResId = skillItem.skill_range
  self:setRangeResId(skillRangeResId)
  
  local skillDesc = skillItem.skill_description
  if skillDesc ~= nil then
    self:setDescription(skillDesc)
  end
  
  self:setSkillRatio(skillItem.skill_ratio)
end

------
--  Getter & Setter for
--      Skill._RangeResId 
-----
function Skill:setRangeResId(RangeResId)
	self._RangeResId = RangeResId
end

function Skill:getRangeResId()
	return self._RangeResId
end 

function Skill:setLevel(level)
  self._level = level
end

function Skill:getLevel()
  return self._level
end

function Skill:setMaxLevel(maxLevel)
  self._maxLevel = maxLevel
end

function Skill:getMaxLevel()
  return self._maxLevel
end

function Skill:setType(skillType)
	self._skillType = skillType
end

function Skill:getType()
	return self._skillType
end

function Skill:setDescription(description)
	self._description = description
end

function Skill:getDescription()
	return self._description
end

function Skill:getLevelByExp(exp)

  local level = 1
  local level_max = self:getMaxLevel()
  --get level by skill exp
  for i=1, level_max do 
    local totalExp = AllConfig.skillexp[i].total_exp
    if exp >= totalExp then 
      level = AllConfig.skillexp[i].skill_level
    else 
      break
    end
  end

  if level > level_max then 
    level = level_max
  end

  return level
end 

function Skill:setExperience(exp)
	self._exp = exp
  self:setLevel(self:getLevelByExp(exp))
end

function Skill:getExperience()
	return self._exp
end

function Skill:setCurLevelTotalExp(exp)
  self._curTotalExp = exp
end

function Skill:getCurLevelTotalExp()
  return self._curTotalExp
end

function Skill:setMaxLevelTotalExp(exp)
  self._maxLevelExp = exp
end

function Skill:getMaxLevelTotalExp()
  return self._maxLevelExp
end

function Skill:getExpPercentByLeve(level, exp)
  local percent = 100
  if level < self:getMaxLevel() then
    local nextlevel_exp = AllConfig.skillexp[level+1].skill_exp
    local nextlevel_totalExp = AllConfig.skillexp[level+1].total_exp
    percent = 100*(1 - (nextlevel_totalExp-exp)/nextlevel_exp)
  end

  echo("---Skill:getExpPercentByLeve:level,exp,percent=", level, exp,percent)
  return percent
end

function Skill:setSkillRatio(ratio)
  self._skillRatio = ratio
end 

function Skill:getSkillRatio()
  return self._skillRatio
end 

function Skill:setCard(card)
  self._card = card
end 

function Skill:getCard()
  return self._card
end 

return Skill