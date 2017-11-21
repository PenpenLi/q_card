--[[
-- 挖矿界面 --> 选择武将界面
-- -]]
require("view.play_states.PlayStatesCardListItem")
require("view.component.ViewWithEave")
require("view.component.PopupView")
require("model.Mining")

SelectCardListView = class("SelectCardListView", ViewWithEave)


SelectCardListView.cellWidth = ConfigListCellWidth
SelectCardListView.cellHeight = ConfigListCellHeight


function SelectCardListView:ctor(parent)
	SelectCardListView.super.ctor(self)
	self:setTabControlEnabled(false)
	self._parent = parent

	local pkg = ccbRegisterPkg.new(self)
	pkg:addProperty("node_fileter","CCNode")
	pkg:addProperty("label_preFilterType","CCLabelTTF")
	pkg:addProperty("label_filterType","CCLabelTTF")
	pkg:addProperty("node_listContainer","CCNode")

	pkg:addFunc("filterCallback",SelectCardListView.filterCallback)
	local layer,owner = ccbHelper.load("SelectCardListView.ccbi","CardListViewCCB","CCLayer",pkg)
	self:addChild(layer)
	self:setTitleTextureName("playstates-image-wujiang.png")
	self:getEaveView().btnHelp:setVisible(false)
	
	self.label_preFilterType:setString(_tr("filter type"))
	self.label_filterType:setString(_tr("default"))
	self._curSelectedCardId = 0

	local filterHeight = self.node_fileter:getContentSize().height
	local size = self:getCanvasContentSize()
	local bottomHeight = GameData:Instance():getCurrentScene():getBottomContentSize().height
	self.node_fileter:setPositionY(bottomHeight+size.height - filterHeight+10)

end

function SelectCardListView:filterCallback()
	echo("filter callback")

	local function filterResult(index)
		if index < 0 then
			return
		end
	    local tbl = { _tr("pop_star_%{count}", {count=1}),
	                  _tr("pop_star_%{count}", {count=2}),
	                  _tr("pop_star_%{count}", {count=3}),
	                  _tr("pop_star_%{count}", {count=4}),
	                  _tr("pop_star_%{count}", {count=5}),
	                  _tr("pop_expCard")
	                }    
	    local colorTbl = {ccc3(199,198,198), ccc3(167,232,0),ccc3(0,176,228),ccc3(222,1,255),ccc3(255,223,14),ccc3(255,239,165)}

	    self.label_filterType:setString(tbl[index])
	    self.label_filterType:setColor(colorTbl[index])

		local package = GameData:Instance():getCurrentPackage()
	    if index < 6 then  --get part of data by rare
	      self.dataArray = package:getItemsByRare(self.dataBackupArray, index)
	    elseif index == 6 then 
	      self.dataArray = Package:getExpCards(self.dataBackupArray)
	    end

		self:showListView(self.dataArray)
	end


	--pop filter
	local pop = PopupView:createFilterPopup(filterResult)
	pop.node4_expFilter:setVisible(false) -- remove expCard filter
	self:addChild(pop)
end


function SelectCardListView:initCardListView(tAllCard)
	print("initCardListView begin")

--	local selectedCardId = 0
--	if self._curCard ~= nil then
--		selectedCardId = self._curCard:getId()
--	end
--	local tAllCard = Mining:getAllCardData(selectedCardId)

	--dump(Mining,"sanmor~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	self.dataBackupArray = tAllCard
	self:showListView(tAllCard)
end

function SelectCardListView:showListView(tListData)

	local lastIdx = nil
	if tListData == nil or #tListData == 0 then
		self:setEmptyImgVisible(true)
	end

	self.dataArray = tListData
	self.cellItems = {}
	local parentType = self:getParentType()
	local totalCells = 0
	if tListData ~=nil then
		totalCells = table.getn(tListData)
	end

	local function scrollViewDidScroll(view)
	end

	local function tableCellTouched(tableview,cell)

		print("###  parentType",parentType)
		if parentType == 1 then
			local isSelected = 0
			local idx = cell:getIdx()
			local curCard = tListData[idx+1]

			--local lastUnitRootId = self._lastSelectedCard:getUnitRoot()
			local unitRootId = curCard:getUnitRoot()
			local workCards = Mining:Instance():getWorkCards()
			for k, v in pairs(workCards) do
				local cardInfo = v:getCardInfo()
				if unitRootId == cardInfo:getUnitRoot() then
					Toast:showString(GameData:Instance():getCurrentScene(), _tr("cannot_set_two_same_battle_card"), ccp(display.cx, display.height*0.4))
					return
				end
			end

			local item = self.cellItems[idx+1] --cell:getChildByTag(100)
			echo("sanmor touch idx =",idx, item)
			if item == nil then
				echo("invalid item while touch !!")
				return
			end
			tListData[idx+1].isSelected = not tListData[idx+1].isSelected
			--highlight curIndex
			item:setSelectedIconVisible(tListData[idx+1].isSelected)


			local cardId = tListData[idx+1]:getId()
			Mining:Instance():InteractChangeCardC2S(cardId,self._curSelectedCardId )
			local handle
			local function callback()
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
				handle = nil
				self:onBackHandler()
			end
			handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(callback, 0.05, false)

		elseif parentType == 2 then   -- 选择一个打工的卡牌
			local isSelected = 0
			local idx = cell:getIdx()

			if lastIdx ~= nil then
				local lastItem = self.cellItems[lastIdx+1]
				lastItem:setSelectedIconVisible(false)
			end

			if lastIdx ~= idx then
				lastIdx = idx
			end

			local item = self.cellItems[idx+1]
			if item == nil then
				echo("invalid item while touch !!")
				return
			end

			tListData[idx+1].isSelected = not tListData[idx+1].isSelected
			item:setSelectedIconVisible(true)              --tListData[idx+1].isSelected

			local cardId = tListData[idx+1]:getId()

			local function selecetedCallback(selectTimes)
				echo("index = ", selectTimes)
				local time = selectTimes
				Mining:Instance():InteractCardTryWorkC2S(cardId,"STATE_WORK",self._minersId,self._workPos,time)

				local handle
				local function callback()
					CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
					handle = nil
					self:onBackHandler()
				end
				handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(callback, 0.05, false)

				-- reduce friend miner hole num
				Friend:Instance():updateMinerIdleCountWithFriendId(self._minersId,"reduce")
			end
			local pop = PopupView:createWorkTimePopup(selecetedCallback)
			--local scene = GameData:Instance():getCurrentScene()
			self:addChild(pop,100)

		elseif parentType == 3  then --选择卡牌去 PK
			local idx = cell:getIdx()
			local card = tListData[idx+1]
			local isSelected = 0
			local item = self.cellItems[idx+1] --cell:getChildByTag(100)
			echo("sanmor touch idx =",idx, item)
			if item == nil then
				echo("invalid item while touch !!")
				return
			end

			--unhighlight last index 
			if self.preSelectedItem ~= nil and self.preSelectedItem ~= item then 
				tListData[idx+1].isSelected = false 
				self.preSelectedItem:setSelectedIconVisible(false)
			end 

			--highlight curIndex
			tListData[idx+1].isSelected = not tListData[idx+1].isSelected			
			item:setSelectedIconVisible(tListData[idx+1].isSelected)
			self.preSelectedItem = item

			local cardId = tListData[idx+1]:getId()
			local challengerCardUnitPic = tListData[idx+1]:getUnitPic()   -- challenger card
			local targetCardUnitpic =  AllConfig.unit[Mining:Instance():getPkTargetCardConfigId()].unit_pic
			print("#########CardId######",cardId,self._minersId,self._workPos)

			local function selecetedCallback(selectTimes)
				echo("index = ", selectTimes)
				local time = selectTimes

				Mining:Instance():InteractCardFightC2S(cardId,self._minersId,self._workPos,time)
				local handle
				local function callback()
					CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
					--self._loading:remove()
					_hideLoading()
					handle = nil

					local function addCcbiAnimLayer()
						self:addMaskLayer()

						local isWin = Mining:Instance():getPkisWin()
						print("~=-------iswin---------------",isWin)
						local node = display.newNode()
						node:setPosition(ccp(0 ,0 ))
						node:setCascadeOpacityEnabled(true)
						self:addChild(node)

						local pkg = ccbRegisterPkg.new(self)
						pkg:addFunc("fight_anim_end",SelectCardListView.onFightAnimEnd)
						pkg:addProperty("mAnimationManager","CCBAnimationManager")
						pkg:addProperty("character_l","CCSprite")
						pkg:addProperty("character_r","CCSprite")

						local layer,owner = ccbHelper.load("anim_MicroFight.ccbi","MicroFight","CCLayer",pkg)
						assert(layer)
						node:addChild(layer)

						local challengerAvator = _res(challengerCardUnitPic)
						self.character_l:addChild(challengerAvator)

						local oldAvator = _res(targetCardUnitpic)
						self.character_r:addChild(oldAvator)

						self._fightAnimLayer = layer
						self._fightAnimLayer:setVisible(false)

						self._fightAnimLayer:setVisible(true)
						self.mAnimationManager:runAnimationsForSequenceNamed("Fight")

					end
					addCcbiAnimLayer()
				end

				--self._loading = Loading:show()
				_showLoading()
				handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(callback, 0.3, false)
			end

			if tListData[idx+1].isSelected == true then 
				local pop = PopupView:createWorkTimePopup(selecetedCallback)
				self:addChild(pop,100)
			end 
		end
	end

	local function tableCellHighLight(table, cell)
		local idx = cell:getIdx()
		local item = self.cellItems[idx+1] --cell:getChildByTag(100)
		if item ~= nil then
			item:setSelectedHighlight(true)
		else
			echo("tableCellHighLight: invalid item !!")
		end
	end

	local function tableCellUnhighLight(table, cell)
		local idx = cell:getIdx()
		local item = self.cellItems[idx+1] --cell:getChildByTag(100)
		if item ~= nil then
			item:setSelectedHighlight(false)
		else
			echo("tableCellUnhighLight: invalid item !!")
		end
	end

	local function cellSizeForTable(tableview,idx)
		return self.cellHeight,self.cellWidth
	end

	local function tableCellAtIndex(tableview, idx)
		--echo("cellAtIndex = "..idx)
		local cell = tableview:dequeueCell()
		if nil == cell then
			cell = CCTableViewCell:new()
		else
			cell:removeChildByTag(100,true)
		end

		local card = tListData[idx+1]
		--dump(card,"@@@@@@@@@@@@@@@@@@@@@@@@@@")
		local item = PlayStatesCardListItem.new()
		item:setHeadClickEnable(false)
		item:setCard(card)
		item:setLevelPreName(_tr("level_%{lv1}/%{lv2}", {lv1=card:getLevel(), lv2=card:getMaxLevel()}), ccc3(0, 255, 16))
		item:setLevelString("")
		--item:setSelected(true)
		print("is worker",card.isWorker)
		if card.isWorker ~= nil and card.isWorker == true then
			item:setSelectedIconVisible(true)
			self._lastSelectedCard = card
		end

		item:setSelectedVisible(true)
		item:setTag(100)
		self.cellItems[idx+1] = item --back up

		cell:addChild(item)

		if self.cellNumPerPage > 0 then
			UIHelper.showScrollListView({object=item, totalCount=self.cellNumPerPage, index = idx})
		end

		return cell
	end


	local function numberOfCellsInTableView(tableview)
		return totalCells
	end

	if self.node_listContainer:getChildByTag(126) ~= nil then
		echo("remove old tableview")
		self.node_listContainer:removeChildByTag(126,true)
	end

	--set position of tab menu and list container
	local filterHeight = self.node_fileter:getContentSize().height
	local size = self:getCanvasContentSize()
	local w = size.width
	local h = size.height - filterHeight -18.0
	local bottomHeight = GameData:Instance():getCurrentScene():getBottomContentSize().height
	local pos_y = bottomHeight

	self.node_listContainer:setPosition(ccp((display.width-640)/2.0, pos_y))
	self.node_listContainer:setContentSize(CCSizeMake(w, h))

	self.node_fileter:setPositionY(bottomHeight+size.height - filterHeight+10)

	self.cellNumPerPage = math.ceil(h/self.cellHeight)
	if self.cellNumPerPage == 0 then
		UIHelper.setIsNeedScrollList(false)
	end

	if totalCells == 0 then
		self:setEmptyImgVisible(true)
	else
		self:setEmptyImgVisible(false)
	end

	local tableView = CCTableView:create(CCSizeMake(w, h))
	tableView:setDirection(kCCScrollViewDirectionVertical)
	tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	tableView:setTag(126)
	self.node_listContainer:addChild(tableView)

	tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
	tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
	tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
	tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
	tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
	tableView:registerScriptHandler(tableCellHighLight,CCTableView.kTableCellHighLight)
	tableView:registerScriptHandler(tableCellUnhighLight,CCTableView.kTableCellUnhighLight)
	tableView:reloadData()

end

function SelectCardListView:onFightAnimEnd()

	local isWin = Mining:Instance():getPkisWin()
	local str = ""
	if isWin == true then
		str = _tr("challenge_success")
	else
		str = _tr("challenge_fail")
	end

	local function backMingView()
		self:onBackHandler()
		self:removeMaskLayer()
	end

	local pop = PopupView:createTextPopup(str, backMingView, true)
	--GameData:Instance():getCurrentScene():addChild(pop,500)
    self:addChild(pop,500)
end

function SelectCardListView:setCurSelectCardId(cardId)
	self._curSelectedCardId = cardId
end

function SelectCardListView:setParentType(type)
	self._parentType = type
end

function SelectCardListView:getParentType()
	return self._parentType
end

function SelectCardListView:exit()
	print("SelectCardListView:exit")
end

function SelectCardListView:onBackHandler()
	print(" SelectCardListView:onBackHandler()")
	self:removeFromParentAndCleanup(true)
	if  self:getParentType() == 1 then   --1:from workerList entry
		print("----------------############------")
		local miningController = ControllerFactory:Instance():create(ControllerType.MINING_CONTROLLER)
		miningController:enter(nil,nil,false,false)
	elseif self:getParentType() == 2 or self:getParentType() == 3 then --2:from friend 3.PK entry
		local mining = Mining:Instance()
		local miningController = ControllerFactory:Instance():create(ControllerType.MINING_CONTROLLER)
		miningController:enter(mining:getUserName(),mining:getUserId())

	end
end

function SelectCardListView:onHelpHandler()
	print("SelectCardListView:onHelpHandler()")
end

function SelectCardListView:setOnClickListCallback(callBackFun)
	self._callBackFun = callBackFun
end

function SelectCardListView:initWorkInfo(pos,minersId)
	print("SelectCardListView.lua<SelectCardListView:return  initWorkInfo:")
	--self._workTimes = workTimes
	self._workPos = pos
	self._minersId = minersId
end

function SelectCardListView:addMaskLayer()
  echo("=== addMaskLayer")
  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
  end 

  self.maskLayer = Mask.new({opacity=0, priority = -1000})
  self:addChild(self.maskLayer)

  self:performWithDelay(handler(self, SelectCardListView.removeMaskLayer), 6.0)
end 

function SelectCardListView:removeMaskLayer()
  echo("=== removeMaskLayer")
  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
    self.maskLayer = nil 
  end 
end 

return SelectCardListView