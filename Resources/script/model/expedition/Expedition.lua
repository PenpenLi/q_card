require("model.expedition.PVPBaseData")
require("model.expedition.BattleReport")
require("model.expedition.Award")
require("model.expedition.ExpeditionConfig")
Expedition = class("Expedition")

function Expedition:ctor()
  self:setLeftTime(0)
  self:setSeasonChangeTime(0)
  self:setHasNewReport(false)
  self:setAwards({})
  self:setPVPQueryFlag(false)
  self:registNetSever()
end

function Expedition:registNetSever()
  net.registMsgCallback(PbMsgId.PVPQueryDataResultS2C,self,Expedition.onPVPQueryDataResultS2C)
  net.registMsgCallback(PbMsgId.PVPQueryTargetResultS2C,self,Expedition.onPVPQueryTargetResultS2C)
  
  net.registMsgCallback(PbMsgId.FightErrorBS2CS,self,Expedition.onCheckPVPFightResult)
  net.registMsgCallback(PbMsgId.PVPFightResultS2C,self,Expedition.onPVPFightResultS2C) -- message sent by Battle.lua
  net.registMsgCallback(PbMsgId.PVPAwardResultS2C,self,Expedition.onPVPAwardResultS2C)
  net.registMsgCallback(PbMsgId.PVPCalculateResultS2C,self,Expedition.onPVPCalculateResultS2C)
  net.registMsgCallback(PbMsgId.PVPQueryRankResultS2C,self,Expedition.onPVPQueryRankResultS2C)
  
end


--//基础数据结构
--1 .PlayerPVPBaseInfo.proto             (PVP基 础数据结构)
 
--2 .PVPDataSyncCommon.proto             (PVP数据更新模块)
--//消息
--3 .PVPQueryDataC2S.proto ->5020        (请求玩家的PVP信息）
--4 .PVPQueryDataResultS2C.proto->5021   (回馈玩家的PVP信息)

--5 .PVPQueryTargetC2S.proto->5022       (请求刷新PVP目标)
--6 .PVPQueryTargetResultS2C.proto->5023 (回馈PVP目标信息)
--7 .PVPFightCheckC2S.proto->5024        (请求检查PVP战斗)(返回FightErrorBS2CS)
--8 .PVPFightReqC2S.proto->5030          (请求开始PVP战斗)(如果有错误返回FightErrorBS2CS,战斗结果FightResult, pvp战斗会更新PVPFightResultS2C同时下发）
--9 .PVPFightResultS2C.proto->5028       (玩家PVP信息更新)
--10.PVPAwardC2S.proto->5029             (领取PVP相关奖励)
--11.PVPAwardResultS2C.proto->5032       (PVP奖励领取结果) 
--12.PVPCalculateResultS2C.proto->5033   (征战系统22点结算数据）
--13.PVPQueryRankC2S.proto->5044         (请求排行榜）
--14.PVPQueryRankResultS2C.proto->5045   (排行榜数据）

function Expedition:setDelegate(delegate)
    self._delegate = delegate
end

function Expedition:getDelegate()
    return self._delegate
end

function Expedition:reqRanks()
   local data = PbRegist.pack(PbMsgId.PVPQueryRankC2S)
   net.sendMessage(PbMsgId.PVPQueryRankC2S,data)
end

function Expedition:onPVPQueryRankResultS2C(action,msgId,msg)
--  repeated PVPBaseData rank = 1;         //最强王者榜
--  repeated PVPBaseData keepWinRank = 2;  //连胜榜
   --set keepWinRank
   local keepWinRanks = {}
   for key, keepWinRank in pairs(msg.keepWinRank) do
      local keepWinRankData = PVPBaseData.new(keepWinRank)
      table.insert(keepWinRanks,keepWinRankData)
   end
   self:setKeepWinRanks(keepWinRanks)
   
   local kingRanks = {}
   for key, kingRank in pairs(msg.rank) do
   	   local kingRankData = PVPBaseData.new(kingRank)
       table.insert(kingRanks,kingRankData)
   end
   self:setHeroRanks(kingRanks)
end

function Expedition:onPVPCalculateResultS2C(action,msgId,msg)
    echo("onPVPCalculateResultS2C:   id:",msg.id)
    self:parsePvpDataSyncCommon(msg.common)
end

function Expedition:reSearchPvpTarget() --请求刷新PVP目标
  _showLoading()
  local data = PbRegist.pack(PbMsgId.PVPQueryTargetC2S)
  net.sendMessage(PbMsgId.PVPQueryTargetC2S,data)
end

function Expedition:onPVPQueryTargetResultS2C(action,msgId,msg)
--- enum TargetResult{
--    TR_NO_ERROR = 1;          //找到了对手
--    TR_NEED_MORE_TOKEN = 2;   //需要更多的令牌
--    TR_LEVEL_NOT_ALLOW = 3;   //等级还没到达开启条件
--    TR_SYSTEM_ERROR = 4;      //系统错误.例如找不到对手等等
--  }
--  
--  message PVPTarget{
--  optional PVPBaseData base   = 1;
--  optional FightCards cards  = 2;
--  optional int32 source = 3; //可以获取的积分
--  optional int32 coin = 4; //可以获取的铜钱
--  optional int32 minecoin = 5; //可以获取的矿场价格
--}
--
--  required TargetResult result = 1;
--  optional PVPTarget    target = 2;
--  optional ClientSync   client = 3;
--  
--  
    echo("onPVPQueryTargetResultS2C:",msg.result)
    _hideLoading()
    if msg.result == "TR_NO_ERROR" then
       echo("PvpTarget:",msg.target.base.player)
       --set pvp target
       local pvpTarget =  PVPBaseData.new(msg.target.base)
       local pvpTatgetCards = {}
    --   msg.selfData.target.cards.card_pos.config
    --   msg.selfData.target.cards.card_pos.pos
    --   msg.selfData.target.cards.card_pos.card
       for key, card in pairs(msg.target.cards.card_pos) do
          local cardMode = Card.new()
          cardMode:setId(card.card)
          cardMode:initAttrById(card.config)
          cardMode:setPosition(card.pos)
          table.insert(pvpTatgetCards,cardMode)
          echo("pvpTarget's card:",cardMode:getName())
       end
       GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)
       pvpTarget:setCards(pvpTatgetCards)
       pvpTarget:setAllCoin(msg.target.coin + msg.target.minecoin)
       pvpTarget:setTelentPoint(msg.target.talent_point)
       self:setPvpTarget(pvpTarget)
       self:getDelegate():getView():updateView()
       self:startTimeCountDown(30)
       print("Pvp search result play_id:",msg.target.base.player)
       --print("Pvp search result play_id:",pvpTarget:getPlayerId())
    elseif msg.result == "TR_NEED_MORE_TOKEN" then
       Toast:showString(GameData:Instance():getCurrentScene(),_tr("need_more_token"), ccp(display.cx, 200))
    else
        echo(msg.result)
    end
    
end

function Expedition:startTimeCountDown(sceonds)
  self:stopTimeCountDown()
  self.leftTime = sceonds
  self:setLeftTime(self.leftTime)
  local function timerCallback(dt)
    self.leftTime = self.leftTime - 1
    self:setLeftTime(self.leftTime)
    if self.leftTime <= 0 then
      self:stopTimeCountDown()
    else 
      if self.leftTime > 86400 then --24*3600
        --echo(string.format("%d天", math.ceil(self.leftTime/86400)))
      else
        local hour = math.floor(self.leftTime/3600)
        local min = math.floor((self.leftTime%3600)/60)
        local sec = math.floor(self.leftTime%60)
        echo(string.format("%02d:%02d:%02d", hour,min,sec))
      end
    end
  end
  self.scheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(timerCallback, 1.0, false)
end

function Expedition:stopTimeCountDown()
  self:setLeftTime(0)
  if self.scheduler ~= nil then
     CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduler)
     self.scheduler = nil
  end
end

function Expedition:setLeftTime(LeftTime)
	self._LeftTime = LeftTime
end

function Expedition:getLeftTime()
	return self._LeftTime
end

function Expedition:checkPVPFight(targetId,challengeType)
   if targetId == nil then
      targetId = self:getPvpTarget():getPlayerId()
   end
   
   if challengeType == nil then
      challengeType = ExpeditionConfig.challengeTypeNormal
   end
   
   local isChallenge = false
   if challengeType == ExpeditionConfig.challengeTypeRank then
      isChallenge = true
   end
   
   self._isChallenge = isChallenge
   
   self:setStopKeepWin(0)
   _showLoading()
   local data = PbRegist.pack(PbMsgId.PVPFightCheckC2S,{ target = targetId ,target_type = challengeType})
   net.sendMessage(PbMsgId.PVPFightCheckC2S,data)
   echo("checkPvpFight")
  
end

function Expedition:onCheckPVPFightResult(action,msgId,msg)


-- enum FightReqError{
--    NO_ERROR_CODE = 0;
--    CARD_NOT_FOUND= 1;
--    CARD_NOT_ACTIVE = 2;
--    CARD_EQUIP_NOT_FOUND = 3;
--    CARD_EQUIP_ERROR = 4;
--    TARGET_DATA_ERROR = 5;
--    STAGE_NOT_FOUND = 6;
--    LEVEL_NOT_ALLOW = 7;
--    PRE_STAGE_NOT_COMPLETE = 8;
--    NEED_MORE_SPIRIT = 9;
--    SYSTEM_ERROR = 10;
--    NOT_COMPLETE_STAR = 11;
--    STAGE_CLOSE = 12;
--    STAGE_TIME_CLOSE = 13;
--    STAGE_NEED_MORE_CHANCE = 14;
--    NOT_FOUND_PVP_TARGET = 15;
--    SYSTEM_LOADING_DATA = 16;
--    NOT_BOSS_STAGE = 17;
--    IS_IN_CD_TIME = 18;
--    BOSS_IS_DEAD = 19;
--    NEED_MORE_TOKEN = 20;
--    CARD_POS_ERROR = 21;
--    NOT_RANK_TARGET = 22;
--    ACTIVITY_STAGE_NOT_OPEN = 23;
--    ENTER_CD = 24;
--    PVP_TARGET_PROTECT = 25;
--  }
----  required FightReqError  error = 1;
----  optional FightMapInfo   info = 2;
--  
       echo("onCheckPVPFightResult",msg.error,msg.info.fightType)
       
       if msg.error == "NOT_FOUND_PVP_TARGET" then
          Toast:showString(GameData:Instance():getCurrentScene(),_tr("not_found_pvp_target"), ccp(display.cx, display.cy))
       end
       
       if msg.info.fightType == "PVP_NORMAL" then
       _hideLoading()
           echo("onCheckPVPFightResult",msg.error)
           if msg.error == "NO_ERROR_CODE" then
              self:getDelegate():startPvpBattle(msg,self._isChallenge)
           elseif msg.error == "NEED_MORE_TOKEN" then
              Toast:showString(GameData:Instance():getCurrentScene(),_tr("need_more_token"), ccp(display.cx, display.cy))
           elseif msg.error == "NOT_RANK_TARGET" then
              Toast:showString(GameData:Instance():getCurrentScene(),_tr("not_rank_target"), ccp(display.cx, display.cy))
           elseif msg.error == "PVP_TARGET_PROTECT" then
              Toast:showString(GameData:Instance():getCurrentScene(),_tr("pvp_target_protect"), ccp(display.cx, display.cy))
           else
              echo("onCheckPVPFightResult",msg.error)
              --Toast:showString(GameData:Instance():getCurrentScene(),msg.error, ccp(display.cx, display.cy))
           end
       end
       
       self._isChallenge = false
       
end


function Expedition:parsePvpDataSyncCommon(common)
    --reset self's data
    if self:getSelfPvpBaseData() == nil then
       local mSelfData =  PVPBaseData.new(common.base)
       self:setSelfPvpBaseData(mSelfData)
    else
       self:getSelfPvpBaseData():updateMsg(common.base)
    end 
    
    if common.enemys ~= nil and table.getn(common.enemys) > 0 then
        local enemysArr = self:getEnemys()
        for key, enemy in pairs(common.enemys) do
             local playerId = enemy.base.player
             if enemy.op == "OP_ADD" then
                local pvpData = PVPBaseData.new(enemy.base)
                table.insert(enemysArr,pvpData)
             elseif  enemy.op == "OP_UPDATE" then
                for key, nEnemy in pairs(enemysArr) do
                  if nEnemy:getPlayerId() == playerId then
                     nEnemy:updateMsg(enemy.base)
                     break
                  end
                end
             elseif  enemy.op == "OP_REMOVE" then
                for i = 1, table.getn(enemysArr) do
                  if enemysArr[i]:getPlayerId() == playerId then
                     table.remove(enemysArr,i)
                     break
                  end
                end
             else
             
             end
        end
        self:setEnemys(enemysArr)
     end
    
     if common.reports ~= nil and table.getn(common.reports) > 0 then
         local reportsArr = self:getReports()
         if reportsArr == nil then
            reportsArr = {}
            self:setReports(reportsArr)
         end
         
         for key, report in pairs(common.reports) do
             if report.op == "OP_ADD" then
                 local battleReport = BattleReport.new(report.report)
                 table.insert(reportsArr,battleReport)
                 if battleReport:getAttacker():getPlayerId() == self:getSelfPvpBaseData():getPlayerId() then
                    self:setAttackReport(battleReport)
                 else
                    self:setHasNewReport(true)
                    GameData:Instance():getCurrentScene():getBottomBlock():updateBottomTip(2)
                 end
                 
             elseif  report.op == "OP_UPDATE" then
                 --self:setHasNewReport(true)
                 --GameData:Instance():getCurrentScene():getBottomBlock():updateBottomTip(2)
             elseif  report.op == "OP_REMOVE" then
             
             else
             
             end
         end
         self:setReports(reportsArr)
         
     end
    
    --common.reset_target     ?????bool
      
     
     if common.awards ~= nil and table.getn(common.awards) > 0 then
         local awardsArr = self:getAwards()
         for key, award in pairs(common.awards) do
             --print("~~~~~~~~~~~~~~award update:",award.op,award.award.rank,award.award.chance)
             if award.op == "OP_ADD" then
                 local awardData = Award.new(award.award)
                 table.insert(awardsArr,awardData)
             elseif  award.op == "OP_UPDATE" then
                 for key, nAward in pairs(awardsArr) do
                  if nAward:getRank() == award.award.rank then
                     nAward:updateMsg(award.award)
                     break
                  end
                end
             elseif  award.op == "OP_REMOVE" then
                 for j = 1, table.getn(awardsArr) do
                  if awardsArr[j]:getRank() == award.award.rank then
                     table.remove(awardsArr,j)
                     break
                  end
                end
             else
             
             end
        end
        self:setAwards(awardsArr)
     end
     -- set keepAward
     self:setKeepAward(common.keepAward)
     
     if self:getDelegate() ~= nil and self:getDelegate():getView() ~= nil then
        self:getDelegate():getView():updateView(false)
     end
end

function Expedition:checkHasAward()
  --[[local awardRank = 1
  local hasRankAward = false
  local awards = self:getAwards()
  for key, m_award in pairs(awards) do
      if m_award:getChance() == true then
         awardRank = m_award:getRank()
         hasRankAward = true
         break
      end
      awardRank = m_award:getRank()
  end
  ]]
  
  
  --new rule
  if not self:getSelfPvpBaseData() then
    return false,1
  end
  
  local lastReceiveTime = self:getSelfPvpBaseData():getAwardTime()
  local curTime = Clock:Instance():getCurServerUtcTime() 
  local time = toint(os.date("%H",lastReceiveTime))*3600+ toint(os.date("%M",lastReceiveTime))*60+toint(os.date("%S",lastReceiveTime))
  local difTimes = curTime - lastReceiveTime 
  
  local hasRankAward = (time + difTimes > 86400 and self:getSelfPvpBaseData():getScore() > 0)
  local awardRank= self:getSelfPvpBaseData():getRank()
  return hasRankAward,awardRank
end

------
--  Getter & Setter for
--      Expedition._AttackReport 
-----
function Expedition:setAttackReport(AttackReport)
	self._AttackReport = AttackReport
end

function Expedition:getAttackReport()
	return self._AttackReport
end

function Expedition:onPVPFightResultS2C(action,msgId,msg)
  printf("Expedition:onPVPFightResultS2C")
--  required PVPDataSyncCommon common = 1;
--  required int32 reportId = 2;
--  optional ClientSync client = 4;
--  optional int32 stopKeepWin = 5;
    self:parsePvpDataSyncCommon(msg.common)
    self:setStopKeepWin(msg.stopKeepWin)
    if msg.client ~= nil then
       self:setFightResultClientSync(msg.client)
       --GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)
    end
    self:reqRanks()
end

------
--  Getter & Setter for
--      Expedition._StopKeepWin 
-----
function Expedition:setStopKeepWin(StopKeepWin)
	self._StopKeepWin = StopKeepWin
end

function Expedition:getStopKeepWin()
	return self._StopKeepWin
end

------
--  Getter & Setter for
--      Expedition._FightResultClientSync 
-----
function Expedition:setFightResultClientSync(FightResultClientSync)
	self._FightResultClientSync = FightResultClientSync
end

function Expedition:getFightResultClientSync()
	return self._FightResultClientSync
end

function Expedition:reqPVPAwardC2S(awardRankNumber)  --领取PVP相关奖励
  --required AwardType type = 1;
  --optional int32     rank = 2;  // 领取阶段奖励的时候，才有奖励
  
  local msgData = {}
  if awardRankNumber ~= nil then
     msgData = { type = "RANK_AWARD",rank = awardRankNumber}
     echo("reqAward: RANK_AWARD  ",awardRankNumber)
  else
     msgData = { type = "KEEP_WIN_AWARD"}
     echo("reqAward: KEEP_WIN_AWARD")
  end
  
  --new rule
  msgData = { type = "DAY_WIN_AWARD"}
  
  local data = PbRegist.pack(PbMsgId.PVPAwardC2S,msgData)
  net.sendMessage(PbMsgId.PVPAwardC2S,data)
end

function Expedition:onPVPAwardResultS2C(action,msgId,msg)
    echo("onPVPAwardResultS2C:",msg.error)
    if msg.error == "NO_ERROR_CODE" then
        --show gained items
        local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client)
        for i = 1,table.getn(gainItems) do
          echo("----gained:", gainItems[i].configId, gainItems[i].count)
          local str = string.format("+%d", gainItems[i].count)
          Toast:showIconNumWithDelay(str, gainItems[i].iconId, gainItems[i].iType, gainItems[i].configId, ccp(display.width/2,display.height*0.5-i*40), 0.3*(i-1))
        end

       GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)
       self:parsePvpDataSyncCommon(msg.common)
--       if self:getDelegate() ~= nil then
--          Toast:showString(GameData:Instance():getCurrentScene(),"领取成功！", ccp(display.cx, display.cy))
--       end
       self:getDelegate():getView():updateView(false)
    else
       if self:getDelegate() ~= nil then
          self:getDelegate():getView():updateView(false)
          Toast:showString(GameData:Instance():getCurrentScene(),_tr("get_award_faild"), ccp(display.cx, display.cy))
       end
    end
end

--PVPQueryDataC2S
function Expedition:reqPVPQueryDataC2S(isForceReq)  --请求玩家的PVP信息
  if isForceReq == nil then
    isForceReq = false
  end
  if isForceReq == false then
    if self:getPVPQueryFlag() == true then
      return
    end
  end
  local data = PbRegist.pack(PbMsgId.PVPQueryDataC2S)
  net.sendMessage(PbMsgId.PVPQueryDataC2S,data)
end

------
--  Getter & Setter for
--      Expedition._PVPQueryFlag 
-----
function Expedition:setPVPQueryFlag(PVPQueryFlag)
	self._PVPQueryFlag = PVPQueryFlag
end

function Expedition:getPVPQueryFlag()
	return self._PVPQueryFlag
end

------
--  Getter & Setter for
--      Expedition._SeasonChangeTime 
-----
function Expedition:setSeasonChangeTime(SeasonChangeTime)
	self._SeasonChangeTime = SeasonChangeTime
end

function Expedition:getSeasonChangeTime()
	return self._SeasonChangeTime
end

function Expedition:onPVPQueryDataResultS2C(action,msgId,msg)
--  optional PVPData      selfData        = 1; //基础数据
--          message PVPData{
--            required PVPBaseData      base    = 1;  //基础数据
--            repeated PVPBaseData      enemys  = 2;  //仇人数据
--            repeated PVPReport        reports = 3;  //战报数据
--            repeated PVPAward         awards  = 4;  //领取奖励数据
--            optional PVPTarget        target  = 5;  //目标信息
--            optional int32          keepAward = 6;  //连胜奖励
--            optional int32      season  = 7;  //赛季结束时间
--          }

--  repeated PVPBaseData  heroRank        = 2; //最强王者
--  repeated PVPBaseData  popularityRank  = 3; //风云榜单
--  repeated PVPBaseData  keepWinRank     = 4; //连胜榜

  --set self's data
  local mSelfData =  PVPBaseData.new(msg.selfData.base)
  self:setSelfPvpBaseData(mSelfData)
  
  
  --set enemys
  local enemys = {}
  for key, pvpBaseData in pairs(msg.selfData.enemys) do
  	local pvpData = PVPBaseData.new(pvpBaseData)
  	table.insert(enemys,pvpData)
  end
  self:setEnemys(enemys)
  
  --set reports
  local reports = {}
  for key, report in pairs(msg.selfData.reports) do
    local battleReport = BattleReport.new(report)
    table.insert(reports,battleReport)
  end
  self:setReports(reports)
  
  --set awards
  local awards = {}
  for key, award in pairs(msg.selfData.awards) do
    local awardData = Award.new(award)
    table.insert(awards,awardData)
  end
  self:setAwards(awards)
  
  --echo("PVPTARGET:",msg.selfData.target.base.player)
  --set pvp target
   local pvpTarget =  PVPBaseData.new(msg.selfData.target.base)
   local pvpTatgetCards = {}
--   msg.selfData.target.cards.card_pos.config
--   msg.selfData.target.cards.card_pos.pos
--   msg.selfData.target.cards.card_pos.card
   for key, card in pairs(msg.selfData.target.cards.card_pos) do
   	  local cardMode = Card.new()
   	  cardMode:setId(card.card)
   	  cardMode:initAttrById(card.config)
   	  cardMode:setPosition(card.pos)
   	  table.insert(pvpTatgetCards,cardMode)
   	  echo("pvpTarget's card:",cardMode:getName())
   end
   pvpTarget:setCards(pvpTatgetCards)
   self:setPvpTarget(pvpTarget)
   
   -- set keepAward
   self:setKeepAward(msg.selfData.keepAward)
   
   --set hero Rank
   local heroRanks = {}
   for key, heroRank in pairs(msg.heroRank) do
      local heroData = PVPBaseData.new(heroRank)
   	  table.insert(heroRanks,heroData)
   end
   self:setHeroRanks(heroRanks)
   
   --set popularityRank
   local popularityRanks = {}
    for key, popularityRank in pairs(msg.popularityRank) do
      local popularityRankData = PVPBaseData.new(popularityRank)
      table.insert(popularityRanks,popularityRankData)
   end
   self:setPopularityRanks(popularityRanks)
   
   --set keepWinRank
    local keepWinRanks = {}
    for key, keepWinRank in pairs(msg.keepWinRank) do
      local keepWinRankData = PVPBaseData.new(keepWinRank)
      table.insert(keepWinRanks,keepWinRankData)
   end
   self:setKeepWinRanks(keepWinRanks)
   
   self:setSeasonChangeTime(msg.selfData.season)
   
   if self:getDelegate() ~= nil and self:getDelegate():getView() ~= nil then
      self:getDelegate():getView():updateView(false)
   end
   
   self:setPVPQueryFlag(true)
   
end

------
--  Getter & Setter for
--      Expedition._IsRankChanged 
-----
function Expedition:setIsRankChanged(IsRankChanged)
	self._IsRankChanged = IsRankChanged
end

function Expedition:getIsRankChanged()
	return self._IsRankChanged
end

function Expedition:setAwards(Awards)
	self._Awards = Awards
end

function Expedition:getAwards()
	return self._Awards
end

function Expedition:setPvpTarget(PvpTarget) --PvpTarget
	self._PvpTarget = PvpTarget
end

function Expedition:getPvpTarget()
	return self._PvpTarget
end

function Expedition:setHeroRanks(HeroRank)
	self._HeroRank = HeroRank
end

function Expedition:getHeroRanks()
	return self._HeroRank
end


------
--  Getter & Setter for
--      Expedition._KingRanks 
-----
function Expedition:setKingRanks(KingRanks)
	self._KingRanks = KingRanks
end

function Expedition:getKingRanks()
	return self._KingRanks
end


function Expedition:setPopularityRanks(PopularityRanks)
	self._PopularityRanks = PopularityRanks
end

function Expedition:getPopularityRanks()
	return self._PopularityRanks
end

function Expedition:setKeepWinRanks(KeepWinRanks)
	self._KeepWinRanks = KeepWinRanks
end

function Expedition:getKeepWinRanks()
	return self._KeepWinRanks
end

function Expedition:setSelfPvpBaseData(SelfPvpBaseData) --基础数据
	self._SelfPvpBaseData = SelfPvpBaseData
end

function Expedition:getSelfPvpBaseData()
	return self._SelfPvpBaseData
end

function Expedition:setKeepAward(KeepAward) -- 可领取的奖励
	self._KeepAward = KeepAward
end

function Expedition:getKeepAward()
	return self._KeepAward
end

function Expedition:setEnemys(Enemys) --仇人数据
	self._Enemys = Enemys
end

function Expedition:getEnemys()
	return self._Enemys
end

------
--  Getter & Setter for
--      Expedition._LastReport 
-----
function Expedition:setLastReport(LastReport)
	self._LastReport = LastReport
end

function Expedition:getLastReport()
	return self._LastReport
end

------
--  Getter & Setter for
--      Expedition._HasNewReport 
-----
function Expedition:setHasNewReport(HasNewReport)
	self._HasNewReport = HasNewReport
end

function Expedition:getHasNewReport()
	return self._HasNewReport
end

function Expedition:setReports(Reports) -- table 战报数据
	self._Reports = Reports
--	if self:getLastReport() ~= nil and self:getLastReport() ~= Reports[#Reports] then
--	   self:setHasNewReport(true)
--	   self:setLastReport(Reports[#Reports])
--	end
	
--	print(Reports[#Reports]:getAttacker():getPlayerName().."~~~~~~~~~~~~~~")
--	print(Reports[#Reports]:getDefender():getPlayerName().."~~~~~~~~~~~~~~")
end

function Expedition:getReports()
	return self._Reports
end

function Expedition:getRankByScore(score)
  local rank = 1
  for i = 1, #AllConfig.rank do
  	if score >= AllConfig.rank[i].min_point and score <= AllConfig.rank[i].max_point then
  	   rank = AllConfig.rank[i].sub_rank
  	   break
  	end
  end
  return rank
end

function Expedition:destory()
     self:stopTimeCountDown()
     --net.unregistAllCallback(self)
end

return Expedition