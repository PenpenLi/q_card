require("view.system.SystemView")
SystemController = class("SystemController",BaseController)

function SystemController:enter()
  SystemController.super.enter(self)
  self:regChangeUserNameAndPassWordNetSever()
  local systemView = SystemView.new(self)
  self.view = systemView
  self:getScene():replaceView(systemView)
end

function SystemController:toggleSound()
  local soundOn = SoundManager.toggleSnd()
    CCUserDefault:sharedUserDefault():setStringForKey("sound_on", tostring(soundOn))
    CCUserDefault:sharedUserDefault():flush()
  return soundOn
end

function SystemController:toggleMusic()
    local musicOn = SoundManager.toggleMusic()
    CCUserDefault:sharedUserDefault():setStringForKey("music_on", tostring(musicOn))
    CCUserDefault:sharedUserDefault():flush()
    return musicOn
end

function SystemController:regChangeUserNameAndPassWordNetSever()
   net.registMsgCallback(PbMsgId.PlayerChangeUserNameResult,self,SystemController.onPlayerChangeUserNameResult)
   net.registMsgCallback(PbMsgId.PlayerChangePasswardResult,self,SystemController.onPlayerChangePasswardResult)
end

function SystemController:changeUserNameAndPassword(user_name,password)
   self._saveStep = 0
   self._userName = user_name
   self._passWord = password
   self:changeChangeUserNameToSever(user_name)
   self:changePassWordToSever(password)
end

function SystemController:changeChangeUserNameToSever(user_name)
   if user_name ~= nil then
     local data = PbRegist.pack(PbMsgId.PlayerChangeUserName,{name = user_name})
     net.sendMessage(PbMsgId.PlayerChangeUserName,data)
   end
end

function SystemController:changePassWordToSever(password)
   
   if password ~= nil then
     local data = PbRegist.pack(PbMsgId.PlayerChangePassward,{passward = password})
     net.sendMessage(PbMsgId.PlayerChangePassward,data)
   end
end

function SystemController:onPlayerChangeUserNameResult(action,msgId,msg)
   local pop = nil
   if msg.state == "Ok" then
      GameData:Instance():getCurrentAccount():setName(self._userName)
      self._saveStep = self._saveStep + 1
      if self._saveStep == 2 then
         GameData:Instance():getCurrentAccount():save()
         pop = PopupView:createTextPopup(_tr("account_binding_ok"), function() return end,true)
         GameData:Instance():getCurrentScene():addChildView(pop)
         self.view:updateView()
      end         
   elseif msg.state =="HasSameUserName" then
      pop = PopupView:createTextPopup(_tr("user_name_not_allow"), function() return end,true)
      GameData:Instance():getCurrentScene():addChildView(pop)
   elseif msg.state =="HasBindUserName" then 
      pop = PopupView:createTextPopup(_tr("user_name_has_bind"), function() return end,true)
      GameData:Instance():getCurrentScene():addChildView(pop)
   elseif msg.state == "ThirdChannelNotAllow" then
   
   else
      pop = PopupView:createTextPopup(_tr("account_binding_ok"), function() return end,true)
      GameData:Instance():getCurrentScene():addChildView(pop)
   end
end

function SystemController:onPlayerChangePasswardResult(action,msgId,msg)
   local pop = nil
   if msg.state == "Ok" then
       GameData:Instance():getCurrentAccount():setPassword(self._passWord)
       self._saveStep = self._saveStep + 1
       if self._saveStep == 2 then
         GameData:Instance():getCurrentAccount():save()
         pop = PopupView:createTextPopup(_tr("account_binding_ok"), function() return end,true)
         GameData:Instance():getCurrentScene():addChildView(pop)
         self.view:updateView()
       end
   elseif msg.state == "AccountNotBind" then
      pop = PopupView:createTextPopup(_tr("pls_bind_before_repassword"), function() return end,true)
      GameData:Instance():getCurrentScene():addChildView(pop)
   elseif msg.state == "ThirdChannelNotAllow" then
      pop = PopupView:createTextPopup(_tr("account_bind_faild"), function() return end,true)
      GameData:Instance():getCurrentScene():addChildView(pop)
   else
      pop = PopupView:createTextPopup(_tr("account_bind_faild"), function() return end,true)
      GameData:Instance():getCurrentScene():addChildView(pop)
   end
end

function SystemController:exit()
    net.unregistAllCallback(self)
    SystemController.super.exit(self)
end

return SystemController