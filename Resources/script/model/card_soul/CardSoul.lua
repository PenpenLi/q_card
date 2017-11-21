

CardSoul = class("CardSoul")

CardSoulMenu = enum({"NONE","SHOP","REFINE_CARD", "REFINE_CARD_CHIP", "CARD_REBORN"})
ChipGrade = enum({"NODE", "GRADE_1", "GRADE_2", "GRADE_3", "GRADE_4", "GRADE_5", "GRADE_ALL"})

CardSoul._instance = nil

function CardSoul:ctor()

end

function CardSoul:instance()
  if CardSoul._instance == nil then 
    CardSoul._instance = CardSoul.new()
  end 

  return CardSoul._instance
end 

function CardSoul:init()
  echo("---CardSoul:enter---")
end

function CardSoul:exit()
  echo("---CardSoul:exit---")
  CardSoul._instance = nil
end

function CardSoul:setRefinedCards(cardsArray)
  self._refinedCards = cardsArray
end 

function CardSoul:getRefinedCards()
  if self._refinedCards == nil then 
    self._refinedCards = {}
  end
  return self._refinedCards
end 

function CardSoul:setRefinedChips(chipsArray)
  self._refinedChips = chipsArray
end 

function CardSoul:getRefinedChips()
  if self._refinedChips == nil then 
    self._refinedChips = {}
  end
  return self._refinedChips
end 

function CardSoul:setRebornCards(cardsArray)
  self._rebornCards = cardsArray
end 

function CardSoul:getRebornCards()
  return self._rebornCards
end 

function CardSoul:getCardsForRefinedList()
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

function CardSoul:getCardsForRebornList()
  local info = Bable:instance():getBableInfo()
  local allCards = GameData:Instance():getCurrentPackage():getAllCards()
  local tbl = {}
  if allCards ~= nil then 
    for k, v in pairs(allCards) do 
      -- if (v:getIsOnBattle() == false) and (v:getCradIsWorkState() == false) and v:getCanDismantled() then
      if v:getCanDismantled() then 
        if v:getIsExpCard() == false and (info and info.helper_card_id ~= v:getId()) then --经验卡或助阵卡不允许熔炼
          table.insert(tbl, v)
        end
      end
    end
  end
  
  return tbl
end 

function CardSoul:getChipsForRefinedList(grade)
  local chipsArray = {}
  local allProps = GameData:Instance():getCurrentPackage():getPropsArray()
  local chipGrade = grade or ChipGrade.GRADE_ALL

  for k, v in pairs(allProps) do 

    if v:getItemType() == 3 then 
      if chipGrade == ChipGrade.GRADE_1 and v:getMaxGrade() == 1 then 
        table.insert(chipsArray, v)
      elseif chipGrade == ChipGrade.GRADE_2 and v:getMaxGrade() == 2 then 
        table.insert(chipsArray, v)
      elseif chipGrade == ChipGrade.GRADE_3 and v:getMaxGrade() == 3 then 
        table.insert(chipsArray, v)
      elseif chipGrade == ChipGrade.GRADE_4 and v:getMaxGrade() == 4 then 
        table.insert(chipsArray, v)
      elseif chipGrade == ChipGrade.GRADE_5 and v:getMaxGrade() == 5 then 
        table.insert(chipsArray, v)
      elseif chipGrade == ChipGrade.GRADE_ALL then 
        table.insert(chipsArray, v) 
      end
    end
  end
  
  return chipsArray
end 

function CardSoul:resetCardRefineData()
  local sourceCards = CardSoul:instance():getCardsForRefinedList()
  for k, v in pairs(sourceCards) do 
    v.isSelected = false  
  end 
  CardSoul:instance():setRefinedCards({})
end 

function CardSoul:resetChipRefineData()
  self:setRefinedChips({})
  local dataArray = CardSoul:instance():getChipsForRefinedList(ChipGrade.GRADE_ALL)
  for k, v in pairs(dataArray) do 
    v:setSelectedCount(0)
  end 
end 

function CardSoul:resetCardRebornData()
  local sourceCards = CardSoul:instance():getCardsForRebornList()
  for k, v in pairs(sourceCards) do 
    v.isSelected = false 
  end 
  CardSoul:instance():setRebornCards({}) 
end 

function CardSoul:getCardRebornMaterials(card)
  local tbl = {}
  if card == nil then 
    return tbl
  end 

  local configId = card:getConfigId()
  local dropItem, dropData
  local array = AllConfig.unit[configId].dismantle_data
  local level = GameData:Instance():getCurrentPlayer():getLevel()

  for i=1, table.getn(array) do
    dropItem = AllConfig.drop[array[i]]
    if level >= dropItem.min_level and level <= dropItem.max_level then 
      for k,v in pairs(dropItem.drop_data) do 
        dropData = v.array
        table.insert(tbl, {dropData[1], dropData[2], dropItem.drop_count*dropData[3]})
      end
    end 
  end

  --extra card chips
  local chips = AllConfig.unit[configId].card_puzzle_drop 
  if #chips > 0 then 
    table.insert(tbl, chips)
  end 

  --level drop
  local level = card:getLevel()
  array = AllConfig.cardlevelupexp[level].drop 
  for i=1, table.getn(array) do
    dropItem = AllConfig.drop[array[i]]
    if level >= dropItem.min_level and level <= dropItem.max_level then 
      for k, v in pairs(dropItem.drop_data) do 
        dropData = v.array
        table.insert(tbl, {dropData[1], dropData[2], dropItem.drop_count*dropData[3]})
      end
    end 
  end  

  --skill drop 
  if card:getSkill() then 
    array = AllConfig.skillexp[card:getSkill():getLevel()].drop 
    for i=1, table.getn(array) do
      dropItem = AllConfig.drop[array[i]]
      if level >= dropItem.min_level and level <= dropItem.max_level then 
        for k, v in pairs(dropItem.drop_data) do 
          dropData = v.array
          table.insert(tbl, {dropData[1], dropData[2], dropItem.drop_count*dropData[3]})
        end
      end 
    end 
  end 
  
  return tbl 
end 

-- function CardSoul:getShopListData()
--  local tbl = {}

--  local salesArray = GameData:Instance():getCurrentPackage():getSoulMarketSales()
--  for k, v in pairs(salesArray) do 
--    local item = {cellId=v:getId(), configId=v:getConfigId(), price=v:getDiscountPrice(), perCount=v:getItemCount()}
--    table.insert(tbl, item)
--  end 

--  return tbl 
-- end 

function CardSoul:handleRefineResult(action,msgId,msg)

  if msg.result == "Success" then 
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)

  elseif msg.result == "NoSuchCardInBackupGroup" then 
    Toast:showString(self, _tr("no such card"), ccp(display.cx, display.cy))

  elseif msg.result == "NoSuchItemInItemBag" then 
    Toast:showString(self, string._tran(Consts.Strings.SOUL_NO_SUCH_CHIP), ccp(display.cx, cy))

  elseif msg.result == "WorkInMine" then 
    Toast:showString(self, string._tran(Consts.Strings.SOUL_CANNOT_REFINE_WORKING_CARD), ccp(display.cx, cy))

  elseif msg.result == "NotEnoughCurrency" then 
    Toast:showString(self, _tr("not enough coin"), ccp(display.cx, display.cy))

  else
    Toast:showString(self, _tr("system error"), ccp(display.cx, display.cy))
  end 
end 
