

require("view.achievement.AchievementListCellView")
require("model.Achievement.Achievement")

OfficeAchievementView = class("OfficeAchievementView",BaseView)

function OfficeAchievementView:ctor()
	OfficeAchievementView.super.ctor(self)

	local pkg = ccbRegisterPkg.new(self)
	pkg:addFunc("rewardBtnCallback",OfficeAchievementView.onRewardBtnCallBack)
	pkg:addProperty("curOfficeal","CCLabelTTF")
	pkg:addProperty("curMoney","CCLabelTTF")
	pkg:addProperty("curGold","CCLabelTTF")
	pkg:addProperty("nextOfficial","CCLabelTTF")
	pkg:addProperty("nextMoney","CCLabelTTF")
	pkg:addProperty("nextGold","CCLabelTTF")
	pkg:addProperty("Official","CCLabelTTF")
	pkg:addProperty("Money","CCLabelTTF")
	pkg:addProperty("rewardCount","CCLabelTTF")
	pkg:addProperty("curPoint","CCLabelTTF")
	pkg:addProperty("nextPoint","CCLabelTTF")
	pkg:addProperty("off_arrow","CCSprite")
	pkg:addProperty("cur_off_font","CCLabelTTF")
	pkg:addProperty("cur_ach_point","CCLabelTTF")
	pkg:addProperty("next_off","CCLabelTTF")
	pkg:addProperty("next_ach_point","CCLabelTTF")
	pkg:addProperty("officialRewardBtn","CCControlButton")

	local layer,owner = ccbHelper.load("OfficialView.ccbi","OfficialViewCCB","CCLayer",pkg)
	self:addChild(layer)

	self.cur_off_font:setString(_tr("cur_off_font"))
	self.cur_ach_point:setString(_tr("cur_ach_point"))
	self.next_off:setString(_tr("next_off"))
	self.next_ach_point:setString(_tr("next_ach_point"))
end


function OfficeAchievementView:onEnter()

	net.registMsgCallback(PbMsgId.AskForAchievementGiftResult, self, OfficeAchievementView.AskForOfficialAwardResult)

	local  point = Achievement:instance():getCurAchievementPoint()
	self._officialInfo = Achievement:instance():getOfficialIdAndNameByPoint(point)
	self.curOfficeal:setString(self._officialInfo.officialName)
	self.nextOfficial:setString(self._officialInfo.nextOfficialName)	
	self.curPoint:setString(point)
	self.nextPoint:setString(self._officialInfo.nextPoint)
	local coin, money = self:getAllCoinMoney(self._officialInfo.curBonus)
	self.curMoney:setString(coin)
	self.curGold:setString(money)
	coin, money = self:getAllCoinMoney(self._officialInfo.nextBonus)
	self.nextMoney:setString(coin)
	self.nextGold:setString(money)
	
	local array = CCArray:create()
	local move = CCMoveBy:create(0.2,ccp(8,0))
	local moveBack = move:reverse()
	array:addObject(move)
	array:addObject(moveBack)
	local action = CCSequence:create(array)
	self.off_arrow:runAction(CCRepeatForever:create(action))


	-- local lastReceiveTime = Achievement:instance():getLastGetAwardTime() 
	-- local curTime = Clock:Instance():getCurServerUtcTime() 
	-- local preDate = os.date("!*t", lastReceiveTime) 
	-- local curDate = os.date("!*t", curTime) 
	-- echo("===preDate.day, curDate.day", preDate.day, curDate.day)
	-- self.officialRewardBtn:setEnabled(preDate.day ~= curDate.day)

	local lastReceiveTime = Achievement:instance():getLastGetAwardTime()
	local curTime = Clock:Instance():getCurServerUtcTime() 
	local time = toint(os.date("%H",lastReceiveTime))*3600+ toint(os.date("%M",lastReceiveTime))*60+toint(os.date("%S",lastReceiveTime))
	local DIFTimes = curTime - lastReceiveTime 
	self.officialRewardBtn:setEnabled(time + DIFTimes > 86400)
end

function OfficeAchievementView:onExit()
	net.unregistAllCallback(self)
end

function OfficeAchievementView:updateReceiveBtnState()
	local coin, money = self:getAllCoinMoney(self._officialInfo.curBonus)
	local array = CCArray:create()
	local callfunc1 = CCCallFunc:create(function()
		local gainCoinStr = string.format("+%d", coin)
		Toast:showIconNum(gainCoinStr, 3059002, nil, nil, ccp(display.cx,display.cy)) --coin
	end)
	local callfunc2 = CCCallFunc:create(function()
		local gainCoinStr = string.format("+%d", money)
		Toast:showIconNum(gainCoinStr, 3059003, nil, nil, ccp(display.cx,display.cy)) --money
	end)
	
	array:addObject(callfunc1)
	array:addObject(CCDelayTime:create(1.0))
	array:addObject(callfunc2)
	self:runAction(CCSequence:create(array))

	self.officialRewardBtn:setEnabled(false)
end

function OfficeAchievementView:onRewardBtnCallBack()
	net.sendMessage(PbMsgId.AskForAchievementGift)
	self.officialRewardBtn:setEnabled(false)
end

function OfficeAchievementView:AskForOfficialAwardResult(action,msgId,msg)
	echo("===AskForOfficialAwardResult:", msg.state)

	if msg.state == "Ok" then
		self:updateReceiveBtnState()
		GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
	else 
		Achievement:instance():handleErrorCode(msg.state)
	end 
end

function OfficeAchievementView:getAllCoinMoney(bonusArray)
	local coin = 0
	local money = 0 
	for k, v in pairs(bonusArray) do 
		if v[1] == 4 then 
			coin = coin + v[3]
		elseif v[1] == 5 then 
			money = money + v[3]
		end 
	end 
	return coin, money
end 

return OfficeAchievementView
