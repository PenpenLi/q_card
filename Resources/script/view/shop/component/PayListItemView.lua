


require("model.shop.ShopItem")
require("view.component.PopupView")
require("view.component.Toast")
PayListItemView = class("PayListItemView", BaseView)

PayListItemView._itemData = nil

local btnIsEnable = true

local function getRange(object)
	local x = object:getPositionX()
	local y = object:getPositionY()

	local parent = object:getParent()
	if parent then
		x = x + parent:getPositionX()
		y = y + parent:getPositionY()
		while parent:getParent() do
			parent = parent:getParent()
			x = x + parent:getPositionX()
			y = y + parent:getPositionY()
		end
	end
	return CCRectMake(x,y,object:getContentSize().width,object:getContentSize().height)
end

local function containsTouchLocation(self,x,y)
	btnIsEnable =  getRange( self.listContainer):containsPoint(ccp(x,y))
	--print("btnisEnable",btnIsEnable)
	return btnIsEnable
end

local function ccTouchBegan(self,x,y)
	if  containsTouchLocation(self,x,y) == false then
		return true
	end
	return false
end

local function onTouch(self,eventType,x,y)

	if eventType == "began" then
		local ret =   ccTouchBegan(self,x,y)
		print("ccTouchBegan(x[1],x[2])",ret)
		return ret
	end

	if eventType == "moved" then
		-- return true
	end

	if eventType == "ended" then
		-- 点击回调函数
		--clickFunc(x , y)
		-- return true
	end
end


function PayListItemView:ctor(index)
	PayListItemView.super.ctor(self)
	local pkg = ccbRegisterPkg.new(self)
	-- regist property

	pkg:addProperty("sprSaleItem","CCSprite")
	pkg:addProperty("moneyTypeIcon","CCSprite")
	pkg:addProperty("lblName","CCLabelTTF")
	pkg:addProperty("moneyType","CCLabelTTF")
	pkg:addProperty("moneyCost","CCLabelTTF")
	pkg:addProperty("lblDesc","CCLabelTTF")
	pkg:addProperty("vipTips","CCLabelTTF")
	pkg:addProperty("tips","CCLabelTTF")--首冲双倍返还

	-- register handler
	pkg:addFunc("onClickPurchase",PayListItemView.onClickPurchase)

	local layer,owner = ccbHelper.load("payListItemView.ccbi","payListItemViewCCB","CCLayer",pkg)
	self:addChild(layer)
	self._index = index
	self.lblDesc:setColor(ccc3(115,68,0)) --
	self.lblName:setColor(ccc3(69,20,1))
	self.moneyCost:setColor(ccc3(72,0,255))
	self.vipTips:setColor(ccc3(255,240,0))
	self.tips:setDimensions(CCSizeMake(150,0))
	self.tips:setString(_tr("first_pay_reward"))


	self:setTouchEnabled( true )
	self:addTouchEventListener(handler(self,onTouch ), false , -1 , true)  --吃掉下面的消息
end


function PayListItemView:onClickPurchase()

	print("onClickPurchase begin btnisEnable",btnIsEnable)
	_playSnd(SFX_CLICK)

	if btnIsEnable == false then
		return
	end

	local playerId = GameData:Instance():getCurrentPlayer():getId()
	print("playerId",playerId)
	local serverId, serverName=  Pay:Instance():getPayServerIdAndName()
	local channel = self._channel

	local roleName = GameData:Instance():getCurrentPlayer():getName()

	local balance = GameData:Instance():getCurrentPlayer():getMoney()
	local userLevel =  GameData:Instance():getCurrentPlayer():getLevel()
	local payPram4GashChannel = Pay:Instance():getPayPram4GashChannel()
	local paid = payPram4GashChannel and payPram4GashChannel.array or "0"   -- a and b or c
	local cuid = payPram4GashChannel and payPram4GashChannel.cuid or "0"
	local service= payPram4GashChannel and payPram4GashChannel.service or "0"
	local erpid = payPram4GashChannel and payPram4GashChannel.erpid or "0"
	local pram = "roleName="..roleName.."&serverName="..serverName.."&balance="..balance.."&userLevel="..userLevel.."&paid="..paid.."&cuid="..cuid.."&service="..service.."&erpid="..erpid

	print("cahnnel==",channel)
	print("parm====",pram)
	c_pay_item(self._itemdata.goodsId,playerId,self._itemdata.paymentCode,serverId,channel,pram)

	print("onClickPurchase end")
end

------
--  Getter & Setter for
--      PayListItemView._equimentData
-----
function PayListItemView:setPayListItemData(itemData)

	self._itemdata = itemData
	self._channel = itemData.channel
	local iconId = 0
	local moneyIconId = 0
	self.moneyCost:setString(itemData.price)

	echo("@@@@@ point, buyCount  ", itemData.point, itemData.alreadyBuyCount)
	if itemData.point > 0 and itemData.alreadyBuyCount ~= nil and itemData.alreadyBuyCount >=1 then
		local tipsStr = _tr("complimentary%{num}", {num=itemData.point})
		self.tips:setString(tipsStr)
	elseif self._itemdata.point == 0 and itemData.alreadyBuyCount ~= nil and itemData.alreadyBuyCount >=1 then
		self.tips:setString("")
	end
	if itemData.goodsType == 1 then -- 元宝
		self.lblName:setString(_tr("gold"))
		self.lblDesc:setString(_tr("%{num}gold",{num = itemData.count}))
		iconId = 3050049
	elseif itemData.goodsType == 2 then -- VIP 卡
		self.lblName:setString("VIP")
		self.lblDesc:setString(_tr("%{num}vip",{num = itemData.count}))  -- (itemData.count .."天VIP")
		iconId = 3050033
		self.vipTips:setVisible(true)
		self.vipTips:setString("")

		self.pVipTips = ui.newTTFLabelWithOutline( {
			text = _tr("enable_get_vip"),
			font = self.vipTips:getFontName(),
			size = self.vipTips:getFontSize(),
			x = 0,
			y = 0,
			color = ccc3(255,240,0),
			align = ui.TEXT_ALIGN_LEFT,
			outlineColor =ccc3(0,0,0),
			pixel = 2
		}
		)
		self.pVipTips:setAnchorPoint(ccp(0,0.5))
		self.pVipTips:setPosition(ccp(self.vipTips:getPosition()))
		self.vipTips:getParent():addChild(self.pVipTips)

		local curTime = Clock:Instance():getCurServerUtcTime()
		self.vip_left = GameData:Instance():getCurrentPlayer():getVipEndTime() - curTime
		if self.vip_left <= 0 then
			self.tips:setVisible(false)
		else
			if self.vip_left > 86400 then --24*3600
				self.tips:setString(_tr("left time").._tr("day %{count}",{count =  math.ceil(self.vip_left/86400) }))  -- string.format("%d天", math.ceil(self.vip_left/86400)))
			else
				--local hour = math.floor(self.vip_left/3600)
				--local min = math.floor((self.vip_left%3600)/60)
				--local sec = math.floor(self.vip_left%60)
				--self.tips:setString(_tr("left time") ..string.format("%02d:%02d:%02d", hour,min,sec))
				self.tips:setString(_tr("left time").._tr("day %{count}",{count =  1 }))
			end
		end
		--self.tips:setVisible(false)

	end

	if itemData.type == "point"   then
		self.moneyType:setString(" ".._tr("point"))
	else
		self.moneyType:setString( itemData.type)
	end


	if itemData.type == "RMB" then
		moneyIconId =  3038002
	elseif itemData.type == "USD" then
		moneyIconId = 3038001
	elseif itemData.type == "TWD" then
	--	moneyIconId =
	elseif itemData.type == "HKD" then
		--moneyIconId =
	end

	if iconId ~= 0  then  --and moneyIconId ~= 0
		local iconImg = _res(iconId)
	--	local moneyIconImg = _res(moneyIconId)
	--	print("@@@@@@@@@@@",moneyIconImg)

		local width = iconImg:getContentSize().width
		if width > 89 then
			iconImg:setScale(89.0/width)
		end
		local posX,posY = self.sprSaleItem:getPosition()
		local parent = self.sprSaleItem:getParent()
		if iconImg~=nil  then
			self.sprSaleItem:removeFromParentAndCleanup(true)
			iconImg:setPosition(ccp(posX,posY))
			parent:addChild(iconImg)
		end

		local moneyTypePosX,moneyTypePosY = self.moneyTypeIcon:getPosition()
		local parent = self.moneyTypeIcon:getParent()
--		if moneyIconImg ~= nil  then
--			self.moneyTypeIcon:removeFromParentAndCleanup(true)
--			moneyIconImg:setPosition(ccp(moneyTypePosX,moneyTypePosY))
--			parent:addChild(moneyIconImg)
--		end
	end
end

function PayListItemView:setContainer(object)
	self.listContainer = object
end

return PayListItemView
