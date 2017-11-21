
ShopCurViewType = enum({"NONE", "JiShi", "TeHui", "DianCang", "VIP", "Soul", "JingJiChang", "GongHui", "Bable","PAY", "OtherShops", "TYPE_MAX"})

ShopItem.Spirit = 20801002 
ShopItem.Token = 20901001
ShopItem.Ticket = 21701001
ShopItem.Ticket = 21701001
ShopItem.ExpeditionBuffer = 22401010

Shop = class("Shop")

Shop._instance = nil

function Shop:ctor()
	if self.shopData == nil then 
		self.shopData = {}
	end 
	if self.shopInfo == nil then 
		self.shopInfo = {}
		for i=1,ShopCurViewType.TYPE_MAX do 
			self.shopInfo[i] = {}
		end 
	end 	
end

function Shop:instance()
	if Shop._instance == nil then 
		Shop._instance = Shop.new()
		Shop._instance:regirstNetServer()
	end 
	return Shop._instance
end 

function Shop:regirstNetServer()
  self:unregirstNetServer()
  net.registMsgCallback(PbMsgId.PlayerBuyFormStoreResultS2C, self, Shop.onBuyFromStoreResult)
end

function Shop:unregirstNetServer()
  net.unregistAllCallback(self)
end

function Shop:initShopData(pbMsg)
	echo("=== Shop:initShopData")

	for k,v in pairs(pbMsg.store.store) do 
		local itemsArray = {}
		for i, item in pairs(v.items) do 
			local shopItem = ShopItem.new()
			shopItem:setId(item.id)
			-- shopItem:setConfigId(item.config_id) --configid 通过掉落包id来获取
			shopItem:setStoreType(item.store_type)
			shopItem:setNeedVipLevel(item.vip_buy_lv)
			shopItem:setBaseBuyLimit(item.buy_daily_limit)
			shopItem:setExtBuyLimitId(item.vip_limit_add)
			shopItem:setDropInfo(item.item_drop)
			shopItem:setPrice(item.show_price)
			shopItem:setCurrencyType(item.show_currency_type)
			shopItem:setDiscountPrice(item.buy_price)
			shopItem:setRealCurrencyType(item.buy_currency_type)
			shopItem:setExtCostId(item.add_cost)
			shopItem:setLevelMin(item.min_level)
			table.insert(itemsArray, shopItem)
		end 
		echo("=== shop data type, len:", v.type, #itemsArray)
		self.shopData[v.type] = itemsArray  -- 1-集市 2-特惠 3-典藏 4-VIP 5-将魂 6-竞技场 7-公会 8-过关斩将
		self:setTipsNewData(v.type, true)
	end 
end 

function Shop:getShopData(shopType)
	if self.shopData[shopType] == nil then 
		self.shopData[shopType] = {}
	end 
	return self.shopData[shopType]
end 

function Shop:reqBuyItem(shopItem,count)
  _showLoading()
  local data = PbRegist.pack(PbMsgId.PlayerBuyFormStoreC2S, {type=shopItem:getStoreType(), store_item=shopItem:getId(),count = count})
  net.sendMessage(PbMsgId.PlayerBuyFormStoreC2S, data)
end

function Shop:onBuyFromStoreResult(action,msgId,msg)
	echo("===onBuyFromStoreResult:", msg.error)
	
  _hideLoading()
  if msg.error == "NO_ERROR_CODE" then 
    local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client)
    for i=1,table.getn(gainItems) do
      echo("----gained configId:", gainItems[i].configId)
      echo("----gained, count:", gainItems[i].count)
      local str = string.format("+%d", gainItems[i].count)
      Toast:showIconNumWithDelay(str, gainItems[i].iconId, gainItems[i].iType, gainItems[i].configId, ccp(display.cx,display.cy-i*40), 0.3*(i-1))
    end 
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)
    local shopBaseView = Shop:instance():getView()
    if shopBaseView ~= nil then
      shopBaseView:updateView()
    end
  else 
    self:handleErrorCode(msg.error)
  end 
end

------
--  Getter & Setter for
--      Shop._View 
-----
function Shop:setView(View)
	self._View = View  --shop base view
end

function Shop:getView()
	return self._View
end

function Shop:setLastRefreshTime(shopType, refreshTime)
	self.shopInfo[shopType].lastRefreshTime = refreshTime 
end 

function Shop:getLastRefreshTime(shopType)
	return self.shopInfo[shopType].lastRefreshTime or 0 
end 

function Shop:setNextRefreshTime(shopType, refreshTime)
	self.shopInfo[shopType].nextRefreshTime = refreshTime 
end  

function Shop:getNextRefreshTime(shopType)
	return self.shopInfo[shopType].nextRefreshTime or 0 
end 

function Shop:setOpenTime(shopType, openTime)
	self.shopInfo[shopType].openTime = openTime 
end  

function Shop:getOpenTime(shopType)
	return self.shopInfo[shopType].openTime or 0 
end 

function Shop:setCloseTime(shopType, closeTime)
	self.shopInfo[shopType].closeTime = closeTime 
end  

function Shop:getCloseTime(shopType)
	return self.shopInfo[shopType].closeTime or 0 
end 

function Shop:setUsedFreeRefreshCount(shopType, count)
	self.shopInfo[shopType].freeRefreshCount = count 
end 

function Shop:getUsedFreeRefreshCount(shopType)
	return self.shopInfo[shopType].freeRefreshCount or 0 
end 

function Shop:setTipsNewData(shopType, needToTip)
	self.shopInfo[shopType].tipsNewData = needToTip 
end 

function Shop:getTipsNewData(shopType)
	return self.shopInfo[shopType].tipsNewData 
end 

--商店刷新时间间隔
function Shop:getRefreshTimeCD(shopType)
	local cd = 0 
	local viplevel = GameData:Instance():getCurrentPlayer():getVipLevel()
	for k, v in pairs(AllConfig.store) do  
		if v.store_type == shopType and (v.vip_lv<0 or v.vip_lv==viplevel) then 
			cd = v.refresh_time 
			break 
		end 
	end 

	return cd 
end 

function Shop:getTipsFlag(shopType) 

	if shopType == ShopCurViewType.JiShi and GameData:Instance():checkSystemOpenCondition(13, false) == false then 
		return false 
	end 

	if shopType == ShopCurViewType.Soul and GameData:Instance():checkSystemOpenCondition(27, false) == false then 
		return false 
	end 

	if shopType == ShopCurViewType.VIP and Shop:instance():checkShopOpen(ShopCurViewType.VIP) == false then 
		return false 
	end 

	if self:getTipsNewData(shopType) then 
		local cd = self:getRefreshTimeCD(shopType) 
		if cd > 0 and cd <= self:getLeftRefreshTime(shopType)+60 then 
			return true 
		end 
	end 
	
	return false 
end 

function Shop:getTotalFreeRefreshCount(shopType)
	local viplevel = GameData:Instance():getCurrentPlayer():getVipLevel()
	local count = 0 

	for k, v in pairs(AllConfig.store) do 
		if v.store_type == shopType then 
			if v.vip_lv < 0 or v.vip_lv == viplevel then 
				if v.allow_refresh > 0 then 
					for m, item in pairs(AllConfig.vip_privilege) do 
						if item.id == v.vip_daily_limit then 
							count = count + item.privilege[viplevel+1]
							break 
						end 
					end 					
				end 
			end 
		end 
	end 

	--针对集市刷新活动
	if shopType == ShopCurViewType.JiShi then 
		if Activity:instance():getActivityLeftTime(ACI_ID_MARKET_REFRESH_TIMES) > 0 then 
			for k, v in pairs(AllConfig.activity) do 
				if v.activity_id == ACI_ID_MARKET_REFRESH_TIMES then 
					count = count + v.activity_drop[1]
					break 
				end 
			end 
		end 
	end 

	return count
end 

function Shop:getTotalPayRefreshCount(shopType)
	local viplevel = GameData:Instance():getCurrentPlayer():getVipLevel()
	local count = 0 
	for k, v in pairs(AllConfig.store) do 
		if v.store_type == shopType then 
			if v.vip_lv < 0 or v.vip_lv == viplevel then 
				if v.allow_refresh > 0 then 
					count = v.money_refresh_count 
					break 
				end 
			end 
		end 
	end 

	return count
end 

function Shop:setUsedPayRefreshCount(shopType, count)
	self.shopInfo[shopType].payRefreshCount = count 
end  

function Shop:getUsedPayRefreshCount(shopType)
	return self.shopInfo[shopType].payRefreshCount or 0 
end 



function Shop:getPayRefreshCost(shopType)
	local needMoney = 0 
	local nextCount = self:getUsedPayRefreshCount(shopType) + 1 
	local viplevel = GameData:Instance():getCurrentPlayer():getVipLevel()
	local costId = 0 
	for k, v in pairs(AllConfig.store) do  
		if v.store_type == shopType and (v.vip_lv<0 or v.vip_lv==viplevel) then 
			costId = v.momey_refresh_cost 
			break 
		end 
	end 

	for k, v in pairs(AllConfig.cost) do
		if v.type == costId and (nextCount >= v.min_count and nextCount <= v.max_count) then
			needMoney = v.cost
			break
		end
	end	
	
	return needMoney 
end 

function Shop:updateShopInfo(increaseBuyGroup) 
	echo("=== updateShopInfo")
	if increaseBuyGroup ~= nil then 
		for k, v in pairs(increaseBuyGroup.store_records) do 
			echo("  store_type, next_refresh_time, free,pay count", v.store_type, v.next_refresh_time,v.store_free_refresh_count,v.store_pay_refresh_count)
			self:setLastRefreshTime(v.store_type, v.last_refresh_time)
			self:setNextRefreshTime(v.store_type, v.next_refresh_time)
			self:setOpenTime(v.store_type, v.store_open_time)
			self:setCloseTime(v.store_type, v.store_close_time)
			self:setUsedFreeRefreshCount(v.store_type, v.store_free_refresh_count)
			self:setUsedPayRefreshCount(v.store_type, v.store_pay_refresh_count)
			local shopData = self:getShopData(v.store_type)
			for m, item in pairs(v.item) do 
				for i=1, #shopData do 
					if shopData[i]:getId() == item.cell_id then 
						shopData[i]:setBuyTimes(item.count)
						break 
					end 
				end 
			end 
		end 
	end 
end 

function Shop:getLeftRefreshTime(shopType)
	local nextTime = self:getNextRefreshTime(shopType)
	local curTime = Clock:Instance():getCurServerUtcTime()
	echo("getLeftRefreshTime, shopType, nextTime, curTime", shopType, nextTime, curTime)
  return math.max(0, nextTime-curTime)
end 

function Shop:checkEntryCondition(shopType)
	local canEntry = true 
	
	return canEntry 
end 

function Shop:getShopItemByConfigId(shopType, id)
	local item = nil 
	local data = self:getShopData(shopType)
	for k, v in pairs(data) do 
		if v:getConfigId() == id then 
			item = v 
			break 
		end 
	end 
	return item 
end 

function Shop:handleErrorCode(errorCode)
	local curScene = GameData:Instance():getCurrentScene()


	if errorCode == "NOT_FOUND_ITEM" then 
		Toast:showString(curScene, _tr("no such item"), ccp(display.cx, display.cy))
	elseif errorCode == "NOT_MORE_COUNT" then 
		Toast:showString(curScene,_tr("cannot_buy_challenge_again"), ccp(display.cx, display.cy))
	elseif errorCode == "NEED_VIP_LEVEL" then 
		Toast:showString(curScene, "VIP ".._tr("poor level"), ccp(display.cx, display.cy))
	elseif errorCode == "NEED_MORE_MONEY" or errorCode == "NotHaveEnoughCurrency" then 
		Toast:showString(curScene, string._tran(Consts.Strings.NO_ENOUGH_CURRENCY), ccp(display.cx, display.cy))
	elseif errorCode == "STORE_CLOSED" then 
		Toast:showString(curScene, string._tran(Consts.Strings.SHOP_IS_CLOSE), ccp(display.cx, display.cy))
	elseif errorCode == "REFRESH_COUNT_MAX" then
		Toast:showString(curScene, string._tran(Consts.Strings.FREE_REFRESH_TIMES_USED_OUT), ccp(display.cx, display.cy))
	elseif errorCode == "MONET_FRESH_MAX" then 
		Toast:showString(curScene, string._tran(Consts.Strings.PAY_REFRESH_TIMES_USED_OUT), ccp(display.cx, display.cy))
	elseif errorCode == "AlreadGetAward" then 
		Toast:showString(curScene, _tr("has award"), ccp(display.cx, display.cy))
	elseif errorCode == "NotDone" then 
		Toast:showString(curScene, _tr("get_award_faild_need_condition"), ccp(display.cx, display.cy))
	elseif errorCode == "ActivityIsNotOpen" then 
		Toast:showString(curScene, _tr("act_not_open"), ccp(display.cx, display.cy))
	elseif errorCode == "MissionError" then 
		Toast:showString(curScene, _tr("no_such_activity"), ccp(display.cx, display.cy))					
	else 
		Toast:showString(curScene, _tr("system error"), ccp(display.cx, display.cy))
	end 
end 

function Shop:checkHasEnoughCurrency(currencyType, needCount, bToastString)
	local ownCount = 0 
	local str = ""
	local player = GameData:Instance():getCurrentPlayer()

	if currencyType == CurrencyType.Coin then 
		ownCount = player:getCoin()
		str = _tr("not enough coin")

	elseif currencyType == CurrencyType.Money then 
		ownCount = player:getMoney()
		str = _tr("not enough money")

	elseif currencyType == CurrencyType.Soul then 
		ownCount = player:getCardSoul() 
		str = string._tran(Consts.Strings.SOUL_NO_ENOUGH_SOUL) 

	elseif currencyType == CurrencyType.RankPoint then 
		ownCount = player:getRankPoint() 
		str = string._tran(Consts.Strings.NO_ENOUGH_CURRENCY)

	elseif currencyType == CurrencyType.GuildPoint then 
		ownCount = player:getGuildPoint() 
		str = string._tran(Consts.Strings.NO_ENOUGH_CURRENCY)

	elseif currencyType == CurrencyType.Bable then 
		ownCount = player:getBablePoint() 
		str = string._tran(Consts.Strings.NO_ENOUGH_CURRENCY)		
	end 


	if ownCount < needCount then 
		if bToastString then 
			if currencyType == CurrencyType.Money then 
				GameData:Instance():notifyForPoorMoney()
			else 
				Toast:showString(GameData:Instance():getCurrentScene(), str, ccp(display.cx, display.cy))
			end 
		end 
		return false 
	end 

	return true 
end 

function Shop:checkShopOpen(shopType)
	local isOpen = false 
	local openTime = self:getOpenTime(shopType)
	local closeTime = self:getCloseTime(shopType)
	local curTime = Clock:Instance():getCurServerUtcTime()
	if curTime >= openTime and curTime < closeTime then 
		isOpen = true 
	end 

	-- dump(os.date("*t", curTime), "=====cur")
	-- dump(os.date("*t", openTime), "=====open")
	echo("===checkShopOpen:", shopType, isOpen, curTime, openTime, closeTime)
	return isOpen, closeTime-curTime
end 
