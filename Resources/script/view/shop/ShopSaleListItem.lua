
require("model.shop.ShopItem")
require("model.shop.Shop")

ShopSaleListItem = class("ShopSaleListItem", BaseView)

function ShopSaleListItem:ctor()
	ShopSaleListItem.super.ctor(self)
	local pkg = ccbRegisterPkg.new(self)

	pkg:addFunc("onClickPurchase",ShopSaleListItem.onClickPurchase)
	pkg:addProperty("node_icon","CCNode")
	pkg:addProperty("node_discount","CCNode")
	pkg:addProperty("node_realPrice","CCNode")
	pkg:addProperty("sprite_discount","CCSprite")
	pkg:addProperty("sprYuanBao1","CCSprite")
	pkg:addProperty("sprYuanBao2","CCSprite")
	pkg:addProperty("sprYuanBao3","CCSprite")
	pkg:addProperty("lblName","CCLabelTTF")
	pkg:addProperty("lblPrice","CCLabelTTF")
	pkg:addProperty("lblPriceDiscount","CCLabelTTF")
	pkg:addProperty("label_realPrice","CCLabelTTF")
	pkg:addProperty("lblDesc","CCLabelTTF")
	pkg:addProperty("label_buyLimit","CCLabelTTF")
	pkg:addProperty("bn_buy","CCControlButton")

	local layer,owner = ccbHelper.load("ShopSaleListItem.ccbi","ShopSaleListItemCCB","CCLayer",pkg)
	self:addChild(layer)
end


function ShopSaleListItem:onEnter()
	self:updateInfos()
end 

function ShopSaleListItem:onExit()

end 

function ShopSaleListItem:setIdx(idx)
	self._idx = idx
end 

function ShopSaleListItem:getIdx()
	return self._idx
end 

function ShopSaleListItem:setPriority(priority)
	self._priority = priority
	
	self.bn_buy:setTouchPriority(priority)
end 

function ShopSaleListItem:getPriority()
	return self._priority or -100
end 

function ShopSaleListItem:onClickPurchase()
	print("onClickPurchase begin")
	_playSnd(SFX_CLICK)

	if self:getDelegate() ~= nil then 
		self:getDelegate():buyItem(self.shopItem, self:getIdx())
	end 
end

function ShopSaleListItem:setData(shopItem)
	self.shopItem = shopItem
end 

function ShopSaleListItem:updateInfos()
	if self.shopItem == nil then 
		return 
	end 	
	

	self.lblName:setString(self.shopItem:getName())
	self.lblDesc:setDimensions(CCSizeMake(144, 0))
	self.lblDesc:setString(self.shopItem:getDesc())
	local itemType = self.shopItem:getObjectType() 
	local configId = self.shopItem:getConfigId()
	local count = self.shopItem:getItemCount()
	local icon = GameData:Instance():getCurrentPackage():getItemSprite(nil, itemType, configId, count, true)
	if icon ~= nil then 
		self.node_icon:addChild(icon)
	end 

	local leftBuyCount = math.max(0, self.shopItem:getBuyLimit() - self.shopItem:getBuyTimes())
	-- if self.shopItem:getBuyLimit() > 0 then 
	-- 	self.bn_buy:setEnabled(leftBuyCount>0)
	-- else 
	-- 	self.bn_buy:setEnabled(true)
	-- end 
	
	--次数用完时, 如果下一VIP等级对应的购买上限 > 当前上限, 则提示用户
	local curLimit = self.shopItem:getBuyLimit() 
	local nextLimit = self.shopItem:getBuyLimit(true)
	echo("@@@@@@ cur/next limit", curLimit, nextLimit)
	if curLimit < 0 or leftBuyCount > 0 then 
		self.bn_buy:setEnabled(true)
	else 
		self.bn_buy:setEnabled(nextLimit > curLimit)
	end 


	--集市不显示购买限制
	if self.shopItem:getStoreType() ~= 1 and self.shopItem:getBuyLimit() > 0 then 
		self.label_buyLimit:setVisible(true)
		local str = _tr("shop_buy_limit")..string.format("%d/%d", leftBuyCount, self.shopItem:getBuyLimit()) 
		self.label_buyLimit:setString(str)
	else 
		self.label_buyLimit:setVisible(false)
	end 

	local costType = self.shopItem:getCurrencyType()
	local bDiscount = self.shopItem:getIsDiscount()

	local frame1, frame2
	if bDiscount == false  then
		self.node_discount:setVisible(false)
		self.node_realPrice:setVisible(true)
		self.sprite_discount:setVisible(false)
		self.label_realPrice:setString(self.shopItem:getDiscountPrice())

		if costType == 1 then --coin
			frame1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("shop_coins.png")
		else 
			frame1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("shop_yuanbao.png")
		end 
		self.sprYuanBao3:setDisplayFrame(frame1)
	else 
		self.node_discount:setVisible(true)
		self.node_realPrice:setVisible(false)
		self.sprite_discount:setVisible(true)
		self.lblPrice:setString(self.shopItem:getPrice())
		self.lblPriceDiscount:setString(self.shopItem:getDiscountPrice())
		if costType ==1 then 
			frame1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("shop_coins.png")
			frame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("shop_coins.png")
		else 
			frame1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("shop_yuanbao.png")			
			frame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("shop_yuanbao.png")
		end 
		self.sprYuanBao1:setDisplayFrame(frame1) 
		self.sprYuanBao2:setDisplayFrame(frame2) 
	end 
end 
