require("model.arena.ArenaPlayer")
require("model.arena.ArenaFightInfo")
require("model.arena.ArenaConfig")
Arena = class("Arena")

local function sortTables(a, b)
   return a < b
end

function Arena:ctor()
end

--function Arena.renew()
--	if(Arena._ArenaInstance ) then
--		Arena._ArenaInstance:destory()
--		Arena._ArenaInstance = nil
--		Arena:Instance()
--	end
--end

function Arena:Instance()
	if Arena._ArenaInstance == nil then
		Arena._ArenaInstance = Arena.new()
		Arena._ArenaInstance:init()
	end
	return Arena._ArenaInstance
end

function Arena:init()
   self:setRankList({})
   self:setLastRankLists({})
   self:setSeverState("ARENA_CLOSE")
   self:setIsSearching(false)

  --set open/close date
  local activityData = nil
  for key, activity in pairs(AllConfig.activity) do
  	if activity.activity_id == 1009 then
      activityData = activity
      break
    end
  end
  
  assert(activityData ~= nil)
  
  self:setOpenDate(activityData.open_date)
  self:setCloseDate(activityData.close_date)
  self:setValidWeekDay(activityData.week_date)
   
   --set open/close time
  local activityDayData = nil
  for key, activity in pairs(AllConfig.dailyevent) do
    if activity.activity_id == 1009 then
      activityDayData = activity
      break
    end
  end
  
  assert(activityDayData ~= nil)
   
  self:setValidDayTime(activityDayData.open_time, activityDayData.close_time)
   
  self:registNetSever()
   
  --self:reqPVPArenaQueryC2S()
end

function Arena:registNetSever()
  net.registMsgCallback(PbMsgId.PVPArenaQueryResultS2C,self,Arena.onPVPArenaQueryResultS2C)
  net.registMsgCallback(PbMsgId.PVPArenaSearchResultS2C,self,Arena.onPVPArenaSearchResultS2C)
  net.registMsgCallback(PbMsgId.PVPArenaChangeCardResultS2C,self,Arena.onPVPArenaChangeCardResultS2C)
  net.registMsgCallback(PbMsgId.PVPArenaTargetChangeCardS2C,self,Arena.onPVPArenaTargetChangeCardS2C)
  net.registMsgCallback(PbMsgId.PVPArenaFightResultS2C,self,Arena.onPVPArenaFightResultS2C)
  net.registMsgCallback(PbMsgId.PVPArenaStateS2C,self,Arena.onPVPArenaStateS2C)
  net.registMsgCallback(PbMsgId.PVPArenaRankS2C,self,Arena.onPVPArenaRankS2C)
  net.registMsgCallback(PbMsgId.PVPArenaBuyChanceResultS2C,self,Arena.onPVPArenaBuyChanceResultS2C)
end

function Arena:destory()
  net.unregistAllCallback(self)
--  ArenaConfig.reset()
--  Arena._ArenaInstance = nil
end

------
--  Getter & Setter for
--      Arena._ArenaView 
-----
function Arena:setArenaView(ArenaView)
	self._ArenaView = ArenaView
end

function Arena:getArenaView()
	return self._ArenaView
end

------
--  Getter & Setter for
--      Arena._IsSearching 
-----
function Arena:setIsSearching(IsSearching)
	self._IsSearching = IsSearching
end

function Arena:getIsSearching()
	return self._IsSearching
end


---here means arena controller
------
--  Getter & Setter for
--      Arena._Delegate 
-----
function Arena:setDelegate(Delegate)
  self._Delegate = Delegate
end

function Arena:getDelegate()
  return self._Delegate
end

function Arena:onPVPArenaRankS2C(action,msgId,msg)
--message PVPArenaRankS2C{
--  enum traits{value = 5145;}
--  message RankInfo{
--    optional int32 rankId = 2;
--    repeated PVPArenaData rank_data = 1;
--  };
--  repeated RankInfo ranks = 1;
--}
  
  local lastArenaRankLists = {}
  dump(msg.ranks)
  if msg.ranks ~= nil then
    for key, arenaRankData in pairs(msg.ranks) do
        local rankList = {}
        local rankId = arenaRankData.rankId
        for key, playerData in pairs(arenaRankData.rank_data) do
        	  local player = ArenaPlayer.new(playerData)
        	  table.insert(rankList,player)
        end
        local arenaGroup = {}
        arenaGroup.rankList = rankList
        arenaGroup.rankId = rankId
        table.insert(lastArenaRankLists,arenaGroup)
    end
  end
  self:setLastRankLists(lastArenaRankLists)
  if self:getArenaView() ~= nil then
     self:getArenaView():updateView(self)
  end
--  print(#lastArenaRankLists)
--  dump(lastArenaRankLists)
--  assert(false)
end

------
--  Getter & Setter for
--      Arena._LastRankLists 
-----
function Arena:setLastRankLists(LastRankLists)
	self._LastRankLists = LastRankLists
end

function Arena:getLastRankLists()
	return self._LastRankLists
end


function Arena:reqPVPArenaBuyChanceC2S(cost)
--  message PVPArenaBuyChanceC2S{
--  enum traits{value = 5146;}  
--  optional int32 cost = 1;
--  }
  _showLoading()
  local data = PbRegist.pack(PbMsgId.PVPArenaBuyChanceC2S,{cost = cost})
  net.sendMessage(PbMsgId.PVPArenaBuyChanceC2S,data)
  
end

function Arena:onPVPArenaBuyChanceResultS2C(action,msgId,msg)
--message PVPArenaBuyChanceResultS2C{
--  enum traits{value = 5147;}  
--  enum ErrorCode{
--    NO_ERROR_CODE = 1;
--    NOT_HAS_ENOUGH_MONEY = 2;
--    PVP_ARENA_CLOSE = 3;
--    NOT_FOUND_AREAN_DATA = 5;
--    HAS_SEARCH_COUNT = 6;
--    LEVEL_LIMIT = 7;
--    SYSTEM_ERROR = 4;
--  }
--  required ErrorCode    error  = 1;
--  optional PVPArenaBase base = 2;
--  optional ClientSync   client = 3;
--  optional int32        cost = 4;
--}
  _hideLoading()
  print("onPVPArenaBuyChanceResultS2C:",msg.error)
  if msg.error == "NO_ERROR_CODE" then
    local selfPlayer = self:getSelfPlayer()
    if selfPlayer == nil then
       selfPlayer = ArenaPlayer.new()
       self:setSelfPlayer(selfPlayer)
    end
    selfPlayer:update(msg.base)
    
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)
    
    if self:getArenaView() ~= nil then
     self:getArenaView():updateView(self)
    end
    
  else
    Toast:showString(GameData:Instance():getCurrentScene(), msg.error, ccp(display.cx, display.height*0.5))
  end
  
end

function Arena:reqPVPArenaQueryC2S()
   _showLoading()
   local data = PbRegist.pack(PbMsgId.PVPArenaQueryC2S)
   net.sendMessage(PbMsgId.PVPArenaQueryC2S,data)
end

function Arena:onPVPArenaQueryResultS2C(action,msgId,msg)
  --[[
  enum ErrorCode{
    NO_ERROR_CODE = 1;  //
    NOT_OPEN_TIME = 2;  //时间没到
    LEVEL_LIMIT   = 3;  //等级不够
    SYSTEM_ERROR  = 4;  //其他错误
  }
  required ErrorCode error = 1;     
  optional PVPArenaData data = 2; 
  ]]
  
  --[[
  message PVPArenaData{
  optional PVPArenaBase base = 1;   //基础数据
  repeated PVPArenaBase rankList = 2; //当前排行榜
  optional int32 rankNo = 3;      //自己排行数据
  }
  ]]
  _hideLoading()
  print("Arena:onPVPArenaQueryResultS2C:",msg.error)
  dump(msg)
  
  if msg.error == "NO_ERROR_CODE" then
    self:updateSelfPVPArenaData(msg.data)
  else
    print(ServerError.GetOrShowDescrible(msg.error,false,ServerError.Type.ARENA))
  end
  
end

------
--  Getter & Setter for
--      Arena._TargetPlayer 
-----
function Arena:setTargetPlayer(TargetPlayer)
	self._TargetPlayer = TargetPlayer
end

function Arena:getTargetPlayer()
	return self._TargetPlayer
end

------
--  Getter & Setter for
--      Arena._SelfPlayer 
-----
function Arena:setSelfPlayer(SelfPlayer)
	self._SelfPlayer = SelfPlayer
end

function Arena:getSelfPlayer()
	return self._SelfPlayer
end

------
--  Getter & Setter for
--      Arena._RankList 
-----
function Arena:setRankList(RankList)
	self._RankList = RankList
end

function Arena:getRankList()
	return self._RankList
end

------
--  Getter & Setter for
--      Arena._SelfRankNum 
-----
function Arena:setSelfRankNum(SelfRankNum)
	self._SelfRankNum = SelfRankNum
end

function Arena:getSelfRankNum()
	return self._SelfRankNum
end

function Arena:reqPVPArenaSearchC2S(isCancle)
  --[[message PVPArenaSearchC2S{
  enum traits{value = 5129;}
  optional bool cancel = 1; // 是否取消搜索
  }
  ]]
   
   if isCancle == nil then
      isCancle = false
   end
   
   if isCancle == true then
     _showLoading()
     self:setIsSearching(false)
   else
     self:setIsSearching(true)
   end
   
   print("reqPVPArenaSearchC2S:  cancel=",isCancle)
  
   local data = PbRegist.pack(PbMsgId.PVPArenaSearchC2S,{cancel = isCancle})
   net.sendMessage(PbMsgId.PVPArenaSearchC2S,data)
end

function Arena:onPVPArenaSearchResultS2C(action,msgId,msg)
  --[[
  enum traits{value = 5130;}
  enum ErrorCode{
    NO_ERROR_CODE = 1;  //
    NOT_OPEN_TIME = 2;  //时间没到
    LEVEL_LIMIT   = 3;  //等级不够
    LIMIT_SEARCH  = 5;  //搜索次数没了
    NOT_IN_SEARCH = 6;  //不在搜索
    WAIT_RESULT   = 7;  //等待战斗结算结果
    SYSTEM_ERROR  = 4;  //其他错误
  }
  required ErrorCode error = 1;     
  optional PVPArenaTarget target = 2;  //对手数据
  optional PVPArenaData self = 3;    //自己数据
  optional bool cancel = 4;
  ]]
  
  print("Arena:onPVPArenaSearchResultS2C:",msg.error)
  dump(msg)
  _hideLoading()
  self:setIsSearching(false)
  
  if msg.error == "NO_ERROR_CODE" then
     if msg.cancel == false then
       if msg.self ~= nil and msg.target ~= nil then
         assert(msg.self.base.player ~= msg.target.base.player)
       end
    
       if msg.self ~= nil then
         self:updateSelfPVPArenaData(msg.self)
       end
          
       if self:getDelegate() ~= nil then
          --dump(msg.target)
          self:getDelegate():enterArenaBattle(msg)
       end
    else
       printf("search has been cancled")
       if self:getArenaView() ~= nil then
         self:getArenaView():cancleSearch()
       end
    end
  else
    if self:getArenaView() ~= nil then
      self:getArenaView():cancleSearch()
    end
    
    if msg.error == "WAIT_RESULT" then
    else
      --ServerError.GetOrShowDescrible(msg.error,true, ServerError.Type.ARENA)
    end
    
  end
end

function Arena:updateSelfPVPArenaData(msgPVPArenaData)
  local selfPlayer = self:getSelfPlayer()
  if selfPlayer == nil then
     selfPlayer = ArenaPlayer.new()
     self:setSelfPlayer(selfPlayer)
  end
  selfPlayer:update(msgPVPArenaData.base)
  print("msgPVPArenaData.base.player:",msgPVPArenaData.base.player)
  
  --rank list
  self:setRankList(nil)
  local rankList = {}
  for key, rankMsg in pairs(msgPVPArenaData.rankList) do
     local rankPlayer = ArenaPlayer.new(rankMsg)
     table.insert(rankList,rankPlayer)
  end
  self:setRankList(rankList)
  
  --self rank number
  self:setSelfRankNum(msgPVPArenaData.rankNo)
  
  if self:getArenaView() ~= nil then
     self:getArenaView():updateView(self)
  end
  CCNotificationCenter:sharedNotificationCenter():postNotification(ArenaConfig.UPDATE_EVENT)
end

function Arena:reqPVPArenaChangeCardC2S(cards)
  --[[
  message PVPArenaChangeCardC2S{
  enum traits{value = 5131;}
  required FightCards cards = 1;
  }
  ]]
  local data = PbRegist.pack(PbMsgId.PVPArenaChangeCardC2S,{cards = {card_pos = cards}})
  net.sendMessage(PbMsgId.PVPArenaChangeCardC2S,data)
end

function Arena:onPVPArenaChangeCardResultS2C(action,msgId,msg)
  --[[
  enum traits{value = 5132;}
  enum ErrorCode{
    NO_ERROR_CODE = 1;  //
    NOT_OPEN_TIME = 2;  //时间没到
    LEVEL_LIMIT   = 3;  //等级不够
    CARD_NOT_FOUND = 5; //卡牌没找到
    CARD_DATA_ERROR = 6;//卡牌数据错误
    SYSTEM_ERROR  = 4;  //其他错误
  }
  required ErrorCode error = 1; //
  ]]
  
  print("Arena:onPVPArenaChangeCardResultS2C:",msg.error)
  
end

function Arena:onPVPArenaTargetChangeCardS2C(action,msgId,msg)
  --[[
  enum traits{value = 5133;}      
  optional PVPArenaTarget target = 1;  //对手数据
  ]]
  print("Arena:onPVPArenaTargetChangeCardS2C")
  dump(msg.target)
  
  print(msg.target.base.player)
  assert(msg.target.base.player ~= self:getSelfPlayer():getId())
  
  if ControllerFactory:Instance():getCurrentControllerType() ==  ControllerType.BATTLE_CONTROLLER then
     local battleController = ControllerFactory:Instance():getCurController()
     if battleController ~= nil then
        local battle = battleController:getBattle()
        battle:updateArenaTargetPlayer(msg.target)
     end
  end
  
end

function Arena:reqPVPArenaFightReqC2S(cards)
  --[[
  message PVPArenaFightReqC2S{
  enum traits{value = 5134;}
  required FightCards cards = 1;
  }
  ]]
  
  print("reqPVPArenaFightReqC2S")
  dump(cards)
  --_showLoading()
  local data = PbRegist.pack(PbMsgId.PVPArenaFightReqC2S,{cards = {card_pos = cards}})
  net.sendMessage(PbMsgId.PVPArenaFightReqC2S,data)
end

function Arena:onPVPArenaFightResultS2C(action,msgId,msg)
  --[[
  enum ArenaType{
    FIGHT_NORMAL = 1;   //正常战斗
    FIGHT_DISCONNECT = 2; //有玩家掉线
  }
  //type = FIGHT_DISCONNECT 时候 
  //result 里面战斗动画播放数据时空的 只需要读结算数据
  required ArenaType  type = 1;   //结算类型  
  optional FightResult result = 2;  //结算数据
  optional PVPArenaData self = 3;   //自己数据更新
  optional PVPArenaAward award = 4; //战报相关数据
  ]]
  print("Arena:onPVPArenaFightResultS2C:",msg.type)
  dump(msg)
  _hideLoading()
  if msg.type == "FIGHT_NORMAL" then
    if ControllerFactory:Instance():getCurrentControllerType() ==  ControllerType.BATTLE_CONTROLLER then
       local battleController = ControllerFactory:Instance():getCurController()
       if battleController ~= nil then
    			local battleView = battleController:getBattleView()
    			assert(battleView)
    			local battle = battleController:getBattle()
          battle:onBattleResult(msg.result.result,msg)
    			local arenaView = battleView:getArenaView()
    			if arenaView ~= nil then
    				arenaView:playLeaveHandler()
    			end
       end
    end
  elseif msg.type == "FIGHT_DISCONNECT" then
	
	  local battleController =nil
    if ControllerFactory:Instance():getCurrentControllerType() ~=  ControllerType.BATTLE_CONTROLLER then
  		battleController = ControllerFactory:Instance():create(ControllerType.BATTLE_CONTROLLER)
  		battleController:enter()
  	else
  		battleController = ControllerFactory:Instance():getCurController()
  	end
	--if battleController ~= nil then
		local battleView = battleController:getBattleView()
		--assert(battleView)
		local battle = battleController:getBattle()
		--assert(battle)
		local arenaView = battleView:getArenaView()
		--assert(arenaView)
		if(arenaView) then
			arenaView:setVisible(false)
		end
		--battle:onBattleResult(msg.result.result,msg)

		battleView:prepareBattleResultView(msg.result.result,msg,"PVP_REAL_TIME")
     
		local result_str = msg.result.result_lv
		if result_str == "WIN_LEVEL_1" or result_str == "WIN_LEVEL_2" or result_str == "WIN_LEVEL_3" then
			if msg.result.client_sync ~= nil then
				GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.result.client_sync)
			end
		end

		battleView:showResult(true)
	--end

  else
  end
  
end

function Arena:onPVPArenaStateS2C(action,msgId,msg)
  --[[
  enum traits{value = 5137;}
  enum ArenaState{
    ARENA_OPEN = 1;
    ARENA_CLOSE = 2;
  }
  required ArenaState state = 1;
  ]]
  
  print("Arena:onPVPArenaStateS2C:",msg.state)
  
  self:setSeverState(msg.state)
  
  if msg.state == "ARENA_CLOSE" then
    -- when player has not started fight at battle view ,force back to arena view.
    if ControllerFactory:Instance():getCurrentControllerType() ==  ControllerType.BATTLE_CONTROLLER then
       local battleController = ControllerFactory:Instance():getCurController()
       if battleController ~= nil then
          local battleView = battleController:getBattleView()
          if not battleView:IsStartBattle() then
            local controller = ControllerFactory:Instance():create(ControllerType.HOME_CONTROLLER) --ARENA_CONTROLLER
            controller:enter()
          end
       end
    end
  end
  
  if self:getArenaView() ~= nil then
     self:getArenaView():updateView(self)
  end
  CCNotificationCenter:sharedNotificationCenter():postNotification(ArenaConfig.UPDATE_EVENT)
  
end

------
--  Getter & Setter for
--      Arena._SeverState 
-----
function Arena:setSeverState(SeverState)
	self._SeverState = SeverState
end

function Arena:getSeverState()
	return self._SeverState
end

------
--  Getter & Setter for
--      Arena._ArenaServerStateIsOpen 
-----
function Arena:setArenaServerStateIsOpen(ArenaServerStateIsOpen)
	self._ArenaServerStateIsOpen = ArenaServerStateIsOpen
end

function Arena:getArenaServerStateIsOpen()
	return self._ArenaServerStateIsOpen
end

function Arena:setValidDayTime(openMin, closeMin)
  self.openTime = openMin * 60
  self.closeTime = closeMin * 60
end

------
--  Getter & Setter for
--      Arena._OpenDate 
-----
function Arena:setOpenDate(OpenDate)
  self._OpenDate = OpenDate
end

function Arena:getOpenDate()
  return self._OpenDate
end

------
--  Getter & Setter for
--      Arena._CloseDate 
-----
function Arena:setCloseDate(CloseDate)
  self._CloseDate = CloseDate
end

function Arena:getCloseDate()
  return self._CloseDate
end

------
--  Getter & Setter for
--      Arena._ValidWeekDay 
-----
function Arena:setValidWeekDay(ValidWeekDay)
  self._ValidWeekDay = ValidWeekDay
  if self._ValidWeekDay[1] < 0 then
    self._ValidWeekDay = {1,2,3,4,5,6,0}
  end
  
end

function Arena:getValidWeekDay()
  return self._ValidWeekDay
end

function Arena:CanOpenCheck()
  return GameData:Instance():checkSystemOpenCondition(22, false)
end


-- return param :   first: left time, second:state 
--state:1 unopen 2 open 3 closed
function Arena:getLeftTime()
  local leftTime = 0
  -- 1 unopen 2 open 3 closed
  local state = 1
  local timeTable = Clock:Instance():getCurServerTimeAsTable()
  local curDate = timeTable.year * 10000 + timeTable.month * 100 + timeTable.day
  
  print("Arena:curDate:",curDate)
  
  local currentSecond = timeTable.hour * 3600 + timeTable.min*60 + timeTable.sec
  
  print("Arena:_OpenDate:",self._OpenDate,"Arena:_CloseDate:",self._CloseDate)
  
  if self._CloseDate < 0 or (curDate >= self._OpenDate and curDate <= self._CloseDate) then
    
    print("Arena:IsOpenDay:true")
    
    if currentSecond < self.openTime then        --"未开启"
      leftTime = self.openTime - currentSecond
      print("Arena:未开启:",leftTime)
      state = 1
    elseif currentSecond < self.closeTime then   --"开启中"
      leftTime = self.closeTime - currentSecond
      print("Arena:开启中:",leftTime)
      state = 2
    else                                  
      leftTime = -(currentSecond-self.openTime)  --"已关闭"
      print("Arena:已关闭")
      state = 3
    end

    print("Arena:day offset:",self:getRecentValidDayOffset())
    if self:getRecentValidDayOffset() >= 1 then
       leftTime = self.openTime - currentSecond%(24*3600)
       --print("Arena:day offset time:",leftTime)
    end
    
    if state == 2 then
      if self:getRecentValidDayOffset() >= 1 then
        state = 1
      end
    end 
    
 
    
    local timeOffset = 24*3600*self:getRecentValidDayOffset()
    
    print("Arena:timeOffset:",timeOffset)
    
    leftTime = leftTime + timeOffset
  end
  
  print("Arena:leftTime:",leftTime,"state:",state)
  return leftTime,state
end

function Arena:getRecentValidDayOffset()
  local found = false
  local dayOffset = 0

  --get current weekday and judge today's time region info
  local isBehindClosedTime = false
  
  --local currentTime = Clock:Instance():getCurServerTime()
  
  local timeTable = Clock:Instance():getCurServerTimeAsTable()
  local currentSecond = timeTable.hour * 3600 + timeTable.min * 60 + timeTable.sec

  local currentWeekDay = timeTable.wday - 1
  if currentSecond > self.closeTime then
    isBehindClosedTime = true
  end
  
  table.sort(self._ValidWeekDay,sortTables)
  
  --calculate day offset
  --print("#self._ValidWeekDay",#self._ValidWeekDay)
  for i = 1, #self._ValidWeekDay do 
    echo("self._ValidWeekDay["..i.."]:",self._ValidWeekDay[i],i)
    echo("currentWeekDay:",currentWeekDay)
    if self._ValidWeekDay[i] >= currentWeekDay then 
      dayOffset = self._ValidWeekDay[i] - currentWeekDay
      print("Arena:@dayOffset:",dayOffset)
      if dayOffset == 0 and isBehindClosedTime == true then --当天但已超过有效时间段
      else
        found = true
        break
      end
    end
  end
  if found == false then
    dayOffset = 6 - currentWeekDay + self._ValidWeekDay[1] + 1
  end
  return dayOffset
end 

return Arena