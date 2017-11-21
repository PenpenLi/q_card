Account = class("Account")

function Account:ctor()
  self:setIsRegisted(false)
  self:setId(0)
  self:setName("")
  self:setPassword("")
  net.registMsgCallback(PbMsgId.ForceOffline,self,Account.forceOfflined)
  net.registMsgCallback(PbMsgId.LoginResult,self,Account.onLoginResult)
  net.registMsgCallback(PbMsgId.LoginVersionChangeS2C,self,Account.onLoginVersionChangeS2C)
end


function Account:loadFromNet(id,password)
  self:setId(msg.id)
  if nil == password then
    self:setPassword("")
  else
    self:setPassword(password)
  end
end

function Account:onLoginVersionChangeS2C()
  print("onLoginVersionChangeS2C")
  CCNotificationCenter:sharedNotificationCenter():postNotification(EventType.CLIENT_VERSION_CHANGED)
end

function Account:forceOfflined()
   CCNotificationCenter:sharedNotificationCenter():postNotification(EventType.FORCE_OFFLINE)
end

------
--  Getter & Setter for
--      Account._LoginResult 
-----
function Account:setLoginResult(LoginResult)
	self._LoginResult = LoginResult
end

function Account:getLoginResult()
	return self._LoginResult
end

function Account:onLoginResult(action,msgId,msg)
   echo("Account:onLoginResult:",msg.state)
   self:setLoginResult(msg)
   if ControllerFactory:Instance():getCurrentControllerType() ~=  ControllerType.REGIST_CONTROLLER
   and msg.state == "ERROR_CLIENT_VERSION"
   then
      GameData:Instance():getCurrentScene():clientVersionChangedHandler()
   end
   CCNotificationCenter:sharedNotificationCenter():postNotification(EventType.LOGIN_RESULT)
end

function Account:loadFromFile(path)
  if nil == path then
    local netItem = GameData:Instance():getCurNetItem()
    echo("---loadFromFile:area = ", netItem.area)
    self:setId(CCUserDefault:sharedUserDefault():getIntegerForKey("user_id"))
    self:setName(CCUserDefault:sharedUserDefault():getStringForKey("user_name"))
    self:setPassword(CCUserDefault:sharedUserDefault():getStringForKey("user_password"))
    self:setChannel(CCUserDefault:sharedUserDefault():getStringForKey("user_channel"))
    self:setSign(CCUserDefault:sharedUserDefault():getStringForKey("user_signkey"))
    self:setDSUCName(CCUserDefault:sharedUserDefault():getStringForKey("dsus_name"))
    self:setDSUCPassword(CCUserDefault:sharedUserDefault():getStringForKey("dsus_password"))
    self:setShowName(CCUserDefault:sharedUserDefault():getStringForKey("user_show_name"))
    
    CCUserDefault:sharedUserDefault():flush()
  else
    echoError("Not yet implemented.")
  end
  echo("---loadFromFile: id= ", self:getId())
  -- TODO set whether this device has been registed
  if self:getName() ~= nil and "" ~= self:getName() then
    self:setIsRegisted(true)
  else
    self:setIsRegisted(false)
  end  
end

function Account:save(path)
  if nil == path then
    local netItem = GameData:Instance():getCurNetItem()    
    CCUserDefault:sharedUserDefault():setIntegerForKey("user_net_prefer", netItem.area)
    CCUserDefault:sharedUserDefault():setIntegerForKey("user_id", self:getId())
    CCUserDefault:sharedUserDefault():setStringForKey("user_name", self:getName())
    CCUserDefault:sharedUserDefault():setStringForKey("user_password", self:getPassword())
    CCUserDefault:sharedUserDefault():setStringForKey("user_channel", self:getChannel())
    CCUserDefault:sharedUserDefault():setStringForKey("user_signkey", self:getSign())
    CCUserDefault:sharedUserDefault():setStringForKey("dsus_name",self:getDSUCName())
    CCUserDefault:sharedUserDefault():setStringForKey("dsus_password",self:getDSUCPassword())
    CCUserDefault:sharedUserDefault():flush()
  else
    echoError("Not yet implemented.")
  end
end

function Account:reset()
  self:setId(0)
  self:setName("")
  self:setPassword("")
  local netItem = GameData:Instance():getCurNetItem()
  --CCUserDefault:sharedUserDefault():setIntegerForKey("user_net_prefer", netItem.area)
  CCUserDefault:sharedUserDefault():setIntegerForKey("user_id", 0)
  CCUserDefault:sharedUserDefault():setStringForKey("user_name", "")
  CCUserDefault:sharedUserDefault():setStringForKey("user_password", "")
  CCUserDefault:sharedUserDefault():setStringForKey("user_channel", "")
  CCUserDefault:sharedUserDefault():setStringForKey("user_signkey", "")
  CCUserDefault:sharedUserDefault():setStringForKey("dsus_name", "")
  CCUserDefault:sharedUserDefault():setStringForKey("dsus_password", "")
  CCUserDefault:sharedUserDefault():flush()
  self:setIsRegisted(false)
  --GameData:Instance():setEnabledActiveTipDisconnect(false)
end

function Account:checkIsValid()
  if self:getIsRegisted() == true then
    if self:getName() == "" then
      return false
    end
    if self:getPassword() == "" then
      return false
    end
  else
    return true
  end
end

function Account:genUserName()
  local time = os.time() + os.clock()
  time = toint(time - 1380000000);
  
  local digit = 1
  local random = 0
  for i = 1,4 do
    digit = digit * 10
    random = random + toint(math.random() * digit)
  end
  random = random + time * digit
  
  local code = to_base64(random)
  local name = "D_"..code
  
  return name
end

function Account:genPassword()
  local digit = 1
  local random = 0
  for i = 1,8 do
    digit = digit * 10
    random = random + toint(math.random() * digit)
  end
  
  local code = to_base64(random)
  local password = code

  return password
end


function Account:reqLogout()
  local data = PbRegist.pack(PbMsgId.Logout)
  net.sendMessage(PbMsgId.Logout,data)
end

function Account:reqLogin()
  local _name = self:getName()
  local _password = self:getPassword()
  self:onLogin()
  if nil ~= _name and nil ~= _password then
--    GameData:Instance():setEnabledActiveTipDisconnect(true)
    local strVersionCode =  CCUserDefault:sharedUserDefault():getStringForKey("current-version-code")
    if strVersionCode == nil or strVersionCode == "" then
       strVersionCode = "1.0.0.0"
    end
    print("strVersionCode:",strVersionCode)
    --assert(false)
    local downLoadChannel = ChannelManager:getCurrentDownloadChannel()
    local data = nil 
--    if GameEntry:instance():isUcPlatform() == true then 
--      local _chn = GameEntry:instance():getChannel()
--      local _sign = GameEntry:instance():getSign()
--      data = PbRegist.pack(PbMsgId.Login,{name = _name,key = _password,property = "Force", channel=_chn, sign=_sign,version = strVersionCode,down_channel = downLoadChannel })
--    else 
      local _chn=self:getChannel()
      local _sig=self:getSign()
      
      if device.platform == "windows" or device.platform == "mac" then
        downLoadChannel = "ow"
      end
      
      data = PbRegist.pack(PbMsgId.Login,{name = _name,key = _password,property = "Force",channel=_chn, sign=_sig,version = strVersionCode,down_channel = downLoadChannel })
    --end    
    
    net.setUserId(0)
    net.sendMessage(PbMsgId.Login,data)
    printf("name:%s,password:%s",_name,_password)
    return true
  else
    printf("Login needs user name")
    return false
  end  
end

-- fast create 
function Account:reqDSUCFastCreate()
    net.setUserId(0)
    printf("reqDSUCFastCreate")
    self:setIsFastCreate(true)
    UserLogin:fastCreateUser()
end

function Account:setIsFastCreate(isFastCreate)
  self._isFastCreate = isFastCreate
end

function Account:getIsFastCreate()
  return self._isFastCreate
end

function Account:reqFastCreate()
    net.setUserId(0)
    local strVersionCode =  CCUserDefault:sharedUserDefault():getStringForKey("current-version-code")
    if strVersionCode == nil or strVersionCode == "" then
       strVersionCode = "1.0.0.0"
    end
    local data = PbRegist.pack(PbMsgId.FastCreatePlayer , {version = strVersionCode})
    net.sendMessage(PbMsgId.FastCreatePlayer,data)
end

function Account:reqFastCreateForUC()
    net.setUserId(0)
    local user = self:getName()
    local psw = self:getPassword()
    echo("Account:reqFastCreateForUC,usr,psw:", user, psw)
    local data = PbRegist.pack(PbMsgId.FastCreatePlayer, {name = user, password = psw})
    net.sendMessage(PbMsgId.FastCreatePlayer,data)
end

function Account:reqLoginOrCreate()
  if self:getIsRegisted() ~= true then
    self:reqFastCreate()
  else
    self:reqLogin()
  end
end

--function Account:onFastCreateResult(msgId,msg)
--  self.view.onFastCreateResult(msgId,msg)
--end
--
--function Account:onLoginResult(msgId,msg)
--  
--end

------
--  Getter & Setter for
--      Account._IsRegisted 
-----
function Account:setIsRegisted(IsRegisted)
	self._IsRegisted = IsRegisted
end

function Account:getIsRegisted()
	return self._IsRegisted
end

------
--  Getter & Setter for
--      Account._Id 
-----
function Account:setId(Id)
	self._Id = Id
end

function Account:getId()
	return self._Id
end


------
--  Getter & Setter for
--      Account._Name 
-----
function Account:setName(Name)
	self._Name = Name
end

function Account:getName()
--  local isUcPlatform = GameEntry:instance():isUcPlatform()
--  if isUcPlatform == true then 
--    return GameEntry:instance():getUserName()
--  end
	return self._Name
end

------
--  Getter & Setter for
--      Account._Password 
-----
function Account:setPassword(Password)
	self._Password = Password
end

function Account:getPassword()
--  local isUcPlatform = GameEntry:instance():isUcPlatform()
--  if isUcPlatform == true then 
--    return GameEntry:instance():getPassword()
--  end 

	return self._Password
end
function Account:setChannel(channel)
  self._channel=channel
end
function Account:getChannel()
  return self._channel
end

function Account:setSign(sign)
    self._signString=sign
end
function Account:getSign()
  return self._signString
end

function Account:setDSUCName(name)
  self._dsucName = name
  self:setShowName(name)
end

function Account:getDSUCName()
  return self._dsucName
end

------
--  Getter & Setter for
--      Account._DSUCPassword 
-----
function Account:setDSUCPassword(DSUCPassword)
	self._DSUCPassword = DSUCPassword
end

function Account:getDSUCPassword()
	return self._DSUCPassword
end

function Account:setShowName(showName)
  self._showName = showName
end

function Account:getShowName()
  if self._showName ~= nil then
     return self._showName
  end
  return CCUserDefault:sharedUserDefault():getStringForKey("user_show_name")
  
end

function Account:setTempUserName(userName)
   self._tempUserName=userName;
end

function Account:getTempUserName()
   return self._tempUserName; 
end

function Account:setTempPassword(tempPassword)
   self._tempPassword=tempPassword;
end

function Account:getTempPassword()
   return self._tempPassword; 
end

function Account:onLogin()
  local dlChannel = ChannelManager:getCurrentDownloadChannel()
  if CCLuaObjcBridge~=nil and dlChannel == "appstore" then
    local userName=self:getTempUserName()
    local luaoc=require("framework.ocbridge")
    local className="TalkingDataSdk"
    local args={account=userName}
    luaoc.callStaticMethod(className,"onLoginLua",args)
  end
end 


return Account
