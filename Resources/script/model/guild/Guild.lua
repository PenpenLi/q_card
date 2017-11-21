require("model.guild.GuildConfig")
require("model.guild.GuildBase")
require("model.guild.GuildStageInstance")
Guild = class("Guild")
function Guild:ctor()
  self:setGuildList({})
  self:setAppliedGuildsList({})
  self:setHasInited(false)
end

function Guild:isRightLength(str,maxLength)
  local isRightLength = false
  
  local len = 0
  local pos = 1
  local length = string.len(str)
  while true do
    local char = string.sub(str , pos , pos)

    local b = string.byte(char)
    if b >= 128 then
      pos = pos + 3
      len = len + 2
    elseif b < 128 and char >= 'A' and char <= 'Z' then
      pos = pos + 1
      len = len + 1.2
    else
      pos = pos + 1
      len = len + 1
    end
    if pos > length then
      break
    end
  end
  
  isRightLength = (len <= maxLength)

  return isRightLength
end

function Guild:Instance()
  if Guild._GuildInstance == nil then
    Guild._GuildInstance = Guild.new()
    Guild._GuildInstance:regirstNetServer()
  end
  return Guild._GuildInstance
end

function Guild:init()
  self:reqGuildQueryC2S()
end

------
--  Getter & Setter for
--      Guild._HasInited 
-----
function Guild:setHasInited(HasInited)
	self._HasInited = HasInited
end

function Guild:getHasInited()
	return self._HasInited
end

------
--  Getter & Setter for
--      Guild._TempFlagId 
-----
function Guild:setTempFlagId(TempFlagId)
	self._TempFlagId = TempFlagId
end

function Guild:getTempFlagId()
	return self._TempFlagId or 0
end

function Guild:getFlagIconByInt(flagInt)
  
  local iconCon = display.newNode()
  
  local boader = display.newSprite("#guild_guildflag_boader.png")
  iconCon:addChild(boader)
  
  if flagInt <= 10000 then
    local type1 = {}
    local type3 = {}
    local type2 = {}
    for key, var in pairs(AllConfig.guild_flag) do
      var._id = key
      if var.type == 1 then
       table.insert(type1,var)
      elseif var.type == 2 then
       table.insert(type2,var)
      elseif var.type == 3 then
       table.insert(type3,var)
      end
    end
    
    local icon1 = _res(AllConfig.guild_flag[type1[1]._id].color)
    iconCon:addChild(icon1)
    
    local icon2 = _res(AllConfig.guild_flag[type2[1]._id].color)
    iconCon:addChild(icon2)
    
    local icon3 = _res(AllConfig.guild_flag[type3[1]._id].color)
    iconCon:addChild(icon3)
    
    return iconCon,type1[1]._id,type2[1]._id,type3[1]._id
    
  end

  local flagStr = string.format("%06d",flagInt)
  print("flagStr:",flagStr)
  local res1Id = toint(string.sub(flagStr,1,2))
  print("res1Id:",res1Id)
  local icon1 = _res(AllConfig.guild_flag[res1Id].color)
  iconCon:addChild(icon1)
  
  local res2Id = toint(string.sub(flagStr,3,4))
  local icon2 = _res(AllConfig.guild_flag[res2Id].color)
  iconCon:addChild(icon2)
  
  local res3Id = toint(string.sub(flagStr,5,6))
  local icon3 = _res(AllConfig.guild_flag[res3Id].color)
  iconCon:addChild(icon3)
  return iconCon,res1Id,res2Id,res3Id
end

function Guild:getIsManagerByMember(guildMember)
  local isManager = false
  if guildMember ~= nil then
     if guildMember:getJob() == GuildConfig.MemberTypeChairman
     or guildMember:getJob() == GuildConfig.MemberTypeViceChairman
     then
       isManager = true
     end
  end
  return isManager
end

------
--  Getter & Setter for
--      Guild._SelfHaveGuild 
-----
function Guild:setSelfHaveGuild(SelfHaveGuild)
	self._SelfHaveGuild = SelfHaveGuild
end

function Guild:getSelfHaveGuild()
	return self._SelfHaveGuild
end

------
--  Getter & Setter for
--      Guild._SelfGuildBase 
-----
function Guild:setSelfGuildBase(SelfGuildBase)
  self._SelfGuildBase = SelfGuildBase
end

function Guild:getSelfGuildBase()
  return self._SelfGuildBase
end

------
--  Getter & Setter for
--      Guild._GuildStageInstance 
-----
function Guild:setGuildStageInstance(GuildStageInstance)
	self._GuildStageInstance = GuildStageInstance
end

function Guild:getGuildStageInstance()
	return self._GuildStageInstance
end

------
--  Getter & Setter for
--      Guild._GuildList 
-----
function Guild:setGuildList(GuildList)
	self._GuildList = GuildList
end

function Guild:getGuildList()
	return self._GuildList
end

function Guild:getGuildById(guildId)
  local guild = nil
  local idx = 1
	local guildList = self:getGuildList()
	for key, t_guild in pairs(guildList) do
		if t_guild:getId() == guildId then
		  guild = t_guild
		  idx = key
		  break
		end
	end
	return guild,idx
end

function Guild:regirstNetServer()
  net.registMsgCallback(PbMsgId.GuildChangeBaseResultS2C,self,Guild.onGuildChangeBaseResultS2C)
  net.registMsgCallback(PbMsgId.GuildQueryResultS2C,self,Guild.onGuildQueryResultS2C)
  net.registMsgCallback(PbMsgId.GuildChangeMemberResultS2C,self,Guild.onGuildChangeMemberResultS2C)
  net.registMsgCallback(PbMsgId.GuildCreateApplyResultS2C,self,Guild.onGuildCreateApplyResultS2C)
  net.registMsgCallback(PbMsgId.GuildCreateResultS2C,self,Guild.onGuildCreateResultS2C)
  net.registMsgCallback(PbMsgId.GuildDonateResultS2C,self,Guild.onGuildDonateResultS2C)
  net.registMsgCallback(PbMsgId.GuildLevelUpBuildResultS2C,self,Guild.onGuildLevelUpBuildResultS2C)
  net.registMsgCallback(PbMsgId.GuildOpenInstanceResultS2C,self,Guild.onGuildOpenInstanceResultS2C)
  net.registMsgCallback(PbMsgId.GuildQuitResultS2C,self,Guild.onGuildQuitResultS2C)
  net.registMsgCallback(PbMsgId.GuildSyncS2C,self,Guild.onGuildSyncS2C)
  net.registMsgCallback(PbMsgId.GuildListS2C,self,Guild.onGuildListS2C)
  net.registMsgCallback(PbMsgId.FightErrorBS2CS,self,Guild.onCheckFightResult)
  --net.registMsgCallback(PbMsgId.QueryPlayerShowResultS2C,self,Guild.onQueryPlayerShowResultS2C)
end

function Guild:onGuildListS2C(action,msgId,msg)
 --[[
  repeated GuildBase dismiss = 1;    //解散列表
  repeated GuildBase new_guild = 2; //新建列表
  ]]
  
  if msg.dismiss ~= nil  then
  	for key, dismissGuildBase in pairs(msg.dismiss) do
  		for key, guild in pairs(self:getGuildList()) do
  		  if dismissGuildBase.guild_id == guild:getId() then
  		    table.remove(self:getGuildList(),key)
  		  end
  		end
  	end
  end
  
  if msg.new_guild ~= nil then
    for key, guildBaseInfo in pairs(msg.new_guild) do
    	local guildBase = self:getGuildById(guildBaseInfo.guild_id)
      if guildBase == nil then
        guildBase = GuildBase.new(guildBaseInfo)
        print("guildBase.guild_id:",guildBaseInfo.guild_id)
        dump(guildBase)
        table.insert(self:getGuildList(),guildBase)
      else
        guildBase:update(guildBaseInfo)
      end
    end
  end
end

------
--  Getter & Setter for
--      Guild._AppliedGuildsList 
-----
function Guild:setAppliedGuildsList(AppliedGuildsList)
  self._AppliedGuildsList = AppliedGuildsList
end

function Guild:getAppliedGuildsList()
  return self._AppliedGuildsList
end

function Guild:reqGuildQueryC2S()
  _showLoading()
  local data = PbRegist.pack(PbMsgId.GuildQueryC2S)
  net.sendMessage(PbMsgId.GuildQueryC2S,data)
end

function Guild:onGuildQueryResultS2C(action,msgId,msg)
  _hideLoading()
  printf("Guild:onGuildQueryResultS2C")
  --[[
  repeated GuildBase guildlist = 1;
  optional bool flag = 2;
  optional GuildSync guild = 3;
  repeated int32 apply_guild = 4;
  ]]
  local guildList = {}
  for key, guildBaseMsg in ipairs(msg.guildlist) do
  	local guildBase = GuildBase.new(guildBaseMsg)
  	guildList[key] = guildBase
  end
  self:setGuildList(guildList)
  
  self:setSelfHaveGuild(msg.flag)
  self:setSelfGuildBase(nil)
  if msg.flag == true then
    self:parseGuildSync(msg.guild)
  end
  self:setHasInited(true)
  
  print("#msg.apply_guild:",#msg.apply_guild)
  local appliedGuildsList = {}
  for key, guildId in pairs(msg.apply_guild) do
  	appliedGuildsList[guildId] = guildId
  end
  self:setAppliedGuildsList(appliedGuildsList)
  
  self:updateView()
  
end

------
--  Getter & Setter for
--      Guild._GuildView 
-----
function Guild:setGuildView(GuildView)
	self._GuildView = GuildView
end

function Guild:getGuildView()
	return self._GuildView
end

function Guild:updateView(idx)
  printf("Guild:updateView()")
  local guildView = self:getGuildView()
  if guildView ~= nil then
    guildView:updateView(idx)
  end
end

function Guild:reqGuildChangeBaseC2S(guild_notice,guild_flag,apply_level,resultHandler)
  _showLoading()
  --[[
  optional string guild_notice = 1;
  optional int32 guild_flag = 2;
  optional int32 apply_level = 3;
  ]]
  
  assert(guild_notice ~= nil and guild_flag ~= nil)
  self._resultHandler = resultHandler
  local data = PbRegist.pack(PbMsgId.GuildChangeBaseC2S,{guild_notice = guild_notice,guild_flag = guild_flag,apply_level = apply_level})
  net.sendMessage(PbMsgId.GuildChangeBaseC2S,data)
end

function Guild:onGuildChangeBaseResultS2C(action,msgId,msg)
  _hideLoading()
  --[[
  enum ErrorCode{
    NO_ERROR_CODE = 1;
    AUTHORITY_LIMIT = 2;  //权限不够
    NOT_HAS_GUILD = 3;    //没有公会
    SYSTEM_ERROR = 99;
  };
  required ErrorCode error = 1;
  optional GuildSync sync = 2;
  ]]
  
  printf("Guild:onGuildChangeBaseResultS2C:"..msg.error)
  if msg.error == "NO_ERROR_CODE" then
    self:parseGuildSync(msg.sync)
    self:updateView()
    if self._resultHandler ~= nil then
      self._resultHandler()
    end
    
    Toast:showString(GameData:Instance():getCurrentScene(),_tr("save_success"), ccp(display.cx, display.cy))
  else
    self:toastError(msg.error)
  end
  
  self._resultHandler = nil
end


--修改公会成员（修改职位。允许加入， 踢人， 禁言等）
function Guild:reqGuildChangeMemberC2S(playerId,action,args,viewDelegate)
  --[[
  message GuildChangeMemberC2S{
  enum traits{value = 5180;}
  enum Action{
    _APPLY_ = 4;  //收人
    _CHANGE_ = 1;   //修改职位
    _KICK_ = 2;   //踢人
    _BAN_ = 3;    //禁言
  };
  required int32 player = 1;
  required Action action = 2;
  optional int32 args = 3; //参数 如果禁言是时间 如果是修改职位GuildMember.GUILD_JOB
  }]]
  _showLoading()
  self._guildChangeMemberViewDelegate = viewDelegate
  self._guildChangeMemberAction = action
  self._guildChangeMemberArgs = args
  printf("Guild:reqGuildChangeMemberC2S:playerId:"..playerId..",action:"..action..",args:"..args)
  local data = PbRegist.pack(PbMsgId.GuildChangeMemberC2S,{player = playerId,action = action,args = args})
  net.sendMessage(PbMsgId.GuildChangeMemberC2S,data)

end

function Guild:onGuildChangeMemberResultS2C(action,msgId,msg)
  --[[
  enum ErrorCode{
    NO_ERROR_CODE = 1;
    LEVEL_LIMIT = 2;    //等级不够
    AUTHORITY_LIMIT = 3;  //权限不够
    ARGS_ERROR = 4;     //参数错误
    NOT_FOUND_PLAYER = 5; //没有找到玩家
    PLAYER_HAS_JOIN = 6;  //玩家已经加入别的公会
    SYSTEM_ERROR = 99;
  };
  required ErrorCode error = 1;
  optional GuildSync sync = 2;
  ]]
  _hideLoading()
  printf("Guild:onGuildChangeMemberResultS2C:"..msg.error)
  if msg.error == "NO_ERROR_CODE" then
    self:parseGuildSync(msg.sync)
    if self._guildChangeMemberViewDelegate ~= nil then
      self._guildChangeMemberViewDelegate:updateView()
    end
    if self._guildChangeMemberAction == GuildConfig.ActionApply then
      local str = ""
      if self._guildChangeMemberArgs == 0 then
        str= _tr("reject_pass")
      elseif self._guildChangeMemberArgs == 1 then
        str= _tr("accept_pass")
      end
      Toast:showString(GameData:Instance():getCurrentScene(),str, ccp(display.cx, display.cy))
    end
    self:updateView()
  else
    self:toastError(msg.error)
  end
  self._guildChangeMemberViewDelegate = nil
  self._guildChangeMemberAction = nil
  self._guildChangeMemberArgs = nil
end

--申请加入公会
function Guild:reqGuildCreateApplyC2S(guild_id,guildItemview)
  printf("Guild:reqGuildCreateApplyC2S:guild_id:"..guild_id)
  _showLoading()
  self._applyGuildId = guild_id
  self._guildItemview = guildItemview
  local data = PbRegist.pack(PbMsgId.GuildCreateApplyC2S,{guild_id = guild_id})
  net.sendMessage(PbMsgId.GuildCreateApplyC2S,data)
end

function Guild:onGuildCreateApplyResultS2C(action,msgId,msg)
  printf("Guild:onGuildCreateApplyResultS2C:"..msg.error)
  _hideLoading()
  if msg.error == "NO_ERROR_CODE" then
    Guild:Instance():getAppliedGuildsList()[self._applyGuildId] = self._applyGuildId 
    if self._guildItemview ~= nil then
      self._guildItemview:updateView()
    end
    Toast:showString(GameData:Instance():getCurrentScene(),_tr("apply_has_passed"), ccp(display.cx, display.cy))
  elseif msg.error == "CONDITION_NOT_MATCH" then
    Toast:showString(GameData:Instance():getCurrentScene(),_tr("退会"..AllConfig.guild[1].reapply_time.."小时内无法进行申请操作"), ccp(display.cx, display.cy))
  else
    self:toastError(msg.error)
  end
  self._guildItemview = nil
end

function Guild:reqGuildCreateC2S(guild_name,guild_flag,guild_notice)
  _showLoading()
  printf("Guild:reqGuildCreateC2S:guild_name:"..guild_name..",guild_flag:"..guild_flag..",guild_notice:"..guild_notice)
  local data = PbRegist.pack(PbMsgId.GuildCreateC2S,{guild_name = guild_name,guild_flag = guild_flag,guild_notice = guild_notice})
  net.sendMessage(PbMsgId.GuildCreateC2S,data)
end

function Guild:onGuildCreateResultS2C(action,msgId,msg)
  _hideLoading()
  printf("Guild:onGuildCreateResultS2C:"..msg.error)
  --[[
  message GuildCreateResultS2C{
  enum traits{value = 5177;}
  enum ErrorCode{
    NO_ERROR_CODE = 1;
    NAME_ERROR = 2;   //公会名字错误
    LEVEL_LIMIT = 3;    //等级不够
    NOTICE_ERROR = 4;   //公告错误
    FLAG_ERROR = 5;   //旗帜错误
    NEED_MORE_MONEY = 6;//需要更多的钱
    HAS_GUILD = 7;    //有公会了
    SYSTEM_ERROR = 99;
  };
  required ErrorCode error = 1;
  optional GuildSync sync = 2;
  optional ClientSync client = 3;
  }
  ]]
  if msg.error == "NO_ERROR_CODE" then
    self:parseGuildSync(msg.sync)
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)
    self:updateView(0)
    Toast:showString(GameData:Instance():getCurrentScene(),_tr("guild_create_success"), ccp(display.cx, display.cy))
  else
    self:toastError(msg.error)
  end
end

--公会捐献
function Guild:reqGuildDonateC2S(type,donateView)
  printf("Guild:reqGuildDonateC2S:type:"..type)
  _showLoading()
  self._donateView = donateView
  local data = PbRegist.pack(PbMsgId.GuildDonateC2S,{type = type})
  net.sendMessage(PbMsgId.GuildDonateC2S,data)
end

function Guild:onGuildDonateResultS2C(action,msgId,msg)
  printf("Guild:onGuildDonateResultS2C:"..msg.error)  
  _hideLoading()
  --[[
  enum ErrorCode{
    NO_ERROR_CODE = 1;
    NOT_FOUND_GUILD = 2;    //没有公会
    NOT_HAS_ENOUGH_MONEY = 3; //没有足够的货币
    NEED_JOIN_TIME = 4;     //已经捐献过了
    SYSTEM_ERROR = 99;
  };
  required ErrorCode error = 1;
  optional GuildSync sync = 2;
  optional ClientSync client = 3;
  
  optional int32 type = 4;    //类型
  optional int32 guild_point = 5;
  ]]
  
 
  
  if msg.error == "NO_ERROR_CODE" then
    self:parseGuildSync(msg.sync)
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)
    if self._donateView ~= nil then
      self._donateView:removeFromParentAndCleanup(true)
    end
    self:updateView()
    Toast:showString(GameData:Instance():getCurrentScene(),_tr("donate_success"), ccp(display.cx, display.cy))
  else
    self:toastError(msg.error)
  end
  
  self._donateView = nil
end

function Guild:reqGuildFightCheckC2S()
  printf("Guild:reqGuildFightCheckC2S")
  _showLoading()
  local data = PbRegist.pack(PbMsgId.GuildFightCheckC2S)
  net.sendMessage(PbMsgId.GuildFightCheckC2S,data)
end

function Guild:onCheckFightResult(action,msgId,msg)
  printf("Guild:onCheckFightResult:"..msg.info.fightType)
  _hideLoading()
  if msg.info.fightType == "PVE_GUILD" then
     if msg.error == "NO_ERROR_CODE" then
      GameData:Instance():getCurrentScene():getDisplayContainer():removeAllChildrenWithCleanup(true)
      local battleController = ControllerFactory:Instance():create(ControllerType.BATTLE_CONTROLLER)
      battleController:enter()
      battleController:startPVEGuildBattle(msg)
     else
      self:toastError(msg.error)
     end
  end
end

function Guild:reqGuildFightReqC2S(cards)
  printf("Guild:reqGuildFightReqC2S")
  --[[
  message GuildFightReqC2S{
    enum traits{ value = 5187 ; }
    required FightCards cards = 1;
  }
  ]]
  
  dump(cards)
  local data = PbRegist.pack(PbMsgId.GuildFightReqC2S,{cards = {card_pos = cards}})
  net.sendMessage(PbMsgId.GuildFightReqC2S,data)
end

function Guild:reqGuildLevelUpBuildC2S(build)
  printf("Guild:reqGuildLevelUpBuildC2S")
  local data = PbRegist.pack(PbMsgId.GuildLevelUpBuildC2S,{build = build})
  net.sendMessage(PbMsgId.GuildLevelUpBuildC2S,data)
end

function Guild:onGuildLevelUpBuildResultS2C(action,msgId,msg)
  printf("Guild:onGuildLevelUpBuildResultS2C:"..msg.error)  
  --[[
  message GuildLevelUpBuildResultS2C{
  enum traits{value = 5189;}
  enum ErrorCode{
    NO_ERROR_CODE = 1;
    NOT_FOUND_GUILD = 2;  //没有公会
    AUTHORITY_LIMIT = 3;  //权限不够
    NOT_FOUND_BUILD = 4;  //没有这个建筑
    NEED_MORE_RESOURCE = 5; //资源不够
    HAS_BUILD_UP = 6;   //有建筑升级
    SYSTEM_ERROR = 99;
  };
  required ErrorCode error = 1;
  optional GuildSync sync = 2;
  }
  ]]
  
  if msg.error == "NO_ERROR_CODE" then
    self:parseGuildSync(msg.sync)
  else
    self:toastError(msg.error)
  end

end

--[[function Guild:reqQueryPlayerShowC2S(playerId)
  printf("Guild:reqQueryPlayerShowC2S playerId:"..playerId)
  _showLoading()
  local data = PbRegist.pack(PbMsgId.QueryPlayerShowC2S,{ pid = playerId })
  net.sendMessage(PbMsgId.QueryPlayerShowC2S,data)
end

function Guild:onQueryPlayerShowResultS2C(action,msgId,msg)
  if ControllerFactory:Instance():getCurrentControllerType() ~=  ControllerType.GUILD_CONTROLLER then
    return
  end
  _hideLoading()
  printf("Guild:onQueryPlayerShowResultS2C")
  printf("msg.pvpbase.maxSource:"..msg.pvpbase.maxSource)
  printf("msg.pvpbase.source:"..msg.pvpbase.source)
  local friendData = FriendData.new()
  friendData:setFriendId(msg.id)
  friendData:setName(msg.nick_name)
  friendData:setLevel(msg.common.level)
  friendData:setAvatar(msg.common.avatar)
  friendData:setVipLevel(msg.common.vip_level)
  friendData:setAchievement(toint(msg.achievement_point))
  friendData:setScore(msg.pvpbase.source or 0)
  friendData:setMaxScore(msg.pvpbase.maxSource or 0)
  friendData:setRankId(msg.pvpbase.rank)
  
  local pop = PopupView:createFriendInfoPopup(friendData,function()  end,true)
  GameData:Instance():getCurrentScene():addChildView(pop)
end
--]]

function Guild:reqGuildMailC2S(titile,content)
  printf("Guild:reqGuildMailC2S")
  local data = PbRegist.pack(PbMsgId.GuildMailC2S,{titile = titile,content = content})
  net.sendMessage(PbMsgId.GuildMailC2S,data)
end

function Guild:reqGuildOpenInstanceC2S(chepter,openInstanceView)
  printf("Guild:reqGuildOpenInstanceC2S:chapter_id:"..chepter)
  --[[
  message GuildOpenInstanceC2S{
  enum traits{value = 5184;}
  required int32 chepter = 1;
  }
  ]]
  _showLoading()
  self._openInstanceView = openInstanceView
  local data = PbRegist.pack(PbMsgId.GuildOpenInstanceC2S,{chepter = chepter})
  net.sendMessage(PbMsgId.GuildOpenInstanceC2S,data)
end

function Guild:onGuildOpenInstanceResultS2C(action,msgId,msg)
 printf("Guild:onGuildOpenInstanceResultS2C:"..msg.error)
--[[message GuildOpenInstanceResultS2C{
  enum traits{value = 5185;}
  enum ErrorCode{
    NO_ERROR_CODE = 1;
    NOT_FOUND_GUILD = 2;    //没有公会
    AUTHORITY_LIMIT = 3;    //权限不够
    GUILD_LEVEL_LIMIT = 4;    //公会等级不够
    GUILD_MONEY_LIMIT = 5;    //公会元宝不够
    GUILD_GOLD_LIMIT = 6;   //公会金币不够
    INSTANCE_OPENED = 7;    //公会副本已经开启
    SYSTEM_ERROR = 99;
  };
  required ErrorCode error = 1;
  optional GuildSync sync = 2;
}]]
  _hideLoading()
  if msg.error == "NO_ERROR_CODE" then
    self:parseGuildSync(msg.sync)
    if self._openInstanceView ~= nil then
      self._openInstanceView:updateView(true)
    end
  else
    self:toastError(msg.error)
  end
  
  self._openInstanceView = nil
end

function Guild:reqGuildQuitC2S(quitViewDelegate)
  printf("Guild:reqGuildQuitC2S")
  _showLoading()
  self._quitViewDelegate = quitViewDelegate
  self._isActiveQuitGuild = true
  local data = PbRegist.pack(PbMsgId.GuildQuitC2S)
  net.sendMessage(PbMsgId.GuildQuitC2S,data)
end

function Guild:onGuildQuitResultS2C(action,msgId,msg)
 printf("Guild:onGuildQuitResultS2C:"..msg.error)
  --[[
  message GuildQuitResultS2C{
  enum traits{value = 5196;}
  enum ErrorCode{
    NO_ERROR_CODE = 1;
    CHAIRMAN_NOT_ALLOW = 2;   //会长不允许退会
    NOT_HAS_GUILD = 3;    //没有公会
    SYSTEM_ERROR = 99;
  };
  required ErrorCode error = 1;
  optional GuildSync sync = 2;
  }
  ]]
  _hideLoading()
  if msg.error == "NO_ERROR_CODE" then
    self:parseGuildSync(msg.sync)
    if self._quitViewDelegate ~= nil then
      self._quitViewDelegate:removeFromParentAndCleanup(true)
    end
    self:updateView()
    self:reqGuildQueryC2S()
  else
    self:toastError(msg.error)
  end
  self._quitViewDelegate = nil
end

function Guild:toastError(error)
  Toast:showString(GameData:Instance():getCurrentScene(),_tr(error), ccp(display.cx, display.cy))
end

function Guild:onGuildSyncS2C(action,msgId,msg)
  printf("Guild:onGuildSyncS2C")
  self:parseGuildSync(msg.sync)
  self:updateView()
end

function Guild:parseGuildSync(sync)
  --[[
  message GuildSync{
  enum Sync{
    _ADD_ = 1;
    _REMOVE_ = 2;
    _UPDATE_ = 3;
  }
  
  
  message GuildInstanceRecord{
    message Record{
      optional int32 player = 2;      //玩家ID
      optional string name = 3;     //玩家名字
      optional int32 damage = 4;      //伤害
      optional int32 time = 5;      //时间
      optional int32 kill = 6;      //击杀
    }
  optional int32 stage = 1;   //副本ID
  repeated Record record = 2;   //副本记录
}

  message GuildMemberSync{
    required Sync sync = 1;
    required GuildMember player = 2;
    optional RelationData data = 3;
  };
  message GuildApplySync{
    required Sync sync = 1;
    optional RelationData data = 2;
  };
  message GuildBaseSync{
    required bool sync = 1;
    optional GuildBase base = 2;
  };
  message GuildInstanceSync{
    required bool sync = 1;
    optional GuildInstanceBase instance = 2;
  };
  message GuildBuildSync{
    required bool sync = 1;
    optional GuildBuildBase build = 2;
  };
  required GuildBaseSync base = 1;      //基础信息变化
  required GuildInstanceSync instance = 3;  //副本信息变化
  required GuildBuildSync build = 4;      //建筑信息变化
  repeated GuildMemberSync member = 2;    //成员信息变化
  repeated GuildApplySync apply = 5;      //申请信息变化
  repeated GuildInstanceRecord record = 6;  //副本战斗记录
  }
  ]]

  if sync == nil then
    return
  end
  
  --基础信息变化
  local guildBase = self:getSelfGuildBase()
  if sync.base ~= nil and sync.base.sync == true then
    if guildBase == nil then
      guildBase = GuildBase.new(sync.base.base)
      self:setSelfGuildBase(guildBase)
    else
      guildBase:update(sync.base.base)
    end
    self:setSelfHaveGuild(true)
    
    local myGuildBase = self:getGuildById(guildBase:getId())
    if myGuildBase == nil then
      table.insert(self:getGuildList(),guildBase)
    end
--    local myGuildBase = self:getGuildById(guildBase:getId())
--    if myGuildBase == nil then
--      table.insert(self:getGuildList(),myGuildBase)
--    else
--      myGuildBase:update(sync.base.base)
--    end
  end
  
  --副本信息变化
  if sync.instance ~= nil and sync.instance.sync == true then
    local guildInstance = self:getGuildStageInstance()
    if guildInstance == nil then
      guildInstance = GuildStageInstance.new(sync.instance.instance)
      self:setGuildStageInstance(guildInstance)
    else
      guildInstance:update(sync.instance.instance)
    end
  end
  
  
  --申请信息变化
  if sync.apply ~= nil and guildBase ~= nil then
    local members = guildBase:getApplyMembers()
    for key, memberSyncInfo in pairs(sync.apply) do
      if memberSyncInfo.sync == GuildConfig.GuildSyncTypeAdd then
        local member = GuildMember.new()
        member:updateRelation(memberSyncInfo.data)
        --members[memberSyncInfo.data.id] = member
        table.insert(members,member)
      elseif memberSyncInfo.sync == GuildConfig.GuildSyncTypeRemove then
        for k, guildMember in pairs(members) do 
          if guildMember:getId() == memberSyncInfo.data.id then 
            table.remove(members, k)
            break
          end
        end
      elseif memberSyncInfo.sync == GuildConfig.GuildSyncTypeUpdate then
        local member = self:getSelfGuildBase():getApplyMemberById(memberSyncInfo.data.id)
        --assert(member ~= nil)
        if member ~= nil then
          member:updateRelation(memberSyncInfo.data)
        end
      end
    end
  end
  
  --成员信息变化
  if sync.member ~= nil and guildBase ~= nil then
    local members = guildBase:getMembers()
    for key, memberSyncInfo in pairs(sync.member) do
      if memberSyncInfo.sync == GuildConfig.GuildSyncTypeAdd then
        local member = GuildMember.new(memberSyncInfo.player)
        member:updateRelation(memberSyncInfo.data)
        table.insert(members,member)
        --members[memberSyncInfo.player.player] = member
        
      elseif memberSyncInfo.sync == GuildConfig.GuildSyncTypeRemove then
        for k, guildMember in pairs(members) do 
          if guildMember:getPlayerId() == memberSyncInfo.player.player then 
            local member = guildBase:getMemberById(memberSyncInfo.player.player)
            local selfJobType = member:getJob()
            table.remove(members, k)
            if memberSyncInfo.player.player == GameData:Instance():getCurrentPlayer():getId() then
              local str = _tr("leave_guild_success")
              if selfJobType == GuildConfig.MemberTypeChairman then
                str = _tr("guild_has_been_deleted")
              end
              if self._isActiveQuitGuild ~= true then
                Toast:showString(GameData:Instance():getCurrentScene(),str, ccp(display.cx, display.cy))
              end
              
              self:setSelfGuildBase(nil)
              self:setSelfHaveGuild(false)
            end
            break
          end
        end
        self._isActiveQuitGuild = false
      elseif memberSyncInfo.sync == GuildConfig.GuildSyncTypeUpdate then
        local member = self:getSelfGuildBase():getMemberById(memberSyncInfo.player.player)
        --assert(member ~= nil)
        if member ~= nil then
          member:updateGuildMember(memberSyncInfo.player)
          member:updateRelation(memberSyncInfo.data)
        end
      end
    end
  end
  
  if sync.record ~= nil then
    if self._guildStageLogs == nil then
      self._guildStageLogs = {}
    end
    
    for key, record in pairs(sync.record) do
      print("stage:",record.stage)
      self._guildStageLogs[record.stage] = {}
      
      local stage = Scenario:Instance():getStageById(record.stage)
      if stage ~= nil then
        for key, recordInfo in pairs(record.record) do
           local strTime = ""
           if recordInfo.time ~= nil then 
              local sec = os.time() - recordInfo.time
              if sec >= 0 then 
                if sec < 60 then
                  strTime = _tr("just_now")
                elseif sec < 3600 then  --1小时内 
                  strTime = _tr("%{miniute}ago", {miniute=math.max(1, math.floor(sec/60))})
                elseif sec < 24*3600 then --今天
                  strTime = _tr("%{hour}hour_ago", {hour=math.floor(sec/3660)})
                elseif sec < 48*3600 then --昨天
                  strTime = _tr("yesterday")
                elseif sec < 72*3600 then --前天
                  strTime = _tr("before_yesterday")
                else 
                  strTime = _tr("%{day}day_ago", {day=math.min(7, math.ceil(sec/(24*3660)))}) 
                end 
              end 
          end 
          --local str = recordInfo.name.."攻打了"..stage:getStageName(true).."造成了"..tostring(recordInfo.damage).."点伤害  "..strTime
          local stageName = stage:getStageName(false)
          local str = _tr("guild_log",{name = recordInfo.name,stage = stageName, damage = tostring(recordInfo.damage),time = strTime})
          table.insert(self._guildStageLogs[record.stage],1,str)
        end
      end
    end
  end

end

function Guild:getStageRecords()
	return self._guildStageLogs
end


return Guild