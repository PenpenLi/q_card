require("view.system.SystemSettingsView")
require("view.system.SystemBlindPopView")
require("view.system.SystemAwardCodeView")
require("view.system.SystemContact")
require("view.system.ChannelShareView")

SystemView = class("SystemView",ViewWithEave)
function SystemView:ctor(delegate)
  SystemView.super.ctor(self)
  self:setDelegate(delegate)
  self:setNodeEventEnabled(true)
end

function SystemView:onEnter()
  SystemView.super:onEnter()
  self:getEaveView().btnHelp:setVisible(false)
  display.addSpriteFramesWithFile("settings/settings0.plist", "settings/settings0.png")
  self:setTitleTextureName("#system-image-paibian.png")
  local menuArray
  local targetPlatform = CCApplication:sharedApplication():getTargetPlatform()
  if kTargetIphone == targetPlatform or  targetPlatform == kTargetWindows then
    menuArray = 
    {
      {"#system-button-nor-shezhi.png","#system-button-sel-shezhi.png"},
      {"#system-button-nor-kefu.png","#system-button-sel-kefu.png"},
    }
    
    if IOS_SHARE_ENABLED > 0 then
      local shareMenu = {"#system-button-nor-fenxiang.png","#system-button-fenxiang.png"}
      table.insert(menuArray,1,shareMenu)
    end
  else
    menuArray = 
    {
      {"#system-button-nor-shezhi.png","#system-button-sel-shezhi.png"},
      {"#system-button-nor-kefu.png","#system-button-sel-kefu.png"},
    }
  end
  self:setMenuArray(menuArray)
  self:setScrollBgVisible(false)
  self:tabControlOnClick(0)
end

function SystemView:setCurrentView(CurrentView)
	self._CurrentView = CurrentView
end

function SystemView:getCurrentView()
	return self._CurrentView
end

function SystemView:popupBlind()
  local pop = SystemBlindPopView.new()
  pop:setDelegate(self:getDelegate())
  self:addChild(pop)
end

function SystemView:popupAwardCode()
  local pop = SystemAwardCodeView.new()
  self:addChild(pop)
end



function SystemView:tabControlOnClick(idx)
  self._index = idx
  if self:getCurrentView() ~= nil then
     self:getCurrentView():removeFromParentAndCleanup(true)
     self:setCurrentView(nil)
  end
  local targetPlatform = CCApplication:sharedApplication():getTargetPlatform()
  
  if kTargetIphone == targetPlatform or targetPlatform == kTargetWindows then
      
      if IOS_SHARE_ENABLED <= 0 then
        idx = idx + 1
      end
      
      if idx == 0 then
       local contentSize=self:getCanvasContentSize()
       local mSize = CCSizeMake(display.size.width,contentSize.height)
       local channelShareView = ChannelShareView.new(mSize)
       self:addChild(channelShareView)
       self:setCurrentView(channelShareView)
      elseif idx == 1 then  
        local systemSettingsView = SystemSettingsView.new(self)
        self:addChild(systemSettingsView)
        self:setCurrentView(systemSettingsView)
      elseif idx == 2 then
        local kf = SystemContact.new()
        self:addChild(kf)
        kf:setPosition(ccp(display.cx - kf:getContentSize().width/2 ,130 + self:getCanvasContentSize().height - kf:getContentSize().height - 80))
        self:setCurrentView(kf)
      end
  else
      if idx == 0 then
        local systemSettingsView = SystemSettingsView.new(self)
        self:addChild(systemSettingsView)
        self:setCurrentView(systemSettingsView)
      elseif idx == 1 then
        local kf = SystemContact.new()
        self:addChild(kf)
        kf:setPosition(ccp(display.cx - kf:getContentSize().width/2 ,130 + self:getCanvasContentSize().height - kf:getContentSize().height - 80))
        self:setCurrentView(kf)
      end
  end
end

function SystemView:updateView()
  self:tabControlOnClick(self._index)
end

function SystemView:onExit()
  display.removeSpriteFramesWithFile("settings/settings0.plist", "settings/settings0.png")
  SystemView.super:onExit()
end

function SystemView:onHelpHandler()
    local helpView = HelpView.new(1039)
    GameData:Instance():getCurrentScene():addChildView(helpView)
    SystemView.super:onHelpHandler()
end

function SystemView:onBackHandler()
  local controller = ControllerFactory:Instance():create(ControllerType.HOME_CONTROLLER)
  controller:enter()
end

return SystemView