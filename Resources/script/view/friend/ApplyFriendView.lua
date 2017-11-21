require("model.Friend")
require("view.friend.FriendListCellView")


ApplyFriendView = class("ApplyFriendView",BaseView)


function ApplyFriendView:ctor(control)
	ApplyFriendView.super.ctor(self)
	self:setDelegate(control)
end

function ApplyFriendView:enter()
	local pkg = ccbRegisterPkg.new(self)

	pkg:addProperty("holdBtn","CCControlButton")
	pkg:addProperty("refreshListBtn","CCControlButton")
	pkg:addProperty("listContainer","CCNode")
	pkg:addProperty("friendCount","CCLabelTTF")
	pkg:addProperty("friend_font","CCLabelTTF")
	pkg:addProperty("label_leadshipInc","CCLabelTTF")
	pkg:addProperty("bottomNode","CCNode")

	pkg:addFunc("holdBtnCallBack",ApplyFriendView.dumyCallBack)
	pkg:addFunc("refreshListCallBack",ApplyFriendView.dumyCallBack)

	local layer,owner = ccbHelper.load("FriendListView.ccbi","FriendListViewCCB","CCLayer",pkg)
	self:addChild(layer)
	self.friend_font:setString(_tr("friend_font"))
	self.holdBtn:removeFromParent()
	self.refreshListBtn:removeFromParent()
	UIHelper.setIsNeedScrollList(true)
	self.listContainer:setPositionX((display.width-640)/2.0)
	self.bottomNode:setPositionX((display.width-640)/2.0)
	self._applyListArray = Friend:Instance():getApplyFriend()
	--dump(self._applyListArray,"self._applyListArray")
	local friendListArray = Friend:Instance():getCurrentFriend()
	local feriendNum = 0
	if friendListArray ~= nil then
		feriendNum =  #friendListArray
	end
	local iMaxFriendCount = Friend:Instance():getFriendMaxCount()
	local strFrinedNum = string.format("%d/%d",feriendNum,iMaxFriendCount)
	self.friendCount:setString(strFrinedNum)
	self.label_leadshipInc:setString(_tr("can_add_leadship_%{count}", {count=feriendNum}))

	local function scrollViewDidScroll(view)
		--print("scrollViewDidScroll")
	end

	local function scrollViewDidZoom(view)
		print("scrollViewDidZoom")
	end

	local function tableCellTouched(table,cell)

	end

	local function cellSizeForTable(table,idx)
		return ConfigListCellHeight,ConfigListCellWidth
	end

	local function tableCellAtIndex2(table, idx) -- 优化过的方法 可能会使数据列表乱掉
		local cell = table:dequeueCell()
		local friendCell = nil
		if nil == cell then
			cell = CCTableViewCell:new()
			friendCell = FriendListCellView.new(self,idx)
			cell:addChild(friendCell)
		else
			friendCell = cell:getChildByTag(123)
		end

		local itemData = self._applyListArray[idx+1]

		if friendCell ~= nil then
			friendCell:setDelegate(self:getDelegate())
			friendCell:enter()
			friendCell:setFriendData(itemData)
			friendCell:setContainer( self.listContainer)
			--	friendCell:setShopItemData(itemData)
			friendCell:setTag(123)
			cell:setIdx(idx)
			UIHelper.showScrollListView({object = friendCell,totalCount =  self._firstShowCellNum ,index = idx })
		end
		return cell
	end

	local function tableCellAtIndex(table, idx)
		local cell = table:dequeueCell()
		local friendCell = nil
		if nil == cell then
			cell = CCTableViewCell:new()
		else
			cell:removeChild(cell:getChildByTag(123),true)
		end
		local itemData = self._applyListArray[idx+1]
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
		local length = 0
		if self._applyListArray ~= nil and  #self._applyListArray >= 0 then
			length = table.getn(self._applyListArray)
		end
		return length
	end

	--local mSize = CCSizeMake(self.listContainer:getContentSize().width,self.listContainer:getContentSize().height+5)
	local size = self:getParent():getCanvasContentSize()
	--local mSize = CCSizeMake(self.listContainer:getContentSize().width,self:getDelegate():getScene():getMiddleContentSize().height-self:getParent():getEaveContentSize().height-200)
	local mSize = CCSizeMake(640,size.height - 73)
	self._firstShowCellNum = math.ceil(mSize.height/ConfigListCellHeight)
	self.tableView = CCTableView:create(mSize)
	self.tableView:setDirection(kCCScrollViewDirectionVertical)
	self.tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	self.listContainer:addChild(self.tableView)
	self.listContainer:setContentSize(mSize)
	self.tableView:setPositionX(0)
	--registerScriptHandler functions must be before the reloadData function
	self.tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
	self.tableView:registerScriptHandler(scrollViewDidZoom,CCTableView.kTableViewZoom)
	self.tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
	self.tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
	self.tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
	self.tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
	self.tableView:reloadData()

	Friend:Instance():setApplyListView(self)
end

function ApplyFriendView:updataTableViewAtIndex(index,friendId)
	for i=#self._applyListArray,1,-1 do
		if self._applyListArray[i]:getFriendId() == friendId then
		   table.remove(self._applyListArray,i)
		   break
		end
	end
	self.tableView:reloadData()

end

function ApplyFriendView:updataTableView()
	self.tableView:reloadData()
end

function ApplyFriendView:onExit()

end

function ApplyFriendView:updateFriendCount()
	local friendListArray = Friend:Instance():getCurrentFriend()
	local feriendNum = #friendListArray
	local iMaxFriendCount = Friend:Instance():getFriendMaxCount()
	local strFrinedNum = string.format("%d/%d",feriendNum,iMaxFriendCount)
	self.friendCount:setString(strFrinedNum)
	self.label_leadshipInc:setString(_tr("can_add_leadship_%{count}", {count=feriendNum}))
end

function ApplyFriendView:exit()
	Friend:Instance():setApplyListView(nil)
	self:removeFromParentAndCleanup(true)
end

function ApplyFriendView:dumyCallBack()
end 

return ApplyFriendView

