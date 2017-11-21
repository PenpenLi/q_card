SystemAwardCodeView = class("SystemAwardCodeView",BaseView)
function SystemAwardCodeView:ctor()
   SystemAwardCodeView.super.ctor(self)
   self:setNodeEventEnabled(true)
   self:setTouchEnabled(true)
   self:addTouchEventListener(
    function(event, x, y)
      return true
    end,false, -128, true)
    
   local pkg = ccbRegisterPkg.new(self)
   pkg:addProperty("sprite9AwardCode","CCScale9Sprite")
   pkg:addProperty("labelError","CCLabelTTF")
   pkg:addProperty("label_exchangeCode","CCLabelTTF")
   
   pkg:addFunc("okHandler",SystemAwardCodeView.okHandler)
   pkg:addFunc("cancleHandler",SystemAwardCodeView.cancleHandler)
   
   local layer,owner = ccbHelper.load("SystemAwardCodePopUp.ccbi","SystemAwardCodePopUpCCB","CCLayer",pkg)
   self:addChild(layer)
   
   self.label_exchangeCode:setString(_tr("pls_input_exchange_code"))
   net.registMsgCallback(PbMsgId.AwardCodeResultS2C,self,SystemAwardCodeView.onAwardCodeResultS2C)
   
   self.input = UIHelper.convertBgToEditBox(self.sprite9AwardCode, _tr("input_gift_exchange_code"),22,nil,nil,16)
   self.input:setTouchPriority(-128)
end

function SystemAwardCodeView:onEnter()
   
end

function SystemAwardCodeView:onExit()
    net.unregistAllCallback(self)
end

function SystemAwardCodeView:onAwardCodeResultS2C(action,msgId,msg)
--    NO_ERROR_CODE = 1;
--    NOT_FOUND_CODE = 2;
--    CODE_IS_USEED = 3;
--    YOU_USED_CODE = 5;
--    SYSTEM_ERROR = 4;
--    if  self._loadingshow ~= nil then
--      self._loadingshow:remove()
--      self._loadingshow = nil 
--    end
    _hideLoading()
    
    local message = "" 
    if msg.error == "NO_ERROR_CODE" then
       message = _tr("exchange_success")
       self:removeFromParentAndCleanup(true)
    elseif msg.error == "NOT_FOUND_CODE" then
       message = _tr("active_code_error")
    elseif msg.error == "CODE_IS_USEED" then
       message = _tr("active_code_used")
    elseif msg.error == "YOU_USED_CODE" then
       message = _tr("active_code_used_twice")
    elseif msg.error == "SYSTEM_ERROR" then
       message = _tr("exchange_fail")
    end
    
    local pop = PopupView:createTextPopup(message,function() end,true)
    GameData:Instance():getCurrentScene():addChildView(pop)
end

function SystemAwardCodeView:okHandler()
   if self.input:getText() == "" then
      echo("can not be empty")
      return
   end
   
--   if self._loadingshow == nil then
--     self._loadingshow = Loading:show()
--   end
   
   _showLoading()
   local data = PbRegist.pack(PbMsgId.AwardCodeC2S,{code = self.input:getText()})
   net.sendMessage(PbMsgId.AwardCodeC2S,data)
   
end

function SystemAwardCodeView:cancleHandler()
   self:removeFromParentAndCleanup(true)
end

return SystemAwardCodeView