--shop market page
require("view.shop.component.PayListItemView")
require("model.Skill")
require("model.Pay")
require("GameInitConfig")

ShopPayView = class("ShopPayView", BaseView)

local ChannelPanelTag = 21111
local popViewTag = 31111

local function utf8_length(str)
	local len = 0
	local pos = 1
	local length = string.len(str)
	while true do
		local char = string.sub(str , pos , pos)
		local b = string.byte(char)
		if b >= 128 then
			pos = pos + 3
		else
			pos = pos + 1
		end
		len = len + 1
		if pos > length then
			break
		end
	end

	return len
end

local function utf8_sub(str , s , e)
	local t = {}
	local length = string.len(str)
	local pos = 1
	local offset = 1

	while true do
		local word = nil
		local char = string.sub(str , pos , pos)
		local b = string.byte(char)

		if b >= 128 then
			if offset >= s then
				word = string.sub(str , pos , pos + 2)
				table.insert(t , word)
			end
			pos = pos + 3
		else
			if offset >= s then
				word = char
				table.insert(t , word)
			end

			pos = pos + 1
		end
		offset = offset + 1
		if offset > e or pos > length then
			break
		end
	end

	return table.concat(t)
end


function ShopPayView:ctor()
	ShopPayView.super.ctor(self)
end

function ShopPayView:onEnter()
	net.registMsgCallback(PbMsgId.PlatformOrderResultS2C,self,ShopPayView.onPlatformOrderResultS2C) -- 处理支付结果

	self.listContainer = CCNode:create()

	local bottomHeight = self:getDelegate():getScene():getBottomContentSize().height
	self.listContainer:setPosition(ccp((display.width-640)/2, bottomHeight))
	self:addChild(self.listContainer)

	local playerLv =  GameData:Instance():getCurrentPlayer():getLevel() -- todo:添加人物等级的判断
	self.payChannelCount = Pay:Instance():getPayChannelsCount()
	self.isContainGooglePay = Pay:Instance():getHasGooglePay()

	self.areaIndex = 1
	self.payMethodIndex = 1
	print("payChannelCount===", self.payChannelCount, playerLv, ANDROID_PAY_COMBIN_PLAYER_LV)
	print("isContainGooglePay===", self.isContainGooglePay)

	if self.payChannelCount > 1 then 
		local payType = "googleWorld"
		local menuIndex = 1 		

		self._areaList = {_tr("Taiwan"),_tr("Hongkong"),_tr("Malaysia")}
		if self.isContainGooglePay then --google商店繁体版
			if playerLv < ANDROID_PAY_COMBIN_PLAYER_LV then 
				self:createPayList()
			end 
		else --官网繁体版(不带google)
			payType = "mycard"
			menuIndex = 2 
		end 

		self:addChannelPanel(payType)
		self:initCombinPayChannelLocalData()
		self:createPayList(payType)
		self:updateMenuState(menuIndex)
	else
		self:createPayList()
	end
end

function ShopPayView:onExit()
	net.unregistAllCallback(self)
end

function ShopPayView:initCombinPayChannelLocalData()
	local PayChannel = AllConfig.paychannel
	self.gashPlusTWPayInfo = {}
	self.gashPlusHKPayInfo = {}
	self.gashPlusMYPayInfo = {}
	local myCardTW = {}
	for k, v in pairs(PayChannel) do
		local payData = {}
		payData.channel = v.channel
		payData.area = v.area
		payData.channel_name = v.channel_name
		payData.array = v.array
		payData.cuid = v.cuid
		payData.service = v.service
		payData.erpid = v.erpid
		if v.channel == "gashPlus" and v.area == "TW" then
			table.insert(self.gashPlusTWPayInfo,payData)
		elseif v.channel == "gashPlus" and v.area == "HK" then
			table.insert(self.gashPlusHKPayInfo,payData)
		elseif v.channel == "gashPlus" and v.area == "MY" then
			table.insert(self.gashPlusMYPayInfo,payData)
		elseif v.channel == "mycard" and v.area == "TW" then
			table.insert(myCardTW,payData)
		end
	end
end

function ShopPayView:createPayList(payChannel,index)

	self.listContainer:removeAllChildrenWithCleanup(true)
	UIHelper.setIsNeedScrollList(true)

	local channelIndex = 1
	if payChannel == "googleWorld" or payChannel == "amazon" then
		channelIndex = 1
	elseif payChannel == "mycard" then
		channelIndex = 2
	elseif payChannel == "gashPlus" and index == 1 then
		channelIndex = 3
	elseif payChannel == "gashPlus" and index == 2 then
		channelIndex = 4
	elseif payChannel == "gashPlus" and index == 3 then
		channelIndex = 5
	elseif payChannel == "paypal" then
		channelIndex = 6
	else
		channelIndex = 1
	end

	self._listArray = Pay:Instance():getPayListDataByIndex(channelIndex)

	-- local function scrollViewDidScroll(view)
	-- 	-- print("scrollViewDidScroll")
	-- end
	local function tableCellTouched(table,cell)
		print("cell touched at index: " .. cell:getIdx())
		self.curSelectListIndex = cell:getIdx()
	end

	local function cellSizeForTable(table,idx)
		return ConfigListCellHeight,ConfigListCellWidth
	end

	local function tableCellAtIndex(table, idx)
		local cell = table:dequeueCell()
		if nil == cell then
			cell = CCTableViewCell:new()
		else
			cell:removeChild(cell:getChildByTag(123),true)
			cell:reset()
		end

		local itemData = self._listArray[idx+1]
		local singleSale = PayListItemView.new(idx)
		singleSale:setContainer(self.listContainer)
		singleSale:setDelegate(self:getDelegate())
		singleSale:setPayListItemData(itemData)
		singleSale:setTag(123)
		cell:setIdx(idx)

		UIHelper.showScrollListView({object = singleSale,totalCount =  self._firstShowCellNum ,index = idx,totalCells = #self._listArray})

		cell:addChild(singleSale)

		return cell
	end

	local function numberOfCellsInTableView(val)
		local length = 0
		if self._listArray ~= nil and #self._listArray > 0 then
			length = table.getn(self._listArray)
		end
		return length
	end

	--set tableView size
	local size = self:getParent():getCanvasContentSize()
	if payChannel == "googleWorld" then
		size.height = size.height - 120
	elseif payChannel == "mycard" then
		size.height = size.height - 120
	elseif payChannel == "paypal" then
		size.height = size.height - 120
	elseif  payChannel == "gashPlus" then
		size.height = size.height - 230
	end

	self._firstShowCellNum = math.ceil(size.height / ConfigListCellHeight)
	self._tableView = CCTableView:create(size)
	self._tableView:setDirection(kCCScrollViewDirectionVertical)
	self.listContainer:addChild(self._tableView)
	self._tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	self.listContainer:setContentSize(size)

	-- self._tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
	self._tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
	self._tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
	self._tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
	self._tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
	self._tableView:reloadData()
end

function ShopPayView:updateCellWithIndex(index)
	if self._tableView ~= nil then
		echo("===updateCellWithIndex, goodsType=", self._listArray[index+1].goodsType)
		if self._listArray[index+1].goodsType == 2 then --VIP
			self._tableView:reloadData()
		else 
			self._tableView:updateCellAtIndex(index)
		end
	end
end

function ShopPayView:onPlatformOrderResultS2C(action,msgId,msg)
	echo("=== ShopPayView:onPlatformOrderResultS2C")
	local function updateView()
		if self.curSelectListIndex ~= nil then
			self:updateCellWithIndex(self.curSelectListIndex)
		end 
	end 
	self:performWithDelay(updateView, 0.5)
end

function ShopPayView:addChannelPanel(payChannel)
	self:removeChildByTag(ChannelPanelTag)

	local pkg = ccbRegisterPkg.new(self)
	--payMethodBtnCallback areaChangeBtnCallBack menuCallBack1 areaFont

	pkg:addProperty("pay_check_ball1","CCSprite")
	pkg:addProperty("pay_check_ball2","CCSprite")
	pkg:addProperty("pay_check_ball3","CCSprite")
	pkg:addProperty("pay_check_ball4","CCSprite")
	pkg:addProperty("areaNode","CCNode")
	pkg:addProperty("payMethodNode","CCNode")
	pkg:addProperty("areaFont","CCLabelTTF")
	pkg:addProperty("payMethodFont","CCLabelTTF")
	pkg:addProperty("payMethodNode","CCLabelTTF")
	pkg:addProperty("pay_font1","CCLabelTTF")
	pkg:addProperty("areaNodeMenu","CCNode")
	pkg:addProperty("payMethodNodeMenu","CCNode")
	pkg:addProperty("areaBtn","CCControlButton")
	pkg:addProperty("payMethodBtn","CCControlButton")
	pkg:addProperty("node_google","CCNode")
	pkg:addProperty("node_mycard","CCNode")
	pkg:addProperty("node_gash","CCNode")
	pkg:addProperty("node_paypal","CCNode")

	pkg:addFunc("menuCallBack1",ShopPayView.menuCallBack1)
	pkg:addFunc("menuCallBack2",ShopPayView.menuCallBack2)
	pkg:addFunc("menuCallBack3",ShopPayView.menuCallBack3)
	pkg:addFunc("menuCallBack4",ShopPayView.menuCallBack4)
	pkg:addFunc("payMethodBtnCallback",ShopPayView.payMethodBtnCallback )
	pkg:addFunc("areaChangeBtnCallBack",ShopPayView.areaChangeBtnCallBack)

	local layer,owner = ccbHelper.load("PayChannelPanel.ccbi","PayChannelPanelCCB","CCLayer",pkg)
	local size = self:getParent():getCanvasContentSize()
	layer:setPosition(ccp(0,135+size.height-230.0))
	self._panelLayer = layer
	self:addChild(layer,ChannelPanelTag,ChannelPanelTag)
	self.areaBtn:setTouchPriority(-2)
	self.payMethodBtn:setTouchPriority(-2)

	--官网包不包含google支付方式
	if self.payChannelCount > 1 and self.isContainGooglePay == false then 
		self.node_google:setVisible(false)
		self.node_mycard:setPositionX(self.node_mycard:getPositionX()-80)
		self.node_gash:setPositionX(self.node_gash:getPositionX()-80)
		self.node_paypal:setPositionX(self.node_paypal:getPositionX()-80)
	end 

	if payChannel ~= "gashPlus" then --payChannel == "googleWorld" or payChannel == "mycard" or payChannel == "paypal" then
		self.areaNode:removeFromParentAndCleanup(true)
		self.payMethodNode:removeFromParentAndCleanup(true)
		self.pay_check_ball1:setVisible(true)
	-- elseif payChannel == "gashPlus" then
	end

	self.pay_font1:setString(string._tran(Consts.Strings.PLS_SELECT_CHARGE_MODE))
end

function ShopPayView:areaChangeBtnCallBack()
	self.areaIndex = 1
	self.payMethodIndex = 1
	self:createPopupView(self._areaList,"area")
end

function ShopPayView:getPayMethodListWithAreaIndex(areaIndex)
	local curMethodData = {}

	if areaIndex == 1 then
		curMethodData = self.gashPlusTWPayInfo
	elseif areaIndex == 2     then
		curMethodData = self.gashPlusHKPayInfo
	elseif areaIndex == 3 then
		curMethodData =  self.gashPlusMYPayInfo
	end

	return curMethodData
end

function ShopPayView:payMethodBtnCallback()
	self.payMethodIndex = 1  --payMethod
	self.curMethodDada = self:getPayMethodListWithAreaIndex(self.areaIndex)
	self:createPopupView(self.curMethodDada,"payMethod")
end

function ShopPayView:updateMenuState(index)
	local balls = {self.pay_check_ball1,self.pay_check_ball2,self.pay_check_ball3,self.pay_check_ball4}

	for i = 1, #balls, 1 do
		if i == index then
			balls[i]:setVisible(true)
		else
			balls[i]:setVisible(false)
		end
	end
end

function ShopPayView:getAreaIndex()
	return 	self.areaIndex
end

function ShopPayView:getPayMethodIndex()
	return self.payMethodIndex
end

function ShopPayView:setChannelpayParm()
	local parm = {}
	if self.areaIndex == 1 then
		parm = self.gashPlusTWPayInfo[self.payMethodIndex]
	elseif self.areaIndex == 2 then
		parm = self.gashPlusHKPayInfo[self.payMethodIndex]
	elseif self.areaIndex == 3 then
		parm = self.gashPlusMYPayInfo[self.payMethodIndex]
	end

	Pay:Instance():setPayPram4GashChannel(parm)
end

function ShopPayView:createPopupView(tableData,type)

	local pkg = ccbRegisterPkg.new(self)
	pkg:addProperty("layerContainer","CCLayer")
	pkg:addProperty("quedingBtn","CCControlButton")

	local layer,owner = ccbHelper.load("PayChannelPopupView.ccbi","PayChannelPopupViewCCB","CCLayer",pkg)
	local mask = Mask.new({opacity = 200,priority = -149})
	mask:addChild(layer)
	self:addChild(mask,popViewTag,popViewTag)
	self.quedingBtn:setVisible(false)
	layer:setScale(0.2)
	layer:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6) )
	local size = self.layerContainer:getContentSize()


	local function tableCellTouched(tbview,cell)
		print("idx ====",cell:getIdx()+1,type)
		if type == "area" then
			self.areaIndex = cell:getIdx()+1
			self.areaFont:setString(tableData[self.areaIndex])
			self:createPayList("gashPlus",self.areaIndex)

			self.payMethodIndex = 1
			local methodList = self:getPayMethodListWithAreaIndex(self.areaIndex)
			self.payMethodFont:setString(methodList[self.payMethodIndex].channel_name)
			self:setChannelpayParm()

		elseif type== "payMethod" then
			self.payMethodIndex = cell:getIdx()+1

			local str = tableData[self.payMethodIndex].channel_name
			if utf8_length(str) > 8 then
				str = utf8_sub(str,1,8).." ..."
			end
			self.payMethodFont:setString(str)
			self:setChannelpayParm()
		end
		self:removeChildByTag(popViewTag)
	end

	local function cellSizeForTable(tbview,idx)
		return 40,size.width
	end

	local function tableCellAtIndex(tbview, idx) -- 没有优化的方法

		print("index ====",idx)
		local cell = tbview:dequeueCell()
		local listCell = nil
		if nil == cell then
			cell = CCTableViewCell:new()
		else
			cell:removeChild(cell:getChildByTag(123),true)
			cell:reset()
		end

		if type == "area" then
			listCell = CCLabelTTF:create(tableData[idx+1],"Courier-Bold",24.0)
		else
			listCell = CCLabelTTF:create(tableData[idx+1].channel_name,"Courier-Bold",24.0)
		end
		listCell:setPosition(ccp(self.layerContainer:getContentSize().width/2,20))
		listCell:setTag(123)

		cell:addChild(listCell)
		return cell
	end

	local function numberOfCellsInTableView(val)
		local length
		if tableData ~= nil then
			length = table.getn(tableData)
		end
		return length
	end

	local mSize = CCSizeMake(size.width,size.height)
	local tableView1 = CCTableView:create(mSize)
	tableView1:setDirection(kCCScrollViewDirectionVertical)
	tableView1:setVerticalFillOrder(kCCTableViewFillTopDown)
	self.layerContainer:addChild(tableView1)
	tableView1:setTouchPriority(-150)
	tableView1:setPosition(ccp(0,0))

	-- tableView1:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
	tableView1:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
	tableView1:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
	tableView1:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
	tableView1:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
	tableView1:reloadData()
end

function ShopPayView:menuCallBack1()
	print("===menuCallBack1, googleWorld")
	self:createPayList("googleWorld")
	self:addChannelPanel("googleWorld")
	self:updateMenuState(1)
end

function ShopPayView:menuCallBack2()
	print("===menuCallBack2, mycard")
	self:createPayList("mycard")
	self:addChannelPanel("mycard")
	self:updateMenuState(2)
end

local function initChannelPayParm(self)
	self.areaIndex = 1
	self.payMethodIndex = 1
	self:setChannelpayParm()
	self.areaFont:setString(self._areaList[self.areaIndex])
	local methodList = self:getPayMethodListWithAreaIndex(self.areaIndex)
	self.payMethodFont:setString(methodList[self.payMethodIndex].channel_name)
end

function ShopPayView:menuCallBack3()
	print("===menuCallBack3, gashPlus")
	self:createPayList("gashPlus",1) -- default index == 1
	self:addChannelPanel("gashPlus")
	self:updateMenuState(3)
	initChannelPayParm(self)
end

function ShopPayView:menuCallBack4()
	print("===menuCallBack4, paypal")
	self:createPayList("paypal")
	self:addChannelPanel("paypal")
	self:updateMenuState(4)
	initChannelPayParm(self)
end

return ShopPayView