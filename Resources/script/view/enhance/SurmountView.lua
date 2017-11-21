
require("view.component.ViewWithEave")
require("view.component.Loading")
require("view.component.TipsInfo")
require("view.component.ItemSourceView")
require("common.Consts")

SurmountView = class("SurmountView", ViewWithEave)

function SurmountView:ctor()
	SurmountView.super.ctor(self)
	--self:setTabControlEnabled(false)

	--1. load levelup view ccbi
	local pkg = ccbRegisterPkg.new(self)
	pkg:addFunc("selectHeroCallback",SurmountView.selectHeroCallback)
	-- pkg:addFunc("startSurmountCallback",SurmountView.startSurmountCallback) --手动绑定, 按下即响应
	pkg:addFunc("bn_cailiao1",SurmountView.touchCailiao1)
	pkg:addFunc("bn_cailiao2",SurmountView.touchCailiao2)
	pkg:addFunc("bn_cailiao3",SurmountView.touchCailiao3)
	pkg:addFunc("bn_cailiao4",SurmountView.touchCailiao4)
	pkg:addFunc("sourceCallback",SurmountView.sourceCallback)
	pkg:addFunc("combineCallback",SurmountView.combineCallback)

	pkg:addProperty("bn_startSurmount","CCControlButton")
	pkg:addProperty("bn_selectHero","CCMenuItemSprite")
	pkg:addProperty("sprite_selectHero","CCSprite")

	pkg:addProperty("node_surcardinfo","CCNode")
	pkg:addProperty("node_largeheader","CCNode")
	pkg:addProperty("label_money","CCLabelTTF")
	pkg:addProperty("label_readme","CCLabelTTF")
	pkg:addProperty("sprite_cailiao1","CCSprite")
	pkg:addProperty("sprite_cailiao2","CCSprite")
	pkg:addProperty("sprite_cailiao3","CCSprite")
	pkg:addProperty("sprite_cailiao4","CCSprite")
	pkg:addProperty("sprite_wenhao1","CCSprite")
	pkg:addProperty("sprite_wenhao2","CCSprite")
	pkg:addProperty("sprite_wenhao3","CCSprite")
	pkg:addProperty("sprite_wenhao4","CCSprite")

	pkg:addProperty("label_cailiao1","CCLabelTTF")
	pkg:addProperty("label_cailiao2","CCLabelTTF")
	pkg:addProperty("label_cailiao3","CCLabelTTF")
	pkg:addProperty("label_cailiao4","CCLabelTTF")

	pkg:addProperty("node_readMe","CCNode")
	--card node info1
	pkg:addProperty("node_cardinfo","CCNode")
	pkg:addProperty("info1_level","CCLabelTTF")
	pkg:addProperty("label_cost","CCLabelTTF")

	pkg:addProperty("info_curming","CCLabelTTF")
	pkg:addProperty("info_curgong","CCLabelTTF")
	pkg:addProperty("info_curwu","CCLabelTTF")
	pkg:addProperty("info_curzhi","CCLabelTTF")
	pkg:addProperty("info_curtong","CCLabelTTF")

	--card node info2 
	pkg:addProperty("node_cardinfo2","CCNode")
	pkg:addProperty("info2_curLevel","CCLabelTTF")
	pkg:addProperty("info2_nextLevel","CCLabelTTF")
	pkg:addProperty("info2_curwu","CCLabelTTF")
	pkg:addProperty("info2_nextwu","CCLabelTTF")
	pkg:addProperty("info2_curzhi","CCLabelTTF")
	pkg:addProperty("info2_nextzhi","CCLabelTTF")
	pkg:addProperty("info2_curtong","CCLabelTTF")
	pkg:addProperty("info2_nexttong","CCLabelTTF")
	pkg:addProperty("info2_curming","CCLabelTTF")
	pkg:addProperty("info2_nextming","CCLabelTTF")
	pkg:addProperty("info2_curgong","CCLabelTTF")
	pkg:addProperty("info2_nextgong","CCLabelTTF")  

	local layer,owner = ccbHelper.load("SurmountView.ccbi","SurmountViewCCB","CCLayer",pkg)
	self:getEaveView():getNodeContainer():addChild(layer)
	
	self.bn_startSurmount:addHandleOfControlEvent(handler(self,SurmountView.startSurmountCallback),CCControlEventTouchDown)

	_registNewBirdComponent(103001,self.bn_startSurmount)
	_executeNewBird()
end


function SurmountView:onEnter()
	echo("---SurmountView:onEnter---")
	net.registMsgCallback(PbMsgId.CardTurnbackResult, self, SurmountView.CardTurnbackResult)

	if self:getDelegate():getTabMenuVisible() == false then 
		self:setTitleTextureName("lv_title_zhuansheng.png")
		self:setTabControlEnabled(false)
		self.node_surcardinfo:setPositionY(self.node_surcardinfo:getPositionY()+30)
	else 
		self:setTitleTextureName("cardlvup-image-paibian.png")
		local menuArray = {
				{"#bn_levelup_0.png","#bn_levelup_1.png"},
				{"#bn_surmount_0.png","#bn_surmount_1.png"},
				{"#bn_dismantle_0.png","#bn_dismantle_1.png"},
				{"#bn_skillUp0.png","#bn_skillUp1.png"}
			}
		self:setMenuArray(menuArray)
		self:getTabMenu():setItemSelectedByIndex(2)
	end 
	self.label_readme:setString(_tr("surmountInfo"))
	self.label_cost:setString(_tr("cost"))

	self.coinCost = 0
	self:setIsSurmounting(false)

	local nodeSize = self.node_largeheader:getContentSize()
	local card = self:getDelegate():dataInstance():getSurmountedCard()
	if card ~= nil then
		self.childLargeCard = CardHeadLargeView.new(card)
		local scale = nodeSize.height/self.childLargeCard:getHeight()
		self.childLargeCard:setScale(scale)
		self.childLargeCard:setTag(400)
		self.childLargeCard:setPosition(ccp(nodeSize.width/2, nodeSize.height/2))
		self.node_largeheader:addChild(self.childLargeCard)
		if card:getGrade() == card:getMaxGrade() then 
			self:showCardInfo(2, card)
		else 
			self:showCardInfo(1, card)
		end 
	else
		self:showCardInfo(0, nil)

		local heroBg = _res(3021010) --默认英雄背景
		if heroBg ~= nil then       
			local scale = nodeSize.height/heroBg:getContentSize().height
			heroBg:setScale(scale)
			heroBg:setPosition(ccp(nodeSize.width/2, nodeSize.height/2))
			self.node_largeheader:addChild(heroBg, -2)

			local bg2 = _res(3021020) --底部渐变
			if bg2 ~= nil then 
				local scale2 = (nodeSize.width-18)/bg2:getContentSize().width 
				bg2:setScale(scale2)
				bg2:setAnchorPoint(ccp(0, 0))
				bg2:setPosition(ccp(9,13))
				self.node_largeheader:addChild(bg2, -1)
			end
		end 

		local action = CCSequence:createWithTwoActions(CCFadeTo:create(1.0, 100),CCFadeTo:create(1.0, 255))
		self.sprite_selectHero:runAction(CCRepeatForever:create(action))
	end
end 

function SurmountView:onExit()
	echo("---SurmountView:onExit---")
	net.unregistAllCallback(self)

	if self.scheduler ~= nil then 
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduler)
		self.scheduler = nil
	end  
end 

function SurmountView:playSurmountAnim()
	--setp 3. play star anim
	local function playStarAnim()
		--local largeCardHeader = self.node_largeheader:getChildByTag(400)
		if self.childLargeCard ~= nil then 
			local card = self.childLargeCard:getCard()      
			local animObj
			if self.preGrade < card:getGrade() then 
				animObj = self.childLargeCard:getStarObj(card:getGrade())
			else 
				self.childLargeCard:setSubRank(card:getConfigId())
				animObj = self.childLargeCard:getSubRankLabel()
			end 

			if animObj ~= nil then 
				local function actEnd()
					echo("===========act end")
					self.childLargeCard:setCard(card:getConfigId())
					self:removeMaskLayer()
          _executeNewBird()
					GameData:Instance():getCurrentPlayer():toastBattleAbility(self.preBattleAbility)
				end 
				local array = CCArray:create()
				array:addObject(CCScaleTo:create(0.5, 3.0))
				array:addObject(CCScaleTo:create(0.5, 1.0))
				array:addObject(CCCallFunc:create(actEnd))

				animObj:setVisible(true)
				animObj:runAction(CCSequence:create(array))
			end 
			
			if card:getGrade() == card:getMaxGrade() then 
				self:showCardInfo(2, card)
			else
				self:showCardInfo(1, card)
			end
			self:setIsSurmounting(false)
		end
	end

	--setp 2. play round anim
	local function playRuondAnim()
		local anim,offsetX,offsetY,duration = _res(5020099)
		if anim ~= nil then
			local nodeSize = self.node_largeheader:getContentSize()
			anim:setPosition(ccp(nodeSize.width/2, nodeSize.height/2))
			self.node_largeheader:addChild(anim)
			anim:getAnimation():play("default")

			self:performWithDelay(function ()
															anim:removeFromParentAndCleanup(true)
															playStarAnim()
														end, duration*0.9)
		else 
			self:removeMaskLayer()
		end
	end


	--setp 1. play eat anim
	if self.totalMeterialNum ~= nil then 
		local duration_time = 0
		local spriteArray = {self.sprite_cailiao1, self.sprite_cailiao2, self.sprite_cailiao3, self.sprite_cailiao4}
		for i=1, self.totalMeterialNum do 
			local anim,offsetX,offsetY,duration = _res(5020100)
			if anim ~= nil then
				self:addChild(anim)
				duration_time = duration
				local pos_x,pos_y = spriteArray[i]:getPosition()
				local pos = spriteArray[i]:getParent():convertToWorldSpace(ccp(pos_x,pos_y))
				anim:setPosition(pos)
				anim:getAnimation():play("default")

				self:performWithDelay(function ()
																anim:removeFromParentAndCleanup(true)
																echo("remove animation")
																self:resetMaterialInfo()
																playRuondAnim()
															end, duration)
			end
		end

		if duration_time > 0 then 
			self:addMaskLayer()
		end 
	end
end


function SurmountView:onHelpHandler()
	echo("helpCallback")
	local help = HelpView.new()
	help:addHelpBox(1008)
	help:addHelpItem(1009, self.node_largeheader, ccp(100,80), ArrowDir.LeftLeftUp)
	help:addHelpItem(1010, self.bn_startSurmount, ccp(10,20), ArrowDir.RightDown)
	self:getDelegate():getScene():addChild(help, 1000)
end

function SurmountView:onBackHandler()
	echo("SurmountView:backCallback")
	SurmountView.super:onBackHandler()
	self:getDelegate():goBackView()
end

function SurmountView:tabControlOnClick(idx)
	_playSnd(SFX_CLICK)

	local result = true

	if idx == 0 then
		result = self:getDelegate():displayLevelUpView()
	elseif idx == 1 then 
	elseif idx == 2 then
		self:getDelegate():displayDismantleView()
	elseif idx == 3 then
		result = self:getDelegate():displaySkillView()
	end

	return result
end

function SurmountView:selectHeroCallback()
	echo("selectHeroCallback")

	if self:getIsSurmounting() == true then
		return
	end

	if self:getDelegate():getTabMenuVisible() == false then 
		if self:getDelegate():dataInstance():getSurmountedCard() ~= nil then 
			echo("disable selecte other card for playstate")
			return 
		end
	end 

	self:getDelegate():disPlayCardListForSurmount()
end

function SurmountView:CardTurnbackResult(action,msgId,msg)
	echo("CardTurnbackResult:", msg.state)

--	if self.loading ~= nil then 
--		self.loading:remove()
--		self.loading = nil
--	end 
  _hideLoading()

	if msg.state ~= "Ok" then 
		self:setIsSurmounting(false)
	end

	if msg.state == "Ok" then 
		local card = self:getDelegate():dataInstance():getSurmountedCard()
		self.preGrade = card:getGrade()
		echo("================ pre grade:", card:getGrade(), card:getImproveGrade(), card:getConfigId())
		GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
		echo("================ after grade:", card:getGrade(), card:getImproveGrade(), card:getConfigId())

		self:playSurmountAnim()

	elseif msg.state == "NeedMoreItem" then
		Toast:showString(self, _tr("not enough material"), ccp(display.width/2, display.height*0.4))
	elseif msg.state == "NoSuchCard" then
		Toast:showString(self, _tr("no such card"), ccp(display.width/2, display.height*0.4))
	elseif msg.state == "NotEnoughCurrency" then
		Toast:showString(self, _tr("not enough coin"), ccp(display.width/2, display.height*0.4))
	elseif msg.state == "NeedCardLevel" then
		Toast:showString(self, _tr("poor level"), ccp(display.width/2, display.height*0.4))  
	elseif msg.state == "NeedMoreCard" then
		Toast:showString(self, _tr("has no eatable cards"), ccp(display.width/2, display.height*0.4))  
	elseif msg.state == "NoSuchConsumedCard" then
		Toast:showString(self, _tr("no_such_consumed_card"), ccp(display.width/2, display.height*0.4))    
	elseif msg.state == "ConsumedCardIsActive" then
		Toast:showString(self, _tr("consumed_card_is_active"), ccp(display.width/2, display.height*0.4))        
	elseif msg.state == "ConsumedCardInMine" then
		Toast:showString(self, _tr("working card can not eaten"), ccp(display.width/2, display.height*0.4))  
	elseif msg.state == "ConsumedCardIdWrong" then
		Toast:showString(self, _tr("wrong_consumed_card"), ccp(display.width/2, display.height*0.4))     
	else
		Toast:showString(self, msg.state, ccp(display.width/2, display.height*0.4))
	end
end 

function SurmountView:startSurmountCallback()
	_playSnd(SFX_CLICK)
	
	if self:getIsSurmounting() == true then
		return
	end

	local card = self:getDelegate():dataInstance():getSurmountedCard()
	
	if card == nil then 
		Toast:showString(self, _tr("please select card"), ccp(display.width/2, display.height*0.4))
		return
	end

	if card:getGrade() == card:getMaxGrade() then
		Toast:showString(self, _tr("card_has_max_grade"), ccp(display.width/2, display.height*0.4))
		return
	end

	echo("---card config id =", card:getConfigId())

	if self:getIsMeterialEnough() == false then 
		Toast:showString(self, _tr("not enough material"), ccp(display.width/2, display.height*0.4))
		return
	end

	-- if card:getLevel() ~= card:getMaxLevel() then 
	-- 	 Toast:showString(self, _tr("poor level"), ccp(display.width/2, display.height*0.4))
	-- 	return
	-- end

	if self:getIsCoinEnough() == false then 
		Toast:showString(self, _tr("not enough coin"), ccp(display.width/2, display.height*0.4))
		return
	end

	local function reqToSurmount()
		echo(" reqToSurmount...")
		for i=1, table.getn(self.consumeCardsArray) do 
			echo(" consume id=", self.consumeCardsArray[i])
		end
    
    _showLoading()
		local data = PbRegist.pack(PbMsgId.CardTurnback, {config_id=card:getConfigId(), card_id=card:getId(), consume_id=self.consumeCardsArray})
		net.sendMessage(PbMsgId.CardTurnback, data)

		--show waiting
		--self.loading = Loading:show()
		self:setIsSurmounting(true)
		
		 --backup battle ability for toast
		local battleCards = GameData:Instance():getCurrentPackage():getBattleCards()
		self.preBattleAbility = GameData:Instance():getBattleAbilityForCards(battleCards)   
	end

	--check leadship for battle card
	if card:getIsOnBattle() == true then 
		local leadship = GameData:Instance():getCurrentPlayer():getLeadShip()
		local leadCost = 0
		local cartable = GameData:Instance():getCurrentPackage():getBattleCards()

		for k,v in pairs(cartable) do 
			leadCost = leadCost + v:getLeadCost()
		end 

		local targetId = AllConfig.combinesummary[card:getConfigId()].target_item
		leadCost = leadCost + AllConfig.unit[targetId].lead_cost - AllConfig.unit[card:getConfigId()].lead_cost
		if leadCost > leadship then
			local pop = PopupView:createTextPopup(_tr("leadship_exceed_after_surmounted2"), nil, true)
			self:addChild(pop)
		else 
			reqToSurmount()
		end
	else 
		reqToSurmount()
	end
end

function SurmountView:showCardInfo(index, card)
		echo("showCardInfo: index="..index)

		self:setEssentialMaterialInfo(card)
	if index == 0 then --read me 
		self.node_readMe:setVisible(true)
		self.node_cardinfo:setVisible(false)
		self.node_cardinfo2:setVisible(false)
	elseif index == 1 then 
		self.node_readMe:setVisible(false)
		self.node_cardinfo:setVisible(false)
		self.node_cardinfo2:setVisible(true)

		if card ~= nil then
			local targetId = AllConfig.combinesummary[card:getConfigId()].target_item
			local nexGradCardUnit = AllConfig.unit[targetId]
			if nexGradCardUnit == nil then 
				echo("invalid target card !!!!")
				return
			end

			local curLevel = card:getLevel()
			local maxLevel = card:getMaxLevel()
			local maxLevel2 = nexGradCardUnit.max_level

			self.info2_curLevel:setString(string.format("%d/%d", curLevel, maxLevel))
			self.info2_nextLevel:setString(string.format("%d/%d", curLevel,maxLevel2))

			local curWu = card:getStrengthByLevel(curLevel)
			local curZhi = card:getIntelligenceByLevel(curLevel)
			local curTong = card:getDominanceByLevel(curLevel)
			local curHp = card:getHpByLevel(curLevel)
			local curGong = card:getAttackByLevel(curLevel)

			local tmpCard = Card.new()
			local weapon = card:getWeapon() 
			local armor = card:getArmor() 
			local accessory = card:getAccessory() 

			tmpCard:setConfigId(targetId)
			tmpCard:setLevel(curLevel)
			tmpCard:setWeapon(weapon)
			tmpCard:setArmor(armor)
			tmpCard:setAccessory(accessory)

			local nextWu = tmpCard:getStrengthByLevel(curLevel)
			local nextZhi = tmpCard:getIntelligenceByLevel(curLevel)
			local nextTong = tmpCard:getDominanceByLevel(curLevel)
			local nextHp = tmpCard:getHpByLevel(curLevel)
			local nextGong = tmpCard:getAttackByLevel(curLevel)

			--restore origin card' equip info 
			card:setWeapon(weapon)
			card:setArmor(armor)
			card:setAccessory(accessory)
			
			self.info2_curwu:setString(string.format("%d", curWu))
			self.info2_nextwu:setString(string.format("%d", nextWu))

			self.info2_curzhi:setString(string.format("%d", curZhi))
			self.info2_nextzhi:setString(string.format("%d", nextZhi))

			self.info2_curtong:setString(string.format("%d", curTong))
			self.info2_nexttong:setString(string.format("%d", nextTong))

			self.info2_curming:setString(string.format("%d", curHp))
			self.info2_nextming:setString(string.format("%d", nextHp))

			self.info2_curgong:setString(string.format("%d", curGong))
			self.info2_nextgong:setString(string.format("%d", nextGong))
		end
	elseif index == 2 then 
		self.node_readMe:setVisible(false)
		self.node_cardinfo:setVisible(true)
		self.node_cardinfo2:setVisible(false)

		if card == nil then 
			self.info1_level:setString("")
			self.info_curming:setString("")
			self.info_curgong:setString("")
			self.info_curwu:setString("")
			self.info_curzhi:setString("")
			self.info_curtong:setString("")
		else
			local curLevel = card:getLevel()
			local maxLevel = card:getMaxLevel()
			self.info1_level:setString(string.format("%d/%d", curLevel, maxLevel))
			self.info_curming:setString(string.format("%d", card:getHpByLevel(curLevel)))
			self.info_curgong:setString(string.format("%d", card:getAttackByLevel(curLevel)))
			self.info_curwu:setString(string.format("%d", card:getStrengthByLevel(curLevel)))
			self.info_curzhi:setString(string.format("%d", card:getIntelligenceByLevel(curLevel)))
			self.info_curtong:setString(string.format("%d", card:getDominanceByLevel(curLevel)))
		end
	end
end

function SurmountView:resetMaterialInfo()
	self.sprite_wenhao1:setVisible(true)
	self.sprite_wenhao2:setVisible(true)
	self.sprite_wenhao3:setVisible(true)
	self.sprite_wenhao4:setVisible(true)
	self.sprite_cailiao1:removeAllChildrenWithCleanup(true)
	self.sprite_cailiao2:removeAllChildrenWithCleanup(true)
	self.sprite_cailiao3:removeAllChildrenWithCleanup(true)
	self.sprite_cailiao4:removeAllChildrenWithCleanup(true)
	self.label_cailiao1:setString("")
	self.label_cailiao2:setString("")
	self.label_cailiao3:setString("")
	self.label_cailiao4:setString("")
	self.label_money:setString("")
end 

function SurmountView:setEssentialMaterialInfo(card)
	if card == nil then 
		return 
	end

	self:setMeterialEnough(false)

	local combineSummary = AllConfig.combinesummary[card:getConfigId()]
	if combineSummary == nil then 
		echo("invalid combineSummary !!", card:getConfigId())
		return
	end 

	--clear
	self:resetMaterialInfo()

	if card ~= nil then 
		if card:getGrade() == card:getMaxGrade() then 
			echo(" has reach the max grade.")
			return
		end
	end

	self.totalMeterialNum = 0
	self.consumeCardsArray = {}
	self.needMaterialArray = {}
	
	local hasEnoughMat = true 
	local iconSize = self.sprite_cailiao1:getContentSize()
	local pos = ccp(iconSize.width/2, iconSize.height/2)

	local materialNode = {self.sprite_cailiao1, self.sprite_cailiao2, self.sprite_cailiao3, self.sprite_cailiao4}
	local materialLabel = {self.label_cailiao1, self.label_cailiao2, self.label_cailiao3, self.label_cailiao4}
	local wenhaoArray = {self.sprite_wenhao1, self.sprite_wenhao2, self.sprite_wenhao3, self.sprite_wenhao4}

	for k, v in pairs(combineSummary.consume) do 
		local dataItem = v.array
		if dataItem[1] == 4 then 
			self.coinCost = dataItem[3]
		else 
			table.insert(self.needMaterialArray, {iType = dataItem[1], configId = dataItem[2], count = dataItem[3]})
		end 
	end 

	self.totalMeterialNum = #self.needMaterialArray
	self.label_money:setString(""..self.coinCost)
	local color = self:getIsCoinEnough() and ccc3(69, 20, 1) or ccc3(201,1,1)
	self.label_money:setColor(color)
	
	--show materials info
	for k, v in pairs(self.needMaterialArray) do 
		local iconId, metNum, id, iconBgId = self:getDelegate():dataInstance():getIconNumByType(v.iType, v.configId, card:getId())
		if iconId ~= nil then
			local sprite = _res(iconId)
			if sprite ~= nil then 
				wenhaoArray[k]:setVisible(false)
				local w = sprite:getContentSize().width
				if w > iconSize.width then 
					sprite:setScale(iconSize.width/w)
				end

				sprite:setPosition(pos)
				materialNode[k]:addChild(sprite,1)

				if v.iType == 6 then --props 
					local item = AllConfig.item[v.configId]
					local frameBg = _res(3021041+item.rare-1)
					if frameBg ~= nil then 
						frameBg:setPosition(pos)
						frameBg:setScale((iconSize.width+2)/frameBg:getContentSize().width)
						materialNode[k]:addChild(frameBg,2)
					end 
					if item.item_type == 3 or item.item_type == 4 then 
						local chip = CCSprite:create("img/common/suipian.png")
						chip:setAnchorPoint(ccp(0,1))
						chip:setPosition(ccp(pos.x-iconSize.width/2+7, pos.y+iconSize.height/2-7))
						materialNode[k]:addChild(chip, 2)
					end

				elseif v.iType == 8 then --card
					local cardHead = CardHeadView.new()
					cardHead:setCardByConfigId(v.configId)
					cardHead:setLvVisible(false)
					cardHead:setPosition(pos)
					materialNode[k]:addChild(cardHead,2)

					if id ~= nil then 
						table.insert(self.consumeCardsArray, id)
					end  
				end 

				materialLabel[k]:setString(string.format("%d/%d", metNum, v.count)) 

				if metNum >= v.count then 
					materialLabel[k]:setColor(ccc3(32,143,0))
				else 
					materialLabel[k]:setColor(ccc3(201,1,1))
					hasEnoughMat = false 
				end
			end
		end
	end 

	echo("=== hasEnoughMat:", hasEnoughMat)
	self:setMeterialEnough(hasEnoughMat)
end 

function SurmountView:setMeterialEnough(isEnough)
	self._meterialEnough = isEnough
end

function SurmountView:getIsMeterialEnough()
	return self._meterialEnough
end

function SurmountView:getIsCoinEnough()
	return GameData:Instance():getCurrentPlayer():getCoin() >= self.coinCost
end

function SurmountView:setIsSurmounting(isSurmounting)

	self.isSurmounting = isSurmounting
	echo("setIsSurmounting:", isSurmounting)

	local scheduler = CCDirector:sharedDirector():getScheduler()
	if self.scheduler ~= nil then 
		scheduler:unscheduleScriptEntry(self.scheduler)
		self.scheduler = nil
	end

	local function timerCallback(dt)
		echo("timer expire....")
		if self.scheduler ~= nil then 
			scheduler:unscheduleScriptEntry(self.scheduler)
			self.scheduler = nil
			self.isSurmounting = false
		end
	end

	--strat timer
	if self.isSurmounting == true then
		self.scheduler = scheduler:scheduleScriptFunc(timerCallback, 60, false)
	end
end

function SurmountView:getIsSurmounting()
	echo("...getIsSurmounting =",self.isSurmounting)
	return self.isSurmounting
end

function SurmountView:touchCailiao1()
	self:handleTouchIcon(1)
end

function SurmountView:touchCailiao2()
	self:handleTouchIcon(2)
end 

function SurmountView:touchCailiao3()
	self:handleTouchIcon(3)
end 

function SurmountView:touchCailiao4()
	self:handleTouchIcon(4)
end 

function SurmountView:handleTouchIcon(index)
	local card = self:getDelegate():dataInstance():getSurmountedCard()
	if card == nil then
		return
	end

	if index <= #self.needMaterialArray then 
		local view = ItemSourceView.new(self.needMaterialArray[index].configId)
		self:addChild(view)
	end 
end 

function SurmountView:addMaskLayer()
	if self.maskLayer ~= nil then 
		self.maskLayer:removeFromParentAndCleanup(true)
	end 

	self.maskLayer = Mask.new({opacity=0, priority = -1000})
	self:addChild(self.maskLayer)
end 

function SurmountView:removeMaskLayer()
	if self.maskLayer ~= nil then 
		self.maskLayer:removeFromParentAndCleanup(true)
		self.maskLayer = nil 
	end 
end 
