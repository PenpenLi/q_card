require("view.component.Toast")
require("view.mining.component.MineHoleView")
require("model.Mining")
require("view.component.OrbitCard")

MiningFieldView = class("MiningFieldView",ViewWithEave)

function MiningFieldView:ctor(control)     -- control is MiningController
	MiningFieldView.super.ctor(self)
	self:setDelegate(control)

	--regist touch event

end

function MiningFieldView:enter()
    print("MiningFieldView:enter()")
	local pkg = ccbRegisterPkg.new(self)
--	pkg:addProperty("miningMainNode","CCNode")
	pkg:addProperty("mine1","CCNode")
	pkg:addProperty("mine2","CCNode")
	pkg:addProperty("mine3","CCNode")
	pkg:addProperty("mine4","CCNode")
	pkg:addProperty("mine5","CCNode")
	pkg:addProperty("mine6","CCNode")
	pkg:addProperty("mine7","CCNode")
	pkg:addProperty("mine8","CCNode")
	pkg:addProperty("earnNode","CCNode")
	pkg:addProperty("workerInfoNode","CCNode")
	pkg:addProperty("mineName","CCLabelTTF")     --矿场名字

  pkg:addProperty("minerReward","CCLabelTTF")
  pkg:addProperty("coinNum","CCLabelTTF")       --
	pkg:addProperty("minxinNum","CCLabelTTF")       --
	pkg:addProperty("mineInfoBtn","CCControlButton")
	pkg:addProperty("hideInfoBtn","CCControlButton")
	pkg:addProperty("infoNode","CCNode")
	pkg:addProperty("cardTableViewContainer","CCNode")
	pkg:addProperty("infoTableViewContainer","CCNode")
	pkg:addProperty("bottomNode","CCNode")
	pkg:addProperty("miningInfoMainNode","CCNode")
	pkg:addProperty("worksNum","CCLabelTTF")
	pkg:addProperty("mainBg","CCSprite")

	pkg:addFunc("earnBtnCallBack",MiningFieldView.onEarnBtnCallBack)
	pkg:addFunc("hidenfoBtnCallBack",MiningFieldView.onHidenfoBtnCallBack) --暂时隐藏掉打工信息
	pkg:addFunc("mineInfoBtnCallBack",MiningFieldView.showMineInfoBtn)

	-- entry friend minier
	pkg:addFunc("friendMineBtnCallBack",MiningFieldView.onfriendMineBtnCallBack)
	local layer,owner = ccbHelper.load("MiningFieldView.ccbi","MiningFieldViewCCB","CCLayer",pkg)

	local curSence = GameData:Instance():getCurrentScene()
	local size= curSence:getBottomContentSize()
--	self.miningMainNode:setPositionY(self:getParent():getEaveBottomPositionY()-40)
--	self:addChild(layer)
	self:getNodeContainer():addChild(layer)

	-- setting title
	self:setTabControlEnabled(false)
	self:setTitleTextureName("mine-image-paibian.png")
    self.minerReward:setString(_tr("miner_reward_font"))


	local mining = Mining:Instance()
	if mining:getUserName() ~=  GameData:Instance():getCurrentPlayer():getName() then
		self.earnNode:removeFromParentAndCleanup(true)
		self.workerInfoNode:removeFromParentAndCleanup(true)
		self.mineInfoBtn:removeFromParentAndCleanup(true)
		local minerName =  mining:getUserName() .. _tr("miner")
	    self.mineName:setString(minerName)
	else
		--self.earnNode:setPositionY(110)
		local minerName =  _tr("MY_MING")
		self.mineName:setString(minerName)

	end
	self.hideInfoBtn:setTouchPriority(-131)
	self.mineInfoBtn:setTouchPriority(-131)

	--暂时隐藏掉打工信息
	-- self.mineInfoBtn:setVisible(false)
	-- self.infoNode:setVisible(false)

	self.move2Right = nil
	self.move2Left = nil
	self._cardViewConArray = {}
	self._menuHeight = 0
	self:setTouchEnabled(true)
	self:addTouchEventListener(handler(self,self.onTouch),false,-129,false)
	self.deaccScheduleId = 0
	self.ScrollDeaccelRate = 0.95
	self.ScrollDeaccelDist = 1.0

	self.offsetMinX = display.width - self.mainBg:getContentSize().width
	self.offsetMaxX = 0


	local action
	local function initMinerView()
		if (mining:getIsMyMining() == true and mining:getMyMiningDataIsOk() == true) then
            self:stopAction(action)  
       --     self._loading:remove()        
            self:createWorkerCardTabelView()   -- 打工卡牌TabelView
			self:createInfoListTabelView()    --暂时隐藏掉打工信息
			self:showReward()
			self:initMineHole()
			mining:setMyMiningDataIsOk(false)
		elseif 	mining:getIsMyMining() == false and mining:getFriendMiningDataIsOk() == true then
            self:stopAction(action)
     --       self._loading:remove()
            self:initMineHole()
			mining:setFriendMiningDataIsOk(false)
		end
	end
 --   self._loading = Loading:show()
	action = self:schedule(initMinerView,0.2)
end

function MiningFieldView:onTouch(event, x,y)

	local function deaccelerateScrolling()
		if self.isDraging then
			if self.deaccScheduleId > 0 then
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.deaccScheduleId)
				self.deaccScheduleId = 0
			end
			return
		end

		self.mainBg:setPositionX(self.mainBg:getPositionX()+self.moveOffsetX)
		self.moveOffsetX = self.moveOffsetX * self.ScrollDeaccelRate
		local newX = self.mainBg:getPositionX()+self.moveOffsetX

		if (math.abs(self.moveOffsetX) <= self.ScrollDeaccelDist) or newX > self.offsetMaxX or newX < self.offsetMinX then
			if self.deaccScheduleId > 0 then
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.deaccScheduleId)
				self.deaccScheduleId = 0
			end

			if newX > self.offsetMaxX then
				newX = self.offsetMaxX
				self.mainBg:setPositionX(newX)
			end
			if newX < self.offsetMinX then
				newX = self.offsetMinX
				self.mainBg:setPositionX(newX)
			end
		end
	end

	if self._cardTableView ~= nil then
		local cardTableViewWorldPos = self._cardTableView:getParent():convertToWorldSpace(ccp(self._cardTableView:getPositionX(),self._cardTableView:getPositionY()))
		if y>cardTableViewWorldPos.y then
			return
		end
	end


	if event == "began" then
	    self.isDraging = false
	    self.touch_x = x

		return true
	elseif event == "moved" then
		self.isDraging = true
		self.moveOffsetX = x - self.touch_x
		self.touch_x = x
		--self.mainBg:setPosition(ccp(x,y))
		local newX = self.mainBg:getPositionX()+self.moveOffsetX
		if newX > self.offsetMaxX then
			newX = self.offsetMaxX
		end
		if newX < self.offsetMinX then
			newX = self.offsetMinX
		end
		self.mainBg:setPositionX(newX)
	elseif event == "ended" then
		if self.isDraging then
			self.isDraging = false
			if self.deaccScheduleId > 0 then
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.deaccScheduleId)
				self.deaccScheduleId = 0
			end
			self.deaccScheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(deaccelerateScrolling, 0, false)
		else

		end
	end
end


function MiningFieldView:onEarnBtnCallBack()
	print("onEarnBtnCallBack")
--	Mining:Instance():InteractAddMinesPosC2S()
	Mining:Instance():InteractGetCoinC2S()
end

function MiningFieldView:checkTouchOutsideView(x, y)
  local size = self.infoTableViewContainer:getContentSize()
  local pos = self.infoTableViewContainer:convertToNodeSpace(ccp(x, y))
  if pos.x < 0 or pos.x > size.width-25 or pos.y < 0 or pos.y > size.height then 
    return true 
  end

  return false  
end 

function MiningFieldView:showMineInfoBtn()

	--TODO: 创建层
	local layerColor =  CCLayerColor:create(ccc4(0,0,0,0))
	layerColor:setContentSize(CCSizeMake(self.infoTableViewContainer:getContentSize().width,self.infoTableViewContainer:getContentSize().height))

	self.infoTableViewContainer:addChild(layerColor,2,1234)
	CCLayerExtend.extend(layerColor)
	local function onTouch(self,eventType , x , y)
		if eventType == "began" then
			print("Mask began")
			self.preTouchFlag = self:checkTouchOutsideView(x, y)
			return true

		elseif eventType == "ended" then
			local curFlag = self:checkTouchOutsideView(x, y)
			if self.preTouchFlag and curFlag then
				self:onHidenfoBtnCallBack()
			end 
		end
	end
	  --registerScriptTouchHandler
	layerColor:addTouchEventListener(handler(self,onTouch ), false , -130 , true)
	layerColor:setTouchEnabled( true )
	local array = CCArray:create()
	local actionTo = CCMoveTo:create(0.15,CCPointMake(0,self.infoNode:getPositionY()))
	array:addObject(actionTo)

	self.move2Right = CCSequence:create(array)
	self.infoNode:runAction(self.move2Right)
	self.mineInfoBtn:setVisible(false)

end

function MiningFieldView:onHidenfoBtnCallBack()
	--TODO 删除层
	self.infoTableViewContainer:removeChildByTag(1234)
	local array = CCArray:create()
	local actionTo = CCMoveTo:create(0.15,CCPointMake(-self.infoNode:getContentSize().width,self.infoNode:getPositionY()))
	array:addObject(actionTo)

	self.move2Left = CCSequence:create(array)
	self.infoNode:runAction(self.move2Left)
	self.mineInfoBtn:setVisible(true)
end

function MiningFieldView:showReward()
	local coinNum = tostring(Mining:Instance():getCoinReward() or 0)
	local loyalty = tostring(Mining:Instance():getloyaltyReward() or 0)
	self.coinNum:setString(coinNum)
	self.minxinNum:setString(loyalty)
end

function MiningFieldView:createWorkerCardTabelView()

	local cardCount = Mining:Instance():getMyCardCount()
	local workCards = Mining:Instance():getWorkCards() -- 所有在打工位子的卡牌信息
	self._arrayList = {}

	local function scrollViewDidScroll(view)

	end

	local function scrollViewDidZoom(view)

	end

	local function tableCellTouched(table,cell)
		print("sel index",cell:getIdx())
		local idx = cell:getIdx()
		if idx +1 > cardCount then -- 点击的位置超过 开启的数量
			Toast:showString(GameData:Instance():getCurrentScene(), _tr("OPEN_MINE_NEED_OFFICIAL"), ccp(display.cx, display.height*0.4))
			return
		end

		local workerCardCell = self._arrayList[idx+1]
		local curSelectedCard
		if workerCardCell ~= nil and  workerCardCell:getCard() ~= nil then
			curSelectedCard = workerCardCell:getCard()
			print("curSelectedCard:getWorkState()==",curSelectedCard:getWorkState())
			if curSelectedCard:getWorkState() == "MINE_WORK" then  -- work state can not touch
				return
			end
		end

		local mSelectCardListView = SelectCardListView.new(self)
		mSelectCardListView:setParentType(1)
		local selectedCardId = 0
		if curSelectedCard ~= nil then
			selectedCardId = curSelectedCard:getId()
			mSelectCardListView:setCurSelectCardId(selectedCardId)
		end

		local tAllCard = Mining:getAllCardData(selectedCardId)
		GameData:Instance():getCurrentPackage():sortCards(tAllCard, nil, SortType.RARE_UP, false)
		mSelectCardListView:initCardListView(tAllCard)
		mSelectCardListView:setOnClickListCallback()
		--进入卡牌选择界面
		self:getDelegate():getScene():replaceView(mSelectCardListView)

	end

	local function cellSizeForTable(table,idx)
		return 100,120
	end

	local function tableCellAtIndex(table, idx)
		print("idx ====",idx)
		local cell = table:dequeueCell()
		if nil == cell then
			cell = CCTableViewCell:new()
		else
			cell:removeChild(cell:getChildByTag(123),true)
			cell:reset()
		end
		local workerCardCell = CardHeadView.new()
		workerCardCell:enableClick(false)
		workerCardCell:setScale(0.8)

		local workCardInfo -- = (workCards == nil and nil) or workCards[idx+1]
		if workCards ~= nil then
			workCardInfo = workCards[idx+1]
		else
			workCardInfo = nil
		end

		local cardInfo   -- = (workCardInfo == nil and nil ) or workCardInfo:getCardInfo()
		if workCardInfo ~= nil then
			cardInfo = workCardInfo:getCardInfo()
			if cardInfo ~= nil then
				local name = cardInfo:getName()
				local pNameLabel  = ui.newTTFLabelWithOutline(
					{
						text = name,
						font ="Arial",
						size = 20,
						color = ccc3(255, 255, 255), -- 原字体色
						align = ui.TEXT_ALIGN_LEFT,
						valign = ui.TEXT_VALIGN_TOP,
						--dimensions = CCSize(140, 30),
						outlineColor =ccc3(0,0,0)  --黑色描边
					}
				)
				pNameLabel:setAnchorPoint(ccp(0,1))
				pNameLabel:setPosition(ccp(-pNameLabel:getContentSize().width/2.0,-workerCardCell:getContentSize().height/2.0))
				workerCardCell:addChild(pNameLabel)

				local function formatTime(time)
					local hour = 0
					local min  = 0
					local sec  = 0
					if time >0 then
						hour = math.floor(time/3600)
						min = math.floor((time - hour * 3600) / 60)
						sec = math.floor((time - hour * 3600)%60)
					end
					return hour,min,sec
				end

				local stateIcon
				if cardInfo:getWorkState() == "MINE_NORMAL" then
					stateIcon = display.newSprite("#kongxianzhong.png")
				elseif cardInfo:getWorkState() == "MINE_WORK" then
					stateIcon = display.newSprite("#dagongzhong.png")
					local iDeadlines = tonumber(workCardInfo._start) + tonumber(workCardInfo._duration)
					local iCurTime = Clock:Instance():getCurServerUtcTime()
					local iShowTime = iDeadlines - iCurTime
					local hour = 0
					local min  = 0
					local sec  = 0
					hour,min,sec = formatTime(iShowTime)
					local str = string.format("%02d:%02d:%02d", hour,min,sec)
					local pTimeLabel  = ui.newTTFLabelWithOutline(
						{
							text = str,
							font ="Arial",
							size = 20,
							color = ccc3(255, 255, 255), -- 原字体纯黄色
							align = ui.TEXT_ALIGN_LEFT,
							valign = ui.TEXT_VALIGN_TOP,
							--dimensions = CCSize(140, 30),
							outlineColor =ccc3(0,0,0)  --黑色描边
						}
					)
					pTimeLabel:setAnchorPoint(ccp(0,1))
					pTimeLabel:setPosition(ccp(-pTimeLabel:getContentSize().width/2.0,-workerCardCell:getContentSize().height/2.0 - 22))
					workerCardCell:addChild(pTimeLabel,0,102)

					local action
					local function updataTime()
						iShowTime = iShowTime-1
						hour,min,sec = formatTime(iShowTime)

						local showTimeStr = ""
						if hour == 0 and min == 0 and sec == 0  then  -- 更新状态
							self:stopAction(action)
							local workCardInfo = workCards[idx+1]
							local cardInfo = workCardInfo:getCardInfo()
							cardInfo:setWorkState("MINE_NORMAL")
							self._cardTableView:updateCellAtIndex(idx)
						elseif hour == 0 and min <=3 then
							showTimeStr = _tr("WILL_FINISH")
						else
							showTimeStr = string.format("%02d:%02d:%02d", hour,min,sec)
						end

						local oldTimeLabel = workerCardCell:getChildByTag(102)
						if oldTimeLabel ~= nil then
							oldTimeLabel:removeFromParentAndCleanup(true)
							local pTimeLabel  = ui.newTTFLabelWithOutline(
								{
									text = showTimeStr,
									font ="Arial",
									size = 20,
									color = ccc3(255, 255, 255), -- 原字体纯黄色
									align = ui.TEXT_ALIGN_LEFT,
									valign = ui.TEXT_VALIGN_TOP,
									--dimensions = CCSize(140, 30),
									outlineColor =ccc3(0,0,0)  --黑色描边
								}
							)
							pTimeLabel:setAnchorPoint(ccp(0,1))
							pTimeLabel:setPosition(ccp(-pTimeLabel:getContentSize().width/2.0,-workerCardCell:getContentSize().height/2.0 - 22))
							workerCardCell:addChild(pTimeLabel,0,102)
						end
					end
					action = workerCardCell:schedule(updataTime,1.0)
				end
				local function stateIconActiuon()
					local array = CCArray:create()

					array:addObject(CCFadeOut:create(1.0))
					array:addObject(CCFadeIn:create(1.0))
					local action = CCSequence:create(array)
					node:runAction(action)
				end

				local array = CCArray:create()
				array:addObject(CCFadeOut:create(1.20))
				array:addObject(CCFadeIn:create(1.2))
				local action =CCRepeatForever:create(CCSequence:create(array))
				stateIcon:runAction(action)
				workerCardCell:addChild(stateIcon,10,999)

			end
		else
			cardInfo = nil
		end
		workerCardCell:setCard(cardInfo)
		workerCardCell:setPosition(ccp(workerCardCell:getWidth()/2,workerCardCell:getHeight()/2+35))
		workerCardCell:setTag(123)
		self._arrayList[idx+1] = workerCardCell
		if idx+1 <= cardCount then
			workerCardCell:setLocked(false)
		else
			workerCardCell:setLocked(true)
			local strName = Mining:Instance():getOfficialNameWithPos(idx+1)
			if strName ~= "" then 
				strName = strName.._tr("OPEN")
			end 
			local pNameLabel = ui.newTTFLabelWithOutline( {
				text = strName,
				font ="Courier-Bold",
				size = 20,
				x =0,-- posX-4,
				y = 0,-- posY-6,
				color = ccc3(255, 255, 255), -- 原字体纯黄色
				align = ui.TEXT_ALIGN_CENTER,
				valign = ui.TEXT_VALIGN_CENTER,
				dimensions = CCSize(0, 0),
				outlineColor =ccc3(0,0,0) } --黑色描边
			)
			workerCardCell:addChild(pNameLabel)
		end
		cell:setIdx(idx)
		cell:addChild(workerCardCell)
		return cell
	end

	local function numberOfCellsInTableView(val)
		return 8      -- 最多10个打工卡牌
	end

	self._cardTableView = CCTableView:create(CCSizeMake(self.cardTableViewContainer:getContentSize().width,self.cardTableViewContainer:getContentSize().height))
	self._cardTableView:setDirection(kCCScrollViewDirectionHorizontal)
	self.cardTableViewContainer:addChild(self._cardTableView)
	--registerScriptHandler functions must be before the reloadData function
	self._cardTableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
	self._cardTableView:registerScriptHandler(scrollViewDidZoom,CCTableView.kTableViewZoom)
	self._cardTableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
	self._cardTableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
	self._cardTableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
	self._cardTableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
	self._cardTableView:reloadData()
	self._cardTableView:setTouchPriority(-131)
end

function MiningFieldView:createInfoListTabelView()    -- 消息列表的TableView

	-- local testStr = Mining:Instance():getreportData() --打工收益信息, tableCellAtIndex()中使用RichLabel解析
	local testStr = Mining:Instance():getAttackReportData()	--踢人与被踢信息, tableCellAtIndex()中使用RichText解析

	local function scrollViewDidScroll(view)

	end

	local function scrollViewDidZoom(view)

	end

	local function tableCellTouched(table,cell)
		print("sel index",cell:getIdx())
	end

	local function cellSizeForTable(table,idx)
		return 45,368
	end

	local function tableCellAtIndex(table, idx)
		local cell = table:dequeueCell()
		if nil == cell then
			cell = CCTableViewCell:new()
		else
			cell:removeChild(cell:getChildByTag(123),true)
			cell:reset()
		end

		-- 打工收益信息使用 RichLabel 显示
		-- local infoCell = RichLabel:create(testStr[idx+1],"Courier-Bold",20,CCSizeMake(372,45),true,true)
		-- infoCell:setColor(ccc3(255,255,255))
		-- infoCell:setTag(123)
		-- cell:addChild(infoCell)

		--踢人信息用 RichText 显示
		local infoCell = RichText.new(testStr[idx+1], 372, 45, "Courier-Bold", 20, 0xffefa5)
		infoCell:setTag(123)
		cell:addChild(infoCell)

		return cell
	end

	local function numberOfCellsInTableView(val)
		return #testStr
	end

	self._infoTableView = CCTableView:create(CCSizeMake(self.infoTableViewContainer:getContentSize().width,self.infoTableViewContainer:getContentSize().height))
	self._infoTableView:setDirection(kCCScrollViewDirectionVertical)
	self.infoTableViewContainer:addChild(self._infoTableView)
	self._infoTableView:setPosition(ccp(0,0))
	--registerScriptHandler functions must be before the reloadData function
	self._infoTableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
	self._infoTableView:registerScriptHandler(scrollViewDidZoom,CCTableView.kTableViewZoom)
	self._infoTableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
	self._infoTableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
	self._infoTableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
	self._infoTableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
	self._infoTableView:reloadData()
	self._infoTableView:setTouchPriority(-131)

end

function MiningFieldView:onfriendMineBtnCallBack()
	print("onfriendMineBtnCallBack")

	local friendController =  ControllerFactory:Instance():create(ControllerType.FRIEND_CONTROLLER)
	friendController:enter(ViewType.mine)
end



function MiningFieldView:initMineHole() -- minerPos 对象

	local mining = Mining:Instance()
	local baseData = {}
	if mining:getIsMyMining() == true then
		baseData = mining:getBaseData()
	else
		baseData = mining:getFriendBaseData()
	end

	--local pos_count = baseData.pos_count  -- 矿主拥有的最大矿坑数
	for i = 1,8,1 do
		local holeIndex
		if baseData.pos[i] ~= nil and baseData.pos[i].pos ~= nil then
			holeIndex = baseData.pos[i].pos    --holeIndex是从服务器的存储下标，从0开始的
		end

		if holeIndex ~= nil and baseData.pos[i].card ~= nil and baseData.pos[i].card.ower > 0 then  -- baseData.pos[i].card.ower 好友的userId
			mining:setMineHoleStateWithIndex(holeIndex+1,3)
		elseif holeIndex ~= nil then
			mining:setMineHoleStateWithIndex(holeIndex+1,2)
		else
			mining:setMineHoleStateWithIndex(i,1)
		end

		if holeIndex ~= nil then
			i = holeIndex + 1
		end

		local mineHole = MineHoleView.new(i,mining)
		self["mine" .. i]:addChild(mineHole)
	end
end


function MiningFieldView:onExit()
	print("MiningFieldView.lua<MiningFieldView:onExit > : ")
	net.unregistAllCallback(self)
	local mining = Mining:Instance()
	mining:setMyMiningDataIsOk(false)
	mining:setFriendMiningDataIsOk(false)
	local control = self:getDelegate()
	control:setCurMiningView(nil)

end

function MiningFieldView:onBackHandler()
	MiningFieldView.super:onBackHandler()
	GameData:Instance():gotoPreView()
end

function MiningFieldView:onHelpHandler()
	Guide:Instance():removeGuideLayer() -- remove guide
	local help = HelpView.new()
	help:addHelpBox(1026,nil,true)
	self:getDelegate():getScene():addChild(help, 1000)
end

return MiningFieldView