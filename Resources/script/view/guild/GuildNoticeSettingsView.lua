require("model.guild.GuildBase")
GuildNoticeSettingsView = class("GuildNoticeSettingsView",BaseView)
local touchPriority = -256
function GuildNoticeSettingsView:ctor()
  GuildNoticeSettingsView.super.ctor(self)
  self:setNodeEventEnabled(true)
  self:setTouchEnabled(true)
  self:addTouchEventListener(function() return true end,false, touchPriority, true)
end

function GuildNoticeSettingsView:onEnter()
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("inputBg","CCScale9Sprite")
  pkg:addProperty("menuParent","CCMenu")
  pkg:addProperty("btnConfirm","CCMenuItemImage")
  pkg:addProperty("btnClose","CCMenuItemImage")
  
  local node,owner = ccbHelper.load("guild_notice_edit.ccbi","guild_notice_edit","CCLayer",pkg)
  self:addChild(node)

  self.menuParent:setTouchPriority(touchPriority)
  local size = self.inputBg:getContentSize()
  local fontSize = 24
  local targetPlatform = CCApplication:sharedApplication():getTargetPlatform()
  if kTargetIphone == targetPlatform or kTargetIpad == targetPlatform then 
    self._fieldGuildNotice = EditBoxExt2.converImgToEditBox(self.inputBg, "Courier-Bold", fontSize, nil, CCSizeMake(size.width, size.height-fontSize))      
  else 
    self._fieldGuildNotice = EditBoxExt.converImgToEditBox(self.inputBg, "Courier-Bold", fontSize, nil, CCSizeMake(size.width, size.height-fontSize))
  end 
  self._fieldGuildNotice:setTouchPriority(-256)

  local myGuildBase = Guild:Instance():getSelfGuildBase()
  self._fieldGuildNotice:setText(myGuildBase:getNotice())
 
  self.btnClose:registerScriptTapHandler(function() 
    self:removeFromParentAndCleanup(true) 
  end)
  
  self.btnConfirm:registerScriptTapHandler(function()
    --Guild:reqGuildChangeBaseC2S(guild_notice,guild_flag,apply_level)
    local inputText = self._fieldGuildNotice:getText()
    
    if Guild:Instance():isRightLength(inputText,96) == false then
      Toast:showString(self,_tr("guild_notice_length_tip"), ccp(display.cx, display.cy))
      return
    end
    
    local successHandler = function()
      self:removeFromParentAndCleanup(true)
    end
    
    Guild:Instance():reqGuildChangeBaseC2S(inputText,myGuildBase:getFlag(),myGuildBase:getApplyLevel(),successHandler)
  end)
  
end

return GuildNoticeSettingsView