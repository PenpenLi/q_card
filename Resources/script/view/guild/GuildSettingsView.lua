require("model.guild.GuildBase")
require("view.guild.GuildFlagSettingsView")

GuildSettingsView = class("GuildSettingsView",BaseView)
local touchPriority = -256
function GuildSettingsView:ctor()
  GuildSettingsView.super.ctor(self)
  self:setNodeEventEnabled(true)
  self:setTouchEnabled(true)
  self:addTouchEventListener(function() return true end,false, touchPriority, true)
end

function GuildSettingsView:onEnter()
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("txtLevel","CCLabelTTF")
  pkg:addProperty("nodeFlag","CCNode")
  
  pkg:addProperty("menuParent","CCMenu")
  pkg:addProperty("btnPre2","CCMenuItemImage")
  pkg:addProperty("btnNext2","CCMenuItemImage")
  pkg:addProperty("btnConfirm","CCMenuItemImage")
  pkg:addProperty("btnClose","CCMenuItemImage")
  
  pkg:addFunc("changeFlagHandler",GuildSettingsView.changeFlagHandler)
  
  
  
  local node,owner = ccbHelper.load("guildSetting.ccbi","guildSetting","CCLayer",pkg)
  self:addChild(node)

  self.menuParent:setTouchPriority(touchPriority)
  
  

  local levels = {30,40,50,60,70}
  local levelIdx = 1
  local myGuildBase = Guild:Instance():getSelfGuildBase()

  for key, level in pairs(levels) do
  	if myGuildBase:getApplyLevel() == level then
  	 levelIdx = key
  	 break
  	end
  end
  self.txtLevel:setString(levels[levelIdx].."")

  self.btnClose:registerScriptTapHandler(function() 
    self:removeFromParentAndCleanup(true) 
  end)
  
  self.btnPre2:registerScriptTapHandler(function() 
    levelIdx = levelIdx - 1
    if levelIdx < 1 then
      levelIdx = #levels
    end
    
    self.txtLevel:setString(levels[levelIdx].."")
  end)
  
  self.btnNext2:registerScriptTapHandler(function()
   levelIdx = levelIdx + 1
   if levelIdx > #levels then
    levelIdx = 1
   end
   self.txtLevel:setString(levels[levelIdx].."")
  end)
  
  local seuccessHandler = function()
    self:removeFromParentAndCleanup(true)
  end
  
  self.btnConfirm:registerScriptTapHandler(function()
    --Guild:reqGuildChangeBaseC2S(guild_notice,guild_flag,apply_level)
    Guild:Instance():reqGuildChangeBaseC2S(myGuildBase:getNotice(),myGuildBase:getFlag(),levels[levelIdx],seuccessHandler)
  end)
  
  
  
  if myGuildBase ~= nil then
    local flagIcon = Guild:Instance():getFlagIconByInt(myGuildBase:getFlag())
    flagIcon:setScale(0.8)
    self.nodeFlag:addChild(flagIcon)
  end
  
end

function GuildSettingsView:updateView()
  self.nodeFlag:removeAllChildrenWithCleanup(true)
  local flagIcon = Guild:Instance():getFlagIconByInt(Guild:Instance():getTempFlagId())
  flagIcon:setScale(0.8)
  self.nodeFlag:addChild(flagIcon)
end

function GuildSettingsView:changeFlagHandler()
  local guildFlagSettingsView = GuildFlagSettingsView.new()
  guildFlagSettingsView:setDelegate(self)
  GameData:Instance():getCurrentScene():addChildView(guildFlagSettingsView)
end


return GuildSettingsView