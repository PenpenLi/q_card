ArenaPlayer = class("ArenaPlayer")
function ArenaPlayer:ctor(msg)
  self:setIsAttacker(false)
  self:update(msg)
end

function ArenaPlayer:update(msg)
  if msg == nil then
     return
  end
  
  --[[
  message PVPArenaBase{
  required int32 player   = 1;    //玩家ID
  optional int32 rank   = 2;    //分段
  optional int32 score  = 3;    //积分
  optional int32 keepWin  = 4;    //连胜
  optional int32 maxWin   = 5;    //最大连胜
  optional string name  = 6;    //玩家名字
  optional int32 search   = 7;    //搜索次数
  optional int32 level  = 8;    //等级
  optional int32 head  = 9;    //头像
  }
  ]]
  
  self:setId(msg.player)
  self:setName(msg.name)
  self:setKeepWin(msg.keepWin)
  self:setLevel(msg.level)
  self:setScore(msg.score)
  self:setMaxWin(msg.maxWin)
  self:setSearchTime(msg.search)
  self:setRank(msg.rank)
  self:setHeadId(msg.head)
  
end

------
--  Getter & Setter for
--      ArenaPlayer._Id 
-----
function ArenaPlayer:setId(Id)
	self._Id = Id
end

function ArenaPlayer:getId()
	return self._Id
end

------
--  Getter & Setter for
--      ArenaPlayer._Name 
-----
function ArenaPlayer:setName(Name)
	self._Name = Name
end

function ArenaPlayer:getName()
	return self._Name
end

------
--  Getter & Setter for
--      ArenaPlayer._Level 
-----
function ArenaPlayer:setLevel(Level)
	self._Level = Level
end

function ArenaPlayer:getLevel()
	return self._Level
end

------
--  Getter & Setter for
--      ArenaPlayer._HeadId 
-----
function ArenaPlayer:setHeadId(HeadId)
	self._HeadId = HeadId
end

function ArenaPlayer:getHeadId()
	return self._HeadId
end

------
--  Getter & Setter for
--      ArenaPlayer._SearchTime 
-----
function ArenaPlayer:setSearchTime(SearchTime)
	self._SearchTime = SearchTime
end

function ArenaPlayer:getSearchTime()
	return self._SearchTime
end

------
--  Getter & Setter for
--      ArenaPlayer._Rank 
-----
function ArenaPlayer:setRank(Rank)
	self._Rank = Rank
end

function ArenaPlayer:getRank()
	return self._Rank
end

------
--  Getter & Setter for
--      ArenaPlayer._Score 
-----
function ArenaPlayer:setScore(Score)
	self._Score = Score
end

function ArenaPlayer:getScore()
	return self._Score
end

------
--  Getter & Setter for
--      ArenaPlayer._KeepWin 
-----
function ArenaPlayer:setKeepWin(KeepWin)
	self._KeepWin = KeepWin
end

function ArenaPlayer:getKeepWin()
	return self._KeepWin
end

------
--  Getter & Setter for
--      ArenaPlayer._MaxWin 
-----
function ArenaPlayer:setMaxWin(MaxWin)
	self._MaxWin = MaxWin
end

function ArenaPlayer:getMaxWin()
	return self._MaxWin
end

------
--  Getter & Setter for
--      ArenaPlayer._IsAttacker 
-----
function ArenaPlayer:setIsAttacker(IsAttacker)
	self._IsAttacker = IsAttacker
end

function ArenaPlayer:getIsAttacker()
	return self._IsAttacker
end

return ArenaPlayer