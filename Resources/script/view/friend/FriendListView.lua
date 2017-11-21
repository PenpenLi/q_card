require("model.Friend")
require("view.friend.FriendListCellView")
require("model.FriendData")
require("view.component.Toast")
require("view.friend.QuickWork")

FriendListView = class("FriendListView",BaseView)

function FriendListView:ctor(control)
	 FriendListView.super.ctor(self)
	 self:setNodeEventEnabled(true)
	 self:setDelegate(control)
end

function FriendListView:enter()
	local pkg = ccbRegisterPkg.new(self)
	pkg:addProperty("refreshListBtn","CCControlButton")
	pkg:addProperty("holdBtn","CCControlButton")
	pkg:addProperty("enterBtn","CCControlButton")
	pkg:addProperty("friendCount","CCLabelTTF")
	pkg:addProperty("bottomNode","CCNode")
	pkg:addProperty("listContainer","CCNode")
	pkg:addProperty("friend_font","CCLabelTTF")
	pkg:addProperty("label_leadshipInc","CCLabelTTF")

	--register handler
	pkg:addFunc("holdBtnCallBack",FriendListView.onHoldBtnCallBack)
	pkg:addFunc("refreshListCallBack",FriendListView.onRefreshListCallBack)
	local layer,owner = ccbHelper.load("FriendListView.ccbi","FriendListViewCCB","CCLayer",pkg)
	self:addChild(layer)
	self.friend_font:setString(_tr("friend_font"))
	self.holdBtn:setTouchPriority(-2)
	self.refreshListBtn:setVisible(false)

	-- if Mining:Instance():getMinerConfig() == nil then
	-- 	self.holdBtn:setEnabled(false)
	-- end

	self.friendListArray =  Friend:Instance():getCurrentFriend()
	UIHelper.setIsNeedScrollList(true)
	self.listContainer:setPositionX((display.width-640)/2.0)
	self.bottomNode:setPositionX((display.width-640)/2.0)
	local feriendNum = 0
	if self.friendListArray ~= nil then
		feriendNum =  #self.friendListArray
	end

	local iMaxFriendCount = Friend:Instance():getFriendMaxCount()
	local strFrinedNum = string.format("%d/%d",feriendNum,iMaxFriendCount)
	self.friendCount:setString(strFrinedNum)
	self.label_leadshipInc:setString(_tr("can_add_leadship_%{count}", {count=feriendNum}))
	
	Friend:setFriendListVirw(self)
	self.tableView = nil

	local function scrollViewDidScroll(view)
	--	print("scrollViewDidScroll")
	end

	local function scrollViewDidZoom(view)
	--	print("scrollViewDidZoom")
	end

	local function tableCellTouched(tbview,cell)

	end

	local function cellSizeForTable(tbview,idx)
		return ConfigListCellHeight,ConfigListCellWidth
	end

	local function tableCellAtIndex(tbview, idx)   -- 优化的方法 但可能会使列表数据乱掉

		local item = nil
		local data = self.friendListArray[idx+1]
		local cell = tbview:dequeueCell()
		if nil == cell then
			cell = CCTableViewCell:new()
			item = FriendListCellView.new(self,idx)
			item:setDelegate(self:getDelegate())
			item:enter()
			item:setFriendData(data)
			item:setContainer( self.listContainer)
			item:setTag(123)
			cell:addChild(item)
		else
			item = cell:getChildByTag(123)
			if item ~= nil then
				item:setFriendData(data)
			end
		end

		UIHelper.showScrollListView({object = item,totalCount =  self._firstShowCellNum ,index = idx})
		return cell

	end

	local function tableCellAtIndex2(tbview, idx) -- 没有优化的方法
		local cell = table:dequeueCell()
		local friendCell = nil
		if nil == cell then
			cell = CCTableViewCell:new()
		else
			cell:removeChild(cell:getChildByTag(123),true)
		end
		local itemData = self.friendListArray[idx+1]
		friendCell = FriendListCellView.new(self,idx)
		friendCell:setDelegate(self:getDelegate())
		friendCell:enter()
		friendCell:setFriendData(itemData)
		friendCell:setContainer( self.listContainer)
		friendCell:setTag(123)
		cell:addChild(friendCell)
		--cell:setIdx(idx)
		UIHelper.showScrollListView({object = friendCell,totalCount =  self._firstShowCellNum ,index = idx })
		return cell
	end

	local function numberOfCellsInTableView(val)
		local length =0
		if self.friendListArray ~= nil then
			length = table.getn(self.friendListArray)
		end
		return length
	end
	--self.listContainer:setPosition(ccp(30,220))
	local size = self:getParent():getCanvasContentSize()
	--local mSize = CCSizeMake(self.listContainer:getContentSize().width,self:getDelegate():getScene():getMiddleContentSize().height-self:getParent():getEaveContentSize().height-200)
	local mSize = CCSizeMake(640,size.height - 73)
	self._firstShowCellNum = math.ceil(math.ceil(mSize.height/ConfigListCellHeight))
	self.tableView = CCTableView:create(mSize)
	self.tableView:setDirection(kCCScrollViewDirectionVertical)
	self.tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	self.listContainer:addChild(self.tableView)
	self.listContainer:setContentSize(mSize)
	self.tableView:setPositionX(0)
	--self.tableView:setPosition(ccp(self.tableView:getPositionX()+10,self.tableView:getPositionY()))
	--registerScriptHandler functions must be before the reloadData function
	self.tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
	self.tableView:registerScriptHandler(scrollViewDidZoom,CCTableView.kTableViewZoom)
	self.tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
	self.tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
	self.tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
	self.tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
	self.tableView:reloadData()

	--self.containerFiltrate:setPositionY(self.listContainer:getPositionY()+mSize.height+10)

end

function FriendListView:onAddFriendCallBack()
	_playSnd(SFX_CLICK)
	local addFriendPopView = self:getChildByTag(615)
	if addFriendPopView ~= nil then
		return
	end

	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("friend/friendNew.plist","friend/friendNew.png")
	local pkg = ccbRegisterPkg.new(self)
	pkg:addFunc("confirmBtnCallBack",FriendListView.addFriendConfirmBtnCallBack)
	pkg:addFunc("returnCallBack",FriendListView.returnBtnCallBack)
	pkg:addProperty("nameInputBg","CCScale9Sprite")
	pkg:addProperty("confirmBtn","CCControlButton")
	pkg:addProperty("diceBtn","CCControlButton")
	pkg:addProperty("returnBtn","CCControlButton")
	pkg:addProperty("inputText","CCLabelTTF")
	pkg:addProperty("tips","CCLabelTTF")
	pkg:addProperty("titleName","CCSprite")
	pkg:addProperty("tishiFont","CCSprite")
	pkg:addProperty("niChenFont","CCSprite")
	pkg:addProperty("mainMenu","CCMenu")


	local layer,owner = ccbHelper.load("CreatePlayerName.ccbi","CreatePlayNameCCB","CCLayer",pkg)
	self.friendName = UIHelper.convertBgToEditBox(self.nameInputBg,_tr("please_input_friend_nick_name"),25,ccc3(255,0,0),false,12)

	self.friendName:registerScriptEditBoxHandler(function(strEventName,pSender) return self:editBoxTextEventHandle(strEventName,pSender) end)

	local mask = Mask.new({opacity = 200,priority = -149})
	mask:addChild(layer)
	self:addChild(mask)
	mask:setTag(615)

	self.friendName:setTouchPriority(-150)
	--init frame
	self.mainMenu:setTouchPriority(-150)
	self.mainMenu:setVisible(true)

	self.diceBtn:removeFromParentAndCleanup(true)
	self.confirmBtn:removeFromParentAndCleanup(true)
	self.tips:removeFromParentAndCleanup(true)
	self.inputText:setPosition(ccp(self.niChenFont:getPosition()))
	self.niChenFont:removeFromParentAndCleanup(true)
	--self.titleName:
	self.tishiFont:setPosition(self.titleName:getPosition())
	self.titleName:removeFromParentAndCleanup(true)

	layer:setScale(0.2)
	layer:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6))
	self.inputText:setString(_tr("input_name"))
end

function FriendListView:onRefreshListCallBack()

end

function FriendListView:onHoldBtnCallBack()
	local quickConfigPopView = QuickWork.new()
	quickConfigPopView:enter()
	self:addChild(quickConfigPopView)
end

function FriendListView:addFriendConfirmBtnCallBack()
	print("addFriendConfirmBtnCallBack begin")
	local nickName = GameData:Instance():getCurrentPlayer():getName()
	local inputName = self.friendName:getText()   -- get input username
	if inputName == "" then
		print("User name can't be empty")
		Toast:showString(GameData:Instance():getCurrentScene(), _tr("friend_name_can_not_be_emety"), ccp(display.cx, display.cy))
	elseif inputName == nickName then
		Toast:showString(GameData:Instance():getCurrentScene(), _tr("disable_search_self"), ccp(display.cx, display.cy))
	else
		local popView = self:getChildByTag(615)
		if popView ~= nil then
			popView:removeFromParentAndCleanup(true)
		end
		-- TODO 判断要添加的好友是否已经在自己的申请列表,如果已经在申请列表，则玩家不能添加该好友
		local applyListArray = Friend:Instance():getApplyFriend()
		if applyListArray ~= nil then
			for i=#applyListArray,1,-1 do
				if applyListArray[i]:getFriendId() == inputName then
					Toast:showIcon("friend/yizailiebiao.png" ,ccp(display.cx, display.cy))
					return
				end
			end
		end
		-- 发送好友姓名
		Friend:MsgC2SInviteFriend(inputName)
	end
end
--function FriendListView:onRefreshListCallBack()
--	print("FriendListView.lua<FriendListView:onRefreshListCallBack>11111 : ")
--end

function FriendListView:editBoxTextEventHandle(strEventName,pSender)
	--self.confirmBtn:setHighlighted(true)
	local edit = tolua.cast(pSender,"CCEditBox")
	local strFmt
	if strEventName == "began" then
		strFmt = string.format("editBox %p DidBegin !", edit)
		print(strFmt)
	elseif strEventName == "ended" then
		strFmt = string.format("editBox %p DidEnd !", edit)
		print(strFmt)
	elseif strEventName == "return" then
		strFmt = string.format("editBox %p was returned !",edit)
		print(strFmt)
	elseif strEventName == "changed" then
		strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
		print(strFmt)
	end
end


function FriendListView:returnBtnCallBack()
	print("returnBtnCallBack")

	local popView = self:getChildByTag(615)
	if popView ~= nil then
		popView:removeFromParentAndCleanup(true)
	end

end

function FriendListView:updataTableViewAtIndex(index)
	self.tableView:removeCellAtIndex(index)
end

function FriendListView:updataTableView()
	self.tableView:reloadData()
end

function FriendListView:removeFriendWithFriendId(friendId)
	Friend:Instance():removeOneFriendById(friendId)
	self:updateFriendNum()
	self:updataTableView()
end

function FriendListView:updateFriendNum()
	local friendListArray = Friend:Instance():getCurrentFriend()
	local feriendNum = #friendListArray
	local iMaxFriendCount = Friend:Instance():getFriendMaxCount()
	local strFrinedNum = string.format("%d/%d",feriendNum,iMaxFriendCount)
	self.friendCount:setString(strFrinedNum)
	self.label_leadshipInc:setString(_tr("can_add_leadship_%{count}", {count=feriendNum}))
end

function FriendListView:onExit()
  CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("friend/friendNew.plist")
end

function FriendListView:exit()
	self:removeFromParentAndCleanup(true)
end

return FriendListView