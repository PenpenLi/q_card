

require("model.Achievement.AchievementData")
require("view.component.Toast")

Achievement = class("Achievement")

AchievementType = enum({"Official","Comprehensive","PVE","PVP","COLLECT","VIP", "TypeMax"})


function Achievement:ctor()
	net.registMsgCallback(PbMsgId.PlayerAchievementState,self,Achievement.updateAchievementState)
	
	--刚登录时导入每一系列第一项
	if self._allAchArray == nil then  
		self._allAchArray = {}
		local item 
		for k, v in pairs(AllConfig.achievement) do 
			if v.pre_task < 0 then 
				item = AchievementData.new(v.id)
				item:setIsFinish(false)
				item:setIsAwarded(false)
				item:setAchProgress(0)
				self._allAchArray[v.id] = item 
			end 
		end 
	end 
end 

function Achievement:instance()
	if Achievement._instance == nil then
		Achievement._instance = Achievement.new()
	end

	return Achievement._instance
end

function Achievement:cleanData()
	self._allAchArray = nil 
end 

--刚登录时状态
function Achievement:initAchievementState(msgState)
	self:updateAchievementState(nil, nil, msgState, true)
end 

function Achievement:updateAchievementState(action,msgId,msg,isFromLogin)
	echo("=== updateAchievementState: point=", msg.achievement_point, isFromLogin)

	--更新成就状态
	local item 
	for k, v in pairs(msg.finished_achievement) do --已完成列表
		item = self._allAchArray[v.config_id]
		if item == nil then 
			item = AchievementData.new(v.config_id)
			self._allAchArray[v.config_id] = item 		
		end 
		item:setIsAwarded(v.is_get > 0)
		item:setIsFinish(true)
		if v.is_get > 0 then --已领取后从列表中剔除
			-- table.remove(self._allAchArray, v.config_id)
			self._allAchArray[v.config_id] = nil 
		end 

		--刚登陆或者已完成,则不再提示
		if not isFromLogin and v.is_get < 1 then 
			if self.tipsQueue == nil then 
				self.tipsQueue = {}
			end 
			table.insert(self.tipsQueue, item:getName())
			self:playAchievedTipsAnim()
		end 
	end 

	for k, v in pairs(msg.progress) do --进行中列表
		item = self._allAchArray[v.config_id]
		if item == nil then 
			item = AchievementData.new(v.config_id)
			self._allAchArray[v.config_id] = item 		
		end 
		item:setAchProgress(v.progress)
		item:setIsFinish(false)
		item:setIsAwarded(false)
		-- echo("===progressing:", item:getName(), v.config_id, v.progress, item:getAchievementType())
	end 

	self:setCurAchievementPoint(msg.achievement_point)
	self:setLastGetAwardTime(msg.last_receive_achievement_gift_time)
end

function Achievement:getAchItemById(configId)
	return self._allAchArray[configId] 
end 

function Achievement:getAllAchievement()
	return self._allAchArray or {} 
end 

function Achievement:getAchDataByType(achType)
	local tbl = {}
	
	for k, v in pairs(self:getAllAchievement()) do 
		if v:getAchievementType() == achType then 
			table.insert(tbl, v)
		end 
	end 
	self:sortAchievement(tbl)
	echo("===getAchDataByType", achType)


	local tmp = {}
	local validTbl = {}
	--每一系列进行中有多项时,只选取第一项
	for k, v in pairs(tbl) do 
		if v:getIsFinish() == true then 
			table.insert(validTbl, v)
		elseif tmp[v:getAchRootId()] == nil then 
			tmp[v:getAchRootId()] = 1
			table.insert(validTbl, v)
		end 
	end 

	return validTbl 
	--return tbl 
end 

function Achievement:sortAchievement(dataArray)
	if dataArray == nil or #dataArray < 1 then 
		return 
	end 

	local startIdx = 1 
	local endIdx = #dataArray 

	local function sortByType(tbl, idx_s, idx_e, _type)
		if idx_e <= idx_s + 1 then 
			return 
		end 

		for i=idx_s, idx_e-1 do
			local k = i
			for j=i+1, idx_e do
				local flag 
				if _type == "type_awarded" then 
					flag = (tbl[k]:getIsAwarded() == true and tbl[j]:getIsAwarded() == false)

				elseif _type == "type_finish" then  
					flag = (tbl[k]:getIsFinish() == false and tbl[j]:getIsFinish() == true)

				elseif _type == "type_id" then
					flag = (tbl[k]:getAchievementId() > tbl[j]:getAchievementId())
				end 

				if flag then 
					k = j
				end 
			end  

			if k > i then
				local tmp = tbl[k]
				tbl[k] = tbl[i]
				tbl[i] = tmp
			end
		end	
	end 

	--已完成放到最后
	sortByType(dataArray, startIdx, endIdx, "type_awarded")
	local getCount = 0 
	for i=startIdx, endIdx do 
		if dataArray[i]:getIsAwarded() then 
			getCount = getCount + 1 
		end 
	end 
	sortByType(dataArray, endIdx-getCount+1, endIdx, "type_id")

	endIdx = endIdx - getCount 

	--已完成可领取放到前面
	sortByType(dataArray, startIdx, endIdx, "type_finish")

	--sort by id 
	local preType, curType
	preType = dataArray[startIdx]:getIsFinish()
	local idx = startIdx
	for i = startIdx+1, endIdx do
		curType = dataArray[i]:getIsFinish()
		if i < endIdx then
			if curType ~= preType then
				sortByType(dataArray, idx, i-1, "type_id")      
				idx = i
				preType = curType
			end
		else
			if curType ~= preType then
				sortByType(dataArray, idx, i-1, "type_id")
			else 
				sortByType(dataArray, idx, i, "type_id")
			end 
		end 
	end 	
end 

function Achievement:setLastGetAwardTime(time)
	self._lastAwardTime = time 
end 

function Achievement:getLastGetAwardTime()
	return self._lastAwardTime or 0 
end 

function Achievement:setCurAchievementPoint(point)
	self._curAchPoint = point 
end 

function Achievement:getCurAchievementPoint()
	return self._curAchPoint or 0 
end 

function Achievement:getOfficialIdAndNameByPoint(point)	
	local positionData = AllConfig.position
	local len = #positionData 
	local curIdx = 0
	for i=1, len do 
		if toint(point) >= positionData[i].achievement_point then 
			curIdx = i 
		end 
	end 

	local info = {}
	info.curBonus = {}
	info.nextBonus = {}
	if curIdx < 1 then 
		info.officialName = _tr("none")
	else 
		local curData = positionData[curIdx]
		info.officialName = curData.position_name 

		for k, v in pairs(curData.bonus) do
			table.insert(info.curBonus, v.array)			
		end 
	end 

	local nexData = positionData[math.min(len, curIdx+1)]
	info.nextOfficialName = nexData.position_name 
	info.nextPoint = nexData.achievement_point 	

	for k, v in pairs(nexData.bonus) do
		table.insert(info.nextBonus, v.array)			
	end 

	return info
end

function Achievement:getOfficialName()
	local point = self:getCurAchievementPoint()
	local positionData = AllConfig.position

	local len = #positionData 
	local curIdx = 0 
	for i=1, len do 
		if toint(point) >= positionData[i].achievement_point then 
			curIdx = i 
		end 
	end 

	if curIdx < 1 then 
		return _tr("none")
	end 

	return positionData[curIdx].position_name
end

function Achievement:hasNewEvent(achType)
	if GameData:Instance():checkSystemOpenCondition(39, false) == false then 
		return false 
	end 

	--官职
	if GameData:Instance():checkSystemOpenCondition(17, false) == true then
		-- local lastReceiveTime = self:getLastGetAwardTime() 
		-- local curTime = Clock:Instance():getCurServerUtcTime() 
		-- local preDate = os.date("!*t", lastReceiveTime) 
		-- local curDate = os.date("!*t", curTime) 
		-- echo("===preDate.day, curDate.day", preDate.day, curDate.day)
		-- if preDate.day ~= curDate.day then 
		-- 	if achType == nil or achType == AchievementType.Official then 
		-- 		return true 
		-- 	end 
		-- end 

		if achType == nil or achType == AchievementType.Official then 
			local lastReceiveTime = self:getLastGetAwardTime()
			local curTime = Clock:Instance():getCurServerUtcTime() 
			local time = toint(os.date("%H",lastReceiveTime))*3600+ toint(os.date("%M",lastReceiveTime))*60+toint(os.date("%S",lastReceiveTime))
			local DIFTimes = curTime - lastReceiveTime 
			echo("=== time gap:", time + DIFTimes)
			if time + DIFTimes > 86400 then 
				return true 
			end 
		end 
	end 

	--其他成就
	for k, v in pairs(self:getAllAchievement()) do 
		if v:getIsFinish() and v:getIsAwarded() == false then 
			if achType == nil or achType == v:getAchievementType() then 
				return true 
			end 
		end 
	end 

	return false 
end 

function Achievement:checkEntryCondition(achType)
	if GameData:Instance():checkSystemOpenCondition(39, false) == false then --成就总开关
		return false 
	end 

	if achType == AchievementType.Official then 
		return GameData:Instance():checkSystemOpenCondition(17, false)
	end 

	return true 
end 

function Achievement:handleErrorCode(errorCode)
	local curScene = GameData:Instance():getCurrentScene()

	if errorCode == "HasReceived" then
		Toast:showString(curScene, _tr("It_is_to_receive_ach_point"), ccp(display.cx, display.cy))

	elseif errorCode == "NeedPoint" then
		Toast:showString(curScene, _tr("Achievement_points_is_not_enough_can't_get"), ccp(display.cx, display.cy))
	else 
		Toast:showString(curScene, _tr("system error"), ccp(display.cx, display.cy))
	end 
end 


function Achievement:playAchievedAnim(tipStr)
	local str
	if GameData:Instance():getLanguageType() == LanguageType.JPN then 
		str = tipStr.._tr("congratulations_to_obtain")
	else 
		str = _tr("congratulations_to_obtain")..tipStr
	end 
	
	local  label = CCLabelTTF:create(str,"Courier-Bold",24)
	label:setColor(ccc3(255,252,0))
	label:setAnchorPoint(ccp(0.5,0.5))
	label:setPosition(ccp(display.cx,display.cy))
	local curScene = GameData:Instance():getCurrentScene()
	local popupNode = curScene:getChildByTag(POPUP_NODE_ZORDER)
	if popupNode == nil then
		popupNode = display.newNode()
		curScene:addChild(popupNode,POPUP_NODE_ZORDER,POPUP_NODE_ZORDER)
	end

	local node = display.newNode()
	node:setPosition(ccp(label:getPositionX() - label:getContentSize().width/2.0 ,display.cy ))
	node:setCascadeOpacityEnabled(true)

	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("img/common/common.plist","img/common/common.png")

	local bgBar = display.newSprite("#common_top_bottom_glod_block.png")
	bgBar:setPosition(ccp(display.cx,display.cy))
	popupNode:addChild(bgBar)
	popupNode:addChild(label)
	popupNode:addChild(node)

	local array1 = CCArray:create()
	array1:addObject(CCDelayTime:create(2.5))
	array1:addObject(CCCallFunc:create(function() bgBar:removeFromParentAndCleanup(true) end))
	array1:addObject(CCRemoveSelf:create())
	label:runAction(CCSequence:create(array1))

	local particle,offsetX,offsetY,duration = _res(6010004)
	particle:setPosition(ccp(offsetX,offsetY))
	node:addChild(particle)

	local time = 1.0
	local fadeOut = CCEaseOut:create(CCFadeOut:create(time),2)
	local move = CCEaseOut:create(CCMoveBy:create(time,ccp(label:getContentSize().width,0)),1.5)
	local spawn = CCSpawn:createWithTwoActions(fadeOut,move)
	local array = CCArray:create()
	array:addObject(spawn)
	array:addObject(CCRemoveSelf:create())
	node:runAction(CCSequence:create(array))
end

function Achievement:playAchievedTipsAnim()
	-- local node = display.newNode()
	-- GameData:Instance():getCurrentScene():addChild(node)
	-- local array = CCArray:create()
	-- array:addObject(CCDelayTime:create(delay or 0.1))
	-- array:addObject(CCCallFunc:create(function() self:playAchievedAnim(str) end))
	-- array:addObject(CCRemoveSelf:create())
	-- node:runAction(CCSequence:create(array))

	local function popFinishedAchId()
		if self.tipsQueue ~= nil and #self.tipsQueue > 0 and ControllerFactory:Instance():getCurrentControllerType()~=ControllerType.BATTLE_CONTROLLER then
			self:playAchievedAnim(self.tipsQueue[1])
			table.remove(self.tipsQueue, 1)
		else 
			if self.scheduler ~= nil then 
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduler)
				self.scheduler = nil 
			end 
		end
	end

	if self.scheduler ~= nil then 
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduler)
		self.scheduler = nil 
	end 
	self.scheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(popFinishedAchId, 3.0, false)
end 
