require("controller.BaseController")
require("view.bag.BagView")


BagController = class("BagController",BaseController)


function BagController:ctor()
  BagController.super.ctor(self)

  GameData:Instance():pushViewType(ViewType.bag)
end

function BagController:enter(viewIdx)
  BagController.super.enter(self)
  self:displayBagView(viewIdx)
end

function BagController:exit()
  BagController.super.exit(self)
  echo("---BagController:exit---")
end

function BagController:displayBagView(viewIdx)
  local view = BagView.new(viewIdx)
  view:setController(self)
  self:getScene():replaceView(view)  
end 

function BagController:displayHomeView()
  echo("BagController:displayHomeView")
  local homeController = ControllerFactory:Instance():create(ControllerType.HOME_CONTROLLER)
  homeController:enter()
end

function BagController:goBackView()
  GameData:Instance():gotoPreView()
end 



