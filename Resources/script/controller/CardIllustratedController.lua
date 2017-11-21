require("view.Illustrated.CardIllustratedView")
require("model.Illustrated.Illustrated")
CardIllustratedController = class("CardIllustratedController",BaseController)

function CardIllustratedController:ctor()
  CardIllustratedController.super.ctor(self,"CardIllustratedController")
  self.illustrated = GameData:Instance():getCurrentPlayer():getIllustratedInstance()
end

function CardIllustratedController:enter()
  CardIllustratedController.super.enter(self)
  self.cardIllustratedView = CardIllustratedView.new(self,self.illustrated)
  self:getScene():replaceView(self.cardIllustratedView)
end

function CardIllustratedController:goToHome()
   local homeController = ControllerFactory:Instance():create(ControllerType.HOME_CONTROLLER)
   homeController:enter()
end

function CardIllustratedController:exit()
  CardIllustratedController.super.exit(self)
end

return CardIllustratedController