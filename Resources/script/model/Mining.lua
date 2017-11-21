--[[
-- 矿场 的对象
-- ]]--

require("model.MiningCard")

Mining = class("Mining")

ReportType = enum({"NONE","REPORT_FIGHT","REPORT_WORK"})

Mining._instance = nil

Mining._userId = 0

local function dump()

end

-- local function print()

-- end

function Mining:Instance()
	if Mining._instance == nil then
		Mining._instance = Mining.new()
	end
	return Mining._instance
end


function Mining:ctor()
	net.registMsgCallback(PbMsgId.InteractQueryDataResultS2C,self,Mining.onInteractQueryDataResultS2C)      -- 返回初始数据
	net.registMsgCallback(PbMsgId.InteractCardTryWorkResultS2C,self,Mining.onInteractCardTryWorkResultS2C)  -- 请求开始打工
	net.registMsgCallback(PbMsgId.InteractChangeCardResultS2C,self,Mining.onInteractChangeCardResultS2C)    -- 请求换卡上打工序列
	net.registMsgCallback(PbMsgId.InteractAddMinesPosResultS2C,self,Mining.onInteractAddMinesPosResultS2C)  -- 请求增矿位
	net.registMsgCallback(PbMsgId.InteractGetCoinResultS2C,self,Mining.onInteractGetCoinResultS2C)          -- 请求收获
	net.registMsgCallback(PbMsgId.InteractCardFightResultS2C,self,Mining.onInteractCardFightResultS2C)      -- 请求开战
	net.registMsgCallback(PbMsgId.InteractUpdateS2C,self,Mining.onInteractUpdateS2C)                        -- 数据包更新

	self._holeState = {}
	self._reportData = {}
	self._player = GameData:Instance():getCurrentPlayer()
	self:initCostTableWithType(7)
	self:initPosAndOfficialName()
	self._lastSelectedcardFromList = nil
end

function Mining:setControl(control)
	self._control = control
end

function Mining:getControl()
	return self._control
end

function Mining:setIsMyMining(isMy)
	self._isMyData = isMy
end

function Mining:getIsMyMining()
	return self._isMyData
end

function Mining:initCostTableWithType(costType)
	self._addMinerPosCostTable ={}
	for k, v in pairs(AllConfig.cost) do
		local type = AllConfig.cost[k].type
		if costType == type then
			table.insert(self._addMinerPosCostTable, AllConfig.cost[k])
		end
	end

end

function Mining:getAddMinerPosCostMoneyWithIndex(index)
	for k, v in pairs(self._addMinerPosCostTable) do
		if index >= v.min_count and index <=v.max_count then
			return v.cost
		end
	end
	return self._addMinerPosCostTable[index].cost
end

function Mining:setUserId(userId)
    local myUserId = self._player:getId()
	if userId == 0 or userId == nil or userId == myUserId then
		if self._player ~= nil then
			self._userId = myUserId
		end
		self:setIsMyMining(true)
	else
		self._userId = userId
		self:setIsMyMining(false)
	end
end

function Mining:getUserId()
	return self._userId
end

function Mining:setUserName(userName)
	if userName == nil then
		--local player = GameData:Instance():getCurrentPlayer()
		if self._player ~= nil then
			self._userName = self._player:getName()
		end
	else
		self._userName = userName
	end

end

function Mining:getUserName()
	return self._userName
end

-- 请求玩家基础数据
function Mining:reqBasedataWithUserId(userId)

	   print("self._userId,userId",self._userId,userId)
	--if self._userId ~= nil and self._userId ~= userId then
		print("@%%%%%%%%%%%%%%%%%Mining.lua<Mining:reqBasedataWithUserId> : userId = " .. userId)
		self._reqDataUesrId = userId
		local data = PbRegist.pack(PbMsgId.InteractQueryDataC2S,{id = userId})
		net.sendMessage(PbMsgId.InteractQueryDataC2S,data)
	--end
end

-- 请求开始打工 派遣卡牌去打工
function Mining:InteractCardTryWorkC2S(cardId,strCardState,minersId,position,time,minerSortType,workSortType)

	print("Mining.lua<Mining:interactCardTryWorkC2S> : " )
	local tryWorkData
	self.workType = 0    --1:normal 2:quick
	if minerSortType ~= nil then
		self.workType = 2
		tryWorkData = PbRegist.pack(PbMsgId.InteractCardTryWorkC2S,{card = cardId,state= strCardState,miners = minersId,pos = position,duration = time,type = minerSortType,card_type = workSortType})
	else
		self.workType = 1
		tryWorkData = PbRegist.pack(PbMsgId.InteractCardTryWorkC2S,{card = cardId,state= strCardState,miners = minersId,pos = position,duration = time})
	end
	net.sendMessage(PbMsgId.InteractCardTryWorkC2S,tryWorkData)
end

--请求换卡上打工序列
function Mining:InteractChangeCardC2S(cardConfigId,targetConfigId)

	print("@@@@@@@@@　InteractChangeCardC2S",cardConfigId,targetConfigId)
	local data = PbRegist.pack(PbMsgId.InteractChangeCardC2S,{card = cardConfigId,target = targetConfigId }) -- target 指的是要替换的打工卡牌的Id，如果该序列没有卡牌。则传0
	net.sendMessage(PbMsgId.InteractChangeCardC2S,data)
end


--请求增加矿位
function Mining:InteractAddMinesPosC2S()
	net.sendMessage(PbMsgId.InteractAddMinesPosC2S)
end

-- 收获金币和民心
function Mining:InteractGetCoinC2S()
	net.sendMessage(PbMsgId.InteractGetCoinC2S)
end

--请求开战
function Mining:InteractCardFightC2S(cardId,targetId,targetPos,time)
	local data = PbRegist.pack(PbMsgId.InteractCardFightC2S,{card = cardId,target = targetId,target_pos = targetPos,duration = time})
	net.sendMessage(PbMsgId.InteractCardFightC2S,data)
end

function Mining:onInteractQueryDataResultS2C(action,msgId,msg)
	print("Mining.lua<Mining:onInteractQueryDataResultS2C> : "  )
	if msg.data == nil then
		return
	end
	
	-- self:initInteractReportData(msg.data.report) --暂时隐藏掉打工信息
	self:initInteractServerBaseData(msg.data.base)

	self:updateAttackReportData(msg.data.report) --显示踢人与被踢信息
end


function Mining:initInteractServerBaseData(pMsgBaseData)

	if pMsgBaseData == nil then
		return
	end

	local player  = GameData:Instance():getCurrentPlayer()
	local userId = player:getId()
	if userId == pMsgBaseData.id then -- 自己的数据
		self._baseData = {}
		self._baseData.userId = pMsgBaseData.id
		self._baseData.pos_count = pMsgBaseData.pos_count

		--初始化 MinerPos 自己的矿坑（好友来打工数据）
		self._baseData.pos = {}  -- pos: int ->pos MinerCard->card
		for i=1,#pMsgBaseData.pos,1 do
			local minerPos = {}
			minerPos.pos = pMsgBaseData.pos[i].pos
			minerPos.card = self:initMinerCard(pMsgBaseData.pos[i].card)
			table.insert(self._baseData.pos,minerPos)
		end
		-- 初始化 MinerCard
		self._baseData.card = {}
		for j = 1,#pMsgBaseData.card,1 do
			local minerCard = {}
			minerCard = self:initMinerCard(pMsgBaseData.card[j])
			table.insert(self._baseData.card,minerCard)
		end

		self._baseData.card_count = pMsgBaseData.card_count  -- 自己当前最多有几个卡牌可以去打工
		self._baseData.award = {}
		self._baseData.award.coin = pMsgBaseData.award.coin
		self._baseData.award.loyalty = pMsgBaseData.award.loyalty

		self:setMyMiningDataIsOk(true)
		--dump(self._baseData,"#######sself._baseData###############")
	else
		self._friendBaseData = {}
		self._friendBaseData.userId = pMsgBaseData.id
		self._friendBaseData.pos_count = pMsgBaseData.pos_count

		--初始化 MinerPos 自己的矿坑（好友来打工数据）
		self._friendBaseData.pos = {}  -- pos: int ->pos MinerCard->card
		for i=1,#pMsgBaseData.pos,1 do
			local minerPos = {}
			minerPos.pos = pMsgBaseData.pos[i].pos
			--	dump(pMsgBaseData.pos[i].card,"pMsgBaseData.pos")
			minerPos.card = self:initMinerCard(pMsgBaseData.pos[i].card)
			dump(minerPos.card.info,"minerPos.card.info")
			print("minerPos.card.info.configId",minerPos.card.info.id)
			table.insert(self._friendBaseData.pos,minerPos)
		end

		-- 初始化 MinerCard
		self._friendBaseData.card = {}
		--print("card num is ",#pMsgBaseData.card)
		for j = 1,#pMsgBaseData.card,1 do
			local minerCard = {}
			minerCard = self:initMinerCard(pMsgBaseData.card[j])
			table.insert(self._friendBaseData.card,minerCard)
		end

		self._friendBaseData.card_count = pMsgBaseData.card_count  -- 自己当前最多有几个卡牌可以去打工
		self._friendBaseData.award = {}
		self._friendBaseData.award.coin = pMsgBaseData.award.coin
		self:setFriendMiningDataIsOk(true)
		dump(self._friendBaseData,"########self._friendBaseData##############")	--好友数据
	end

end

function Mining:getPosCount()
	print("Mining.lua<Mining:getPosCount> self._baseData.pos_count: " .. self._baseData.pos_count)
	
	return self._baseData.pos_count
end

function Mining:setPosCount(posCount)
	if self._baseData ~= nil then
		self._baseData.pos_count = posCount
	end
end

function Mining:getCoinReward()
	print("Mining.lua<Mining:getCoinReward> self._baseData.award.coin : " ..  self._baseData.award.coin)
	return self._baseData.award.coin
end

function Mining:updateCoinReward(coin)
	print("Mining.lua<Mining:updateCoinReward> coin: " .. coin)
	self._baseData.award.coin = coin
end

function Mining:getloyaltyReward()
	return self._baseData.award.loyalty
end

function Mining:updateloyaltyReward(loyalty)
	self._baseData.award.loyalty = loyalty
end

function Mining:getBaseData()
	return self._baseData
end

function Mining:getFriendBaseData()
	return self._friendBaseData
end

function Mining:initInteractReportData(pMsgReportData)

	dump(pMsgReportData,"pMsgReportData")
	if pMsgReportData == nil or self:getIsMyMining() == false then
		return
	end
	self._reportData = {}
	self.report = {}

	for i = 1,#pMsgReportData,1 do
		local oneLineReportData = {}
		local strReport

		oneLineReportData.type = pMsgReportData[i].type

		oneLineReportData.workerAward = {}       --打工者收益
		oneLineReportData.workerAward.coin = pMsgReportData[i].award.coin
		oneLineReportData.workerAward.loyalty = pMsgReportData[i].award.loyalty
		oneLineReportData.time = pMsgReportData[i].time

		oneLineReportData.minerAward = {}   --矿主收益
		oneLineReportData.minerAward.coin =  pMsgReportData[i].awardminer.coin
		oneLineReportData.minerAward.loyalty =  pMsgReportData[i].awardminer.loyalty
		oneLineReportData.miners = pMsgReportData[i].miners
		oneLineReportData.minerName = "<font><fontname>Courier-Bold</><color><value>53519</>" ..pMsgReportData[i].minerName .. "</></> "

		oneLineReportData.worker = pMsgReportData[i].worker
		oneLineReportData.workername =  "<font><fontname>Courier-Bold</><color><value>53519</>" ..pMsgReportData[i].workerName .. "</></> "

		oneLineReportData.attacker = pMsgReportData[i].attacker
		oneLineReportData.attackerName = pMsgReportData[i].attackerName
		oneLineReportData.winner = pMsgReportData[i].winner

		--local times = toint(os.time()-oneLineReportData.time) TODO: 2014-06-26 服务端修改time为 时间差，而不是之前的其实打工时间，因此不需要客户端计算
		local times = oneLineReportData.time
		local hour = math.floor(times/3600)
		local min = math.floor((times - hour * 3600) / 60)
		local sec = math.floor((times - hour * 3600)%60)
		local strTime
		if hour == 0 then
			strTime = min .._tr("minute")
		else
			strTime = hour.. _tr("hour") .. min .._tr("minute")
		end

		if oneLineReportData.type == "REPORT_WORK" then
			print(pMsgReportData[i].minerName ,self._player:getName())

			if pMsgReportData[i].minerName == self._player:getName() then -- 【路人甲】为您干活8小时，你从TA的工钱中获得了10000铜钱。
				-- 打工信息
				local money = "<font><fontname>Courier-Bold</><color><value>44790</>"..oneLineReportData.minerAward.coin .."</></>"
				local loyalty ="<font><fontname>Courier-Bold</><color><value>44790</>" .. oneLineReportData.minerAward.loyalty .."</></>"

				local reward
				if money ~= 0 and loyalty ~= 0 then
					reward = _tr("coin%{num1}_and_loyalty%{num2}", {num1=money,num2=loyalty})
				elseif money~= 0 and loyalty == 0 then
					reward = money .._tr("coin")
				elseif money == 0 and loyalty ~= 0 then
					reward = _tr("loyalty%{num}", {num=loyalty})
				end

				strReport = _tr("%{name}_work_time%{count}_for_you_benefit%{count2}", {name=oneLineReportData.workername, count=strTime,count2=reward})

			else -- 矿主是好友，自己为好友打工  您为【路人乙】干活8小时，获得了10000铜钱。
				-- 打工信息
				local money = "<font><fontname>Courier-Bold</><color><value>44790</>"..oneLineReportData.workerAward.coin .."</></>"
				local loyalty ="<font><fontname>Courier-Bold</><color><value>44790</>" .. oneLineReportData.workerAward.loyalty .."</></>"

				local reward
				if money ~= 0 and loyalty ~= 0 then
					reward = _tr("coin%{num1}_and_loyalty%{num2}", {num1=money,num2=loyalty})
				elseif money~= 0 and loyalty == 0 then
					reward = money .._tr("coin")
				elseif money == 0 and loyalty ~= 0 then
					reward = _tr("loyalty%{num}", {num=loyalty})
				end

				strReport = _tr("you_work_for_%{name}_%{time}_benefit_%{str}", {name=oneLineReportData.minerName, time=strTime, str=reward})
			end

		elseif oneLineReportData.type == "REPORT_FIGHT" then


		end


		table.insert(self._reportData,strReport)
		table.insert(self.report,oneLineReportData)
	end
	dump(self.report,"self.report")
end

function Mining:getreportData()
	return self._reportData
end

--踢人与被踢信息
function Mining:updateAttackReportData(pMsgReportData)
	print("@@@@@@@@@@@@@@@ updateAttackReportData")
	if pMsgReportData == nil then
		return
	end

	self._attackData = {}
	local playerId = GameData:Instance():getCurrentPlayer():getId()
	for k, v in pairs(pMsgReportData) do
		if v.type == "REPORT_FIGHT" then 
			print("===atkId,atkName,winnerId:", v.attacker, v.attackerName, v.winner)
			local str = ""
			local nameStr
			if v.attacker == playerId then --我踢别人
				nameStr = string.format("{%s, 0xef2416}", v.workerName)
				if v.attacker == v.winner then --成功
					str = _tr("you_atk_%{name}_mine_hole_success", {name=nameStr})
				else 
					str = _tr("you_atk_%{name}_mine_hole_fail", {name=nameStr})
				end 

			else --别人踢我
				nameStr = string.format("{%s, 0xef2416}", v.attackerName)
				if v.attacker == v.winner then --成功
					str = _tr("%{name}_atk_your_mine_hole_success", {name=nameStr})
				else 
					str = _tr("%{name}_atk_your_mine_hole_fail", {name=nameStr})
				end 
			end
			table.insert(self._attackData, 1, str)
		end 
	end 
end 

function Mining:getAttackReportData()
	if self._attackData == nil then 
		self._attackData = {}
	end 

	return self._attackData 
end 

function Mining:initMinerCard(minerCardData)
	local minerCard = {}
	minerCard.ower = minerCardData.ower       -- 所有者的userId
	minerCard.card = minerCardData.card        -- 该卡牌的 cardId：服务端自动生成的Id
	minerCard.miners = minerCardData.miners    -- 该卡牌所打工好友的 userId
	minerCard.pos = minerCardData.pos          -- 该卡牌在好友矿场的打工位置
	minerCard.start = minerCardData.start       -- 开始打工时间
	minerCard.duration = minerCardData.duration -- 打工持续的时间
	minerCard.award = {}
	if minerCardData.award ~= nil then
		minerCard.award.coin = minerCardData.award.coin
		minerCard.award.loyalty = minerCardData.award.loyalty
	end
	minerCard.info = minerCardData.info    -- 该卡牌的Card model信息
	minerCard.minerName = minerCardData.minerName --  矿主的昵称
	minerCard.ownerName = minerCardData.ownerName --   所有者的昵称
	print("minerCardData.minerName",minerCardData.minerName)
	return minerCard
end

function Mining:onInteractCardTryWorkResultS2C(action,msgId,msg)
	print("Mining.lua<Mining:onInteractCardTryWorkResultS2C> : "  )

	print("msg.error is",msg.error)
	if msg.error == "NO_ERROR_CODE" then
		--dump(msg.update,"ChangeCardResult")
		print("begin idel count == ",#self:getIdelWorkCards() )
		self:parseUpdataMsg(msg)
		local player = GameData:Instance():getCurrentPlayer()
		local userId = player:getId()
		self:reqBasedataWithUserId(userId)

		if self.workType == 2 then
			--local totalWorkCard = self:getMyCardCount() --总的打工卡牌
			local idelWorkCards = #self:getIdelWorkCards() -- 空闲的卡牌
			print("end idel count == ",#self:getIdelWorkCards() )
			if idelWorkCards >0 then
				Toast:showString(self, _tr("no_enough_mine_for_left_cards_%{num}", {num=idelWorkCards}), ccp(display.cx, display.cy))
			else
				Toast:showString(self, _tr("all_cards_working"), ccp(display.cx, display.cy))
			end
		end


	elseif msg.error == "MINES_FULL" then

	elseif msg.error == "NOT_FOUND_POS" then

	elseif msg.error == "NOT_FOUND_TARGET" then

	elseif msg.error == "ALL_FRIEND_FULL" then
		Toast:showString(self, _tr("all_friends_mine_is_full"), ccp(display.cx, display.cy))
	end
end

-- 请求上打工序列的回调
function Mining:onInteractChangeCardResultS2C(action,msgId,msg)
	print("Mining.lua<Mining:onInteractChangeCardResultS2C> : " )
	print("msg.error is",msg.error)
	if msg.error == "NO_ERROR_CODE" then
		dump(msg.update,"ChangeCardResult")
		self:parseUpdataMsg(msg)
	elseif msg.error == "CARD_IS_ACTIVE" then
		Toast:showString(self, _tr("battle_card_cannot_working"), ccp(display.cx, display.cy))
	end
end

function Mining:onInteractAddMinesPosResultS2C(action,msgId,msg)
	print("Mining.lua<Mining:onInteractAddMinesPosResultS2C> : "  )

	print("msg.error is",msg.error)
	if msg.error == "NO_ERROR_CODE" then
		dump(msg.update,"ChangeCardResult")
		self:parseUpdataMsg(msg)
	end
end

function Mining:onInteractGetCoinResultS2C(action,msgId,msg)
	print("Mining.lua<Mining:onInteractGetCoinResultS2C> : " )
	print("msg.error is",msg.error)
	if msg.error == "NO_ERROR_CODE" then
		dump(msg.update,"GetCoinResult")
		self:parseUpdataMsg(msg)
	end

end

function Mining:onInteractCardFightResultS2C(action,msgId,msg)
	echo("@@@ onInteractCardFightResultS2C")
	local myUserPlayerId = GameData:Instance():getCurrentPlayer():getId()
	if msg.error == "NO_ERROR_CODE" then
		if msg.winner == myUserPlayerId then
			self:setPkIsWin(true)
		else
			self:setPkIsWin(false)
		end
		--dump(msg.update,"CardFightResult")
		self:parseUpdataMsg(msg)
	end

end

function Mining:parseUpdataMsg(InteractDataUpdate)

	if InteractDataUpdate.update == nil then
		return
	end

--
--	required InteractBase base    = 1;
--	repeated InteractCard cards   = 2;
--	repeated InteractPos  poss    = 3;
--	optional ClientSync  client  = 4;
--	repeated InteractReport report = 5;

	if InteractDataUpdate.update.client ~= nil then
		GameData:Instance():getCurrentPackage():parseClientSyncMsg(InteractDataUpdate.update.client)
	end
	local owner = 0
	local myUserId = 0
	if InteractDataUpdate.update.base ~= nil then
		owner = InteractDataUpdate.update.base.ower
		myUserId = GameData:Instance():getCurrentPlayer():getId()
		print("update msg myUserId =",myUserId)
		print("updata msg owner = ",InteractDataUpdate.update.base.ower)
		if owner ==  myUserId and self:getControl() ~= nil then
			print("InteractDataUpdate.update.base.ower",InteractDataUpdate.update.base.ower)
			print("InteractDataUpdate.update.base.pos_count",InteractDataUpdate.update.base.pos_count)
			print("InteractDataUpdate.update.base.card_count",InteractDataUpdate.update.base.card_count)
			print("InteractDataUpdate.update.base.award.coin",InteractDataUpdate.update.base.award.coin)
			print("InteractDataUpdate.update.base.award.loyalty",InteractDataUpdate.update.base.award.loyalty)
			self:setPosCount(InteractDataUpdate.update.base.pos_count)
			self:updateCoinReward(InteractDataUpdate.update.base.award.coin)
			self:updateloyaltyReward(InteractDataUpdate.update.base.award.loyalty)
			self:setMyCardCount(InteractDataUpdate.update.base.card_count)
		elseif owner~= myUserId  then   -- updata friend miner info
			local friendMod = Friend:Instance()
			friendMod:setMinerMaxCountWithFriendId(owner,InteractDataUpdate.update.base.pos_count) -- 增加矿位
		end
	end

	if InteractDataUpdate.update.cards ~= nil then  -- 更新minerCard
		-- dump(self._baseData.card,"begin")
		local removeCardId = 0
		local removeMinerCard = nil
		local addCardId = 0
		local addMinerCard = nil
		local updateCardId = 0
		local updateMinerCard = nil

		local function updateMinerCard(operator,targetCardId,minerCardData)

			print("update operator =====",operator)
			if table.getn(self._baseData.card) == 0 and targetCardId then
				table.insert(self._baseData.card,minerCardData)
				targetCardId = 0
			else
				for k, v in pairs(self._baseData.card) do
					if operator == "OP_REMOVE" then
						if v.card == targetCardId then
							table.remove(self._baseData.card,k)
						end
					elseif operator == "OP_UPDATE" then
						if v.card == targetCardId then
							table.remove(self._baseData.card,k)
							table.insert(self._baseData.card,minerCardData)
							targetCardId = 0
						end
					elseif operator == "OP_ADD" then
						if targetCardId >0 then
							table.insert(self._baseData.card,minerCardData)
							targetCardId = 0
						end
					end

				end
			end
		end

		for k, v in pairs(InteractDataUpdate.update.cards) do
			local operator = InteractDataUpdate.update.cards[k].op --OP_ADD OP_UPDATE OP_REMOVE
			local targetCardId = InteractDataUpdate.update.cards[k].card.card
			local cardData = self:initMinerCard(InteractDataUpdate.update.cards[k].card)
			updateMinerCard(operator,targetCardId,cardData)
		end

	end

	if InteractDataUpdate.update.poss  ~= nil then         -- 更新MinerPos
		for k, v in pairs(InteractDataUpdate.update.poss) do
			local MinerPos = InteractDataUpdate.update.poss[k].pos
			local operator = InteractDataUpdate.update.poss[k].op --OP_ADD OP_UPDATE OP_REMOVE
			if operator == "OP_ADD" then
				local minerPos = {}
				minerPos.pos = MinerPos.pos
				minerPos.card = self:initMinerCard(MinerPos.card)
				table.insert(self._baseData.pos,minerPos)
			elseif operator == "OP_UPDATE" then

			elseif operator == "OP_REMOVE" then

			end
			print("2222operator",operator)
		end
	end
	
	if  InteractDataUpdate.update.report ~= nil then
		-- self:initInteractReportData(InteractDataUpdate.update.report) --暂时隐藏掉打工信息
		self:updateAttackReportData(InteractDataUpdate.update.report) --显示踢人与被踢信息
	end

	if owner == myUserId then
		local control = self:getControl()
		local controlType = ControllerFactory:Instance():getCurrentControllerType()
		if ControllerType.MINING_CONTROLLER == controlType and control ~= nil  then
			local viewTag = control:getcurViewTag()
			local curMiningView = control:getCurMiningView()
			if  curMiningView ~= nil and Mining:Instance():getUserId() ~= myUserId then   -- 好友的矿场
				--control:dispMiningInfoView()
				Mining:Instance():setMyMiningDataIsOk(true)
				local miningController = ControllerFactory:Instance():create(ControllerType.MINING_CONTROLLER)
				miningController:enter( Mining:Instance():getUserName(),Mining:Instance():getUserId(),false,false)    --self._friendName,self.friendId
			elseif curMiningView ~= nil and Mining:Instance():getUserId() == myUserId then
				Mining:Instance():setMyMiningDataIsOk(true)
				local miningController = ControllerFactory:Instance():create(ControllerType.MINING_CONTROLLER)
				miningController:enter( nil,nil,false,false)
				--control:dispMiningFieldView()
			end
		end
	end
end

-- 数据同步更新
function Mining:onInteractUpdateS2C(action,msgId,msg)
--	dump(msg.update,"InteractUpdateS2C")

	self:parseUpdataMsg(msg)
end


--矿主的userId
function Mining:setMineUserId(userId)
	self._userId = userId
end

function Mining:getMineUserId()
	return
	self._userId
end

-- 矿场的名字
function Mining:setMineName(ownerName)
	self._ownerName = ownerName
end

function Mining:getMineName()
	return self._ownerName
end

--获得矿场的矿位数量
function Mining:setMineCount(count)
	if count >0 or count <=8 then
		self._mineCount = count
	elseif count > 8 then
		self._mineCount = 8
	else
		assert(false)
	end
end

function Mining:getMineCount()
	return self._mineCount
end

function Mining:setReawrd(rewardCoin)
	self._rewardCoin = rewardCoin
end

function Mining:getReward()
	return self._rewardCoin
end


-- 矿场里矿坑位置信息
function Mining:setMiningPosInfo(pMsgMinerPos)

	if pMsgMinerPos.pos ~= nil then

	end

	if pMsgMinerPos.card ~= nil then
		print("card .owner",pMsgMinerPos.card.ower)
		print("card.card",pMsgMinerPos.card.card)
		print("card.miner",pMsgMinerPos.card.miners)
	end


end


function Mining:setWorkCardInfo(pMsgMinerCard)
	print("card .owner",pMsgMinerCard.card.ower)
	print("card.card",pMsgMinerCard.card.card)
	print("card.miner",pMsgMinerCard.card.miners)
end

function Mining:setMineHoleIndex(index)
	self._index = index
end

function Mining:getMineHoleIndex()
	return self._index
end


--矿位的状态
function Mining:setMineHoleStateWithIndex(index, iState) -- 矿位(默认8个矿位)的状态  1:锁住状态  2：空闲状态 3：已经有人在挖矿
	self._holeState[index] = iState
end

function Mining:getMineHoleStateWithIndex(index)
	return self._holeState[index]
end

--矿主的收益
function Mining:setMineEarnings(earnings)
	self._earnings = earnings
end

function Mining:getMineEarnings()
	return self._earnings
end

-- 卡牌的打工信息
function Mining:setCardWorkInfoWithCardConfigId(configId)
--	self._cardName =                    --卡牌名称
--	self._playerNickName =               -- 玩家姓名
--	self._workTime =                          -- 打工时间
end

function Mining:getAllCardData(curSelectedCardId)  -- Id 唯一的识别  从卡牌列表中获得 可以去打工的卡牌，如果是替换打工的卡牌 测传入被替换的卡牌ID，被替换的卡牌也显示到列表中

	print("Mining.lua<Mining:getAllCardData> curSelectedCardId: " .. curSelectedCardId)

	local allCards = GameData:Instance():getCurrentPackage():getAllCards()
	--dump(allCards,"allCard")
	self._tAllCard = {}
	local curSelectedCard
	for k,v in pairs(allCards) do
		print("v:getWorkState()",v:getId(),v:getWorkState())
		print("isExpCard====",v:getIsExpCard())
		if v:getIsOnBattle() == false and v:getWorkState() == "MINE_NONE" and v:getIsExpCard() == false then      --MINE_NONE   = 1;  MINE_NORMAL    MINE_WORK
			table.insert(self._tAllCard, v)
			v.isSelected = false
		end
		if v:getId() == curSelectedCardId then
			curSelectedCard = v
			curSelectedCard.isWorker = true

			if self._lastSelectedcardFromList == nil then
				self._lastSelectedcardFromList = v
			elseif self._lastSelectedcardFromList ~= nil and self._lastSelectedcardFromList:getId() ~= curSelectedCardId  then
				self._lastSelectedcardFromList.isWorker = false
				self._lastSelectedcardFromList = curSelectedCard
			end

		end
	end
	if curSelectedCard ~= nil and curCardConfigId ~= 0 then
		table.insert(self._tAllCard,1,curSelectedCard)
	end
	return self._tAllCard
end

function Mining:getWorkCards() -- 是MiningCard对象 获得打工中 和空闲的打工卡牌

--	dump(self._baseData,"getAllWorkCards")
	--print("Mining:getWorkCards() work card num is ",#self._baseData.card)

	self._workCards = {}
	if self._baseData ~= nil and self._baseData.card ~= nil and #self._baseData.card >0 then
		for i = 1,#self._baseData.card,1 do
			local card = MiningCard.new()
			print("config=====",self._baseData.card[i].info.config_id)
			print("state=====",self._baseData.card[i].info.state)
			card:initCardInfo(self._baseData.card[i])
			table.insert(self._workCards,card)
		end
	end
	return self._workCards
end


function Mining:getIdelWorkCards() -- Pk的时候从该数据中获得出战的卡牌     获得空闲的打工卡牌

	local workCards = self:getWorkCards()
	local pkCards = {}
	--dump(workCards,"workCards")
	for k, v in pairs(workCards) do
		if v._cardInfo:getWorkState() == "MINE_NORMAL" then
			table.insert(pkCards,v._cardInfo)
		end
	end
	return pkCards
end

function Mining:setPkTargetId(curPkTargetId)
	self._curPkTargetId = curPkTargetId
end

function Mining:getPkTargetId()
	return self._curPkTargetId
end

function Mining:setPkIsWin(isWin)
	self._isWin = isWin
end

function Mining:getPkisWin()
	return self._isWin
end

function Mining:setPkTargetCardConfigId(configId)
	self._PkTargetCardConfigId  = configId
end

function Mining:getPkTargetCardConfigId()
	return self._PkTargetCardConfigId
end

function Mining:getMyCardCount()
	return self._baseData.card_count
end

function Mining:setMyCardCount(cardCount)
	self._baseData.card_count = cardCount
end

function Mining:setMyMiningDataIsOk(dataIsOk)
	self._myMiningDataIsOk = dataIsOk
end

function Mining:getMyMiningDataIsOk()
	local dataIsOk = self._myMiningDataIsOk or false
	return dataIsOk
end

function Mining:setFriendMiningDataIsOk(dataIsOk)
	self._friendMiningDataIsOk = dataIsOk
end

function Mining:getFriendMiningDataIsOk()
	local dataIsOk = self._friendMiningDataIsOk or false
	return dataIsOk
end

function Mining:initPosAndOfficialName()
	local pos2OficialName = {}
	for i = 1, 8 do
		local tab = {}
		tab.id = i
		tab.name = AllConfig.position[i].position_name
		table.insert(pos2OficialName,tab)
	end

	local mineCardCount = AllConfig.minecardcount
	for k, v in pairs(mineCardCount) do

	end
end

function Mining:getOfficialNameWithPos(pos)
	local tabIds = {}
	local officialId
	for k, v in ipairs(AllConfig.minecardcount) do
		if v.max_card_count == pos then
			table.insert(tabIds, k)
		end
	end

	local function  TableSort(a, b)
		return  a< b
	end

	if #tabIds <= 1 then
		officialId = tabIds[1]

	elseif #tabIds > 1 then
		table.sort(tabIds,TableSort)
		officialId = tabIds[1]
	end

  local name = ""
  if officialId ~= nil then
    name = AllConfig.position[officialId].position_name
  end

  return name
end

function Mining:getRewardByTime(index)

	local workLv = self._player:getLevel()
	local minerLv = 0
	if self._friendBaseData ~= nil and self._friendBaseData.userId > 0 then
		minerLv = Friend:Instance():getFriendLvByUserId(self._friendBaseData.userId)
	end

	local time = AllConfig.mineinitdata[index].time
	local minuteTime = (time/60)  -- 单位：分钟
    local lv = math.min(workLv,minerLv) -- 取 打工者和矿主LV的最小值
	local coin = AllConfig.minecoin[lv].miner_get    -- 每分钟获得铜钱
	local loyalty = AllConfig.minecoin[lv].miner_loyalty
	local coinRate = AllConfig.mineinitdata[index].coin_rate /10000
	local loyaltyRate = AllConfig.mineinitdata[index].loyalty_rate /10000

	local retCoins =  math.floor(minuteTime*coinRate*coin)
	local retLoyalty =  math.floor(minuteTime*loyaltyRate*loyalty)
	return retCoins,retLoyalty
end


function Mining:saveMinerConfig(pare)
	self.quickWorkConfig = pare
end



function Mining:quickWork()
	dump(self.quickWorkConfig,"aaa")

	local workTime =  AllConfig.mineinitdata[self.quickWorkConfig.time].time

	local minerSortType = 0
	local workSortType = 0

--	local function TableSortForUp(a, b) -- 升序
--
--		return  a:getLevel() > b:getLevel()
--	end
--
--	local function TableSortForDown(a,b)    --降序
--		return  a:getLevel() < b:getLevel()
--	end

	if self.quickWorkConfig ~= nil then
		local tAllCard = self:getIdelWorkCards()
		if self.quickWorkConfig.workSortType == 1 then -- 升序
		--	table.sort(tAllCard,TableSortForUp)
			workSortType = "LEVEL_LIMIT"
		else
		--	table.sort(tAllCard,TableSortForDown)
			workSortType = "LEVEL_LARGE"
		end

		if self.quickWorkConfig.minerSorType == 1 then
			minerSortType = "LEVEL_LIMIT"
		else
			minerSortType = "LEVEL_LARGE"
		end

		if #tAllCard == 0 then
			Toast:showString(self, _tr("has_no_card_for_mining"), ccp(display.cx, display.cy))
		else
			--for i = 1, #tAllCard, 1 do
			--local lv = tAllCard[i]:getLevel()
			--local cardId = tAllCard[i]:getId()
			self:InteractCardTryWorkC2S(0,"STATE_WORK",0,0,workTime,minerSortType,workSortType)
			--end
		end

	end
end

function Mining:getMinerConfig()
	return self.quickWorkConfig
end

function Mining:hasNewEvent()
	local flag = GameData:Instance():checkSystemOpenCondition(3, false)
	if flag == false then 
		return false 
	end 

	local idelWorkCards = self:getIdelWorkCards()
	if idelWorkCards~= nil and #idelWorkCards >0 then
		return true
	else
		return false
	end
end


return Mining




