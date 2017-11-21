require("view.BaseView")
require("view.component.OrbitCard")
require("view.component.Mask")
require("view.component.Loading")
require("view.component.SequenceAnim")
require("view.regist.RegistDocumentView")
require("view.regist.StoryPrintView")


LoginView = class("LoginView", BaseView)


function LoginView:ctor(controller)

  -- enable layer event
  self:setNodeEventEnabled(true)
  self._controller = controller
  LoginType = enum({"CREATE","LOGIN_WITH_PASSWORD"})
  self.loginType = LoginType.CREATE
  local pkg = ccbRegisterPkg.new(self)
  
  pkg:addFunc("onClickInputLogin",LoginView.onClickInputLogin)
  pkg:addFunc("onClickLogin",LoginView.onClickLogin)
  pkg:addFunc("onClickRegist",LoginView.onClickRegist)
  pkg:addFunc("onClickShowPanelAccount",LoginView.onClickShowPanelAccount)
  pkg:addFunc("onClickEnterGame",LoginView.onClickEnterGame)
  pkg:addFunc("onClickLogout",LoginView.onClickLogout)
  --pkg:addFunc("onLoginClose",LoginView.onLoginClose)
  pkg:addFunc("onBackFromReg",LoginView.onBackFromReg)
  
   pkg:addFunc("loginBackHandler",LoginView.loginBackHandler)
  
  pkg:addFunc("onClickCurrentTmpUserName",LoginView.onClickCurrentTmpUserName)
  pkg:addFunc("onClickSwitchLoginAlert",LoginView.onClickSwitchLoginAlert)
  pkg:addFunc("onOpenUsernameListHandler",LoginView.onOpenUsernameListHandler)
  pkg:addFunc("onClickTmpUserNameLogin",LoginView.onClickTmpUserNameLogin)
  
  pkg:addFunc("onClickFastRegist",LoginView.onClickFastRegist)
  
  pkg:addFunc("onClickLastestSelectedSever",LoginView.onClickLastestSelectedSever)
  
  
  pkg:addProperty("sprAccount","CCNode")
  pkg:addProperty("lblAccount","CCLabelTTF")
  pkg:addProperty("btnLogout","CCControlButton")
  pkg:addProperty("btnFastRegister","CCControlButton")
  pkg:addProperty("btnRegister","CCControlButton")
    
  pkg:addProperty("panelAccount","CCNode")
  pkg:addProperty("loginNode","CCNode")
  pkg:addProperty("regNode","CCNode")
  pkg:addProperty("panelLogin","CCLayer")
  pkg:addProperty("labelError","CCLabelTTF")
  pkg:addProperty("labelRegError","CCLabelTTF")
  pkg:addProperty("labelBlindError","CCLabelTTF")
  pkg:addProperty("labelMyAccount","CCLabelTTF")
  pkg:addProperty("label_other_username","CCLabelTTF")
  
  
  
  pkg:addProperty("label_last_enter","CCLabelTTF")
  pkg:addProperty("label_last_enter_name","CCLabelTTF")
  pkg:addProperty("label_all_server_list_title","CCLabelTTF")
  
  pkg:addProperty("nodeInputArea","CCNode")
  
  pkg:addProperty("label_tmpAcount_name","CCLabelTTF")
  pkg:addProperty("nodeUsernameList","CCNode")
  
  pkg:addProperty("scaleUserNo","CCScale9Sprite")
  pkg:addProperty("bgPassword","CCScale9Sprite")
  pkg:addProperty("scaleUserNoReg","CCScale9Sprite")
  pkg:addProperty("bgPasswordReg","CCScale9Sprite")
  pkg:addProperty("bgPasswordReputReg","CCScale9Sprite")
  pkg:addProperty("node_loginInfo","CCNode")
  pkg:addProperty("node_list","CCNode")
  pkg:addProperty("node_listContainer","CCNode")
  pkg:addProperty("sprite_enter","CCSprite")
  pkg:addProperty("sprite_listBg","CCScale9Sprite")
  pkg:addProperty("label_curServer","CCLabelTTF")
  pkg:addProperty("label_curServer2","CCLabelTTF")
  pkg:addProperty("menu_serverSelect","CCMenuItemSprite")
  pkg:addProperty("btnRegisterWithInfo","CCControlButton")
  pkg:addProperty("btnAccountMgr","CCControlButton")
  pkg:addProperty("btnLogin","CCControlButton")
  
  pkg:addProperty("menuLoginAlertBtnBak","CCMenuItemSprite")
  
  pkg:addProperty("btnDoBlind","CCControlButton")
  pkg:addProperty("btnBackFromReg","CCControlButton")
  
  pkg:addProperty("spriteAgree","CCSprite")
  
  pkg:addProperty("spriteTitleRegist","CCSprite")
  pkg:addProperty("spriteTitleBlind","CCSprite")
  
  pkg:addProperty("templeteAccountMgrNode","CCNode")
  pkg:addProperty("accountMgrNode","CCNode")
  pkg:addProperty("nodeLoginForce","CCNode")
  pkg:addProperty("node_tencent","CCNode")
  pkg:addProperty("menu_loginInfo","CCMenu")

  pkg:addFunc("serverSelectedCallback",LoginView.showServerList)
  pkg:addFunc("alertDocumentHandler",LoginView.alertDocumentHandler)
  pkg:addFunc("clickAgreeHandler",LoginView.clickAgreeHandler)
  pkg:addFunc("onClickAccountMgr",LoginView.onClickAccountMgr)
  pkg:addFunc("onClickPreBlind",LoginView.onClickPreBlind)
  pkg:addFunc("onClickCloseLogin",LoginView.onClickCloseLogin)
  pkg:addFunc("onClickCloseAccountMgr",LoginView.onClickCloseAccountMgr)
  pkg:addFunc("onClickCloseTempAccountMgr",LoginView.onClickCloseTempAccountMgr)
  pkg:addFunc("onClickBlind",LoginView.onClickBlind) --绑定账号
  pkg:addFunc("loginQQ",LoginView.loginQQ)
  pkg:addFunc("loginWeiXin",LoginView.loginWeiXin)
  
  pkg:addProperty("versionCode","CCLabelTTF")
  pkg:addProperty("label_tips","CCLabelTTF")
  pkg:addProperty("labelUserNameTip","CCLabelTTF")
  pkg:addProperty("labelPasswordTip","CCLabelTTF")
  pkg:addProperty("reg_labelUserNameTip","CCLabelTTF")
  pkg:addProperty("reg_labelPasswordTip","CCLabelTTF")
  pkg:addProperty("reg_labelRePasswordTip","CCLabelTTF")
  pkg:addProperty("bn_accept","CCControlButton")
  pkg:addProperty("bn_loginQQ","CCControlButton")
  pkg:addProperty("bn_loginWX","CCControlButton")
  pkg:addProperty("nodeAccept","CCNode")

  local layer,owner = ccbHelper.load("LoginView.ccbi","LoginViewCCB","CCLayer",pkg)

  self.label_tips:setString(_tr("login_tip"))
  
  self._tmpUserNameListIsOpen = false
  self.nodeUsernameList:setVisible(false)
  self:setLoginSdkState(false)

  self.labelUserNameTip:setString(_tr("login_username_tip"))
  self.labelPasswordTip:setString(_tr("login_psw_tip"))
  self.reg_labelUserNameTip:setString(_tr("login_username_tip"))
  self.reg_labelRePasswordTip:setString(_tr("login_psw_tip2"))
  self.label_other_username:setString(_tr("other_account"))
  self.reg_labelPasswordTip:setString(_tr("login_psw_tip"))
  self.bn_accept:setTitleForState(CCString:create(_tr("accept_info")), CCControlStateNormal)
  self.label_last_enter:setString(_tr("last_login_str"))
  self.label_all_server_list_title:setString(_tr("all_login_sever_list"))

  self.fieldUserName = UIHelper.convertBgToEditBox(self.scaleUserNo,_tr("login_username_tip2"),22,nil,nil,50)
  self.fieldPassword = UIHelper.convertBgToEditBox(self.bgPassword,_tr("pls_input_psw"),22,nil,true,15)
  self.fieldRegUserName = UIHelper.convertBgToEditBox(self.scaleUserNoReg,_tr("login_username_tip2"),22,nil,nil,50)
  self.fieldRegPassword = UIHelper.convertBgToEditBox(self.bgPasswordReg,_tr("pls_input_psw"),22,nil,true,15)
  self.fieldRegReputPassword = UIHelper.convertBgToEditBox(self.bgPasswordReputReg,_tr("pls_input_psw2"),22,nil,true,15)
  self.labelError:setString("")
  self.labelRegError:setString("")
  self.spriteAgree:setVisible(true)
  self.btnRegisterWithInfo:setEnabled(self.spriteAgree:isVisible())
  
  self._tipImg = display.newSprite("#common_tipImg.png")
  self.btnAccountMgr:addChild(self._tipImg)
  self._tipImg:setPosition(ccp(self.btnAccountMgr:getContentSize().width -5,self.btnAccountMgr:getContentSize().height - 5))
  
  local strVersionCode =  CCUserDefault:sharedUserDefault():getStringForKey("current-version-code")
  self.versionCode:setString(strVersionCode)
  self.regNode:setVisible(false)
  local netItem = GameData:Instance():getCurNetItem()
  self:setSelectedServer(netItem)
  self:updateView()
  
  --show entry menu anim
  local seq = CCSequence:createWithTwoActions(CCScaleTo:create(0.8, 0.9), CCScaleTo:create(0.8, 1.0))
  self.sprite_enter:runAction(CCRepeatForever:create(seq))

  if self:isInSdkPlugin(ChannelManager:getCurrentLoginChannel()) then
    self.loginNode:setVisible(false)
    self.btnLogout:setPosition(2048,display.height - 80)
    self.sprAccount:setPosition(2048,display.height - 80)
    SdkPluginManager:registerScriptHandler(handler(self,LoginView.onVerifyHandler))
  else  
    self.btnLogout:setPosition(ccp(display.cx+210,display.height - 80))
    self.sprAccount:setPosition(display.width/2,display.height - 80)
  end
  if ChannelManager:getCurrentLoginChannel() == 'dsuc' then
     UserLogin:registerScriptHandler(handler(self,LoginView.onFastCreateUser))
  end
  self._loginViewNode = layer
  self._loginViewNode:setVisible(false)
  self:addCcbiAnimLayer()
  self:addChild(layer)
  
  self._displayNode = display.newNode()
  self:addChild(self._displayNode)
  CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self, handler(self,GameData.setNotifice),"APP_SET_NOTIFICE_EVENT")
  if GameData:Instance():getLanguageType() == LanguageType.JPN then 
    self.node_loginInfo:setPositionY(self.node_loginInfo:getPositionY()+60)
    self.menu_serverSelect:setVisible(false)
    self.label_curServer:setVisible(false)
    self.label_curServer2:setVisible(false)
  end 
end

function LoginView:reset()
  self._displayNode:removeAllChildrenWithCleanup(true)
  self._loginViewNode:setVisible(true)
  self:endPlayAnim()
end

function LoginView:onClickTmpUserNameLogin()
  local pop = PopupView:createTextPopup(_tr("login_tip"), function() end,true)
  self:addChild(pop,200)
  self:updateView()
end

function LoginView:onClickFastRegist()
   local account = GameData:Instance():getCurrentAccount()
   self.loginType = LoginType.CREATE
    if ChannelManager:getCurrentLoginChannel()=='dsuc' then
      UserLogin:registerScriptHandler(handler(self,LoginView.onFastCreateUser))
      account:reqDSUCFastCreate()
    end
end

function LoginView:onOpenUsernameListHandler()
  if self._tmpUserNameListIsOpen ==  true then
     self.nodeUsernameList:setVisible(false)
     self._tmpUserNameListIsOpen = false
  else
     self.nodeUsernameList:setVisible(true)
     self._tmpUserNameListIsOpen = true
  end
end

function LoginView:onClickSwitchLoginAlert()
  self.node_loginInfo:setVisible(false)
  self.accountMgrNode:setVisible(false)
  self.templeteAccountMgrNode:setVisible(false)
  self.regNode:setVisible(false)
  self.loginNode:setVisible(true)
  self.nodeInputArea:setVisible(false)
  self:onClickLogin()
end

function LoginView:loginBackHandler()
  self.loginNode:setVisible(false)
  self.nodeUsernameList:setVisible(true)
  self:onClickAccountMgr()
end

function LoginView:onClickCurrentTmpUserName()
  self.nodeUsernameList:setVisible(false)
end

function LoginView:onClickCloseAccountMgr()
  self.accountMgrNode:setVisible(false)

  local account = GameData:Instance():getCurrentAccount()
  
  if account:getIsRegisted() == true then
    local username = account:getDSUCName()
    if ChannelManager:getCurrentLoginChannel() == 'dsuc' then
      self:showLoginPanle()
    end
  else
    
    self.node_loginInfo:setVisible(true)
  end
  
  
end

function LoginView:onClickCloseLogin()
  self.loginNode:setVisible(false)
  self.node_loginInfo:setVisible(true)
end

function LoginView:onClickCloseTempAccountMgr()
  self.templeteAccountMgrNode:setVisible(false)
  self.node_loginInfo:setVisible(true)
end

function LoginView:alertDocumentHandler()
  if self:getDocumentIsOpen() == true then
     return
  end
  self:setDocumentIsOpen(true)
  print("alertDocumentHandler")
  local doc = RegistDocumentView.new(self)
  GameData:Instance():getCurrentScene():addChildView(doc)
end

------
--  Getter & Setter for
--      LoginView._DocumentIsOpen 
-----
function LoginView:setDocumentIsOpen(DocumentIsOpen)
	self._DocumentIsOpen = DocumentIsOpen
end

function LoginView:getDocumentIsOpen()
	return self._DocumentIsOpen
end

function LoginView:onClickPreBlind()
  self.templeteAccountMgrNode:setVisible(false)
  self:onClickBlind()
end

function LoginView:clickAgreeHandler()
  if self.spriteAgree:isVisible() == true then
     self.spriteAgree:setVisible(false)
  else
     self.spriteAgree:setVisible(true)
  end
  self.btnRegisterWithInfo:setEnabled(self.spriteAgree:isVisible())
  self.btnDoBlind:setEnabled(self.spriteAgree:isVisible())
end

function LoginView:onClickAccountMgr()
  self.node_list:setVisible(false)
  self.loginNode:setVisible(false)
  self.regNode:setVisible(false)
  self.node_loginInfo:setVisible(false)
  local account = GameData:Instance():getCurrentAccount()
  if account:getIsRegisted() == true then
     if account:getShowName() ~= nil then
       self.labelMyAccount:setString(account:getShowName())
     end
     
     if account:getDSUCName() ~= nil and account:getDSUCName() ~= "" then
       self.labelMyAccount:setString(account:getDSUCName())
     end
    
     local username = account:getDSUCName()
     if string.find(username,"@dsucsys.com") then
        self.accountMgrNode:setVisible(false)
        self.templeteAccountMgrNode:setVisible(true)
        self.nodeUsernameList:setVisible(false)
     else
        self.accountMgrNode:setVisible(true)
        self.templeteAccountMgrNode:setVisible(false)
     end
  else
     self.accountMgrNode:setVisible(false)
     self.templeteAccountMgrNode:setVisible(false)
     self.regNode:setVisible(false)
     self.loginNode:setVisible(true)
     self.btnRegister:setVisible(true)
     self.btnFastRegister:setVisible(true)
     self.nodeInputArea:setVisible(false)
     
  end
end


function LoginView:endPlayAnim()
  if self._playedAnim == true then
    return
  end
  
  self._playedAnim = true
  print("endPlayAnim~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
  self:showNoticeView()

  self._loginViewNode:setVisible(true)
  self.node_light_caocao:setVisible(true)
  self.node_light_guanyu:setVisible(true)
  self.node_light_zhugeliang:setVisible(true)
    
  local caocao_anim = _res(6010015)
  caocao_anim:setPosition(ccp(0,0))
  local guanyu_anim = _res(6010016)
  guanyu_anim:setPosition(ccp(0,0))
  local zhugeliang_anim = _res(6010017)
  zhugeliang_anim:setPosition(ccp(0,0))
  self.node_light_caocao:addChild(caocao_anim)
  self.node_light_guanyu:addChild(guanyu_anim)
  self.node_light_zhugeliang:addChild(zhugeliang_anim)
  Guide:Instance():removeGuideLayer()

  local channel = ChannelManager:getCurrentLoginChannel()
  if self:isInSdkPlugin(channel) then
    if self._isCallLogin == true then
      return
    end
    self._isCallLogin = true 
    local account = GameData:Instance():getCurrentAccount()
    if account:getIsRegisted() == true then
        if self:getSwitchFlag()==true then
           SdkPluginManager:switchAccount()
           return 
        end
    end
    SdkPluginManager:registerScriptHandler(handler(self,LoginView.onVerifyHandler))
    if channel ~= "tencent" then 
      SdkPluginManager:getInstance():login()
    end 
  end
  
  local account = GameData:Instance():getCurrentAccount()
  
  if account:getIsRegisted() == true then
    local username = account:getDSUCName()
    if ChannelManager:getCurrentLoginChannel() == 'dsuc' then
      if string.find(username,"@dsucsys.com") then
         self:onClickAccountMgr()
      else
         self:showLoginPanle()
      end
    end
  else
    if ChannelManager:getCurrentLoginChannel() == 'dsuc' then
      self:onClickAccountMgr()
    end
  end
end

function LoginView:showLoginPanle()
  self.menuLoginAlertBtnBak:setVisible(false)
  self.node_loginInfo:setVisible(false)
  self.accountMgrNode:setVisible(false)
  self.templeteAccountMgrNode:setVisible(false)
  self.regNode:setVisible(false)
  self.loginNode:setVisible(true)
  self.nodeInputArea:setVisible(true)
  
  self.labelError:setString("")
  
  local account = GameData:Instance():getCurrentAccount()
  local username = account:getDSUCName()
    
  self.fieldUserName:setText(username)
  self.fieldPassword:setText(account:getDSUCPassword())
end

function LoginView:showNoticeView()
   local noticeView = LoginNoticeView.new()
   GameData:Instance():getCurrentScene():addChildView(noticeView)
end

function LoginView:addCcbiAnimLayer()
  local node = display.newNode()
  node:setPosition(ccp(0 ,0 ))
  node:setCascadeOpacityEnabled(true)
  self:addChild(node,0)

  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("anim_end",LoginView.endPlayAnim)
  pkg:addProperty("node_light_zhugeliang","CCNode")
  pkg:addProperty("node_light_guanyu","CCNode")
  pkg:addProperty("node_light_caocao","CCNode")
  pkg:addProperty("mAnimationManager","CCBAnimationManager")
  local layer,owner = ccbHelper.load("anim_login.ccbi","anim_loginCCB","CCLayer",pkg)
  node:addChild(layer)
  
  local anim = _res(6010010)
  node:addChild(anim)

  self.node_light_caocao:setVisible(false)
  self.node_light_guanyu:setVisible(false)
  self.node_light_zhugeliang:setVisible(false)
end

function LoginView:onFightAnimEnd()
  
end

function LoginView:updateView()
  --if tencent channel, show login button for QQ/WEIXIN, and hide when logined success
  local channel = ChannelManager:getCurrentLoginChannel()
  local account = GameData:Instance():getCurrentAccount()
  local sdkstate = self:getLoginSdkState()
  echo("===LoginView:updateView: channel, state=", channel, sdkstate)
  if (channel~= nil and channel == "tencent") and sdkstate == false then 
    self.node_loginInfo:setVisible(false)
    self.menu_loginInfo:setEnabled(false)
    self.node_tencent:setVisible(true)
    self.bn_loginQQ:setEnabled(true)
    self.bn_loginWX:setEnabled(true) 
  else 
    self.node_loginInfo:setVisible(true)
    self.menu_loginInfo:setEnabled(true)
    self.node_tencent:setVisible(false)
    self.bn_loginQQ:setEnabled(false)
    self.bn_loginWX:setEnabled(false)
  end 

  self.btnLogout:setVisible(false)
  self.menuLoginAlertBtnBak:setVisible(true)
  
  if account:getIsRegisted() == true then
    self.sprAccount:setVisible(false)
    self.btnRegister:setVisible(false)
    self.btnFastRegister:setVisible(false)
    self.lblAccount:setString(account:getDSUCName())
    if account:getShowName() ~= nil then
      self.labelMyAccount:setString(account:getShowName())
    end
    
    if channel ~=nil then
      if self:isInSdkPlugin(channel) then
        self.sprAccount:setVisible(false)
      end
    end
    printf("Name:%s",account:getName())
    
    if account:getDSUCName() ~= nil and account:getDSUCName() ~= "" then
       self.labelMyAccount:setString(account:getDSUCName())
    end
    --self.btnLogout:setVisible(true)
    
    self.loginNode:setVisible(false)
    -- self.node_loginInfo:setVisible(true)
    self.templeteAccountMgrNode:setVisible(false)
    self.accountMgrNode:setVisible(false)
    
   -- self.panelAccount:setVisible(false)  
  else
    self.sprAccount:setVisible(false)
    self.btnLogout:setVisible(false)
    self.templeteAccountMgrNode:setVisible(false)
    self.accountMgrNode:setVisible(false)
    self.loginNode:setVisible(false)
  end
  
  if channel == 'dsuc' then     
     local username = account:getDSUCName()
     if string.find(username,"@dsucsys.com") then
       local tmpNameShowPreStr = string.sub(username, 1, -35)
       local tmpNameShowLastStr = string.sub(username, 23, -1)
       self.label_tips:setString(tmpNameShowPreStr.."..."..tmpNameShowLastStr)
       self.label_tmpAcount_name:setString(tmpNameShowPreStr.."..."..tmpNameShowLastStr)
     else
       if self._tipImg ~= nil then
         self._tipImg:removeFromParentAndCleanup(true)
         self._tipImg = nil 
       end
     end
     
     if account:getName() == "" then
       if self._tipImg ~= nil then
         self._tipImg:removeFromParentAndCleanup(true)
         self._tipImg = nil 
       end
     end
     
     self.btnAccountMgr:setVisible(true)
  else
     self.btnAccountMgr:setVisible(false)
     self.sprAccount:setVisible(false)
     self.btnLogout:setVisible(false)
     self.templeteAccountMgrNode:setVisible(false)
     self.accountMgrNode:setVisible(false)
     self.loginNode:setVisible(false)
  end
end

function LoginView:onEnter()
  printf("LoginView:onEnter")
  net.registMsgCallback(PbMsgId.FastCreatePlayerResult,self,LoginView.onFastCreateResult)
  --net.registMsgCallback(PbMsgId.LoginResult,self,LoginView.onLoginResult)
  net.registMsgCallback(PbMsgId.PlayerBaseInformation,self,LoginView.onPlayerInfo)
  net.registCallback(NetAction.ON_CONNETING_LOGIN_SERVER_FAILED,0,self,LoginView.onConnectServerFailed)
  net.registMsgCallback(NetAction.ON_CONNETED_LOGIN_SERVER,PbMsgId.NoValidGateServer,self,LoginView.onConnectServerFailed)
  net.registMsgCallback(NetAction.ON_CONNETING_GAME_SERVER_FAILED,0,self,LoginView.onConnectServerFailed)
  net.registCallback(NetAction.ON_CONNETED_GAME_SERVER,0,self,LoginView.onConnectServerSuccess)
  CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self,handler(self,LoginView.onLoginResult),EventType.LOGIN_RESULT)

  -- play bgm
  _playBgm(BGM_LOGIN)

--  self:setKeypadEnabled(true)
  local function KeypadHandler(strEvent)
    if "backClicked" == strEvent then
      self:keyBackClicked()
    elseif "menuClicked" == strEvent then
    end
  end
  self:addKeypadEventListener(KeypadHandler)
end

function LoginView:onExit()
  printf("LoginView:onExit")
  self:removeLoading()
  CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(self, EventType.LOGIN_RESULT)
  net.unregistAllCallback(self)
end

local function performWithDelay(node, callback, delay)
  local delay = CCDelayTime:create(delay)
  local callfunc = CCCallFunc:create(callback)
  local sequence = CCSequence:createWithTwoActions(delay, callfunc)
  node:runAction(sequence)
  return sequence
end

function LoginView:onClickEnterGame()
  print("onClickEnterGame")
  if self:isInSdkPlugin(ChannelManager:getCurrentLoginChannel()) then
    local luaj = require("framework.javabridge")
    local className="com/m543/pay/FastSdk"
    local params={ChannelManager:getCurrentLoginChannel()}
    local arg="(Ljava/lang/String;)Z"
    local ok,isLogin=luaj.callStaticMethod(className,"isLogin",params,arg)
    if ok==true and isLogin==false then
      SdkPluginManager:registerScriptHandler(handler(self,LoginView.onVerifyHandler))
      SdkPluginManager:getInstance():login()
      return 
    end
  end

  local account = GameData:Instance():getCurrentAccount()
  if self:isInSdkPlugin(ChannelManager:getCurrentLoginChannel()) then
    if account:getIsRegisted() ~= true then
      SdkPluginManager:registerScriptHandler(handler(self,LoginView.onVerifyHandler))
      SdkPluginManager:getInstance():login()
      return 
    end
  end
--  if self._isMaintain == true then
--     local pop = PopupView:createTextPopup(_tr("server_maintain"), function() return end,true)
--     pop:setScale(0.2)
--     pop:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6) )
--     GameData:Instance():getCurrentScene():addChildView(pop)
--     return
--  end
  self:showLoading()
  print("getIsRegisted :", account:getIsRegisted())
  if ChannelManager:getCurrentLoginChannel() == 'uc' then
    account:setIsRegisted(true)
  end

  if account:getIsRegisted() == true then
    self.loginType = LoginType.LOGIN_WITH_PASSWORD
      if net.isConnected == false and net.isActiveDisconnect == false then
        print("net disonnected,connecting.....")
        net.connect()
      elseif net.isConnected == false and net.isActiveDisconnect == true then
        print("net disonnected,connecting.....")
        net.isActiveDisconnect = false
        net.connect()
      else
        print("net connected,req login.....")
        account:reqLogin()
      end
  else
    self.loginType = LoginType.CREATE
    if ChannelManager:getCurrentLoginChannel()=='dsuc' then
      UserLogin:registerScriptHandler(handler(self,LoginView.onFastCreateUser))
      account:reqDSUCFastCreate()
    end
  end
  
end

function LoginView:onBackFromReg()
  if self._registType == "regist" then
     self.regNode:setVisible(false)
     self.loginNode:setVisible(true)
  elseif self._registType == "bind" then
     self.regNode:setVisible(false)
     self.loginNode:setVisible(false)
     self.templeteAccountMgrNode:setVisible(true)
  end
end

function LoginView:onClickInputLogin()
  self.loginNode:setVisible(true)
  --self.nodeEnterGame:setVisible(false)
end

--function LoginView:onLoginClose()
--  self.loginNode:setVisible(false)
--end

function LoginView:showLoading()
--   self:removeLoading()
--   local timeOutHandler = function()
--    self:removeLoading()
--    local pop = PopupView:createTextPopup(_tr("connect_timeout"), function() return end,true)
--    pop:setScale(0.2)
--    pop:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6) )
--    GameData:Instance():getCurrentScene():addChildView(pop)
--  end
--  performWithDelay(self,timeOutHandler,30)
--  self._loadingshow = Loading:show({timeOutRemove = false})
  _showLoading()
end

function LoginView:removeLoading()
--   self:stopAllActions()
--   if self._loadingshow ~= nil then
--      self._loadingshow:stopAllActions()
--      self._loadingshow:remove()
--      self._loadingshow = nil 
--   end
  _hideLoading()
end

function LoginView:onClickLogin() 
  self:removeLoading()
  echo("touch down onClickLogin btn")
  
  if self.nodeInputArea:isVisible() ~= true then
     self.btnRegister:setVisible(false)
     self.btnFastRegister:setVisible(false)
     self.nodeInputArea:setVisible(true)
     return
  end
  
  self._login_register="login"
  local account = GameData:Instance():getCurrentAccount()
  local inputName = self.fieldUserName:getText()   -- get input username
  if inputName == "" then
    self.labelError:setVisible(true)
    self.labelError:setString(_tr("pls_input_correct_mail"))
    return
  end
  
  if self:isRightUserName(inputName) == false then
     self.labelError:setVisible(true)
     self.labelError:setString(_tr("pls_input_correct_mail"))
     return
  end
  
  if string.len(inputName) > 50 then
     self.labelError:setVisible(true)
     self.labelError:setString(_tr("pls_input_correct_mail"))
     return
  end
  
  local inputPassword = self.fieldPassword:getText()
  if inputPassword == "" then
    self.labelError:setVisible(true)
    self.labelError:setString(_tr("empty_psw"))
    return
  end
  
  if string.len(inputPassword) > 50 then
     self.labelError:setVisible(true)
    self.labelError:setString(_tr("pls_input_correct_psw"))
    return
  end
  
  UserLogin:registerScriptHandler(handler(self,LoginView.onLoginOrRegister))
  self:showLoading()
  CCUserDefault:sharedUserDefault():setStringForKey("user_show_name",inputName)
  CCUserDefault:sharedUserDefault():flush()
  local account = GameData:Instance():getCurrentAccount()
  account:setTempUserName(inputName)
  account:setTempPassword(inputPassword)
  account:setIsFastCreate(false)
  UserLogin:login(inputName,inputPassword)
end

function LoginView:isRightUserName(str)
  local isRightUserName = false
  if self:isRightEmail(str) == false then
    return self:isRightTel(str)
  else
    return true
  end
end

function LoginView:isRightTel(str)
  if string.len(str or "") ~= 11 then return false end
  local _,count = string.gsub(str, "%d", "")
  return count == 11
end

function LoginView:isRightEmail(str)
     if string.len(str or "") < 6 then return false end
     local b,e = string.find(str or "", '@')
     local bstr = ""
     local estr = ""
     if b then
         bstr = string.sub(str, 1, b-1)
         estr = string.sub(str, e+1, -1)
         print("bstr:",bstr,"estr:",estr)
     else
         return false
     end
 
     -- check the string before '@'
     if GameData:Instance():getLanguageType() == LanguageType.JPN then 
       local p1,p2 = string.find(bstr, "[%S_]+")
       print("p1:",p1,"p2:",p2,"bstrLenght:",string.len(bstr))
       if (p1 ~= 1) or (p2 ~= string.len(bstr)) then return false end
     else
       local p1,p2 = string.find(bstr, "[%w_]+")
       local point,point1 = string.find(bstr, "%.")
        
       if point == 1 then
          if (p1 ~= 1) or (p2 ~= string.len(bstr)) then return false end
       else
          if (p1 ~= 1)  then return false end
          local p_str,p_count = string.gsub(bstr, "%.", "")
          local p_1,p_2 = string.find(p_str, "[%w_]+")
          if (p_1 ~= 1) or (p_2 ~= string.len(p_str)) then return false end
       end
     end
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

function LoginView:onClickRegist() --click register
  self:doRegist("regist")
end

function LoginView:onClickBlind() --click register
  self:doRegist("bind")
end

function LoginView:loginQQ()
  SdkPluginManager:getInstance():setSubChannel("QQ")
  SdkPluginManager:getInstance():login()
end 

function LoginView:loginWeiXin()
  SdkPluginManager:getInstance():setSubChannel("WEIXIN")
  SdkPluginManager:getInstance():login()
end 

function LoginView:doRegist(registType)
  printf("LoginView:doRegist: type:"..registType)
  
   if registType == "regist" then
      self.spriteTitleRegist:setVisible(true)
      self.spriteTitleBlind:setVisible(false)
      self.btnDoBlind:setVisible(false)
      self.btnBackFromReg:setVisible(true)
      self.btnRegisterWithInfo:setVisible(true)
      
  elseif registType == "bind" then
      self.spriteTitleRegist:setVisible(false)
      self.spriteTitleBlind:setVisible(true)
      self.btnDoBlind:setVisible(true)
      self.btnBackFromReg:setVisible(true)
      self.btnRegisterWithInfo:setVisible(false)
  end
  
  self._registType = registType
  
  if self.regNode:isVisible() == false then
    self.regNode:setVisible(true)
    if GameData:Instance():getLanguageType() == LanguageType.JPN then 
      self.nodeAccept:setVisible(false)
    else 
      self.nodeAccept:setVisible(true)
    end     
    self.loginNode:setVisible(false)
    self.templeteAccountMgrNode:setVisible(false)
    return
  end
  
  self._login_register="register"
  local inputName = self.fieldRegUserName:getText()     -- get input username
  local password = self.fieldRegPassword:getText()    -- get input password
  local reputPassword = self.fieldRegReputPassword:getText() 
  
  if self:isRightUserName(inputName) == false then
     self.labelRegError:setVisible(true)
     self.labelRegError:setString(_tr("pls_input_correct_mail"))
     return
  end
  
  if string.len(inputName) > 50 then
     self.labelError:setVisible(true)
     self.labelError:setString(_tr("pls_input_correct_mail"))
     return
  end
  
  if password == "" then
    self.labelRegError:setVisible(true)
    self.labelRegError:setString(_tr("empty_psw"))
    return
  end
  
  if reputPassword == "" then
    self.labelRegError:setVisible(true)
    self.labelRegError:setString(_tr("pls_input_psw2"))
    return
  end
  
  if reputPassword ~= password then
    self.labelRegError:setVisible(true)
    self.labelRegError:setString(_tr("psw_not_identical"))
    return
  end
  
  if string.len(password) >= 16 or string.len(reputPassword) >= 16  then
    self.labelRegError:setVisible(true)
    self.labelRegError:setString(_tr("pls_input_correct_psw"))
    return
  end
  
  print("start reg:",inputName,password,reputPassword)
  CCUserDefault:sharedUserDefault():setStringForKey("user_show_name",inputName)
  CCUserDefault:sharedUserDefault():flush()
  UserLogin:registerScriptHandler(handler(self,LoginView.onLoginOrRegister))
  self:showLoading()
  local account = GameData:Instance():getCurrentAccount()
  
  if registType == "regist" then
    account:setTempUserName(inputName)
    account:setTempPassword(password)
    account:setIsFastCreate(false)
    UserLogin:registe(inputName,password)
  elseif registType == "bind" then
    account:setIsFastCreate(false)
    UserLogin:registerScriptHandler(handler(self,LoginView.onBindResult))
    local oldUserName = account:getDSUCName()
    local oldPassWord = account:getDSUCPassword()
    account:setTempUserName(inputName)
    account:setTempPassword(password)
    UserLogin:bindAccount(oldUserName,oldPassWord,inputName,password)
  end

  
end

function LoginView:onClickLogout()  --click logout
  echo("logout")
  local doLogoutHandler = function()
    self.btnLogout:setVisible(false)
    self.regNode:setVisible(false)
    self:setLoginSdkState(false)
    --self.loginNode:setVisible(true)
    local account = GameData:Instance():getCurrentAccount()
    account:reset()
    account:save()
    self.node_loginInfo:setVisible(true)
    self:updateView()
    self:onClickAccountMgr()
  end
  
  local account = GameData:Instance():getCurrentAccount()
  local username = account:getDSUCName()
  local tipStr = ""
  if string.find(username,"@dsucsys.com") then
     tipStr = _tr("logout_tip")
  else
     tipStr = _tr("confirm_logout")
  end
  
  local pop = PopupView:createTextPopup(tipStr, doLogoutHandler)
  GameData:Instance():getCurrentScene():addChildView(pop)
end

function LoginView:onClickShowPanelAccount( ... ) -- click Account Login
  printf("LoginView:onClickShowPanelAccount")
  local scale = CCScaleTo:create(0.5,1.0,1.0)
  self.panelAccount:setVisible(true)
  self.panelLogin:setScale(0.1)
  self.panelLogin:runAction(CCEaseBounceOut:create(scale))
end

function LoginView:onConnectServerFailed(action,msgId,msg)
  printf("LoginView: Connect server failed")
  self["labelError"]:setString("Connect server failed")
  self["labelError"]:setVisible(true)
  
  self:removeLoading()
  local pop = PopupView:createTextPopup(_tr("connect_fail"), function() return end,true)
  GameData:Instance():getCurrentScene():addChildView(pop)
end

function LoginView:onConnectServerSuccess(action,msgId,msg)
  printf("LoginView: Connect server success")
  local account = GameData:Instance():getCurrentAccount()
  if self.loginType == LoginType.LOGIN_WITH_PASSWORD then
    print("LoginView: loginType = LOGIN_WITH_PASSWORD")
    account:reqLogin()
  else
    print("LoginView: loginType = CREATE")
    self:removeLoading()
    account:reqFastCreate()
  end
end

function LoginView:onFastCreateResult(action,msgId,msg)
  if msg.result == "Ok" then
    printf("Fast create successfully. ")
    self:updateView()
  elseif msg.result == "HasLogined" then
    --self:onPlayerInfo()
  elseif msg.state == "ERROR_CLIENT_VERSION" then
     local pop = PopupView:createTextPopup(_tr("detect_new_versition"), function() return end,true)
     pop:setScale(0.2)
     pop:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6) )
     GameData:Instance():getCurrentScene():addChildView(pop)
  elseif msg.result == "ServerPlayerFull" then
    local pop = PopupView:createTextPopup(_tr("server_full"), function() return end,true)
    GameData:Instance():getCurrentScene():addChildView(pop)
  else
    printf("Fast create failed,reason:%s",msg.result)
  end
end

function LoginView:onLoginResult()
  
--    enum State {
--    Ok = 0;
--    PlayerNotExist = 1;
--    PasswordError = 2;
--    HasLoginned = 3;
--    UseForceButNoLoginedPlayer = 4;
--    JustLoginning = 5;
--    ServerPlayerFull = 6;
--    PlayerLocked = 7;
--    ERROR_SIGN_CODE = 8;
--    ERROR_CLIENT_VERSION = 9;
--  }
  local account = GameData:Instance():getCurrentAccount()
  local msg = account:getLoginResult()
  echo("LoginView:onLoginResult: ", msg.state)
  if msg.state == "Ok" then
    self:stopAllActions()
    printf("Login successfully. ")
    --save selected info to file
    local item = GameData:Instance():getCurNetItem()
    CCUserDefault:sharedUserDefault():setIntegerForKey("user_net_prefer", item.area)
    CCUserDefault:sharedUserDefault():flush()
    echo("save user perfer net server area =", item.area)
    self:updateView()
  else
    self:getDelegate():logout()
    self:removeLoading()
    if msg.state == "PlayerNotExist" or msg.state == "PasswordError" then
       local pop = PopupView:createTextPopup(_tr("wrong_name_or_psw"), function() return end,true)
       GameData:Instance():getCurrentScene():addChild(pop)
    elseif msg.state == "HasLoginned" then
       local pop = PopupView:createTextPopup(_tr("has_login"), function() return end,true)
       GameData:Instance():getCurrentScene():addChild(pop)
    elseif msg.state == "PlayerNotExist" then
      local pop = PopupView:createTextPopup(_tr("invalid_account"), function() return end,true)
      GameData:Instance():getCurrentScene():addChild(pop)
    elseif msg.state == "ServerPlayerFull" then
       local pop = PopupView:createTextPopup(_tr("server_full"), function() return end,true)
       GameData:Instance():getCurrentScene():addChild(pop)
    elseif msg.state == "PlayerLocked" then
       local pop = PopupView:createTextPopup(_tr("account_is_permit"), function() return end,true)
       GameData:Instance():getCurrentScene():addChild(pop)
    elseif msg.state == "ERROR_SIGN_CODE" then
       local pop = PopupView:createTextPopup(_tr("invalid_signature"), function() return end,true)
       GameData:Instance():getCurrentScene():addChild(pop)
    elseif msg.state == "ERROR_CLIENT_VERSION" then
       local pop = PopupView:createTextPopup(_tr("detect_new_versition"), function() return end,true)
       GameData:Instance():getCurrentScene():addChild(pop)
    elseif msg.state == "PlayerLocked" then
       local pop = PopupView:createTextPopup(_tr("account_is_frozen"), function() return end,true)
       GameData:Instance():getCurrentScene():addChild(pop)
    elseif msg.state == "ServerPlayerFull" then
       local pop = PopupView:createTextPopup(_tr("server_busy"), function() return end,true)
       GameData:Instance():getCurrentScene():addChild(pop)
    elseif msg.state == "JustLoginning" then
    else
       printf(_tr("Login failed,reason:%{reason}", {reason = _tr(msg.state)}))
       --self.labelError:setString(_tr("Login failed,reason:%{reason}", {reason = _tr(msg.state)}))
       self.labelError:setString("")
       print("Fail reason:",msg.state)
       local pop = PopupView:createTextPopup(_tr("login_fail"), function() return end,true)
       GameData:Instance():getCurrentScene():addChild(pop)
    end
  end
end

-- after login,client will recv the init data from server
function LoginView:onPlayerInfo(action,msgId,msg)
  -- for test,forward to battle view
  --  local battleController = ControllerFactory:Instance():create(ControllerType.BATTLE_CONTROLLER)
  --  battleController:enter()

  -- for test ,forward to home view
  -- local homeController = ControllerFactory:Instance():create(ControllerType.HOME_CONTROLLER)
  --homeController:enter()
    
    local nickName = msg.nick_name --GameData:Instance():getCurrentPlayer():getName()
    print("---------------------onPlayerInfo: ", msg.nick_name)
    print("player have nickName is:",nickName,"#:",#nickName,"byte:",string.byte(nickName))
    if  nickName ~= nil and #nickName > 0 then
      --不要从player.lua里获取数据，防止未及时初始化
      -- local flag = GameData:Instance():getCurrentPlayer():getCardGiftFlag()
      local flag = msg.common.score
      echo("=====LoginView:onPlayerInfo: award flag=", flag)
      if flag > 0 then 
        local homeController = ControllerFactory:Instance():create(ControllerType.HOME_CONTROLLER)
        --homeController:enter(true)
        homeController:enter()
      else 
        self:removeLoading()
        self:setVisible(false)
        local view = CreateRoleView.new()
        GameData:Instance():getCurrentScene():addChild(view)
      end 
    else 
        self:removeLoading()
        self._loginViewNode:setVisible(false)
        local str = _tr("battle_story_start")
        local printStoryView = StoryPrintView.new(str,true)
        self._displayNode:addChild(printStoryView,200)
    end
end

--below for server list
function LoginView:setSelectedServer(netItem)
  if netItem == nil then 
    return
  end
  
  if netItem.stateCode == 3 then
     self._isMaintain = true
  else
     self._isMaintain = false
  end
  
  echo("setSelectedServer, serverId=", netItem.serverId)
  Pay:Instance():setPayServerIdAndName(netItem.serverId,netItem.name)
  GameData:Instance():setCurNetItem(netItem)
  self.lblAccount:setString(GameData:Instance():getCurrentAccount():getDSUCName())
  
  self.node_listContainer:removeAllChildrenWithCleanup(true)
  self.node_loginInfo:setVisible(true)
  self.node_list:setVisible(false)
  
  local last_netItem = GameData:Instance():getLastNetItem()
  local last_str = _tr("area %{count}", {count=last_netItem.area}).."   "..last_netItem.name.."   ["..last_netItem.status.."]"
  self.label_last_enter_name:setString(last_str)
  self.label_last_enter_name:setColor(last_netItem.color)

  --set current server string info
  local str = _tr("area %{count}", {count=netItem.area}).."   "..netItem.name.."   ["..netItem.status.."]"
  
  
  self.label_curServer:setString(str)
  self.label_curServer:setColor(netItem.color)

  self.label_curServer2:setString(_tr("touch_select"))
  local w = self.label_curServer:getContentSize().width
  local w2 = self.label_curServer2:getContentSize().width

  self.label_curServer:setPositionX(-w2/2)
  self.label_curServer2:setPositionX((w-w2)/2)
  
  print("netItem.ip, netItem.port:",netItem.ip, netItem.port)
  echo("=== ip", netItem.ip, netItem.port)
  --setup ip
  net.setup_login_server(netItem.ip, netItem.port)
end 

function LoginView:onClickLastestSelectedSever()
  local last_netItem = GameData:Instance():getLastNetItem()
  self:setSelectedServer(last_netItem)
end


function LoginView:showServerList()
  echo("--showServerList--",self.node_loginInfo:isVisible())

  local function tableCellTouched(tableview,cell)
    local index = cell:getIdx() + 1
    local item = self.serverArray[index]
    self:setSelectedServer(item)
  end
  
  local function cellSizeForTable(tableview,idx)
    return self.cellHeight,self.cellWidth
  end
  
  local function tableCellHighLight(tableview, cell)    
    local selImg = tolua.cast(cell:getChildByTag(101), "CCSprite")
    if selImg ~= nil then
      selImg:setVisible(true)
    end
  end 

  local function tableCellUnhighLight(tableview, cell)
    local selImg = tolua.cast(cell:getChildByTag(101), "CCSprite")
    if selImg ~= nil then
      selImg:setVisible(false)
    end
  end

  local function tableCellAtIndex(tableview, idx)
    --echo("cellAtIndex = "..idx)
    local cell = tableview:dequeueCell()
    if nil == cell then
      cell = CCTableViewCell:new()
    else
      cell:removeAllChildrenWithCleanup(true)
    end

    local selectedImg = CCSprite:createWithSpriteFrameName("yinying2.png")
    selectedImg:setPosition(ccp(self.cellWidth/2, self.cellHeight/2-1))
    selectedImg:setTag(101)
    selectedImg:setVisible(false)
    cell:addChild(selectedImg)

    if idx ~= (self.totalCells-1) then 
      local lineImg = CCSprite:createWithSpriteFrameName("xian.png")
      lineImg:setAnchorPoint(ccp(0.5, 1))
      lineImg:setPosition(ccp(self.cellWidth/2, self.cellHeight))
      cell:addChild(lineImg)
    end
    
    local str = _tr("area %{count}", {count=self.serverArray[idx+1].area}).."   "..self.serverArray[idx+1].name.."   ["..self.serverArray[idx+1].status.."]"
    local label = CCLabelTTF:create(str,"Courier-Bold",24)
    if label ~= nil then 
      label:setHorizontalAlignment(kCCTextAlignmentLeft)
      label:setAnchorPoint(ccp(0,0.5))
      label:setPosition(ccp(self.cellWidth/2-150, self.cellHeight/2))
      label:setColor(self.serverArray[idx+1].color)
      cell:addChild(label)
    end
    return cell
  end
  
  local function numberOfCellsInTableView(tableview)
    return self.totalCells
  end

  self.serverArray = GameData:Instance():getNetServerArray()
  self.totalCells = table.getn(self.serverArray)
  if self.totalCells == 0 then 
    echo("empty server list...")
    return
  end

  --disable bottom menu
  --self.node_loginInfo:setVisible(false)
  self.node_list:setVisible(true)

  --init tableview
  --[[local maxRow = 7
  local size = self.sprite_listBg:getContentSize()
  self.cellWidth = size.width
  self.cellHeight = self.sprite_listBg:getContentSize().height/maxRow
  
  self.node_listContainer:removeAllChildrenWithCleanup(true)

  local pos_y = -size.height/2
  if self.totalCells < maxRow then 
    pos_y = pos_y + (maxRow - self.totalCells)*self.cellHeight
  end
  self.node_listContainer:setPosition(ccp(-self.cellWidth/2, pos_y))
  ]]
  
  local size = self.sprite_listBg:getContentSize()
  self.cellWidth = size.width
  self.cellHeight = 55
  
  local viewSize = self.node_listContainer:getContentSize()
  self.node_listContainer:removeAllChildrenWithCleanup(true)
  --self.tableView = CCTableView:create(CCSizeMake(self.cellWidth, math.min(maxRow, self.totalCells)*self.cellHeight))
  self.tableView = CCTableView:create(viewSize)
  self.tableView:setDirection(kCCScrollViewDirectionVertical)
  self.node_listContainer:addChild(self.tableView)

  self.tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  self.tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  self.tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  self.tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  self.tableView:registerScriptHandler(tableCellHighLight,CCTableView.kTableCellHighLight)
  self.tableView:registerScriptHandler(tableCellUnhighLight,CCTableView.kTableCellUnhighLight)

  self.tableView:reloadData()
--  self.node_listContainer:setScale(0.8)
--  self.node_listContainer:runAction(CCScaleTo:create(0.2, 1.0))
end

function LoginView:keyBackClicked()
  local function ExitGameCallBack()
    local guideLayer = GuideLayer:createGuideLayer()
    guideLayer:skip()
  end
  local scene = GameData:Instance():getCurrentScene()
  if scene~= nil then
    scene:removeChildByTag(123321)
  end

  local str = _tr("confirm_quit")
  local pop = PopupView:createTextPopup(str,ExitGameCallBack)

  pop:setTouchPriority(-999999)
  scene:addChild(pop,999999,123321)
end

function LoginView:onLoginOrRegister(status,message)
   print("status="..status.."message="..message)
   if("success"==status)then
      UserLogin:registerScriptHandler(handler(self,LoginView.onVerifyHandler))
      UserLogin:getUser(message)
   else
     self:removeLoading()
     if(self._login_register=="login")then
        self.labelError:setVisible(true)
        message=_tr("login_error_msg_"..message)
        self.labelError:setString(message)
     elseif(self._login_register=="register")then
        self.labelError:setVisible(true)
        message=_tr("login_error_msg_"..message)
        self.labelRegError:setString(message) 
     end
   end
end
function LoginView:onVerifyHandler(status,user,password,channel,sign)
   print("status="..status..";user="..user..";password="..password..";channel="..channel..";sign="..sign)
   if "success"==status then
     local account = GameData:Instance():getCurrentAccount()
     account:setName(user)
     account:setPassword(password)
     account:setChannel(channel)
     account:setSign(sign)
     if ChannelManager:getCurrentLoginChannel()=='dsuc' then
        account:setDSUCName(account:getTempUserName())
        account:setDSUCPassword(account:getTempPassword())
        if self._login_register=="register" then
            self:onRegister(account:getTempUserName())
        end
     end
     account:setIsRegisted(true)
     self:setLoginSdkState(true)
     account:save()
     
     if ControllerFactory:Instance():getCurrentControllerType() ~=  ControllerType.REGIST_CONTROLLER then
       local registController = ControllerFactory:Instance():create(ControllerType.REGIST_CONTROLLER)
       registController:enter()
       registController:logout()
       return
     end
     
     
     --self:removeLoading()
     self.regNode:setVisible(false)
     self.loginNode:setVisible(false)
     -- clear text
     self.fieldUserName:setText("")
     self.fieldPassword:setText("")
     self.fieldRegUserName:setText("")
     self.fieldRegPassword:setText("")
     self.fieldRegReputPassword:setText("")
     self:updateView()
     if account:getIsFastCreate() == true then
       --self:onClickEnterGame()
       local pop = PopupView:createTextPopup(_tr("login_tip"), function() end,true)
       self:addChild(pop,200)
       print("tip bind account")
     end
     self.labelMyAccount:setString(account:getDSUCName())
   else
     self.labelError:setVisible(true)
     self.labelError:setString(user)
   end
   self:removeLoading()
end

function LoginView:isInSdkPlugin(channel)
    if(channel==nil) then
        return false
    end
    local channels = {"360","baidu","wandoujia","gfan","mi","anzhi","uc","tencent","oppo"}
    for key,value in ipairs(channels) do
      if(value==channel) then
         return true
      end
    end
    return false
end
function LoginView:onFastCreateUser(status,userName,password)
  local account = GameData:Instance():getCurrentAccount()
  account:setTempUserName(userName)
  account:setTempPassword(password)
  self:onRegister(userName)
  UserLogin:registerScriptHandler(handler(self,LoginView.onLoginOrRegister))
  UserLogin:login(userName,password)
end
function LoginView:onBindResult(status)
--判断判定与否 success
  print(status)
  self:removeLoading()
  local tip = ""
  if status == "success" then
     tip = _tr("account_binding_ok")
     local account = GameData:Instance():getCurrentAccount()
     account:setDSUCName(account:getTempUserName())
     account:setDSUCPassword(account:getTempPassword())
     account:save()
     self.labelMyAccount:setString(account:getDSUCName())
     self.regNode:setVisible(false)
     self.templeteAccountMgrNode:setVisible(false)
     self.accountMgrNode:setVisible(true)
     if self._tipImg ~= nil then
        self._tipImg:removeFromParentAndCleanup(true)
        self._tipImg = nil 
     end
  else
     self.regNode:setVisible(false)
     self.templeteAccountMgrNode:setVisible(true)
     self.accountMgrNode:setVisible(false)
     status=_tr("login_error_msg_"..status);
     tip =status
  end
  local pop = PopupView:createTextPopup(tip, function() return end,true)
  GameData:Instance():getCurrentScene():addChildView(pop)
end
function LoginView:setSwitchFlag(flag)
   self._switchFlag=flag
end

function LoginView:getSwitchFlag()
   return self._switchFlag
end

function LoginView:setLoginSdkState(isSuccess)
  self._loginSdkSuccess = isSuccess
end 

function LoginView:getLoginSdkState()
  return self._loginSdkSuccess
end 

function LoginView:onRegister(userName)
  local dlChannel = ChannelManager:getCurrentDownloadChannel()
  if CCLuaObjcBridge~=nil and dlChannel == "appstore" then
    local luaoc=require("framework.ocbridge")
    local className="TalkingDataSdk"
    local args={account=userName}
    luaoc.callStaticMethod(className,"onRegisterLua",args)
  end
end




return LoginView