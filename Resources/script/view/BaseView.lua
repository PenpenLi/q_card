
BaseView = class("BaseView", function()
    return display.newLayer()
end)

function BaseView:ctor(name)
  self.name = name
 -- echo("BaseView ctor:%s",self.name)
 self:setNodeEventEnabled(true)
end

function BaseView:setDelegate(controller) --here can set controller or any kinds of delegate you want
	self._controller = controller
end

function BaseView:getDelegate()
	return self._controller
end

function BaseView:onEnter()
  --printf("--:onEnter")
end


function BaseView:onExit()
  printf("--:onExit")
end
return BaseView