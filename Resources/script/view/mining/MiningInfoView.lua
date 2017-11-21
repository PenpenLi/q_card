
require("model.PlayStates")
require("view.mining.component.SelectCardListView")
MiningInfoView = class("MiningInfoView",BaseView)


function MiningInfoView:ctor(control) -- control is MiningController
	MiningInfoView.super.ctor(self)
	self:setDelegate(control)
end

function MiningInfoView:enter()
	local pkg = ccbRegisterPkg.new(self)
	pkg:addProperty("cardTableViewContainer","CCNode")
	pkg:addProperty("infoTableViewContainer","CCNode")
	pkg:addProperty("bottomNode","CCNode")
	pkg:addProperty("miningInfoMainNode","CCNode")
	pkg:addProperty("worksNum","CCLabelTTF")

	pkg:addFunc("friendMineBtnCallBack",MiningInfoView.onfriendMineBtnCallBack)
	local layer,owner = ccbHelper.load("MiningInfoView.ccbi","MiningInfoViewCCB","CCLayer",pkg)
	self:addChild(layer)
	local winsize = CCDirector:sharedDirector():getWinSize()
	local control = self:getDelegate()
	local menuView = control:getMenuView()
	local size = menuView:getCanvasContentSize() --self:getListContainer():getContentSize()

	--self.miningInfoMainNode:setPositionY((size.height+120)*winsize.height/960)
	--self.bottomNode:setPositionY((120*winsize.height)/960)
	self:createWorkerCardTabelView()   -- 打工卡牌TabelView
	self:createInfoListTabelView()    -- 消息列表的TableView

	self:updateWorkSCardNum()
end

function MiningInfoView:updateWorkSCardNum()
	local workCards = Mining:Instance():getWorkCards()
	if workCards ~= nil then
		local workerNum = #workCards
		local workerNumStr = string.format("%d/%d",workerNum,8)
		self.worksNum:setString(workerNumStr)
	else
		local workerNumStr = string.format("%d/%d",0,8)
		self.worksNum:setString(workerNumStr)
	end
end

function MiningInfoView:createWorkerCardTabelView()

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
		--	local str = string.format(_tr("open_friend_system %{lv}",{lv = systemOpenLv}))
			Toast:showString(GameData:Instance():getCurrentScene(), "官职未到，不能开启打工位", ccp(display.cx, display.height*0.4))
			return
		end

		local workerCardCell = self._arrayList[idx+1]
	--	print("workerCardCell",workerCardCell)
		--print("workerCardCell getCard is",workerCardCell:getCard())
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
						font ="Courier-Bold",
						size = 20,
						color = ccc3(255, 255, 255), -- 原字体纯黄色
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
						font ="Courier-Bold",
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

					local function updataTime()
						iShowTime = iShowTime-1
						hour,min,sec = formatTime(iShowTime)
						local str = string.format("%02d:%02d:%02d", hour,min,sec)
						local oldTimeLabel = workerCardCell:getChildByTag(102)
						if oldTimeLabel ~= nil then
							oldTimeLabel:removeFromParentAndCleanup(true)
							local pTimeLabel  = ui.newTTFLabelWithOutline(
								{
									text = str,
									font ="Courier-Bold",
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
					workerCardCell:schedule(updataTime,1.0)
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
end


--{

----	"测试8",
--	"<font><fontname>Courier-Bold</><color><value>5835096</>【路人甲】</></>被 <font><fontname>Courier-Bold</><color><value>16776960</>【路人乙】</></>赶走"
--     --sddd<font><fontname>Arial</><fontsize>60</><color><value>1356820</>"<<"qqqqqqqq" << "</></>"

--}

function MiningInfoView:createInfoListTabelView()
	local testStr =  Mining:Instance():getreportData()

	local function scrollViewDidScroll(view)

	end

	local function scrollViewDidZoom(view)

	end

	local function tableCellTouched(table,cell)
		print("sel index",cell:getIdx())
	end

	local function cellSizeForTable(table,idx)
		return 45,600
	end

	local function tableCellAtIndex(table, idx)
		local cell = table:dequeueCell()
		if nil == cell then
			cell = CCTableViewCell:new()
		else
			cell:removeChild(cell:getChildByTag(123),true)
			cell:reset()
		end

		local infoCell = RichLabel:create(testStr[idx+1],"Courier-Bold",20,CCSizeMake(600,45),true,true)
		infoCell:setColor(sgBROWN)
		infoCell:setTag(123)
	--	infoCell:setAnchorPoint(ccp(0,0.5))
	--	cell:setIdx(idx)
		cell:addChild(infoCell)
		return cell
	end

	local function numberOfCellsInTableView(val)
		local cellNum = 0
		if #testStr >0 then
			cellNum = #testStr
		end
		return cellNum      -- 最多8个打工卡牌
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


end

function MiningInfoView:onfriendMineBtnCallBack()
	print("onfriendMineBtnCallBack")

	local friendController =  ControllerFactory:Instance():create(ControllerType.FRIEND_CONTROLLER)
	friendController:enter(ViewType.mine)
end

function MiningInfoView:onExit()
	print("MiningInfoView.lua<MiningInfoView:onExit >" )
	self:removeFromParentAndCleanup(true)
end
return MiningInfoView
