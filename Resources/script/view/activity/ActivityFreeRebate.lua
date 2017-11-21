
require("view.BaseView")
require("model.Activity")


ActivityFreeRebate = class("ActivityFreeRebate", BaseView)

function ActivityFreeRebate:ctor(index)

  print("index =================",index)

  ActivityFreeRebate.super.ctor(self)
 
  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("fetchCallback",ActivityFreeRebate.fetchCallback)
  pkg:addFunc("entryLotteryCallback",ActivityFreeRebate.entryLotteryCallback)

  pkg:addProperty("label_rebate","CCLabelTTF")
  pkg:addProperty("label_leftTime","CCLabelTTF")
  pkg:addProperty("label_count","CCLabelTTF")
  pkg:addProperty("totalTime","CCLabelTTF")
  pkg:addProperty("reward_money","CCLabelTTF")
  pkg:addProperty("label_actLeftTime","CCLabelTTF")

  pkg:addProperty("rewardBtn","CCControlButton")
  pkg:addProperty("tips1Node","CCNode")
  pkg:addProperty("tips2Node","CCNode")
  pkg:addProperty("tip0Node","CCNode")
  pkg:addProperty("rebateMainBg","CCSprite")
  pkg:addProperty("totalTimeNode","CCNode")
  pkg:addProperty("lotteryBtn","CCControlButton")

  local layer,owner = ccbHelper.load("ActivityFreeRebate.ccbi","ActivityFreeRebateCCB","CCLayer",pkg)
  self:addChild(layer)

  net.registMsgCallback(PbMsgId.QueryDrawCardRebateResultS2C, self, ActivityFreeRebate.queryDrawCardRebateResultS2C)
  self.rebateData = Mall:Instance():getRebateData()
  self.tips1Node:setVisible(true)

  local hasOldRebate = false --Mall:Instance():isShowRebateView(1)
  local hasOneRebate = Mall:Instance():isShowRebateView(1)
  local hasTenRebate = Mall:Instance():isShowRebateView(2)
  print("=======================",hasOldRebate,hasOneRebate,hasTenRebate,index)
  self._index = index

  self.label_actLeftTime:setString(_tr("rebase left time"))

  local parent = self.rebateMainBg:getParent()
  local bg
  if self._index == 8 then
	  bg = display.newSprite("img/activity/bg_miandanOne.png")
	  parent:addChild(bg)
	  self.rebateMainBg:removeFromParentAndCleanup(true)
	  self.rewardBtn:setPositionY(self.rewardBtn:getPositionY()+15.0)
	  self.label_rebate:setPositionY(self.label_rebate:getPositionY()+14.0)
  elseif self._index == 9 then
	  bg = display.newSprite("img/activity/bg_miandanTen.png")
	  parent:addChild(bg)
	  self.rebateMainBg:removeFromParentAndCleanup(true)
	  self.rewardBtn:setPositionY(self.rewardBtn:getPositionY()+15.0)
	  self.label_rebate:setPositionY(self.label_rebate:getPositionY()+14.0)
  end

end

function ActivityFreeRebate:initShowData()

	--dump(self.rebateData,"@@@@@@@@@@")
	local index = 2
	if self._index == 9 then
		index = index +1
	end
	self.curRebateData = self.rebateData[index]
	print("index ===",index)
	--dump(self.curRebateData ,"@@@@@@@@@@")
	self._rebateMoney = self.curRebateData.rebateMoney 
	--Activity

	if self.rebateData~= nil and #self.rebateData >0 then
		local rebateMoney = self.curRebateData.rebateTemMoney -- 已返还的钱
		local remainDayTime = self.curRebateData.rebateTime -  Clock:Instance():getCurServerUtcTime()
		local remainTotalTime = self.curRebateData.rebateEndTime - Clock:Instance():getCurServerUtcTime()
		print("@@@@@@@@@",remainTotalTime)
		if remainTotalTime <=0 then
			self.tip0Node:setVisible(false)
			self.tips1Node:setVisible(false)
			self.tips2Node:setVisible(false)
			local finishMark = display.newSprite("img/activity/activity_finish_mark.png")
			finishMark:setPosition(ccp(display.cx,270))
			self:addChild(finishMark,10)
			self.lotteryBtn:removeFromParentAndCleanup(true)
		end

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

		local function updataTime()
			local hour,min,sec
			remainDayTime = remainDayTime - 1.0
			hour,min,sec = formatTime(remainDayTime)
			local str = string.format("%02d:%02d:%02d", hour,min,sec)
			if self.pLeftTime ~= nil then
				self.pLeftTime:setString(str)
			end
			if remainDayTime <= 0 and self.curRebateData.rebateTemMoney > 0 then
				self.label_rebate:setString(self.curRebateData.rebateTemMoney)
				self.rewardBtn:setEnabled(true)
			end
		end

		local function updataTotalTime()
			local hour,min,sec
			remainTotalTime = remainTotalTime - 1.0
			if remainTotalTime <= 0 then
				self.tip0Node:setVisible(false)
			end
			hour,min,sec = formatTime(remainTotalTime)
			local str = string.format("%02d:%02d:%02d", hour,min,sec)
			if self.pTotalTime ~= nil then
				self.pTotalTime:setString(str)
			end
		end

		local hour1,min1,sec1 = formatTime(remainDayTime)
		local str1 = string.format("%02d:%02d:%02d", hour1,min1,sec1)
		self.pLeftTime:setString(str1)

		local hour2,min2,sec2 = formatTime(remainTotalTime)
		local str2 = string.format("%02d:%02d:%02d", hour2,min2,sec2)
		self.pTotalTime:setString(str2)

		self:schedule(updataTotalTime,1.0)

		self.label_rebate:setString(self.curRebateData.rebateMoney)
		if self.curRebateData.rebateMoney == 0 then
			self.rewardBtn:setEnabled(false)
		end

		local needDrawCount = 0
		if remainTotalTime >0 then
			self:schedule(updataTime,1.0)
			needDrawCount = AllConfig.activity_rebate[self.curRebateData.rebateId].rebate_once_count - self.curRebateData.currentDrawCount	
		end
		if needDrawCount > 0  then
			self.tips1Node:setVisible(true)
			self.tips2Node:setVisible(false)
			self.label_count:setString(needDrawCount)
		elseif needDrawCount <= 0 and remainTotalTime >0 then
			self.reward_money:setString(self.curRebateData.rebateTemMoney)
			self.tips1Node:setVisible(false)
			self.tips2Node:setVisible(true)
		end
	else
		self.rewardBtn:setEnabled(false)
	end

end
  
function ActivityFreeRebate:initOutLineLabel()
  self.label_leftTime:setString("")
  self.pLeftTime = ui.newTTFLabelWithOutline( {
											text = "",
											font = self.label_leftTime:getFontName(),
											size = self.label_leftTime:getFontSize(),
											x = 0,
											y = 0,
											color = ccc3(0, 255, 16),
											align = ui.TEXT_ALIGN_LEFT,
											--valign = ui.TEXT_VALIGN_TOP,
											--dimensions = self.label_info:getContentSize(),
											outlineColor =ccc3(0,0,0),
											pixel = 2
											}
										  )
  self.pLeftTime:setPosition(ccp(self.label_leftTime:getPosition()))
  self.label_leftTime:getParent():addChild(self.pLeftTime)

  self.totalTime:setString("")
  self.pTotalTime = ui.newTTFLabelWithOutline( {
	  text = "",
	  font = self.totalTime:getFontName(),
	  size = self.totalTime:getFontSize(),
	  x = 0,
	  y = 0,
	  color = ccc3(255, 241, 192),
	  align = ui.TEXT_ALIGN_LEFT,
	  --valign = ui.TEXT_VALIGN_TOP,
	  --dimensions = self.label_info:getContentSize(),
	  outlineColor =ccc3(0,0,0),
	  pixel = 2
  }
  )
  self.pTotalTime:setPosition(ccp(self.totalTime:getPosition()))
  self.totalTime:getParent():addChild(self.pTotalTime)

end 

function ActivityFreeRebate:onEnter()
  echo("---ActivityFreeRebate:onEnter---")
  self:initOutLineLabel()
  self:initShowData()
end

function ActivityFreeRebate:fetchCallback()
  echo("=== fetchCallback====")
  local rebateId = self.curRebateData.rebateId
  local queryDrawCardRebateC2SData = PbRegist.pack(PbMsgId.QueryDrawCardRebateC2S,{id = rebateId})
  net.sendMessage(PbMsgId.QueryDrawCardRebateC2S,queryDrawCardRebateC2SData)

end 

function ActivityFreeRebate:entryLotteryCallback()
  echo("=== entryLotteryCallback")
  net.unregistAllCallback(self)
  local controller = ControllerFactory:Instance():create(ControllerType.LOTTERY_CONTROLLER)
  controller:enter()
end

function ActivityFreeRebate:queryDrawCardRebateResultS2C(action,msgId,msg)
	print("queryDrawCardRebateResultS2C: result=", msg.error)
	if msg.error == "NO_ERROR_CODE" then
	    --show gained bonus
	    local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client)
	    for i=1,table.getn(gainItems) do
	      echo("----gained configId:", gainItems[i].configId)
	      echo("----gained, count:", gainItems[i].count)
	      local str = string.format("+%d", gainItems[i].count)
	      Toast:showIconNumWithDelay(str, gainItems[i].iconId, gainItems[i].iType, gainItems[i].configId, ccp(display.width/2,display.height*0.5-i*40), 0.3*(i-1))
	    end

		GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)
		self.rewardBtn:setEnabled(false)
		self.label_rebate:setString("0")

		-- local gainCoinStr = string.format("+%d",self.curRebateData.rebateMoney)
		-- Toast:showIconNum(gainCoinStr, 3059003, nil, nil, ccp(display.cx,display.cy))
	end
end

function ActivityFreeRebate:onExit()
	net.unregistAllCallback(self)
	print("=============onExit ==========")
end

return ActivityFreeRebate

			 