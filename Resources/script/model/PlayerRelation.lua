PlayerRelation = class("PlayerRelation")
function PlayerRelation:ctor(relation)
  self:updateRelation(relation)
end

function PlayerRelation:updateRelation(relation)
  if relation == nil then
    return
  end
  --[[ @PlayerFriends.proto
  message RelationData{

  enum MDOperator{
    op_init = 0;
    op_add = 1;
    op_update = 2;
    op_remove = 3;
  }

  optional int32  id = 1;
  optional string name = 2;
  optional int32  level = 3;
  optional int32  avatar = 4;
  optional bool   is_on_line=5;
 
  optional int32  vip_level = 6;         //VIP
    
  optional int32  minerIdlePos = 7;   //空闲的矿场位置
  optional int32  minerPosCount = 8;  // 总计矿场位置 
  optional int32  last_logout_time = 9; // 最后一次登录时间
  
  optional int32 fight_value = 10; //战斗力
  optional int32 vip_exp = 11;  //vip exp 
  optional FriendHelpInfo help_info = 12;
  }
  ]]
  self:setId(relation.id)
  self:setName(relation.name)
  self:setLevel(relation.level)
  self:setAvatar(relation.avatar)
  self:setIsOnLine(relation.is_on_line)
  self:setVipLevel(relation.vip_level)
  self:setMinerIdlePos(relation.minerIdlePos)
  self:setMinerPosCount(relation.minerPosCount)
  self:setLastLogoutTime(relation.last_logout_time)
  self:setFightValue(relation.id)
  self:setVipExp(relation.vip_exp)
  self:setHelpInfo(relation.help_info)
end

------
--  Getter & Setter for
--      PlayerRelation._Id 
-----
function PlayerRelation:setId(Id)
	self._Id = Id
end

function PlayerRelation:getId()
	return self._Id
end

------
--  Getter & Setter for
--      PlayerRelation._Name 
-----
function PlayerRelation:setName(Name)
	self._Name = Name
end

function PlayerRelation:getName()
	return self._Name
end

------
--  Getter & Setter for
--      PlayerRelation._Level 
-----
function PlayerRelation:setLevel(Level)
	self._Level = Level
end

function PlayerRelation:getLevel()
	return self._Level
end

------
--  Getter & Setter for
--      PlayerRelation._Avatar 
-----
function PlayerRelation:setAvatar(Avatar)
	self._Avatar = Avatar
end

function PlayerRelation:getAvatar()
	return self._Avatar
end

------
--  Getter & Setter for
--      PlayerRelation._IsOnLine 
-----
function PlayerRelation:setIsOnLine(IsOnLine)
	self._IsOnLine = IsOnLine
end

function PlayerRelation:getIsOnLine()
	return self._IsOnLine
end

------
--  Getter & Setter for
--      PlayerRelation._VipLevel 
-----
function PlayerRelation:setVipLevel(VipLevel)
	self._VipLevel = VipLevel
end

function PlayerRelation:getVipLevel()
	return self._VipLevel
end

------
--  Getter & Setter for
--      PlayerRelation._VipExp 
-----
function PlayerRelation:setVipExp(VipExp)
	self._VipExp = VipExp
end

function PlayerRelation:getVipExp()
	return self._VipExp
end

------
--  Getter & Setter for
--      PlayerRelation._MinerIdlePos 
-----
function PlayerRelation:setMinerIdlePos(MinerIdlePos)
	self._MinerIdlePos = MinerIdlePos
end

function PlayerRelation:getMinerIdlePos()
	return self._MinerIdlePos
end

------
--  Getter & Setter for
--      PlayerRelation._MinerPosCount 
-----
function PlayerRelation:setMinerPosCount(MinerPosCount)
	self._MinerPosCount = MinerPosCount
end

function PlayerRelation:getMinerPosCount()
	return self._MinerPosCount
end
------
--  Getter & Setter for
--      PlayerRelation._LastLogoutTime 
-----
function PlayerRelation:setLastLogoutTime(LastLogoutTime)
	self._LastLogoutTime = LastLogoutTime
end

function PlayerRelation:getLastLogoutTime()
	return self._LastLogoutTime
end

------
--  Getter & Setter for
--      PlayerRelation._FightValue 
-----
function PlayerRelation:setFightValue(FightValue)
	self._FightValue = FightValue
end

function PlayerRelation:getFightValue()
	return self._FightValue
end

------
--  Getter & Setter for
--      PlayerRelation._HelpInfo 
-----
function PlayerRelation:setHelpInfo(HelpInfo)
	self._HelpInfo = HelpInfo
end

function PlayerRelation:getHelpInfo()
	return self._HelpInfo
end

return PlayerRelation