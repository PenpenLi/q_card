

require("view.card_soul.CardSoulBaseView")
require("view.card_soul.CardSoulChipListView")

require("model.card_soul.CardSoul")

CardSoulController = class("CardSoulController",BaseController)

function CardSoulController:ctor()
	CardSoulController.super.ctor(self,"CardSoulController")

	--reset data 
	CardSoul:instance():setRefinedCards({})
	CardSoul:instance():resetCardRefineData()
end

function CardSoulController:enter(viewIndex)
	CardSoulController.super.enter(self)

	self:setCurViewIndex(viewIndex)
	
	self.baseView = CardSoulBaseView.new()
	if self.baseView ~= nil then 
		self.baseView:setDelegate(self)
		self:getScene():replaceView(self.baseView,false,false)
	end 
end

function CardSoulController:exit()
  CardSoulController.super.exit(self)
end 

function CardSoulController:disPlayCardListForRefine()
	local sourceCards = CardSoul:instance():getCardsForRefinedList()

	local view = CardListView.new(SelectType.SELECTE_ALL)
	view:setDelegate(self)
	view:setIsUsedFor(CardListType.CARD_SOUL)
	view:init(sourceCards)
	self:getScene():replaceView(view,false,false)
end 

function CardSoulController:disPlayChipListForRefine()
	local view = CardSoulChipListView.new()
	view:setDelegate(self)
	self:getScene():replaceView(view,false,false)
end 

function CardSoulController:disPlayCardListForReborn()
	local sourceCards = CardSoul:instance():getCardsForRebornList()

	local view = CardListView.new(SelectType.SELECTE_ONE)
	view:setDelegate(self)
	view:setIsUsedFor(CardListType.CARD_REBORN)
	view:init(sourceCards)
	self:getScene():replaceView(view,false,false)
end 

function CardSoulController:displayPreView()
	self.baseView = CardSoulBaseView.new()
	if self.baseView ~= nil then 
		self.baseView:setDelegate(self)
		self:getScene():replaceView(self.baseView,false,false)
	end 	
end 

function CardSoulController:getBaseView()
	return self.baseView
end 

function CardSoulController:getListViewSize()
	return self:getBaseView():getCanvasContentSize()
end 

function CardSoulController:setCurViewIndex(index)
	self._viewIndex = index
end 

function CardSoulController:getCurViewIndex()
	return self._viewIndex or CardSoulMenu.SHOP
end 

function CardSoulController:gotoPayView()
	local controller = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
	controller:enter(ShopCurViewType.PAY)		
end 

function CardSoulController:goToItemView() 
  local bagController = ControllerFactory:Instance():create(ControllerType.BAG_CONTROLLER)
  bagController:enter()
end

return CardSoulController
