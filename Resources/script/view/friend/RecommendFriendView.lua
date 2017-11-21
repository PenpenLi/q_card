RecommendFriendView = class("RecommendFriendView",BaseView)

function RecommendFriendView:ctor(control)
	ApplyFriendView.super.ctor(self)
	self:setDelegate(control)
  self:setNodeEventEnabled(true)
end

function RecommendFriendView:enter()
	local pkg = ccbRegisterPkg.new(self)
	pkg:addProperty("holdBtn","CCControlButton")

	pkg:addProperty("refreshListBtn","CCControlButton")
	pkg:addProperty("listContainer","CCNode")
	pkg:addProperty("friendCount","CCLabelTTF")
	pkg:addProperty("bottomNode","CCNode")
	pkg:addProperty("friend_font","CCLabelTTF")
	pkg:addProperty("label_leadshipInc","CCLabelTTF")
--	pkg:addFunc("addFriendCallBack",RecommendFriendView.onAddFriendCallBack)
	pkg:addFunc("refreshListCallBack",RecommendFriendView.onRefreshListCallBack)

	pkg:addFunc("holdBtnCallBack",RecommendFriendView.dumyCallBack)
	pkg:addFunc("refreshListCallBack",RecommendFriendView.dumyCallBack)

	local layer,owner = ccbHelper.load("FriendListView.ccbi","FriendListViewCCB","CCLayer",pkg)
	self:addChild(layer)
	self.friend_font:setString(_tr("friend_font"))
	self.holdBtn:removeFromParent()
	self.refreshListBtn:setVisible(true)
	self.refreshListBtn:setTouchPriority(-2)
	self._recommendFriendList = Friend:Instance():getRecommendFriend()
	UIHelper.setIsNeedScrollList(true)
	local friendListArray = Friend:Instance():getCurrentFriend()
	local feriendNum = 0
	if friendListArray ~= nil then
		feriendNum =  #friendListArray
	end
	local iMaxFriendCount = Friend:Instance():getFriendMaxCount()
	local strFrinedNum = string.format("%d/%d",feriendNum,iMaxFriendCount)
	self.friendCount:setString(strFrinedNum)
	self.label_leadshipInc:setString(_tr("can_add_leadship_%{count}", {count=feriendNum}))
	
	self.listContainer:setPositionX((display.width-640)/2.0)
	self.bottomNode:setPositionX((display.width-640)/2.0)
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

	local function tableCellAtIndex2(table, idx)  -- 次优化的方法会使列表乱掉
		local cell = table:dequeueCell()
		local friendCell = nil
		if nil == cell then
			cell = CCTableViewCell:new()
			friendCell = FriendListCellView.new(self,idx)
			cell:addChild(friendCell)
		else
			friendCell = cell:getChildByTag(123)
		end
		local itemData = self._recommendFriendList[idx+1]

		if friendCell ~= nil then
			friendCell:setDelegate(self:getDelegate())
			friendCell:enter()
			friendCell:setFriendData(itemData)
			friendCell:setContainer( self.listContainer)
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
		local itemData = self._recommendFriendList[idx+1]
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
		if self._recommendFriendList ~= nil  then
			length = #self._recommendFriendList
		end
		return  length
	end

	--local mSize = CCSizeMake(self.listContainer:getContentSize().width,self.listContainer:getContentSize().height+5)
	local size = self:getParent():getCanvasContentSize()
	local mSize = CCSizeMake(640,size.height - 73)
	--local mSize = CCSizeMake(self.listContainer:getContentSize().width,self:getDelegate():getScene():getMiddleContentSize().height-self:getParent():getEaveContentSize().height-200)
	self._firstShowCellNum = math.ceil(mSize.height/ConfigListCellHeight)
	self.tableView = CCTableView:create(mSize)
	self.tableView:setDirection(kCCScrollViewDirectionVertical)
	self.tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	self.listContainer:addChild(self.tableView)
	self.tableView:setPositionX(0)
	self.listContainer:setContentSize(mSize)
	--registerScriptHandler functions must be before the reloadData function
	self.tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
	self.tableView:registerScriptHandler(scrollViewDidZoom,CCTableView.kTableViewZoom)
	self.tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
	self.tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
	self.tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
	self.tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
	self.tableView:reloadData()

end


function RecommendFriendView:onRefreshListCallBack()
	print("onRefreshListCallBack" )
	_playSnd(SFX_CLICK)
	Friend:Instance():reqFriendList("QUERY_RECOMMEND")

	local function reloadTableData()
		self._recommendFriendList = Friend:Instance():getRecommendFriend()
		self.tableView:reloadData()
	end

	local array = CCArray:create()
	array:addObject( CCDelayTime:create(0.5))
	array:addObject(CCCallFunc:create( reloadTableData ))
	local action = CCSequence:create(array)
	self:runAction(action)
end

function RecommendFriendView:updataTableViewAtIndex(index,frinedId)
	for i=#self._recommendFriendList,1,-1 do
		if self._recommendFriendList[i]:getFriendId() == frinedId then
			table.remove(self._recommendFriendList,i)
			--break
		end
	end
	self.tableView:reloadData()
end

function RecommendFriendView:onExit()
end

function RecommendFriendView:exit()
	self:removeFromParentAndCleanup(true)
end

function RecommendFriendView:dumyCallBack()
end 


return RecommendFriendView