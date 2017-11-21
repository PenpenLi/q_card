require("controller.BaseController")
require("view.mail.MailListView")
require("model.mail.MailBox")


MailController = class("MailController",BaseController)



function MailController:ctor()
  MailController.super.ctor(self)
  self.firstEngtry = true
end


function MailController:enter(index)
  MailController.super.enter(self)

  if nil == self:getScene() then
    self:setScene(GameData:Instance():getCurrentScene())
  end

  self:displayMailListView(index,nil)
end


function MailController:enterWriteView(revName)
  MailController.super.enter(self)

  local view = MailListView.new(2, revName)
  view:setDelegate(self)
  view:init()
  view:writeCallback(revName)
  self:getScene():replaceView(view)
end

function MailController:displayMailListView(index, revName)
  local view = MailListView.new(index, revName)
  view:setDelegate(self)
  view:init()
  self:getScene():replaceView(view)
end

function MailController:displayHomeView()
  echo("MailController:displayHomeView")
  local homeController = ControllerFactory:Instance():create(ControllerType.HOME_CONTROLLER)
  homeController:enter()
end




function MailController:goToItemView() -- 跳到行囊界面
  local bagController = ControllerFactory:Instance():create(ControllerType.BAG_CONTROLLER)
  bagController:enter()
end

function MailController:goToCardBagView() -- 跳到卡牌背包界面
  local cardBagController = ControllerFactory:Instance():create(ControllerType.CARDBAG_CONTROLLER)
  cardBagController:enter(false)
end

function MailController:goToEquipBagView() -- 跳到装备背包界面
  local cardBagController = ControllerFactory:Instance():create(ControllerType.CARDBAG_CONTROLLER)
  cardBagController:enter(true)
end