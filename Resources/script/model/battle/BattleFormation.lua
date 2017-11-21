require("model.bable.Bable")
BattleFormation = class("BattleFormation")
BattleFormation.BATTLE_INDEX_NORMAL_1 = "BATTLE_INDEX_NORMAL_1"
BattleFormation.BATTLE_INDEX_NORMAL_2 = "BATTLE_INDEX_NORMAL_2"
BattleFormation.BATTLE_INDEX_NORMAL_3 = "BATTLE_INDEX_NORMAL_3"
BattleFormation.BATTLE_INDEX_PVP = "BATTLE_INDEX_PVP"
BattleFormation.BATTLE_INDEX_RANK_MATCH = "BATTLE_INDEX_RANK_MATCH"
BattleFormation.BATTLE_INDEX_BABLE = "BATTLE_INDEX_BABLE"

function BattleFormation:ctor()
  
end

function BattleFormation:Instance()
  if BattleFormation._BattleFormationInstance == nil then
    BattleFormation._BattleFormationInstance = BattleFormation.new()
    BattleFormation._BattleFormationInstance:init()
  end
  return BattleFormation._BattleFormationInstance
end

function BattleFormation:init()
  self._battleSaveCards = {}
  self._battleSaveCards[BattleFormation.BATTLE_INDEX_NORMAL_1] = {}
  self._battleSaveCards[BattleFormation.BATTLE_INDEX_NORMAL_2] = {}
  self._battleSaveCards[BattleFormation.BATTLE_INDEX_NORMAL_3] = {}
  self._battleSaveCards[BattleFormation.BATTLE_INDEX_PVP] = {}
  self._battleSaveCards[BattleFormation.BATTLE_INDEX_RANK_MATCH] = {}
  self._battleSaveCards[BattleFormation.BATTLE_INDEX_BABLE] = {}
  
  local attackIdxs = {
    BattleFormation.BATTLE_INDEX_NORMAL_1,
    BattleFormation.BATTLE_INDEX_NORMAL_2,
    BattleFormation.BATTLE_INDEX_NORMAL_3
  }
  self:setAttackBattleFormationIdxs(attackIdxs)
  
  local defendIdxs = {
    BattleFormation.BATTLE_INDEX_PVP,
    BattleFormation.BATTLE_INDEX_RANK_MATCH
  }
  self:setDefendBattleFormationIdxs(defendIdxs)
  
  self:registNetSever()
end

function BattleFormation:registNetSever()
  net.registMsgCallback(PbMsgId.SaveBattleFormationResultS2C,self,BattleFormation.onSaveBattleFormationResultS2C)
end

------
--  Getter & Setter for
--      BattleFormation._AttackBattleFormationIdxs 
-----
function BattleFormation:setAttackBattleFormationIdxs(AttackBattleFormationIdxs)
	self._AttackBattleFormationIdxs = AttackBattleFormationIdxs
end

function BattleFormation:getAttackBattleFormationIdxs()
	return self._AttackBattleFormationIdxs
end

------
--  Getter & Setter for
--      BattleFormation._CurrentAttackBattleFormationIdx 
-----
function BattleFormation:setCurrentAttackBattleFormationIdx(CurrentAttackBattleFormationIdx)
  if self:checkBattleFormationIdxIsAttack(CurrentAttackBattleFormationIdx) == true then
  	self._CurrentAttackBattleFormationIdx = CurrentAttackBattleFormationIdx
  	GameData:Instance():getCurrentPackage():sortingCards()
	end
end

function BattleFormation:getCurrentAttackBattleFormationIdx()
  if self._CurrentAttackBattleFormationIdx == nil then
    self._CurrentAttackBattleFormationIdx = self:getAttackBattleFormationIdxs()[1]
  end
	return self._CurrentAttackBattleFormationIdx
end

function BattleFormation:checkBattleFormationIdxIsAttack(battleFormationIdx)
  return BattleFormation.BATTLE_INDEX_NORMAL_1 == battleFormationIdx
  or BattleFormation.BATTLE_INDEX_NORMAL_2 == battleFormationIdx
  or BattleFormation.BATTLE_INDEX_NORMAL_3 == battleFormationIdx
  or BattleFormation.BATTLE_INDEX_BABLE == battleFormationIdx
end

------
--  Getter & Setter for
--      BattleFormation._DefendBattleFormationIdxs 
-----
function BattleFormation:setDefendBattleFormationIdxs(DefendBattleFormationIdxs)
	self._DefendBattleFormationIdxs = DefendBattleFormationIdxs
end

function BattleFormation:getDefendBattleFormationIdxs()
	return self._DefendBattleFormationIdxs
end

function BattleFormation:update(battleSaveCards)
  --[[
  message BattleCard{
  required int32 card = 1;  //卡牌ID
  required int32 pos = 2;   //卡牌位置
  required int32 leader = 3;  //是否主帅
  }

  message BattleFormation{
  enum BattleIndex{
    BATTLE_INDEX_NORMAL_1 = 1;  //普通阵容
    BATTLE_INDEX_NORMAL_2 = 2;  //普通阵容
    BATTLE_INDEX_NORMAL_3 = 3;  //普通阵容
    BATTLE_INDEX_PVP = 4;   //征战防守阵容
    BATTLE_INDEX_RANK_MATCH = 5;//排位赛防守阵容
  }
  repeated BattleCard cards = 1;  //卡牌信息
  required BattleIndex id = 2;  //阵容Id
  }
  
  //卡牌阵容信息
  message BattleSaveCards{
  repeated BattleFormation battle = 1;  //阵容详细信息
  }
  ]]
  
  if battleSaveCards == nil then
    return
  end
  
  for key, battleFormation in pairs(battleSaveCards.battle) do
    print("battleFormation.id:",battleFormation.id)
    self._battleSaveCards[battleFormation.id] = battleFormation.cards
  end

end

function BattleFormation:updateView()
  local view = self:getView()
  if view ~= nil then
    view:updateView()
  end
end

------
--  Getter & Setter for
--      BattleFormation._View 
-----
function BattleFormation:setView(View)
	self._View = View
end

function BattleFormation:getView()
	return self._View
end

--cards in battle formation inedex
function BattleFormation:getBattleFormationCards(battleInformationIdx,ownerType)
  if ownerType == nil then
    ownerType = BattleConfig.CardOwnerTypeAll
  end
  
  local cards = {}
  if battleInformationIdx == BattleFormation.BATTLE_INDEX_BABLE then
    if ownerType == BattleConfig.CardOwnerTypeSelf then
      cards = Bable:instance():getCardsForBattle()
    elseif ownerType == BattleConfig.CardOwnerTypeFriend then
      cards = Bable:instance():getFriendCards()
    elseif ownerType == BattleConfig.CardOwnerTypeAll then
      cards = Bable:instance():getAllCards()
    end 
    for key, card in pairs(cards) do
      card.tempSelected = 0
    end
  else
    local allCards = GameData:Instance():getCurrentPackage():getAllCards()
    for key, card in pairs(allCards) do
      card.tempSelected = 0
      if card:getCradIsWorkState() == false then
       if ownerType == BattleConfig.CardOwnerTypeAll then
         table.insert(cards,card)
       else
         if card:getOwnerType() == ownerType then
           table.insert(cards,card)
         end
       end
      end
    end
  end
  
  local cardsFormation = self:getCardsFormationByBattleIndex(battleInformationIdx)
  --dump(cardsFormation)
  local finalCards = {}
  for key, card in pairs(cards) do
    card:setPos(0)
    for key, battleCardInfo in pairs(cardsFormation) do
      --print(battleCardInfo.card,battleCardInfo.pos,battleCardInfo.leader)
      if battleCardInfo.card == card:getId() then
        card:setPos(battleCardInfo.pos)
        card.tempSelected = 1
        table.insert(finalCards,card)
        break
      end
    end
  end
  
  return finalCards
end


--all cards can select by battle formation index  请注意与 'getBattleFormationCards'接口的区别
function BattleFormation:getCardsByBattleFormationIdx(battleInformationIdx,ownerType)
  if ownerType == nil then
    ownerType = BattleConfig.CardOwnerTypeAll
  end
  
  local cards = {}
  if battleInformationIdx == BattleFormation.BATTLE_INDEX_BABLE then
    if ownerType == BattleConfig.CardOwnerTypeSelf then
      cards = Bable:instance():getCardsForBattle()
    elseif ownerType == BattleConfig.CardOwnerTypeFriend then
      cards = Bable:instance():getFriendCards()
    elseif ownerType == BattleConfig.CardOwnerTypeAll then
      cards = Bable:instance():getAllCards()
    end 
    for key, card in pairs(cards) do
      card.tempSelected = 0
    end
  else
    local allCards = GameData:Instance():getCurrentPackage():getAllCards()
    for key, card in pairs(allCards) do
      card.tempSelected = 0
      if card:getCradIsWorkState() == false then
       if ownerType == BattleConfig.CardOwnerTypeAll then
         table.insert(cards,card)
       else
         if card:getOwnerType() == ownerType then
           table.insert(cards,card)
         end
       end
      end
    end
  end
  
  local cardsFormation = self:getCardsFormationByBattleIndex(battleInformationIdx)
  for key, card in pairs(cards) do
    card:setPos(0)
    for key, battleCardInfo in pairs(cardsFormation) do
      --print(battleCardInfo.card,battleCardInfo.pos,battleCardInfo.leader)
      if battleCardInfo.card == card:getId() then
        card:setPos(battleCardInfo.pos)
        card.tempSelected = 1
        break
      end
    end
  end
  
  return cards
end

function BattleFormation:getAllBattleFormations()
	return self._battleSaveCards
end

function BattleFormation:getCardsFormationByBattleIndex(battleIndex)
  return self._battleSaveCards[battleIndex]
end

function BattleFormation:reqSaveBattleFormationC2S(battleIndex,cards,isSettingLeader,saveResultHandler)
  printf("reqSaveBattleFormationC2S:"..battleIndex)
  dump(cards)
  self._saveResultHandler = saveResultHandler
  self._isSettingLeader = isSettingLeader
  self._saveingCards = cards
  if battleIndex == BattleFormation.BATTLE_INDEX_BABLE then
    self._battleSaveCards[BattleFormation.BATTLE_INDEX_BABLE] = cards
--    local str = "阵容保存成功"
--    Toast:showString(GameData:Instance():getCurrentScene(), str, ccp(display.cx, display.cy))
    if self._saveResultHandler ~= nil then
      self._saveResultHandler()
    end
    return
  end
  
  self._savingBattleIndex = battleIndex
  
  --[[message BattleCard{
  required int32 card = 1;  //卡牌ID
  required int32 pos = 2;   //卡牌位置
  required int32 leader = 3;  //是否主帅
  }
  message BattleFormation{
    enum BattleIndex{
      BATTLE_INDEX_NORMAL_1 = 1;  //普通阵容
      BATTLE_INDEX_NORMAL_2 = 2;  //普通阵容
      BATTLE_INDEX_NORMAL_3 = 3;  //普通阵容
      BATTLE_INDEX_PVP = 4;   //征战防守阵容
      BATTLE_INDEX_RANK_MATCH = 5;//排位赛防守阵容
    }
    repeated BattleCard cards = 1;  //卡牌信息
    required BattleIndex id = 2;  //阵容Id
  }]]
  
  --local battleFormation = {}
  --[[local cards = {}
  for key, battleCard in pairs(battleCards) do
  	local card = {}
  	card.card = battleCard:getId()
  	card.pos = battleCard:getPos()
  	local isLeader = 0
  	if battleCard:getIsPrimary() == true then
  	 isLeader = 1
  	end
  	card.leader = isLeader
  	table.insert(cards,card)
  end]]
  
--  battleFormation.id = battleIndex
--  battleFormation.cards = cards


  --[[message SaveBattleFormationC2S{
  enum traits{value = 5171;}
  required BattleFormation battle = 1; //阵容
  }]]
  if ControllerFactory:Instance():getCurrentControllerType() ~= ControllerType.BATTLE_CONTROLLER then
    _showLoading()
  end
  local battleFormation = {id = battleIndex,cards = cards }
  local data = PbRegist.pack(PbMsgId.SaveBattleFormationC2S,{ battle = battleFormation})
  net.sendMessage(PbMsgId.SaveBattleFormationC2S,data)
end

function BattleFormation:onSaveBattleFormationResultS2C(action,msgId,msg)
  --[[message SaveBattleFormationResultS2C{
  enum traits{value = 5172;}
  enum ErrorCode{
    NO_ERROR_CODE = 1;
    NOT_FOUND_CARD = 2;
    CARD_IN_MINE = 3;
    CARD_POS_ERROR = 4;
    CARD_DATA_ERROR = 5;
    LEADER_DATA_ERROR = 6;
    SYSTEM_ERROR = 99;
  }
  required ErrorCode error = 1;
  optional ClientSync client = 2;
  }]]
  _hideLoading()
  
  if self._savingBattleIndex == BattleFormation.BATTLE_INDEX_NORMAL_1
  or self._savingBattleIndex == BattleFormation.BATTLE_INDEX_NORMAL_2
  or self._savingBattleIndex == BattleFormation.BATTLE_INDEX_NORMAL_3
  then
    self:setCurrentAttackBattleFormationIdx(self._savingBattleIndex)
  end
  
  printf("onSaveBattleFormationResultS2C:"..msg.error)
  local str = ""
  if msg.error == "NO_ERROR_CODE" then
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)
    str = _tr("save_battle_formation_success")
    if self._isSettingLeader == true then
      self._isSettingLeader = ""
    end
    
    self:updateView()
    if self._saveResultHandler ~= nil then
      self._saveResultHandler()
    end
    
    if self._savingBattleIndex == BattleFormation.BATTLE_INDEX_RANK_MATCH then
      self:reqSaveBattleFormationC2S(BattleFormation.BATTLE_INDEX_PVP,self._saveingCards,self._isSettingLeader,nil)
      self._isSyncSaveing = true
    elseif self._savingBattleIndex == BattleFormation.BATTLE_INDEX_PVP then
      self:reqSaveBattleFormationC2S(BattleFormation.BATTLE_INDEX_RANK_MATCH,self._saveingCards,self._isSettingLeader,nil)
      self._isSyncSaveing = true
    end
    
  else
    str = _tr("save_battle_formation_fail").."("..msg.error..")"
  end
  self._savingBattleIndex = nil
  self._saveResultHandler = nil
  self._isSettingLeader = nil
  self._saveingCards = nil
  
  if ControllerFactory:Instance():getCurrentControllerType() ~= ControllerType.BATTLE_CONTROLLER then
    
    if self._isSyncSaveing == true then
      self._isSyncSaveing = false
      return
    end
  
    Toast:showString(GameData:Instance():getCurrentScene(), str, ccp(display.cx, display.cy))
  end
  
  
end


return BattleFormation