Pay = class("Pay")


require("view.shop.component.PayPanelPopUp")
require("view.component.Mask")

Pay._instance = nil

Pay._userId = 0
function Pay:Instance()
	if Pay._instance == nil then
		Pay._instance = Pay.new()
	end
	return Pay._instance
end

function Pay:ctor()
	net.registMsgCallback(PbMsgId.CommodityListS2C,self,Pay.onCommodityListS2C)
	net.registMsgCallback(PbMsgId.PlatformOrderResultS2C,self,Pay.onPlatformOrderResultS2C) -- 处理支付结果

	self._payListData = {}
	--self._channelData = {}
	self.vipCardData = nil --vip 30day`s
end

function Pay:reqPayDataWithMoneyType()
	self._payListData = {}
	local str =  UserLogin:getChannel()
	local payChannels = string.split(str,",")

	for i = 1, #payChannels, 1 do
		print("curPayChannels===>>>",payChannels[i])
		local channelId
		if payChannels[i] == "appstore" or payChannels[i] == "appstorect" then
			local zone
			if device.platform == "ios" then
				zone = DSNotificationManager:getLocaleIdentifier()
				if zone == "zh_CN" then
					channelId = payChannels[i].."cn"
				elseif zone == "zh_TW" then
					channelId = payChannels[i].."tw"
				elseif zone == "zh_HK" then
					channelId = payChannels[i].."hk"
				else
					channelId = payChannels[i]
				end
			end
		else
			channelId = payChannels[i]
		end

		local data = PbRegist.pack(PbMsgId.CommodityQueryC2S,{channel = tostring(channelId)})
		net.sendMessage(PbMsgId.CommodityQueryC2S,data)
	end
end

function Pay:getHasGooglePay()
	local channels = UserLogin:getChannel()
	local payChannels = string.split(channels,",")
	local flag = false 
	if payChannels ~= nil then 
		for k, v in pairs(payChannels) do 
			if v == "googleWorld" then 
				flag = true 
				break 
			end 
		end 
	end 
	
	return flag 
end 

function Pay:getPayChannelsCount()
	local channels = UserLogin:getChannel()
	local payChannels = string.split(channels,",")
	local count = 0
	if payChannels then
		count = #payChannels
	end
	return count
end

function Pay:onCommodityListS2C(action,msgId,msg)
	--dump(msg.list,"@@@@@@")
	if msg.data == nil then
		return
	end
	self:InitPayListData(msg.list)
	self:InitPayHistoryData(msg.data)
	--self:initInteractReportData(msg.list)
end

function Pay:onPlatformOrderResultS2C(action,msgId,msg)
	local orderId = msg.order --订单号
	local commodityId =  msg.commodity --当前的商品ID
	local money = msg.money + msg.point + msg.firstPoint
	local price,priceType = self:getPriceAndType(self._goodsList,commodityId)
	self:onPaySuccess(orderId,price*100,priceType,"AppStore")

	GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)

	self:InitPayHistoryData(msg.data) -- 充值记录

	local successTips = ""
	if msg.vip > 0 then
		local vipLeftTime = GameData:Instance():getCurrentPlayer():getVipEndTime()-Clock:Instance():getCurServerUtcTime()
		local leftDays = math.ceil(vipLeftTime/(24*3600))
		if msg.vip > 7 then --is month card 
			successTips = _tr("buy_month_card_success_%{day}", {day=leftDays})
		else 
			successTips = _tr("buy_week_card_success_%{day}", {day=leftDays})
		end 
	else
		successTips = _tr("charge_success_for_money_%{count}", {count=money})
	end
	
	local curScene = GameData:Instance():getCurrentScene()
	local popupNode = curScene:getChildByTag(POPUP_NODE_ZORDER)
	if popupNode == nil then
		popupNode = display.newNode()
		curScene:addChild(popupNode,POPUP_NODE_ZORDER,POPUP_NODE_ZORDER)
	end

	local popView =  PopupView:createTextPopup(successTips,nil ,true)
	popupNode:addChild(popView) 
end

function Pay:InitPayListData(listData)
    self._goodsList=listData
	local curPayListData = {}
	for k, v in pairs(listData) do
		local listCell = {}
		listCell.goodsId = v.id
		listCell.channel = v.channel
		listCell.type = v.type    -- 货币类型 string PriceType    RMB = 1; 	USD = 2; 	TWD = 3;  HKD = 4;
		listCell.price = (v.price - v.price%0.01) --
		listCell.goodsType = v.goods_type -- 1 元宝  2 VIP月
		listCell.firstPoint =  v.firstPoint
		listCell.count = v.count
		listCell.isOpen = v.is_open
		listCell.addPercent = v.add_percent
		listCell.paymentCode = v.payment_code
		listCell.point = v.point    --附送元宝
--		listCell.data.id  = v.data.id
--		listCell.data.count = v.data.count

		listCell.firstBouns = {} --首次掉落信息
		listCell.firstBouns.type = v.first_bouns.type
		listCell.firstBouns.count = v.first_bouns.count
		listCell.firstBouns.id = v.first_bouns.id
		table.insert(curPayListData,listCell)
	end

	if #curPayListData >0 then
		table.insert(self._payListData,curPayListData)
	end

	self:init30DayVipCardGoodsData()
	print("total pay list count is ==============>>>>>",#self._payListData)
end

--默认每个平台只有1种充值方式；但是繁体版有多种充值方式,并且默认第一项存放的是googlepay, 
--但是繁体版的官网版本不包含googlepay方式！！！！
function Pay:getPayListDataByIndex(index)
	if index > 1 then 
		if self:getHasGooglePay() == false then 
			index = index - 1 
		end 
	end 
	
	return self._payListData[index]
end

function Pay:InitPayHistoryData(historyData)
	echo("@@@ InitPayHistoryData")
	if #historyData.data > 0 then
		for k, v in pairs(historyData.data) do
			for m, item in pairs(self._payListData) do
				for key, val in pairs(item) do

					if v.id == val.goodsId then
						echo("=== already pay:id=", v.id)
						val.alreadyBuyCount = v.count
					end
				end
			end
		end
	end
end

function Pay:init30DayVipCardGoodsData()
	if(self._payListData and self._payListData[1]) then
		for k, v in pairs(self._payListData[1]) do  --    默认第一列的数据
			if v.goodsType == 2 and v.count == 30 then   -- vip 30day`s
				self.vipCardData = v
			end
		end
	end
end


function Pay:autoBuyVipCard()

	local playerLv =  GameData:Instance():getCurrentPlayer():getLevel() -- todo:添加人物等级的判断
	self.payChannelCount = Pay:Instance():getPayChannelsCount()

	if self.payChannelCount >1 and  playerLv >= ANDROID_PAY_COMBIN_PLAYER_LV then
		local PayPanelPopUplayer = PayPanelPopUp:new()
		local mask = Mask.new({opacity = 50,priority = -149})
		local curScene = GameData:Instance():getCurrentScene()
		local popupNode = nil
		popupNode = curScene:getChildByTag(POPUP_NODE_ZORDER)

		if popupNode == nil then
			popupNode = display.newNode()
			curScene:addChild(popupNode,POPUP_NODE_ZORDER,POPUP_NODE_ZORDER)
		end
		mask:addChild(PayPanelPopUplayer)
		popupNode:addChild(mask)
	else
		if self.vipCardData ~= nil then
			local playerId = GameData:Instance():getCurrentPlayer():getId()
			print("playerId",playerId,self.vipCardData.channel)
			print("playerId",playerId)
			local serverId, serverName=  Pay:Instance():getPayServerIdAndName()
			local roleName = GameData:Instance():getCurrentPlayer():getName()
			local balance = GameData:Instance():getCurrentPlayer():getMoney()
			local userLevel =  GameData:Instance():getCurrentPlayer():getLevel()
			local pram = "roleName="..roleName.."&serverName="..serverName.."&balance="..balance.."&userLevel="..userLevel.."&paid=".."0".."&cuid=".."0".."&service=".."0".."&erpid=".."0"
			print(c_pay_item(self.vipCardData.goodsId,playerId,self.vipCardData.paymentCode,self.serverId,self.vipCardData.channel,pram))
		end
	end

end


function Pay:setPayServerIdAndName(serverId,name)
   self.serverId = serverId
   self.serverName = name
end

function Pay:getPayServerIdAndName()
	return self.serverId,self.serverName
end

function Pay:setPayPram4GashChannel(pram) -- for Gash
	self.PayPram4GashChannel = pram
end

function Pay:getPayPram4GashChannel()
	return self.PayPram4GashChannel
end

--function Pay:setChannelpayParm(parm)
--	self.channelPayParm =  parm
--end
--
--function Pay:getChannelpayParm()
--	return self.channelPayParm
--end

--[[
   IOS上使用
   TalkingData_AdTracking
   当支付成功以后调用该方法进行记录支付结果
--]]
function Pay:onPaySuccess(orderIdStr,amountStr,currencyTypeStr,payTypeStr)
  local dlChannel = ChannelManager:getCurrentDownloadChannel()
  if CCLuaObjcBridge~=nil and dlChannel == "appstore" then
    local luaoc=require("framework.ocbridge")
    local className="TalkingDataSdk"
    local userName=CCUserDefault:sharedUserDefault():getStringForKey("dsus_name")
    local args={
      account=userName,
      orderId=orderIdStr,
      amount=amountStr,
      currencyType=currencyTypeStr,
      payType=payTypeStr,
    }
    luaoc.callStaticMethod(className,"onPay",args)
  end
end

function Pay:getPriceAndType(listData,goodsId)
	if listData~=nil then
		for k, v in pairs(listData) do
			if v.id== goodsId then
	           return (v.price - v.price%0.01),v.type
			end
		end
    end
	return 0
end



return Pay

