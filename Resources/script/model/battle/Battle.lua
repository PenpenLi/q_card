require("model.battle.BattleConfig")
require("model.battle.BattleCard")
require("model.battle.BattleBoss")
require("model.battle.BattleField")
require("model.battle.BattleWall")
require("model.battle.BattleResult")
require("model.Player")

require("model.battle.event.BattleAliveEvent")
require("model.battle.event.BattleAttackEvent")
require("model.battle.event.BattleMoveEvent")
require("model.battle.event.BattleWallBrokenEvent")
require("model.battle.event.BattleSkillEvent")
require("model.battle.event.BattleSkillDamageEvent")
require("model.battle.event.BattleChangeStatusEvent")
require("model.battle.event.BattleDropItemEvent")
require("model.battle.event.BattleCardTurnEvent")
require("model.battle.event.BattleCombineSkillEvent")
require("model.battle.event.BattleCardEffectEvent")
require("model.battle.event.BattleCardChangeValueEvent")
require("model.battle.event.BattleWallBeCureEvent")
require("model.battle.event.BattleWallChangeValueEvent")
require("model.battle.event.BattleWallAttackEvent")


Battle = class("Battle")


function Battle:ctor(isLocalFight,isLocalPlay)
  self._isLocalFight = isLocalFight
  self._isLocalPlay = isLocalPlay
  self._IsFinish = false
  self._DropCount = 0
  self._Cards = {}
  self:setSelfIsAttacker(true)
  self:setIsPlayingReview(false)
  -- for local fight,default map view config
  self:setViewConfig(AllConfig.battletheme[1])
  -- only for local fight
  net.registMsgCallback(PbMsgId.NormalBattleResult,self,Battle.onNormalBattleResult)
  -- server fight
  net.registMsgCallback(PbMsgId.FightResult,self,Battle.onServerBattleResult)
  net.registMsgCallback(PbMsgId.FightErrorBS2CS,self,Battle.onFightCheckResult)
  -- pvp fight
  --net.registMsgCallback(PbMsgId.PVPFightResultS2C,self,Battle.onPVPFightResultS2C) -- at Expedition.lua
  net.registMsgCallback(PbMsgId.SaveBattlePositionResult,self,Battle.onSaveBattlePositionResult)
  
  net.registMsgCallback(PbMsgId.SaveBattleFormationResultS2C,self,Battle.onSaveBattleFormationResultS2C)
  
  if isLocalPlay == true then
     local playStage = ScenarioStage.new()
     playStage:setStageId(BattleConfig.LocalPlayStageId)
     local allStages = Scenario:Instance():getAllStages()
     allStages[BattleConfig.LocalPlayStageId] = playStage
     Scenario:Instance():setUnPassedLastStage(playStage)
     self:setFightType("PVE_NORMAL")
  end
  self:setIsBattleFormationModle(true)
end

------
--  Getter & Setter for
--      Battle._IsBattleFormationModle 
-----
function Battle:setIsBattleFormationModle(IsBattleFormationModle)
	self._IsBattleFormationModle = IsBattleFormationModle
end

function Battle:getIsBattleFormationModle()
	return self._IsBattleFormationModle
end

function Battle:destory()

  local event_loop = self:getEventLoop()
  self:setEventLoop(nil)
  printf("To destory event loop")
  if event_loop ~= nil then
     coroutine.resume(event_loop)
  end
  
  self:setBattleView(nil)
  net.unregistAllCallback(self)
  
  if self._isLocalPlay == true then
     Scenario:Instance():setUnPassedLastStage(Scenario:Instance():getCurrentStage())
  end

end

function Battle:accept(msg)
  -- setup cards
  local cards = {}
  printf("BattleConfig.BattleSide.Blue:%d,BattleConfig.BattleSide.Red:%d",BattleConfig.BattleSide.Blue,BattleConfig.BattleSide.Red)
  
  for key, _card in pairs(msg.cards) do
    local card = BattleCard.new()
    card:accept(_card)
    cards[card:getIndex()] = card
  end
  self:setCards(cards)
  -- setup fields
  local fields = {}
  for i = BattleConfig.BattleFieldBegin, BattleConfig.BattleFieldEnd do
    fields[i] = "Wall"
  end
  for i = BattleConfig.BattleFieldBegin + BattleConfig.BattleFieldWallLength, BattleConfig.BattleFieldEnd - BattleConfig.BattleFieldWallLength - 1 do
  	fields[i] = BattleField.new(i)
  end
  for key, _field in pairs(msg.fields) do
    local field = fields[_field.init_pos]
    field:accept(_field)
  end
  self:setFields(fields)
  -- setup wall
  local walls = {}
  for key, _wall in pairs(msg.walls) do
    local wall = BattleWall.new()
    wall:accept(_wall)
  	walls[wall:getGroup()] = wall
  end
  self:setWalls(walls)
  -- setup events
  local events = {}
  for key, _event in pairs(msg.events) do
    local event = nil
    if _event.type == PbEventType.EventTypeMove then
      event = BattleMoveEvent.new(_event.type,_event.event_info)
    elseif _event.type == PbEventType.EventTypeAttack then
      event = BattleAttackEvent.new(_event.type,_event.event_info)
    elseif _event.type == PbEventType.EventTypeAlive then
      event = BattleAliveEvent.new(_event.type,_event.event_info)
    elseif _event.type == PbEventType.EventTypeWallBroken then
      event = BattleWallBrokenEvent.new(_event.type,_event.event_info)
    elseif _event.type == PbEventType.EventTypeSkill then
      event = BattleSkillEvent.new(_event.type,_event.event_info)
    elseif _event.type == PbEventType.EventTypeSkillDamage then
      event = BattleSkillDamageEvent.new(_event.type,_event.event_info)
    elseif _event.type == PbEventType.EventTypeChangeStatus then
      event = BattleChangeStatusEvent.new(_event.type,_event.event_info)
    elseif _event.type == PbEventType.EventTypeDropItem then
      event = BattleDropItemEvent.new(_event.type,_event.event_info)
    elseif _event.type == PbEventType.EventTypeTurn then
      event = BattleCardTurnEvent.new(_event.type,_event.event_info)
    elseif _event.type == PbEventType.EventTypeCombineSkill then
      event = BattleCombineSkillEvent.new(_event.type,_event.event_info)
    elseif _event.type == PbEventType.EventTypeEffect then
      event = BattleCardEffectEvent.new(_event.type,_event.event_info)
    elseif _event.type == PbEventType.EventTypeChangeValue then
      event = BattleCardChangeValueEvent.new(_event.type,_event.event_info)
    elseif _event.type == PbEventType.EventTypeWallBeCure then
      event = BattleWallBeCureEvent.new(_event.type,_event.event_info)
    elseif _event.type == PbEventType.EventTypeWallChangeValue then
      event = BattleWallChangeValueEvent.new(_event.type,_event.event_info)
    elseif  _event.type == PbEventType.EventTypeWallAttack then
      event = BattleWallAttackEvent.new(_event.type,_event.event_info)
    else
      assert(false,"Unknown event:%d",_event.type)
    end
    events[#events + 1] = event
  end
  self:setEvents(events)
  -- setup result
  local result = BattleResult.new()
  result:accept(msg.result)
  self:setResult(result)
  
  self:setMapId(msg.map_id)
  self:setMapLevel(msg.map_level)
  print(msg.map_id)
  if msg.map_id ~= 0 then
    local battleTheme = AllConfig.stage[msg.map_id].background
    if battleTheme ~= 0 then
      self:setViewConfig(AllConfig.battletheme[battleTheme])
    end
  end
  --- Battle Type
  -- 0 normal,1 boss
  -- 
  self:setIsBossBattle(msg.battle_type == 1)
  if self:getIsBossBattle() == true then
    local boss = BattleBoss.new()
    dump(msg.players)
    local player = msg.players[msg.boss_group + 1]
    boss:accept(player)
    self:setBoss(boss)
    for key, card in pairs(cards) do
      if card:getGroup() == msg.boss_group then
        card:setIsBoss(true)
      end
    end
  end
end

--function Battle:setBossId(BossId)
--	self._BossId = BossId
--end
--
--function Battle:getBossId()
--	return self._BossId
--end

function Battle:setStage(Stage)
	self._Stage = Stage
	self:setViewConfig(AllConfig.battletheme[self._Stage:getBackground()])
end

function Battle:getStage()
	return self._Stage
end

------
--  Getter & Setter for
--      Battle._IsPlayingReview 
-----
function Battle:setIsPlayingReview(IsPlayingReview)
	self._IsPlayingReview = IsPlayingReview
end

function Battle:getIsPlayingReview()
	return self._IsPlayingReview
end

------
--  Getter & Setter for
--      Battle._isLocalFight 
-----
function Battle:setIsLocalPlay(IsLocalPlay)
	self._isLocalFight = IsLocalPlay
end

function Battle:getIsLocalPlay()
	return self._isLocalFight
end

function Battle:makeSureCardsPos()
   local function getIdlePos()
        local pos = 4
        for m_pos = 4, 15 do
           local posIsIdle = true
           for key, m_card in pairs(self._Cards) do
               if m_card:getPosition() == m_pos then
                  posIsIdle = false
                  break
               end
           end
           if posIsIdle == true then
              pos = m_pos
              break
           end 
        end
        return pos
    end
        
    --make sure card pos right
    for key, mcard in pairs(self._Cards) do
      if mcard:getIsMySide() == true then
          if mcard:getPos() < 4 or mcard:getPos() > 15 then
             local __mpos = getIdlePos()
             mcard:setPos(__mpos)
          end
      end
    end
    
    --make sure card pos unique (not repeat)
     for m_pos = 4, 15 do
       local count = 0
       for key, m_card in pairs(self._Cards) do
           if m_card:getPosition() == m_pos then
              count = count + 1
              if count > 1 then
                 local pos = getIdlePos()
                 m_card:setPos(pos)
              end
           end
       end
    end
end

function Battle:reqSaveBattleFormation(autoPVEBable)
    if autoPVEBable == nil then
      autoPVEBable = true
    end

    self:makeSureCardsPos()
    local myCards = {}
    for key, card in pairs(self:getCards()) do
      if card:getIsMySide() == true then
         local cardTable = {}
         cardTable.card = card:getId()
         cardTable.pos = card:getPos()
         local leader = 0
         if card:getIsPrimary() == true then
           leader = 1
         end
         cardTable.leader = leader
         if self._fightType == "PVE_BABLE" then
           cardTable.ownerType = card:getOwnerType()
         end
         table.insert(myCards,cardTable)
      end
   end
   self:setIsBattleFormationModle(false)
   local attackBattleFormationIdx = BattleFormation:Instance():getCurrentAttackBattleFormationIdx()
   if self._fightType == "PVE_BABLE" then
    attackBattleFormationIdx = BattleFormation.BATTLE_INDEX_BABLE
    if autoPVEBable == true then
      self:reqSeverBattle()
    end
   end
   BattleFormation:Instance():reqSaveBattleFormationC2S(attackBattleFormationIdx,myCards)
end

function Battle:onSaveBattleFormationResultS2C(action,msgId,msg)
  printf("onSaveBattleFormationResultS2C:"..msg.error)
   
  if self:getIsBattleFormationModle() == true then
    local str = ""
    if msg.error == "NO_ERROR_CODE" then
      str = _tr("save_battle_formation_success")
    else
      str = _tr("save_battle_formation_fail").."("..msg.error..")"
    end
    Toast:showString(GameData:Instance():getCurrentScene(), str, ccp(display.cx, display.cy))
    return
  end
  
  self:reqSeverBattle()
end

--[[function Battle:reqSaveBattlePosition()
    
    self:makeSureCardsPos()
        
    local myCards = {}
    for key, card in pairs(self:getCards()) do
      if card:getIsMySide() == true then
         local cardTable = {}
         cardTable["card_id"] = card:getId()
         cardTable["position"] = card:getPos()
         --echo("sendCards:",cardTable.card_id,cardTable.position)
         table.insert(myCards,cardTable)
      end
   end
   
   local data = PbRegist.pack(PbMsgId.SaveBattlePosition,{ card = myCards })
   net.sendMessage(PbMsgId.SaveBattlePosition,data)
end]]

function Battle:onSaveBattlePositionResult(action,msgId,msg)
   --assert(false,"geted SaveBattlePositionResult")
   if msg.state == "Ok" then
      print("save cards position to server success!")
      GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
   end
   
   self:reqSeverBattle()
  
end

function Battle:onFightCheckResult(action,msgId,msg)
  print("Battle:onFightCheckResult:",msg.error)
  if msg.error == "NO_ERROR_CODE" then
  else
     if msg.info.fightType == "PVE_BOSS" then
         if msg.error == "IS_IN_CD_TIME" then
             Toast:showString(self, _tr("invalid_time"), ccp(display.width/2, display.height*0.4))
         elseif msg.error == "BOSS_IS_DEAD" then
             Toast:showString(self, _tr("boss_is_killed"), ccp(display.width/2, display.height*0.4))
             --self:setIsFinish(true)
             self:getBattleView():getDelegate():goToActivity()
         elseif msg.error == "STAGE_CLOSE" then
             Toast:showString(self, _tr("boss_is_close"), ccp(display.width/2, display.height*0.4))
             self:getBattleView():getDelegate():goToActivity()
         else
             Toast:showString(self, msg.error, ccp(display.width/2, display.height*0.4))
             self:getBattleView():getDelegate():goToActivity()
         end
         
     end
  end
end

function Battle:reqSeverBattle()
    
    --_showLoading()
   
     --req sever battle
    if self._isLocalFight == true then
      local data = PbRegist.pack(PbMsgId.DebugGetSingleFightResult)
      net.sendMessage(PbMsgId.DebugGetSingleFightResult,data)
    else
    
    
    local myCards = {}
    
    local function getIdlePos()
        local pos = 4
        for m_pos = 4, 15 do
           local posIsIdle = true
           for key, m_card in pairs(myCards) do
               if m_card.pos == m_pos then
                  posIsIdle = false
                  break
               end
           end
           if posIsIdle == true then
              pos = m_pos
              break
           end 
        end
        return pos
    end

      -- convert defender and attacker pos
      
      local isAttacker = self:getSelfIsAttacker()
      for key, card in pairs(self:getCards()) do
        if card:getIsMySide() == isAttacker then
           local cardTable = {}
           cardTable["card"] = card:getId()
           if isAttacker == true then
              cardTable["pos"] = card:getPos()
           else
              cardTable["pos"] = 31 - card:getPos()
           end
           if card:getIsPrimary() == true then
              cardTable["leader"] = 1
           else
              cardTable["leader"] = 0
           end
           
           cardTable["owner_type"] = card:getOwnerType()
           
           if cardTable.pos < 4 or cardTable.pos > 15 then
             local __mpos = getIdlePos()
             cardTable.pos = __mpos
           end
          
           echo("sendCards:",cardTable.card,cardTable.pos)
           table.insert(myCards,cardTable)
        end
      end
      
       --make sure card pos unique (not repeat)
       for m_pos = 4, 15 do
         local count = 0
         for key, m_card in pairs(myCards) do
             if m_card.pos == m_pos then
                count = count + 1
                if count > 1 then
                   local pos = getIdlePos()
                   m_card.pos = pos
                end
             end
         end
      end
      
      for key, card in pairs(self:getCards()) do
        print(card.pos,"Pos")
      end
      dump(myCards)
      
  --    PVE_NORMAL
  --    PVP_NORMAL
  --    PVE_BOSS
  --    PVE_ACTIVITY
      print("reqBattle:", "self._fightType:",self._fightType)
      local data = nil 
      if self._fightType == "PVE_NORMAL" or self._fightType == "PVE_ACTIVITY" then
          local stage = self:getStage()
          print("startPVEbattle")
          data = PbRegist.pack(PbMsgId.FightReqCS2BS,{ map = {map = stage:getStageId(),level = 1 ,fightType = self._fightType },cards = { card_pos = myCards },activity_id = stage:getActivityId() })
          net.sendMessage(PbMsgId.FightReqCS2BS,data)
      elseif self._fightType == "PVE_GUILD" then
         Guild:Instance():reqGuildFightReqC2S(myCards)
      elseif self._fightType == "PVP_NORMAL" then
          data = PbRegist.pack(PbMsgId.PVPFightReqC2S,{ cards = { card_pos = myCards } })
          net.sendMessage(PbMsgId.PVPFightReqC2S,data)
      elseif self._fightType == "PVE_BOSS" then
          data = PbRegist.pack(PbMsgId.BossFightReqC2S,{ cards = { card_pos = myCards },boss = self:getBossFromActivity():getId() })
          net.sendMessage(PbMsgId.BossFightReqC2S,data)
      elseif self._fightType == "PVP_REAL_TIME" then
          Arena:Instance():reqPVPArenaFightReqC2S(myCards)
      elseif self._fightType == "PVP_RANK_MATCH" then
          PvpRankMatch:Instance():reqPVPRankMatchFightReqC2S(myCards)
      elseif self._fightType == "PVE_BABLE" then
          Bable:instance():reqFightBattle(myCards)
      else
          echo("UNKNOW fightType")
          return
      end  
    end
end


function Battle:reqBattle()
  if self._isLocalFight == true then
     self:reqSeverBattle()
  else
     if self:getFightType() == "PVP_REAL_TIME" then
       self:reqSeverBattle()
     else
       -- save cards position to server
       --self:reqSaveBattlePosition()
       self:reqSaveBattleFormation()
     end
  end
end

------
--  Getter & Setter for
--      Battle._FightType 
-----
function Battle:setFightType(FightType)
	self._fightType = FightType
end

function Battle:getFightType()
	return self._fightType
end

function Battle:prepareArenaBattle(msg)
  --[[  msg:
  enum traits{value = 5130;}
  enum ErrorCode{
    NO_ERROR_CODE = 1;  //
    NOT_OPEN_TIME = 2;  //时间没到
    LEVEL_LIMIT   = 3;  //等级不够
    LIMIT_SEARCH  = 5;  //搜索次数没了
    NOT_IN_SEARCH = 6;  //不在搜索
    WAIT_RESULT   = 7;  //等待战斗结算结果
    SYSTEM_ERROR  = 4;  //其他错误
  }
  required ErrorCode error = 1;     
  optional PVPArenaTarget target = 2;  //对手数据
  optional PVPArenaData self = 3;    //自己数据
  ]]
  
  local targetMsg = msg.target
  --[[  targetMsg:
  message PVPArenaTarget{
  optional PVPArenaBase base = 1;   //基础数据
  optional FightCards cards  = 2;   //卡牌数据
  optional int32 keepWinBuffer = 3; //增加BUFF
  optional bool isAttacker = 4;   //是否攻击
  optional FightMap map = 7;      //对战地图
  }
  ]]
  
  --parse msg
  self:setFightType(targetMsg.map.fightType)
  print("FightType:",targetMsg.map.fightType)
  
  self._Cards = {}
 
   -- setup fields
  local fields = {}
  for i = BattleConfig.BattleFieldBegin, BattleConfig.BattleFieldEnd do
    fields[i] = "Wall"
  end
  
  local idx = 1
  for i = BattleConfig.BattleFieldBegin + BattleConfig.BattleFieldWallLength, BattleConfig.BattleFieldEnd - BattleConfig.BattleFieldWallLength - 1 do
    fields[i] = BattleField.new(i)
    fields[i]:setIndex(idx)
    idx = idx + 1
  end
  
  local mapId = targetMsg.map.map
  local mapFields = {}
  if AllConfig.territory[mapId] ~= nil then
    mapFields = AllConfig.territory[mapId].territory
  end
  
  if mapId > 0 then
    local battleTheme = AllConfig.stage[mapId].background
    if battleTheme > 0 then
      self:setViewConfig(AllConfig.battletheme[battleTheme])
    end
  end

  for key, fieldGroup in pairs(mapFields) do
    local fieldPos = fieldGroup.array[1]
    local fieldType = fieldGroup.array[2]
    echo(fieldPos ,fieldType)
    local field = fields[fieldPos]
    field:setType(fieldType)
    --echo("fieldPos:",fieldPos,"fieldType:",fieldType)
  end
  self:setFields(fields)
  
  --setup self cards
  self:setupSelfCards(targetMsg.isAttacker)
  
  -- setup wall
  -- TODO assign wall level
  local wallsOrg = {{level = 10,hp = 0,group = BattleConfig.BattleSide.Blue},{level = targetMsg.map.level,hp = 0,group = BattleConfig.BattleSide.Red}}
  local walls = {}
  for key, _wall in pairs(wallsOrg) do
    local wall = BattleWall.new()
    wall:accept(_wall)
    walls[wall:getGroup()] = wall
  end
  self:setWalls(walls)
  self:getBattleView():resetView()
  self:getBattleView():setupView(self)
  self:getBattleView():showArenaCloud(self:getSelfIsAttacker())
end

function Battle:updateArenaTargetPlayer(targetMsg)
  dump(targetMsg.cards.card_pos)
  
  local targetCards = {}
  local fightCards = targetMsg.cards.card_pos
  
  dump(fightCards)
  
  --check sever data 
  for key, targetInfo in pairs(fightCards) do
     local targetCard = BattleCard.new()
     targetCard:initAttrById(targetInfo.config)
     targetCard:setType(AllConfig.unit[targetInfo.config].unit_type)
     --[[targetCard:setLevel(targetInfo.level)
     -- read equipment info
     for key, equipItem in pairs(targetInfo.equip) do
         local idx = equipItem.config_id
          if  AllConfig.equipment[idx].equip_type == 1 then -- weapon
            local weapon = Weapon.new()
            weapon:update(equipItem)
            if equipItem.card_id ~= 0 then
               targetCard:setWeapon(weapon)
            end
          elseif AllConfig.equipment[idx].equip_type == 2 then -- armor
            local armor = Armor.new()
            armor:update(equipItem)
            if equipItem.card_id ~= 0 then
              targetCard:setArmor(armor)
            end
          elseif AllConfig.equipment[idx].equip_type == 3 then --accessory
            local accessory = Accessory.new()
            accessory:update(equipItem)
            if equipItem.card_id ~= 0 then
               targetCard:setAccessory(accessory)
            end
          end
     end
     targetCard:setHpFix(targetCard:getHpByLevel(targetInfo.level))
     targetCard:setAttackFix(targetCard:getAttack())
     targetCard:setPos(targetInfo.pos)]]

     --targetCard:setInfoId(targetInfo.config)
     targetCard:setIsMySide(targetMsg.isAttacker)
     --self:appendCard(targetCard)
     table.insert(targetCards,targetCard)
  end
  


    --setup arena fight info
  local targetArenaPlayer = ArenaPlayer.new(targetMsg.base)
  targetArenaPlayer:setIsAttacker(targetMsg.isAttacker)
  local arenaFightInfo = ArenaFightInfo.new()
  arenaFightInfo:setTargetCards(targetCards)
  
  --print("targetCards:")
  --dump(targetCards)
  arenaFightInfo:setTargetPlayer(targetArenaPlayer)
  
  self:getBattleView():updateAreaView(arenaFightInfo)
end

function Battle:prepareBattle(msg)
      if msg ~= nil then
        self._prepareBattle = msg
      else
        msg = self._prepareBattle
      end
      self:setIsBattleFormationModle(true)
      --self._fightType = msg.info.fightType
      self:setFightType(msg.info.fightType)
      if msg.info.mapId ~= 0 then
        local battleTheme = AllConfig.stage[msg.info.mapId].background
        if battleTheme ~= 0 then
          self:setViewConfig(AllConfig.battletheme[battleTheme])
        end
      end
      echo("Battle:fightType:",self._fightType)
      
      local talentIds = msg.info.talent_skill
      local talentProperties = {}
      if talentIds ~= nil and GameData:Instance():getCurrentPlayer() ~= nil then
        talentProperties = GameData:Instance():getCurrentPlayer():getTalentPropertiesByTalentIdsList(talentIds)
      end
      
      self._Cards = {}
      -- pve || boss monsters -- or pvp target cards
      for key, targetInfo in pairs(msg.info.target) do
          local needAppend = true
          echo(targetInfo.card,targetInfo.pos,targetInfo.config)
          --if targetInfo.card ~= 0 then
              local targetCard = BattleCard.new()
              if msg.info.fightType == "PVP_NORMAL" or msg.info.fightType == "PVP_RANK_MATCH" then -- when pvp fight,read unit config
                targetCard:initAttrById(targetInfo.config)
                targetCard:setType(AllConfig.unit[targetInfo.config].unit_type)
                targetCard:setLevel(targetInfo.level)
                
                 -- read equipment info
                for key, equipItem in pairs(targetInfo.equip) do
                   local idx = equipItem.config_id
                    if  AllConfig.equipment[idx].equip_type == 1 then -- weapon
                      local weapon = Weapon.new()
                      weapon:update(equipItem)
                      if equipItem.card_id ~= 0 then
                         targetCard:setWeapon(weapon)
                      end
                    elseif AllConfig.equipment[idx].equip_type == 2 then -- armor
                      local armor = Armor.new()
                      armor:update(equipItem)
                      if equipItem.card_id ~= 0 then
                        targetCard:setArmor(armor)
                      end
                    elseif AllConfig.equipment[idx].equip_type == 3 then --accessory
                      local accessory = Accessory.new()
                      accessory:update(equipItem)
                      if equipItem.card_id ~= 0 then
                         targetCard:setAccessory(accessory)
                      end
                    end
                end

                local cardHpFix = targetCard:getHpByLevel(targetCard:getLevel())
                local talentHp = 0
                local cardAttackFix = targetCard:getAttack()
                local talentAttack = 0
                
                if talentProperties ~= nil then
                  if talentProperties[k_property_hp_per] ~= nil then
                    local value = talentProperties[k_property_hp_per].value
                    talentHp = cardHpFix*(value/10000)
                  end
                  if talentProperties[k_property_atk_per] ~= nil then
                    local value = talentProperties[k_property_atk_per].value
                    talentAttack = cardAttackFix*(value/10000)
                  end
               end
               
               local finalHp = toint(cardHpFix + talentHp)
               local finalAttack = toint(cardAttackFix + talentAttack)
               
               targetCard:setHpFix(finalHp)
               targetCard:setAttackFix(finalAttack)
              elseif  msg.info.fightType == "PVE_NORMAL" 
              or msg.info.fightType == "PVE_BOSS" 
              or msg.info.fightType == "PVE_ACTIVITY" 
              or msg.info.fightType == "PVE_GUILD" 
              or msg.info.fightType == "PVE_BABLE" 
              then  -- when pve or boss fight,read monster config
                 targetCard:initAttrById(AllConfig.monster[targetInfo.monster].unit)
                 targetCard:setType(AllConfig.monster[targetInfo.monster].unit_type)
                 targetCard:setSpecies(AllConfig.monster[targetInfo.monster].unit_type)
                 local skillId = AllConfig.monster[targetInfo.monster].skill
                 local skill = Skill.new(targetCard)
                 skill:initBySkillId(skillId)
                 targetCard:setSkill(skill)
                 
                 local finalHp = AllConfig.monster[targetInfo.monster].hp_fix
                 targetCard:setHpFix(finalHp)
                 targetCard:setAttackFix(AllConfig.monster[targetInfo.monster].atk_fix)
                 
                 if self:getFightType() == "PVE_BABLE" then
                  local cardHpInfos = Bable:instance():getHpInfo().target_card_info
                  --dump(cardHpInfos)
                  --[[
                    message BableCardInfo{
                    optional int32 card_id = 1;           //卡牌configid
                    optional int32 card_hp_per = 2;         //卡牌血量        
                    };]]
                  for key, bableCardInfo in pairs(cardHpInfos) do
                    if bableCardInfo.card_id == targetCard:getConfigId() then
                     local hp = toint(finalHp * bableCardInfo.card_hp_per / 10000)
                     targetCard:setHpFix(hp)
                     targetCard:setHp(hp)
                     targetCard:setMaxHp(finalHp)
                     needAppend = bableCardInfo.card_hp_per > 0
                     break
                    end
                  end
                  
               end
                 
              end
              
              if msg.info.fightType == "PVE_BOSS"
              or  msg.info.fightType == "PVE_GUILD" 
              then
                 targetCard:setIsBoss(true)
              end
              
              targetCard:setPos(targetInfo.pos)
              targetCard:setInfoId(targetInfo.config)
              targetCard:setIsMySide(false)
              if needAppend == true then
                self:appendCard(targetCard)
              end
         -- end
       end
       
        -- setup fields
        local fields = {}
        for i = BattleConfig.BattleFieldBegin, BattleConfig.BattleFieldEnd do
          fields[i] = "Wall"
        end
        
        local idx = 1
        for i = BattleConfig.BattleFieldBegin + BattleConfig.BattleFieldWallLength, BattleConfig.BattleFieldEnd - BattleConfig.BattleFieldWallLength - 1 do
          fields[i] = BattleField.new(i)
          fields[i]:setIndex(idx)
          idx = idx + 1
        end

        for key, fieldGroup in pairs(msg.info.fields) do
          local fieldPos = fieldGroup.index
          local fieldType = fieldGroup.type
          echo(fieldPos ,fieldType)
          local field = fields[fieldPos]
          field:setType(fieldType)
          --echo("fieldPos:",fieldPos,"fieldType:",fieldType)
        end
        self:setFields(fields)
        
        --setup self cards
        self:setupSelfCards()
        
        -- setup wall
        -- TODO assign wall level
        local wallsOrg = {{level = 10,hp = 0,group = BattleConfig.BattleSide.Blue},{level = 10,hp = 0,group = BattleConfig.BattleSide.Red}}
        local walls = {}
        for key, _wall in pairs(wallsOrg) do
          local wall = BattleWall.new()
          wall:accept(_wall)
          walls[wall:getGroup()] = wall
        end
        self:setWalls(walls)
        self:getBattleView():resetView()
        self:getBattleView():setupView(self)
end

------
--  Getter & Setter for
--      Battle._SelfIsAttacker 
-----
function Battle:setSelfIsAttacker(SelfIsAttacker)
	self._SelfIsAttacker = SelfIsAttacker
end

function Battle:getSelfIsAttacker()
	return self._SelfIsAttacker
end

function Battle:setupSelfCards(isDefender)
  
  local needSaveBattleFormation = false
  
  if isDefender == nil then
		isDefender = false
  end
 
  if isDefender == true then
    self:setSelfIsAttacker(false)
	  print("=========================Defender")
  else
    self:setSelfIsAttacker(true)
	  print("=========================Attacker")
  end
  
  -- setup cards
  local cards = GameData:Instance():getCurrentPackage():getBattleCards()
  if self:getFightType() == "PVE_BABLE" then
    cards = {}
    local minLevel = AllConfig.bable_init[1].card_level
    local bableCards = Bable:instance():getAllCards(true)
    local cardsFormation = BattleFormation:Instance():getCardsFormationByBattleIndex(BattleFormation.BATTLE_INDEX_BABLE)
    for key, card in pairs(bableCards) do
      for key, battleCardInfo in pairs(cardsFormation) do
        if card:getId() == battleCardInfo.card
        and card:getCardHpperByHpType(Card.CardHpTypeBable) > 0 
        and card:getLevel() > minLevel
        then
          table.insert(cards,card)
        end
      end
    end
    
    if #cards == 0 and Bable:instance():getHaveUsedDefaultBattleFormation() ~= true then
      local cardsFormation = BattleFormation:Instance():getCardsFormationByBattleIndex(BattleFormation.BATTLE_INDEX_NORMAL_1)
      local bableCards = Bable:instance():getCardsForBattle(false)
      
      for key, card in pairs(bableCards) do
       for key, battleCardInfo in pairs(cardsFormation) do
         if card:getId() == battleCardInfo.card 
         and card:getCardHpperByHpType(Card.CardHpTypeBable) > 0 
         and card:getLevel() > minLevel
         then
           table.insert(cards,card)
         end
       end
      end
      
      Bable:instance():setHaveUsedDefaultBattleFormation(true)
      needSaveBattleFormation = true
    end
    
    dump(cardsFormation)
  end
  
  local battleCards = {}
  
  local function getIdlePos(is_Defender)
      local startPos = 4
      local endPos = 15
      
      if is_Defender == true then
         startPos = 16
         endPos = 27
      end
  
      local pos = startPos
      for m_pos = startPos, endPos do
         local posIsIdle = true
         for key, m_card in pairs(battleCards) do
             if m_card:getPosition() == m_pos then
                posIsIdle = false
                break
             end
         end
         if posIsIdle == true then
            pos = m_pos
            break
         end 
      end
      return pos
  end
  
  local startPos = 4
  local endPos = 15

  local myCardsIsAttacker  = self:getSelfIsAttacker()
  for i = 1 , table.getn(cards) do
    local card = BattleCard.new()
    self:appendCard(card)
    table.insert(battleCards,card)
    card:setOwnerType(cards[i]:getOwnerType())
    card:setId(cards[i]:getId())
    card:initAttrById(cards[i]:getConfigId())
    card:setInfoId(cards[i]:getConfigId())
    local card_pos = cards[i]:getPosition()
    print("org_Pos:",card_pos)

    if card_pos <= 0 then
       card_pos = getIdlePos(false)
    end
    card:setPos(card_pos)
    card.orgCard = cards[i]
    print("org_IdlePos:",card_pos)
    card:setPos(card_pos)
    card:setLevel(cards[i]:getLevel())
    if myCardsIsAttacker == true then
       card:setGroup(BattleConfig.BattleSide.Blue) 
    else
       card:setGroup(BattleConfig.BattleSide.Red) 
    end
    card:setType(cards[i]:getSpecies())
    card:setIsMySide(myCardsIsAttacker)
    card:setIsPrimary(cards[i]:getIsBoss())
    local cardHpFix = cards[i]:getHpByLevel(cards[i]:getLevel())
    local talentHp = 0
    local cardAttackFix = cards[i]:getAttack()
    local talentAttack = 0
    local player = GameData:Instance():getCurrentPlayer()
    if player ~= nil then
      local talentProperties = player:getTalentProperties()
      if talentProperties[k_property_hp_per] ~= nil then
        local value = talentProperties[k_property_hp_per].value
        talentHp = cardHpFix*(value/10000)
      end
      
      if talentProperties[k_property_atk_per] ~= nil then
        local value = talentProperties[k_property_atk_per].value
        talentAttack = cardAttackFix*(value/10000)
      end
    end
    local finalHp = toint(cardHpFix + talentHp)
    local finalAttack = toint(cardAttackFix + talentAttack)
    card:setHpFix(finalHp)
    card:setAttackFix(finalAttack)
    
    if self:getFightType() == "PVE_BABLE" then
      local hpper = card.orgCard:getCardHpperByHpType(Card.CardHpTypeBable)
      local hp = toint(finalHp * hpper / 10000)
      card:setHpFix(hp)
      card:setHp(hp)
      card:setMaxHp(finalHp)
    end
    
  end
  
  -- convert attacker pos to defender pos
  for key, card in pairs(battleCards) do
    local card_pos = card:getPosition()
  	if isDefender == true then
       card_pos = 31 - card_pos
       card:setPos(card_pos)
    end
  end
  
  if isDefender == true then
     startPos = 16
     endPos = 27
  end
  
  --make sure self's cards position
  for key, _mcard in pairs(self._Cards) do
    if _mcard:getIsMySide() == myCardsIsAttacker then
        if _mcard:getPos() < startPos or _mcard:getPos() > endPos then
           local __mpos = getIdlePos(isDefender)
           _mcard:setPos(__mpos)
        end
    end
  end
  
  if self:getFightType() == "PVP_REAL_TIME" then
     -- convert defender and attacker pos
      local myCards = {}
      local isAttacker = self:getSelfIsAttacker()
      for key, card in pairs(self:getCards()) do
        if card:getIsMySide() == isAttacker then
           local cardTable = {}
           cardTable["card"] = card:getId()
           cardTable["pos"] = card:getPos()
           
           local leader = 0
           if card:getIsPrimary() == true then
             leader = 1
           end
           cardTable["leader"]  = leader
           
           if isAttacker == true then
              cardTable["pos"] = card:getPos()
           else
              cardTable["pos"] = 31 - card:getPos()
           end
           cardTable["config"]  = card:getConfigId()
           echo("sendCards:",cardTable.card,cardTable.pos,cardTable.config)
           table.insert(myCards,cardTable)
        end
      end
      
      printf("Arena:Instance():reqPVPArenaChangeCardC2S(myCards)")
      dump(myCards)
      -- send cards pos to pvp target
      Arena:Instance():reqPVPArenaChangeCardC2S(myCards)
      
  elseif self:getFightType() == "PVE_BABLE" then
    if needSaveBattleFormation == true then
      self:reqSaveBattleFormation(false)
    end
  
    local cardsFormation = BattleFormation:Instance():getCardsFormationByBattleIndex(BattleFormation.BATTLE_INDEX_BABLE)
    dump(cardsFormation)
    for battleCardKey, card in pairs(self._Cards) do
      for key, battleCardInfo in pairs(cardsFormation) do
        --print(battleCardInfo.card,battleCardInfo.pos,battleCardInfo.leader)
        if battleCardInfo.card == card:getId() then
          card:setPos(battleCardInfo.pos)
          card:setIsPrimary(battleCardInfo.leader == 1)
        end
      end
    end
  end
  
end

function Battle:onNormalBattleResult(action,msgId,msg)
  --_hideLoading()
  self:onBattleResult(msg)
end

function Battle:onServerBattleResult(action,msgId,msg)
  --_hideLoading()
  self:onBattleResult(msg.result,msg)
end

function Battle:onBattleResult(result,msg)

  print("Battle:onBattleResult~~~~~~~~~~~~~~~~~~~~~~~~")

  if self:getFightType() == "PVE_BABLE" then
    local cardsFormation = BattleFormation:Instance():getCardsFormationByBattleIndex(BattleFormation.BATTLE_INDEX_BABLE)
    for key, battleCardInfo in pairs(cardsFormation) do
      if battleCardInfo.ownerType == BattleConfig.CardOwnerTypeFriend then
        table.remove(cardsFormation,key)
      end
    end
  end
  
  self:accept(result)
  self:getBattleView():resetView()
  self:getBattleView():setupView(self)
  
  self:getBattleView():onBeginBattle(self,self:getBattleView())
  if self._isLocalFight == false and msg ~= nil and self:getIsPlayingReview() == false then
     self:getBattleView():prepareBattleResultView(result,msg,self._fightType)
     
     --[[if self._fightType == "PVP_REAL_TIME" then
       local result_str = msg.result.result_lv
       if result_str == "WIN_LEVEL_1" or result_str == "WIN_LEVEL_2" or result_str == "WIN_LEVEL_3" then
          if msg.result.client_sync ~= nil then
             GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.result.client_sync)
          end
       end
       
     elseif self._fightType ~= "PVP_NORMAL" then -- sync for pve_normal and pve_boss
      
       if result.result.win_group == BattleConfig.BattleSide.Blue then
          print("result.result.win_group:",result.result.win_group,"msg.result_lv:",msg.result_lv)
          if msg.client_sync ~= nil and msg.result_lv == "WIN_LEVEL_2" then
             GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
          end
       elseif result.result.win_group == BattleConfig.BattleSide.Red then
           if self._fightType == "PVE_BOSS" then
              if msg.client_sync ~= nil then
                 GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
              end
           end
       end
       
     end]]
  end
  
  local event_loop = coroutine.create( function ()
    local events = self:getEvents()
    local isLastEventMove = false
    local lastMoveEvent = nil
    for key, event in pairs(events) do
      if self:getIsFinish() == false then
        printf("execute event: %d",key)
        event:execute(self,self:getBattleView())
        if isLastEventMove == true then
          if event:getType() ~= PbEventType.EventTypeMove then
            if lastMoveEvent ~= nil then
              lastMoveEvent:onQuitEvent(self,self:getBattleView())
            end
            lastMoveEvent = nil
            isLastEventMove = false
          end
        end
        if event:getType() == PbEventType.EventTypeMove then
          isLastEventMove = true
          lastMoveEvent = event
        end
      else
        break
      end
    end
    self:setIsFinish(false)
    local battleView = self:getBattleView()
    battleView:wait(0.6)
    battleView:cameraReset()
    if self._isLocalFight == false and self._isLocalPlay ~= true and self:getIsPlayingReview() == false then
       battleView:showResult()
    end
    
    if self._isLocalPlay == true then
       -- trigger ActionTypeBattleFinished
       if self:getFightType() == "PVE_NORMAL" then --or battle:getIsLocalPlay() == true 
           local stage = Scenario:Instance():getUnPassedLastStage()
           local dialogues = {}
           if stage ~= nil then
              local stageId = stage:getStageId()
              assert(AllConfig.dialogue ~= nil,"dialoge data error")
              for key, dialogue in pairs(AllConfig.dialogue) do
                  if  dialogue.stage_id == stageId
                  and dialogue.type == 2
                  and dialogue.time == BattleConfig.ActionTypeBattleFinished
                  then
                     table.insert(dialogues,dialogue)
                  end
              end
           end
           
           local sortDialogues = function(a,b)
              if a.order == b.order then
                 return a.id < b.id
              end
              return a.order < b.order
           end
           
           if #dialogues > 0 then
              table.sort(dialogues,sortDialogues)
              for i = 1, #dialogues do
                local dialogue = BattleDialogueView.new(dialogues[i])
                GameData:Instance():getCurrentScene():addChildView(dialogue)
                dialogue:pause()
              end
           end
       end
           
       local str = _tr("battle_story_end")
       local printStoryView = StoryPrintView.new(str)
       battleView:addChild(printStoryView,1000)
    end
    
        
    if self:getIsPlayingReview() == true or self._isLocalFight == true then
       -- local expeditionController = ControllerFactory:Instance():create(ControllerType.EXPEDITION_CONTROLLER)
       -- --expeditionController:setIsChallenge(false)
       -- expeditionController:enter()
       battleView:showReviewDamageCount(result)
    end
    CONFIG_DEFAULT_ANIM_DELAY_RATIO = 1.0
    CCDirector:sharedDirector():getScheduler():setTimeScale(1.0)
    
  end )
  self:setEventLoop(event_loop)
  printf(coroutine.status(event_loop))
  local success,error = coroutine.resume(event_loop)
  if not success then
    printf("event loop error:"..error)
    print(debug.traceback(event_loop, error)) 
  end
  
end

function Battle:appendCard(card)
  local index = #self._Cards + 1
  card:setIndex(index)
  self._Cards[index] = card
end

function Battle:getCardByIndex(index)
  return self._Cards[index]
end

------
--  Getter & Setter for
--      Battle._EventLoop 
-----
function Battle:setEventLoop(EventLoop)
	self._EventLoop = EventLoop
end

function Battle:getEventLoop()
	return self._EventLoop
end


------
--  Getter & Setter for
--      Battle._BattleView 
-----
function Battle:setBattleView(BattleView)
	self._BattleView = BattleView
end

function Battle:getBattleView()
	return self._BattleView
end


------
--  Getter & Setter for
--      Battle._Cards 
-----
function Battle:setCards(Cards)
	self._Cards = Cards
end

function Battle:getCards()
	return self._Cards
end

------
--  Getter & Setter for
--      Battle._Fields 
-----
function Battle:setFields(Fields)
	self._Fields = Fields
end

function Battle:getFields()
	return self._Fields
end

function Battle:getFieldByIndex(index)
  return self._Fields[index]
end

------
--  Getter & Setter for
--      Battle._Walls 
-----
function Battle:setWalls(Walls)
	self._Walls = Walls
end

function Battle:getWalls()
	return self._Walls
end

function Battle:getWallByIndex(index)

  return self._Walls[index]
end

------
--  Getter & Setter for
--      Battle._Events 
-----
function Battle:setEvents(Events)
	self._Events = Events
end

function Battle:getEvents()
	return self._Events
end


------
--  Getter & Setter for
--      Battle._Result 
-----
function Battle:setResult(Result)
	self._Result = Result
end

function Battle:getResult()
	return self._Result
end

------
--  Getter & Setter for
--      Battle._MapId 
-----
function Battle:setMapId(MapId)
	self._MapId = MapId
end

function Battle:getMapId()
	return self._MapId
end

------
--  Getter & Setter for
--      Battle._MapLevel 
-----
function Battle:setMapLevel(MapLevel)
	self._MapLevel = MapLevel
end

function Battle:getMapLevel()
	return self._MapLevel
end

------
--  Getter & Setter for
--      Battle._ViewConfig 
-----
function Battle:setViewConfig(ViewConfig)
	self._ViewConfig = ViewConfig
end

function Battle:getViewConfig()
	return self._ViewConfig
end

------
--  Getter & Setter for
--      Battle._IsBossBattle 
-----
function Battle:setIsBossBattle(IsBossBattle)
	self._IsBossBattle = IsBossBattle
end

function Battle:getIsBossBattle()
	return self._IsBossBattle
end

------
--  Getter & Setter for
--      Battle._Boss 
-----
function Battle:setBoss(Boss)
	self._Boss = Boss
end

function Battle:getBoss()
	return self._Boss
end

------
--  Getter & Setter for
--      Battle._BossFromActivity 
-----
function Battle:setBossFromActivity(BossFromActivity)
	self._BossFromActivity = BossFromActivity
end

function Battle:getBossFromActivity()
	return self._BossFromActivity
end

------
--  Getter & Setter for
--      Battle._DropCount 
-----
function Battle:setDropCount(DropCount)
	self._DropCount = DropCount
end

function Battle:getDropCount()
	return self._DropCount
end


------
--  Getter & Setter for
--      Battle._IsFinish 
-----
function Battle:setIsFinish(IsFinish)
	self._IsFinish = IsFinish
end

function Battle:getIsFinish()
	return self._IsFinish
end




