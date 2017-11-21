require("controller.BaseController")
require("view.cardbag.CardBagView")


CardBagController = class("CardBagController",BaseController)

function CardBagController:ctor()
  CardBagController.super.ctor(self)
end


function CardBagController:enter(isEntryEquipView)
  CardBagController.super.enter(self)
  self:setScene(GameData:Instance():getCurrentScene())
  if isEntryEquipView == true then 
    self:displayEquipBagView()
  else 
    self:displayCardBagView()
  end

  GameData:Instance():pushViewType(ViewType.card_bag, isEntryEquipView)
end

function CardBagController:exit()
  CardBagController.super.exit(self)
end 

function CardBagController:displayCardBagView()
  self.cardbagview = CardBagView.new()
  self.cardbagview:setDelegate(self)
  self.cardbagview:setIsFirstEntryEquipView(false)
  self:getScene():replaceView(self.cardbagview)
end

function CardBagController:displayEquipBagView()
  self.cardbagview = CardBagView.new()
  self.cardbagview:setDelegate(self)
  self.cardbagview:setIsFirstEntryEquipView(true)
  self:getScene():replaceView(self.cardbagview)
end

function CardBagController:displayHomeView()
  echo("CardBagController:displayHomeView:")
  local homeController = ControllerFactory:Instance():create(ControllerType.HOME_CONTROLLER)
  if homeController ~= nil then
  	homeController:enter()
  end
  --display.replaceScene(homeController:getScene(), "fade", 0, display.COLOR_WHITE)
end

function CardBagController:goBackView()
  GameData:Instance():gotoPreView()
end 