
require("controller.BaseController")
--require("view.mining.MiningMenuView")
require("view.mining.MiningFieldView")
require("view.mining.MiningInfoView")
require("model.Mining")


MinerWinTag = enum({"NONE","MiningField","Mininginfo"})
MiningController = class("MiningController",BaseController)


MiningController.preView = nil
local MiningCurViewTag = enum({"NULL","MINING","MINING_INFO"})

function MiningController:ctor()
	MiningController.super.ctor(self)
end

function MiningController:enter(minerOwnerName,userId,fullScreen,enabledTransition)
	MiningController.super.enter(self)
	self._curViewTag =  MiningCurViewTag.MINING
	self:setScene(GameData:Instance():getCurrentScene())
	print("minerName,userId",minerOwnerName,userId)
	local mining = Mining:Instance()
	mining:setUserName(minerOwnerName)
	mining:setUserId(userId)
	mining:setControl(self)

	-- 请求 基数数据
	mining:reqBasedataWithUserId(mining:getUserId())

--
--	self._miningMenuView = MiningMenuView.new(self)
--	self._miningMenuView:enter()

--	if  enabledTransition ~= nil and fullScreen ~= nil then
--		self:getScene():replaceView(self._miningMenuView,false,false)
--	else
--		self:getScene():replaceView(self._miningMenuView)
--	end

	-- 直接进入创建矿场界面
	self._view = MiningFieldView.new(self)
	self._view:enter()
	self:setCurMiningView(self._view)
	self:getScene():replaceView(self._view,fullScreen,enabledTransition)

	if Mining:Instance():getIsMyMining() == true then
		GameData:Instance():pushViewType(ViewType.mine)
	else 
		GameData:Instance():pushViewType(ViewType.friend_mining)
	end 
  _executeNewBird()
end


function MiningController:setMinerWinTag(minerWinTag)
	self._minerWinTag = minerWinTag
end

function MiningController:getMinerWinTag()
	return self._minerWinTag
end

function MiningController:dispMiningFieldView()
	print("MiningController.lua<FriendController>:dispMiningFieldView" )
--	if self._curView ~= nil then
--		self._curView:onExit()
--	end
--	if self._miningMenuView:getChildByTag(CurViewTag.MINING) ~= nil then
--		return
--	end
	self._miningMenuView:removeChildByTag(self._curViewTag,true)
	self._curViewTag = MiningCurViewTag.MINING
	self._curView = MiningFieldView.new(self)
	--self._miningMenuView:addChild(self._curView,1,MiningCurViewTag.MINING)
	self._curView:enter()
	self:getScene():setTopVisible(true)

	self._miningMenuView:getNodeContainer():addChild(self._curView)
end

function MiningController:dispMiningInfoView()
	print("MiningController.lua<FriendController>:dispMiningInfoView" )
--	if self._curView ~= nil then
--		self._curView:onExit()
--	end
--	if self._miningMenuView:getChildByTag(MiningCurViewTag.MINING_INFO) ~= nil then
--		return
--	end
	self._miningMenuView:removeChildByTag(self._curViewTag,true)
	self._curViewTag = MiningCurViewTag.MINING_INFO
	self._curView = MiningInfoView.new(self)
	--self._miningMenuView:addChild(self._curView,1,MiningCurViewTag.MINING_INFO)
	self._curView:enter()
	self:getScene():setTopVisible(true)
	self._miningMenuView:getNodeContainer():addChild(self._curView)
end

function MiningController:getMenuView()
	return self._miningMenuView
end

function MiningController:getLayer()
	return self._miningMenuView
end

function MiningController:getCurMiningView()
	return  self._curView
end

function MiningController:setCurMiningView(viewData)
	self._curView = viewData
end

function MiningController:getcurViewTag()
	return self._curViewTag
end

function MiningController:setcurViewTag(tag)
	self._curViewTag = tag
end

function  MiningController:exit()
	print("MiningController exit")
--	if self._curView ~= nil then
--		self._curView:onExit()
--	end
end

return MiningController
