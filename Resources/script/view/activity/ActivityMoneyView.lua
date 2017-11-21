require("view.BaseView")
require("model.Activity")
require("view.component.Toast")

ActivityMoneyView = class("ActivityMoneyView",BaseView)

local numValue = {0,0,0,0,0}

--当前运动的计数器
local count = 0

--开始减速的边界
local speed = 0.5

local numStep = 1

local moveSpeed = 0.03

local step = 1

local result = nil

local stopCount = 0

local clickIng = false

local originMoney = 0

local winSize = CCDirector:sharedDirector():getWinSize()

function ActivityMoneyView:ctor()

	ActivityMoneyView.super.ctor(self)

	local pkg = ccbRegisterPkg.new(self)

	pkg:addProperty("txtLeftTime", "CCLabelTTF")

	pkg:addProperty("txtOne", "CCLabelBMFont")
	pkg:addProperty("txtTwo", "CCLabelBMFont")
	pkg:addProperty("txtThree", "CCLabelBMFont")
	pkg:addProperty("txtFour", "CCLabelBMFont")
	pkg:addProperty("txtFive", "CCLabelBMFont")

	pkg:addProperty("txtMaxMoney", "CCLabelTTF")
	pkg:addProperty("txtMinMoney", "CCLabelTTF")
	pkg:addProperty("txtDenote", "CCLabelTTF")
	pkg:addProperty("txtCurrent", "CCLabelTTF")
	pkg:addProperty("txtLeftNum", "CCLabelTTF")
	pkg:addProperty("btnDenote", "CCMenuItemImage")

	pkg:addProperty("spContent", "CCSprite")

	local layer, owner = ccbHelper.load("ActivityMoneyView.ccbi", "activity_money_view", "CCLayer", pkg)

	self:addChild(layer)

	self:init()

	self:addEvent()

	self:addNetEvent()

	self:showInfo()

	self:createEffect(5020220, self, winSize.width/2, winSize.height/2)
	self:createEffect(5020222, self, winSize.width/2-15, winSize.height/2+125)

	self.txtOne:setString(0)
	self.txtTwo:setString(0)
	self.txtThree:setString(0)
	self.txtFour:setString(0)
	self.txtFive:setString(0)

	self.move = {0,0,0,0,0}
end

function ActivityMoneyView:showResult()

	local function setValue(moveNum, txt)

		local num = nil

		if step <= string.len(result) then
			num = string.sub(result, string.len(result) + 1 - step, string.len(result) + 1 - step)+0
		else
			num = 0
		end

		if self.move[moveNum] == 0 then
			numValue[moveNum] = (numValue[moveNum] + 1)%10
			txt:setString(numValue[moveNum])
		elseif self.move[moveNum] == 1 then
			count = count + 0.2

			if count >= speed and numValue[moveNum] == num then
				count = 0.1
				self.move[moveNum] = 2
			else
				numValue[moveNum] = (numValue[moveNum] + 1)%10
				txt:setString(numValue[moveNum])
			end
		elseif self.move[moveNum] == 2 then
			count = count + 0.2
			if count >= (0.15 * numStep) then
				numValue[moveNum] = (numValue[moveNum] + 1)%10
				txt:setString(numValue[moveNum])
				numStep = numStep + 1
				count = 0
			end

			if (numValue[moveNum]+0) == (num+0) then

				echo("停止所有的动画stop animation"..num..numValue[moveNum].."count"..count)

				self.move[moveNum] = 3

				if step <= string.len(result) then
					txt:setString(string.sub(result, string.len(result) + 1 - step, string.len(result) + 1 - step))
				else
					txt:setString(0)
				end

				step = step + 1

				if step > 5 then
					stopCount = 0
					self:showInfo()

					self._actArrow = display.newNode()
					for i=1, 4 do
						self:createEffect(5020221, self._actArrow, winSize.width/8*((i-1)*2+1), winSize.height/2 + (i%2) * 140)
					end
					self:addChild(self._actArrow)

				else
					count= 0
					numStep = 1
					self.move[step] = 1
				end
			end
		end
	end

	local function numMove()

		setValue(1, self.txtOne)
		setValue(2, self.txtTwo)
		setValue(3, self.txtThree)
		setValue(4, self.txtFour)
		setValue(5, self.txtFive)

		if self.move[1] == 3 and self.move[2] == 3 and self.move[3] == 3 and self.move[4] == 3 and self.move[5] == 3 then
			stopCount = stopCount + 1

			if stopCount > 75 then
				self._actArrow:removeAllChildrenWithCleanup(true)
				self.move = {0, 0, 0, 0, 0}
				self:init()

				self.txtOne:setString(0)
				self.txtTwo:setString(0)
				self.txtThree:setString(0)
				self.txtFour:setString(0)
				self.txtFive:setString(0)

				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self._schedule)
			end
		end
	end
	self._schedule = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(numMove,moveSpeed,false)
end

function ActivityMoneyView:init()
	clickIng = false
	stopCount = 0
	count = 0
	speed = 1.9
	step = 1
	result = nil
	numStep = 1
end

function ActivityMoneyView:createEffect(type, target, width, height)
    local light,offsetX,offsetY,duration = _res(type)
    if light ~= nil then
    	light:setPosition(width, height)
        target:addChild(light)
        light:getAnimation():play("default")
    end
end

function ActivityMoneyView:onExit()
    net.unregistAllCallback(self)
    if self._schedule ~= nil then
    	CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self._schedule)
    end
    ActivityMoneyView.super.onExit(self)
    
end

function ActivityMoneyView:addEvent()

	local function denoteHandler()
		if self.count == #AllConfig.quickmoney then
			Toast:showString(self, _tr("quick_money_times_end"), ccp(display.width/2, display.height*0.4))
			return
		end

		if clickIng == true then
			return
		end

		clickIng = true

    	local data = PbRegist.pack(PbMsgId.ReqUseQuickMoney)
    	net.sendMessage(PbMsgId.ReqUseQuickMoney, data)
	end

	self.btnDenote:registerScriptTapHandler(denoteHandler)
end

function ActivityMoneyView:addNetEvent()
	net.registMsgCallback(PbMsgId.ReqUseQuickMoneyResult,self,ActivityMoneyView.onReqUseQuickMoneyResult)
end


function ActivityMoneyView:onReqUseQuickMoneyResult(action,msgId,msg)
	if msg.state ~= "Success" then
		clickIng = false
		if msg.state == "NotEnoughMoney" then
			local pop = PopupView:createTextPopup(_tr("money_limit_ask"),function()
        		local shopController = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
        		shopController:enter(ShopCurViewType.PAY)
      			end)
      		GameData:Instance():getCurrentScene():addChildView(pop)
		else
			Toast:showString(self,_tr(msg.state),ccp(display.width/2,display.height*0.4))
		end

        return
    end

    --直接同步数据
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)

    result = (GameData:Instance():getCurrentPlayer():getMoney() - originMoney + AllConfig.quickmoney[self.count+1].money_cost)..""

    echo(""..result)

    self.move[step] = 1
   	self:showResult()
--[[

	GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)

    local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client_sync)

    if table.getn(gainItems) < 1 then
    	echo("返回数据为0")
    	return
    end

    for i = 1,table.getn(gainItems) do
        result = string.format("+%d", gainItems[i].count) + AllConfig.quickmoney[self.count+1].money_cost
        self.move[step] = 1
   	 	self:showResult()
        Toast:showIconNumWithDelay(result, gainItems[i].iconId, gainItems[i].iType, gainItems[i].configId, ccp(display.width/2,display.height*0.4), 0.3*(i-1))
    end
]]
end

local function formatTime(data, value)
    local month = string.sub(data,1,1)

    local t = ""

    if month == "0" then
        t = t..string.sub(data,2,2)
    else
        t = t..string.sub(data,1,2)
    end

    t = t.."月"

    local day = string.sub(data,3,3)

    if day == "0" then
        t = t..(string.sub(data,4,4) - value)
    else
        t = t..(string.sub(data,3,4) - value)
    end

    t = t.."日"

    return t
end

function ActivityMoneyView:showInfo()

	--活动时间
	local time = ""
    for key, activity in pairs(AllConfig.activity) do
        if activity.activity_id == 5016 then
            time = _tr("startTime:%{count1} -- endTime:%{count2}", {count1 = formatTime(string.sub(activity.open_date,5,8), 0),count2 = formatTime(string.sub(activity.close_date,5,8), 1).."23点59分"})
        end
    end
	self.txtLeftTime:setString(time)

	--献祭单价
	self.count = Activity:instance():getActProgress(ACT_ID_QUICK_MONEY)
	if self.count == #AllConfig.quickmoney then
		self.txtDenote:setString("0000")
		self.txtMinMoney:setString("0000")
		self.txtMaxMoney:setString("0000")
	else		
		self.txtDenote:setString(AllConfig.quickmoney[self.count+1].money_cost)
		local drop_data = AllConfig.drop[AllConfig.quickmoney[self.count+1].drop].drop_data
		self.txtMinMoney:setString(drop_data[1].array[3])
		self.txtMaxMoney:setString(drop_data[#drop_data].array[3])
	end

	originMoney = GameData:Instance():getCurrentPlayer():getMoney()

	--获取元宝
	self.txtCurrent:setString(originMoney)

	--抽奖次数
	if #AllConfig.quickmoney - self.count == 0 then
		self.txtLeftNum:setColor(ccc3(255,0,0))
	else
		self.txtLeftNum:setColor(ccc3(255,255,255))
	end
	self.txtLeftNum:setString(#AllConfig.quickmoney - self.count)

end