
require("view.BaseView")

QuickWork = class("PopupView",BaseView)

local SwitchType = enum({"NONE","WORKETLV","MINERLV"})

local ConfigSortType = enum({"NONE","UP","DOWN"})

function QuickWork:ctor()
	ApplyFriendView.super.ctor(self)
	self:setDelegate(control)
end

local function updateTimeBall(self,index)
	local balls = {self.workTimeBall1,self.workTimeBall2,self.workTimeBall3,self.workTimeBall4 }

	for i = 1, 4, 1 do
		if i== index then
			balls[i]:setVisible(true)
		else
			balls[i]:setVisible(false)
		end
	end
end

function QuickWork:enter()
	local pkg = ccbRegisterPkg.new(self)

	pkg:addProperty("returnBtn","CCControlButton")
	pkg:addProperty("mainMenu","CCMenu")
	pkg:addProperty("timeMenu","CCMenu")
	pkg:addProperty("switchBtn1","CCNode")
	pkg:addProperty("switchBtn2","CCNode")
	pkg:addProperty("arrowUp1","CCSprite")
	pkg:addProperty("arrowDown1","CCSprite")
	pkg:addProperty("arrowUp2","CCSprite")
	pkg:addProperty("arrowDown2","CCSprite")
	pkg:addProperty("fontUp1","CCSprite")
	pkg:addProperty("fontUp2","CCSprite")
	pkg:addProperty("fontDown1","CCSprite")
	pkg:addProperty("fontDown2","CCSprite")

	pkg:addProperty("workTimeBall1","CCSprite")
	pkg:addProperty("workTimeBall2","CCSprite")
	pkg:addProperty("workTimeBall3","CCSprite")
	pkg:addProperty("workTimeBall4","CCSprite")

	pkg:addFunc("workTime1CallBack",QuickWork.workTime1CallBack)
	pkg:addFunc("workTime2CallBack",QuickWork.workTime2CallBack)
	pkg:addFunc("workTime3CallBack",QuickWork.workTime3CallBack)
	pkg:addFunc("workTime4CallBack",QuickWork.workTime4CallBack)
	pkg:addProperty("workTime1","CCLabelTTF")
	pkg:addProperty("workTime2","CCLabelTTF")
	pkg:addProperty("workTime3","CCLabelTTF")
	pkg:addProperty("workTime4","CCLabelTTF")


	pkg:addFunc("returnCallBack",QuickWork.returnBtnCallBack)
	pkg:addFunc("oneKeyResetBtnCallBack",QuickWork.onOneKeyResetCallBack)  --reset
	pkg:addFunc("confirmBtnCallBack",QuickWork.onConfigCallBack) -- config

	local layer,owner = ccbHelper.load("OnekeyWorkPopView.ccbi","OneKeyWorkCCB","CCLayer",pkg)

	self.mainMenu:setTouchPriority(-150)
	self.mainMenu:setVisible(true)
	self.timeMenu:setTouchPriority(-150)
	-- self.returnBtn:setVisible(false)
	self:drawTimeDesc()

	local mask = Mask.new({opacity = 200,priority = -149})
	mask:addChild(layer)
	self:addChild(mask)
	mask:setTag(615)
	layer:setScale(0.2)
	layer:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6) )

	local function valueChanged(type,pSender)
		local pControl = tolua.cast(pSender,"CCControlSwitch")

		self.content = nil
		if type == SwitchType.WORKETLV then
	        self.content = {self.arrowUp1,self.fontUp1,self.arrowDown1,self.fontDown1}
		elseif type == SwitchType.MINERLV then
			self.content = {self.arrowUp2,self.fontUp2,self.arrowDown2,self.fontDown2}
		end

		if pControl:isOn() then
			for i = 1, 4, 1 do
				if i<=2 then
					self.content[i]:setVisible(true)
				else
					self.content[i]:setVisible(false)
				end
			end
		else
			for i = 1, 4, 1 do
				if i<=2 then
					self.content[i]:setVisible(false)
				else
					self.content[i]:setVisible(true)
				end
			end
		end
	end

	local function valueChanged1(strEventName,pSender)
		valueChanged(SwitchType.WORKETLV,pSender)
	end

	local function valueChanged2(strEventName,pSender)
		valueChanged(SwitchType.MINERLV,pSender)
	end

	self._switchControl1 = self:createControlSwitchBtn()
	self._switchControl1:addHandleOfControlEvent(valueChanged1, CCControlEventValueChanged)
	self.switchBtn1:addChild(self._switchControl1)

	self._switchControl2 = self:createControlSwitchBtn()
	self._switchControl2:addHandleOfControlEvent(valueChanged2, CCControlEventValueChanged)
	self.switchBtn2:addChild(self._switchControl2)

	valueChanged1("",self._switchControl1)
	valueChanged2("",self._switchControl2)

	if Mining:Instance():getMinerConfig() ~= nil then
	    local oldConfig = Mining:Instance():getMinerConfig()
		local timeIndex = oldConfig.time
	    updateTimeBall(self,timeIndex)
	    self._workTimeIndex = timeIndex
		if oldConfig.workSortType == ConfigSortType.UP then
			self._switchControl1:setOn(true)
		else
			self._switchControl1:setOn(false)
		end

	    if oldConfig.minerSorType == ConfigSortType.UP then
		    self._switchControl2:setOn(true)
	    else
		    self._switchControl2:setOn(false)
	    end

	else
		self:workTime1CallBack()
		self._switchControl1:setOn(false)
		self._switchControl2:setOn(false)
		self:saveConfig()
	end

end

function QuickWork:createControlSwitchBtn()

	local switchControl = CCControlSwitch:create( CCSprite:create("img/oneKeyWork/switch-mask.png"),
		CCSprite:create("img/oneKeyWork/switch-on.png"),
		CCSprite:create("img/oneKeyWork/switch-off.png"),
		CCSprite:create("img/oneKeyWork/switch-thumb.png")
	)

	--switchControl:setOn(false)
	switchControl:setTouchPriority(-150)
	return switchControl
end

function QuickWork:workTime1CallBack()
	updateTimeBall(self,1)
	self._workTimeIndex = 1
end

function QuickWork:workTime2CallBack()
	updateTimeBall(self,2)
	self._workTimeIndex = 2
end

function QuickWork:workTime3CallBack()
	updateTimeBall(self,3)
	self._workTimeIndex = 3
end

function QuickWork:workTime4CallBack()
	updateTimeBall(self,4)
	self._workTimeIndex = 4
end

function QuickWork:drawTimeDesc()
	local tbl = {self.workTime1, self.workTime2,self.workTime3, self.workTime4 }
	for i = 1, 4, 1 do
		local item = AllConfig.mineinitdata
		for i =1, math.min(4, table.getn(item)) do
			if item[i].time < 3600 then
				tbl[i]:setString(string.format("%d", item[i].time/60).._tr("minute"))
			else
				tbl[i]:setString(string.format("%d", item[i].time/3600).._tr("hour"))
			end
		end
	end
end

function QuickWork:returnBtnCallBack()
	print("returnBtnCallBack")

	local popView = self:getChildByTag(615)
	if popView ~= nil then
		popView:removeFromParentAndCleanup(true)
	end
end

function QuickWork:onOneKeyResetCallBack()
	if self._switchControl1 and self._switchControl1:isOn() == true then
		self._switchControl1:setOn(false,true)
	end

	if self._switchControl2 and self._switchControl2:isOn() == true then
		self._switchControl2:setOn(false,true)
	end
	self:workTime1CallBack()
end

function QuickWork:onConfigCallBack()
	print("QuickWork.lua<QuickWork:onConfigCallBack> : ")
	self:saveConfig()
	self:returnBtnCallBack()

	Mining:Instance():quickWork()
end

function QuickWork:saveConfig()
	local minerConfig = {}
	local workerSortType = 0
	local minerSortType = 0
	if self._switchControl1 and self._switchControl1:isOn() == true then -- 升序 On 降序：off
		workerSortType = ConfigSortType.UP
	else
		workerSortType = ConfigSortType.DOWN
	end

	if self._switchControl2 and self._switchControl2:isOn() == true then       -- 升序
		minerSortType = ConfigSortType.UP
	else
		minerSortType = ConfigSortType.DOWN
	end

	minerConfig.time = self._workTimeIndex
	minerConfig.workSortType = workerSortType
	minerConfig.minerSorType = minerSortType
	Mining:Instance():saveMinerConfig(minerConfig)
end


return QuickWork



