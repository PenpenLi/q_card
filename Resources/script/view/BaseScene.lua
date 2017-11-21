
BaseScene = class("BaseScene", function(name)
    return display.newScene(name)
end)

function BaseScene:ctor()
  echo("BaseScene ctor~")
   self._view = nil
   self._viewContainer = display.newNode()
   self:addChild(self._viewContainer)
   
end

function BaseScene:replaceView(view)
  self._viewContainer:removeAllChildrenWithCleanup(true)
  self._view = view
  if view ~= nil then
    self._viewContainer:addChild(view)
    echo("replaced view@@@")
  end
end

function BaseScene:getCurrentView()
  return self._view
end

return BaseScene