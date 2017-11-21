require("view.shop.LotteryView")
require("model.Mall")


LotteryController = class("LotteryController",BaseController)

function LotteryController:ctor()
	LotteryController.super.ctor(self)
end

function LotteryController:enter()
	LotteryController.super.enter(self)
	Mall:Instance()

	--self:setScene(GameData:Instance():getCurrentScene())
	self._lotteryView = LotteryView.new(self)
	self._lotteryView:enter()

	self:getScene():replaceView(self._lotteryView)
	
	GameData:Instance():pushViewType(ViewType.lottery)
end

function LotteryController:goBackView()
	GameData:Instance():gotoPreView()
end

function LotteryController:gotoMining()
  if GameData:Instance():checkSystemOpenCondition(3, true) == false then 
    return 
  end 
  local controller = ControllerFactory:Instance():create(ControllerType.MINING_CONTROLLER)
  controller:enter() 
end 

return LotteryController