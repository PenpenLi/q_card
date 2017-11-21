require("model.Item")

ShopItem = class("ShopItem",Item)



function ShopItem:ctor()
	ShopItem.super.ctor(self)
end

function ShopItem:setStoreType(_type) -- 1--集市 2-特惠 3-典藏 4-VIP,5-将魂
	self._storeType = _type
end 

function ShopItem:getStoreType()
	return self._storeType 
end 

function ShopItem:setNeedVipLevel(level)
	self._needVipLevel = level
end 

function ShopItem:getNeedVipLevel()
	return self._needVipLevel
end 

--原始价格
function ShopItem:setPrice(price)
	self._price = price
end

function ShopItem:getPrice()
	return self._price
end

--成交价格
function ShopItem:setDiscountPrice(price)
	self._discountPrice = price
end

function ShopItem:getDiscountPrice()
	local price = self._discountPrice 
	--calc ext price 
	local extCostId = self:getExtCostId()
	if extCostId and extCostId > 0 then 
		echo("===getDiscountPrice:costid, buytimes", extCostId, self:getBuyTimes())
		local count = self:getBuyTimes() + 1 
		for k, v in pairs(AllConfig.cost) do 
			if v.type == extCostId then 
				if count >= v.min_count and count <= v.max_count then 
					price = v.cost 
					break 
				end 
			end 
		end 
	end 

	return price
end

function ShopItem:setCurrencyType(currencyType)
	self._currencyType = currencyType
end

function ShopItem:getCurrencyType()
	return self._currencyType
end

function ShopItem:setRealCurrencyType(realCurrencyType)
	self._realCurrencyType = realCurrencyType
end

function ShopItem:getRealtCurrencyType()
	return self._realCurrencyType
end

function ShopItem:setExtCostId(costId)
	self._extCostId = costId
end 

function ShopItem:getExtCostId()
	return self._extCostId
end 

function ShopItem:setDropInfo(dropId)
	local drop = AllConfig.drop[dropId]
	if drop ~= nil then 
		local item = drop.drop_data[1].array
		local iType = item[1]
		local configId = item[2]
		self:setObjectType(iType)
		self:setConfigId(configId)
		self:setItemCount(item[3])

		if iType == 4 then --coin
			self:setName("")
			self:setDesc("")
			self:setIconId(3050050)
		elseif iType == 5 then --money
			self:setName("")
			self:setDesc("")
			self:setIconId(3050049)
		elseif iType == 6 then --props 
			self:setName(AllConfig.item[configId].item_name)
			self:setDesc(AllConfig.item[configId].item_desc)
			self:setIconId(AllConfig.item[configId].item_resource)
		elseif iType == 7 then --equip
			self:setName(AllConfig.equipment[configId].name)
			self:setDesc(AllConfig.equipment[configId].description)
			self:setIconId(AllConfig.equipment[configId].equip_icon)
		elseif iType == 8 then --card 
			self:setName(AllConfig.unit[configId].unit_name)
			self:setDesc(AllConfig.unit[configId].description)
			self:setIconId(AllConfig.unit[configId].unit_head_pic)
		end 
	end 
end 

function ShopItem:setObjectType(objectType)
	self._objectType = objectType
end

function ShopItem:getObjectType()
	return self._objectType
end

function ShopItem:setItemCount(count)
	 self._itemCount = count
end

function ShopItem:getItemCount()
		return self._itemCount
end

function ShopItem:setDesc(desc)
	self._desc = desc
end

function ShopItem:getDesc()
	return self._desc
end

--当前购买的次数
function ShopItem:setBuyTimes(buyTimes)
	self._buyTimes = buyTimes
end

function ShopItem:getBuyTimes()
	return self._buyTimes or 0 
end

--默认购买次数限制
function ShopItem:setBaseBuyLimit(baseLimit)
	self._baseLimit = baseLimit
end 

function ShopItem:getBaseBuyLimit()
	return self._baseLimit or -1 
end 

--根据VIP对应的额外购买次数
function ShopItem:setExtBuyLimitId(id)
	self._extBuyLimitId = id 
end 

function ShopItem:getExtBuyLimitId()
	return self._extBuyLimitId or -1 
end 

function ShopItem:getBuyLimit(exceptNextVipLimit)
	local limit = self:getBaseBuyLimit()
	if limit < 0 then --always
		return -1 
	end 

	local id = self:getExtBuyLimitId()
	if id > 0 then 
		local viplevel = GameData:Instance():getCurrentPlayer():getVipLevel()
		if exceptNextVipLimit then 
			viplevel = math.min(12, viplevel+1)
		end 
		local item = AllConfig.vip_privilege[id]
		if item ~= nil then 
			limit = limit + item.privilege[viplevel+1]
		end 
	end 
	
	return limit
end

function ShopItem:setIsNeedVip(isNeedVip)
	self._needVip = isNeedVip
end

function ShopItem:getIsNeedVip()
	return self._needVip
end

function ShopItem:getIsDiscount()
	return self:getPrice() > self:getDiscountPrice()
end 

--最低要求等级
function ShopItem:setLevelMin(level)
	self._levelLimit = level
end 

function ShopItem:getLevelMin()
	return self._levelLimit or 0 
end 

return ShopItem
