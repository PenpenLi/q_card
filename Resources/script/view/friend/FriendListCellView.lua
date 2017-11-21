require("view.BaseView")
require("view.component.RoleHeadView")
require("model.Friend")
require("view.player_info.PlayerInfoView")
require("view.component.Loading")
require("view.component.PopupView")
--require("controller.FriendController")

FriendListCellView = class("FriendListCellView",BaseView)
local CurViewTag = enum({"NULL","FRIEND_LIST","APPLY_FRIEND","RECOMMEND_FRIEND"})

local btnIsEnable = false

local function getRange(object)
	local x = object:getPositionX()
	local y = object:getPositionY()
	local parent = object:getParent()
	if parent then
		x = x + parent:getPositionX()
		y = y + parent:getPositionY()
		while parent:getParent() do
			parent = parent:getParent()
			x = x + parent:getPositionX()
			y = y + parent:getPositionY()
		end
	end
	return CCRectMake(x,y,object:getContentSize().width,object:getContentSize().height)
end

local function containsTouchLocation(self,x,y)
	btnIsEnable =  getRange( self.listContainer):containsPoint(ccp(x,y))
	return btnIsEnable
end

local function ccTouchBegan(self,x,y)
	if  containsTouchLocation(self,x,y) == false then
		return true
	end
	return false
end

local function onTouch(self,eventType,x,y)
	if eventType == "began" then
		return ccTouchBegan(self,x,y)
	end
	-- if eventType == "moved" then
	-- 	-- return true
	-- end
	-- if eventType == "ended" then
	-- end
end

function FriendListCellView:ctor(parent,index)
	FriendListView.super.ctor(self)
	--print("FriendListCellView.lua<FrindListCellView:ctor> : ", control )
	self._cellIndex = index
	self._parent = parent
	self:setNodeEventEnabled(true)
end

function FriendListCellView:enter()
--	print("FriendListCellView.lua<FriendListCellView:enter> : " )
	local pkg = ccbRegisterPkg.new(self)
	pkg:addProperty("friendName","CCLabelTTF")
	--pkg:addProperty("isOnline","CCLabelTTF")
	pkg:addProperty("curLv","CCLabelBMFont")
	--pkg:addProperty("btnZone","CCLayerColor")
	pkg:addProperty("enterBtn","CCControlButton")
	pkg:addProperty("acceptFriendBtn","CCControlButton")
	pkg:addProperty("headClickBtn","CCControlButton")
	pkg:addProperty("refuseFriendBtn","CCControlButton")
	pkg:addProperty("addFriendBtn","CCControlButton")
	pkg:addProperty("headItemNode","CCNode")
	pkg:addProperty("minerCount","CCLabelTTF")
	pkg:addProperty("lastLogoutTime","CCLabelTTF")

	pkg:addFunc("enterCallBack",FriendListCellView.onEnterCallBack)
	pkg:addFunc("acceptFriendCallBack",FriendListCellView.onAcceptFriendCallback)
	pkg:addFunc("refuseFriendCallBack",FriendListCellView.onRefuseFriendCallback)
	pkg:addFunc("addFriendCallBack",FriendListCellView.onAddFriendCallback)
	pkg:addFunc("onHeadClickCallBack",FriendListCellView.onHeadClickCallBack)

	local layer,owner = ccbHelper.load("FriendListCell.ccbi","FriendListCellCCB","CCLayer",pkg)
	self:addChild(layer)

	local curViewType = self:getDelegate():getCurViewTag()
	if curViewType == CurViewTag.FRIEND_LIST then
		self.acceptFriendBtn:removeFromParent()
		self.refuseFriendBtn:removeFromParent()
		self.addFriendBtn:removeFromParent()
	elseif curViewType == CurViewTag.APPLY_FRIEND then
		self.enterBtn:removeFromParent()
		self.addFriendBtn:removeFromParent()
	elseif curViewType == CurViewTag.RECOMMEND_FRIEND then
		self.enterBtn:removeFromParent()
		self.refuseFriendBtn:removeFromParent()
		self.acceptFriendBtn:removeFromParent()
	end

	self:setTouchEnabled( true )
	self:addTouchEventListener(handler(self,onTouch ), false ,-1 , true)
	self._iMaxFriendCount = Friend:Instance():getFriendMaxCount()

	self.roleHeader = RoleHeadView.new()
	self.headItemNode:addChild(self.roleHeader)	
end

function FriendListCellView:setFriendData(friendData)

	if friendData ~= nil then
		self.friendName:setString(friendData:getName())
		self.curLv:setString(friendData:getLevel())
		self.friendId = friendData:getFriendId()
		self._friendName =  friendData:getName()
		
		self.roleHeader:setAvatorIcon(friendData:getAvatarId())
		self.roleHeader:setVipLevel(friendData:getVipLevel())
		
		self.minerCount:setColor(ccc3(32,157,77)) -- set default color
		local minerIdelcount = (toint)(friendData:getMinerIdleCount())
		local minerMaxCount  = friendData:getMinerMaxCount()
		local strMinerInfo = minerIdelcount .."/" .. minerMaxCount
		self.minerCount:setString(strMinerInfo)
		if minerIdelcount <= 0 then
			self.minerCount:setColor(ccc3(201,1,1))
		end

		--上次登录时间
		local strTime = ""
		
		if friendData:getIsOnLine() == true then
		  strTime = _tr("current_online")
		else
  		local lastLogoutTime = friendData:getLastLogoutTime() 
  		if lastLogoutTime ~= nil then 
  			local sec = Clock:Instance():getCurServerUtcTime() - lastLogoutTime 
  			if sec >= 0 then 
  				if sec < 3600 then 	--1小时内 
  					strTime = _tr("last_logout_time").._tr("%{miniute}ago", {miniute=math.max(1, math.floor(sec/60))})
  				elseif sec < 24*3600 then --今天
  					strTime = _tr("last_logout_time").._tr("%{hour}hour_ago", {hour=math.floor(sec/3660)})
  				elseif sec < 48*3600 then --昨天
  					strTime = _tr("last_logout_time").._tr("yesterday")
  				elseif sec < 72*3600 then --前天
  					strTime = _tr("last_logout_time").._tr("before_yesterday")
  				else 
  					strTime = _tr("last_logout_time").._tr("%{day}day_ago", {day=math.min(7, math.ceil(sec/(24*3660)))}) 
  				end 
  			end 
  		end 
    end
		self.lastLogoutTime:setString(strTime)
	end
end

function FriendListCellView:setListCellType(type)
	self._listCellType = type
end

function FriendListCellView:onEnterCallBack()
	_playSnd(SFX_CLICK)
  if GameData:Instance():checkSystemOpenCondition(3, true) == false then 
    return 
  end 
 
	local miningController = ControllerFactory:Instance():create(ControllerType.MINING_CONTROLLER)
	miningController:enter(self._friendName,self.friendId)
end

function FriendListCellView:onAcceptFriendCallback()
	print("FrinedListCellView.lua<FriendListCellView:onAcceptFriendCallback>:",Friend:Instance():getAcceptBtnEnable() )

	if Friend:Instance():getAcceptBtnEnable() == false then
		return
	end
	_playSnd(SFX_CLICK)

	local friendListArray = Friend:Instance():getCurrentFriend()
	local curFriendNum = 0
	if friendListArray ~= nil then
		curFriendNum =  #friendListArray
	end
	if curFriendNum >= self._iMaxFriendCount then
		Toast:showString(self, _tr("max_friend_count"), ccp(display.cx, display.cy))
		return
	end

	local curViewType = self:getDelegate():getCurViewTag()

	if  self._parent ~= nil and curViewType == CurViewTag.APPLY_FRIEND   then
		Friend:Instance():setAcceptBtnEnable(false)
		print("self.friendId",self.friendId)
		Friend:MsgC2SChooseInvite(self.friendId,true)
		self._parent:updataTableViewAtIndex(self._cellIndex,self.friendId)
	end
end

function FriendListCellView:setAcceptBtnIsEnable(isEnable)
	self._acceptBtnIsEnable = isEnable
end

function FriendListCellView:getAcceptBtnIsEnable()
	return self._acceptBtnIsEnable
end

function FriendListCellView:onRefuseFriendCallback()
	print("FrinedListCellView.lua<FriendListCellView:ctor> onRefuseFriendCallback: ")
	_playSnd(SFX_CLICK)
	if self._parent ~= nil  then
		self._parent:updataTableViewAtIndex(self._cellIndex,self.friendId)
		print("self.friendId",self.friendId)
		Friend:MsgC2SChooseInvite(self.friendId,false)
	end
end

--发送添加好友消息
function FriendListCellView:onAddFriendCallback()
	print("FrinedListCellView.lua<FriendListCellView:ctor> onAddFriendCallback: ")
	print("add ,self._friendName",self._friendName)
	_playSnd(SFX_CLICK)
	
	local friendListArray = Friend:Instance():getCurrentFriend()
	local feriendNum = 0
	if friendListArray ~= nil then
		feriendNum =  #friendListArray
	end
	local iMaxFriendCount = Friend:Instance():getFriendMaxCount()
	if feriendNum >= iMaxFriendCount then
		Toast:showString(self, _tr("max_friend_count"), ccp(display.cx, display.cy))
		return
	end

	if self._parent ~= nil then
		Friend:MsgC2SInviteFriend(self._friendName)
		self._parent:updataTableViewAtIndex(self._cellIndex,self.friendId)
	end
end

-- 点击进入好友信息界面
function FriendListCellView:onHeadClickCallBack()
	_playSnd(SFX_CLICK)
	--print("##############onHeadClickCallBack()")
	local curViewType = self:getDelegate():getCurViewTag()
	Friend:Instance():QueryPlayerShowC2S(curViewType,self.friendId,self)
end

function FriendListCellView:showFriendInfo(curViewType)
    --self._loading:remove()
    local friendData = Friend:Instance():getFriendDataWithFriendId(self.friendId,curViewType)
    local curViewType = self:getDelegate():getCurViewTag()
    
    local pop = nil
    if curViewType == CurViewTag.FRIEND_LIST then
       pop = PopupView:createFriendInfoPopup(friendData,function() Friend:Instance():MsgC2SRemoveFriend(self.friendId) end)
    else
       pop = PopupView:createFriendInfoPopup(friendData,function() Friend:Instance():MsgC2SRemoveFriend(self.friendId) end,true)
    end
    if pop ~= nil then
      --self:getDelegate():getScene():addChild(pop,100)
      self._parent:addChild(pop,100)
    end
end

function FriendListCellView:setContainer(object)
	self.listContainer = object
end

function FriendListCellView:onExit()
end

return FriendListCellView