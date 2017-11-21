PVPBaseData = class("PVPBaseData")
function PVPBaseData:ctor(msg)
--  required int32 player       = 1;  // id
--  optional int32 source       = 2;  // 积分
--  optional int32 attackSource = 3;  // 攻击积分
--  optional int32 defendSource = 4;  // 防守积分
--  optional int32 maxSource    = 5;  // 最大积分
--  optional int32 rank         = 6;  // 排名段
--  optional int32 keepWin      = 7;  // 连胜记录
--  optional int32 maxKeepWin   = 8;  // 最高连胜记录
--  optional int32 headId       = 9; // 头像
--  optional int32 exp          = 10; // 经验
--  optional string name        = 11; // 玩家名字
--  optional int32 protectTime  = 12; //免战时间
--  optional int32 dayScore    = 13; //当天积分
--  optional int32 award_time   = 14; //上次领取每日奖励时间
  self._Rank = 1
  self:setAllCoin(0)
  self:setTelentPoint(0)
  self:setProtectTime(0)
  self:setDailyScore(0)
  self:setAwardTime(0)
  if msg ~= nil then
    self:updateMsg(msg)
  end
end

function PVPBaseData:updateMsg(msg)
  self:setPlayerId(msg.player)
  self:setScore(msg.source)
  self:setAttackScore(msg.attackSource)
  self:setDefendScore(msg.defendSource)
  self:setMaxScore(msg.maxSource)
  self:setRank(msg.rank)
  self:setKeepWin(msg.keepWin)
  self:setMaxKeepWin(msg.maxKeepWin)
  self:setHeadId(msg.headId)
  self:setExp(msg.exp)
  self:setPlayerName(msg.name)
  self:setProtectTime(msg.protectTime)
  self:setDailyScore(msg.dayScore)
  self:setAwardTime(msg.award_time)
end

------
--  Getter & Setter for
--      PVPBaseData._AwardTime 
-----
function PVPBaseData:setAwardTime(AwardTime)
	self._AwardTime = AwardTime
end

function PVPBaseData:getAwardTime()
	return self._AwardTime
end

function PVPBaseData:setPlayerId(PlayerId)
	self._PlayerId = PlayerId
end

function PVPBaseData:getPlayerId()
	return self._PlayerId
end

function PVPBaseData:setPlayerName(PlayerName)
	self._PlayerName = PlayerName
end

function PVPBaseData:getPlayerName()
	return self._PlayerName
end

function PVPBaseData:setCards(Cards)
	self._Cards = Cards
end

function PVPBaseData:getCards()
  local cards = self._Cards
  if self._Cards == nil then
     cards = {}
  end
	return cards
end

------
--  Getter & Setter for
--      PVPBaseData._DailyScore 
-----
function PVPBaseData:setDailyScore(DailyScore)
	self._DailyScore = DailyScore
end

function PVPBaseData:getDailyScore()
	return self._DailyScore
end

function PVPBaseData:setScore(Score)
	self._Score = Score
end

function PVPBaseData:getScore()
	return self._Score
end

function PVPBaseData:setAttackScore(AttackScore)
	self._AttackScore = AttackScore
end

function PVPBaseData:getAttackScore()
	return self._AttackScore
end

function PVPBaseData:setDefendScore(DefendScore)
	self._DefendScore = DefendScore
end

function PVPBaseData:getDefendScore()
	return self._DefendScore
end

function PVPBaseData:setMaxScore(MaxScore)
	self._MaxScore = MaxScore
end

function PVPBaseData:getMaxScore()
	return self._MaxScore
end

function PVPBaseData:setRank(Rank)
  if GameData:Instance():getExpeditionInstance():getSelfPvpBaseData() ~= nil and self:getPlayerId() == GameData:Instance():getExpeditionInstance():getSelfPvpBaseData():getPlayerId() then
    local lastRank = self:getLastRank() or Rank
    if lastRank < Rank then
    GameData:Instance():getExpeditionInstance():setIsRankChanged(true)
    else
      self:setLastRank(Rank)
    end
  end
  self._Rank = Rank
end

function PVPBaseData:getRank()
	return self._Rank
end

------
--  Getter & Setter for
--      PVPBaseData._LastRank 
-----
function PVPBaseData:setLastRank(LastRank)
	self._LastRank = LastRank
end

function PVPBaseData:getLastRank()
	return self._LastRank
end

function PVPBaseData:setKeepWin(KeepWin)
	self._KeepWin = KeepWin
end

function PVPBaseData:getKeepWin()
	return self._KeepWin
end

function PVPBaseData:setMaxKeepWin(MaxKeepWin)
  --echo("MaxKeepWin:",self._MaxKeepWin)
	self._MaxKeepWin = MaxKeepWin
end

function PVPBaseData:getMaxKeepWin()
	return self._MaxKeepWin
end

function PVPBaseData:setHeadId(HeadId)
	local unitRoot = HeadId
  local picId = 0
  if unitRoot <= 1 then
     picId = 3012502
  else
     local cardConfigId = tonumber(unitRoot.."01")
     picId = AllConfig.unit[cardConfigId].unit_head_pic
  end
  self._HeadId = picId
end

function PVPBaseData:getHeadId()
	return self._HeadId
end

-- use for level 
function PVPBaseData:setExp(Exp)
	self._Exp = Exp
 -- echo("nowLEVEL:",self._Exp)
----  --echo("LEvel:",AllConfig.charlevel,table.getn(AllConfig.charlevel))
----  --100
----  --105
----  -- level    exp totalexp
----  -- 1    0   0
----  -- 2    100 100
----  -- 3    104 204
--  local level = 1
--  for i = 1, table.getn(AllConfig.charlevel) do
--    --echo("current Exp:",self._Exp,"needExp:",AllConfig.charlevel[i].exp)
--    if self._Exp < AllConfig.charlevel[i].totalexp then
--      level = i - 1
--      break
--    end
--  end
--  if level < 1 then
--     level = 1
--  end
  self:setLevel(self._Exp)

end

function PVPBaseData:getExp()
	return self._Exp
end

function PVPBaseData:setLevel(Level)
	self._Level = Level
end

function PVPBaseData:getLevel()
	return self._Level
end

------
--  Getter & Setter for
--      PVPBaseData._AllCoin 
-----
function PVPBaseData:setAllCoin(AllCoin)
	self._AllCoin = AllCoin
end

function PVPBaseData:getAllCoin()
	return self._AllCoin
end

------
--  Getter & Setter for
--      PVPBaseData._TelentPoint 
-----
function PVPBaseData:setTelentPoint(TelentPoint)
	self._TelentPoint = TelentPoint
end

function PVPBaseData:getTelentPoint()
	return self._TelentPoint
end

------
--  Getter & Setter for
--      PVPBaseData._ProtectTime 
-----
function PVPBaseData:setProtectTime(ProtectTime)
	self._ProtectTime = ProtectTime
end

function PVPBaseData:getProtectTime()
	return self._ProtectTime
end

return PVPBaseData