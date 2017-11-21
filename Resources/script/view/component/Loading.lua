
require("view.component.Mask")
Loading = class("Mask",function()  return display.newLayer() end)

Loading._Instance = nil
function Loading:Instance()
	if Loading._Instance == nil then
		Loading._Instance = Loading.new()
	end
	return Loading._Instance
end

function Loading:ctor()
	print("-------------loading------------timeout remove flag=:", self.bTimeOutRemove)
	local animationBg = _res(3022026)
	self:addChild(animationBg)
	animationBg:setPosition(ccp(display.cx,display.cy))

	local loading_sprite,offsetX,offsetY = _res(5020139)
	loading_sprite:setPosition(ccp(display.cx + offsetX + 15,display.cy + offsetY + 20))
	loading_sprite:setScaleY(0.8)
	loading_sprite:setScaleX(-0.8)
	loading_sprite:getAnimation():play("default") 
	
	self:addChild(loading_sprite)

	self.view = Mask.new({opacity = 80,priority = -140})
	self.view:addChild(self)

	local action
	local second = 0
	local function delayRemove()
		second = second + 1
		if second >= 10  then
			print("==== loading over 10 second ")
			self:stopAction(action)
			self:remove()
			CCNotificationCenter:sharedNotificationCenter():postNotification(EventType.LOADING_TIMEOUT)
		end
	end
	if self.bTimeOutRemove == true then
		action = self:schedule(delayRemove,1)
	end
end


function Loading:show(para)
--	if Loading._Instance ~= nil then
--		self.view:remove()
--	end
	self.bTimeOutRemove = true
	local localPara = para or {}
	if  localPara.timeOutRemove ~= nil and localPara.timeOutRemove == false then
		self.bTimeOutRemove = false
	end

	local loading = Loading.new()
	loading.view:show()
	return loading
end

function Loading:hide()
	self.view:hide()
end

function Loading:remove()
	self:stopAllActions()
	self.view:remove()
end

return Loading
