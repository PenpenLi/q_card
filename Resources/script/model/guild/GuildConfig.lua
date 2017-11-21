GuildConfig =  {}

GuildConfig.MemberTypeChairman = "CHAIRMAN" --会长
GuildConfig.MemberTypeViceChairman = "VICE_CHAIRMAN" --副会长
GuildConfig.MemberTypeElite = "ELITE" --精英成员
GuildConfig.MemberTypeNormal = "ORDINARY" --普通成员

GuildConfig.MemberType = {}
GuildConfig.MemberType[GuildConfig.MemberTypeChairman] = 1
GuildConfig.MemberType[GuildConfig.MemberTypeViceChairman] = 2
GuildConfig.MemberType[GuildConfig.MemberTypeElite] = 3
GuildConfig.MemberType[GuildConfig.MemberTypeNormal] = 4

GuildConfig.FlagTypeColor = 1
GuildConfig.FlagTypeBoader = 2
GuildConfig.FlagTypeFlag = 3

--[[
 enum Action{
    _APPLY_ = 4;  //收人
    _CHANGE_ = 1;   //修改职位
    _KICK_ = 2;   //踢人
    _BAN_ = 3;    //禁言
  };
  ]]
GuildConfig.ActionApply = "_APPLY_"
GuildConfig.ActionChange = "_CHANGE_"
GuildConfig.ActionKick = "_KICK_"
GuildConfig.ActionBan = "_BAN_"

GuildConfig.GuildSyncTypeAdd = "_ADD_"
GuildConfig.GuildSyncTypeUpdate = "_UPDATE_"
GuildConfig.GuildSyncTypeRemove = "_REMOVE_"