require("model.PlayerRelation")
GuildMember = class("GuildMember",PlayerRelation)
function GuildMember:ctor(pbMsg)
  GuildMember.super.ctor(self)
  self:updateGuildMember(pbMsg)
end

function GuildMember:updateGuildMember(pbMsg)
  --[[message GuildMember{
  enum GUILD_JOB{
    CHAIRMAN  = 1;      //会长
    VICE_CHAIRMAN = 2;    //副会长
    ELITE = 3;        //精英
    ORDINARY = 4;     //普通 
  };
  enum GUILD_AUTHORITY{
    SET_VICE_CHAIRMAN = 1;    //设置副会长
    SET_DECLARATION = 2;    //设置宣言
    ACCEPT_PENDING = 3;     //接受会员
    KICK_ORDINARY = 4;      //剔除会员
    INVITE_PENDING = 5;     //邀请成员
    BAN_CHAT = 6;       //禁言
  };
  required int32 player  = 1;       //玩家
  required GUILD_JOB job = 2;       //职位
  optional int32 point = 3;       //贡献度 (总贡献度 当前贡献度在玩家身上)
  optional int32 ban_chat = 4;      //禁言时间
  optional int32 join_time = 5;     //加入公会时间
  optional int32 donate_time = 6;     //上次捐献时间
  optional int32 guild_id = 7;      //所在公会Id
  }
  ]]
  if pbMsg == nil then
    return
  end
  self:setPlayerId(pbMsg.player)
  self:setJob(pbMsg.job)
  self:setPoint(pbMsg.point)
  self:setBanChat(pbMsg.ban_chat)
  self:setJoinTime(pbMsg.join_time)
  self:setDonateTime(pbMsg.donate_time)
  self:setGuildId(pbMsg.guild_id)
end

------
--  Getter & Setter for
--      GuildMember._GuildId 
-----
function GuildMember:setGuildId(GuildId)
	self._GuildId = GuildId
end

function GuildMember:getGuildId()
	return self._GuildId
end

------
--  Getter & Setter for
--      GuildMember._PlayerId 
-----
function GuildMember:setPlayerId(PlayerId)
	self._PlayerId = PlayerId
end

function GuildMember:getPlayerId()
	return self._PlayerId
end

------
--  Getter & Setter for
--      GuildMember._Job 
-----
function GuildMember:setJob(Job)
	self._Job = Job
  --[[CHAIRMAN  = 1;      //会长
  VICE_CHAIRMAN = 2;    //副会长
  ELITE = 3;        //精英
  ORDINARY = 4;     //普通 
  ]]
  self:setJobId(GuildConfig.MemberType[self._Job])
end

function GuildMember:getJob()
	return self._Job
end

------
--  Getter & Setter for
--      GuildMember._JobId 
-----
function GuildMember:setJobId(JobId)
	self._JobId = JobId
end

function GuildMember:getJobId()
	return self._JobId
end

------
--  Getter & Setter for
--      GuildMember._Point 
-----
function GuildMember:setPoint(Point)
	self._Point = Point
end

function GuildMember:getPoint()
	return self._Point
end

------
--  Getter & Setter for
--      GuildMember._BanChat 
-----
function GuildMember:setBanChat(BanChat)
	self._BanChat = BanChat
end

function GuildMember:getBanChat()
	return self._BanChat
end

------
--  Getter & Setter for
--      GuildMember._JoinTime 
-----
function GuildMember:setJoinTime(JoinTime)
	self._JoinTime = JoinTime
end

function GuildMember:getJoinTime()
	return self._JoinTime
end

------
--  Getter & Setter for
--      GuildMember._DonateTime 
-----
function GuildMember:setDonateTime(DonateTime)
	self._DonateTime = DonateTime
end

function GuildMember:getDonateTime()
	return self._DonateTime
end

return GuildMember