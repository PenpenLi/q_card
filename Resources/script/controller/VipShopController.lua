

require("view.card_soul.VipShopView")



VipShopController = class("VipShopController",BaseController)

function VipShopController:ctor()
	VipShopController.super.ctor(self,"VipShopController")
end

function VipShopController:enter(viewIndex)
	VipShopController.super.enter(self)

	self.baseView = VipShopView.new()
	if self.baseView ~= nil then 
		self.baseView:setDelegate(self)
		self:getScene():replaceView(self.baseView,false,false)
	end 
end

function VipShopController:getBaseView()
	return self.baseView 
end 

function VipShopController:getListViewSize()
	return self:getBaseView():getCanvasContentSize()
end 

function VipShopController:gotoPayView()
	local controller = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
	controller:enter(ShopCurViewType.PAY)		
end 

function VipShopController:goToItemView() 
  local bagController = ControllerFactory:Instance():create(ControllerType.BAG_CONTROLLER)
  bagController:enter()
end

return VipShopController
