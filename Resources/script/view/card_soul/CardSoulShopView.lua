
require("view.BaseView")
require("model.card_soul.CardSoul")
require("view.card_soul.CardSoulShopListItem")
require("view.card_soul.CardSoulShopPopup")


CardSoulShopView = class("CardSoulShopView", BaseView)


function CardSoulShopView:ctor(viewType)

	CardSoulShopView.super.ctor(self)

	--1. load levelup view ccbi
	local pkg = ccbRegisterPkg.new(self)
	pkg:addFunc("refreshCallback",CardSoulShopView.refreshCallback)
	pkg:addFunc("sourceCallback",CardSoulShopView.sourceCallback)
	pkg:addProperty("node_list","CCNode")
	pkg:addProperty("node_refresh","CCNode")
	pkg:addProperty("sprite_fontBg","CCSprite")
	pkg:addProperty("sprite_banner","CCSprite")	
	pkg:addProperty("label_preLeftTime","CCLabelTTF")
	pkg:addProperty("label_leftTime","CCLabelBMFont")
	pkg:addProperty("label_preLeftCounts","CCLabelTTF")
	pkg:addProperty("label_leftCounts","CCLabelBMFont")	
	pkg:addProperty("label_preCloseTime","CCLabelTTF")
	pkg:addProperty("label_closeTime","CCLabelBMFont")	
	pkg:addProperty("bn_refresh","CCControlButton") 
  pkg:addProperty("bn_source","CCControlButton") 
  

	local layer,owner = ccbHelper.load("CardSoulShopView.ccbi","CardSoulShopViewCCB","CCLayer",pkg)
	self:addChild(layer)

	self.viewType = viewType 
end

function CardSoulShopView:onEnter()
	echo("---CardSoulShopView:onEnter---")
	net.registMsgCallback(PbMsgId.PlayerStoreInfoS2C,self,CardSoulShopView.updateListForRefresh)	--自动刷新
	net.registMsgCallback(PbMsgId.PlayerRefreshStoreResultS2C,self,CardSoulShopView.refreshResult) --手动刷新
	net.registMsgCallback(PbMsgId.InstanceRefresh,self,CardSoulShopView.systomRefresh)		--零点更新

	self.cols = 3 
	self.priority = 0 
	self.bn_refresh:setTouchPriority(self.priority)
	self.bn_source:setTouchPriority(self.priority)
	
	--set position of tab menu and list container 
	local refreshHeight = self.node_refresh:getContentSize().height
	local bottomHeight = self:getDelegate():getScene():getBottomContentSize().height
	local list_w = 640 --size.width
	local list_h = self:getDelegate():getListViewSize().height - refreshHeight - 5

	self.sprite_banner:setVisible(self.viewType == ShopCurViewType.Soul)
	self.bn_source:setVisible(self.viewType == ShopCurViewType.Soul)
	if self.sprite_banner:isVisible() then 
		list_h = list_h - self.sprite_banner:getContentSize().height 
		self.sprite_banner:setPositionY(bottomHeight+refreshHeight+list_h)
	end 
	self.node_refresh:setPositionY(bottomHeight)
	self.node_list:setPosition(ccp((display.width-list_w)/2, bottomHeight+refreshHeight))
	self.node_list:setContentSize(CCSizeMake(list_w, list_h))

	Shop:instance():setTipsNewData(self.viewType, false)

	--string 
	self:initOutLineLabel()

	self:setListButtonEnable(false)

	self:registerTouchEvent()
	
	self:showListView()
end 

function CardSoulShopView:onExit()
	echo("---CardSoulShopView:onExit---")
	net.unregistAllCallback(self) 
end


function CardSoulShopView:registerTouchEvent()
	local function onTouch(eventType, x, y)
		if eventType == "began" then
			self:pointIsInListRect(x,y)
			return false
		end
	end
	
	self:addTouchEventListener(onTouch, false, -300, true)
	self:setTouchEnabled(true)
end

function CardSoulShopView:pointIsInListRect(touch_x, touch_y)
	local isInRect = false 
	local listSize = self.node_list:getContentSize()
	local pos = self.node_list:convertToNodeSpace(ccp(touch_x, touch_y))
	if pos.x > 0 and pos.x < listSize.width and pos.y > 0 and pos.y < listSize.height then 
		isInRect = true
	end 

	self:setListButtonEnable(isInRect)
end

function CardSoulShopView:setListButtonEnable(isEnable)
	self._isBnEnable = isEnable
end 

function CardSoulShopView:getListButtonEnable()
	return self._isBnEnable
end 

function CardSoulShopView:setIsTouchEvent(isTouchEvent)
	self._isTouch = isTouchEvent
end 

function CardSoulShopView:getIsTouchEvent()
	return self._isTouch
end 

function CardSoulShopView:showListView()

	self.dataArray = Shop:instance():getShopData(self.viewType) 
	self.dataLen = #self.dataArray
	echo("showListView, dataLen=", self.dataLen)

	-- local function scrollViewDidScroll(view)
	-- end

	local function tableCellTouched(tbView,cell)   
		self:setIsTouchEvent(true)
	end

	local function tableCellAtIndex(tbView, idx)
		-- echo("tableCellAtIndex = "..idx)
		local cell = tbView:dequeueCell()

		if nil == cell then
			cell = CCTableViewCell:new()
		else 
			cell:removeAllChildrenWithCleanup(true)
		end 

		local item = CardSoulShopListItem.new()
		if item ~= nil then 
			-- item:setButtonEnableDelegate(function() return self:getListButtonEnable() end)
			local data = {}
			local count = math.min(self.cols, self.dataLen-idx*self.cols)
			for i=1, count do 
				data[i] = self.dataArray[idx*self.cols+i]
			end 
			item:setPriority(self.priority+2)
			item:setIdx(idx)
			item:setChips(data)
			item:setDelegate(self)
			cell:addChild(item)
		end 

		return cell
	end
	
	local function cellSizeForTable(tbView,idx)
		return self.cellHeight,self.cellWidth
	end

	local function numberOfCellsInTableView(tableview)
		return self.totalCells
	end


	self.node_list:removeAllChildrenWithCleanup(true)
	local listSize = self.node_list:getContentSize()
	self.cellWidth = listSize.width 
	self.cellHeight = 202
	self.totalCells = math.ceil(#self.dataArray/self.cols)

	--create table view
	self.tableView = CCTableView:create(listSize)
	self.node_list:addChild(self.tableView)
	self.tableView:setDirection(kCCScrollViewDirectionVertical)
	self.tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	self.tableView:setTouchPriority(self.priority+1)

	-- self.tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
	self.tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
	self.tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
	self.tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
	self.tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
	self.tableView:reloadData()

	local freeLimit = Shop:instance():getTotalFreeRefreshCount(self.viewType)
	local payLimit = Shop:instance():getTotalPayRefreshCount(self.viewType)
	local usedCount = Shop:instance():getUsedFreeRefreshCount(self.viewType)
	echo("=== showRefreshCounts: used, total", usedCount, freeLimit)
	self.label_leftCounts:setString(string.format("%d/%d", math.max(0,freeLimit-usedCount), freeLimit))

	echo("=== showRefreshCounts: used, total, limit", usedCount, freeLimit, payLimit)
	self.bn_refresh:setEnabled(payLimit<0 or usedCount<payLimit)
	
	self:showRefreshTime()
end

function CardSoulShopView:showPopupToBuy(chipIndex)
	echo("=== chipIndex", chipIndex)
	local item = self.dataArray[chipIndex]
	local pop = CardSoulShopPopup.new()
	pop:setDelegate(self)
	pop:setDataIndex(chipIndex)
	pop:setData(item)
	GameData:Instance():getCurrentScene():addChild(pop, 666)
end 

function CardSoulShopView:initOutLineLabel()
	self.label_preLeftTime:setString("")
	local outline1 = ui.newTTFLabelWithOutline({
																							text = _tr("shop_free_refresh_time"),
																							font = self.label_preLeftTime:getFontName(),
																							size = self.label_preLeftTime:getFontSize(),
																							x = 0,
																							y = 0,
																							color = ccc3(255, 235, 0),
																							align = ui.TEXT_ALIGN_LEFT,
																							outlineColor =ccc3(0,0,0),
																							pixel = 2
																						}
																					)
	local pos = ccp(self.label_preLeftTime:getPositionX()-outline1:getContentSize().width-5, self.label_preLeftTime:getPositionY())
	outline1:setPosition(pos)
	self.label_preLeftTime:getParent():addChild(outline1) 

	self.label_preLeftCounts:setString("")
	local outline2 = ui.newTTFLabelWithOutline({
																							text = _tr("shop_free_refresh_count"),
																							font = self.label_preLeftCounts:getFontName(),
																							size = self.label_preLeftCounts:getFontSize(),
																							x = 0,
																							y = 0,
																							color = ccc3(255, 235, 0),
																							align = ui.TEXT_ALIGN_LEFT,
																							outlineColor =ccc3(0,0,0),
																							pixel = 2
																						}
																					)
	local pos2 = ccp(self.label_preLeftCounts:getPositionX()-outline2:getContentSize().width-5, self.label_preLeftCounts:getPositionY())
	outline2:setPosition(pos2)
	self.label_preLeftCounts:getParent():addChild(outline2)

	if self.viewType == ShopCurViewType.VIP then 	
		self.label_preCloseTime:setString("")
		local outline3 = ui.newTTFLabelWithOutline({
																								text = _tr("left_close_time"),
																								font = self.label_preCloseTime:getFontName(),
																								size = self.label_preCloseTime:getFontSize(),
																								x = 0,
																								y = 0,
																								color = ccc3(255, 235, 0),
																								align = ui.TEXT_ALIGN_LEFT,
																								outlineColor =ccc3(0,0,0),
																								pixel = 2
																							}
																						)
		local pos2 = ccp(self.label_preCloseTime:getPositionX()-outline3:getContentSize().width-5, self.label_preCloseTime:getPositionY())
		outline3:setPosition(pos2)
		self.label_preCloseTime:getParent():addChild(outline3)

		self.label_preCloseTime:setVisible(true)
		self.label_closeTime:setVisible(true)
		self.sprite_fontBg:setScaleY(1.2)

		self:showVIPCloseTime()
	else 
		self.label_preCloseTime:setVisible(false)
		self.label_closeTime:setVisible(false)
		self.sprite_fontBg:setScaleY(1.0)
	end 
end 

function CardSoulShopView:buyItem(index, count)
  self.buyIndex = index
  local buyCount = count or 1 
  
  if buyCount < 1 then 
    return 
  end 

  --卡牌碎片不需校验背包格子
  if self.viewType ~= ShopCurViewType.Soul and self:checkIsBagSpaceEnough() == false then 
    return 
  end 

  local shopItem = self.dataArray[self.buyIndex]
  local currencyType = shopItem:getCurrencyType()
  local needCurrency = shopItem:getDiscountPrice()
  if Shop:instance():checkHasEnoughCurrency(currencyType, needCurrency, true) == false then 
    return 
  end 
  Shop:instance():setView(self)
  Shop:instance():reqBuyItem(shopItem, buyCount)
end 

function CardSoulShopView:updateView() --buyItemResult
	if self.tableView ~= nil then 
		local idx = math.floor((self.buyIndex-1)/self.cols)
		self.tableView:updateCellAtIndex(idx)
	end 
end 


function CardSoulShopView:refreshCallback()
	local totalFreeCount = Shop:instance():getTotalFreeRefreshCount(self.viewType)
	local usedfreeCounts = Shop:instance():getUsedFreeRefreshCount(self.viewType)
	if usedfreeCounts < totalFreeCount then -- 免费刷新
		local data = PbRegist.pack(PbMsgId.PlayerRefreshStoreC2S, {type=self.viewType, use_money=0})
		net.sendMessage(PbMsgId.PlayerRefreshStoreC2S, data)
		self:addMaskLayer()
	else --元宝刷新
		local needMoney = Shop:instance():getPayRefreshCost(self.viewType)
		local function useMoneyToRefresh()
			if GameData:Instance():getCurrentPlayer():getMoney() >= needMoney then
				local data = PbRegist.pack(PbMsgId.PlayerRefreshStoreC2S, {type=self.viewType, use_money=1})
				net.sendMessage(PbMsgId.PlayerRefreshStoreC2S, data)
				self:addMaskLayer()
			else
				local pop = PopupView:createTextPopup(_tr("not_enough_money_to_refresh"), function() return self:getDelegate():gotoPayView() end)
				self:addChild(pop,100)
			end 
		end 

		local str = _tr("ask_pay%{coin}to_refresh",{coin = needMoney})
		local pop = PopupView:createTextPopup(str, useMoneyToRefresh)
		self:addChild(pop, 100)				
	end 
end 

function CardSoulShopView:sourceCallback()
	local view = ItemSourceView.new(20)
	self:addChild(view)
end 

function CardSoulShopView:refreshResult(action,msgId,msg)
	echo("=== refreshResult:", msg.error)
	if msg.error == "NO_ERROR_CODE" then 
		-- GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)
		-- Shop:instance():initShopData(msg)
    self:performWithDelay(function()
                self:updateListForRefresh()
                end, 0.5) 
	else 		
		Shop:instance():handleErrorCode(msg.error)
		self:removeMaskLayer()
	end 
end 

function CardSoulShopView:systomRefresh(action,msgId,msg)
	local totalCount = Shop:instance():getTotalFreeRefreshCount(self.viewType)
	local usedCount = Shop:instance():getUsedFreeRefreshCount(self.viewType)
	echo("=== CardSoulShopView:systomRefresh: used, total", usedCount, totalCount)
	self.label_leftCounts:setString(string.format("%d/%d", math.max(0,totalCount-usedCount), totalCount))
end 

function CardSoulShopView:getTimeStr(timeSec)
	local str = "00:00"
	if timeSec > 3600 then 
		str = math.floor(timeSec/3600).._tr("hour")
	elseif timeSec > 0 then 
		str = string.format("%02d:%02d", math.floor(timeSec/60), math.mod(timeSec,60))
	end 
	
	return str 
end 

function CardSoulShopView:showRefreshTime()

	local function updataRefreshTime(dt)
		self.leftSec = self.leftSec - 1 

		if self.leftSec <= 0 then
			self.label_leftTime:setString("00:00")
			if self.refreshTimer ~= nil then 
				self:unschedule(self.refreshTimer) 
				self.refreshTimer = nil 
			end 
		else 
			self.label_leftTime:setString(self:getTimeStr(self.leftSec))
		end
	end

	if self.refreshTimer ~= nil then 
		self:unschedule(self.refreshTimer)
		self.refreshTimer = nil 
	end 

	self.leftSec = Shop:instance():getLeftRefreshTime(self.viewType)
	if self.leftSec > 0 then 	
		self.label_leftTime:setString(self:getTimeStr(self.leftSec))
		self.refreshTimer = self:schedule(updataRefreshTime, 1.0)
	else 
		self.label_leftTime:setString("00:00")
	end 
	echo("===showRefreshTime:left", self.leftSec)
end 


function CardSoulShopView:showVIPCloseTime()

	local function updataCloseTime(dt)
		self.closeSec = self.closeSec - 1 

		if self.closeSec <= 0 then
			self.label_closeTime:setString("00:00")
			if self.closeTimer ~= nil then 
				self:unschedule(self.closeTimer)
				self.closeTimer = nil 
			end 
		else 
			self.label_closeTime:setString(self:getTimeStr(self.closeSec))
		end
	end

	if self.closeTimer ~= nil then 
		self:unschedule(self.closeTimer)
		self.closeTimer = nil 
	end 

	local _, leftSec = Shop:instance():checkShopOpen(self.viewType)
	self.closeSec = leftSec 
	if self.closeSec > 0 then 
		self.label_closeTime:setString(self:getTimeStr(self.closeSec))
		self.closeTimer = self:schedule(updataCloseTime, 1.0)
	else 
		self.label_closeTime:setString("00:00")
	end 
	echo("===showClsoeTime:left", self.closeSec)
end 




function CardSoulShopView:updateListForRefresh()
	echo("=== CardSoulShopView:updateListForRefresh")

	Shop:instance():setTipsNewData(self.viewType, false)
	
	local function updataTableView()
		self:showListView()

--		if self.loading ~= nil then 
--			self.loading:remove()
--			self.loading = nil 
--		end 
    _hideLoading()
		self:removeMaskLayer()

		local pop = GameData:Instance():getCurrentScene():getChildByTag(666)
		if pop ~= nil then 
			pop:removeFromParentAndCleanup(true)
		end 
	end
	--self.loading = Loading:show()
	_showLoading()
	local array = CCArray:create()
	array:addObject( CCDelayTime:create(0.5))
	array:addObject( CCCallFunc:create(updataTableView))
	self:runAction( CCSequence:create(array) )
end

function CardSoulShopView:checkIsBagSpaceEnough()
	local isEnough1 = GameData:Instance():getCurrentPackage():checkItemBagEnoughSpace(1) 
	if isEnough1 == false then
		local pop = PopupView:createTextPopupWithPath({leftNorBtn = "button-nor-zhengli.png",
																									 leftSelBtn = "button-sel-zhengli.png",
																									 text = _tr("bag is full,clean up?"),
																									 leftCallBack = function()                                                    
																											return self:getDelegate():goToItemView()
																									end})
		self:getDelegate():getScene():addChild(pop,100)
	end 

	return isEnough1
end 

function CardSoulShopView:addMaskLayer()
	echo("=== addMaskLayer")
	if self.maskLayer ~= nil then 
		self.maskLayer:removeFromParentAndCleanup(true)
	end 

	self.maskLayer = Mask.new({opacity=0, priority = -1000})
	self:addChild(self.maskLayer)

	self:performWithDelay(handler(self, CardSoulShopView.removeMaskLayer), 5.0)
end 

function CardSoulShopView:removeMaskLayer()
	echo("=== removeMaskLayer")
	if self.maskLayer ~= nil then 
		self.maskLayer:removeFromParentAndCleanup(true)
		self.maskLayer = nil 
	end 
end 
