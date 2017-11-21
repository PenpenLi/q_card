PlayStates = class("PlayStates")

function PlayStates:ctor()
	--net.registMsgCallback(PbMsgId.GoIntoBattleResult,self,PlayStates.goIntoBattleResult)
	--net.registMsgCallback(PbMsgId.GoDownFromBattleResult,self,PlayStates.goDownFromBattleResult)
	--net.registMsgCallback(PbMsgId.AssembleEquipmentToCardResult,self,PlayStates.assembleEquipmentToCardResult)
	net.registMsgCallback(PbMsgId.ResetMasterCardResult,self,PlayStates.resetMasterCardResult)
	--net.registMsgCallback(PbMsgId.RemoveEquipmentFromCardResult,self,PlayStates.removeEquipmentFromCardResult)
	net.registMsgCallback(PbMsgId.QuickExchangeCardResult,self,PlayStates.quickExchangeCardResult)
	--net.registMsgCallback(PbMsgId.ChangeCardEquipmentResultS2C,self,PlayStates.onChangeCardEquipmentResultS2C)
	self._isRemoveEquipmentFirst = false
	self:setIsChangeType(false)
	self:setPreViewTabType(1)
end

--    set a card to show now
function PlayStates:setCurrentShowCard(card)
  self._currentShowCard = card
  if self._currentShowCard ~= nil then
      local _,isOnBattle = self._currentShowCard:getIsOnBattle()
      local battleCards =  {}
      
      if isOnBattle == true then
         battleCards = self:getBattleCards()
      else
         battleCards = GameData:Instance():getCurrentPackage():getIdleCards()
      end
      
      local idx = 0
      for key, battleCard in pairs(battleCards) do
      	  if battleCard:getId() == self._currentShowCard:getId() then
      	     self._currentShowCardIdx = idx
      	     break
      	  end
      	  idx = idx + 1
      end 
  else
      self._currentShowCardIdx = -1
  end

-- if no card on battle, set an index card on battle 
--  local battleCards =  GameData:Instance():getCurrentPackage():getBattleCards()
--  local allCards = GameData:Instance():getCurrentPackage():getAllCards()
--  
--  if table.getn(battleCards) <= 0 then
--      if self._currentShowCard ~= nil then
--        self:goIntoBattle(0)
--      end
--  end

end

------
--  Getter & Setter for
--      PlayStates._IsChangeType 
-----
function PlayStates:setIsChangeType(IsChangeType)
	self._IsChangeType = IsChangeType
end

function PlayStates:getIsChangeType()
	return self._IsChangeType
end

function PlayStates:getBattleCards()
  --local battleCards =  GameData:Instance():getCurrentPackage():getBattleCardsByPlaystagesPos()
  
  local battleCards =  GameData:Instance():getCurrentPackage():getBattleCards()
  return battleCards
end

------
--  Getter & Setter for
--      PlayStates._PreViewTabType 
-----
function PlayStates:setPreViewTabType(PreViewTabType)
	self._PreViewTabType = PreViewTabType
end

function PlayStates:getPreViewTabType()
	return self._PreViewTabType
end

function PlayStates:getCurrentShowCard()
  return self._currentShowCard
end

function PlayStates:setCurrentShowCardByIdx(currentShowCardIdx,isOnBattleStates)
    self._currentShowCardIdx = currentShowCardIdx
    if isOnBattleStates == nil then
       isOnBattleStates = true
    end
    local battleCards = {}
    if isOnBattleStates == true then
      battleCards = self:getBattleCards()
      if self._currentShowCardIdx + 1 > table.getn(battleCards) then
          self._currentShowCardIdx = -1
      end
    else
      battleCards =  GameData:Instance():getCurrentPackage():getIdleCards()
    end
    self:setCurrentShowCard(battleCards[self._currentShowCardIdx+1])
end

function PlayStates:getCurrentShowCardIdx()
    return self._currentShowCardIdx
end


function PlayStates:getCurrentCost()
  local battleCards = self:getBattleCards()
  local battleCardsLength = table.getn(battleCards)
  local cost = 0
  for i = 1,battleCardsLength do
      cost = cost + battleCards[i]:getLeadCost()
  end
  
	return cost
end

function PlayStates:getListDataByListType(listType,isAddCard)
	 --get list data
   local mArray = {}
   local package = GameData:Instance():getCurrentPackage()
   if listType == SelectListType.CARD then
      local idleArr= package:getIdleCards()
      package:sortCards(idleArr,SortType.LEVEL_DOWN, SortType.RARE_UP, nil, false)
      for key, mcard in pairs(idleArr) do
        if mcard:getIsExpCard() == false then
      	   table.insert(mArray,mcard)
      	end
      end
      
      if isAddCard == false then
          if  self._currentShowCard ~= nil then  --add the selected card  -- on change card
           table.insert(mArray,self:getCurrentShowCard())
          end
      end
   elseif listType == SelectListType.WEAPON then
      mArray = package:getAllWeapons()
   elseif listType == SelectListType.ACCESSORY then
      mArray = package:getAllAccessories()
   elseif listType == SelectListType.ARMOR then
      mArray = package:getAllArmors()
   else
   end
   
   local function sortEquipmentTable(a, b)
       if a:hasCard()== false and b:hasCard()== true then
          return false
       elseif a:hasCard()== true and b:hasCard()== false then
          return true
       else
          return a:getId() > b:getId()
       end
    end
        
   if listType == SelectListType.WEAPON or listType == SelectListType.ACCESSORY or listType == SelectListType.ARMOR  then
      -- table.sort(mArray, sortEquipmentTable)
      local rootId = nil 
      local card = self:getCurrentShowCard()
      if card ~= nil then         
        rootId = AllConfig.unit[card:getConfigId()].active_equipment
      end 
      GameData:Instance():getCurrentPackage():sortEquipments(mArray, true, rootId, true)      
   end
  
   return mArray
end

function PlayStates:setPlayStatesView(view)
  self._view = view
end

function PlayStates:getPlayStatesView()
  return self._view
end

function PlayStates:destroy()
  net.unregistAllCallback(self)
  self:setPlayStatesView(nil)
end

-- goIntoBattle
function PlayStates:goIntoBattle(position,card)
  self._goIntoBattleCard = card
  self._goIntoBattlePosition = position
--  local data = PbRegist.pack(PbMsgId.GoIntoBattle,{ backup_card_id = self._goIntoBattleCard:getId(), position_in_active_group = 0 })
--  net.sendMessage(PbMsgId.GoIntoBattle,data)
  
  local data = PbRegist.pack(PbMsgId.QuickExchangeCard,{ op_type = "GoIntoBattle",backup_card_id = self._goIntoBattleCard:getId(),pos_or_cardid = self._goIntoBattlePosition})
  net.sendMessage(PbMsgId.QuickExchangeCard,data)
end

--function PlayStates:goIntoBattleResult(action,msgId,msg)
--  printf("goIntoBattleResult:"..msg.state)
--  if  msg.state == "Ok" then
--    self._goIntoBattleCard:setIsOnBattle(true)
--    self._goIntoBattleCard:setPlayStagesPosition(self._goIntoBattlePosition)
--    self:setCurrentShowCard(self._goIntoBattleCard)
--    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
--  end
--  
--  if self:getPlayStatesView() ~= nil then
--    self:getPlayStatesView():goIntoBattleResult(msg.state)
--  end
--end

-- goDownFromBattle
function PlayStates:goDownFromBattle(card)
  self._cardToGoDownFromBattle = card
  if self._cardToGoDownFromBattle == nil then
    echo("card to godown from battle is nil")
    return
  end 
--  local data = PbRegist.pack(PbMsgId.GoDownFromBattle,{active_card_id = self._cardToGoDownFromBattle:getId()})
--  net.sendMessage(PbMsgId.GoDownFromBattle,data)

  --[[
    message QuickExchangeCard {
    enum traits { value = 2561;}
    enum Optype{
     GoIntoBattle = 1;
     GoDownBattle = 2;
     Exchange = 3;
    }
    
    required int32 pos_or_cardid = 1;
    required int32 backup_card_id = 2;
    required Optype op_type = 3;
  }
  ]]
  
  local data = PbRegist.pack(PbMsgId.QuickExchangeCard,{ op_type = "GoDownBattle", pos_or_cardid = self._cardToGoDownFromBattle:getId(),backup_card_id = 0})
  net.sendMessage(PbMsgId.QuickExchangeCard,data)
  
end

--function PlayStates:goDownFromBattleResult(action,msgId,msg)
--  printf("goDownFromBattleResult:"..msg.state)
--  
--  if msg.state =="Ok" then
--    if self._cardToGoDownFromBattle ~= nil then
----      if self._cardToGoDownFromBattle:getWeapon() ~= nil then
----         self._cardToGoDownFromBattle:getWeapon():setCard(nil)
----      end
----      
----      if self._cardToGoDownFromBattle:getArmor() ~= nil then
----         self._cardToGoDownFromBattle:getArmor():setCard(nil)
----      end
----      if self._cardToGoDownFromBattle:getAccessory() ~= nil then
----         self._cardToGoDownFromBattle:getAccessory():setCard(nil)
----      end
--      --self._cardToGoDownFromBattle:setWeapon(nil)
--      --self._cardToGoDownFromBattle:setArmor(nil)
--      --self._cardToGoDownFromBattle:setAccessory(nil)
--      self._cardToGoDownFromBattle:setIsOnBattle(false)
--    end
--     --self:setCurrentShowCard(nil)  -- or reset an index showCard 
--     self:setCurrentShowCardByIdx(0) -- or reset an index showCard 
--     GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
--  end
--  
--  if self:getPlayStatesView() ~= nil then
--     self:getPlayStatesView():goDownFromBattleResult(msg.state)
--  end
-- 
--end


--assembleEquipmentToCard
--function PlayStates:assembleEquipmentToCard(equipment)
--  self._currentEquipment = equipment
--  if self._currentEquipment == nil then
--    return
--  end
--  
--  if self._currentEquipment:getCard() ~= nil then
--     self._isRemoveEquipmentFirst = true
--     self:removeEquipmentFromCard(self._currentEquipment)
--     return
--  end
--  
--  self._isRemoveEquipmentFirst = false
--  
--  local data = PbRegist.pack(PbMsgId.AssembleEquipmentToCard,{card_id = self:getCurrentShowCard():getId(),equipment_id = equipment:getId()})
--  net.sendMessage(PbMsgId.AssembleEquipmentToCard,data)
--end

--function PlayStates:assembleEquipmentToCardResult(action,msgId,msg)
--
--    local equipmentType = self._currentEquipment:getEquipType()
--    if msg.state == "Ok" then
--      if equipmentType == 1 then
--         if self._currentShowCard:getWeapon() ~= nil then
--            self._currentShowCard:getWeapon():setCard(nil)
--         end
--         self._currentShowCard:setWeapon(self._currentEquipment)
--      elseif equipmentType == 3 then
--         if self._currentShowCard:getAccessory() ~= nil then
--            self._currentShowCard:getAccessory():setCard(nil)
--         end
--         self._currentShowCard:setAccessory(self._currentEquipment)
--      elseif equipmentType == 2 then
--         if self._currentShowCard:getArmor() ~= nil then
--            self._currentShowCard:getArmor():setCard(nil)
--         end
--         self._currentShowCard:setArmor(self._currentEquipment)
--      end
--      echo("assembleEquipmentToCard success!")
--    end
--  
--    if self:getPlayStatesView() ~= nil then
--      self:getPlayStatesView():assembleEquipmentToCardResult(msg.state)
--    end
--end

--RemoveEquipmentFromCard
--function PlayStates:removeEquipmentFromCard(equip)
--  self._currentEquipment = equip
--  echo("remove Equipment Id:",equip:getId(),equip:getCard():getId())
--  local data = PbRegist.pack(PbMsgId.RemoveEquipmentFromCard,{ equipment_id = equip:getId() })
--  net.sendMessage(PbMsgId.RemoveEquipmentFromCard,data)
--end

function PlayStates:changeCardEquipmentC2S(dressOrUnDress,equipmentId)
  assert((dressOrUnDress == "Dress" or dressOrUnDress == "UnDress"))
  --local data = PbRegist.pack(PbMsgId.ChangeCardEquipmentC2S,{ action = dressOrUnDress,card_id = self:getCurrentShowCard():getId(),equipment_id = equipmentId  })
  --net.sendMessage(PbMsgId.ChangeCardEquipmentC2S,data)

end

function PlayStates:onChangeCardEquipmentResultS2C(action,msgId,msg)
--  enum ErrorCode{
--    NO_ERROR_CODE = 1;
--    NOT_FOUND_EQUIPMENT = 2;
--    NOT_FOUND_CARD = 3;
--    CARD_NOT_HAVE_EQUIPMENT = 5;
--    CARD_IS_DRESS_EQUIPMENT = 6;
--    SYSTEM_ERROR = 4;
--  }
--  required ErrorCode error = 1;
--  optional ClientSync client_sync = 2;
--  if msg.error == "NO_ERROR_CODE" then
--     GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
--  elseif msg.error == "CARD_IS_DRESS_EQUIPMENT" then
--    Toast:showString(GameData:Instance():getCurrentScene(),_tr("card_has_dress_equip"), ccp(display.cx, display.height*0.4))
--  else
--    print("Error Code:",msg.error)
--    Toast:showString(GameData:Instance():getCurrentScene(),_tr("equip_dress_fail"), ccp(display.cx, display.height*0.4))
--  end
--  
--  self:getPlayStatesView():onChangeCardEquipmentResult()

  
end


--function PlayStates:removeEquipmentFromCardResult(action,msgId,msg)
--  printf("removeEquipmentFromCardResult():"..msg.state)
--  
--  if msg.state == "Ok" then 
--    
--    local card = nil
--    if  self._isRemoveEquipmentFirst == false then
--       card = self._currentShowCard
--       echo("card = [self._currentShowCard]")
--    else
--       card = self._currentEquipment:getCard()
--        echo("card = [self._currentEquipment:getCard()]")
--    end
--        
--    local equipmentType = self._currentEquipment:getEquipType()
--    if equipmentType == 1 then
--       if card:getWeapon() ~= nil then
--          card:getWeapon():setCard(nil)
--       end
--       card:setWeapon(nil)
--    elseif equipmentType == 3 then
--       if card:getAccessory() ~= nil then
--          card:getAccessory():setCard(nil)
--       end
--       card:setAccessory(nil)
--    elseif equipmentType == 2 then
--       if card:getArmor() ~= nil then
--          card:getArmor():setCard(nil)
--       end
--       card:setArmor(nil)
--    end
--    self._currentEquipment:setCard(nil)
--  end
--  
--  if self._isRemoveEquipmentFirst == false then
--    if self:getPlayStatesView() ~= nil then
--      self:getPlayStatesView():removeEquipmentFromCardResult(msg.state)
--    end
--  else
--      self._isRemoveEquipmentFirst = false
--      self:assembleEquipmentToCard(self._currentEquipment)
--  end
--  
--end

--resetMasterCard
function PlayStates:resetMasterCard()
  local data = PbRegist.pack(PbMsgId.ResetMasterCard,{card_id = self._currentShowCard:getId()})
  net.sendMessage(PbMsgId.ResetMasterCard,data)
end

function PlayStates:resetMasterCardResult(action,msgId,msg)
  printf("resetMasterCardResult:"..msg.state)
  
--  local battleCardsArray = self:getBattleCards()
--  local length = table.getn(battleCardsArray)
--  for i = length,1,-1 do
--     battleCardsArray[i]:setIsBoss(false)
--  end
--  self._currentShowCard:setIsBoss(true)

  --[[message ResetMasterCardResult {
  enum traits { value = 1082;}
  enum State {
    Ok = 0;
    NotValidActiveCard = 1;
  }
  required State state = 1;
  optional ClientSync   client = 2; 
  }]]
  
  if msg.state == "Ok" then
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)
  end
  
  if self:getPlayStatesView() ~= nil then
    self:getPlayStatesView():resetMasterCardResult()
  end
end



--QuickExchangeCard
function PlayStates:quickExchangeCard(targetCard)
  self._toQuickExchangeCard = targetCard
  if self._toQuickExchangeCard == nil then 
    return 
  end
  
   --[[
    message QuickExchangeCard {
    enum traits { value = 2561;}
    enum Optype{
     GoIntoBattle = 1;
     GoDownBattle = 2;
     Exchange = 3;
    }
    
    required int32 pos_or_cardid = 1;
    required int32 backup_card_id = 2;
    required Optype op_type = 3;
  }
  ]]
  
  local data = PbRegist.pack(PbMsgId.QuickExchangeCard,{op_type = "Exchange",  backup_card_id = targetCard:getId(), pos_or_cardid = self._currentShowCard:getId()})
  net.sendMessage(PbMsgId.QuickExchangeCard,data)
end

function PlayStates:quickExchangeCardResult(action,msgId,msg)
  printf("quickExchangeCardResult:"..msg.state)
  if msg.state =="Ok" then
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
    if msg.op_type == "GoIntoBattle" then
       self:setCurrentShowCard(self._goIntoBattleCard)
     elseif msg.op_type == "GoDownBattle" then
       self:setCurrentShowCard(nil)  -- or reset an index showCard 
       self:setCurrentShowCardByIdx(0) -- or reset an index showCard 
     elseif msg.op_type == "Exchange" then
       self:setCurrentShowCard(self._toQuickExchangeCard)  -- or reset an index showCard 
     end
  end
  
  if self:getPlayStatesView() ~= nil then
     if msg.op_type == "GoIntoBattle" then
       self:getPlayStatesView():goIntoBattleResult(msg.state)
     elseif msg.op_type == "GoDownBattle" then
       self:getPlayStatesView():goDownFromBattleResult(msg.state)
     elseif msg.op_type == "Exchange" then
       self:getPlayStatesView():quickExchangeCardResult(msg.state)
     end
  end
  
end


--
----quickExchangeCardResult
--function PlayStates:quickExchangeCardResult(action,msgId,msg)
--  printf("quickExchangeCardResult:"..msg.state)
--  
--  if msg.state =="Ok" then
--        local oldCard = self._currentShowCard
--        local mCard = self._toQuickExchangeCard
--        mCard:setIsBoss(oldCard:getIsBoss())
--        mCard:setIsOnBattle(true) 
----        mCard:setWeapon(oldCard:getWeapon())
----        mCard:setArmor(oldCard:getArmor())
----        mCard:setAccessory(oldCard:getAccessory())
--        mCard:setPlayStagesPosition(oldCard:getPlayStagesPosition())
--        mCard:setPosition(oldCard:getPosition())
--        
--        oldCard:setIsOnBattle(false) 
--        oldCard:setIsBoss(false)
----        oldCard:setWeapon(nil)
----        oldCard:setArmor(nil)
----        oldCard:setAccessory(nil)
--        oldCard:setPlayStagesPosition(0)
--        oldCard:setPosition(0)
--        
--        self:setCurrentShowCard(mCard)
--        GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
--  end
--  
--  if self:getPlayStatesView() ~= nil then
--     self:getPlayStatesView():quickExchangeCardResult(msg.state)
--  end
--end

function PlayStates:setCardBattleAbility(val)
  self._battleAbility = val 
end 

function PlayStates:getCardBattleAbility()
  return self._battleAbility or 0 
end 

function PlayStates:updateAbility(showToast)
  if showToast == nil then
    showToast = true
  end
  local battleCards = GameData:Instance():getCurrentPackage():getBattleCards()
  local curVal = GameData:Instance():getBattleAbilityForCards(battleCards)
  local preVal = self:getCardBattleAbility()
  if showToast == true then
    GameData:Instance():getCurrentPlayer():toastBattleAbility(preVal)
  end
  self:setCardBattleAbility(curVal)
end

------
--  Getter & Setter for
--      PlayStates._ListContentOffset 
-----
function PlayStates:setListContentOffset(ListContentOffset)
	self._ListContentOffset = ListContentOffset
end

function PlayStates:getListContentOffset()
	return self._ListContentOffset
end

return PlayStates