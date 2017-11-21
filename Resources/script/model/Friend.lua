require("view.component.Toast")
require("model.FriendData")
require("view.component.Loading")


Friend = class("Friend")

FriendParentType = enum({ "NONE","HOME","INTERACT",})  -- 1.主界面 2.好友交互

Friend._instance = nil

function Friend:Instance()
	if Friend._instance == nil then
		Friend._instance = Friend.new()
	end
	return Friend._instance
end

function Friend:ctor()
	net.registMsgCallback(PbMsgId.MsgS2CFriendLists,self,Friend.MsgS2CFriendLists)    -- 好友列表
	net.registMsgCallback(PbMsgId.MsgS2CInviteLists,self,Friend.MsgS2CInviteLists)    -- 申请列表
	net.registMsgCallback(PbMsgId.MsgS2CRecommendLists,self,Friend.MsgS2CRecommendLists) --推荐好友
--	net.registMsgCallback(PbMsgId.MsgS2CMailList,self,Friend.MsgS2CMailList)       -- 邮件列表
	net.registMsgCallback(PbMsgId.MsgS2CInviteResult,self,Friend.MsgS2CInviteResult)            -- 申请好友的结果
	net.registMsgCallback(PbMsgId.MsgS2CRemoveFriendResult,self,Friend.MsgS2CRemoveFriendResult)      -- 删除好友
	net.registMsgCallback(PbMsgId.QueryPlayerShowResultS2C,self,Friend.QueryPlayerShowResultS2C)      --
	net.registMsgCallback(PbMsgId.MsgS2CChooseResult,self,Friend.MsgS2CChooseResult)

	self._acceptBtnEnable = true

end

local  function isVipState(endTime)
	local curTime = Clock:Instance():getCurServerUtcTime()
	if endTime ~= nil and endTime > curTime then
		return true
	else
		return false
	end
end


function Friend:setCurFriend(view)
	self._curFriendView = view
end

-- add friend
function Friend:MsgC2SInviteFriend(nickName)
	--print("MsgC2SInviteFriend nickName = ",nickName)
	local data = PbRegist.pack(PbMsgId.MsgC2SInviteFriend,{name = nickName})
	net.sendMessage(PbMsgId.MsgC2SInviteFriend,data)
end

-- 是否同意加好友
function Friend:MsgC2SChooseInvite(friendId,isAgree)
	self._isAgree = isAgree
	local data = PbRegist.pack(PbMsgId.MsgC2SChooseInvite,{id = friendId,choose = isAgree})
	net.sendMessage(PbMsgId.MsgC2SChooseInvite,data)
end

-- 是否同意好友申请的 result消息
function Friend:MsgS2CChooseResult(action,msgId,msg)
  _hideLoading()
	print("MsgS2CChooseResult------msg.error =",msg.error)
	if msg.error == "NO_ERROR_CODE" then
		if self._isAgree == true then
			Toast:showString(GameData:Instance():getCurrentScene(), _tr("become_friend"), ccp(display.cx, display.cy))
		else
			Toast:showString(GameData:Instance():getCurrentScene(), _tr("has_refuse_been_friend"), ccp(display.cx, display.cy))
		end

		if self._applyListView ~= nil then
			self._applyListView:updateFriendCount()
		end
	elseif msg.error == "FRIEND_LIST_FULL" then
		Toast:showString(GameData:Instance():getCurrentScene(), _tr("friend_exceed_maxnum"), ccp(display.cx, display.cy))
	elseif msg.error == "TARGET_LIST_FULL" then
		self:setAcceptBtnEnable(true)
		Toast:showString(GameData:Instance():getCurrentScene(), _tr("otherside_friends_exceed_maxnum"), ccp(display.cx, display.cy))
	elseif msg.error == "NOT_FOUND_INVITE" then

	elseif msg.error == "SYSTEM_ERROR" then

	end

end


function Friend:reqFriendList(queryType)

--	QUERY_ALL = 0;
--	QUERY_FRIEND = 1;
--	QUERY_INVITE = 2;
--	QUERY_RECOMMEND = 3;
--	QUERY_MAIL = 4;
	print("------reqFriendList-- queryType-----:------", queryType)
	_showLoading()
	local data = PbRegist.pack(PbMsgId.MsgC2SQueryRelation,{query = queryType})
	net.sendMessage(PbMsgId.MsgC2SQueryRelation,data)

end

function Friend:MsgC2SRemoveFriend(friendId)
	local data = PbRegist.pack(PbMsgId.MsgC2SRemoveFriend,{id = friendId})
	net.sendMessage(PbMsgId.MsgC2SRemoveFriend,data)
end

function Friend:MsgS2CFriendLists(action,msgId,msg)
  _hideLoading()
	print("------------MsgS2CFriendLists------------")
	local friendList = {}
	self._friendList = {}
	if msg.relations ~= nil then
		local item 
		for i=1, #msg.relations.data do
			item = msg.relations.data[i] 
			local friendData = FriendData.new()
			friendData:updateRelation(msg.relations.data[i])
			friendData:setFriendId(item.id)
			friendData:setName(item.name)
			friendData:setLevel(item.level)
			friendData:setAvatar(item.avatar)
			friendData:setIsOnLine(item.is_on_line)
			friendData:setVipLevel(item.vip_level)
			friendData:setMinerIdleCount(item.minerIdlePos)
			friendData:setMinerMaxCount(item.minerPosCount)
			friendData:setLastLogoutTime(item.last_logout_time)
			table.insert(friendList,friendData)
		end 
		self._friendList = friendList
		self:setAcceptBtnEnable(true)
		GameData:Instance():getCurrentPlayer():setFriendLeadShip(table.getn(self._friendList))
	end
end

function Friend:getCurrentFriend()
	if self._friendList == nil then 
		self._friendList = {}
	end 
	return self._friendList
end

function Friend:cleanFriendData()
	self._friendList = nil
	self._applyFriendList = nil
	self._recommendFriendList = nil
end


function Friend:QueryPlayerShowC2S(queryType ,userId,view)
  _showLoading()
  print("Friend:QueryPlayerShowC2S:userId",userId,"queryType:",queryType)
	self._queryType = queryType       -- 1,2,3,4:任意的一个玩家类型
	self._viewDelegate = view
	local data = PbRegist.pack(PbMsgId.QueryPlayerShowC2S,{pid = userId})
	net.sendMessage(PbMsgId.QueryPlayerShowC2S,data)
end

function Friend:MsgS2CInviteLists(action,msgId,msg)
  _hideLoading()
	print("Friend:MsgS2CInviteLists"  )

	local applyFriendList = {}
	self._applyFriendList = {}
	if msg.relations ~= nil then
		for i=1,#msg.relations.data,1 do
			local friendData = FriendData.new()
			friendData:updateRelation(msg.relations.data[i])
			friendData:setFriendId(msg.relations.data[i].id)
			friendData:setName(msg.relations.data[i].name)
			friendData:setLevel(msg.relations.data[i].level)
			friendData:setAvatar(msg.relations.data[i].avatar)
			friendData:setIsOnLine(msg.relations.data[i].is_on_line)
			friendData:setVipLevel(msg.relations.data[i].vip_level)
			friendData:setMinerIdleCount(msg.relations.data[i].minerIdlePos)
			friendData:setMinerMaxCount(msg.relations.data[i].minerPosCount)
			table.insert(applyFriendList,friendData)
		end
		self._applyFriendList = applyFriendList

		if table.getn(self._applyFriendList) > 0 then
			echo(" notify home to update friend tip.")
			CCNotificationCenter:sharedNotificationCenter():postNotification(EventType.UPDATE_TIP)
		end
	end
end

function Friend:getApplyFriend()
	return self._applyFriendList
end

function Friend:MsgS2CRecommendLists(action,msgId,msg)
	print("Friend.lua<MsgS2CRecommendLists > :"  )
  _hideLoading()
	local recommendFriendList = {}
	self._recommendFriendList = {}
	if msg.relations ~= nil then
		for k, v in pairs(msg.relations.data) do
			local friendData = FriendData.new()
			friendData:updateRelation(v)
			friendData:setFriendId(v.id)
			friendData:setName(v.name)
			friendData:setLevel(v.level)
			friendData:setAvatar(v.avatar)
			friendData:setIsOnLine(v.is_on_line)
			friendData:setVipLevel(v.vip_level)
			friendData:setMinerIdleCount(v.minerIdlePos)
			friendData:setMinerMaxCount(v.minerPosCount)
			table.insert(recommendFriendList,friendData)
		end
		self._recommendFriendList =  recommendFriendList
	end
end

function Friend:getRecommendFriend()
	return self._recommendFriendList
end

function Friend:QueryPlayerShowResultS2C(action,msgId,msg)
	 local queryType = self._queryType
	 
	 print("self._queryType",self._queryType,msg.result)
  _hideLoading()
  
  if queryType == nil then
    return
  end
  
	if msg.result == true then
		local friendList
		self._anyPlayer = FriendData.new()
		if queryType == 1 then
			friendList = self._friendList
		elseif queryType == 2 then
			friendList = self._applyFriendList
		elseif queryType ==3 then
			friendList = self._recommendFriendList
		elseif queryType ==4 then

		else
		
		end

		if queryType ~= 4 then
			for k, v in pairs(friendList) do
				if v:getFriendId() == msg.id and (v:getRankId() == nil or v:getRankId() == 0 )then
					v:setFriendId(msg.id)
					v:setName(msg.nick_name)
					v:setLevel(msg.common.level)
					v:setAvatar(msg.common.avatar)
					v:setVipLevel(msg.common.vip_level)
					v:setAchievement(toint(msg.achievement_point))
					v:setScore(msg.pvpbase.source or 0)
					v:setMaxScore(msg.pvpbase.maxSource or 0)
					v:setRankId(msg.pvpbase.rank)
					break
				end
			end
		elseif queryType == 4 then
			self._anyPlayer:setFriendId(msg.id)
			self._anyPlayer:setName(msg.nick_name)
			self._anyPlayer:setLevel(msg.common.level)
			self._anyPlayer:setAvatar(msg.common.avatar)
			self._anyPlayer:setVipLevel(msg.common.vip_level)
			self._anyPlayer:setAchievement(toint(msg.achievement_point))
			self._anyPlayer:setScore(msg.pvpbase.source or 0)
			self._anyPlayer:setMaxScore(msg.pvpbase.maxSource or 0)
			self._anyPlayer:setRankId(msg.pvpbase.rank)
		end
		
		if self._viewDelegate ~= nil then
		  self._viewDelegate:showFriendInfo(queryType)
		end
	end
	self._viewDelegate = nil
	self._queryType = nil
end

function Friend:getFriendDataWithFriendId(id,type)
	local friendList
	if type ==1 then
		friendList = self:getCurrentFriend()
	elseif type == 2 then
		friendList = self:getApplyFriend()
	elseif type ==3 then
		friendList = self:getRecommendFriend()
	elseif type ==4 then
		return self._anyPlayer
	end
	for k, v in pairs(friendList) do
		if id == v:getFriendId() then
			return v
		end
	end
	return nil
end

function Friend:getFriendLvByUserId(userId)
	local friendData = self:getFriendDataWithFriendId(userId,1) -- 1:好友列表
	if friendData ~= nil then
		return friendData:getLevel()
	end
end

function Friend:updateMinerIdleCountWithFriendId(friendId,type) -- only my friend list
	local friendList = self:getCurrentFriend()
	for k, v in pairs(friendList) do
		if friendId == v:getFriendId() then
			local curCount = v:getMinerIdleCount() -1
			if curCount < 0 then
				curCount = 0
			end

			if type == "reduce" then
				v:setMinerIdleCount(curCount)
			elseif type == "add" then
			    v:setMinerIdleCount(v:getMinerIdleCount()+1)
			end
		end
	end
end

function Friend:setMinerMaxCountWithFriendId(friendId,count)
	local friendList = self:getCurrentFriend()
	for k, v in pairs(friendList) do
		if friendId == v:getFriendId() then
			--local curCount = v:getMinerMaxCount()
			v:setMinerMaxCount(count)
		end
	end
end

-- 添加好友的返回消息
function Friend:MsgS2CInviteResult(action,msgId,msg)
  _hideLoading()
	print("Friend.lua<MsgS2CInviteLists > : msg.r ==============================",  msg.r)
	if msg.r == "INVITE_OK" then
		Toast:showString(GameData:Instance():getCurrentScene(), _tr("req_add_friend_success"), ccp(display.cx, display.cy))
	elseif msg.r ==  "NOT_FOUND_NICKNAME"    then
		Toast:showString(GameData:Instance():getCurrentScene(), _tr("meiyouzhaodaogaiwanjia"), ccp(display.cx, display.cy))
	elseif msg.r ==  "FRIEND_LIST_FULL"    then
		Toast:showString(GameData:Instance():getCurrentScene(), _tr("friend_exceed_maxnum"), ccp(display.cx, display.cy))
	elseif msg.r ==  "INVITE_IS_YOU_FRIEND"    then
		Toast:showString(GameData:Instance():getCurrentScene(), _tr("shenqingwanjiayishihaoyou"), ccp(display.cx, display.cy))
	elseif msg.r ==  "INVITE_IS_IN_LIST"    then
		Toast:showString(GameData:Instance():getCurrentScene(), _tr("req_add_friend_success"), ccp(display.cx, display.cy))
	elseif msg.r == "TARGET_FRIEND_FULL" then
		self:setAcceptBtnEnable(true)
		Toast:showString(GameData:Instance():getCurrentScene(), _tr("othersize_friend_full"), ccp(display.cx, display.cy))
	end
end

function Friend:MsgS2CRemoveFriendResult(action,msgId,msg)
  _hideLoading()
	local friendId = msg.id
	if msg.result == "REMOVE_OK" then
		local friendName = self:getFriendNameById(friendId)
		local str = _tr("shanchuhaoyou%{name}", {name=friendName})
		Toast:showString(GameData:Instance():getCurrentScene(), str, ccp(display.cx, display.cy))
		if self._friendListView ~= nil then
			self._friendListView:removeFriendWithFriendId(friendId)
		else
			Friend:Instance():removeOneFriendById(friendId)
		end
		GameData:Instance():getCurrentPlayer():setFriendLeadShip(table.getn(self:getCurrentFriend()))
	elseif msg.result ==  "NOT_FOUND"    then
		Toast:showString(GameData:Instance():getCurrentScene(), _tr("meiyouzhaodaogaiwanjia"), ccp(display.cx, display.cy))
	elseif msg.result ==  "SYSTEM_ERROR"    then
		Toast:showString(GameData:Instance():getCurrentScene(), _tr("system error"), ccp(display.cx, display.cy))
	end
end

function Friend:getFriendNameById(friendId)
	for k, v in pairs(self._friendList) do
		if friendId == v:getFriendId() then
			return v:getName()
    	end
	end
end

function Friend:setFriendListVirw(friendListView)
	self._friendListView = friendListView
end

function Friend:setApplyListView(applyListView)
	self._applyListView = applyListView
end

function Friend:setParentTag(parentTag)
	self._parentTag = parentTag
end

function Friend:getParentTag()
	return self._parentTag
end

function Friend:getFriendMaxCount()
	local player = GameData:Instance():getCurrentPlayer()
	local playerLv = player:getLevel()
	local iMaxFriendCount = 0

	if playerLv > 0 then
		local vipLevel = player:getVipLevel()
		iMaxFriendCount = AllConfig.char_friend_count[playerLv].friend_max_count + AllConfig.vipinitdata[vipLevel+1].friend_add_count
	end
	
	return iMaxFriendCount
end


function Friend:hasNewEvent()
	local curFriend = 0
	if self:getCurrentFriend() == nil then

	else
		curFriend = #self:getCurrentFriend()
	end

	local maxFriend = self:getFriendMaxCount()
	if curFriend >= maxFriend then
		return false
	end

	if GameData:Instance():checkSystemOpenCondition(11, false) == false then 
		return false
	end
 
	local arr = self:getApplyFriend()
	if arr ~= nil and table.getn(arr) > 0 then 
		return true
	end 

    return false
end

function Friend:setAcceptBtnEnable(isEnable)
	self._acceptBtnEnable = isEnable
end

function Friend:getAcceptBtnEnable()
	return self._acceptBtnEnable
end

function Friend:removeOneFriendById(friendId)
	local friendListArray =self:getCurrentFriend()
	if friendListArray == nil then
		return
	end
	for i= #friendListArray,1 ,-1 do
		if friendListArray[i]:getFriendId() == friendId then
			table.remove(friendListArray,i)
			break
		end
	end
end




return  Friend
