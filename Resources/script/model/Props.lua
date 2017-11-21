require("model.Item")
require("common.Consts")

Props = class("Props",Item)

function Props:ctor(systemId, configId, count)
  Props.super.ctor(self)

 -- print(systemId,configId,count)
  self:setId(systemId)
  self:setConfigId(configId)
  self:setCount(count)

  local staticItem = AllConfig.item[configId]
  assert(staticItem,"item not exist, pls check the configuration.")
  self:setName(staticItem.item_name)
  self:setCurrencyType(staticItem.item_seqence)
  self:setSalePrice(staticItem.sell_price)
  self:setDescStr(staticItem.item_desc)
  self:setItemType(staticItem.item_type)
  self:setItemSequence(staticItem.item_seqence)
  self:setMaxGrade(staticItem.rare)

  if self:getItemType() == iType_CardChip then --card chip
    self:setGrade(1)
    -- if self:getMaxGrade() >= 4 then 
      self:setRefinedPrice(AllConfig.jianghun[configId].cost)
      self:setRefinedGainType(AllConfig.jianghun[configId].currency_type)
      self:setRefinedGain(AllConfig.jianghun[configId].currency) 
    -- end  
  else
    self:setGrade(staticItem.rare) --item / equip
  end

  self:setIconId(staticItem.item_resource)

  if self:getItemType() == iType_SkillBook then 
    self:setSkillExp(staticItem.bonus[3])
  elseif self:getItemType() == iType_XuanTie then
    self:setSkillExp(staticItem.upgrade_exp)
  else
    self:setSkillExp(0)
  end

  self:setQuality(staticItem.quality)
  self:setSaleFlag(staticItem.sell_state)
  self:setRequireLevel(staticItem.required_level)
end


function Props:setCurrencyType(type)
  self._currencyType = type
end 

function Props:getCurrencyType()
  return self._currencyType
end 

function Props:setCount(num)
  self._count = num
end 

function Props:getCount()
  return self._count
end 

function Props:setDescStr(str)
  self._descString = str
end 

function Props:getDescStr()
  return self._descString
end 

function Props:setItemType(itemType)
  self._itemType = itemType
end 

function Props:getItemType()
  return self._itemType
end 

function Props:setItemSequence(seq)
  self._itemSeq = seq
end 

function Props:getItemSequence()
  return self._itemSeq
end 

function Props:setSkillExp(exp)
  self._skillExp = exp
end 

function Props:getSkillExp()
  return self._skillExp
end 

function Props:getIsMergedProps()
  if self._isMergedProps == nil then 
    self._isMergedProps = false 

    local itemType = self:getItemType()
    local grade = self:getGrade()

    if itemType == iType_CardChip or itemType == iType_EquipChip 
      or (itemType==iType_HunShi and grade<5) or (itemType==iType_JunLingZhuang and grade<5)
      or (itemType==iType_SkillBook and grade<5) or (itemType==iType_XuanTie and grade<5) then 
      self._isMergedProps = true
    end
  end

  return self._isMergedProps
end


--just for merged chip props sort
function Props:setChipCanCombined(flag)
  self._canCombined = flag
end

function Props:getChipCanCombined()
  if self._canCombined == nil then
    self._canCombined = false
  end

  return self._canCombined
end

function Props:setQuality(qualityLevel)
  self._quality = qualityLevel
end 

function Props:getQuality()
  return self._quality
end 

function Props:setRequireLevel(level)
  self._requireLevel = level
end 

function Props:getRequireLevel()
  return self._requireLevel
end 

function Props:setSaleFlag(flag)
  self._saleFlag = flag
end 

function Props:getSaleFlag()
  return self._saleFlag
end 

function Props:setSelectedCount(count) 
  self._selectedCount = count 
end 

function Props:getSelectedCount() 
  if self._selectedCount == nil or self._selectedCount < 0 then 
    self._selectedCount = 0 
  end 

  return self._selectedCount 
end 

function Props:setRefinedPrice(price)
  self._refinedPrice = price  
end 

function Props:getRefinedPrice()
  return self._refinedPrice or 0 
end 

function Props:setRefinedGainType(currencyType)
  self._gainedCurrencyType = currencyType 
end 

function Props:getRefinedGainType()
  return self._gainedCurrencyType 
end 

function Props:setRefinedGain(val)
  self._refinedGain = val  
end 

function Props:getRefinedGain()
  return self._refinedGain or 0 
end 


return Props
