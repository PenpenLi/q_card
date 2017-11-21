require("model.guild.GuildMember")
GuildBase = class("GuildBase")
function GuildBase:ctor(msg)
  self:setId(0)
  self:setName("")
  self:setLevel(1)
  self:setFlag(0)
  self:setNotice("")
  self:setAdNotice("")
  self:setExp(0)
  self:setCoin(0)
  self:setMoney(0)
  self:setCreateTime(0)
  self:setCreater(0)
  self:setApplyLevel(0)
  

  local members = {}
  self:setMembers(members)
  self:setApplyMembers({})
  self:update(msg)
end

function GuildBase:update(msg)
  if msg == nil then
    return
  end
  
  --guild base
  self:setId(msg.guild_id)
  self:setName(msg.guild_name)
  self:setLevel(msg.guild_level)
  self:setFlag(msg.guild_flag)
  self:setNotice(msg.guild_notice)
  self:setAdNotice(msg.guild_notice)
  self:setExp(msg.guild_exp)
  self:setCoin(msg.guild_coin)
  self:setMoney(msg.guild_money)
  self:setCreateTime(msg.guild_create)
  self:setCreater(msg.guild_creater)
  self:setApplyLevel(msg.guild_apply)
  
--  --members
--  local members = {}
--  for key, memberId in ipairs(msg.members) do
--  	local member = GuildMember.new(memberInfo)
--  	members[key] = member
--  end
--  self:setMembers(members)
end

function GuildBase:getMemberById(memberId)
  local targetMember = nil
  for key, member in ipairs(self:getMembers()) do
    if memberId == member:getPlayerId() then
      targetMember = member
      break
    end
  end
	return targetMember
end

function GuildBase:getApplyMemberById(memberId)
  local targetMember = nil
  for key, member in ipairs(self:getApplyMembers()) do
    if memberId == member:getId() then
      targetMember = member
      break
    end
  end
  return targetMember
end

------
--  Getter & Setter for
--      GuildBase._ApplyMembers 
-----
function GuildBase:setApplyMembers(ApplyMembers)
	self._ApplyMembers = ApplyMembers
end

function GuildBase:getApplyMembers()
	return self._ApplyMembers
end

------
--  Getter & Setter for
--      GuildBase._Id 
-----
function GuildBase:setId(Id)
	self._Id = Id
end

function GuildBase:getId()
	return self._Id
end

------
--  Getter & Setter for
--      GuildBase._Name 
-----
function GuildBase:setName(Name)
	self._Name = Name
end

function GuildBase:getName()
	return self._Name
end

------
--  Getter & Setter for
--      GuildBase._Level 
-----
function GuildBase:setLevel(Level)
	self._Level = Level
end

function GuildBase:getLevel()
	return self._Level
end

------
--  Getter & Setter for
--      GuildBase._Members 
-----
function GuildBase:setMembers(Members)
	self._Members = Members
end

function GuildBase:getMembers()
	return self._Members
end

------
--  Getter & Setter for
--      GuildBase._Flag 
-----
function GuildBase:setFlag(Flag)
	self._Flag = Flag
end

function GuildBase:getFlag()
	return self._Flag
end

------
--  Getter & Setter for
--      GuildBase._Notice 
-----
function GuildBase:setNotice(Notice)
	self._Notice = Notice
end

function GuildBase:getNotice()
	return self._Notice
end

------
--  Getter & Setter for
--      GuildBase._AdNotice 
-----
function GuildBase:setAdNotice(AdNotice)
	self._AdNotice = AdNotice
end

function GuildBase:getAdNotice()
	return self._AdNotice
end

------
--  Getter & Setter for
--      GuildBase._Exp 
-----
function GuildBase:setExp(Exp)
	self._Exp = Exp
end

function GuildBase:getExp()
	return self._Exp
end

------
--  Getter & Setter for
--      GuildBase._Coin 
-----
function GuildBase:setCoin(Coin)
	self._Coin = Coin
end

function GuildBase:getCoin()
	return self._Coin
end

------
--  Getter & Setter for
--      GuildBase._Money 
-----
function GuildBase:setMoney(Money)
	self._Money = Money
end

function GuildBase:getMoney()
	return self._Money
end

------
--  Getter & Setter for
--      GuildBase._CreateTime 
-----
function GuildBase:setCreateTime(CreateTime)
	self._CreateTime = CreateTime
end

function GuildBase:getCreateTime()
	return self._CreateTime
end

------
--  Getter & Setter for
--      GuildBase._Creater 
-----
function GuildBase:setCreater(Creater)
	self._Creater = Creater
end

function GuildBase:getCreater()
	return self._Creater
end

------
--  Getter & Setter for
--      GuildBase._ApplyLevel 
-----
function GuildBase:setApplyLevel(ApplyLevel)
	self._ApplyLevel = ApplyLevel
end

function GuildBase:getApplyLevel()
	return self._ApplyLevel
end

return GuildBase