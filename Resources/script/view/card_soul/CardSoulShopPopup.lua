
require("view.BaseView")



CardSoulShopPopup = class("CardSoulShopPopup", BaseView)

function CardSoulShopPopup:ctor()
	CardSoulShopPopup.super.ctor(self)

	--1. load levelup view ccbi
	local pkg = ccbRegisterPkg.new(self)
	pkg:addFunc("buyCallback",CardSoulShopPopup.buyCallback)
	pkg:addFunc("closeCallback",CardSoulShopPopup.closeCallback)
	pkg:addFunc("detailCallback",CardSoulShopPopup.detailCallback)
	pkg:addFunc("decreseCallback",CardSoulShopPopup.decreseCallback)
	pkg:addFunc("increseCallback",CardSoulShopPopup.increseCallback)
	pkg:addFunc("maxCallback",CardSoulShopPopup.maxCallback)

	pkg:addProperty("node_chip","CCNode")
	pkg:addProperty("layer_mask","CCLayerColor")
	pkg:addProperty("label_name","CCLabelTTF")
	pkg:addProperty("label_count","CCLabelTTF")
	pkg:addProperty("label_desc","CCLabelTTF")
	pkg:addProperty("label_buyCount","CCLabelTTF")
	pkg:addProperty("label_cost","CCLabelBMFont")
	pkg:addProperty("sprite_popBg","CCScale9Sprite")
	pkg:addProperty("sprite_currency","CCSprite")
	pkg:addProperty("menu_close","CCMenu")
	pkg:addProperty("menu_detail","CCMenu")
	pkg:addProperty("bn_buy","CCControlButton")

	pkg:addProperty("node_costInfo","CCNode")
	pkg:addProperty("node_input","CCNode")
	pkg:addProperty("menu_jian","CCMenu")
	pkg:addProperty("menu_jia","CCMenu")
	pkg:addProperty("menu_max","CCMenu")
	pkg:addProperty("sprite9_input","CCScale9Sprite")
	pkg:addProperty("sprite_currency2","CCSprite")
	pkg:addProperty("label_preCost2","CCLabelTTF")
	pkg:addProperty("label_cost2","CCLabelTTF")


	local layer,owner = ccbHelper.load("CardSoulShopPopup.ccbi","CardSoulShopPopupCCB","CCLayer",pkg)
	self:addChild(layer)
end

function CardSoulShopPopup:setData(dataArray)
	self._data = dataArray
end 

function CardSoulShopPopup:onEnter()
	self.touchPriority = -600
	self.buyCount = 1 
	
	self.menu_close:setTouchPriority(self.touchPriority-1)
	self.menu_detail:setTouchPriority(self.touchPriority-1)
	self.bn_buy:setTouchPriority(self.touchPriority-1) 
	self.menu_jian:setTouchPriority(self.touchPriority-1) 
	self.menu_jia:setTouchPriority(self.touchPriority-1) 
	self.menu_max:setTouchPriority(self.touchPriority-1) 

	self:addTouchEventListener(function(event, x, y)
																if event == "began" then
																	self.preTouchFlag = self:isTouchOutOfView(x, y)
																	return true
																elseif event == "ended" then
																	local curFlag = self:isTouchOutOfView(x, y)
																	if self.preTouchFlag == true and curFlag == true then
																		echo(" touch out of region: close popup") 
																		self:closeCallback()
																	end 
																end
														end,
							false, self.touchPriority, true)
	self:setTouchEnabled(true)

	
	local flag
	local iType 
	--update info 
	if self._data ~= nil then 
		local configId = self._data:getConfigId()
		local count = self._data:getItemCount()
		local price = self._data:getDiscountPrice()
		echo("=== configid", configId)

		self:initInputInfos(self._data)

		flag = math.floor(configId/10000000)
		if configId < 100 or flag == 2 then 
			iType = 6 
		elseif flag == 3 then 
			iType = 7 
		elseif flag == 1 then 
			iType = 8 
		end 

		local chipImg = GameData:Instance():getCurrentPackage():getItemSprite(nil, iType, configId, 1)
		if chipImg ~= nil then 
			self.node_chip:addChild(chipImg)
		end 
		local name = ""
		local desc = ""
		local ownNum = 0 
		self.menu_detail:setVisible(false)

		if iType == 6 then 
			name = AllConfig.item[configId].item_name 
			desc = AllConfig.item[configId].item_desc 
			ownNum = GameData:Instance():getCurrentPackage():getPropsNumByConfigId(configId)
			self.menu_detail:setVisible(AllConfig.item[configId].item_type ==iType_CardChip)
			
		elseif iType == 7 then 
			name = AllConfig.equipment[configId].name 
			desc = AllConfig.equipment[configId].description
			ownNum = GameData:Instance():getCurrentPackage():getEquipNumByConfigId(configId)

		elseif iType == 8 then 
			name = AllConfig.unit[configId].unit_name 
			desc = AllConfig.unit[configId].description
			ownNum = GameData:Instance():getCurrentPackage():getCardNumByConfigId(configId)
		end 
		self.label_name:setString(name)
		self.label_count:setString(string.format("%d", ownNum))

		self.label_desc:setString(desc)

		self.label_buyCount:setString(string.format("%d", count))
		self.label_cost:setString(string.format("%d", price))

		self:setCurrencyIcon(self._data, self.sprite_currency)
	end 
end 


function CardSoulShopPopup:onExit()

end 


function CardSoulShopPopup:isTouchOutOfView(x, y)
	--outside check 
	local size2 = self.sprite_popBg:getContentSize()
	local pos2 = self.sprite_popBg:convertToNodeSpace(ccp(x, y))
	if pos2.x < 0 or pos2.x > size2.width or pos2.y < 0 or pos2.y > size2.height then 
		return true 
	end

	return false  
end 

function CardSoulShopPopup:setDataIndex(idx)
	self._dataIndex = idx 
end 

function CardSoulShopPopup:getDataIndex()
	return self._dataIndex
end 

function CardSoulShopPopup:closeCallback()
	self:removeFromParentAndCleanup(true)
end 

function CardSoulShopPopup:detailCallback()
	if self.menu_detail:isVisible() == false then 
		return 
	end 

	if self._data ~= nil then 
		local configId = self._data:getConfigId()
		local cardId 
		for k, v in pairs(AllConfig.cardcombine) do 
			if v.id == configId then 
				cardId = v.target_card 
				break 
			end 
		end 
		if cardId ~= nil then 
			local cardHead = OrbitCard.new({configId = cardId}) 
			cardHead:show()
		end 
	end 	
end 

function CardSoulShopPopup:buyCallback()
	if self:getDelegate() ~= nil then 
		self:getDelegate():buyItem(self:getDataIndex(), self.buyCount)
	end 
	
	self:closeCallback()
end 

function CardSoulShopPopup:setCurrencyIcon(shopItem, obj)
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

	if frame and obj then 
		obj:setDisplayFrame(frame)
	end 	
end 

function CardSoulShopPopup:initInputInfos(shopItem)
	if shopItem:getCurrencyType() == CurrencyType.Bable then --只有通天商城才允许手动输入
		self.node_costInfo:setVisible(false)
		self.node_input:setVisible(true)

		self.buyCount = 1
		local ownBablePoint = GameData:Instance():getCurrentPlayer():getBablePoint()
		self:setInputMax(math.min(50,  math.floor(ownBablePoint/shopItem:getDiscountPrice())))
		self:initInputBox()
	else 
		self.node_costInfo:setVisible(true)
		self.node_input:setVisible(false)
	end 
end 

function CardSoulShopPopup:setInputMin(val)
  self._inputMin = val
end 

function CardSoulShopPopup:getInputMin()
  return self._inputMin or 0
end 

function CardSoulShopPopup:setInputMax(val)
	self._inputMax = val
end 

function CardSoulShopPopup:getInputMax()
	return self._inputMax or 10
end 


function CardSoulShopPopup:decreseCallback()
  if self.buyCount > 0 then
    self.buyCount = self.buyCount - 1
    if self.buyCount <= 0 then 
      self.buyCount = self:getInputMin()
    end 
    
    if self.inputBox ~= nil then 
      self.inputBox:setText(string.format("%d",self.buyCount))
    end

    self.label_cost2:setString(string.format("%d",self.buyCount*self._data:getDiscountPrice()))   
  end
end

function CardSoulShopPopup:increseCallback()

  self.buyCount = self.buyCount + 1
  if self.buyCount > self:getInputMax() then 
    self.buyCount = self:getInputMax()
  end

  if self.inputBox ~= nil then 
    self.inputBox:setText(string.format("%d",self.buyCount))
  end

	self.label_cost2:setString(string.format("%d",self.buyCount*self._data:getDiscountPrice()))
end

function CardSoulShopPopup:maxCallback()
  if self:getInputMax() > 0 then 
    self.buyCount = self:getInputMax()

    if self.inputBox ~= nil then 
      self.inputBox:setText(string.format("%d",self.buyCount))
    end

    self.label_cost2:setString(string.format("%d",self.buyCount*self._data:getDiscountPrice()))   
  end
end

function CardSoulShopPopup:initInputBox()

  local function editBoxTextEventHandle(strEventName,pSender)
    if strEventName == "began" then

    elseif strEventName == "changed" then
      --self.inputNum = toint(self.inputBox:getText())
      --self:updateBooks()
    elseif strEventName == "ended" then

    elseif strEventName == "return" then
      self.buyCount = toint(self.inputBox:getText())
      if self.buyCount > self:getInputMax() then 
        self.buyCount = self:getInputMax()
      elseif self.buyCount <= 0 then 
        self.buyCount = self:getInputMin()
      end

      self.label_cost2:setString(string.format("%d",self.buyCount*self._data:getDiscountPrice())) 
    end
  end

  self.inputBox = UIHelper.convertBgToEditBox(self.sprite9_input,string.format("%d",self.buyCount),22,ccc3(69,20,1))
  self.inputBox:setMaxLength(6)
  self.inputBox:setInputMode(kEditBoxInputModeNumeric)
  self.inputBox:setTouchPriority(self.touchPriority - 1)
  self.inputBox:registerScriptEditBoxHandler(editBoxTextEventHandle)

  self.label_cost2:setString(string.format("%d",self.buyCount*self._data:getDiscountPrice())) 
end 



