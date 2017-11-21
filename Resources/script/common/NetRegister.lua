NetRegister = {}

net.isTryingReconnect = false
net.isActiveDisconnect = false
net.registActionHandler(NetAction.ON_CONNETING_LOGIN_SERVER_FAILED,function(msgId,data)
  printf("Failed to connect login server.")
end)

net.registActionHandler(NetAction.ON_CONNETED_LOGIN_SERVER,function(msgId,data)
  local pbMsg = PbRegist.unpack(msgId,data)
  print("NetAction.ON_CONNETED_LOGIN_SERVER success")
  if msgId == PbMsgId.NoValidGateServer then
    printf("No valid game server now.");
  elseif msgId == PbMsgId.ValidGateServerInformation then
    printf("Valid game server [address:%s,port:%d]",pbMsg.address,pbMsg.port)
    net.setup_game_server(pbMsg.address,pbMsg.port)
    net.sendAction(NetAction.REQ_CONNECT_GAME_SERVER,0,nil)
  else
     printf("Unknown login server response,msgId:%d",msgId);
  end
  
end)

net.registActionHandler(NetAction.ON_CONNETING_GAME_SERVER_FAILED,function(msgId,data)
  printf("Failed to connect game server.")
  if net.isTryingReconnect == true then
    CCNotificationCenter:sharedNotificationCenter():postNotification(EventType.RECONNECT_FAILED)
  end
end)

net.registActionHandler(NetAction.ON_CONNETED_GAME_SERVER,function(msgId,data)
  printf("Connected to game server.")
  net.isConnected = true
  
  if net.isTryingReconnect == true then
    if net.isActiveDisconnect == false then
       local account = GameData:Instance():getCurrentAccount()
       account:reqLogin()
    end
    
    net.resetKeepAlive()
    CCNotificationCenter:sharedNotificationCenter():postNotification(EventType.RECONNECT_SUCCESS)
    
    net.isActiveDisconnect = false
    net.isTryingReconnect = false
  end
end)

net.registActionHandler(NetAction.ON_DISCONNECTED_FROM_GAME_SERVER,function(msgId,data)
  printf("Disconnect from game server.")
  net.isConnected = false
  if net.isActiveDisconnect == false then
     net.isTryingReconnect = true
     CCNotificationCenter:sharedNotificationCenter():postNotification(EventType.RECONNETING)
     net.sendAction(NetAction.REQ_CONNECT_GAME_SERVER,0,nil)
  end
  
end)

----------- handle msg -------------------

net.doHeartBeatFunc = function()
   local echoData = PbRegist.pack(PbMsgId.PingPong,{information = "ping",})
   net.sendAction(NetAction.REQ_SEND_GAME_MESSAGE,PbMsgId.PingPong,echoData) 
end

net.registMessageHandler(PbMsgId.PingPong,function(msgId,pbMsg)
  net.onRecvHeartBeatRsp()
--  printf("Ping pong msg information:%s.",pbMsg.information)
  return pbMsg
end)

net.registMessageHandler(PbMsgId.FastCreatePlayerResult,function(msgId,pbMsg)
  local account = GameData:Instance():getCurrentAccount()
  local result = pbMsg.result
  if result == "Ok" then
    dump(pbMsg)
    net.setUserId(pbMsg.id)
    account:setId(pbMsg.id)
    printf("pbMsg.password:%s",pbMsg.password)
    account:setName(pbMsg.name)
    account:setPassword(pbMsg.password)
    account:save()
    account:setIsRegisted(true)
  end
end)

net.registMessageHandler(PbMsgId.LoginResult,function(msgId,pbMsg)
  local account = GameData:Instance():getCurrentAccount()
  local result = pbMsg.state
  if result == "Ok" then
    net.setUserId(pbMsg.player_id)
    account:setId(pbMsg.player_id)
    account:save()
    account:setIsRegisted(true)
  end
end)

net.registMessageHandler(PbMsgId.PlayerDailyChangedInformation,function(msgId,pbMsg)
  print("------------------------PbMsgId.PlayerDailyChangedInformation--")

  local player = GameData:Instance():getCurrentPlayer()
  if player == nil then 
    player = Player.new()
    GameData:Instance():setCurrentPlayer(player)
  end

  player:updatePlayerDailyChangedInformation(pbMsg, false)
  CCNotificationCenter:sharedNotificationCenter():postNotification(EventType.PLAYER_UPDATE)
end)

net.registMessageHandler(PbMsgId.PlayerBaseInformation,function(msgId,pbMsg)

  print("------------------------PbMsgId.PlayerBaseInformation")

  local player = GameData:Instance():getCurrentPlayer()
  if player == nil then 
    player = Player.new()
    GameData:Instance():setCurrentPlayer(player)
  end
  player:update(msgId,pbMsg)

  CCNotificationCenter:sharedNotificationCenter():postNotification(EventType.PLAYER_UPDATE)
  
  local package = GameData:Instance():getCurrentPackage()
  if package == nil then
      package = Package.new()
      GameData:Instance():setCurrentPackage(package)
  end
  package:update(msgId,pbMsg)
  
  --req FriendList
	local friend =  Friend:Instance()
	friend:cleanFriendData()
	friend:reqFriendList("QUERY_ALL")
  --req mail list
  --MailBox:instance():reqMails()

  -- req QueryInteractBaseData
	local mining = Mining:Instance()
	local userId = player:getId()
	mining:reqBasedataWithUserId(userId)
  --save login time

  -- req pay list
  Pay:Instance():reqPayDataWithMoneyType()

  Activity:instance():checkActivityMsg()

  local expedition = GameData:Instance():getExpeditionInstance()
  if expedition ~= nil then
    if expedition:getPVPQueryFlag() == true then
       expedition:reqPVPQueryDataC2S()
    end
  end
  
  if PvpRankMatch:Instance():getHasInited() == true then
    PvpRankMatch:Instance():init()
  end
  
  if GameData:Instance():checkSystemOpenCondition(43, false) == true then 
    Guild:Instance():init()
  end
  
end)

net.registMessageHandler(PbMsgId.PlayerStoreInfoS2C,function(msgId,pbMsg)
  print("NetRegister.lua : msg-->PlayerStoreInfoS2C")
  Shop:instance():initShopData(pbMsg)
end)

net.registMessageHandler(PbMsgId.PlayerRefreshStoreResultS2C,function(msgId,pbMsg)
  print("NetRegister.lua : msg-->PlayerRefreshStoreResultS2C")
  GameData:Instance():getCurrentPackage():parseClientSyncMsg(pbMsg.client)
  Shop:instance():initShopData(pbMsg)
end)


net.registMessageHandler(PbMsgId.SyncTime,function(msgId,pbMsg)
	print("server time2",os.date("%Y/%m/%d/ %X",pbMsg.receive_message_time))
	Clock:Instance():setDeviationTime(pbMsg.receive_message_time) 
  Clock:Instance():setTimeZone(pbMsg.time_zone)
end)

net.registMessageHandler(PbMsgId.GameServerInformationS2C,function(msgId,pbMsg)
  print("server open time",os.date("%Y/%m/%d/ %X",pbMsg.server_begin_time))
  Clock:Instance():setServerOpenTime(pbMsg.server_begin_time, pbMsg.time_zone)
end)

net.registMessageHandler(PbMsgId.RankInformationS2C,function(msgId,pbMsg)
  print("NetRegister.lua : msg-->RankInformationS2C")
  GameData:Instance():setPlayersRank(pbMsg)
end)

net.registMessageHandler(PbMsgId.ActivityMissionInfos,function(msgId,pbMsg)
  print("NetRegister.lua : msg-->ActivityMissionInfos")
  Activity:instance():initActMissionState(pbMsg)
end)

net.registMessageHandler(PbMsgId.RechargeMaxInfo,function(msgId,pbMsg)
  print("NetRegister.lua : msg-->RechargeMaxInfo")
  Home:instance():initRechargeTopInfo(pbMsg)
end)

net.registMessageHandler(PbMsgId.ActivityStateS2C,function(msgId,pbMsg)
  print("NetRegister.lua : msg-->ActivityStateS2C")
  Activity:instance():initActivityOpenState(pbMsg)
end)