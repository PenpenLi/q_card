
Bable = class("Bable")

function Bable:ctor()
  self:regirsterNetSever()
  self:setHaveUsedDefaultBattleFormation(false)
end 

function Bable:instance()
  if Bable._instance == nil then 
    Bable._instance = Bable.new() 
  end

  return Bable._instance
end

function Bable:regirsterNetSever()
  net.registMsgCallback(PbMsgId.FightErrorBS2CS,self,Bable.onCheckFightResult)
  net.registMsgCallback(PbMsgId.BableSetHelpFriendCountC2B,self,Bable.onBableSetHelpFriendCountUpdate)
  net.registMsgCallback(PbMsgId.BableChoiceFriendCardResultS2C,self,Bable.onBableChoiceFriendCardResultS2C)
  net.registMsgCallback(PbMsgId.BableChangeHelpCard,self,Bable.onBableChangeHelpCard)
end

------
--  Getter & Setter for
--      Bable._HaveUsedDefaultBattleFormation 
-----
function Bable:setHaveUsedDefaultBattleFormation(HaveUsedDefaultBattleFormation)
	self._HaveUsedDefaultBattleFormation = HaveUsedDefaultBattleFormation
end

function Bable:getHaveUsedDefaultBattleFormation()
	return self._HaveUsedDefaultBattleFormation
end

function Bable:onBableChangeHelpCard(action,msgId,msg)
  --[[
   optional FriendHelpSimpleInfo friend_help_info = 1;
   optional int32 friend_id = 2;
   ]]
  local friends = Friend:Instance():getCurrentFriend()
  for key, friend in pairs(friends) do
   if friend:getId() == msg.friend_id then
      friend:setHelpInfo(msg.friend_help_info)
      break
   end
  end
  
  local battleFormationView = self:getBattleFormationView()
  if battleFormationView ~= nil then
    --battleFormationView:buildCardPages(BattleFormation.BATTLE_INDEX_BABLE)
    battleFormationView:updateView(BattleFormation.BATTLE_INDEX_BABLE)
  end
end

------
--  Getter & Setter for
--      Bable._BattleFormationView 
-----
function Bable:setBattleFormationView(BattleFormationView)
	self._BattleFormationView = BattleFormationView
end

function Bable:getBattleFormationView()
	return self._BattleFormationView
end

function Bable:onBableSetHelpFriendCountUpdate(action,msgId,msg)
  --[[
  message BableSetHelpFriendCountC2B{
  enum traits {
    value = 10101;
  }
  optional ClientSync client_sync = 1;
  optional int32 friendId = 2;
  }]]
  GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
end

function Bable:reqBableChoiceFriendCardC2S(friendId,saveResultHandler)
  --[[
    message BableChoiceFriendCardC2S{
  enum traits {
    value = 10085;
  }
  optional int32 friend_id = 1;
  }
  ]]
  printf("Bable:reqBableChoiceFriendCardC2S(friendId):"..friendId)
  self._saveResultHandler = saveResultHandler
  _showLoading()
  local data = PbRegist.pack(PbMsgId.BableChoiceFriendCardC2S,{friend_id = friendId})
  net.sendMessage(PbMsgId.BableChoiceFriendCardC2S,data)
end

function Bable:onBableChoiceFriendCardResultS2C(action,msgId,msg)
  --[[
  message BableChoiceFriendCardResultS2C{
   enum traits {value = 10086;}
   enum State{
    FriendAlreadyHelp = 1;      //该好友今天已经帮助过你了
    FriendHasNoHelpCard = 2;      //该好友没有指定卡牌帮助别人
    Success = 3;
   }
   required State state = 1;
   optional ClientSync client_sync = 2;
  }
  ]]
  printf("Bable:onBableChoiceFriendCardResultS2C:"..msg.state)
  _hideLoading()
  if msg.state == "Success" then
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
    if self._saveResultHandler ~= nil then
       self._saveResultHandler()
    end
  else
    self:toastError(msg.state)
  end
  
  self._saveResultHandler = nil
  
end

function Bable:setSharedCard(card)
  self._sharedCard = card 
end 

function Bable:getSharedCard()
  return self._sharedCard 
end 

function Bable:getCardsForShareList()
  local tbl = {}
  local allCards = GameData:Instance():getCurrentPackage():getAllCards()
  local minLevel = AllConfig.bable_init[1].card_level
  if allCards ~= nil then 
    for k, v in pairs(allCards) do 
      if (v:getLevel() > minLevel) and (v:getCradIsWorkState() == false) then
        if v:getIsExpCard() == false then 
          table.insert(tbl, v)
        end
      end
    end
  end
  return tbl
end 

function Bable:getCardsForBattle(withDeadedCard)
  if withDeadedCard == nil then
    withDeadedCard = true
  end

  local tbl = {}
  local allCards = GameData:Instance():getCurrentPackage():getAllCards()
  local minLevel = AllConfig.bable_init[1].card_level
  if allCards ~= nil then 
    for k, card in pairs(allCards) do 
      if card:getLevel() > minLevel 
      and card:getCradIsWorkState() == false 
      --and card:getCardHpperByHpType(Card.CardHpTypeBable) > 0
      then
        if card:getIsExpCard() == false then 
          print(card:getName(),card:getCardHpperByHpType(Card.CardHpTypeBable))
          if withDeadedCard == true then
            table.insert(tbl, card)
          else
            if card:getCardHpperByHpType(Card.CardHpTypeBable) > 0 then
              table.insert(tbl, card)
            end
          end
        end
      end
    end
  end
  return tbl
end 

function Bable:getFriendCards()
  --friend cards
  local cards = {}
  local friends = Friend:Instance():getCurrentFriend()
  --dump(friends)
  for key, friend in pairs(friends) do
    --dump(friend:getHelpInfo())
    local hasHelpedToday = false
    local friendsId = self:getHpInfo().friend_help_info or {}
    for key, friendId in pairs(friendsId) do
    	if friend:getId() == friendId then
    	 hasHelpedToday = true
    	 break
    	end
    end
    
    if hasHelpedToday == false then
      local helpInfo = friend:getHelpInfo()
      if helpInfo ~= nil and helpInfo.card_config_id > 0 then
       --[[
        message FriendHelpInfo{
        optional int32 card_config_id = 1;
        optional int32 card_level = 2;
        }
        ]]
        local card = Card.new()
        card:initAttrById(helpInfo.card_config_id)
        card:setId(10000 + friend:getId())
        card:setLevel(helpInfo.card_level)
        card:setOwnerType(BattleConfig.CardOwnerTypeFriend)
        card:setName(friend:getName())
        table.insert(cards,card)
      end
     end
  end
  --dump(cards)
  return cards
end

function Bable:getAllCards()
  local cards = self:getCardsForBattle()
  local friendCards = self:getFriendCards()
  table.insertList(cards, friendCards)
  return cards
end

function Bable:reqFightCheck(stageId)
  if #self:getCardsForBattle(false) <= 0 then
    Toast:showString(GameData:Instance():getCurrentScene(),_tr("您已经没有可以战斗的武将"), ccp(display.cx, display.cy))
    return
  end

  printf("Bable:reqFightCheck:"..stageId)
  _showLoading()
  local fightTypes = "PVE_BABLE"
  local data = PbRegist.pack(PbMsgId.BableFightReqCheckC2S,{ map = {map = stageId,level = 1 ,fightType = fightTypes} })
  net.sendMessage(PbMsgId.BableFightReqCheckC2S,data)
end

function Bable:onCheckFightResult(action,msgId,msg)
  printf("Bable:onCheckFightResult:"..msg.info.fightType)
  _hideLoading()
  if msg.info.fightType == "PVE_BABLE" then
     if msg.error == "NO_ERROR_CODE" then
      GameData:Instance():getCurrentScene():getDisplayContainer():removeAllChildrenWithCleanup(true)
      local battleController = ControllerFactory:Instance():create(ControllerType.BATTLE_CONTROLLER)
      battleController:enter()
      battleController:startPVEBableBattle(msg)
     else
      self:toastError(msg.error)
     end
  end
end

function Bable:reqFightBattle(cards)
  printf("Bable:reqFightBattle")
  dump(cards)
  local data = PbRegist.pack(PbMsgId.BableFightReqCS2BS,{cards = {card_pos = cards}})
  net.sendMessage(PbMsgId.BableFightReqCS2BS,data)
end

function Bable:toastError(error)
  Toast:showString(GameData:Instance():getCurrentScene(),_tr(error), ccp(display.cx, display.cy))
end

-- 通天塔信息
-- message BableInfo{
--   optional int32 helper_card_id = 1;        //帮助好友的卡牌id
--   optional int32 bable_id = 2;              //当前通关塔层
--   optional int32 help_friend_count = 3;     //帮助好友的次数 
-- }
function Bable:setBableInfo(pMsgBableInfo)
  -- if pMsgBableInfo.bable_id <= #AllConfig.bable then 
    self._bableInfo = pMsgBableInfo 
    echo("setBableInfo:", pMsgBableInfo.bable_id, pMsgBableInfo.helper_card_id, pMsgBableInfo.help_friend_count)
  -- else 
  --   echo("=== invalid bable info...")
  -- end 
end 

function Bable:getBableInfo()
  return self._bableInfo 
end 

-- 通天塔重置次数
function Bable:setResetTimes(counts)
  self._resetTimes = counts
end 

function Bable:getResetTimes()
  return self._resetTimes or 0 
end 

-- 今天是否战斗过, 只要战斗过即可领取奖励
function Bable:setDailyFightFlag(flag)
  self._dailyFightFlag = flag 
end 

function Bable:getDailyFightFlag()
  return self._dailyFightFlag 
end 

-- 通天塔每日奖励是否已领取
function Bable:setDailyAwardFlag(flag)
  self._dailyAwardFlag = flag 
end 

function Bable:getDailyAwardFlag()
  return self._dailyAwardFlag 
end 


-- 通天塔怪物血量信息
  -- message BableInfo{
  -- optional int32 self_wall_hp_per = 1;      //自己城墙血量万分比
  -- optional int32 target_wall_hp_per = 2;      //目标城墙血量万分比
  -- repeated int32 friend_help_info = 3;      //援助过自己的好友id集合
  -- repeated BableCardInfo target_card_info = 4;  //最后一关的怪物血量信息
  -- };
function Bable:setHpInfo(pMsgMonsterInfo)
  self._monsterInfo = pMsgMonsterInfo 
  echo("====Bable:setHpInfo:", pMsgMonsterInfo.target_wall_hp_per)
end 

function Bable:getHpInfo()
  return self._monsterInfo 
end 


-- 好友卡牌信息
-- message FriendHelpInfo{
--   optional CommanderCard friend_card_info = 1;      //好友卡牌信息
--   repeated Equipment equip = 2;
-- };
function Bable:setFriendHelpInfo(pMsgHelpInfo)
  self._friendHelpInfo = pMsgHelpInfo 
end 

function Bable:getFriendHelpInfo()
  return self._friendHelpInfo 
end 

function Bable:getAwardInfoById(bableId)
  local isPass = false 
  local isAwarded = false 

  if bableId >= 1 then 
    local info = GameData:Instance():getCurrentPlayer():getAllGetedAwards()
    if info and info.bable then 
      for k, v in pairs(info.bable) do 
        echo("====bable award_id, type:", v.id, v.type, v.data)
        if v.id == bableId then 
          isPass = true 
          if v.type == "BABLE_AWARD" then 
            isAwarded = v.data > 0 
          end 
          break 
        end 
      end 
    end 
  end 
  return isPass, isAwarded
end 

function Bable:getHpPercent(bableId)
  local hpInfo = self:getHpInfo()
  local stageId = AllConfig.bable[bableId].stage_id 
  local totalWallHp = AllConfig.stage[stageId].gate_hp 
  local totalCardsHp = 0
  local curWallHp, curCardsHp
  
  local cardIdMap = {}
  for k, v in pairs(AllConfig.monstergroup[stageId].monster_group) do 
    totalCardsHp = totalCardsHp + AllConfig.monster[v.array[2]].hp_fix 
    cardIdMap[v.array[2]] = AllConfig.monster[v.array[2]].unit 
  end 

  if #hpInfo.target_card_info == 0 then --新关卡
    curWallHp = totalWallHp 
    curCardsHp = totalCardsHp 
  else 
    curWallHp = totalWallHp * hpInfo.target_wall_hp_per/10000
    curCardsHp = 0 

    for k, v in pairs(hpInfo.target_card_info) do 
      for monsterId, configId in pairs(cardIdMap) do 
        if configId == v.card_id then 
          echo("update: card_id, card_hp_per", v.card_id, v.card_hp_per)       
          curCardsHp = curCardsHp + AllConfig.monster[monsterId].hp_fix * v.card_hp_per/10000
          break 
        end 
      end 
    end 
  end 
  
  echo("===curWallHp,totalWallHp, curCardsHp, totalCardsHp", curWallHp,totalWallHp, curCardsHp, totalCardsHp)
  local percent = 100*(curWallHp+curCardsHp)/(totalWallHp+totalCardsHp)
  echo("===getHpPercent: bableId, percent=", bableId, percent)
  
  return percent
end 

function Bable:handleErrorCode(errorCode)
  if errorCode == "ConfigError" then 
    Toast:showString(curScene, _tr("system error"), ccp(display.cx, display.cy))
  elseif errorCode == "ResetTimesLimit" then 
    Toast:showString(curScene, _tr("reset_times_used_out"), ccp(display.cx, display.cy))
  elseif errorCode == "NoItemAndNoMoney" then 
    Toast:showString(curScene, _tr("no_enough_money_or_item"), ccp(display.cx, display.cy))
  elseif errorCode == "CardNotFixCondition" then 
    Toast:showString(curScene, _tr("help_card_not_correct"), ccp(display.cx, display.cy))  
  elseif errorCode == "SameCard" then 
    Toast:showString(curScene, _tr("same_help_card"), ccp(display.cx, display.cy)) 
  elseif errorCode == "AlreadyGetAward" then 
    Toast:showString(curScene, _tr("has_awarded_today"), ccp(display.cx, display.cy)) 
  elseif errorCode == "DonotFightBable" then 
    Toast:showString(curScene, _tr("no_bonus_for_no_bable_fight"), ccp(display.cx, display.cy)) 
  elseif errorCode == "HelpCountNoFix" then 
    Toast:showString(curScene, _tr("no_enough_assist_counts"), ccp(display.cx, display.cy))                  
  end 
end 


-- 系统登录时同步助阵卡
function Bable:getHelpCardMode()
  local card = nil
  if GameData:Instance():getCurrentPackage() then 
    local allCards = GameData:Instance():getCurrentPackage():getAllCards()
    if allCards then 
      local info = self:getBableInfo()
      for k, v in pairs(allCards) do 
        if v:getId() == info.helper_card_id then 
          card = v 
          break 
        end 
      end 
    end 
  end 

  return card 
end 

function Bable:hasCardToRelived()
  local flag = false  
  local allCards = GameData:Instance():getCurrentPackage():getAllCards()
  for k, v in pairs(allCards) do 
    if v:getCardHpperByHpType(Card.CardHpTypeBable) < 10000 then 
      flag = true 
      break 
    end 
  end 

  return flag 
end 

function Bable:hasBonusForFetch()

  local fightFlag = self:getDailyFightFlag()
  local awardFlag = self:getDailyAwardFlag()
  if fightFlag and not awardFlag then 
    return true 
  end 

  local info = self:getBableInfo()
  local assistMax = AllConfig.bable_init[1].friend_count 
  if info and info.help_friend_count >= assistMax then 
    return true 
  end 

  return false 
end 

return Bable