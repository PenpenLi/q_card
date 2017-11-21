require("controller.BaseController")
require("view.friend.FriendMenuView")
require("view.friend.FriendListView")
require("view.friend.ApplyFriendView")
require("view.friend.RecommendFriendView")
require("model.Friend")


FriendController = class("FriendController",BaseController)

local CurViewTag = enum({"NULL","FRIEND_LIST","APPLY_FRIEND","RECOMMEND_FRIEND"})

function FriendController:ctor()
	FriendController.super.ctor(self)
end

function FriendController:enter()
	FriendController.super.enter(self)
	self._curViewTag =  CurViewTag.FRIEND_LIST
	self:setScene(GameData:Instance():getCurrentScene())
	self._friendMenuView = FrindMenuView.new(self)
	self._friendMenuView:enter()
	self:getScene():replaceView(self._friendMenuView)
	_executeNewBird()

	GameData:Instance():pushViewType(ViewType.friend)
end

function FriendController:dispFriendListView()
	if self._curView ~= nil then
		self._curView:exit()
	end
	if self._friendMenuView:getChildByTag(CurViewTag.FRIEND_LIST) ~= nil then
		return
	end
	self._friendMenuView:showHelpBtn(true)
	if self._friendMenuView:getChildByTag(self._curViewTag) ~= nil then 
		self._friendMenuView:removeChildByTag(self._curViewTag,true)
	end 
	self._curViewTag = CurViewTag.FRIEND_LIST
	self._curView = FriendListView.new(self)
	self._friendMenuView:addChild(self._curView,1,CurViewTag.FRIEND_LIST)
	self._curView:enter()
	self:getScene():setTopVisible(true)
end

function FriendController:dispApplyFriendView()
	print("dispApplyFriendView" )
	if self._curView ~= nil  then
		self._curView:exit()
	end
	if self._friendMenuView:getChildByTag(CurViewTag.APPLY_FRIEND) ~= nil then
		return
	end
	self._friendMenuView:showHelpBtn(false)
	if self._friendMenuView:getChildByTag(self._curViewTag) ~= nil then 
		self._friendMenuView:removeChildByTag(self._curViewTag,true)
	end 
	self._curViewTag = CurViewTag.APPLY_FRIEND
	self._curView = ApplyFriendView.new(self)

	self._friendMenuView:addChild(self._curView,1,CurViewTag.APPLY_FRIEND)
	self._curView:enter()
	self._curViewTag = CurViewTag.APPLY_FRIEND
	self:getScene():setTopVisible(true)
end

function FriendController:dispRecommendFriendView()
	print("dispRecommendFriendView")
	if self._curView ~= nil  then
		self._curView:exit()
	end
	if self._friendMenuView:getChildByTag(CurViewTag.RECOMMEND_FRIEND) ~= nil then
		return
	end
	self._friendMenuView:showHelpBtn(false)
	if self._friendMenuView:getChildByTag(self._curViewTag) ~= nil then 
		self._friendMenuView:removeChildByTag(self._curViewTag,true)
	end 
	self._curViewTag = CurViewTag.RECOMMEND_FRIEND
	self._curView = RecommendFriendView.new(self)

	self._friendMenuView:addChild(self._curView,1,CurViewTag.RECOMMEND_FRIEND)
	self._curView:enter()
	self._curViewTag = CurViewTag.RECOMMEND_FRIEND
	self:getScene():setTopVisible(true)
end

function FriendController:getCurViewTag()
	return self._curViewTag
end

function  FriendController:exit()
	print("FriendController exit")
	if self._curView ~= nil then
		self._curView:exit()
	end
	FriendController.super.exit(self)
end

function FriendController:getFriendCurView()
	return  self._curView
end

function FriendController:getLayer()
	return self._friendMenuView
end

function FriendController:goBackView()
	GameData:Instance():gotoPreView()
end

return FriendController



