require("controller.BaseController")
require("model.bable.Bable")

BableController = class("BableController",BaseController)


function BableController:ctor()
	BableController.super.ctor(self)

end

function BableController:enter()
  BableController.super.enter(self)

  Bable:instance():setSharedCard(nil)
  
  local view = require("view.bable.BableView").new()
  view:setDelegate(self)
	self:getScene():replaceView(view)

	GameData:Instance():pushViewType(ViewType.bable)
end

function BableController:goBackView()
	GameData:Instance():gotoPreView()
end 

function BableController:disPlayCardListForBable()
  local sourceCards = Bable:instance():getCardsForShareList()

  local view = CardListView.new(SelectType.SELECTE_ONE)
  view:setDelegate(self)
  view:setIsUsedFor(CardListType.BABLE_SHARE)
  view:init(sourceCards)
  self:getScene():replaceView(view,false,false)
end 

--返回选择共享卡牌界面
function BableController:displayPreView()
  local view = require("view.bable.BableView").new()
  view:setDelegate(self)
  view:assistCallback(true)
  self:getScene():replaceView(view)
end 




