--[[
  矿位
-- ]]--

require("model.Mining")
require("view.component.CardHeadView")
require("view.component.PopupView")

MineHoleView = class("MineHoleView",BaseView)

function MineHoleView:ctor(index,object )   -- object:mining
	MineHoleView.super.ctor(self)

	local pkg = ccbRegisterPkg.new(self)

	-- regist property
	pkg:addProperty("MineHoleBgNode","CCNode")
	pkg:addProperty("MineStateNode","CCNode")
	pkg:addProperty("holeMenuImage","CCMenuItemSprite")
	-- register handler
	pkg:addFunc("MenuItemCallBack",MineHoleView.onMenuItemCallBack)

	local node,owner = ccbHelper.load("MineHoleView.ccbi","MineHoleViewCCB","CCNode",pkg)
	self:addChild(node)
	self._index = index
	self._mining = object
	self._holeState = object:getMineHoleStateWithIndex(self._index)
	if self._holeState == 3 and Mining:Instance():getIsMyMining() == true then
		self._ownerMinerCardInfo = Mining:Instance():getBaseData().pos[index].card
		--dump(self._ownerMinerCardInfo ,"MinerCardInfo")
	elseif self._holeState == 3 and Mining:Instance():getIsMyMining() == false then
		self._ownerMinerCardInfo = Mining:Instance():getFriendBaseData().pos[index].card
	end

	self:initHoleBgWithState(self._holeState)
	self:initHoleTitleWithState(self._holeState)

end

function MineHoleView:getContentSize()
	local sizeX = self.MineHoleBgNode:getContentSize().width
	local sizeY = self.MineHoleBgNode:getContentSize().height
	return sizeX,sizeY
end

-- 矿位的背景 (默认是 锁定的背景)
function MineHoleView:initHoleBgWithState(state)

	if state == 2 or state == 3 then -- 空闲 或者打工状态
		print("MineHoleView.lua<MineHoleView:initHoleBgWithState> state: " .. state)
		--local oldBg = self.MineHoleBgNode:getChild()
		self.holeMenuImage:setNormalImage(CCSprite:createWithSpriteFrameName("mine-button-kuang-nor.png"))
		self.holeMenuImage:setSelectedImage(CCSprite:createWithSpriteFrameName("mine-button-kuang3-sel.png"))
	end
end

-- 矿位的标签状态(默认是 "未解锁")
function MineHoleView:initHoleTitleWithState(state)

	if state == 1 then


	elseif state == 2 then-- 空闲状态
		self.MineStateNode:removeAllChildrenWithCleanup(true)
		local newStateTitle = display.newSprite("#mine-button-kongxian.png")
		--newBg:setPosition(ccp(oldBg:getPositionX(),oldBg:getPositonY()))
		self.MineStateNode:addChild(newStateTitle)
	elseif state ==3 then   -- 打工状态
		self.MineStateNode:removeAllChildrenWithCleanup(true)

		local miningCard = MiningCard.new()  -- show card`s avatar
		miningCard:initCardInfo(self._ownerMinerCardInfo)
		local cardInfo = miningCard:getCardInfo()
		local cardCell = CardHeadView.new()
		cardCell:setCard(cardInfo)
		cardCell:setScale(0.8)
		cardCell:setPositionY(5.0)
		if cardInfo ~= nil then
			self.MineStateNode:addChild(cardCell)
		end

		local nameStr =  self._ownerMinerCardInfo.ownerName    --"玩家" .. self._index
		local friendName = CCLabelTTF:create(nameStr,"Courier-Bold",20)
		friendName:setPositionY(-55)
		friendName:setColor(sgGREEN)
		self.MineStateNode:addChild(friendName)

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

		local iDeadlines = tonumber(self._ownerMinerCardInfo.start) + tonumber(self._ownerMinerCardInfo.duration)
		local iCurTime = Clock:Instance():getCurServerUtcTime()
		local iShowTime = iDeadlines - iCurTime

		local hour = 0
		local min  = 0
		local sec  = 0
		hour,min,sec = formatTime(iShowTime)

	--	self.label_time:setString(string.format("%02d:%02d", _min,_sec))
		local str = string.format("%02d:%02d:%02d", hour,min,sec)  --os.date("%Y/%m/%d/ %X",iShowTime)
		local timeLabel =    CCLabelTTF:create(str,"Courier-Bold",20)
		timeLabel:setPositionY(-80.0)
		self.MineStateNode:addChild(timeLabel)

		local function updataTime()
			iShowTime = iShowTime-1
			hour,min,sec = formatTime(iShowTime)
			local str
			if hour == 0 and min < 3 then
				str = _tr("mining_work_will_finish")
				timeLabel:setString(str)
			else
				str = string.format("%02d:%02d:%02d", hour,min,sec)
				timeLabel:setString(str)
			end

		end
		self:schedule(updataTime,1.0)
	end
end

function MineHoleView:onMenuItemCallBack()
	print("self._index",self._index)   -- 从1开始
	print("self._holeState",self._holeState)
	print("onMenuItemCallBack")
	print("self._mining:getIsMyMining()",self._mining:getIsMyMining())
	local baseData = self._mining:getBaseData()

	if self._holeState == 1 and self._mining:getIsMyMining() == true then            --锁定
		local curPosCount = Mining:Instance():getPosCount()
		print("curPosCount",curPosCount)
--		if self._index >=7 then
--			Toast:showString(GameData:Instance():getCurrentScene(),"该矿位暂未开启....", ccp(display.cx, display.height*0.4))
--			return
--		end
		if self._index > curPosCount + 1 then
			return
		end
		local costMoney = Mining:Instance():getAddMinerPosCostMoneyWithIndex(curPosCount+1)
		local ownMoney = GameData:Instance():getCurrentPlayer():getMoney()

		print("costMoney = ",costMoney)

		local function addHoleCallback()

			if ownMoney < costMoney then
				-- Toast:showString(GameData:Instance():getCurrentScene(),_tr("no_enough_money_to_buy_mining_hole"), ccp(display.cx, display.height*0.4))
				GameData:Instance():notifyForPoorMoney()
			else
				Mining:Instance():InteractAddMinesPosC2S()  -- 请求增加矿位
			end

		end
		local str = _tr("spend_%{count}_for_mining_hole?", {count=costMoney})
		local pop = PopupView:createTextPopup(str,addHoleCallback)
		local scene = GameData:Instance():getCurrentScene()
		scene:addChild(pop,100)
	elseif self.__holeState == 1 and self._mining:getIsMyMining() == false then
		return
	elseif self._holeState == 2  and self._mining:getIsMyMining() == true then        --空闲
		-- 无响应
	elseif self._holeState == 2  and self._mining:getIsMyMining() == false then
		-- 去打工 1.选择卡 2选择时间 3.然后再打工
		local mSelectCardListView = SelectCardListView.new(self)
		mSelectCardListView:setParentType(2)
		local tAllCard = Mining:Instance():getIdelWorkCards()
		local userId = Mining:Instance():getUserId()

		mSelectCardListView:initCardListView(tAllCard)

		local pos = self._index
		mSelectCardListView:initWorkInfo(pos-1,userId)
		GameData:Instance():getCurrentScene():replaceView(mSelectCardListView)


	--	self._mining:InteractCardTryWorkC2S()
	elseif self._holeState == 3 and self._mining:getIsMyMining() == true then          -- 站位
		-- 弹出卡牌信息界面
		local cardConfigId = baseData.pos[self._index].card.info.config_id
		--print("configId",cardConfigId)
		if cardConfigId ~= 0 then
			self.card =  OrbitCard.new({configId = cardConfigId})
			self.card:show()
		end
	elseif self._holeState == 3 and self._mining:getIsMyMining() == false then
		-- pk 提示矿位已被站 是否决斗 决斗的时候先选择时间然后进入 战斗界面
		local myUserId = GameData:Instance():getCurrentPlayer():getId()
		--print("aaaaaaaaaaaa",self._ownerMinerCardInfo.ower,myUserId)
		if myUserId == self._ownerMinerCardInfo.ower then
			return
		end

		local function checkInfoCallBack()  --资料

			Friend:Instance():QueryPlayerShowC2S(4,self._ownerMinerCardInfo.ower)
			--self._loading = Loading:show()
			_showLoading()
			local function showFriendInfo()
				--self._loading:remove()
				_hideLoading()
				local friendData = Friend:Instance():getFriendDataWithFriendId(self.friendId,4)
				local pop = PopupView:createFriendInfoPopup(friendData,function() Friend:Instance():MsgC2SRemoveFriend(self.friendId) end,true)
				--GameData:Instance():getCurrentScene():addChild(pop,100)
				local curScene = GameData:Instance():getCurrentScene()
				local popupNode = nil
				local popupNode = curScene:getChildByTag(POPUP_NODE_ZORDER)
				if popupNode == nil then
					popupNode = display.newNode()
					curScene:addChild(popupNode,POPUP_NODE_ZORDER,POPUP_NODE_ZORDER)
					popupNode:addChild(pop,100)
				else
					popupNode:addChild(pop,100)
				end
			end
			self:performWithDelay(handler(self,showFriendInfo),0.8)

		end

		local function pkCallBack(self)
			local mSelectCardListView = SelectCardListView.new(self)
			mSelectCardListView:setParentType(3)
			local tAllCard = Mining:Instance():getIdelWorkCards()
			local userId = Mining:Instance():getUserId()
			local friendBaseData  = Mining:Instance():getFriendBaseData()
			local pos = self._index
			local  pkTargetId
			local  pkTargetCardConfigId  -- 挑战的卡牌的configId
			local curFriendSelectedCardInfo
			if friendBaseData ~= nil then
				 pkTargetId = friendBaseData.pos[pos].card.miners
				 pkTargetCardConfigId =  self._ownerMinerCardInfo.info.config_id  --
				 curFriendSelectedCardInfo = friendBaseData.pos[pos].card
				 print("########@@@@@@@@@@@@@#######,pkTargetId",pkTargetId,pkTargetCardConfigId)
				 if pkTargetId ~= nil then
					 Mining:Instance():setPkTargetId(pkTargetId)
					 Mining:Instance():setPkTargetCardConfigId(pkTargetCardConfigId)
				 end
			end

			mSelectCardListView:initCardListView(tAllCard)

			mSelectCardListView:initWorkInfo(pos-1,userId)
			GameData:Instance():getCurrentScene():replaceView(mSelectCardListView)
		end

		local pop = PopupView:createTextPopupWithPath(
			{leftNorBtn = "miner_ziliao_nor.png",leftSelBtn = "miner_ziliao1-sel.png",rightNorBtn = "juedou_nor.png",
				rightSelBtn = "juedou1.png",text = _tr("fighting_for_mining_hole?"),
				leftCallBack = function() return checkInfoCallBack() end,rightCallBack = function() return pkCallBack(self) end
		})
		--GameData:Instance():getCurrentScene():addChild(pop,100)

		local curScene = GameData:Instance():getCurrentScene()
		local popupNode = nil
		local popupNode = curScene:getChildByTag(POPUP_NODE_ZORDER)
		if popupNode == nil then
			popupNode = display.newNode()
			curScene:addChild(popupNode,POPUP_NODE_ZORDER,POPUP_NODE_ZORDER)
			popupNode:addChild(pop,100)
		else
			popupNode:addChild(pop,100)
		end

	else
		return
		--assert(false)
	end


end


function MineHoleView:enter()

end

function MineHoleView:onExit()
	print("MineHoleView:onExit()")
end

return MineHoleView
