require("model.Player") 
require("model.Account")
require("model.CardPropertyDef") 
require("model.Card")
--require("framework.utility.time")
require("model.Package")
require("model.Friend")
require("model.expedition.Expedition")
require("common.Consts")
require("model.notice.Notice")
require("model.guide.Guide")
require("model.mail.MailBox")
require("model.talent.TalentData")
require("model.chat.Chat")
require("model.guild.Guild")
require("model.battle_report.BattleReportShare")

LanguageType = enum({"ZHCN", "BIG5", "JPN"})

GameData = class("GameData")

GameData._Instance = nil


function GameData:Instance() 
	if GameData._Instance == nil then
		GameData._Instance = GameData.new()
	end
	return GameData._Instance
end

function GameData:init() 
	self:setInitSysComplete(false)
	--self:initNetConfig()
	self:initNetConfigWithJsonData()
	MailBox:instance()
	Liveness:instance()
	ActivityStages:Instance()
	TalentData:Instance()
	self:initNotification2()
	Arena:Instance()
	EquipmentReinforce:Instance()
	Achievement:instance()
	Guild:Instance()
	Chat:Instance()
	BattleReportShare:Instance()
	
	local account = Account.new()
	-- TODO load from a valid path
	account:loadFromFile()
	self:setCurrentAccount(account)
	
	local notice = Notice.new()
	self:setNoticeInstance(notice)

	self.wklk = false
	self:WakeLockRadioBtnCallBack()
end

------
--  Getter & Setter for
--      GameData._NoticeInstance 
-----
function GameData:setNoticeInstance(NoticeInstance)
	self._NoticeInstance = NoticeInstance
end

function GameData:getNoticeInstance()
	return self._NoticeInstance
end

--------
----  Getter & Setter for
----      GameData._EnabledActiveTipDisconnect 
-------
--function GameData:setEnabledActiveTipDisconnect(EnabledActiveTipDisconnect)
--	self._EnabledActiveTipDisconnect = EnabledActiveTipDisconnect
--end
--
--function GameData:getEnabledActiveTipDisconnect()
--	return self._EnabledActiveTipDisconnect
--end
--
--
------
--  Getter & Setter for
--      GameData._currentScene 
-----
function GameData:setCurrentScene(currentScene)
	self._currentScene = currentScene
end

function GameData:getCurrentScene()
	return self._currentScene
end

------
--  Getter & Setter for
--      GameData._CurrentPlayer 
-----
function GameData:setCurrentPlayer(CurrentPlayer)
	self._CurrentPlayer = CurrentPlayer
end

function GameData:getCurrentPlayer()
	return self._CurrentPlayer
end

function GameData:playDubbingByCard(card)
  
	if card == nil then
		 return
	end
	
	local randomDubbingId = card:getRandomDubbing()
	--print("randomDubbingId:",randomDubbingId)
	if randomDubbingId ~= 0 then
		 if self._m_nSoundId ~= nil then
				SoundManager.stopEffect(self._m_nSoundId)
				self._m_nSoundId = nil
		 end
		 self._m_nSoundId = SoundManager.playEffect("img/"..AllConfig.sounds[randomDubbingId].sounds_path)
	end
end

------
--  Getter & Setter for
--      GameData._CurrentAccount 
-----
function GameData:setCurrentAccount(CurrentAccount)
	self._CurrentAccount = CurrentAccount
end

function GameData:getCurrentAccount()
	return self._CurrentAccount
end

function GameData:setExpeditionInstance(ExpeditionInstance)
	self._ExpeditionInstance = ExpeditionInstance
end

function GameData:getExpeditionInstance()
	return self._ExpeditionInstance
end
------
--  Getter & Setter for
--      GameData._currentPackage 
-----
function GameData:setCurrentPackage(currentPackage)
	self._currentPackage = currentPackage
end


function GameData:getCurrentPackage()
	return self._currentPackage
end

function GameData:setAskForDrawTenCardInformationResultOfKey(key)
	self._key = key
end

function GameData:getAskForDrawTenCardInformationResultOfKey()
	return self._key
end

function GameData:setAskForDrawTenCardInformationResultOfData(msg)
	self._LotteryNoticeTable =  {}
	for i=1 ,#msg.card,1 do
		local nickName = msg.card[i].nick_name
		local drawActionTime = msg.card[i].draw_action_time
		local cardConfigId  = msg.card[i].card_config_id
		local time = os.date("%Y/%m/%d/ %X",drawActionTime)
		local  LotteryNotice = {}
		LotteryNotice["nickName"] = nickName
		LotteryNotice["cardConfigId"] = cardConfigId
		LotteryNotice["time"] = time
		table.insert(self._LotteryNoticeTable,LotteryNotice)
	end
	--test
	--print("------------self._LotteryNoticeTable[]",self._LotteryNoticeTable[1]["nickName"],self._LotteryNoticeTable[1]["time"])
end

function GameData:getAskForDrawTenCardInformationResultOfData()
	return self._LotteryNoticeTable
end

function GameData:setLastRefreshTime(lastRefreshTime)
	self._lastRefreshTime = lastRefreshTime
end

function GameData:getLastRefreshTime()
		return self._lastRefreshTime
end

function GameData:setLastRefreshTimeForSoul(lastRefreshTime)
		self._lastRefreshTimeForSoul = lastRefreshTime
end

function GameData:getLastRefreshTimeForSoul()
		return self._lastRefreshTimeForSoul
end

function GameData:getOnlineBonusArray()

	if self.onlineBonus == nil then
		self.onlineBonus = {}
		local dropItem
		local level = GameData:Instance():getCurrentPlayer():getLevel()

		for i=1, table.getn(AllConfig.signupbonus) do 
			if AllConfig.signupbonus[i].type == 3 then 
				local tbl = {}

        for m, dropId in pairs(AllConfig.signupbonus[i].bonus) do 
        	dropItem = AllConfig.drop[dropId] 
        	if level >= dropItem.min_level and level <= dropItem.max_level then 
						for k, v in pairs(dropItem.drop_data) do
							v = v.array

							local bonusItem = {}
							if v[1] == 1 or v[1] == 2 or v[1] == 3 then  -- player/card/skill exp
								bonusItem = {iType = 88, configId = nil, iconId = 3059022, count = v[3]}
							elseif v[1] == 4 then --coin
								bonusItem = {iType = 88, configId = nil, iconId = 3050050, count = v[3]}
							elseif v[1] == 5 then --money
								bonusItem = {iType = 88, configId = nil, iconId = 3050049, count = v[3]}
							elseif v[1] >= 6 and v[1] <= 8 then 
								bonusItem = {iType = v[1], configId = v[2], iconId = nil, count = v[3]}	
							elseif v[1] == 12 then --token
								bonusItem = {iType = 88, configId = nil, iconId = 3050003, count = v[3]}
							end

							table.insert(tbl, bonusItem)
						end
					end 
        end 

				local tmp = {time = AllConfig.signupbonus[i].condition, bonus = tbl}
				table.insert(self.onlineBonus, tmp)
			end 
		end
	end

	return self.onlineBonus
end

function GameData:initNetConfig()
	echo("---initNetConfig()---")
	self.serverArray = require("config.NetConfig")
	for k, v in pairs(self.serverArray) do
		if v.status == _tr("recommend") then
			v.stateCode = 1
			v.color = ccc3(0,252,255)
		elseif v.status == _tr("busy") then
			v.stateCode = 2
			v.color = ccc3(255,0,0)
		elseif v.status == _tr("maintain") then
			v.stateCode = 3
			v.color = ccc3(144,144,144)
		end
	end

	--sort by status
	local totalLen = table.getn(self.serverArray)
	for i=1, totalLen-1 do
		local k = i
		for j=i+1, totalLen do
			if self.serverArray[k].stateCode < self.serverArray[j].stateCode then
				k = j
			end
		end

		if k > i then
			local tmp = self.serverArray[k]
			self.serverArray[k] = self.serverArray[i]
			self.serverArray[i] = tmp
		end
	end

	local index = totalLen
	local area = CCUserDefault:sharedUserDefault():getIntegerForKey("user_net_prefer")
	echo("get perfer net server area =", area)
	if area ~= nil then
		for i=1, totalLen do
			if self.serverArray[i].area == area then
				index = i
				break
			end
		end
	end
	self:setCurNetItem(self.serverArray[index])
end



function GameData:initNetConfigWithJsonData()
	echo("---initNetConfig()---")

	--local json = require("framework.json")
	local path = CCFileUtils:sharedFileUtils():fullPathForFilename("version")
	print("path",path)
	local str = io.readfile(path)
	print(type(str))
	local jsonData = JSON.decode(str)
	self.serverArray = jsonData.netConfig --require("config.NetConfig")
	for k, v in pairs(self.serverArray) do
		if v.status == "recommend" then
			v.status = _tr("recommend")
			v.stateCode = 1
			v.color = ccc3(84,238,0)
		elseif v.status == "idle" then
			v.status = _tr("idle")
			v.stateCode = 2
			v.color = ccc3(84,238,0)
				elseif v.status == "busy" then
					v.status = _tr("busy")
					v.stateCode = 2
					v.color = ccc3(255,210,0)
				elseif v.status == "maintain" then
					v.status = _tr("maintain")
					v.stateCode = 3
					v.color = ccc3(178,178,178)       
				end
			v.name = _tr(v.name)
				v.area = tonumber(v.area)
	end

	--sort by status
	local totalLen = table.getn(self.serverArray)
	print("totalLen",totalLen)
	for i=1, totalLen-1 do
		local k = i
		for j=i+1, totalLen do
			if self.serverArray[k].stateCode < self.serverArray[j].stateCode then
				k = j
			end
		end

		if k > i then
			local tmp = self.serverArray[k]
			self.serverArray[k] = self.serverArray[i]
			self.serverArray[i] = tmp
		end
	end

	local function sortByArea(tbl, startIdx, endIdx)
		for i=startIdx, endIdx-1 do 
			local k = i 
			for j=i+1, endIdx do 
				if tbl[k].area < tbl[j].area then 
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

	--sort by area for same status
	local preStatus = self.serverArray[1].stateCode
	local startIdx = 1
	for i = 2, totalLen do
		local curStatus = self.serverArray[i].stateCode
		if i < totalLen then 
			if curStatus ~= preStatus then 
				sortByArea(self.serverArray, startIdx, i-1)

				startIdx = i
				preStatus = curStatus
			end
		else 
			if curStatus ~= preStatus then 
				sortByArea(self.serverArray, startIdx, i-1)
			else
				sortByArea(self.serverArray, startIdx, i)
			end
		end
	end

	--save selected item 
	local index = totalLen
	local area = CCUserDefault:sharedUserDefault():getIntegerForKey("user_net_prefer")
	echo("get perfer net server area =", area)
	if area ~= nil then
		for i=1, totalLen do
			if self.serverArray[i].area == area then
				index = i
				break
			end
		end
	end
	self:setCurNetItem(self.serverArray[index])
	self:setLastNetItem(self.serverArray[index])
end

function GameData:setCurNetItem(item)
	self._netItem = item
end 

function GameData:getCurNetItem()
	return self._netItem
end

------
--  Getter & Setter for
--      GameData._LastNetItem 
-----
function GameData:setLastNetItem(LastNetItem)
	self._LastNetItem = LastNetItem
end

function GameData:getLastNetItem()
	return self._LastNetItem
end

function GameData:getNetServerArray()
	return self.serverArray
end

function GameData:setHomeHeaderVisible(isVisible)
	self._headersVisible = isVisible
end 

function GameData:getHomeHeaderVisible()
	if self._headersVisible == nil then 
		self._headersVisible = true
	end
	return self._headersVisible
end 

local function getSkillAttrData(cardData,skillId,isReturnNextVal, levelsOffset)

	--[[
	n1 普通攻击
	n2 力量
	n3 智力
	n4 统帅
	n5 生命
	--]]

	echo("===skillId, isReturnNextVal", skillId, isReturnNextVal)
	local curLevel = cardData:getSkill():getLevel() 
	local maxLevel = cardData:getSkill():getMaxLevel() 
	local skillFixId = (AllConfig.cardskill[skillId].card_value_rank+1)*1000 + curLevel 
	if isReturnNextVal == true then 
		if levelsOffset ~= nil and levelsOffset > 0 then 
			skillFixId = skillFixId + math.min(levelsOffset, maxLevel-curLevel)
		elseif curLevel < maxLevel then 
			skillFixId = skillFixId + 1 
		end 
	end 

	local n1 = AllConfig.cardskillfix[skillFixId].fix_value 
	local n2 = cardData:getAttack()
	local n3 = cardData:getHp() 
	local n4 = 0 
	local n5 = 0 

	local function formatStrData(strData)
		if strData == nil or strData == ""then
			return 0
		end
		local str = strData
		for j = 1,5,1 do
			str = string.gsub(str, "n"..j, "%%d")
		end
		local tmpData = string.format(str,n1,n2,n3,n4,n5)
		local script = "return "..tmpData
		local data= loadstring(script)()
		return data
	end
	local strData1 = AllConfig.cardskill[skillId].d1
	local strData2 = AllConfig.cardskill[skillId].d2
	local strData3 = AllConfig.cardskill[skillId].d3

	local data1 = math.floor(formatStrData(strData1)/10000)
	local data2 = math.floor(formatStrData(strData2)/10000)
	local data3 = math.floor(formatStrData(strData3)/10000)

	return data1,data2,data3
end

function GameData:formatSkillDesc(cardData,isShowNextAttrOrTalentNextCardData,isTalent, levelsOffset)
	local function safeString(s)
		return string.gsub(s.."", "%%", "%%%%")
	end

	if (isTalent) then
		if (cardData.skill_type == 4 or cardData.skill_type == 5)  then
			local skillStr  =cardData.skill_description
			if(isShowNextAttrOrTalentNextCardData) then
				local nextData = isShowNextAttrOrTalentNextCardData
				skillStr = string.gsub(skillStr,"%%d1",safeString(cardData.d1).."<color><value>190956</>("..safeString(nextData.d1)..")</>")
				skillStr = string.gsub(skillStr,"%%d2",safeString(cardData.d2).."<color><value>191956</>("..safeString(nextData.d2)..")</>")
				skillStr = string.gsub(skillStr,"%%d3",safeString(cardData.d3).."<color><value>190956</>("..safeString(nextData.d3)..")</>")
			else
			  local d1 = safeString(cardData.d1)
			  local d2 = safeString(cardData.d2)
			  local d3 = safeString(cardData.d3)
				skillStr = string.gsub(skillStr,"%%d1",d1)
				skillStr = string.gsub(skillStr,"%%d2",d2)
				skillStr = string.gsub(skillStr,"%%d3",d3)
			end
			return skillStr
		else
			local card = Card.new()
			card:initAttrById(cardData.id)
			cardData = card
		end
	end

	local configId = cardData:getConfigId()
	local skillCurLv = cardData:getSkill():getLevel()
	local skillId =  AllConfig.unit[configId].skill
	local skillStr = AllConfig.cardskill[skillId].skill_description
	local data1,data2,data3
	if isShowNextAttrOrTalentNextCardData == nil or isShowNextAttrOrTalentNextCardData == false then
		data1,data2,data3 = getSkillAttrData(cardData, skillId, false)
		skillStr = string.gsub(skillStr,"%%d1",data1.."")
		skillStr = string.gsub(skillStr,"%%d2",data2 .."")
		skillStr = string.gsub(skillStr,"%%d3",data3.."")

	elseif isShowNextAttrOrTalentNextCardData ~= nil and isShowNextAttrOrTalentNextCardData == true and levelsOffset == nil then
		data1,data2,data3 = getSkillAttrData(cardData, skillId, true)
		skillStr = string.gsub(skillStr,"%%d1",data1.."")
		skillStr = string.gsub(skillStr,"%%d2",data2 .."")
		skillStr = string.gsub(skillStr,"%%d3",data3.."")		
	elseif isShowNextAttrOrTalentNextCardData ~= nil and isShowNextAttrOrTalentNextCardData == true and levelsOffset ~= nil then
		data1,data2,data3 = getSkillAttrData(cardData, skillId, false)
		local nextData1,nextData2,nextData3 = getSkillAttrData(cardData, skillId, true, levelsOffset)
		skillStr = string.gsub(skillStr,"%%d1",data1.."<color><value>190956</>("..nextData1..")</>")
		skillStr = string.gsub(skillStr,"%%d2",data2.."<color><value>191956</>("..nextData2..")</>")
		skillStr = string.gsub(skillStr,"%%d3",data3.."<color><value>190956</>("..nextData3..")</>")
	end

	return  skillStr
end

function GameData:formatSkillDescExt(configId, skillLevel, atk, hp)
	local skillId =  AllConfig.unit[configId].skill
	local skillStr = AllConfig.cardskill[skillId].skill_description	
	local skillFixId = (AllConfig.cardskill[skillId].card_value_rank+1)*1000 + skillLevel 

	local n1 = AllConfig.cardskillfix[skillFixId].fix_value 
	local n2 = atk
	local n3 = hp
	local n4 = 0 
	local n5 = 0 

	local function formatStrData(strData)
		if strData == nil or strData == ""then
			return 0
		end
		local str = strData
		for j = 1,5,1 do
			str = string.gsub(str, "n"..j, "%%d")
		end
		local tmpData = string.format(str,n1,n2,n3,n4,n5)
		local script = "return "..tmpData
		local data= loadstring(script)()
		return data
	end
	local strData1 = AllConfig.cardskill[skillId].d1
	local strData2 = AllConfig.cardskill[skillId].d2
	local strData3 = AllConfig.cardskill[skillId].d3

	local data1 = math.floor(formatStrData(strData1)/10000)
	local data2 = math.floor(formatStrData(strData2)/10000)
	local data3 = math.floor(formatStrData(strData3)/10000)

	-- return data1,data2,data3
	local skillStr = string.gsub(skillStr,"%%d1",data1.."")
	skillStr = string.gsub(skillStr,"%%d2",data2 .."")
	skillStr = string.gsub(skillStr,"%%d3",data3.."")

	return skillStr
end 


function GameData:setInitSysComplete(isInitOk)
	self._initSysOk = isInitOk

	if isInitOk then 
		Quest:Instance():reFreshTaskState()
	end 
end

function GameData:getInitSysComplete()
	return self._initSysOk
end

function GameData:initNotification()
		local targetPlatform = CCApplication:sharedApplication():getTargetPlatform()
	--if kTargetIphone == targetPlatform or kTargetIpad == targetPlatform then
				local path =  CCFileUtils:sharedFileUtils():fullPathForFilename("pushNotification")
			print("path",path)
			local str = io.readfile(path)
				if str == nil then
						print("file open error~")
						return 
				end
 
				local function formatTime(time) 
						time = time *60
						local hour = 0
						local min  = 0
						local sec  = 0
						if time >0 then
								hour = math.floor(time/3600)
								min = math.floor((time - hour * 3600) / 60)
								sec = math.floor((time - hour * 3600)%60)
						end
						local str = string.format("%02d:%02d:%02d", hour,min,sec)
						return str
				end

				local json2LuaData = cjson.decode(str)
				print(type(json2LuaData))
				local unlockBossTime = json2LuaData.unlockBossTime

				local bossOpentime = Activity:instance():getBossOpenTime()
				unlockBossTime[1].time = formatTime(bossOpentime[1])
				unlockBossTime[2].time = formatTime(bossOpentime[2])

				local eatPatty = json2LuaData.spiritTime
				local eatPattyTime1 = Activity:instance():getEatPattyTime(1)
				local eatPattyTime2 = Activity:instance():getEatPattyTime(3)
				eatPatty[1].time = formatTime(eatPattyTime1)
				eatPatty[2].time = formatTime(eatPattyTime2)

				dump("aaaa",json2LuaData)
				local jsonData = cjson.encode(json2LuaData)
				io.writefile(path,jsonData)
	--  end
end

function GameData:initNotification2()
	local targetPlatform = CCApplication:sharedApplication():getTargetPlatform()
	if kTargetIphone == targetPlatform or kTargetIpad == targetPlatform then

		local function formatTime(time)
			time = time *60
			local hour = 0
			local min  = 0
			local sec  = 0
			if time >0 then
				hour = math.floor(time/3600)
				min = math.floor((time - hour * 3600) / 60)
				sec = math.floor((time - hour * 3600)%60)
			end
			local str = string.format("%02d:%02d:%02d", hour,min,sec)
			return str
		end

		self._noticeTime = {}
		local unlockBoss = {}
		local eatPatty = {}

		local bossOpentime = Activity:instance():getBossOpenTime()

		for i = 1, 2, 1 do
			local obejct = {}
			obejct.time = formatTime(bossOpentime[i])
			obejct.content = _tr("now_is_boss_time")
			table.insert(unlockBoss,obejct)
		end

		for i = 1, 2, 1 do
			local object = {}
			local time = Activity:instance():getEatPattyTime(i*2-1)
			object.time = formatTime(time)
			object.content = _tr("now_is_eat_party_time")
			table.insert(eatPatty,object)
		end

		self._noticeTime["boss"] = unlockBoss
		self._noticeTime["eatPatty"] = eatPatty
	end
end

function GameData:setNotifice()
	print("SET_NOTIFICE_EVENT")
	local target = GameData:Instance();
	if target._noticeTime == nil then
		return
	end
	local targetPlatform = CCApplication:sharedApplication():getTargetPlatform()
	if kTargetIphone == targetPlatform or kTargetIpad == targetPlatform then

		local bossEvent = target._noticeTime["boss"]
		local eatPatty = target._noticeTime["eatPatty"]
		for k, v in pairs(bossEvent) do
			local time = v.time
			local content = v.content
			local btnText = ""
			print(time,content)
			DSNotificationManager:addNotification(content, btnText, time, true);
		end

		for k, v in pairs(eatPatty) do

			local time = v.time
			local content = v.content
			local btnText = ""
			print("time,content",time,content)
			DSNotificationManager:addNotification(content, btnText, time, true);
		end
	end
end

function GameData:WakeLockRadioBtnCallBack()
	if device.platform == "android" then
		if self.wklk == false then
			self:openWakeLock()
			self.wklk = true
		else
			self:closeWakeLock()
			self.wklk = false
		end
	end
end

function GameData:getWakeLockState()
	return self.wklk  -- false：有锁屏（默认是有系统锁屏） true： 没有锁屏，常亮的状态
end

function GameData:setWakeLockState(state)
	self.wklk = state
end

function GameData:openWakeLock()
	if device.platform == "android" then
	  local luaj = require("framework.javabridge")
		-- call Java method
		local javaClassName = "com/dst/sanguocard/SanguoCardMain"
		local javaMethodName = "openWakeLock"
		local javaParams = ""
		local javaMethodSig = "()V"
		luaj.callStaticMethod(javaClassName, javaMethodName,javaParams, javaMethodSig)
	end
end

function GameData:closeWakeLock()
	if device.platform == "android" then
	  local luaj = require("framework.javabridge") 
		-- call Java method
		local javaClassName = "com/dst/sanguocard/SanguoCardMain"
		local javaMethodName = "closeWakeLock"
		local javaParams = ""
		local javaMethodSig = "()V"
		luaj.callStaticMethod(javaClassName, javaMethodName,javaParams, javaMethodSig)
	end
end

function GameData:pushViewType(viewType, data)
	echo(" === pushViewType:", viewType)

	--无返回按钮情况下需清空栈
	if self._viewType == nil or viewType == ViewType.home then 
		self._viewType = {}
		self.curView = nil 
	end 

	
	--pop 情况下返回
	if self.curView ~= nil and self.curView[1] == viewType then 
		echo("is pop view, update newest data")
		self.curView = {viewType, data}
		return 
	end 

	--如果已经存在，则栈中该项后面的数据均丢弃
	local hasPush = false 
	local len = #self._viewType
	for i=1, len do 
		if self._viewType[i][1] == viewType then 
			hasPush = true 
			self.curView = {viewType, data} --以最新的数据替换原有的数据			
			for j=i, len do 
				self._viewType[j] = nil 
			end 
			echo("=== dump invalid views...")
			return  
		end 
	end 

	--将pre view入栈
	self._viewType[len+1] = self.curView
	--保存当前view
	self.curView = {viewType, data}
	dump(self._viewType, "@@@ pushViewType")
end 

function GameData:popViewType()
	local len = #self._viewType
	-- dump(self._viewType, "pop self._viewType")
	if len > 0 then 
		self.curView = self._viewType[len]
		self._viewType[len] = nil 
	else 
		self.curView = {ViewType.home, nil}
	end 

	echo("popViewType:", self.curView[1])
	return self.curView
end 

function GameData:resetViewType()
	echo("=== GameData:resetViewType")
	self._viewType = {}
	self.curView = nil 	
end 

function GameData:gotoPreView()

	local preview = self:popViewType()
	local viewType = preview[1]
	local viewData = preview[2]

	echo("=== GameData:gotoPreView:", viewType, viewData)

	local controller = nil 
	if viewType ~= nil then 
		if viewType == ViewType.quest then --任务
			controller = ControllerFactory:Instance():create(ControllerType.QUEST_CONTROLLER)
			controller:enter()
			if viewData == 1 then 
				controller:gotoDailyTask() 
			end 

		elseif viewType == ViewType.liveness then --活跃度
			controller = ControllerFactory:Instance():create(ControllerType.HOME_CONTROLLER)
			controller:setLivenessShowFlag(true)
			controller:enter()

		elseif viewType == ViewType.act_mission then --7天开服活动
			controller = ControllerFactory:Instance():create(ControllerType.HOME_CONTROLLER)
			controller:setActMissionShowFlag(true)
			controller:enter()

		elseif viewType == ViewType.playstate then --上阵
			local controller  = ControllerFactory:Instance():create(ControllerType.PLAY_STATES_CONTROLLER)
			controller:enterInfoView(viewData[1], viewData[2]) --直接进详细信息界面

		elseif viewType == ViewType.mine then --矿场
			controller = ControllerFactory:Instance():create(ControllerType.MINING_CONTROLLER)
			controller:enter(nil,nil,false,false) -- 返回到我的矿场信息界面

		elseif viewType == ViewType.friend or viewType == ViewType.friend_mining then --好友
			controller = ControllerFactory:Instance():create(ControllerType.FRIEND_CONTROLLER)
			controller:enter()

		elseif viewType == ViewType.enhance_levelup then --升级
			-- local levelUpController = ControllerFactory:Instance():create(ControllerType.LEVELUP_CONTROLLER)
			-- levelUpController:enter(1,viewData)   

		elseif viewType == ViewType.enhance_surmount then --转生
			local levelUpController = ControllerFactory:Instance():create(ControllerType.LEVELUP_CONTROLLER)
			levelUpController:enter(2,viewData)  

		elseif viewType == ViewType.enhance_dismantle then --熔炼
			-- local levelUpController = ControllerFactory:Instance():create(ControllerType.LEVELUP_CONTROLLER)
			-- levelUpController:enter(3)   

		elseif viewType == ViewType.enhance_skillup then --修行
			local levelUpController = ControllerFactory:Instance():create(ControllerType.LEVELUP_CONTROLLER)
			levelUpController:enter(4,viewData)

		elseif viewType == ViewType.bag then --行囊
			local controller = ControllerFactory:Instance():create(ControllerType.BAG_CONTROLLER)
			controller:enter(viewData)  

		elseif viewType == ViewType.card_bag then --中军帐
			local controller =  ControllerFactory:Instance():create(ControllerType.CARDBAG_CONTROLLER)
			controller:enter(viewData)
		
		elseif viewType == ViewType.shop then --商城
			controller = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
			controller:enter(viewData) 

		elseif viewType == ViewType.lianhun then --炼魂
			local controller = ControllerFactory:Instance():create(ControllerType.CARD_SOUL_CONTROLLER)
			controller:enter(viewData)
		
		elseif viewType == ViewType.activity then --活动
			Activity:instance():entryActView(viewData[1], viewData[2])

		elseif viewType == ViewType.scenario then --战役副本
			local stage = Scenario:Instance():getLastNormalStage()
			local controller = ControllerFactory:Instance():create(ControllerType.SCENARIO_CONTROLLER)
			controller:enter()
			controller:gotoStageById(stage:getStageId())			

		elseif viewType == ViewType.activity_stage then --剑阁 
			local controller = ControllerFactory:Instance():create(ControllerType.ACTIVITY_STAGE_CONTROLLER)
			controller:enter() 
			
		elseif viewType == ViewType.achievement then --成就
			local controller = ControllerFactory:Instance():create(ControllerType.ACHIEVEMENT_CONTROLLER)
			controller:enter(viewData)

		elseif viewType == ViewType.lottery then --抽卡
			local controller = ControllerFactory:Instance():create(ControllerType.LOTTERY_CONTROLLER)
			controller:enter()

		elseif viewType == ViewType.home then --首页
			controller = ControllerFactory:Instance():create(ControllerType.HOME_CONTROLLER)
			if viewData == true then 
				controller:setLivenessShowFlag(true)
			end 
			controller:enter(viewData)

		elseif viewType == ViewType.rank_match then --竞技场
			local controller = ControllerFactory:Instance():create(ControllerType.PVP_RANK_MATCH_CONTROLLER)
			controller:enter()

		elseif viewType == ViewType.expedition then --征战
			local controller = ControllerFactory:Instance():create(ControllerType.EXPEDITION_CONTROLLER)
			controller:enter()

		elseif viewType == ViewType.bable then --通天塔
			local controller = ControllerFactory:Instance():create(ControllerType.BABEL_CONTROLLER)
			controller:enter()  

		else 
			controller = ControllerFactory:Instance():create(ControllerType.HOME_CONTROLLER)
			controller:enter()      
		end 
	else 
		controller = ControllerFactory:Instance():create(ControllerType.HOME_CONTROLLER)
		controller:enter()  
	end
end 

function GameData:gotoViewByJumpType(_type, value)

	echo("===gotoViewByJumpType:", _type, value)

	if _type == -1 then --元宝消费
		if self:checkSystemOpenCondition(15, true) == false then 
      return 
    end   
    local controller = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
    controller:enter(ShopCurViewType.DianCang)

	elseif _type == 1 then --关卡
		if value == -1 then --跳到当前最新关卡
			local stage = Scenario:Instance():getLastNormalStage()
			local controller = ControllerFactory:Instance():create(ControllerType.SCENARIO_CONTROLLER)
			controller:enter()
			controller:gotoStageById(stage:getStageId())			
		else 
			local controller = ControllerFactory:Instance():create(ControllerType.SCENARIO_CONTROLLER)
			controller:enter()
			controller:gotoChapterById(value)
			-- controller:gotoStageById(value,true)
		end 

	elseif _type == 2 then -- 不做任何处理

	elseif _type == 3 then --升级
		local controller = ControllerFactory:Instance():create(ControllerType.BAG_CONTROLLER)
		controller:enter()  

	elseif _type == 4 then --征战
		if self:checkSystemOpenCondition(4, true) == false then 
			return 
		end 
		local controller = ControllerFactory:Instance():create(ControllerType.EXPEDITION_CONTROLLER)
		controller:enter()

	elseif _type == 5 then --抽卡
		local controller = ControllerFactory:Instance():create(ControllerType.LOTTERY_CONTROLLER)
		controller:enter()

	elseif _type == 6 then --典藏
		if self:checkSystemOpenCondition(15, true) == false then 
			return 
		end 	
		local controller = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
		controller:enter(ShopCurViewType.DianCang)

	elseif _type == 7 then --矿场
		if self:checkSystemOpenCondition(3, true) == false then 
			return 
		end 	
		local controller = ControllerFactory:Instance():create(ControllerType.MINING_CONTROLLER)
		controller:enter()
		
	elseif _type == 8 then --集市
		if self:checkSystemOpenCondition(13, true) == false then 
			return 
		end 
		local controller = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
		controller:enter(ShopCurViewType.JiShi)

	elseif _type == 9 then --聚宝盆		
		Activity:instance():entryActView(ActMenu.MONEY_TREE, false)

	elseif _type == 10 then --特惠
		if self:checkSystemOpenCondition(14, true) == false then 
			return 
		end 
		local controller = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
		controller:enter(ShopCurViewType.TeHui)

	elseif _type == 11 then --主线任务 
		controller = ControllerFactory:Instance():create(ControllerType.QUEST_CONTROLLER)
		controller:enter()		

	elseif _type == 12 then --好友 
		if self:checkSystemOpenCondition(11, true) == false then 
			return 
		end 
		local controller = ControllerFactory:Instance():create(ControllerType.FRIEND_CONTROLLER)
		controller:enter(ViewType.home)

	elseif _type == 13 then --充值 
    local controller = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
    controller:enter(ShopCurViewType.PAY)

  elseif _type == 14 then --上阵列表
		local controller  = ControllerFactory:Instance():create(ControllerType.PLAY_STATES_CONTROLLER)
		controller:enter(idx)

  elseif _type == 15 then --日常任务
	  local controller = ControllerFactory:Instance():create(ControllerType.QUEST_CONTROLLER)
	  controller:enter()
	
  elseif _type == 16 then --BOSS战
    if GameData:Instance():checkSystemOpenCondition(5, true) == false then 
      return 
    end 
    Activity:instance():entryActView(ActMenu.BOSS, false)

  elseif _type == 17 then --武斗大会
  	Activity:instance():entryActView(ActMenu.ARENA, false)

  elseif _type == 18 then --竞技场
		if GameData:Instance():checkSystemOpenCondition(41, true) == false then 
			return 
		end 
		local controller = ControllerFactory:Instance():create(ControllerType.PVP_RANK_MATCH_CONTROLLER)
		controller:enter()
		
  elseif _type == 19 then --将魂商店
		if GameData:Instance():checkSystemOpenCondition(27, true) == false then 
			return 
		end 
		local controller = ControllerFactory:Instance():create(ControllerType.CARD_SOUL_CONTROLLER)
		controller:enter(CardSoulMenu.SHOP)

  elseif _type == 20 then --军政府
	  local ret,hit = Talent.CanOpenCheck()
	  if not ret then
	    Toast:showString(GameData:Instance():getCurrentScene(), hit, ccp(display.cx, display.cy))
	    return
	  end
	  local controller = ControllerFactory:Instance():create(ControllerType.TALENT_CONTROLLER)
	  controller:enter()

  elseif _type == 21 then --每日签到
  	Activity:instance():entryActView(ActMenu.DAILY_SIGNIN, false)

	else 
		echo("### invalid jump type !!!")
	end
end 

function GameData:setLevelTrigAtHome(flag)
	self._newTrigAtHome = flag
end 

function GameData:getLevelTrigAtHome()
	return self._newTrigAtHome
end 

function GameData:getBattleAbilityForCards(cardsArray)
		if cardsArray == nil then 
				return 0
		end 

--[[战斗力计算:
				攻击力[atk] * 兵种对应攻击力修正[atk_revise] *( 4+ 暴击率 + 命中率 + 破击率 + 伤害增幅)/4 
				+ 生命值[HP] / 5 * 兵种对应生命修正[hp_revise] * (4 + 韧性 + 闪避率 + 格挡率 + 伤害减免)/4 + skill_fix
--]]

		local battleAbility = 0 
		for k, v in pairs(cardsArray) do 
				local atk = v:getAttack()
				local atkRevise = AllConfig.unittype[v:getSpecies()].atk_revise/10000
				local hpRevise = AllConfig.unittype[v:getSpecies()].hp_revise/10000				
				local hp = v:getHp()

				local skillId = AllConfig.unit[v:getConfigId()].skill
				local skillFixId = (AllConfig.cardskill[skillId].card_value_rank+1)*1000 + v:getSkill():getLevel()
				local skill_fix = AllConfig.cardskillfix[skillFixId].power_add 
				
				local unit_grown = AllConfig.unitgrown[v:getConfigId()]
				--ext attr val 
				local baoji = unit_grown.cri             --type:13
				local mingzhong = unit_grown.hit         --type:11
				local poji = unit_grown.precision              --type:16
				local shanghaizengjia = unit_grown.damage_increase   --type:17
				local shanghaijianmian =  unit_grown.damage_reduce  --type:18
				local renxing = unit_grown.toughness           --type:14
				local shanbi =  unit_grown.evade            --type:12
				local gedang = unit_grown.block            --type:15
				
				local equipments = {v:getWeapon(), v:getArmor(), v:getAccessory()}
				for k, equ in pairs(equipments) do 
						if equ ~= nil then 
								local attValArray = equ:getAttrValueArray()
								baoji = baoji + attValArray[13]
								mingzhong = mingzhong + attValArray[11]
								poji = poji + attValArray[16]
								shanghaizengjia = shanghaizengjia + attValArray[17]
								shanghaijianmian = shanghaijianmian + attValArray[18]
								renxing = renxing + attValArray[14]
								shanbi = shanbi + attValArray[12]
								gedang = gedang + attValArray[15]
						end 
				end 
				local ability = atk * atkRevise * (4 + baoji/10000 + mingzhong/10000 + poji/10000 + shanghaizengjia/10000)/4
											+hp/5 * hpRevise * (4 + renxing/10000 + shanbi/10000 + gedang/10000 + shanghaijianmian/10000)/4 + skill_fix
				battleAbility = battleAbility + ability
		end 

		-- echo("=== GameData:getBattleAbilityForCards", battleAbility)
		return toint(battleAbility)
end 

function GameData:getLanguageType()
  local lanType = LanguageType.ZHCN
  local langCode = AllConfig.characterinitdata[24].data
  if langCode == 2 then --繁体中文
    lanType = LanguageType.BIG5
  elseif langCode == 3 then --日文
    lanType = LanguageType.JPN   
  end 
  
  return lanType
end 


function GameData:checkSystemOpenCondition(id, bToastNotice)
	local canEntry = true 
	local str = ""

	if id <= #AllConfig.systemopen then 
		local item = AllConfig.systemopen[id]
		if item.type == 0 then --level condition 
			local player = self:getCurrentPlayer()
			if player and player:getLevel() < item.type_value then
				canEntry = false 
				str = _tr("open_%{name}_need_%{lv}", {name=item.system_desc, lv=item.type_value})
			end 
		elseif item.type == 1 then -- task condition
			if Quest:Instance():checkTaskIsFinishById(item.type_value) == false then 				
				canEntry = false 
				local taskName = Quest:Instance():getTaskById(item.type_value):getName()
				str = _tr("open_%{name}_need_%{task}", {name=item.system_desc, task=taskName})
			end 

		elseif item.type == 2 then -- stage condition 
		  local stage = Scenario:Instance():getStageById(item.type_value)
		  if stage and stage:getIsPassed() == false then
		  	canEntry = false
		    str = _tr("open_%{name}_need_%{stage}", {name=item.system_desc, stage=stage:getStageName()})		    
		  end
		else
		  canEntry = false
		  --assert(false,"unknow condition type: "..item.type)
		end 
	end 
	
	if ALL_SYSTEM_OPEN > 0 then
	 canEntry = true
	end

	if canEntry == false and bToastNotice == true then 
		Toast:showString(self:getCurrentScene(), str, ccp(display.cx, display.cy))
	end 

	return canEntry, str
end 

function GameData:setPlayersRank(msg)

	self._ranks = {nil, nil}
	for k, v in pairs(msg.ranks) do 
		for idx, player in pairs(v.players) do 
		  player.rank = idx
		end 
		echo("=== update rank info:", v.en)
		if v.en == "RANK_LEVEL" then 
			self._ranks[RankEnum.Level] = v.players
		elseif v.en == "RANK_VIP_LEVEL" then 
			self._ranks[RankEnum.Vip_Level] = v.players 
		elseif v.en == "RANK_MATCH" then  
			self._ranks[RankEnum.Match] = v.players
		else 
			echo("=== invalid rank data")
		end 
	end 
end 

function GameData:getPlayersRank(rankType)
	if self._ranks == nil then 
		self._ranks = {nil, nil, nil}
	end 
	return self._ranks[rankType] or {}
end 

function GameData:getItemsWithDropsArray(dropArray,level)
  if level == nil then
    level = self:getCurrentPlayer():getLevel()
  end 
  local drops = {}
  for key, dropId in pairs(dropArray) do
      if level >= AllConfig.drop[dropId].min_level and level <= AllConfig.drop[dropId].max_level then
          for key, dropsArr in pairs(AllConfig.drop[dropId].drop_data) do

             local dropInfo = {}
             local dropItemView = nil
             local m_type = dropsArr.array[1]
             local m_configId = dropsArr.array[2]
             local m_count = dropsArr.array[3]
             
             if m_configId <= 0 then
                m_configId = m_type
             end
             dropInfo.type = m_type
             dropInfo.configId = m_configId
             dropInfo.count = m_count
             table.insert(drops,dropInfo)
         end
      end
   end
   
   return drops
end

function GameData:notifyForPoorMoney()

	if self:checkSystemOpenCondition(16, false) == false then --商城未开启
		Toast:showString(self, _tr("not enough money"), ccp(display.cx, display.cy))
	else 
		local pop = PopupView:createTextPopupWithPath({text = _tr("money_limit_ask"),leftCallBack = function()
				local controller = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
				controller:enter(ShopCurViewType.PAY)
		end})
		self:getCurrentScene():addChild(pop,9000)
	end 
end 

return GameData
