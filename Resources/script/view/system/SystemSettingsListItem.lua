require("view.regist.RegistDocumentView")
SystemSettingsListItem = class("SystemSettingsListItem",BaseView)

-- type
-- 1 : account
-- 2 : sound
-- 3 : music
-- 4 : award code
-- 5 : gong gao
-- 6 : ke fu
-- 7 : auto lock
function SystemSettingsListItem:ctor(type)
	SystemSettingsListItem.super.ctor(self)
	local pkg = ccbRegisterPkg.new(self)

  pkg:addProperty("spriteTitleAcount","CCSprite")
  pkg:addProperty("spriteTitleSoundEffect","CCSprite")
  pkg:addProperty("spriteAwardCodeTitle","CCSprite")
  pkg:addProperty("spriteTitleMusic","CCSprite")
  pkg:addProperty("spriteGongGaoTitle","CCSprite")
  pkg:addProperty("spriteKeFuTitle","CCSprite")
  pkg:addProperty("spriteAutoLockTitle","CCSprite")
  
  pkg:addProperty("btnOpen","CCMenuItemImage")
  pkg:addProperty("btnBinding","CCMenuItemImage")
  pkg:addProperty("btnClose","CCMenuItemImage")
  pkg:addProperty("btnExit","CCMenuItemImage")
  pkg:addProperty("btnGetAward","CCMenuItemImage")
  pkg:addProperty("btnReWrite","CCMenuItemImage")
  pkg:addProperty("btnChaKan","CCMenuItemImage")
  
  pkg:addFunc("onCloseHandler",SystemSettingsListItem.onCloseHandler)
  pkg:addFunc("onBindingHandler",SystemSettingsListItem.onBindingHandler)
  pkg:addFunc("onOpenHandler",SystemSettingsListItem.onOpenHandler)
  pkg:addFunc("onExitHandler",SystemSettingsListItem.onExitHandler)
  pkg:addFunc("reWriteHandler",SystemSettingsListItem.reWriteHandler)
  pkg:addFunc("onClickAwardCodeHanler",SystemSettingsListItem.onClickAwardCodeHanler)
  pkg:addFunc("onClickChaKanHanler",SystemSettingsListItem.onClickChaKanHanler)
  
  
  local layer,owner = ccbHelper.load("SystemListItem.ccbi","SystemSettingsListItemCCB","CCLayer",pkg)
  self:addChild(layer)
  
--  self.btnGetAward:setVisible(false)
--  self.spriteAwardCodeTitle:setVisible(false)
  if type == 1 then -- account
--     self.spriteTitleSoundEffect:setVisible(false)
--     self.spriteTitleMusic:setVisible(false)
--     self.btnOpen:setVisible(false)
--     self.btnClose:setVisible(false)
--     self.btnExit:setVisible(false)
--     self.btnReWrite:setVisible(false)
     self.spriteTitleAcount:setVisible(true)
     local netCongig = GameData:Instance():getCurNetItem()
     --local userName = CCUserDefault:sharedUserDefault():getStringForKey("user_name_"..netCongig.area)
     local userName = GameData:Instance():getCurrentAccount():getName()
     if string.byte(userName) == 35 then -- first char is #
     
     else
        self.btnBinding:setVisible(false)
        self.btnExit:setVisible(true)
     end
  elseif type == 2 then  --sound
--     self.spriteTitleAcount:setVisible(false)
--     self.spriteTitleMusic:setVisible(false)
--     self.btnBinding:setVisible(false)
--     self.btnExit:setVisible(false)
--     self.btnReWrite:setVisible(false)
--     self.btnOpen:setVisible(false)
     self.spriteTitleSoundEffect:setVisible(true)
     self.btnClose:setVisible(true)
     if CCUserDefault:sharedUserDefault():getStringForKey("sound_on") == "true" or CCUserDefault:sharedUserDefault():getStringForKey("sound_on") == nil then
         self.btnOpen:setVisible(false)
         self.btnClose:setVisible(true)
      elseif CCUserDefault:sharedUserDefault():getStringForKey("sound_on") == "false" then
         self.btnOpen:setVisible(true)
         self.btnClose:setVisible(false)
      end
  elseif type == 3 then -- music
--     self.spriteTitleAcount:setVisible(false)
--     self.spriteTitleSoundEffect:setVisible(false)
--     self.btnBinding:setVisible(false)
--     self.btnOpen:setVisible(false)
       self.btnClose:setVisible(true)
       self.spriteTitleMusic:setVisible(true)
--     self.btnExit:setVisible(false)
--     self.btnReWrite:setVisible(false)
      if CCUserDefault:sharedUserDefault():getStringForKey("music_on") == "true" or CCUserDefault:sharedUserDefault():getStringForKey("music_on") == nil then
         self.btnOpen:setVisible(false)
         self.btnClose:setVisible(true)
      elseif CCUserDefault:sharedUserDefault():getStringForKey("music_on") == "false" then
         self.btnOpen:setVisible(true)
         self.btnClose:setVisible(false)
      end
  elseif type == 4 then --award code
--       self.spriteTitleSoundEffect:setVisible(false)
--       self.spriteTitleMusic:setVisible(false)
--       self.spriteTitleAcount:setVisible(false)
--       self.spriteTitleSoundEffect:setVisible(false)
--       self.btnBinding:setVisible(false)
--       self.btnOpen:setVisible(false)
--       self.btnClose:setVisible(false)
--       self.btnExit:setVisible(false)
--       self.btnReWrite:setVisible(false)
       self.btnGetAward:setVisible(true)
       self.spriteAwardCodeTitle:setVisible(true)
 
  elseif type == 5 then --gonggao
       self.spriteGongGaoTitle:setVisible(true)
       self.btnChaKan:setVisible(true)
  elseif  type == 6 then --kefu
       self.spriteKeFuTitle:setVisible(true)
       self.btnChaKan:setVisible(true)
  elseif type == 7 then -- auto lock
    self.spriteAutoLockTitle:setVisible(true)
    if GameData:Instance():getWakeLockState() == true then
       self.btnOpen:setVisible(false)
       self.btnClose:setVisible(true)
    else
       self.btnOpen:setVisible(true)
       self.btnClose:setVisible(false)
    end
  elseif type == 8 then --user 1
       self.spriteGongGaoTitle:setVisible(true)
       self.btnChaKan:setVisible(true)
       
       local frame = display.newSpriteFrame("system-image-user1.png")
       self.spriteGongGaoTitle:setDisplayFrame(frame)
  elseif type == 9 then --user 2
       self.spriteGongGaoTitle:setVisible(true)
       self.btnChaKan:setVisible(true)
       
       local frame = display.newSpriteFrame("system-image-user2.png")
       self.spriteGongGaoTitle:setDisplayFrame(frame)
  end
  self.type = type
end

function SystemSettingsListItem:onCloseHandler()
  echo("onCloseHandler")
  if self.type == 2 then
     self:toggleSound()
  end
  if self.type == 3 then
     self:toggleMusic()
  end
  if self.type == 7 then
     GameData:Instance():closeWakeLock()
     self:toggleAutoLock()
  end
end

function SystemSettingsListItem:onClickChaKanHanler()
  if self.type == 5 then
     local noticeView = LoginNoticeView.new()
     noticeView:setDelegate(nil)
     GameData:Instance():getCurrentScene():addChildView(noticeView,1000)
  elseif self.type == 6 then
    if CCUserDefault:sharedUserDefault():getStringForKey("music_on") == "true" or CCUserDefault:sharedUserDefault():getStringForKey("music_on") == nil then
       self.btnOpen:setVisible(false)
       self.btnClose:setVisible(true)
    elseif CCUserDefault:sharedUserDefault():getStringForKey("music_on") == "false" then
       self.btnOpen:setVisible(true)
       self.btnClose:setVisible(false)
    end
  elseif self.type == 7 then
  
  elseif self.type == 8 or self.type == 9 then
    local doc = RegistDocumentView.new(nil,self.type)
    GameData:Instance():getCurrentScene():addChildView(doc)
  end
end

function SystemSettingsListItem:onExitHandler()
  echo("exitHandler")
  
  local loginfun = function()
    --GameData:Instance():setEnabledActiveTipDisconnect(false)
    --net.sendAction(NetAction.REQ_DISCONNECT)
    local registController = ControllerFactory:Instance():create(ControllerType.REGIST_CONTROLLER)
    registController:enter()
    registController:logout()
  end
  
  local  pop = PopupView:createTextPopup(_tr("return_login_view?"), function() return loginfun()  end)
  self:getDelegate():getDelegate():getScene():addChildView(pop,100)
end

function SystemSettingsListItem:onClickAwardCodeHanler()
  self:getDelegate():popupAwardCode()
end

function SystemSettingsListItem:reWriteHandler()
  self:getDelegate():popupBlind()
end


function SystemSettingsListItem:onBindingHandler()
  echo("onBindingHandler")
  self:getDelegate():popupBlind()
end

function SystemSettingsListItem:onOpenHandler()
  echo("onOpenHandler")
  
  if self.type == 2 then
     self:toggleSound()
  end
  
  if self.type == 3 then
     self:toggleMusic()
  end
  
  if self.type == 7 then
     GameData:Instance():openWakeLock()
     self:toggleAutoLock()
  end
end

function SystemSettingsListItem:toggleAutoLock()
   if GameData:Instance():getWakeLockState() == true then
      self.btnOpen:setVisible(false)
      self.btnClose:setVisible(true)
   else
      self.btnOpen:setVisible(true)
      self.btnClose:setVisible(false)
   end
end

function SystemSettingsListItem:toggleSound()
   local soundOn = self:getDelegate():getDelegate():toggleSound()
   if soundOn == true then
      self.btnOpen:setVisible(false)
      self.btnClose:setVisible(true)
   else
      self.btnOpen:setVisible(true)
      self.btnClose:setVisible(false)
   end
end

function SystemSettingsListItem:toggleMusic()
   local musicOn = self:getDelegate():getDelegate():toggleMusic()
   if musicOn == true then
      self.btnOpen:setVisible(false)
      self.btnClose:setVisible(true)
   else
      self.btnOpen:setVisible(true)
      self.btnClose:setVisible(false)
   end
end

return SystemSettingsListItem