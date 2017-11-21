require("model.expedition.PVPBaseData")
BattleReport = class("BattleReport")
function BattleReport:ctor(msg)

--message ReportResult{
--  required int32        source_attack  = 1;  //积分
--  required int32        source_defend  = 3;
--  required int32        result  = 2;  //战斗结果
-- optional int32        coin = 4; // 
-- optional int32        miner_coin = 5;//矿产
-- optional int32        talent_point = 6; //天赋点
--
--}                                                 <-----
--                                                        |
--                                                        |
--  required PVPBaseData  attacker      = 1;  //攻击方       |
--  required PVPBaseData  defender      = 2;  //防守方      |
--  required ReportResult result        = 3;  //结果   ___|
--  required int32        fightTime     = 4;  //战斗时间
--  optional int32    review_id     = 5;  //录像ID
--  optional int32    report_id     = 6;  //
    if msg ~= nil then
       self:updateMsg(msg)
    end
end

function BattleReport:updateMsg(msg)
  local attacker = self:getAttacker()
  if attacker == nil then
     attacker = PVPBaseData.new(msg.attacker)
     self:setAttacker(attacker)
  else
     attacker:updateMsg(msg.attacker)
  end
  
  local defender = self:getDefender()
  if defender == nil then
      defender = PVPBaseData.new(msg.defender)
      self:setDefender(defender)
  else
      defender:updateMsg(msg.defender)
  end
  
  self:setId(msg.report_id)
  self:setBattleResult(msg.result.result)
  self:setBattleAttackScore(msg.result.source_attack)
  self:setBattleDefendScore(msg.result.source_defend)
  self:setFightTime(msg.fightTime)
  self:setCoin(msg.result.coin)
  self:setMinerCoin(msg.result.miner_coin)
  self:setTelentPoint(msg.result.talent_point)
  self:setReviewId(msg.review_id)
end

------
--  Getter & Setter for
--      BattleReport._Id 
-----
function BattleReport:setId(Id)
	self._Id = Id
end

function BattleReport:getId()
	return self._Id
end

------
--  Getter & Setter for
--      BattleReport._ReviewId 
-----
function BattleReport:setReviewId(ReviewId)
  --assert(ReviewId ~= 0)
	self._ReviewId = ReviewId
end

function BattleReport:getReviewId()
	return self._ReviewId
end

------
--  Getter & Setter for
--      BattleReport._Coin 
-----
function BattleReport:setCoin(Coin)
	self._Coin = Coin
end

function BattleReport:getCoin()
	return self._Coin
end

------
--  Getter & Setter for
--      BattleReport._TelentPoint 
-----
function BattleReport:setTelentPoint(TelentPoint)
	self._TelentPoint = TelentPoint
end

function BattleReport:getTelentPoint()
	return self._TelentPoint
end

------
--  Getter & Setter for
--      BattleReport._MinerCoin 
-----
function BattleReport:setMinerCoin(MinerCoin)
	self._MinerCoin = MinerCoin
end

function BattleReport:getMinerCoin()
	return self._MinerCoin
end

function BattleReport:getAllCoin()
  echo("self:getMinerCoin():",self:getMinerCoin(),"self:getCoin():",self:getCoin())
	return self:getMinerCoin()  + self:getCoin()
end

function BattleReport:setFightTime(FightTime)
	self._FightTime = FightTime
end

function BattleReport:getFightTime()
	return self._FightTime
end

function BattleReport:setAttacker(Attacker)
	self._Attacker = Attacker
end

function BattleReport:getAttacker()
	return self._Attacker
end

function BattleReport:setDefender(Defender)
	self._Defender = Defender
end

function BattleReport:getDefender()
	return self._Defender
end

function BattleReport:setBattleResult(BattleResult)
--   WIN_LEVEL_1 = 2;
--    WIN_LEVEL_2 = 3;
--    WIN_LEVEL_3 = 4;
--    LOSE_LEVEL_1 = 5;
--    LOSE_LEVEL_2 = 6;
--    LOSE_LEVEL_3 = 7;
	self._BattleResult = BattleResult
	
end

function BattleReport:getBattleResult()
	return self._BattleResult
end

function BattleReport:setBattleAttackScore(BattleAttackScore)
	self._BattleAttackScore = BattleAttackScore
end

function BattleReport:getBattleAttackScore()
	return self._BattleAttackScore
end

function BattleReport:setBattleDefendScore(BattleDefendScore)
	self._BattleDefendScore = BattleDefendScore
end

function BattleReport:getBattleDefendScore()
	return self._BattleDefendScore
end


return BattleReport