require("view.BaseScene")  

BaseController = class("BaseController")
BaseController._lastController = nil
function BaseController:ctor()
  printf("BaseController ctor")
  if self:getScene() == nil then
    self:setScene(GameData:Instance():getCurrentScene())
  end
  
end

function BaseController:enter()
  echo("BaseController enter: ["..self.__cname.."] enter")
  echo("BaseController._lastController", BaseController._lastController)
  if BaseController._lastController ~= nil then
    BaseController._lastController:exit()
    Guide:Instance():unregistAllComponent(BaseController._lastController:getControllerType())
    display.removeUnusedSpriteFrames()
    display.addSpriteFramesWithFile("top_bottom/top_bottom.plist", "top_bottom/top_bottom.png")
    display.addSpriteFramesWithFile("common/common.plist", "common/common.png")
    BaseController._lastController = nil
  end
  BaseController._lastController = self
end

------
--  Getter & Setter for
--      BaseController._ControllerType 
-----
function BaseController:setControllerType(ControllerType)
	self._ControllerType = ControllerType
end

function BaseController:getControllerType()
	return self._ControllerType
end

function BaseController:exit()
  if nil ~= BaseController._lastController then
    echo("last controller:["..BaseController._lastController.__cname.."] exit")
  end
  -- display.removeUnusedSpriteFrames()
  -- display.addSpriteFramesWithFile("top_bottom/top_bottom.plist", "top_bottom/top_bottom.png")
  -- display.addSpriteFramesWithFile("common/common.plist", "common/common.png")
end

function BaseController:setScene(scene)
	self._scene = scene
end

function BaseController:getScene()
	return self._scene
end

return BaseController