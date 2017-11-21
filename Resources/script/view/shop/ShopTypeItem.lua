

require("model.shop.Shop")

ShopTypeItem = class("ShopTypeItem", BaseView)

function ShopTypeItem:ctor()
	ShopTypeItem.super.ctor(self)
	local pkg = ccbRegisterPkg.new(self)

	--for shop list info 
  pkg:addFunc("onShopGoto",ShopTypeItem.gotoOtherShop)
	pkg:addProperty("sprite_icon","CCSprite")
	pkg:addProperty("label_shopInfo","CCLabelTTF")
	pkg:addProperty("bn_goto","CCControlButton") 

	local layer,owner = ccbHelper.load("ShopTypeItem.ccbi","ShopTypeItemCCB","CCLayer",pkg)
	self:addChild(layer)
end


function ShopTypeItem:onEnter()
	self:updateInfos()
end 

function ShopTypeItem:onExit()

end 

function ShopTypeItem:setIdx(id)
	self._id = id 
end 

function ShopTypeItem:setData(shopInfo)
	self._shopInfo = shopInfo 
end 


function ShopTypeItem:setPriority(priority)
	self._priority = priority
	
	self.bn_goto:setTouchPriority(priority)
end 

function ShopTypeItem:getPriority()
	return self._priority or -100
end 

function ShopTypeItem:gotoOtherShop()
	print("onClickPurchase begin")
	_playSnd(SFX_CLICK)

	if self:getDelegate() and self._shopInfo then 
		self:getDelegate():gotoOtherShop(self._shopInfo.shopType)
	end 
end

function ShopTypeItem:updateInfos()
	local frame 
	local str = ""
	if self._shopInfo.shopType == ShopCurViewType.JingJiChang then 
		frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("shop_jingjichang.png")
		str = _tr("shop_jingjichang")
	elseif self._shopInfo.shopType == ShopCurViewType.GongHui then 
		frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("shop_gonghui.png")
		str = _tr("shop_gonghui")
	elseif self._shopInfo.shopType == ShopCurViewType.Bable then 
		frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("shop_bable.png")
		str = _tr("shop_bable")
	end 
	if frame then 
		self.sprite_icon:setDisplayFrame(frame)
	end 

	self.label_shopInfo:setString(str)
	self.bn_goto:setEnabled(self._shopInfo.canEntry)
end 
