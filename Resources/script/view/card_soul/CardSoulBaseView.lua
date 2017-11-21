
require("view.component.ViewWithEave")
require("view.card_soul.CardSoulRefineCardView")
require("view.card_soul.CardSoulRefineChipView")
require("view.card_soul.CardSoulShopView")
require("view.enhance.CardRebornView")
require("model.shop.Shop")

CardSoulBaseView = class("CardSoulBaseView", ViewWithEave)

function CardSoulBaseView:ctor()
	CardSoulBaseView.super.ctor(self)

	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("img/cardSoul/cardSoul.plist")
end 

function CardSoulBaseView:onEnter()
	echo("=== CardSoulBaseView:onEnter=== ")

	local viewIndex = self:getDelegate():getCurViewIndex()
	local menuArray = {}
	if GameData:Instance():getLanguageType() == LanguageType.JPN then
		menuArray = {
			{"#bn_soul_shop0.png","#bn_soul_shop1.png"},
			{"#bn_soul_card0.png","#bn_soul_card1.png"},
			{"#bn_soul_chip0.png","#bn_soul_chip1.png"}
		}
	else 
		menuArray = {
			{"#bn_soul_shop0.png","#bn_soul_shop1.png"},
			{"#bn_soul_card0.png","#bn_soul_card1.png"},
			{"#bn_soul_chip0.png","#bn_soul_chip1.png"},
			{"#bn_reborn0.png","#bn_reborn1.png"} 
		}
	end 

	self:setMenuArray(menuArray)
	self:getTabMenu():setItemSelectedByIndex(toint(viewIndex))

	self:showView(viewIndex)
	
	_executeNewBird()
end 

function CardSoulBaseView:onExit()
	echo("=== CardSoulBaseView:onExit=== ")
	-- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("img/cardSoul/cardSoul.plist")
end 

function CardSoulBaseView:onHelpHandler()
	if self.subView ~= nil then 
		self.subView:onHelpHandler()
	end 
end 

function CardSoulBaseView:onBackHandler()
  echo("=== CardSoulBaseView:backCallback")
  CardSoulBaseView.super:onBackHandler()
  GameData:Instance():gotoPreView()
end


function CardSoulBaseView:showView(viewIndex)
	if self:getDelegate():getCurViewIndex() == viewIndex and self.subView ~= nil then 
		return false 
	end 
	
	if viewIndex == CardSoulMenu.CARD_REBORN then 
		self:setTitleTextureName("reborn_title.png")
	else 
		self:setTitleTextureName("soul_title.png")
	end 

	local view = nil 
	if viewIndex == CardSoulMenu.REFINE_CARD then 
		view = CardSoulRefineCardView.new() 
		CardSoul:instance():resetChipRefineData()
		CardSoul:instance():resetCardRebornData()
		self:getEaveView().btnHelp:setVisible(true)

	elseif viewIndex == CardSoulMenu.REFINE_CARD_CHIP then 
		view = CardSoulRefineChipView.new()
		CardSoul:instance():resetCardRefineData()
		CardSoul:instance():resetCardRebornData()
		self:getEaveView().btnHelp:setVisible(true)

	elseif viewIndex == CardSoulMenu.SHOP then 
		view = CardSoulShopView.new(ShopCurViewType.Soul)
		CardSoul:instance():resetChipRefineData()
		CardSoul:instance():resetCardRefineData()
		CardSoul:instance():resetCardRebornData()
		self:getEaveView().btnHelp:setVisible(false)

	elseif viewIndex == CardSoulMenu.CARD_REBORN then				
		view = CardRebornView.new() 
		CardSoul:instance():resetCardRefineData()		
		CardSoul:instance():resetChipRefineData()	
		self:getEaveView().btnHelp:setVisible(true)	
	else 
		echo("=== invalid view index.")
	end 
	
	if view ~= nil  then
		if self.subView ~= nil then 
			self.subView:removeFromParentAndCleanup(true)
		end 
		view:setDelegate(self:getDelegate())
		self:getEaveView():getNodeContainer():addChild(view)    
		self.subView = view 
		self:getDelegate():setCurViewIndex(viewIndex)

		GameData:Instance():pushViewType(ViewType.lianhun, viewIndex)

		self:showShopMenuTips(viewIndex)
		
		return true 
	end 

	return false 
end 

function CardSoulBaseView:tabControlOnClick(idx)
	_playSnd(SFX_CLICK) 

	echo("=== tabControlOnClick", idx)
	local result = true
	if idx == 0 then
		result = self:showView(CardSoulMenu.SHOP)
	elseif idx == 1 then 
		result = self:showView(CardSoulMenu.REFINE_CARD)
	elseif idx == 2 then
		result = self:showView(CardSoulMenu.REFINE_CARD_CHIP)
	elseif idx == 3 then
		result = self:showView(CardSoulMenu.CARD_REBORN)
	end

	return result
end

function CardSoulBaseView:showShopMenuTips(viewIndex)
	if viewIndex ~= CardSoulMenu.SHOP then 
		local tipFlag = Shop:instance():getTipsFlag(ShopCurViewType.Soul)
		echo("=== tipFlag", tipFlag)
		self:getTabMenu():setTipImgVisible(CardSoulMenu.SHOP, tipFlag)
	end 
end 