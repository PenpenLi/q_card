
require("view.BaseView")


CardSoulRefineChipView = class("CardSoulRefineChipView", BaseView)

function CardSoulRefineChipView:ctor(viewIndex)
	CardSoulRefineChipView.super.ctor(self)

	local pkg = ccbRegisterPkg.new(self)
	pkg:addFunc("patchAddCallback",CardSoulRefineChipView.patchAddCallback)
	pkg:addFunc("xilianCallback",CardSoulRefineChipView.xilianCallback)
	pkg:addFunc("addCardCallback",CardSoulRefineChipView.addCardCallback)
	pkg:addFunc("animHideChipsCallback",CardSoulRefineChipView.animHideChipsCallback)
	pkg:addFunc("animFinishCallback",CardSoulRefineChipView.animFinishCallback)

	pkg:addProperty("node_addCard1","CCNode")
	pkg:addProperty("node_addCard2","CCNode")
	pkg:addProperty("node_addCard3","CCNode")
	pkg:addProperty("node_addCard4","CCNode")
	pkg:addProperty("node_addCard5","CCNode")
	pkg:addProperty("node_addCard6","CCNode")
	pkg:addProperty("node_anim","CCNode")
	pkg:addProperty("node_anim1","CCNode")
	pkg:addProperty("node_anim2","CCNode")
	pkg:addProperty("node_anim3","CCNode")
	pkg:addProperty("node_anim4","CCNode")
	pkg:addProperty("node_anim5","CCNode")
	pkg:addProperty("node_anim6","CCNode")

	pkg:addProperty("sprite_add1","CCSprite")
	pkg:addProperty("sprite_add2","CCSprite")
	pkg:addProperty("sprite_add3","CCSprite")
	pkg:addProperty("sprite_add4","CCSprite")
	pkg:addProperty("sprite_add5","CCSprite")
	pkg:addProperty("sprite_add6","CCSprite")

	pkg:addProperty("bn_patchAdd","CCControlButton")
	pkg:addProperty("bn_xilian","CCControlButton")

	pkg:addProperty("label_preGain","CCLabelTTF")
	pkg:addProperty("label_preCost","CCLabelTTF")
	pkg:addProperty("label_cost","CCLabelBMFont")
	pkg:addProperty("label_gain","CCLabelBMFont")
	pkg:addProperty("label_gainCoin","CCLabelBMFont")
	pkg:addProperty("mAnimationManager","CCBAnimationManager")

	local layer,owner = ccbHelper.load("CardSoulRefineChipView.ccbi","CardSoulRefineChipViewCCB","CCLayer",pkg)
	self:addChild(layer)

	
end

function CardSoulRefineChipView:onEnter()
	echo("=== CardSoulRefineChipView:onEnter=== ")
	net.registMsgCallback(PbMsgId.ReqJianghunResult, self, CardSoulRefineCardView.ReqJianghunResult)

	self.cardNodes = {self.node_addCard1, self.node_addCard2, self.node_addCard3, self.node_addCard4, self.node_addCard5, self.node_addCard6}
	self.animNodes = {self.node_anim1, self.node_anim2, self.node_anim3, self.node_anim4, self.node_anim5, self.node_anim6}

	self.NumMax = #self.cardNodes
	self.node_anim:setVisible(false)

	self:initOutLineLabel()
	self:showChipsInfo()
end 

function CardSoulRefineChipView:onExit()
	echo("=== CardSoulRefineChipView:onExit=== ")
	net.unregistAllCallback(self) 
end 

function CardSoulRefineChipView:patchAddCallback()
	local sourceChips = CardSoul:instance():getChipsForRefinedList(ChipGrade.GRADE_ALL)
	local len = #sourceChips 
	if len > 0 then 
		GameData:Instance():getCurrentPackage():sortItems(sourceChips, 1, len, SortType.RARE_UP)

		local validCount = 0 
		local tbl = {}
		for i=1, len do 
			if validCount < self.NumMax then 
				if sourceChips[i]:getMaxGrade() < 5 then 
					sourceChips[i]:setSelectedCount(sourceChips[i]:getCount())
					table.insert(tbl, sourceChips[i])

					validCount = validCount + 1 
				end 
			else 
				sourceChips[i]:setSelectedCount(0)
			end 
		end 
		CardSoul:instance():setRefinedChips(tbl)
		self:showChipsInfo()
	else 
		Toast:showString(self, string._tran(Consts.Strings.SOUL_NO_CHIPS_FOR_REFINED), ccp(display.cx, display.cy))
	end 
end 

function CardSoulRefineChipView:xilianCallback()
	echo("=== CardSoulRefineChipView:xilianCallback")

	local tbl = {}
	local chips = CardSoul:instance():getRefinedChips()
	self.refinedChipsCount = math.min(self.NumMax, #chips)
	if self.refinedChipsCount > 0 then 
		local curCoin = GameData:Instance():getCurrentPlayer():getCoin()
		if curCoin < self.needCoin then 
			Toast:showString(self, _tr("not enough coin"), ccp(display.cx, display.cy))
			return 
		end 

		local function sendMsgToRefine()
			for k=1, self.refinedChipsCount do 
				echo("=== chips id, count:", chips[k]:getId(), chips[k]:getSelectedCount())
				table.insert(tbl, {id=chips[k]:getId(), count=chips[k]:getSelectedCount()})
			end 
      
      _showLoading()
			local data = PbRegist.pack(PbMsgId.ReqJianghun, {item_id=tbl})
			net.sendMessage(PbMsgId.ReqJianghun, data)

			--self.loading = Loading:show()
		end 

    local str = string._tran(Consts.Strings.SOUL_BE_SURE_TO_REFINE_CHIP)
    local pop = PopupView:createTextPopup(str, sendMsgToRefine)
    self:addChild(pop)

	else 
		Toast:showString(self, string._tran(Consts.Strings.SOUL_PLS_SELECT_CHIPS), ccp(display.cx, display.cy))
	end 
end 

function CardSoulRefineChipView:addCardCallback()
	self:getDelegate():disPlayChipListForRefine()
end

function CardSoulRefineChipView:initOutLineLabel()
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

function CardSoulRefineChipView:showChipsInfo()
	for i=1, #self.cardNodes do 
		self.cardNodes[i]:removeAllChildrenWithCleanup(true)
	end 

	self.needCoin = 0 
	local gainSoul = 0 
	local gainCoin = 0
	local chips = CardSoul:instance():getRefinedChips()
	local len = math.min(self.NumMax, #chips)
	echo("=== showChipsInfo", len)
	self.bn_xilian:setEnabled(len>0)

	for i=1, len do 
		local chipImg = GameData:Instance():getCurrentPackage():getItemSprite(nil, 6, chips[i]:getConfigId(), 1)
		if chipImg ~= nil then 
			self.cardNodes[i]:addChild(chipImg)

			local strNum = string.format("%d", chips[i]:getSelectedCount())
			local label = CCLabelBMFont:create(strNum, "client/widget/words/card_name/number_skillup.fnt")
			local labelSize = label:getContentSize()
			local iconSize = chipImg:getContentSize() 
			-- label:setPosition(ccp(iconSize.width/2-labelSize.width/2-4, iconSize.height/2-labelSize.height/2-6))
			label:setPosition(ccp(iconSize.width/2-labelSize.width/2+5, -iconSize.height/2+labelSize.height/2+6))
			chipImg:addChild(label)

			local closeImg = CCSprite:createWithSpriteFrameName("bn_soul_jian0.png")
			if closeImg ~= nil then 
				local menuSize = closeImg:getContentSize()
				local menu = CCMenu:create()
				local menuItem = CCMenuItemSprite:create(closeImg, nil, nil)
				menuItem:setTag(chips[i]:getId()*100+i)
				menuItem:registerScriptTapHandler(handler(self, CardSoulRefineChipView.remvoveChip))
				menu:addChild(menuItem)
				menu:setPosition(ccp(iconSize.width/2, iconSize.height/2-menuSize.height/2+5))
				self.cardNodes[i]:addChild(menu)
			end 

			self.needCoin = self.needCoin + chips[i]:getRefinedPrice() * chips[i]:getSelectedCount()
			if chips[i]:getRefinedGainType() == CurrencyType.Soul then 
				gainSoul = gainSoul + chips[i]:getRefinedGain()*chips[i]:getSelectedCount()
			else 
				gainCoin = gainCoin + chips[i]:getRefinedGain()*chips[i]:getSelectedCount() 
			end 
		end 
	end 

	self.label_cost:setString(string.format("%d", self.needCoin))
	self.label_gain:setString(""..gainSoul)
	self.label_gainCoin:setString(""..gainCoin)
end 


function CardSoulRefineChipView:remvoveChip(tagId)

	if tagId == nil then  
		return 
	end 
	local idx = tagId%100
	local sysId = math.floor(tagId/100)
	echo("===remvoveChip:", idx, sysId)

	local chips = CardSoul:instance():getRefinedChips()
	for k, v in pairs(chips) do 
		if v:getId() == sysId then 
			chips[k]:setSelectedCount(0)
			table.remove(chips, k)
			self.cardNodes[idx]:removeAllChildrenWithCleanup(true)
			break 
		end 
	end 

	self.needCoin = 0 
	local gainSoul = 0 
	local gainCoin = 0 
	local len = math.min(self.NumMax, #chips)
	self.bn_xilian:setEnabled(len>0)

	for i=1, len do 
		self.needCoin = self.needCoin + chips[i]:getRefinedPrice() * chips[i]:getSelectedCount()
		if chips[i]:getRefinedGainType() == CurrencyType.Soul then 
			gainSoul = gainSoul + chips[i]:getRefinedGain()*chips[i]:getSelectedCount()
		else 
			gainCoin = gainCoin + chips[i]:getRefinedGain()*chips[i]:getSelectedCount() 
		end 
	end 

	self.label_cost:setString(string.format("%d", self.needCoin))
	self.label_gain:setString(""..gainSoul)
	self.label_gainCoin:setString(""..gainCoin)
end 


function CardSoulRefineChipView:ReqJianghunResult(action,msgId,msg)
	echo("=== CardSoulRefineChipView:ReqJianghunResult", msg.result)

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

function CardSoulRefineChipView:playRefineAnim()
	self:addMaskLayer()

	self.node_anim:setVisible(true)
	for i=1, self.NumMax do 
		self.animNodes[i]:setVisible(i<=self.refinedChipsCount)
	end 

	self.mAnimationManager:runAnimationsForSequenceNamed("anim_chipRefine") 
end 

function CardSoulRefineChipView:animHideChipsCallback()
	echo("=== animHideChipsCallback") 
	for k, v in pairs(self.cardNodes) do 
		v:removeAllChildrenWithCleanup(true) 
	end 
end 

function CardSoulRefineChipView:animFinishCallback()
	echo("=== animFinishCallback")
	CardSoul:instance():setRefinedChips({})
	self.label_cost:setString("0")
	self.label_gain:setString("0")
	self.label_gainCoin:setString("0")
	self.bn_xilian:setEnabled(false)
	CardSoul:instance():resetChipRefineData()

	if self.gainItems ~= nil then 
		for i=1,table.getn(self.gainItems) do
			echo("----gained configId:", self.gainItems[i].configId)
			echo("----gained, count:", self.gainItems[i].count)
			local str = string.format("+%d", self.gainItems[i].count)
			Toast:showIconNumWithDelay(str, self.gainItems[i].iconId, self.gainItems[i].iType, self.gainItems[i].configId, ccp(display.cx,display.cy-i*40), 0.3*(i-1))
		end	
	end 

	self:removeMaskLayer()
end 

function CardSoulRefineChipView:addMaskLayer()
  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
  end 

  self.maskLayer = Mask.new({opacity=0, priority = -1000})
  self:addChild(self.maskLayer)
end 

function CardSoulRefineChipView:removeMaskLayer()
  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
    self.maskLayer = nil 
  end 
end 

function CardSoulRefineChipView:onHelpHandler()
  local help = HelpView.new()
  help:addHelpBox(1054)
  help:addHelpItem(1055, self.node_addCard2, ccp(0,0), ArrowDir.LeftDown)
  help:addHelpItem(1056, self.label_gain, ccp(30,80), ArrowDir.LeftDown)
  help:addHelpItem(1057, self.bn_patchAdd, ccp(30,20), ArrowDir.RightDown)
  help:addHelpItem(1058, self.bn_xilian, ccp(-40,20), ArrowDir.LeftDown)
  self:getDelegate():getScene():addChild(help, 1000)
end 