require("model.pvp_rank_match.RankMatchPlayer")
RankMatchReport = class("RankMatchReport")
function RankMatchReport:ctor(rankMatchReport)
  self:update(rankMatchReport)
end

function RankMatchReport:update(rankMatchReport)
  if rankMatchReport == nil then
    return
  end
  
  --[[
  message RankMatchServerReport{
  optional int32 report_id    = 8;  //战报ID
  optional int32 attacker     = 1;  //进攻方
  optional int32 defender     = 2;  //防守方
  optional int32 result       = 3;  //战斗结果
  optional int32 attacker_rank  = 4;  //进攻方排名
  optional int32 defender_rank  = 5;  //防守方排名
  optional int32 time       = 6;  //战斗时间
  optional int32 review_id    = 7;  //录像ID
  }

  message RankMatchReport{
  optional RankMatchBase  attacker  = 1;  //进攻方
  optional RankMatchBase  defender  = 2;  //防守方
  optional RankMatchServerReport content = 3;
  }]]
  
  local attacker = self:getAttacker()
  if attacker == nil then
    attacker = RankMatchPlayer.new(rankMatchReport.attacker)
    self:setAttacker(attacker)
  else
    attacker:update(rankMatchReport.attacker)
  end
  
  local defender = self:getDefender()
  if defender == nil then
    defender = RankMatchPlayer.new(rankMatchReport.defender)
    self:setDefender(defender)
  else
    defender:update(rankMatchReport.defender)
  end
  
  self:setId(rankMatchReport.content.report_id)
  self:setResult(rankMatchReport.content.result)
  self:setAttackerRank(rankMatchReport.content.attacker_rank)
  self:setDefenderRank(rankMatchReport.content.defender_rank)
  self:setFightTime(rankMatchReport.content.time)
  self:setReviewId(rankMatchReport.content.review_id)
end

------
--  Getter & Setter for
--      RankMatchReport._Id 
-----
function RankMatchReport:setId(Id)
	self._Id = Id
end

function RankMatchReport:getId()
	return self._Id
end

------
--  Getter & Setter for
--      RankMatchReport._Attacker 
-----
function RankMatchReport:setAttacker(Attacker)
	self._Attacker = Attacker
end

function RankMatchReport:getAttacker()
	return self._Attacker
end

------
--  Getter & Setter for
--      RankMatchReport._Defender 
-----
function RankMatchReport:setDefender(Defender)
	self._Defender = Defender
end

function RankMatchReport:getDefender()
	return self._Defender
end

------
--  Getter & Setter for
--      RankMatchReport._Result 
-----
function RankMatchReport:setResult(Result)
--    WIN_LEVEL_1 = 2;
--    WIN_LEVEL_2 = 3;
--    WIN_LEVEL_3 = 4;
--    LOSE_LEVEL_1 = 5;
--    LOSE_LEVEL_2 = 6;
--    LOSE_LEVEL_3 = 7;
	self._Result = Result
end

function RankMatchReport:getResult()
	return self._Result
end

------
--  Getter & Setter for
--      RankMatchReport._FightTime 
-----
function RankMatchReport:setFightTime(FightTime)
	self._FightTime = FightTime
end

function RankMatchReport:getFightTime()
	return self._FightTime
end

------
--  Getter & Setter for
--      RankMatchReport._ReviewId 
-----
function RankMatchReport:setReviewId(ReviewId)
	self._ReviewId = ReviewId
end

function RankMatchReport:getReviewId()
	return self._ReviewId
end

------
--  Getter & Setter for
--      RankMatchReport._AttackerRank 
-----
function RankMatchReport:setAttackerRank(AttackerRank)
	self._AttackerRank = AttackerRank
end

function RankMatchReport:getAttackerRank()
	return self._AttackerRank
end

------
--  Getter & Setter for
--      RankMatchReport._DefenderRank 
-----
function RankMatchReport:setDefenderRank(DefenderRank)
	self._DefenderRank = DefenderRank
end

function RankMatchReport:getDefenderRank()
	return self._DefenderRank
end

return RankMatchReport