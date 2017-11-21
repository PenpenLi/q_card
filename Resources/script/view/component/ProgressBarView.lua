
ProgressBarView = class("ProgressBarView",function()
											return display.newNode()
										  end)

function ProgressBarView:ctor(spriteBg, spriteFg1, spriteFg2)
  self:setNodeEventEnabled(true)
	if spriteBg == nil or spriteFg1 == nil then 
		return
	end

	self.img_bg = spriteBg
	self.img_fg1 = spriteFg1 
	self.img_fg2 = spriteFg2

	self:addChild(self.img_bg)

	self.progressor1 = CCProgressTimer:create(self.img_fg1)
	self.progressor1:setType(kCCProgressTimerTypeBar)
	self.progressor1:setMidpoint(ccp(0, 1))
	self.progressor1:setBarChangeRate(ccp(1, 0))
	self:addChild(self.progressor1)

	if self.img_fg2 ~= nil then 
		self.progressor2 = CCProgressTimer:create(self.img_fg2)
		self.progressor2:setType(kCCProgressTimerTypeBar)
		self.progressor2:setMidpoint(ccp(0, 1))
		self.progressor2:setBarChangeRate(ccp(1, 0))
		self:addChild(self.progressor2)
	end

	self.pLabel = ui.newTTFLabelWithOutline( {
                                            text = "",
                                            font = "Corier-Bold",
                                            size = 18,
                                            x = 0,
                                            y = 0,
                                            color = ccc3(255, 255, 255),
                                            align = ui.TEXT_ALIGN_CENTER,
                                            --valign = ui.TEXT_VALIGN_TOP,
                                            --dimensions = CCSize(200, 30),
                                            outlineColor =ccc3(0,0,0),
                                            pixel = 1
                                            }
                                          )

	self.pLabel:setPosition(ccp(self.progressor1:getPosition()))                                          
	self:addChild(self.pLabel)

	self:setLabelEnabled(false)

	self._percent1 = 0
	self._percent2 = 0
	self.scheduleId = 0
end

function ProgressBarView:setAnchorPoint(point)
	self.img_bg:setAnchorPoint(point)
	self.progressor1:setAnchorPoint(point)
	if self.progressor2 ~= nil then 
		self.progressor2:setAnchorPoint(point)
	end
	local size = self:getContentSize()
	self.pLabel:setPosition(ccp(size.width/2*(1-point.x) - self:getContentSize().width*0.2+45 , size.height/2*(1-point.y)))
end 

function ProgressBarView:setContentSize(size)
	local orgSize = self:getContentSize()
	local scale = size.width/orgSize.width 
	self:setScaleX(scale)
end

function ProgressBarView:getContentSize()
    return self.img_bg:getContentSize()
end

function ProgressBarView:setLabelEnabled(LabelEnabled)
	self._LabelEnabled = LabelEnabled
	if self._LabelEnabled == false then
	    self.pLabel:setString("")
	end
end

function ProgressBarView:getLabelEnabled()
	return self._LabelEnabled
end

------
--  Getter & Setter for
--      ProgressBarView._Type 
-----
function ProgressBarView:setType(Type)
	self._Type = Type
end

function ProgressBarView:getType()
	return self._Type
end

function ProgressBarView:setPercent(percent, fgIndex) -- 0~100
	if self:getLabelEnabled() == true then
	  if self:getType() == nil or self:getType() == "spirit" then
	     self.pLabel:setString(GameData:Instance():getCurrentPlayer():getSpirit().."/"..GameData:Instance():getCurrentPlayer():getMaxSpirit())
	  elseif self:getType() == "talent" then
	     local str = ""
	     if GameData:Instance():getCurrentPlayer():getTalentBankLevel() ~= nil then
        local talentPoint = GameData:Instance():getCurrentPlayer():getTalentBankPoints()
        local talentMaxPoint = GameData:Instance():getCurrentPlayer():getTalentBankMaxPoint()
        str = talentPoint.."/"..talentMaxPoint
       end
	     self.pLabel:setString(str)
	  end
	end

	if fgIndex == nil then 
		fgIndex = 1 
	end

	if fgIndex == 1 then  --progressorBar 1
		self.progressor1:setPercentage(percent)
		self._percent1 = percent
	elseif fgIndex == 2 and self.progressor2 ~= nil then 
		self.progressor2:setPercentage(percent)
		self._percent2 = percent
	end
end

function ProgressBarView:getPercent(fgIdx)
	if fgIdx ~= nil and fgIdx == 2 then 
		return self._percent2
	end 

	return self._percent1
end

--呼吸灯效果
function ProgressBarView:setBreathAnim(fgIdx)
	if fgIdx == nil then
		fgIdx = 1 
	end

	-- local action = CCSequence:createWithTwoActions(CCFadeTo:create(1.0, 100),CCFadeTo:create(2.0, 255))
	local fade = CCFadeIn:create(1.0)
	local action = CCSequence:createWithTwoActions(fade,fade:reverse())
	if fgIdx == 1 then 
		self.progressor1:runAction(CCRepeatForever:create(action))
	else 
		if self.progressor2 ~= nil then 
			self.progressor2:runAction(CCRepeatForever:create(action))
		end
	end
end

function ProgressBarView:setFgVisible(isVisible, fgIdx)
	if fgIdx == nil then
		fgIdx = 1 
	end

	if fgIdx == 1 then 
		self.progressor1:setVisible(isVisible)
	else 
		if self.progressor2 ~= nil then
			self.progressor2:setVisible(isVisible)
		end
	end
end

function ProgressBarView:getFgVisible(fgIdx)
	local isVisible = false 
	if fgIdx == 1 then 
		isVisible = self.progressor1:isVisible()
	else 
		if self.progressor2 ~= nil then
			isVisible = self.progressor2:isVisible()
		end
	end

	return isVisible
end

function ProgressBarView:setFullPercentCallback(callbackFunc)
	self._fullPercentCallBack = callbackFunc
end 

function ProgressBarView:getFullPercentCallback()
	return self._fullPercentCallBack
end

------
--  Getter & Setter for
--      ProgressBarView._UpdateCallback 
-----
function ProgressBarView:setUpdateCallback(UpdateCallback)
	self._UpdateCallback = UpdateCallback
end

function ProgressBarView:getUpdateCallback()
	return self._UpdateCallback
end


function ProgressBarView:startProgressing(finishCallback, startPercent, endPercent, fgIdx)
	local totalTime = 0.5
	local deltaPercent = math.abs(endPercent - startPercent)

	if deltaPercent == 0 then 
		return 
	end

	if deltaPercent < 50  then
	   totalTime = 1.0
	   if deltaPercent < 10 then
	     totalTime = 2.0
	   end
	elseif deltaPercent > 500 then 
		totalTime = 0.3
	end
	
	local endTime = totalTime * deltaPercent/100
	local elapsTime = 0
	local direction = 1 --进度正向增长
	if endPercent < startPercent then 
		direction = -1 		--进度反向减少
	end

	local function finish()
		-- echo("finish")
		if self.scheduleId > 0 then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleId)
			self.scheduleId = 0
		end 

		--re-adjust
		if direction == 1 then 
			if endPercent > 0 then 
				local val = endPercent%100
				
				if val == 0 then 
					self:setPercent(100, fgIdx)
				else 
					self:setPercent(val, fgIdx)
				end
			else 
				self:setPercent(0, fgIdx)
			end
		end 

		if finishCallback ~= nil then
			finishCallback()
		end
	end

	local function update(dt)		
		elapsTime = elapsTime + dt 
		if self._UpdateCallback ~= nil then
		  self._UpdateCallback()
		end
		if elapsTime >= endTime then 
			finish()
			return
		end

		local percent = startPercent + direction*100*elapsTime/totalTime 
		-- echo("update:", percent)
		if percent >= 100 then 
			endTime = endTime - elapsTime
			elapsTime = 0
			startPercent = 0 
			percent = 0

			if self._fullPercentCallBack ~= nil then 
				self._fullPercentCallBack()
			end
		end
		-- echo("percent=",percent)
		self:setPercent(percent, fgIdx)
	end

	if self.scheduleId > 0 then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleId)
		self.scheduleId = 0
	end
	self.scheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(update, 0, false)
end

function ProgressBarView:stopProgressBar()
	if self.scheduleId > 0 then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleId)
		self.scheduleId = 0
	end
	self:setFullPercentCallback(nil)
end

function ProgressBarView:onExit()
  self:stopProgressBar()
end


return ProgressBarView