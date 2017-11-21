
require("view.BaseView")


PayPanelPopUp = class("PayPanelPopUp", BaseView)

local ChannelPanelTag = 21111
local popViewTag = 30000


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


function PayPanelPopUp:ctor(payChannel)

	local pkg = ccbRegisterPkg.new(self)
	pkg:addProperty("layerContainer","CCLayer")
	pkg:addProperty("quedingBtn","CCControlButton")
	pkg:addFunc("confirmBtnCallBack",PayPanelPopUp.onConfirmBtnCallBack )

	local layer,owner = ccbHelper.load("PayChannelPopupView.ccbi","PayChannelPopupViewCCB","CCLayer",pkg)
	self.quedingBtn:setTouchPriority(-150)
	self:addChild(layer,1111,1111)
	layer:setScale(0.2)
	self.BgPopLayer = layer
	layer:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6) )
	self:createPanel("googleWorld")

	self._areaList = {_tr("Taiwan"),_tr("Hongkong"),_tr("Malaysia") }
	self.curSelectPayType = 1
	self.areaIndex = 1
	self.payMethodIndex = 1
	self:initCombinPayChannelLocalData()
end

function PayPanelPopUp:initCombinPayChannelLocalData()
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
		else

		end

	end
end

function PayPanelPopUp:onConfirmBtnCallBack()
	self:getParent():removeFromParentAndCleanup(true)
	local payList = Pay:Instance():getPayListDataByIndex(self.curSelectPayType)--- todo:
	self.vipCardData = nil
	for k, v in pairs(payList) do  --    默认第一列的数据
		if v.goodsType == 2 and v.count == 30 then   -- vip 30day`s
			self.vipCardData = v
		end
	end

	if self.vipCardData ~= nil  then
		local playerId = GameData:Instance():getCurrentPlayer():getId()
		print("playerId",playerId,self.vipCardData.channel)
		print("playerId",playerId)
		local serverId, serverName=  Pay:Instance():getPayServerIdAndName()
		local roleName = GameData:Instance():getCurrentPlayer():getName()
		local balance = GameData:Instance():getCurrentPlayer():getMoney()
		local userLevel =  GameData:Instance():getCurrentPlayer():getLevel()
		local pram = "roleName="..roleName.."&serverName="..serverName.."&balance="..balance.."&userLevel="..userLevel.."&paid=".."0".."&cuid=".."0".."&service=".."0".."&erpid=".."0"
		c_pay_item(self.vipCardData.goodsId,playerId,self.vipCardData.paymentCode,serverId,self.vipCardData.channel,pram)
	end
end

function PayPanelPopUp:createPanel(payChannel)

	self.BgPopLayer:removeChildByTag(ChannelPanelTag)
	local pkg = ccbRegisterPkg.new(self)
	pkg:addProperty("pay_check_ball1","CCSprite")
	pkg:addProperty("pay_check_ball2","CCSprite")
	pkg:addProperty("pay_check_ball3","CCSprite")
	pkg:addProperty("areaNode","CCNode")
	pkg:addProperty("payMethodNode","CCNode")
	pkg:addProperty("areaFont","CCLabelTTF")
	pkg:addProperty("payMethodFont","CCLabelTTF")
	pkg:addProperty("payMethodNode","CCLabelTTF")
	pkg:addProperty("areaNodeMenu","CCNode")
	pkg:addProperty("payMethodNodeMenu","CCNode")
	pkg:addProperty("areaBtn","CCControlButton")
	pkg:addProperty("payMethodBtn","CCControlButton")
	pkg:addProperty("mainMenu","CCMenu")

	pkg:addFunc("menuCallBack1",PayPanelPopUp.menuCallBack1)
	pkg:addFunc("menuCallBack2",PayPanelPopUp.menuCallBack2)
	pkg:addFunc("menuCallBack3",PayPanelPopUp.menuCallBack3)
	pkg:addFunc("payMethodBtnCallback",PayPanelPopUp.payMethodBtnCallback )
	pkg:addFunc("areaChangeBtnCallBack",PayPanelPopUp.areaChangeBtnCallBack)

	local layer,owner = ccbHelper.load("PayChannelPanel.ccbi","PayChannelPanelCCB","CCLayer",pkg)

	self.mainMenu:setTouchPriority(-150)
	self.areaBtn:setTouchPriority(-150)
	self.payMethodBtn:setTouchPriority(-150)

	if payChannel == "googleWorld" or payChannel == "mycard" then
		self.areaNode:removeFromParentAndCleanup(true)
		self.payMethodNode:removeFromParentAndCleanup(true)
		self.pay_check_ball1:setVisible(true)
	elseif payChannel == "gashPlus" then

	end

	layer:setPosition(ccp(0,display.cy-105))
	self.BgPopLayer:addChild(layer,ChannelPanelTag,ChannelPanelTag)
end

local function updateMenuState(self,index)
	local balls = {self.pay_check_ball1,self.pay_check_ball2,self.pay_check_ball3 }

	for i = 1, #balls, 1 do
		if i == index then
			balls[i]:setVisible(true)
		else
			balls[i]:setVisible(false)
		end
	end
end

function PayPanelPopUp:menuCallBack1()
	self.curSelectPayType = 1
	self:createPanel("googleWorld")
	updateMenuState(self,1)
end

function PayPanelPopUp:menuCallBack2()
	self.curSelectPayType = 2
	self:createPanel("mycard")
	updateMenuState(self,2)
end

local function initChannelPayParm(self)
	self.areaIndex = 1
	self.payMethodIndex = 1

	self:setChannelpayParm()

	self.areaFont:setString(self._areaList[self.areaIndex])
	local methodList = self:getPayMethodListWithAreaIndex(self.areaIndex)
	self.payMethodFont:setString(methodList[self.payMethodIndex].channel_name)

end

function PayPanelPopUp:menuCallBack3()
	self.curSelectPayType = 3
	self:createPanel("gashPlus")
	updateMenuState(self,3)
	initChannelPayParm(self)
end

function PayPanelPopUp:getPayMethodListWithAreaIndex(areaIndex)
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
function PayPanelPopUp:areaChangeBtnCallBack()
	self.areaIndex = 1
	self.payMethodIndex = 1
	self:createPopupView(self._areaList,"area")
end

function PayPanelPopUp:payMethodBtnCallback()
	self.payMethodIndex = 1  --payMethod
	self.curMethodDada = self:getPayMethodListWithAreaIndex(self.areaIndex)
	self:createPopupView(self.curMethodDada,"payMethod")
end

function PayPanelPopUp:createPopupView(tableData,type)

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

	local function scrollViewDidScroll(view)
	end

	local function scrollViewDidZoom(view)
	end

	local function tableCellTouched(tbview,cell)
		print("idx ====",cell:getIdx()+1,type)
		if type == "area" then
			self.areaIndex = cell:getIdx()+1
			self.areaFont:setString(tableData[self.areaIndex])
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
	--	self.tableView:setPosition(ccp(0,size.height/2))
	tableView1:setTouchPriority(-150)
	tableView1:setPosition(ccp(0,0))
	tableView1:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
	tableView1:registerScriptHandler(scrollViewDidZoom,CCTableView.kTableViewZoom)
	tableView1:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
	tableView1:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
	tableView1:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
	tableView1:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
	tableView1:reloadData()

end

function PayPanelPopUp:setChannelpayParm()
	local parm = {}
	if self.areaIndex == 1 then
		parm = self.gashPlusTWPayInfo[self.payMethodIndex]
	elseif self.areaIndex == 2 then
		parm = self.gashPlusHKPayInfo[self.payMethodIndex]
	elseif self.areaIndex == 3 then
		parm = self.gashPlusMYPayInfo[self.payMethodIndex]
	end
	dump(parm,"curPayParm")
	Pay:Instance():setPayPram4GashChannel(parm)
end



return PayPanelPopUp

