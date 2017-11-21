require("model.pvp_rank_match.RankMatchPlayer")
require("model.pvp_rank_match.RankMatchReport")
PvpRankMatch = class("PvpRankMatch")
function PvpRankMatch:ctor()
  self:setHasInited(false)
end

function PvpRankMatch:Instance()
  if PvpRankMatch._PvpRankMatchInstance == nil then
    PvpRankMatch._PvpRankMatchInstance = PvpRankMatch.new()
    PvpRankMatch._PvpRankMatchInstance:registNetSever()
  end
  return PvpRankMatch._PvpRankMatchInstance
end

function PvpRankMatch:init()
  self:reqPVPRankMatchQueryC2S()
  self:reqPVPRankMatchSearchC2S()
  self:reqRankInformation()
end

------
--  Getter & Setter for
--      PvpRankMatch._HasInited 
-----
function PvpRankMatch:setHasInited(HasInited)
	self._HasInited = HasInited
end

function PvpRankMatch:getHasInited()
	return self._HasInited
end

function PvpRankMatch:registNetSever()
  net.registMsgCallback(PbMsgId.PVPRankMatchQueryResultS2C,self,PvpRankMatch.onPVPRankMatchQueryResultS2C)
  net.registMsgCallback(PbMsgId.PVPRankMatchFightResultS2C,self,PvpRankMatch.onPVPRankMatchFightResultS2C)
  net.registMsgCallback(PbMsgId.PVPRankMatchSearchResultS2C,self,PvpRankMatch.onPVPRankMatchSearchResultS2C)
  net.registMsgCallback(PbMsgId.PVPRankMatchBuyCountResultS2C,self,PvpRankMatch.onPVPRankMatchBuyCountResultS2C)
  net.registMsgCallback(PbMsgId.PVPRankMatchSyncS2C,self,PvpRankMatch.onPVPRankMatchSyncS2C)
  net.registMsgCallback(PbMsgId.PVPRankMatchClearCDResultS2C,self,PvpRankMatch.onPVPRankMatchClearCDResultS2C)
  net.registMsgCallback(PbMsgId.FightErrorBS2CS,self,PvpRankMatch.onCheckRankMatchFightResult)
  
end

function PvpRankMatch:onPVPRankMatchSyncS2C(action,msgId,msg)
  --[[
  message PVPRankMatchSyncS2C{
  enum traits{ value = 5174;}
  required RankMatchBase self = 1;
  repeated RankMatchReport report = 2; 
  }]]
  local selfPlayer = self:getSelfPlayer()
  if selfPlayer == nil then
    selfPlayer = RankMatchPlayer.new(msg.self)
    self:setSelfPlayer(selfPlayer)
  else
    selfPlayer:update(msg.self)
  end
  
  if msg.report ~= nil then
    local reports = self:getRepotrs()
    for key, rankMatchReport in pairs(msg.report) do
      local report = RankMatchReport.new(rankMatchReport)
    	table.insert(reports,report)
    end
    self:setRepotrs(reports)
  end
  
  if selfPlayer:getRank() <= 3 then
    --请求刷新榜单
    self:reqRankInformation()
  end
  
  local targetPlayers = self:getTargetPlayers()
  if targetPlayers ~= nil and #targetPlayers < 3 then
    self:reqPVPRankMatchSearchC2S(false)
  end
  
end

--排位赛基础信息请求
function PvpRankMatch:reqPVPRankMatchQueryC2S()
  printf("reqPVPRankMatchQueryC2S")
  _showLoading()
  local data = PbRegist.pack(PbMsgId.PVPRankMatchQueryC2S)
  net.sendMessage(PbMsgId.PVPRankMatchQueryC2S,data)
end

--排位赛基础信息请求结果
function PvpRankMatch:onPVPRankMatchQueryResultS2C(action,msgId,msg)
  printf("onPVPRankMatchQueryResultS2C")
  --[[message PVPRankMatchQueryResultS2C{
  enum traits{value = 5161;}
  optional RankMatchBase self = 1;
  repeated RankMatchReport reports = 2;
  }]]
  _hideLoading()
  PvpRankMatch:Instance():setHasInited(true)
  local selfPlayer = self:getSelfPlayer()
  if selfPlayer == nil then
    selfPlayer = RankMatchPlayer.new(msg.self)
    self:setSelfPlayer(selfPlayer)
  else
    selfPlayer:update(msg.self)
  end
  
  local reports = {}
  for key, rankMatchReport in pairs(msg.reports) do
  	local report = RankMatchReport.new(rankMatchReport)
  	table.insert(reports,report)
  end
  self:setRepotrs(reports)
  
  self:updateView()
end

--排位赛搜索
function PvpRankMatch:reqPVPRankMatchSearchC2S(isShowLoading)
  printf("reqPVPRankMatchSearchC2S")
  
  if isShowLoading == nil then
    isShowLoading = true
  end
  if isShowLoading == true then
    _showLoading()
  end
  local data = PbRegist.pack(PbMsgId.PVPRankMatchSearchC2S)
  net.sendMessage(PbMsgId.PVPRankMatchSearchC2S,data)
end

--排位赛搜索结果
function PvpRankMatch:onPVPRankMatchSearchResultS2C(action,msgId,msg)
  printf("onPVPRankMatchSearchResultS2C")
  --[[
  message PVPRankMatchSearchResultS2C{
  enum traits{value = 5163;}
  repeated RankMatchBase targets = 1; //对手
  }
  ]]
  _hideLoading()
  local targetPlayers = {}
  for key, rankMatchBase in pairs(msg.targets) do
  	local player = RankMatchPlayer.new(rankMatchBase)
  	table.insert(targetPlayers,player)
  end
  self:setTargetPlayers(targetPlayers)
  self:updateView()
end

--排位赛战斗check请求
function PvpRankMatch:reqPVPRankMatchFightCheckC2S(targetPlayer)
  printf("reqPVPRankMatchFightCheckC2S: { target = "..targetPlayer:getId().." }")
  _showLoading()
  local data = PbRegist.pack(PbMsgId.PVPRankMatchFightCheckC2S,{ target = targetPlayer:getId() })
  net.sendMessage(PbMsgId.PVPRankMatchFightCheckC2S,data)
  self._targetPlayer = targetPlayer
end

function PvpRankMatch:onCheckRankMatchFightResult(action,msgId,msg)
  --[[  enum FightReqError{
    NO_ERROR_CODE = 0;
    CARD_NOT_FOUND= 1;
    CARD_NOT_ACTIVE = 2;
    CARD_EQUIP_NOT_FOUND = 3;
    CARD_EQUIP_ERROR = 4;
    TARGET_DATA_ERROR = 5;
    STAGE_NOT_FOUND = 6;
    LEVEL_NOT_ALLOW = 7;
    PRE_STAGE_NOT_COMPLETE = 8;
    NEED_MORE_SPIRIT = 9;
    SYSTEM_ERROR = 10;
    NOT_COMPLETE_STAR = 11;
    STAGE_CLOSE = 12;
    STAGE_TIME_CLOSE = 13;
    STAGE_NEED_MORE_CHANCE = 14;
    NOT_FOUND_PVP_TARGET = 15;
    SYSTEM_LOADING_DATA = 16;
    NOT_BOSS_STAGE = 17;
    IS_IN_CD_TIME = 18;
    BOSS_IS_DEAD = 19;
    NEED_MORE_TOKEN = 20;
    CARD_POS_ERROR = 21;
    NOT_RANK_TARGET = 22;
  ACTIVITY_STAGE_NOT_OPEN = 23;
  ENTER_CD = 24;
  PVP_TARGET_PROTECT = 25;
  
  RANK_MATCH_CD_TIME = 26;
  RANK_MATCH_NEED_CHANCE = 27;
  }
  required FightReqError  error = 1;
  optional FightMapInfo   info = 2;
  }]]

  echo("onCheckRankMatchFightResult",msg.error,msg.info.fightType)
  _hideLoading()
  if msg.info.fightType ~= "PVP_RANK_MATCH" then
    return
  end
  
  if msg.error == "NO_ERROR_CODE" then
    local battleController = ControllerFactory:Instance():create(ControllerType.BATTLE_CONTROLLER)
    battleController:enter()
    battleController:startPVPRankMatch(msg)
  else
    self._targetPlayer = nil
  end
end

--排位赛战斗开战请求
function PvpRankMatch:reqPVPRankMatchFightReqC2S(cards)
  _showLoading()
  printf("reqPVPRankMatchFightReqC2S: target = "..self._targetPlayer:getId())
  local data = PbRegist.pack(PbMsgId.PVPRankMatchFightReqC2S,{target = self._targetPlayer:getId(),cards = { card_pos = cards }})
  net.sendMessage(PbMsgId.PVPRankMatchFightReqC2S,data)
end

--排位赛战斗开战结果
function PvpRankMatch:onPVPRankMatchFightResultS2C(action,msgId,msg)
  printf("onPVPRankMatchFightResultS2C")
  self._targetPlayer = nil
  --[[message PVPRankMatchFightResultS2C{
  enum traits{value = 5164;}
  required RankMatchBase self = 1;
  required RankMatchReport report = 2; 
  optional PVPRankMatchSearchResultS2C target = 3; //对手
  }]]
  _hideLoading()
  local selfPlayer = self:getSelfPlayer()
  if selfPlayer == nil then
    selfPlayer = RankMatchPlayer.new(msg.self)
    self:setSelfPlayer(selfPlayer)
  else
    selfPlayer:update(msg.self)
  end
  
  local reports = self:getRepotrs()
  if msg.report ~= nil and reports ~= nil then
    local report = RankMatchReport.new(msg.report)
    table.insert(reports,report)
  end
  
  self:onPVPRankMatchSearchResultS2C(nil,nil,msg.target)
  
  if selfPlayer:getRank() <= 3 then
    --请求刷新榜单
    self:reqRankInformation()
  end
  
end

function PvpRankMatch:reqRankInformation()
   local data = PbRegist.pack(PbMsgId.RankInformationQueryC2S)
   net.sendMessage(PbMsgId.RankInformationQueryC2S,data)
end

function PvpRankMatch:reqPVPRankMatchBuyCountC2S(targetPlayer)
  printf("reqPVPRankMatchBuyCountC2S")
  self._targetPlayer = targetPlayer
  _showLoading()
  local data = PbRegist.pack(PbMsgId.PVPRankMatchBuyCountC2S)
  net.sendMessage(PbMsgId.PVPRankMatchBuyCountC2S,data)
  
end

function PvpRankMatch:onPVPRankMatchBuyCountResultS2C(action,msgId,msg)
  printf("onPVPRankMatchBuyCountResultS2C:"..msg.error)
  --[[message PVPRankMatchBuyCountResultS2C{
  enum traits{value = 5170;}
  enum ErrorCode{
    NO_ERROR_CODE = 1;
    HAS_CHANCE = 2;
    NEED_MORE_MONEY = 3;
    SYSTEM_ERROR = 99;
  }
  required ErrorCode error = 1;
  optional RankMatchBase base = 2;
  optional ClientSync client = 3;]]
  _hideLoading()
  if msg.error == "NO_ERROR_CODE" then
    local selfPlayer = self:getSelfPlayer()
    if selfPlayer == nil then
      selfPlayer = RankMatchPlayer.new(msg.base)
      self:setSelfPlayer(selfPlayer)
    else
      selfPlayer:update(msg.base)
    end
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)
    self:updateView()
    
    if self._targetPlayer ~= nil then
      self:reqPVPRankMatchFightCheckC2S(self._targetPlayer)
    end
    
  else
    
  end
  
end

function PvpRankMatch:reqPVPRankMatchClearCDC2S(targetPlayer)
   printf("reqPVPRankMatchClearCDC2S")
   self._targetPlayer = targetPlayer
   _showLoading()
   local data = PbRegist.pack(PbMsgId.PVPRankMatchClearCDC2S)
   net.sendMessage(PbMsgId.PVPRankMatchClearCDC2S,data)
end

function PvpRankMatch:onPVPRankMatchClearCDResultS2C(action,msgId,msg)
  --[[
  message PVPRankMatchClearCDResultS2C{
  enum traits{value = 5168;}
  enum ErrorCode{
    NO_ERROR_CODE = 1;
    NOT_HAS_CD = 2;
    NEED_MORE_MONEY = 3;
    NOT_HAS_CHANCE = 4;
    SYSTEM_ERROR = 99;
  }
  required ErrorCode error = 1;
  optional RankMatchBase base = 2;
  optional ClientSync client = 3;
  }]]
  printf("onPVPRankMatchClearCDResultS2C:"..msg.error)
  _hideLoading()
  if msg.error == "NO_ERROR_CODE" then
    local selfPlayer = self:getSelfPlayer()
    if selfPlayer == nil then
      selfPlayer = RankMatchPlayer.new(msg.base)
      self:setSelfPlayer(selfPlayer)
    else
      selfPlayer:update(msg.base)
    end
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)
    self:updateView()
    
    if self._targetPlayer ~= nil then
      self:reqPVPRankMatchFightCheckC2S(self._targetPlayer)
    end
  end
end

------
--  Getter & Setter for
--      PvpRankMatch._TargetPlayers 
-----
function PvpRankMatch:setTargetPlayers(TargetPlayers)
	self._TargetPlayers = TargetPlayers
end

function PvpRankMatch:getTargetPlayers()
	return self._TargetPlayers
end

------
--  Getter & Setter for
--      PvpRankMatch._SelfPlayer 
-----
function PvpRankMatch:setSelfPlayer(SelfPlayer)
	self._SelfPlayer = SelfPlayer
end

function PvpRankMatch:getSelfPlayer()
	return self._SelfPlayer
end

------
--  Getter & Setter for
--      PvpRankMatchView._View 
-----
function PvpRankMatch:setView(View)
	self._View = View
end

function PvpRankMatch:getView()
	return self._View
end

function PvpRankMatch:updateView()
  if self:getView() ~= nil then
    self:getView():updateView()
  end
end

------
--  Getter & Setter for
--      PvpRankMatch._Repotrs 
-----
function PvpRankMatch:setRepotrs(Repotrs)
	self._Repotrs = Repotrs
end

function PvpRankMatch:getRepotrs()
	return self._Repotrs
end

------
--  Getter & Setter for
--      PvpRankMatch._ReportListContentOffset 
-----
function PvpRankMatch:setReportListContentOffset(ReportListContentOffset)
	self._ReportListContentOffset = ReportListContentOffset
end

function PvpRankMatch:getReportListContentOffset()
	return self._ReportListContentOffset
end

return PvpRankMatch