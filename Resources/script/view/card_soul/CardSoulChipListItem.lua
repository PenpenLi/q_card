
require("view.BaseView")


CardSoulChipListItem = class("CardSoulChipListItem", BaseView)


function CardSoulChipListItem:ctor()
	CardSoulChipListItem.super.ctor(self)

	--1. load levelup view ccbi
	local pkg = ccbRegisterPkg.new(self)
	pkg:addFunc("iconTouchCallback1",CardSoulChipListItem.iconTouchCallback1)
	pkg:addFunc("iconTouchCallback2",CardSoulChipListItem.iconTouchCallback2)
	pkg:addFunc("iconTouchCallback3",CardSoulChipListItem.iconTouchCallback3)
	pkg:addFunc("iconTouchCallback4",CardSoulChipListItem.iconTouchCallback4)
	pkg:addFunc("iconTouchCallback5",CardSoulChipListItem.iconTouchCallback5)

	pkg:addProperty("node_chip1","CCNode")
	pkg:addProperty("node_chip2","CCNode")
	pkg:addProperty("node_chip3","CCNode")
	pkg:addProperty("node_chip4","CCNode")
	pkg:addProperty("node_chip5","CCNode")
	pkg:addProperty("node_head1","CCNode")
	pkg:addProperty("node_head2","CCNode")
	pkg:addProperty("node_head3","CCNode")
	pkg:addProperty("node_head4","CCNode")
	pkg:addProperty("node_head5","CCNode")

	pkg:addProperty("label_leftNum1","CCLabelTTF")
	pkg:addProperty("label_leftNum2","CCLabelTTF")
	pkg:addProperty("label_leftNum3","CCLabelTTF")
	pkg:addProperty("label_leftNum4","CCLabelTTF")
	pkg:addProperty("label_leftNum5","CCLabelTTF")
	pkg:addProperty("label_selectedCount1","CCLabelBMFont")
	pkg:addProperty("label_selectedCount2","CCLabelBMFont")
	pkg:addProperty("label_selectedCount3","CCLabelBMFont")
	pkg:addProperty("label_selectedCount4","CCLabelBMFont")
	pkg:addProperty("label_selectedCount5","CCLabelBMFont")

	pkg:addProperty("sprite_selecte1","CCSprite")
	pkg:addProperty("sprite_selecte2","CCSprite")
	pkg:addProperty("sprite_selecte3","CCSprite")
	pkg:addProperty("sprite_selecte4","CCSprite")
	pkg:addProperty("sprite_selecte5","CCSprite")

	local layer,owner = ccbHelper.load("CardSoulChipListItem.ccbi","CardSoulChipListItemCCB","CCLayer",pkg)
	self:addChild(layer)
end


function CardSoulChipListItem:onEnter()
	if self.chipsArray == nil then 
		return 
	end 	

	self.chipNodes = {self.node_chip1, self.node_chip2, self.node_chip3, self.node_chip4, self.node_chip5}
	self.chipHeads = {self.node_head1, self.node_head2, self.node_head3, self.node_head4, self.node_head5}
	self.selectedIcons = {self.sprite_selecte1, self.sprite_selecte2, self.sprite_selecte3, self.sprite_selecte4, self.sprite_selecte5}
	self.leftCountArray = {self.label_leftNum1, self.label_leftNum2, self.label_leftNum3, self.label_leftNum4, self.label_leftNum5}
	self.selectedLabel = {self.label_selectedCount1, self.label_selectedCount2, self.label_selectedCount3, self.label_selectedCount4, self.label_selectedCount5}
	self.chipNameArray = {}

	local len = math.min(5, #self.chipsArray)
	for i=1, 5 do 
		if i <= len then 
			local chipImg = GameData:Instance():getCurrentPackage():getItemSprite(nil, 6, self.chipsArray[i]:getConfigId(), 1)
			if chipImg ~= nil then 
				self.chipHeads[i]:addChild(chipImg)

				--set name 
				local outline = ui.newTTFLabelWithOutline({ text = self.chipsArray[i]:getName(),
																										font = "Courier-Bold",
																										size = 22,
																										x = 0,
																										y = 0,
																										color = ccc3(255, 255, 255),
																										align = ui.TEXT_ALIGN_LEFT,
																										outlineColor =ccc3(0,0,0),
																										pixel = 2
																									}
																								)
				local x = - outline:getContentSize().width/2
				local y = - chipImg:getContentSize().height/2 - outline:getContentSize().height/2 - 5 
				outline:setPosition(ccp(x, y))
				self.chipNameArray[i] = outline
				self.chipHeads[i]:addChild(outline)

				--set left count
				local selectedCount = self.chipsArray[i]:getSelectedCount()
				self.leftCountArray[i]:setString(string.format("%d", self.chipsArray[i]:getCount()-selectedCount))
				self.selectedIcons[i]:setVisible(selectedCount > 0)
				if selectedCount > 0 then 
					self.selectedLabel[i]:setString(string.format("%d", selectedCount))
				end 
			end 
		else 
			self.chipNodes[i]:setVisible(false) 
		end 
	end 
end 

function CardSoulChipListItem:onExit()
end

function CardSoulChipListItem:iconTouchCallback1()
	self:handleSelecte(1)
end 

function CardSoulChipListItem:iconTouchCallback2()
	self:handleSelecte(2)
end 

function CardSoulChipListItem:iconTouchCallback3()
	self:handleSelecte(3)
end 

function CardSoulChipListItem:iconTouchCallback4()
	self:handleSelecte(4)
end 

function CardSoulChipListItem:iconTouchCallback5()
	self:handleSelecte(5)
end 

function CardSoulChipListItem:setButtonEnableDelegate(delegate)
	self._isBnEanbleDelegate = delegate
end 

function CardSoulChipListItem:setChips(chipArray)
	self.chipsArray = chipArray 
end 

function CardSoulChipListItem:updateCountInfo(menuIdx)
	if self:getDelegate() ~= nil then 
		self:getDelegate():updateSelectedInfo()
	end 

	local selectedCount = self.chipsArray[menuIdx]:getSelectedCount()
	self.selectedLabel[menuIdx]:setVisible(selectedCount>0)
	self.selectedIcons[menuIdx]:setVisible(selectedCount>0)
	self.selectedLabel[menuIdx]:setString(string.format("%d", selectedCount))
	self.leftCountArray[menuIdx]:setString(string.format("%d", self.chipsArray[menuIdx]:getCount()-selectedCount))
end 

function CardSoulChipListItem:handleSelecte(menuIdx)
	local function inputCallback(n)
		echo("inputCallback: n=", n)
		self.chipsArray[menuIdx]:setSelectedCount(n)
		self:updateCountInfo(menuIdx)
	end 

	if self:getDelegate():getIsTouchEvent() == false then 
		return 
	end 
	self:getDelegate():setIsTouchEvent(false)

	--unselecte 
	local selectedCount = self.chipsArray[menuIdx]:getSelectedCount()
	if selectedCount > 0 then 
		self.chipsArray[menuIdx]:setSelectedCount(0)
		self:updateCountInfo(menuIdx)
		return 
	end 

	--do nothing when selete types exceed 
	if self:getDelegate():getLeftTypesForSelecte() <= 0 then 
		Toast:showString(self, string._tran(Consts.Strings.SOUL_CHIPS_NUM_EXCEED), ccp(display.width/2, display.height*0.4))
		return 
	end 

	local maxCount = self.chipsArray[menuIdx]:getCount() 
	if maxCount == 1 then 
		self.chipsArray[menuIdx]:setSelectedCount(maxCount-selectedCount) 
		self:updateCountInfo(menuIdx) 
	else 
		local name = self.chipsArray[menuIdx]:getName()
		local pop = PopupView:createInputPopup(PopupType.INPUT_NUMBER_USE, name, 0, maxCount, inputCallback) 
		pop:setInputMinVal(0) 
		self:getDelegate():addChild(pop) 
		pop:setScale(0.2) 
		pop:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6)) 
	end 
end 
