require("controller.BaseController")  
require("view.regist.LoginView")  

LoginController = class("LoginController",BaseController)

function LoginController:ctor()
  LoginController.super.ctor(self, "LoginController")
end

function LoginController:enter()
  LoginController.super.enter(self)
  Guide:Instance():setGuideStepIdWhenOffLine(nil)
  self:setScene(GameData:Instance():getCurrentScene())
  self.view = LoginView.new(self)
  self:getScene():replaceView(self.view,true,false)
  self:getScene():getNoticeView():setVisible(false)
end

function LoginController:logout(isLogout)
   net.isActiveDisconnect = true
   net.sendAction(NetAction.REQ_DISCONNECT)
   net.isConnected = false
   GameData:Instance():getCurrentAccount():reqLogout()
   if isLogout == true then
     self.view:onClickLogout()
   end

   MailBox:instance():reset()
   GameData:Instance():setInitSysComplete(false)
   Activity:instance():cleanup()
end

function LoginController:exit()
  LoginController.super.exit(self)
  self:getScene():getNoticeView():setVisible(true)
  self.view = nil
end
function LoginController:setSwitchFlag(flag)
 if self.view~=nil then
  self.view:setSwitchFlag(flag)
 end
end
function LoginController:sdkLogout()
 if self.view~=nil then
   if self.view:isInSdkPlugin(ChannelManager:getCurrentLoginChannel()) then
     SdkPluginManager:getInstance():logout()
   end
 end
end


return LoginController