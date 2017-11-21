-- Frined mainMenu

require("view.component.ViewWithEave")

FrindMenuView = class("FrindMenuView",ViewWithEave)

function FrindMenuView:ctor(control)   -- control is friendController
	FrindMenuView.super.ctor(self)
--	self:setTabControlEnabled(false)

	self:setDelegate(control)
  self:setNodeEventEnabled(true)
	self._curTag = control:getCurViewTag()
end

function FrindMenuView:enter()

	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("friend/friendNew.plist","friend/friendNew.png")

	local menuArray =
	{
		{"#friend-button-nor-haoyouliebiao.png","#friend-button-sel-haoyouliebiao.png"},
		{"#friend-button-nor-shenqingliebiao.png","#friend-button-sel-shenqingliebiao.png"} ,
		{"#friend-button-nor-tuijianhaoyou.png","#friend-button-sel-tuijianhaoyou.png"},
	}

	self:setMenuArray(menuArray)
	self:setTitleTextureName("friend-image-paibian.png")

--	self.friendListBtn:setTouchPriority(-2)
--	self.applyFriendBtn:setTouchPriority(-2)
--	self.recommendFriendBtn:setTouchPriority(-2)
	self:setScrollBgVisible(false)

	local ApplyFriendHasNewEvent = self:hasNewEvent()
	if ApplyFriendHasNewEvent == true then
		self:getTabMenu():setTipImgVisible(2, true)
	end

	self:changeHelpBtnToAddBtn()

	local friendController = self:getDelegate()
	friendController:dispFriendListView()
	self:setActiveBtn(1)
	
	local tabMenu = self:getTabMenu():getTableView()
  for i = 1, #menuArray do
    local targetCell = tabMenu:cellAtIndex(i-1)
    if targetCell ~= nil then
      targetCell:setContentSize(CCSizeMake(135,60))
      _registNewBirdComponent(113001 + (i-1),targetCell)
    end
  end
end


function FrindMenuView:changeHelpBtnToAddBtn()
	local nor_frame =  display.newSpriteFrame("tianjiahaoyou0.png")
	local disabled_frame = display.newSpriteFrame("tianjiahaoyou1.png")
	self:getEaveView().btnHelp:setNormalSpriteFrame(nor_frame)
	self:getEaveView().btnHelp:setSelectedSpriteFrame(disabled_frame)
	self:getEaveView().btnHelp:setDisabledSpriteFrame(disabled_frame)
	self:getEaveView().btnHelp:setVisible(false)
end

function FrindMenuView:showHelpBtn(isShow)
	self:getEaveView().btnHelp:setVisible(isShow)
end

function FrindMenuView:tabControlOnClick(idx)
	_executeNewBird()
	self._curMenuIndex = idx
	if idx == 0 then
		local ApplyFriendHasNewEvent = self:hasNewEvent()
		self:getTabMenu():setTipImgVisible(2, ApplyFriendHasNewEvent)
		self:onFriendListCallBack()
	elseif idx == 1 then
		self:getTabMenu():setTipImgVisible(2, false)

		self:onApplyFriendCallBack()
	elseif idx == 2 then
		local ApplyFriendHasNewEvent = self:hasNewEvent()
		self:getTabMenu():setTipImgVisible(2, ApplyFriendHasNewEvent)
		self:onRecommendFriendCallback()
	else
		assert(false,"FrindMenuView idx is error")
		return
	end
end


function FrindMenuView:onFriendListCallBack()
	print("onFriendListCallBack" )
	_playSnd(SFX_CLICK)
	local friendController = self:getDelegate()
	friendController:dispFriendListView()
	self:setActiveBtn(1)
end

function FrindMenuView:onApplyFriendCallBack()
	print("onApplyFriendCallBack"  )
	_playSnd(SFX_CLICK)
	local friendController = self:getDelegate()
	friendController:dispApplyFriendView()
	self:setActiveBtn(2)
end

function FrindMenuView:onRecommendFriendCallback()
	print("onRecommendFriendCallback")
	_playSnd(SFX_CLICK)
	local friendController = self:getDelegate()
	friendController:dispRecommendFriendView()
	self:setActiveBtn(3)
end

function FrindMenuView:setActiveBtn(tag) --set state(true or false) of button
--	if self._curBtn ~= nil then
--		self._curBtn:setEnabled(true)
--	end
--	if tag == 1 then
--		self._curBtn = self.friendListBtn
--	elseif tag == 2 then
--		self._curBtn = self.applyFriendBtn
--	elseif tag == 3 then
--		self._curBtn = self.recommendFriendBtn
--	else
--		return
--	end
--	self._curBtn:setEnabled(false)
end

function FrindMenuView:hasNewEvent()
	local bRet = false
	local arr = Friend:Instance():getApplyFriend()
	if arr ~= nil and table.getn(arr) > 0 then
		bRet = true
	end
	return bRet
end

-- modify to add friend
function FrindMenuView:onHelpHandler()
	local control = self:getDelegate()

	if control~= nil and control:getCurViewTag() == 1 then
		local friendListView = control:getFriendCurView()
		friendListView:onAddFriendCallBack()
	end
end

function FrindMenuView:onBackHandler()
	FrindMenuView.super:onBackHandler()
	self:getDelegate():goBackView()
end

function FrindMenuView:onExit()
	echo("---FrindMenuView:onExit---")
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("friend/friendNew.plist")
end


return   FrindMenuView
