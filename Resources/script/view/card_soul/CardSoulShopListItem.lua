
require("view.BaseView")


CardSoulShopListItem = class("CardSoulShopListItem", BaseView)


function CardSoulShopListItem:ctor()
	CardSoulShopListItem.super.ctor(self)

	--1. load levelup view ccbi
	local pkg = ccbRegisterPkg.new(self)
	pkg:addFunc("iconTouchCallback1",CardSoulShopListItem.iconTouchCallback1)
	pkg:addFunc("iconTouchCallback2",CardSoulShopListItem.iconTouchCallback2)
	pkg:addFunc("iconTouchCallback3",CardSoulShopListItem.iconTouchCallback3)

	pkg:addProperty("node_chip1","CCNode")
	pkg:addProperty("node_chip2","CCNode")
	pkg:addProperty("node_chip3","CCNode")
	pkg:addProperty("node_head1","CCNode")
	pkg:addProperty("node_head2","CCNode")
	pkg:addProperty("node_head3","CCNode")

	pkg:addProperty("sprite_soldOut1","CCSprite")
	pkg:addProperty("sprite_soldOut2","CCSprite")
	pkg:addProperty("sprite_soldOut3","CCSprite")
	pkg:addProperty("sprite_currency1","CCSprite")
	pkg:addProperty("sprite_currency2","CCSprite")
	pkg:addProperty("sprite_currency3","CCSprite")

	pkg:addProperty("label_name1","CCLabelTTF")
	pkg:addProperty("label_name2","CCLabelTTF")
	pkg:addProperty("label_name3","CCLabelTTF")
	pkg:addProperty("label_cost1","CCLabelBMFont")
	pkg:addProperty("label_cost2","CCLabelBMFont")
	pkg:addProperty("label_cost3","CCLabelBMFont")
	pkg:addProperty("bn_chip1","CCControlButton")
	pkg:addProperty("bn_chip2","CCControlButton")
	pkg:addProperty("bn_chip3","CCControlButton")


	local layer,owner = ccbHelper.load("CardSoulShopListItem.ccbi","CardSoulShopListItemCCB","CCLayer",pkg)
	self:addChild(layer)
end

function CardSoulShopListItem:onEnter()
	-- echo("---CardSoulShopListItem:onEnter---")
	if self.chipsArray == nil then 
		return 
	end 

	self.chipNodes = {self.node_chip1, self.node_chip2, self.node_chip3}
	self.chipHeads = {self.node_head1, self.node_head2, self.node_head3}
	self.nameArray = {self.label_name1, self.label_name2, self.label_name3}
	self.costArray = {self.label_cost1, self.label_cost2, self.label_cost3}
	self.soldOutArray = {self.sprite_soldOut1, self.sprite_soldOut2, self.sprite_soldOut3}

	local flag
	local iType 
	local len = math.min(3, #self.chipsArray)
	for i=1, 3 do 
		if i <= len then 
			local configId = self.chipsArray[i]:getConfigId()

			flag = math.floor(configId/10000000)
			if configId < 100 or flag == 2 then 
				iType = 6 
			elseif flag == 3 then 
				iType = 7 
			elseif flag == 1 then 
				iType = 8 
			end 
			
			local chipImg = GameData:Instance():getCurrentPackage():getItemSprite(nil, iType, configId, self.chipsArray[i]:getItemCount())
			if chipImg ~= nil then 
				self.chipHeads[i]:addChild(chipImg)
				local str = ""
				if iType == 6 then 
					str = AllConfig.item[configId].item_name 
				elseif iType == 7 then 
					str = AllConfig.equipment[configId].name 
				elseif iType == 8 then 
					str = AllConfig.unit[configId].unit_name 
				end 
				self.nameArray[i]:setString(str)
				self.costArray[i]:setString(string.format("%d", self.chipsArray[i]:getDiscountPrice()))
				self.soldOutArray[i]:setVisible(self.chipsArray[i]:getBuyTimes() > 0)

				local w = self.costArray[i]:getContentSize().width 
				local x = self.chipHeads[i]:getPositionX() - w/2
				self.costArray[i]:setPositionX(x)

				--currency icon 
				self:setCurrencyIcon(self.chipsArray[i], i)
			end 
		else 
			self.chipNodes[i]:setVisible(false) 
		end 
	end 
end 

function CardSoulShopListItem:onExit()
	-- echo("---CardSoulShopListItem:onExit---")

end

function CardSoulShopListItem:iconTouchCallback1()
	self:handleSelecte(1)
end 

function CardSoulShopListItem:iconTouchCallback2()
	self:handleSelecte(2)
end 

function CardSoulShopListItem:iconTouchCallback3()
	self:handleSelecte(3)
end 

function CardSoulShopListItem:setIdx(idx)
	self._idx = idx 
end 

function CardSoulShopListItem:getIdx()
	return self._idx
end 

function CardSoulShopListItem:setButtonEnableDelegate(delegate)
	self._isBnEanbleDelegate = delegate
end 

function CardSoulShopListItem:setChips(chipArray)
	self.chipsArray = chipArray 
end 


function CardSoulShopListItem:handleSelecte(menuIdx)
	if self.chipsArray ~= nil and self:getDelegate() ~= nil then 
		if self.chipsArray[menuIdx]:getBuyTimes() > 0 then --sold out 
			return 
		end 
		if self:getDelegate():getIsTouchEvent() == true then 
			self:getDelegate():setIsTouchEvent(false)
			self:getDelegate():showPopupToBuy(self:getIdx()*3+menuIdx)
		end 
	end 
end 

function CardSoulShopListItem:setPriority(priority)
	self.bn_chip1:setTouchPriority(priority)
	self.bn_chip2:setTouchPriority(priority)
	self.bn_chip3:setTouchPriority(priority)
end 

function CardSoulShopListItem:setCurrencyIcon(shopItem, nodeIdx)
	local sprites = {self.sprite_currency1, self.sprite_currency2, self.sprite_currency3}
	local currency = shopItem:getCurrencyType() 
	local frame = nil 

	if currency == CurrencyType.Coin then 
		frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("soul_coin.png")
	elseif currency == CurrencyType.Money then 
		frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("soul_money.png")
	elseif currency == CurrencyType.Soul then 
		frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("soul_fire.png")
	elseif currency == CurrencyType.RankPoint then --竞技场
		frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("currency_jingjichang.png")	
	elseif currency == CurrencyType.GuildPoint then --公会
		frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("currency_gonghui.png")
	elseif currency == CurrencyType.Bable then --通天塔
		frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("currency_bable.png")		
	end 
	if frame then 
		sprites[nodeIdx]:setDisplayFrame(frame)
	end 	
end 
