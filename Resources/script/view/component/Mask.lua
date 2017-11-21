
--[[

遮挡层 (模态框)

** Return **
    CCLayerColor

]]

Mask = class("Mask",function()  return CCLayerColor:create() end)



local function onTouch(self,eventType , x , y)
	if eventType == "began" then
		--print("Mask began")
		return true
	end
	if eventType == "moved" then return true end

	if eventType == "ended" then
		-- 点击回调函数
		--clickFunc(x , y)
		return true
	end
	return false
end


function Mask:ctor(args)

	local args = args or {}

	local r = args.r or 0
	local g = args.g or 0
	local b = args.b or 0
	local opacity = args.opacity or 100         -- 透明度
	local priority = args.priority or -129      -- 优先级
	local item = args.item or nil               -- 额外 addChild 上去的元素

	self:setColor(ccc3(r,g,b))
	self:setOpacity(opacity)

	-- 屏蔽点击
	self:setTouchEnabled( true )
	self:addTouchEventListener(handler(self,onTouch ), false , priority , true)

	-- 附加的item 可选
	if item ~= nil then
		self:addChild(item)
	end
end

function Mask:show()
	print("mask show")
	local scene =  GameData:Instance():getCurrentScene()
	scene:addChild(self,9999999)
end

function Mask:hide()
	self:setVisible(false)
end

function Mask:remove()
	xpcall(function()
	self:removeFromParentAndCleanup(true)
	end, __G__TRACKBACK__)
end

return Mask



