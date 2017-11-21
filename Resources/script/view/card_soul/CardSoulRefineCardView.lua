
require("view.BaseView")
require("common.Consts")

CardSoulRefineCardView = class("CardSoulRefineCardView", BaseView)

function CardSoulRefineCardView:ctor(viewIndex)
	CardSoulRefineCardView.super.ctor(self)

	local pkg = ccbRegisterPkg.new(self)
	pkg:addFunc("patchAddCallback",CardSoulRefineCardView.patchAddCallback)
	pkg:addFunc("xilianCallback",CardSoulRefineCardView.xilianCallback)
	pkg:addFunc("addCardCallback",CardSoulRefineCardView.addCardCallback)
	pkg:addFunc("animFinishCallback",CardSoulRefineCardView.animFinishCallback)
	pkg:addFunc("allAnimEnd",CardSoulRefineCardView.allAnimEnd)

	pkg:addProperty("node_addCard1","CCNode")
	pkg:addProperty("node_addCard2","CCNode")
	pkg:addProperty("node_addCard3","CCNode")
	pkg:addProperty("node_addCard4","CCNode")
	pkg:addProperty("node_addCard5","CCNode")
	pkg:addProperty("node_anim","CCNode")
	pkg:addProperty("node_anim1","CCNode")
	pkg:addProperty("node_anim2","CCNode")
	pkg:addProperty("node_anim3","CCNode")
	pkg:addProperty("node_anim4","CCNode")
	pkg:addProperty("node_anim5","CCNode")

	pkg:addProperty("sprite_add1","CCSprite")
	pkg:addProperty("sprite_add2","CCSprite")
	pkg:addProperty("sprite_add3","CCSprite")
	pkg:addProperty("sprite_add4","CCSprite")
	pkg:addProperty("sprite_add5","CCSprite")
	pkg:addProperty("sprite_stove","CCSprite")

	pkg:addProperty("bn_patchAdd","CCControlButton")
	pkg:addProperty("bn_xilian","CCControlButton")

	pkg:addProperty("label_preGain","CCLabelTTF")
	pkg:addProperty("label_preCost","CCLabelTTF")
	pkg:addProperty("label_cost","CCLabelBMFont")
	pkg:addProperty("label_gainSoul","CCLabelBMFont")
	pkg:addProperty("label_gainCoin","CCLabelBMFont")
	pkg:addProperty("mAnimationManager","CCBAnimationManager")

	local layer,owner = ccbHelper.load("CardSoulRefineCardView.ccbi","CardSoulRefineCardViewCCB","CCLayer",pkg)
	self:addChild(layer)

end

function CardSoulRefineCardView:onEnter()
	echo("=== CardSoulRefineCardView:onEnter=== ")
	net.registMsgCallback(PbMsgId.ReqJianghunResult, self, CardSoulRefineCardView.ReqJianghunResult)

	self.cardNodes = {self.node_addCard1, self.node_addCard2, self.node_addCard3, self.node_addCard4, self.node_addCard5}
	self.animNodes = {self.node_anim1, self.node_anim2, self.node_anim3, self.node_anim4, self.node_anim5}

	self.NumMax = #self.cardNodes

	self.node_anim:setVisible(false)
	self:initOutLineLabel()

	--anim effect 
	local fire,offsetX,offsetY,duration = _res(5020207)
	if fire ~= nil then
	fire:setPosition(ccp(310, 152))
	self.sprite_stove:addChild(fire)
	fire:getAnimation():play("default")
	end	

	self:showCardsInfo()
end 

function CardSoulRefineCardView:onExit()
	echo("=== CardSoulRefineCardView:onExit=== ")
	net.unregistAllCallback(self) 
end 

function CardSoulRefineCardView:patchAddCallback()
	local sourceCards = CardSoul:instance():getCardsForRefinedList()
	local len = #sourceCards
	if len > 0 then 
		GameData:Instance():getCurrentPackage():sortCards(sourceCards, SortType.LEVEL_UP, SortType.RARE_UP) 
		--reset
		for k, v in pairs(sourceCards) do 
			v.isSelected = false 
		end 

		local tbl = {}
		local count = 0 
		for i=1, len do 
			if sourceCards[i]:getMaxGrade() < 5 then 
				sourceCards[i].isSelected = true 
				table.insert(tbl, sourceCards[i])
				
				count = count + 1 
				if count >= self.NumMax then 
					break 
				end 
			end 
		end 

		CardSoul:instance():setRefinedCards(tbl)
		self:showCardsInfo()
	else 
		Toast:showString(self, string._tran(Consts.Strings.SOUL_NO_CARDS_FOR_REFINED), ccp(display.cx, display.cy))
	end 
end 

function CardSoulRefineCardView:xilianCallback()
	echo("=== CardSoulRefineCardView:xilianCallback")

	local tbl = {}
	local cards = CardSoul:instance():getRefinedCards()
	self.refinedCardsCount = math.min(self.NumMax, #cards)

	if self.refinedCardsCount > 0 then 
		local curCoin = GameData:Instance():getCurrentPlayer():getCoin()
		if curCoin < self.needCoin then 
			Toast:showString(self, _tr("not enough coin"), ccp(display.cx, display.cy))
			return 
		end 

		local function sendMsgToRefine()
			for k=1, self.refinedCardsCount do 
				echo("=== sysId", cards[k]:getId())
				table.insert(tbl, cards[k]:getId())
			end 
      
      _showLoading()
			local data = PbRegist.pack(PbMsgId.ReqJianghun, {card_id=tbl})
			net.sendMessage(PbMsgId.ReqJianghun, data)

			--self.loading = Loading:show()
		end 

		local str = string._tran(Consts.Strings.SOUL_BE_SURE_TO_REFINE_CARD)
		local pop = PopupView:createTextPopup(str, sendMsgToRefine)
		self:addChild(pop)

	else 
		Toast:showString(self, _tr("please select card"), ccp(display.cx, display.cy))
	end 
end

function CardSoulRefineCardView:addCardCallback()
	self:getDelegate():disPlayCardListForRefine()
end

function CardSoulRefineCardView:initOutLineLabel()
	self.label_preGain:setString("")
	local outline1 = ui.newTTFLabelWithOutline({
																							text = _tr("will get"),
																							font = self.label_preGain:getFontName(),
																							size = self.label_preGain:getFontSize(),
																							x = 0,
																							y = 0,
																							color = ccc3(255, 255, 255),
																							align = ui.TEXT_ALIGN_LEFT,
																							outlineColor =ccc3(0,0,0),
																							pixel = 2
																						}
																					)

	outline1:setPosition(ccpAdd(ccp(self.label_preGain:getPosition()), ccp(-outline1:getContentSize().width/2, 0)))
	self.label_preGain:getParent():addChild(outline1) 

	self.label_preCost:setString("")
	local outline2 = ui.newTTFLabelWithOutline({
																							text = _tr("pre_cost_desc"),
																							font = self.label_preCost:getFontName(),
																							size = self.label_preCost:getFontSize(),
																							x = 0,
																							y = 0,
																							color = ccc3(255, 255, 255),
																							align = ui.TEXT_ALIGN_LEFT,
																							outlineColor =ccc3(0,0,0),
																							pixel = 2
																						}
																					)
	outline2:setPosition(ccpAdd(ccp(self.label_preCost:getPosition()), ccp(-outline2:getContentSize().width/2, 0)))
	self.label_preCost:getParent():addChild(outline2) 	 
end 

function CardSoulRefineCardView:showCardsInfo()
	for i=1, #self.cardNodes do 
		self.cardNodes[i]:removeAllChildrenWithCleanup(true)
	end 

	self.needCoin = 0 
	local gainedSoul = 0 
	local gainedCoin = 0 
	local cards = CardSoul:instance():getRefinedCards()
	local len = math.min(self.NumMax, #cards)
	self.bn_xilian:setEnabled(len>0)

	for k=1, len do 
		local headCard = MiddleCardHeadView.new()
		headCard:setCard({card = cards[k]})
		headCard:drawAvatarBg(cards[k]:getMaxGrade()) --手动根据最大星级显示边框颜色, 防止误删除
		local size = headCard:getContentSize()
		headCard:setScale(135/size.width)
		headCard:setPosition(ccp(-size.width/2, -size.height/2))
		self.cardNodes[k]:addChild(headCard)
		
		local closeImg = CCSprite:createWithSpriteFrameName("bn_soul_jian0.png")
		if closeImg ~= nil then 
			local menuSize = closeImg:getContentSize()
			local menu = CCMenu:create()
			local menuItem = CCMenuItemSprite:create(closeImg, nil, nil)
			menuItem:setTag(cards[k]:getId()*100+k)
			menuItem:registerScriptTapHandler(handler(self, CardSoulRefineCardView.remvoveCard))
			menu:addChild(menuItem)
			menu:setPosition(ccp(size.width/2-menuSize.width/2, size.height/2-menuSize.height/2))
			self.cardNodes[k]:addChild(menu)
		end 

		self.needCoin = self.needCoin + cards[k]:getCardSoulCost()
		if cards[k]:getCardSoulGainType() == CurrencyType.Soul then
			gainedSoul = gainedSoul + cards[k]:getCardSoulGain()
		elseif cards[k]:getCardSoulGainType() == CurrencyType.Coin then 
			gainedCoin = gainedCoin + cards[k]:getCardSoulGain()
		end 
	end 

	self.label_cost:setString(string.format("%d", self.needCoin))
	self.label_gainSoul:setString(string.format("%d", gainedSoul))
	self.label_gainCoin:setString(string.format("%d", gainedCoin))
end 

function CardSoulRefineCardView:remvoveCard(tagId)

	if tagId == nil then  
		return 
	end 
	local idx = tagId%100
	local sysId = math.floor(tagId/100)
	echo("===remvoveCard:", idx, sysId)

	local cards = CardSoul:instance():getRefinedCards()
	for k, v in pairs(cards) do 
		if v:getId() == sysId then 
			cards[k].isSelected = false 
			table.remove(cards, k)
			self.cardNodes[idx]:removeAllChildrenWithCleanup(true)
			break 
		end 
	end 

	self.needCoin = 0 
	local gainedSoul = 0 
	local gainedCoin = 0 
	
	self.bn_xilian:setEnabled(#cards>0)

	for k, v in pairs(cards) do 		
		self.needCoin = self.needCoin + v:getCardSoulCost()
		if v:getCardSoulGainType() == CurrencyType.Soul then
			gainedSoul = gainedSoul + v:getCardSoulGain()
		elseif v:getCardSoulGainType() == CurrencyType.Coin then 
			gainedCoin = gainedCoin + v:getCardSoulGain()
		end 
	end 

	self.label_cost:setString(string.format("%d", self.needCoin))
	self.label_gainSoul:setString(string.format("%d", gainedSoul))
	self.label_gainCoin:setString(string.format("%d", gainedCoin))	
end 

function CardSoulRefineCardView:ReqJianghunResult(action,msgId,msg)
	echo("=== CardSoulRefineCardView:ReqJianghunResult", msg.result)

--	if self.loading ~= nil then 
--		self.loading:remove()
--		self.loading = nil
--	end 
  _hideLoading()
	self.gainItems = {}

	if msg.result == "Success" then 
		self.gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client_sync)
		self:playRefineAnim()
	end 

	CardSoul:instance():handleRefineResult(action,msgId,msg) 
end 

function CardSoulRefineCardView:playRefineAnim()

	self:addMaskLayer()

	self.node_anim:setVisible(true)
	self.animBeginIndex = 1 
	for i=1, self.NumMax do 
		self.animNodes[i]:setVisible(i<=self.refinedCardsCount)
	end 
	self.mAnimationManager:runAnimationsForSequenceNamed("anim_cardRefine") 
end 

function CardSoulRefineCardView:animFinishCallback()
	echo("===animFinishCallback")
	if self.animBeginIndex >= 1 and self.animBeginIndex <= self.NumMax then 
		self.cardNodes[self.animBeginIndex]:removeAllChildrenWithCleanup(true)
		self.animBeginIndex = self.animBeginIndex + 1 
	end 
end 

function CardSoulRefineCardView:allAnimEnd()
	echo("allAnimEnd")

	--all anims finish 
	-- if self.animBeginIndex > self.refinedCardsCount then 
		CardSoul:instance():setRefinedCards({})
		self.label_gainSoul:setString("0")
		self.label_gainCoin:setString("0")
		self.label_cost:setString("0")
		self.bn_xilian:setEnabled(false)

		if self.gainItems ~= nil then 
			for i=1,table.getn(self.gainItems) do
				echo("----gained configId:", self.gainItems[i].configId)
				echo("----gained, count:", self.gainItems[i].count)
				local str = string.format("+%d", self.gainItems[i].count)
				Toast:showIconNumWithDelay(str, self.gainItems[i].iconId, self.gainItems[i].iType, self.gainItems[i].configId, ccp(display.cx,display.cy-i*40), 0.3*(i-1))
			end	
		end 
	-- end 

	self:removeMaskLayer()
end 

function CardSoulRefineCardView:addMaskLayer()
	if self.maskLayer ~= nil then 
		self.maskLayer:removeFromParentAndCleanup(true)
	end 

	self.maskLayer = Mask.new({opacity=0, priority = -1000})
	self:addChild(self.maskLayer)
end 

function CardSoulRefineCardView:removeMaskLayer()
	if self.maskLayer ~= nil then 
		self.maskLayer:removeFromParentAndCleanup(true)
		self.maskLayer = nil 
	end 
end 

function CardSoulRefineCardView:onHelpHandler()
	local help = HelpView.new()
	help:addHelpBox(1049)
	help:addHelpItem(1050, self.node_addCard2, ccp(0,0), ArrowDir.LeftLeftDown)
	help:addHelpItem(1051, self.label_gainSoul, ccp(0,80), ArrowDir.LeftDown)
	help:addHelpItem(1052, self.bn_patchAdd, ccp(0,10), ArrowDir.RightDown)
	help:addHelpItem(1053, self.bn_xilian, ccp(-30,10), ArrowDir.LeftDown)
	self:getDelegate():getScene():addChild(help, 1000)
end 
