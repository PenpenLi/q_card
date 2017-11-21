SystemBlindPopView = class("SystemBlindPopView",BaseView)

function SystemBlindPopView:ctor()
   SystemBlindPopView.super.ctor(self)
   self:setNodeEventEnabled(true)
   self:setTouchEnabled(true)
   self:addTouchEventListener(
    function(event, x, y)
      return true
    end,false, -128, true)
    
	 local pkg = ccbRegisterPkg.new(self)
	 pkg:addProperty("sprite9Acount","CCScale9Sprite")
   pkg:addProperty("sprite9PassWord","CCScale9Sprite")
   pkg:addProperty("sprite9RePassWord","CCScale9Sprite")
   pkg:addProperty("labelError","CCLabelTTF")
   
   pkg:addFunc("registHandler",SystemBlindPopView.registHandler)
   pkg:addFunc("cancleHandler",SystemBlindPopView.cancleHandler)
   
   local layer,owner = ccbHelper.load("SystemPopUp.ccbi","SystemPopUpCCB","CCLayer",pkg)
   self:addChild(layer)
   
   self.inputUserName = UIHelper.convertBgToEditBox(self.sprite9Acount,_tr("login_username_tip2"),22,nil,nil,100)
   self.inputUserName:setTouchPriority(-128)
   self.inputPassword = UIHelper.convertBgToEditBox(self.sprite9PassWord,_tr("pls_input_psw"),22,nil,true,16)
   self.inputPassword:setTouchPriority(-128)
   self.reInputPassword = UIHelper.convertBgToEditBox(self.sprite9RePassWord,_tr("pls_input_psw2"),22,nil,true,16)
   self.reInputPassword:setTouchPriority(-128)
end

function SystemBlindPopView:onEnter()
  self:setScale(0.2)
  self:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6) )
end

function SystemBlindPopView:isRightEmail(str)
     if string.len(str or "") < 6 then return false end
     local b,e = string.find(str or "", '@')
     local bstr = ""
     local estr = ""
     if b then
         bstr = string.sub(str, 1, b-1)
         estr = string.sub(str, e+1, -1)
     else
         return false
     end
 
     -- check the string before '@'
     local p1,p2 = string.find(bstr, "[%w_]+")
     if (p1 ~= 1) or (p2 ~= string.len(bstr)) then return false end
     
     -- check the string after '@'
     if string.find(estr, "^[%.]+") then return false end
     if string.find(estr, "%.[%.]+") then return false end
     if string.find(estr, "@") then return false end
     if string.find(estr, "[%.]+$") then return false end
 
     local _,count = string.gsub(estr, "%.", "")
     if (count < 1 ) or (count > 3) then
         return false
     end
 
     return true
 end 

function SystemBlindPopView:registHandler()

   --each input can not be empty
   if self.inputUserName:getText() == "" then
      echo("can not be empty")
      self.labelError:setString(_tr("empty_name"))
      return
   end
   
   local isRightEmail = self:isRightEmail(self.inputUserName:getText())
   if isRightEmail == false then
      echo("user name must be an e-mail adress")
      self.labelError:setString(_tr("pls_input_correct_mail_account"))
      return
   end
   
   if self.inputPassword:getText() == "" then
      echo("can not be empty")
      self.labelError:setString(_tr("pls_input_psw"))
      return
   end
   
   if string.find( self.inputPassword:getText()," ") then
      self.labelError:setString(_tr("psw_permit_space"))
      return
   end
   
   
    if self.reInputPassword:getText() == ""  then
      echo("can not be empty")
      self.labelError:setString(_tr("pls_input_psw2"))
      return
   end
   
   
   -- check password
   if self.inputPassword:getText() ~= self.reInputPassword:getText() then
      echo("pls in put same password twice")
      self.labelError:setString(_tr("psw_not_identical"))
      return
   end
   
   if string.len(self.inputPassword:getText()) < 6 or string.len(self.inputPassword:getText()) > 14 then
      self.labelError:setString(_tr("psw_should_between_6_14"))
      return
   end
   
   -- do chang
   self:getDelegate():changeUserNameAndPassword(self.inputUserName:getText(),self.inputPassword:getText())
   self:cancleHandler()
end

function SystemBlindPopView:cancleHandler()
   echo("cancleHandler")
   self:removeFromParentAndCleanup(true)
end

return SystemBlindPopView