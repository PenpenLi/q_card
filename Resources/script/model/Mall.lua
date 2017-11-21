

--require("view.shop.LotteryView")

Mall = class("Mall")

Mall._instance = nil

Mall._userId = 0
function Mall:Instance()
	if Mall._instance == nil then
		Mall._instance = Mall.new()
	end
	return Mall._instance
end

function Mall:ctor()
--	net.registMsgCallback(PbMsgId.CommodityListS2C,self,Pay.onCommodityListS2C)
--	net.registMsgCallback(PbMsgId.PlatformOrderResultS2C,self,Pay.onPlatformOCommodityListS2C,self,Pay.onCommodityListS2C)
	--	net.registMsgCallback(PbMsgId.PlatformOrderResultS2C,self,Pay.onPlatformOrderResultS2C) -- 处理支付结果

	self:initLotteryTenTimesCardHead()
	self._isHasNewEvent = false
	self._isUseMoneyOrVIPRefreshMarket = false
	--self:initNoticeTenNode()

end

function Mall:reqNoticeInfo(value)
	local askForDrawTenCardInformationtData = PbRegist.pack(PbMsgId.AskForDrawTenCardInformation,{key = value})
	net.sendMessage(PbMsgId.AskForDrawTenCardInformation,askForDrawTenCardInformationtData)
end



function Mall:setLotteryView(viewData)
	self._lotteryView = viewData
end

function Mall:initLotteryTenTimesCardHead()

	self._tenCardHeadNode = {}
	for i= 1,10,1 do
		local cardHead = CardHeadView.new()
		cardHead:retain()
		self._tenCardHeadNode[i]= cardHead
	  --  table.insert(self._tenCardHeadNode,cardHead)
	end
end

function Mall:getLotteryTenCardHead()
	return self._tenCardHeadNode
end

function Mall:initNoticeTenNode()
	self._tenNoticeNode = {}
	for i= 1,5,1 do
		local noticeNode = CardAwardNotifyView.new()
	--	GameData:Instance():getCurrentScene():addChild(noticeNode,-1)
		noticeNode:retain()
		table.insert(self._tenNoticeNode,noticeNode)
	end
end

function Mall:getNoticeNode()
	return self._tenNoticeNode
end

function Mall:setMallHasNewTipEvent(isNewEvent)
	self._isHasNewEvent = isNewEvent
end


function Mall:getHasNewTip()
 	local flag = GameData:Instance():checkSystemOpenCondition(16, false)
	if flag == false then
		return false
	end

	return self._isHasNewEvent
end

function Mall:setHasNewTip(isNew)
	self._isHasNewEvent = isNew

end

function  Mall:setUseMoneyOrVIPRefreshMarket(isFree)
	self._isUseMoneyOrVIPRefreshMarket = isFree
end

function Mall:isUseMoneyOrVIPRefreshMarket()
	return self._isUseMoneyOrVIPRefreshMarket
end


function Mall:getHasLotteryNewEvent()
  local curTime = Clock:Instance():getCurServerUtcTime()
  
  if GameData:Instance():getCurrentPlayer():getLastLoyaltyFreeDrawTime()+AllConfig.characterinitdata[31].data*60 <= curTime then 
  	return true 
  end 

	if GameData:Instance():getCurrentPlayer():getLastItemFreeDrawTime() + AllConfig.characterinitdata[23].data*60 <= curTime then 
		return true 
  end 

  return false 
end


function Mall:setRebateData(ackRebateData)
	if ackRebateData == nil then
		return
	end
	self._rebatedata = {}
	for k, v in pairs(ackRebateData) do
		local data = {}
		data.rebateId = v.rebate_id
		data.rebateCount = v.rebate_count
		data.rebateTime =  v.rebate_time 
		data.rebateEndTime = v.rebate_end_time 
		data.rebateMoney = v.rebate_money
		data.rebateTemMoney = v.rebate_tem_money
		data.currentDrawCount = v.current_draw_count
		if data.rebateId == 1001 or data.rebateId == 1002 or data.rebateId == 1003 then
			table.insert(self._rebatedata,data)
		end
	end

	local hasOldRebate = false
	for k, v in pairs(self._rebatedata) do
		if v.rebateId == 1001 then
			hasOldRebate = true
		end
	end
	if hasOldRebate == false then
		local data ={}
		table.insert(self._rebatedata,1,data)
	end
--	 dump(self._rebatedata,"##@@")
end

function Mall:updateRebateData(rebateData)

	for k, v in pairs(rebateData) do
		local data = {}
		data.rebateId = v.rebate_id
		data.rebateCount = v.rebate_count
		data.rebateTime =  v.rebate_time
		data.rebateEndTime = v.rebate_end_time
		data.rebateMoney = v.rebate_money
		data.rebateTemMoney = v.rebate_tem_money
		data.currentDrawCount = v.current_draw_count
		if data.rebateId == 1001 and #self._rebatedata >=2 then
			self._rebatedata[1] = data
		elseif data.rebateId == 1002 and #self._rebatedata >=2 then -- one
			self._rebatedata[2] = data
		elseif data.rebateId == 1003 and #self._rebatedata >=2 then -- ten
			self._rebatedata[3] = data
		end
	end
end

function Mall:getRebateData()
	return self._rebatedata
end

function Mall:isShowRebateView(index)-- 1,2,3

	index = index +1
	if #self._rebatedata <= 1 or self._rebatedata[index].rebateId == nil then
		print("=======rebateDate is nil=======")
		return false
	end

	local bRet = true
	local endTime = toint(self._rebatedata[index].rebateEndTime - Clock:Instance():getCurServerUtcTime())
	local isReward = self._rebatedata[index].rebateMoney   -- 已经返利的元宝(未领取)
	local rebateTimes = self._rebatedata[index].rebateCount -- 返利次数

	if index >= 2 and endTime<=0 and isReward == 0 and rebateTimes == 3 then
	    bRet = false
	end

	return bRet
end

function Mall:hasTenLotteryRebateReward()
    local bRet = false
    if self._rebatedata ~= nil then
        local isReward = self._rebatedata[3].rebateMoney
        if isReward >0 then
            bRet = true
        end
    end  
    return bRet
end


function Mall:setShopCollectView(view)
	self._shopCollectView = view
end

function Mall:updateView()
	if self._shopCollectView ~= nil then
		self._shopCollectView:reloadData()
	end

end

--
--function Mall:setAskForDrawTenCardInformationResultOfKey(key)
--	self._key = key
--end
--
--function GameData:getAskForDrawTenCardInformationResultOfKey()
--	return self._key
--end






--function Pay:reqPayDataWithMoneyType()
--
--	local data = PbRegist.pack(PbMsgId.CommodityQueryC2S,{channel = "alipay"})
--	net.sendMessage(PbMsgId.CommodityQueryC2S,data)
--end
--
--function Pay:onCommodityListS2C(action,msgId,msg)
--	print("@@@@@@@@@@@@@@@@@----------------------")
--	--dump(msg.list,"@@@@@@")
--	if msg.data == nil then
--		return
--	end
--	self:InitPayListData(msg.list)
--	--self:initInteractReportData(msg.list)
--end
--
--function Pay:onPlatformOrderResultS2C(action,msgId,msg)
--
--	local orderId = msg.order --订单号
--	local commodityId =  msg.commodity --当前的商品ID
--	local money = msg.money + msg.point + msg.firstPoint
--	local vip = msg.vip
--	local commodityData = {}
--	commodityData = msg.data  -- 充值记录
--	GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)
--end
--
--function Pay:InitPayListData(listData)
--
--
--	for k, v in pairs(listData) do
--		local listCell = {}
--		listCell.goodsId = v.id
--		listCell.channel = v.channel
--		listCell.type = v.type    -- 货币类型 string PriceType    RMB = 1; 	USD = 2; 	TWD = 3;  HKD = 4;
--		listCell.price = v.price
--		listCell.goodsType = v.goods_type -- 1 元宝  2 VIP月
--		listCell.firstPoint =  v.firstPoint
--		listCell.count = v.count
--		listCell.isOpen = v.is_open
--		listCell.addPercent = v.add_percent
--		listCell.paymentCode = v.payment_code
--		table.insert(self._payListData,listCell)
--	end
--
--	--	dump(self._payListData,"qqqqqqqqqqqqqq")
--
--end
--
--function Pay:getPayListData()
--	return self._payListData
--end


return Mall

