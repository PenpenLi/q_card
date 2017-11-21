
require("model.shop.Shop")
require("model.Pay")
require("view.shop.ShopBaseView")
require("view.component.Toast")
require("view.component.Loading")
require("view.shop.VipInfoView")

ShopController = class("ShopController",BaseController)

ShopController.ItemType = enum({"NONE","SPRITE","TOKEN"})

function ShopController:ctor()
	ShopController.super.ctor(self)

end

function ShopController:enter(viewIndex)
	ShopController.super.enter(self)

	self:setCurViewIndex(viewIndex)
	self.baseView = ShopBaseView.new()
	self.baseView:setDelegate(self)
	self:getScene():replaceView(self.baseView,false,false)	
end

function ShopController:setCurViewIndex(viewIndex)
	self._viewIndex = viewIndex
end 

function ShopController:getCurViewIndex()
	return self._viewIndex or ShopCurViewType.JiShi
end 

function ShopController:initSpriteAndTokenPriceRange()
	self.tAllSpritePrice ={}
	self.tAllTokenPrice = {}
	for k, v in pairs(AllConfig.cost) do
		if v.type == 3 then
			table.insert(self.tAllSpritePrice,AllConfig.cost[k])
		elseif v.type == 6 then
			table.insert(self.tAllTokenPrice,AllConfig.cost[k])
		end
	end

	local function TableSort(a, b)
		return  a.id < b.id
	end

	if #self.tAllTokenPrice > 0 then
		table.sort(self.tAllTokenPrice,TableSort)
	end
	if #self.tAllSpritePrice >0 then
		table.sort(self.tAllSpritePrice,TableSort)
	end
end

function ShopController:getSpritePriceRangeCount()
	return #self.tAllSpritePrice
end

function ShopController:getTokenPriceRangeCount()
	return #self.tAllTokenPrice
end

function ShopController:getCurPriceByCount(type,count)
	if type == BuyItemType.SPRITE  then
		for k, v in pairs(self.tAllSpritePrice) do
			if  count>= v.min_count  and (count <=v.max_count or v.max_count ==-1) then
				return v.cost
			end
		end
	elseif type == BuyItemType.TOKEN then
		for k, v in pairs(self.tAllTokenPrice) do
			if  count>= v.min_count  and (count <=v.max_count or v.max_count ==-1) then
				return v.cost
			end
		end
	end
end

function ShopController:updataSpriteAndTokenPrice()
	local package = GameData:Instance():getCurrentPackage()
	local player = GameData:Instance():getCurrentPlayer()
	local mArray = package:getCollectSales()
	local iBuyTokenCount =  player:getBuyTokenCount() + 1
	local iBuySpriteCount = player:getBuySpriteCount() + 1


	for k, v in pairs(mArray) do
		if v:getConfigId() == 20801002  then
			local spritePrice = self:getCurPriceByCount(BuyItemType.SPRITE,iBuySpriteCount)

			v:setPrice(spritePrice)
		elseif v:getConfigId() == 20901001 then
			local tokenPrice = self:getCurPriceByCount(BuyItemType.TOKEN,iBuyTokenCount)
			v:setPrice(tokenPrice)
		end
	end
end

function ShopController:displayVipInfoView() 
	local view = VipInfoView:createVipPopView()
	view:setDelegate(self.baseView)
	self:getScene():addChild(view)
end 

function ShopController:gotoBagView(iType)
	local controller

	if iType == 6 then 
		controller = ControllerFactory:Instance():create(ControllerType.BAG_CONTROLLER)
		controller:enter()
	elseif iType == 7 then 
		controller = ControllerFactory:Instance():create(ControllerType.CARDBAG_CONTROLLER)
		controller:enter(true)
	elseif iType == 8 then
		controller = ControllerFactory:Instance():create(ControllerType.CARDBAG_CONTROLLER)
		controller:enter(false)
	end  
end 

function ShopController:gotoVipPrivilegeView()
	Activity:instance():entryActView(ActMenu.VIP_PRIVILEGE, false)
end 

return ShopController
