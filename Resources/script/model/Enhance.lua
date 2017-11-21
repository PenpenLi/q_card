

Enhance = class("Enhance")


Enhance._instance = nil

function Enhance:ctor()

end

function Enhance:instance()
  if Enhance._instance == nil then 
    Enhance._instance = Enhance.new()
  end 

  return Enhance._instance
end 

function Enhance:init()
  echo("---Enhance:enter---")
  --net.registMsgCallback(PbMsgId.EatCardResult, self, LevelUpView.EatCardResult)
  --net.registMsgCallback(PbMsgId.CardTurnbackResult, self, SurmountView.CardTurnbackResult)
  --net.registMsgCallback(PbMsgId.SmeltCardResult, self, DismantleView.SmeltCardResult)
  --net.registMsgCallback(PbMsgId.UpdateCardSkillExperienceResult, self, SkillUpView.cardSkillUpResult)

  local allCards = GameData:Instance():getCurrentPackage():getAllCards()
  for k,v in pairs(allCards) do 
    v.isSelected = false
  end

  self:setLevelUpCard(nil)
  self:setLevelUpCards(nil)
  self:setSurmountedCard(nil)
  self:setDismantleCards(nil)
  self:setSkillCard(nil)
end

function Enhance:exit()
  echo("---Enhance:exit---")
  --net.unregistAllCallback(self)
  Enhance._instance = nil
end

function Enhance:setLevelUpCard(card)
  self._levelupCard = card
end

function Enhance:getLevelUpCard()
  return self._levelupCard
end

function Enhance:setSurmountedCard(card)
  self._surmountedCard = card
end

function Enhance:getSurmountedCard()
  return self._surmountedCard
end

function Enhance:setSkillCard(card)
  self._skillCard = card
end 

function Enhance:getSkillCard()
  return self._skillCard
end 

function Enhance:setLevelUpCards(cardTbl)
  self._levelupCards = cardTbl
end

function Enhance:getLevelUpCards()
  if self._levelupCards == nil then 
  	self._levelupCards = {}
  end

  return self._levelupCards
end 

function Enhance:setDismantleCards(cardTbl)
  self._dismantleCards = cardTbl
end

function Enhance:getDismantleCards()
  if self._dismantleCards == nil then 
    self._dismantleCards = {}
  end

  return self._dismantleCards
end 






function Enhance:getCardForLevelUp()
  self.sourceSkillCards = {}

  local allCards = GameData:Instance():getCurrentPackage():getAllCards()
  for k,v in pairs(allCards) do 
    if v:getLevel() < v:getMaxLevel() then 
      table.insert(self.sourceSkillCards, v)
    end
  end

  return self.sourceSkillCards
end

function Enhance:getCardToEatForLevelUp()
  local tbl = {}
  
  local skillupCard = self:getLevelUpCard()
  if skillupCard ~= nil then 
    tbl = GameData:Instance():getCurrentPackage():getIdleCardsExt(skillupCard:getId())
  end
  echo("getCardToEatForLevelUp: len=", #tbl)
  return tbl
end 

function Enhance:getCardForSurmount()
  self.sourceSurmount = {}
  echo("Enhance:getCardForSurmount()")
  local allCards = GameData:Instance():getCurrentPackage():getAllCards()
  for k,v in pairs(allCards) do 
    if v:getGrade() < v:getMaxGrade() then
      local _, _, flag = self:getSurmountInfoByCard(v)
      if flag ~= nil then 
        v:setSurmountFlag(flag)
        v.isSelected = false
        table.insert(self.sourceSurmount, v)
      end
    else
      echo("max grade card cannot be surmount:", v:getId(), v:getConfigId())
    end
  end

  return self.sourceSurmount
end 

function Enhance:getCardForDismantle()
  local allCards = GameData:Instance():getCurrentPackage():getAllCards()
  local tbl = {}
  if allCards ~= nil then 
    for k, v in pairs(allCards) do 
      if (v:getIsOnBattle() == false) and (v:getCradIsWorkState() == false) then
        if v:getIsExpCard() == false then 
          table.insert(tbl, v)
        end
      end
    end
  end
  
  return tbl
end 

function Enhance:getCardsForSkillUp()
  local skillCars = {}

  local allCards = GameData:Instance():getCurrentPackage():getAllCards()
  for k,v in pairs(allCards) do 
    local skill = v:getSkill()
    if skill ~= nil then 
      -- echo("---skill card:", v:getConfigId(), skill:getLevel(), skill:getMaxLevel())
      if skill:getLevel() < skill:getMaxLevel() then 
        v.isSelected = false
        table.insert(skillCars, v)
      end
    end
  end

  return skillCars
end

function Enhance:resetSelectedCards()
  local allCards = GameData:Instance():getCurrentPackage():getAllCards()
  for k,v in pairs(allCards) do 
    v.isSelected = false
  end  
end


--return 1: can be surmounted, 2: level not enough, 3:not enough metarial, 
function Enhance:getSurmountInfoByCard(card)

  --1. level condition
  -- if card:getLevel() < card:getMaxLevel() then 
  --   return _tr("poor level"), sgRED, 2
  -- end

  --2. metarial condition
  local combineSummary = AllConfig.combinesummary[card:getConfigId()]
  if combineSummary == nil then 
    echo("invalid combineSummary !!")
    return ""
  end 

  --echo("--configid=", card:getConfigId())
  
  local canSurmounted = true 
  local sysId = card:getId()
  local dataItem
  for k, v in pairs(combineSummary.consume) do 
    dataItem = v.array
    if dataItem[1] ~= 4 then 
      local _, ownNum = self:getIconNumByType(dataItem[1], dataItem[2], sysId)
      if ownNum < dataItem[3] then 
        canSurmounted = false 
        break 
      end 
    end 
  end 

  if canSurmounted == false then 
    return _tr("not enough material"), sgRED, 3
  end
  
  --3. ok
  return _tr("can surmount"), ccc3(136,230,0), 1
end 

function Enhance:isCardCanSurmounted(card)
  if GameData:Instance():checkSystemOpenCondition(10, false) == false then 
    return false 
  end 
  
  local canSurmounted = false 
  if card ~= nil then 
    if card:getGrade() < card:getMaxGrade() then
      local _, _, flag = self:getSurmountInfoByCard(card)
      if flag == 1 then 
        canSurmounted = true 
      end 
    end 
  end 
  
  return canSurmounted
end 

function Enhance:getDropItemsName(card)

  if card == nil then 
    return "", ccc3(136,230,0)
  end

  local dropInfo = card:getDismantleInfo()

  local name = _tr("will get")
  for i = 1, table.getn(dropInfo) do 
    if i <= 1 then 
      name = name .. dropInfo[i].name
    else 
      if dropInfo[i].name ~= nil then 
        name = name.."、"
        name = name .. dropInfo[i].name
      end
    end 
  end

  return name, ccc3(136,230,0)
end

function Enhance:getTotalDismantleCost(cardTbl)
  if cardTbl == nil then 
    return 0
  end
  
  local money = 0
  for k,v in pairs(cardTbl) do 
    money = money + AllConfig.unit[v:getConfigId()].dismantle_cost
  end

  return money
end

function Enhance:getDismantleMaterials(cardTbl)
  local tmpTable = {}
  local num  = 0 

  if cardTbl == nil then 
    return tmpTable
  end

  for k, v in pairs(cardTbl) do 
    local dropInfo = v:getDismantleInfo()
    for i = 1, table.getn(dropInfo) do 
      if tmpTable[dropInfo[i].configId] == nil then  -- new one
        tmpTable[dropInfo[i].configId] = {}
        tmpTable[dropInfo[i].configId].itype = dropInfo[i].itype        
        tmpTable[dropInfo[i].configId].count = dropInfo[i].count
        tmpTable[dropInfo[i].configId].rate = dropInfo[i].rate
        tmpTable[dropInfo[i].configId].configId = dropInfo[i].configId
       
        num = num + 1
      else 
        tmpTable[dropInfo[i].configId].count = tmpTable[dropInfo[i].configId].count + dropInfo[i].count
      end
    end
  end

  return tmpTable, num
end

function Enhance:getDismantleCardIdArray()

  local hasBigGradeCard = false
  local array = self:getDismantleCards()
  local tmpTable = {}
  for k, v in pairs(array) do 
    table.insert(tmpTable, v:getId())
    if v:getMaxGrade() >= 3 then 
      hasBigGradeCard = true
    end
  end

  return tmpTable,hasBigGradeCard
end

function Enhance:getIconNumByType(iType, configId, sysId)
  local package = GameData:Instance():getCurrentPackage()
  local iconId = nil
  local num = 0
  local id = nil 
  local iconBgId = nil 


  if iType == 6 then --props
    local array = package:getPropsArray()
    for i=1, table.getn(array) do 
      if array[i]:getConfigId() == configId then 
        num = array[i]:getCount()
        id = array[i]:getId()
        break
      end
    end
    iconId = AllConfig.item[configId].item_resource
  elseif iType == 8 then --cards
    local array = package:getIdleCardsExt(sysId) -- getAllCards()
    for i=1, table.getn(array) do 
      if array[i]:getConfigId() == configId then 

        num = num + 1
        id = array[i]:getId()
        iconBgId = 3022021 + array[i]:getGrade() - 1  --card icon background
      end
    end
    iconId = AllConfig.unit[configId].unit_head_pic
  end

  return iconId, num, id, iconBgId
end

function Enhance:getExpCardsForEaten(needExp)
  local package = GameData:Instance():getCurrentPackage()
  local allCards = package:getAllCards()
  local expCardsArray = package:getExpCards(allCards)
  
  --sort cards by exp value 
  if expCardsArray ~= nil then 
    local endIdx = #expCardsArray
    for i=1, endIdx-1 do 
      local k = i 
      for j=i+1, endIdx do 
        if expCardsArray[k]:getGainedExpAfterEaten() > expCardsArray[j]:getGainedExpAfterEaten() then 
          k = j
        end
      end  

      if k > i then 
        local tmp = expCardsArray[k]
        expCardsArray[k] = expCardsArray[i]
        expCardsArray[i] = tmp 
      end
    end
  end 
  
  local resultArray = {}
  local gained = 0 
  for i=1, #expCardsArray do 
    gained = gained + expCardsArray[i]:getGainedExpAfterEaten()
    expCardsArray[i].isSelected = true 
    table.insert(resultArray, expCardsArray[i])
    if gained >= needExp then 
      break 
    end 
  end 

  return resultArray
end 

function Enhance:getAllExpCards(isBuy)
  
  local id1 = AllConfig.shop[1].item  --1星士兵卡包
  local id2 = AllConfig.shop[2].item  --士兵卡包
  local id3 = AllConfig.shop[3].item  --校慰卡包
  local tbl = {}

  local package = GameData:Instance():getCurrentPackage()

  if isBuy == true then 
    --这里暂时用系统id保存这些其对应商城里的cellid
    local sysId1 = 1
    local sysId2 = 1
    local sysId3 = 1
    local shopData = package:getCollectSales()
    for k, v in pairs(shopData) do 
      if v:getConfigId() == id1 then 
        sysId1 = v:getId()
      elseif v:getConfigId() == id2 then 
        sysId2 = v:getId()
      elseif v:getConfigId() == id3 then 
        sysId3 = v:getId()
      end 
    end 
    echo("=== sys id:", sysId1, sysId2, sysId3)
    local item1 = Props.new(sysId1, id1, 1)
    local item2 = Props.new(sysId2, id2, 1)
    local item3 = Props.new(sysId3, id3, 1)
    tbl = {item1, item2, item3}
  else 
    local allProps = package:getPropsArray()
    for k, v in pairs(allProps) do 
      local configId = v:getConfigId()
      if (configId >= id1 and configId <= id1+4) or configId == id2 or configId == id3 then 
        table.insert(tbl, v)
      end 
    end 
  end 

  --sort 
  package:sortItems(tbl, 1, #tbl, SortType.RARE_UP)

  return tbl 
end 

function Enhance:getMaterialSource(configId)
  local flag = math.floor(configId/10000000)
  echo("getMaterialSource: configId, flag =", configId, flag)
  if configId < 100 then --虚拟道具
    flag = 2 
  end 

  local tbl = {}
  local groupdata = nil 
  if flag == 1 then --card
    groupdata = AllConfig.unit[configId].card_droup
  elseif flag == 2 then --item
    groupdata = AllConfig.item[configId].card_drop
  else 
    echo(" invalid source item type")
  end

  if groupdata ~= nil then 
    for k, v in pairs(groupdata) do 
      for m, id in pairs(v.array) do 
        if id > 0 then 
          if k == 1 then 
            table.insert(tbl, {SourceType.CardFromStage, id})
          elseif k == 2 then 
            table.insert(tbl, {SourceType.ChipFromStage, id})
          elseif k == 3 then 
            table.insert(tbl, {SourceType.Lottery, id})
          elseif k == 4 then 
            table.insert(tbl, {SourceType.Charpter, id})
          elseif k == 5 then 
            table.insert(tbl, {SourceType.Arena, id})
          elseif k == 6 then 
            table.insert(tbl, {SourceType.SoulShop, id})
          elseif k == 7 then 
            table.insert(tbl, {SourceType.Expedition, id})
          elseif k == 8 then 
            table.insert(tbl, {SourceType.Gonghui, id})
          elseif k == 9 then 
            table.insert(tbl, {SourceType.JingJiChang, id})
          elseif k == 10 then 
            table.insert(tbl, {SourceType.Bable, id}) 
          elseif k == 11 then 
            table.insert(tbl, {SourceType.VipShop, id})
          elseif k == 12 then 
            table.insert(tbl, {SourceType.TimeAct, id})
          elseif k == 13 then 
            table.insert(tbl, {SourceType.Battle, id})
          elseif k == 14 then 
            table.insert(tbl, {SourceType.SoulRefine, id})                      
          end 
        end 
      end 
    end 
  end 
  
  return tbl
end 

function Enhance:getHasChipForCard(configId)
  local hasChip = false 

  local rootId = AllConfig.unit[configId].unit_root * 100 + 1
  local propsConfigid = nil 
  for k, v in pairs(AllConfig.combinesummary) do 
    if v.target_item == rootId then 
      propsConfigid = v.id 
      break 
    end 
  end 

  if propsConfigid ~= nil then 
    local allprops = GameData:Instance():getCurrentPackage():getPropsArray()
    for k, v in pairs(allprops) do 
      if propsConfigid == v:getConfigId() then 
        hasChip = true 
        break 
      end 
    end 
  end 
  echo("getHasChipForCard:", configId, hasChip)
  return hasChip
end

function Enhance:canSkillUpForCard(cardMode)
  if GameData:Instance():checkSystemOpenCondition(28, false) == false then 
    return false 
  end

  if cardMode and cardMode:getSkill():getLevel() < cardMode:getLevel() and cardMode:getSkill():getLevel() < cardMode:getSkill():getMaxLevel() then 
    local allprops = GameData:Instance():getCurrentPackage():getPropsArray()
    for k, v in pairs(allprops) do 
      if iType_SkillBook == v:getItemType() then 
        return true 
      end 
    end 
  end  
  
  return false 
end 

function Enhance:handleErrorCode(errorCode)
  local curScene = GameData:Instance():getCurrentScene()

  if errorCode == "NoSuchCardId" then
     Toast:showString(curScene, _tr("no such card"), ccp(display.cx, display.cy))
  elseif errorCode == "NoSuchItem" then
     Toast:showString(curScene, _tr("no such book"), ccp(display.cx, display.cy)) 
  elseif errorCode == "SkillCouldNotGrowup" then
     Toast:showString(curScene, _tr("is max skill level"), ccp(display.cx, display.cy))
  elseif errorCode == "NeedMoreItem" then
     Toast:showString(curScene, _tr("not enough books"), ccp(display.cx, display.cy))
  elseif errorCode == "NeedMoreCoin" or errorCode == "NotEnoughCurrency" then
     Toast:showString(curScene, _tr("not enough coin"), ccp(display.cx, display.cy))
  elseif errorCode == "NeedCardLevel" then
    Toast:showString(curScene, _tr("poor level"), ccp(display.cx, display.cy))
  elseif errorCode == "NeedMoreCard" then
    Toast:showString(curScene, _tr("has no eatable cards"), ccp(display.cx, display.cy))
  elseif errorCode == "NoSuchConsumedCard" then
    Toast:showString(curScene, _tr("no_such_consumed_card"), ccp(display.cx, display.cy))
  elseif errorCode == "ConsumedCardIsActive" then
    Toast:showString(curScene, _tr("consumed_card_is_active"), ccp(display.cx, display.cy))
  elseif errorCode == "ConsumedCardInMine" then
    Toast:showString(curScene, _tr("working card can not eaten"), ccp(display.cx, display.cy))
  elseif errorCode == "ConsumedCardIdWrong" then
    Toast:showString(curScene, _tr("wrong_consumed_card"), ccp(display.cx, display.cy))
  elseif errorCode == "NeedMoreBagCell" then
    Toast:showString(curScene, _tr("card bag is full"), ccp(display.cx, display.cy))
  elseif errorCode == "IsActiveCard" then
    Toast:showString(curScene, _tr("battle_card_cannot_dismantled"), ccp(display.cx, display.cy))
  elseif errorCode == "HasEquipmentInCard" then
    Toast:showString(curScene, _tr("equip_card_cannot_dismantled"), ccp(display.cx, display.cy))
  elseif errorCode == "IsMineCard" then
    Toast:showString(curScene, _tr("working_card_cannot_dismanted"), ccp(display.cx, display.cy))

  elseif errorCode == "ErrorExpCard" then
    Toast:showString(curScene, _tr("exp_card_cannot_dismantled"), ccp(display.cx, display.cy))
    
  else
    Toast:showString(curScene, _tr("system error"), ccp(display.cx, display.cy))
  end 
end 