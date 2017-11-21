

local net = {}

NetAction = {}
NetAction.NONE = 0
NetAction.ON_CONNETING_LOGIN_SERVER = 100001
NetAction.ON_CONNETING_LOGIN_SERVER_FAILED = 100002
NetAction.ON_CONNETED_LOGIN_SERVER = 100003
NetAction.ON_CONNETING_GAME_SERVER = 100004
NetAction.ON_CONNETING_GAME_SERVER_FAILED = 100005
NetAction.ON_CONNETED_GAME_SERVER = 100006
NetAction.ON_DISCONNECTING_FROM_GAME_SERVER = 100007
NetAction.ON_DISCONNECTED_FROM_GAME_SERVER = 100008
NetAction.ON_RECV_GAME_MESSAGE = 100009

NetAction.REQ_NONE = 0
NetAction.REQ_CONNECT_LOGIN_SERVER = 200001
NetAction.REQ_CONNECT_GAME_SERVER = 200002
NetAction.REQ_SEND_GAME_MESSAGE = 200003
NetAction.REQ_DISCONNECT = 200004

net.HeartBeartInterval = 2.0
net.MaxHeartBeatTimeoutCount = 0
net.MaxHeartBeatTimeout = 10.0

net._userId = 0
net.isConnected = false
net.heartBeatTimeoutCount = 0
net.lastHeartBeatTime = 0

net.actionHandler = {}
net.messageHandler = {}
net.callback = {}

net.onRecvMessage = function (msgId,data)
  local pbMsg = PbRegist.unpack(msgId,data)

  if net.messageHandler[msgId] ~= nil then
    net.messageHandler[msgId](msgId,pbMsg)
  else
    echo("No handler for message:"..msgId) 
  end
  return pbMsg
end

function net.setUserId(_userId)
--  assert(_userId ~= 0,string.format("Invalid user id:%d",_userId))
  net._userId = _userId
  printf("Set user id:%d",_userId)
end

net.onConnectingLoginServer = function(msgId,data)
  printf("On connecting login server..")
end

net.onConnectedLoginServer = function(msgId,data)
  printf("On connected login server.")
end

net.onConnectingGameServer = function(msgId,data)
  printf("On connecting game server..")
end

net.onConnectedGameServer = function(msgId,data)
  printf("On connected game server.")
end

net.onDisconnectingGameServer = function(msgId,data)
  printf("On disconnecting game server..")
end

net.onDisconnectedGameServer = function(msgId,data)
  printf("On disconnected game server.")
end

function net.registActionHandler(action,handler)
  net.actionHandler[action] = handler
end

function net.registMessageHandler(msgId,handler)
  net.messageHandler[msgId] = handler
end

function net.registCallback(action,msgId,target,callback)
--  printf("==>registCallback,action:%d,msgId:%d",action,msgId)
  if nil == net.callback[action] then
--    printf("No callback for action:%d,create it",action)
    net.callback[action] = {}
  end
  local actionPkg = net.callback[action]
  if nil == actionPkg[msgId] then
--    printf("No callback for msg:%d,create it",msgId)
    actionPkg[msgId] = {}
  end
  local msgPkg = actionPkg[msgId]
  local param = {}
  param.target = target
  param.func = callback
--  printf("Insert callback for action:%d,msg:%d,index:%d",action,msgId,#msgPkg + 1)
  msgPkg[#msgPkg + 1] = param
  
--  net.printCallback()
end

function net.printCallback()
  printf("net.printCallback")
  for key1, var1 in pairs(net.callback) do
    printf("  action:%d",key1)
  	for key2, var2 in pairs(var1) do
  	  printf("    msgId:%d",key2)
  	  for key3, var3 in pairs(var2) do
  	    printf("      index:%d",key3)
  	  end

  	end
  end
end


function net.unregistCallback(action,msgId,target)
  if nil ~= net.callback[action] then
    local t = net.callback[action][msgId]
    if nil ~= t then
      for index, callback in pairs(t) do
        if callback.target == target then
         printf("To remove callback{ action = %d,msg = %d,index = %d }",action,msgId,index)
         t[index] = nil
        end
      end
    end
  end
end

function net.unregistMsgCallback(action,msgId,target)
  net.unregistCallback(NetAction.ON_RECV_GAME_MESSAGE,msgId,target)
end

function net.unregistAllCallback(target)
  for action, action_callbacks in pairs(net.callback) do
--    printf("  action:%d",action)
  	for msgId, msg_callbacks in pairs(action_callbacks) do
--  	  printf("    msgId:%d",msgId)
  	  for index, callback in pairs(msg_callbacks) do
--  	    printf("      index:%d",index)
  	    if callback.target == target then
  	     printf("To remove callback{ action = %d,msg = %d,index = %d }",action,msgId,index)
  	     msg_callbacks[index] = nil
  	    end
      end
  	end
  end
end

function net.registMsgCallback(msgId,target,callback)
  net.registCallback(NetAction.ON_RECV_GAME_MESSAGE,msgId,target,callback)
end

function net.unregistMsgCallback(msgId,target)
  net.unregistCallback(NetAction.ON_RECV_GAME_MESSAGE,msgId,target)
end

-- regist default handler
net.registActionHandler(NetAction.ON_CONNETING_LOGIN_SERVER,net.onConnectingLoginServer)
net.registActionHandler(NetAction.ON_CONNETED_LOGIN_SERVER,net.onConnectedLoginServer)
net.registActionHandler(NetAction.ON_CONNETING_GAME_SERVER,net.onConnectingGameServer)
net.registActionHandler(NetAction.ON_CONNETED_GAME_SERVER,net.onConnectedGameServer)
net.registActionHandler(NetAction.ON_DISCONNECTING_FROM_GAME_SERVER,net.onDisconnectingGameServer)
net.registActionHandler(NetAction.ON_DISCONNECTED_FROM_GAME_SERVER,net.onDisconnectedGameServer)
net.registActionHandler(NetAction.ON_RECV_GAME_MESSAGE,net.onRecvMessage)

function net.onRecvAction(action,msgId,data)
  if msgId ~= 1000 then 
    printf("net.onRecvAction,action:%d,msgId:%d",action,msgId)
  end 

  if net.actionHandler[action] ~= nil then
    local pbMsg = net.actionHandler[action](msgId,data)
    if pbMsg == nil then
      printf("net.onRecvAction,pbMsg is nil.")
    end
    net.dispatch(action,msgId,pbMsg)
  else
    echoError("Can not handle action:"..action)
  end
end

function net.dispatch(action,msgId,pbMsg)
  if nil ~= net.callback[action] then
    local t = net.callback[action][msgId]
    -- dispatch msg
    if nil ~= t then
      for key, param in pairs(t) do
        assert(param.target ~= nil,"Invalid param in callback regist execute")
        assert(param.func ~= nil,"Invalid param in callback regist execute")
--        param.func(param.target,action,msgId,pbMsg)
        param.func(param.target,action,msgId,pbMsg)
        
      end
    else
--      printf("Invalid callback,t is nil")
    end
  end
end

function net.sendMessage(msgId,data)
  net.sendAction(NetAction.REQ_SEND_GAME_MESSAGE,msgId,data)
end

function net.sendAction(action,msgId,data)
  if nil == msgId then
    msgId = 0
  end
  if nil == data then
    data = ""
  end
--  if action == NetAction.REQ_SEND_GAME_MESSAGE and msgId ~= PbMsgId.FastCreatePlayer and net._userId == 0 then
--    assert(false)
--  end
  c_send_action(action,msgId,net._userId,data)
end

function net.pumpAction()
  if c_pump_action ~= nil then
    local action,msgId,data = c_pump_action()
    if action ~= nil then
      net.onRecvAction(action,msgId,data)
    end
    
  else
    echoError("You should define C pump message interface")
  end
end

function net.keepAlive()
  if net.isConnected == true and net._userId ~= 0 then
    if net.lastHeartBeatTime == 0 then
      net.lastHeartBeatTime = os.time()
    end
    local duration = os.time() - net.lastHeartBeatTime
    if duration > net.MaxHeartBeatTimeout then
      -- timeout
      net.heartBeatTimeoutCount = net.heartBeatTimeoutCount + 1
      -- exceed max timeout count,prepare to reconnect
      if net.heartBeatTimeoutCount > net.MaxHeartBeatTimeoutCount then
	    print("initiative send netAction REQ_DISCONNECT")
        net.sendAction(NetAction.REQ_DISCONNECT)
      end
    else
      net.heartBeatTimeoutCount = 0
    end
    net.doHeartBeatFunc()
  end
end

function net.doHeartBeatFunc()
  -- do nothing
  -- you should overwrite it
end

function net.resetKeepAlive()
  net.heartBeatTimeoutCount = 0
  net.lastHeartBeatTime = 0
end

function net.onRecvHeartBeatRsp()
  net.resetKeepAlive()
end

---- global function for C call
--function lua_recvAction(action,msgId,data)
--  net.onRecvAction(action,msgId,data)
--end

function net.setup_login_server(ip,port)
  c_setup_login_server(ip,port)
end

function net.setup_game_server(ip,port)
  c_setup_game_server(ip,port)
end

function net.loop()
  local scheduler = CCDirector:sharedDirector():getScheduler()
  
  net._loopFuncId = scheduler:scheduleScriptFunc(net.pumpAction,0,false)
  net._keepAliveFuncId = scheduler:scheduleScriptFunc(net.keepAlive,net.HeartBeartInterval,false)
end

function net.connect()
  if net.isConnected == false then
    net.sendAction(NetAction.REQ_CONNECT_LOGIN_SERVER,0,nil)
  else
    printf("Already conected to game server.")
  end
end

function net.pause()
  local scheduler = CCDirector:sharedDirector():getScheduler()
  scheduler:unscheduleScriptEntry(net._loopFuncId)
end



return net

