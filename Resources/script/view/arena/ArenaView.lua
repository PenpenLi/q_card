require("model.arena.Arena")
require("view.arena.ArenaAwardListItem")
ArenaView = class("ArenaView",BaseView)
local unitTag = 125
function ArenaView:ctor()
  self:setNodeEventEnabled(true)
end
function ArenaView:enterBackground()
  self:stopAllActions()
  Arena:Instance():setIsSearching(false)
	net.sendAction(NetAction.REQ_DISCONNECT)
end
function ArenaView:enterForeground()
	self:cancleSearch()
end
function ArenaView:onEnter()
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("label_current_rank","CCLabelTTF")
  pkg:addProperty("label_battle_score","CCLabelTTF")
  pkg:addProperty("label_battle_rank","CCLabelTTF")
  pkg:addProperty("label_battle_keepwin","CCLabelTTF")
  pkg:addProperty("label_remain_time","CCLabelTTF")
  pkg:addProperty("label_remain_times","CCLabelTTF")
  pkg:addProperty("label_pre_remain_time","CCLabelTTF")
  pkg:addProperty("label_searching","CCLabelTTF")
  pkg:addProperty("btn_search","CCControlButton")
  pkg:addProperty("btn_cancel","CCControlButton")
  pkg:addProperty("nodeAwardList","CCNode")
  pkg:addProperty("nodeCancle","CCNode")
  pkg:addProperty("layer_block","CCLayer")
  pkg:addProperty("btnBuyCount","CCControlButton")
  
  pkg:addFunc("searchTargetHandler",ArenaView.searchTargetHandler)
  pkg:addFunc("cancleSearchHandler",ArenaView.cancleSearchHandler)
  pkg:addFunc("onBackHandler",ArenaView.onBackHandler)
  pkg:addFunc("buyCountHandler",ArenaView.buyCountHandler)
  pkg:addFunc("helpHandler",ArenaView.helpHandler)
  
  
  CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self, handler(self,ArenaView.enterForeground),"APP_WILL_ENTER_FOREGROUND") 
  CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self, handler(self,ArenaView.enterBackground),"APP_ENTER_BACKGROUND") 

  for i = 1,10 do
     pkg:addProperty("name_"..i,"CCLabelTTF")
     pkg:addProperty("num_"..i,"CCLabelTTF")
  end
  
  local layer,owner = ccbHelper.load("Contest_top.ccbi","ContestCCB","CCLayer",pkg)
  self:addChild(layer)
  
  --clear str
  for i = 1,10 do
     self["name_"..i]:setString("")
     self["num_"..i]:setString("")
  end
  
  self.nodeCancle:setVisible(false)
  
  if AllConfig.arena_top ~= nil then
     self:buildAwardList()
  end
  
  self._timeCount = 0
  
  MessageBox.Help.LayerClick(self.layer_block,nil,function() return true end,nil,-130,false)
  
  self.label_pre_remain_time:setString(_tr("activity_time_remain")..":")
  self.label_remain_time:setString(Clock.format(Arena:Instance():getLeftTime(),Clock.Type.NODAY))
  self.label_remain_times:setString("")

--  if Arena:Instance():getSeverState() ~= "ARENA_OPEN" then
--  	Toast:showString(self, string._tran(Consts.Strings.ARENAVIEW_FINISH), ccp(display.width/2, display.height*0.4))
--  	local controller = ControllerFactory:Instance():create(ControllerType.ARENA_CONTROLLER)
--  	controller:enter()
--  end

end

function ArenaView:helpHandler()
  local help = HelpView.new()
  help:addHelpBox(1048,nil,true)
  GameData:Instance():getCurrentScene():addChildView(help,1000)
end

function ArenaView:buyCountHandler()
  
  local rank = Arena:Instance():getSelfPlayer():getRank()
  local cost = AllConfig.arena_rank[rank].search_add_cost
  
  local pop = PopupView:createTextPopup(_tr("spend_%{count}_for_challenge?", {count = cost}),function()
    if GameData:Instance():getCurrentPlayer():getMoney() < cost then
      local pop = PopupView:createTextPopup(_tr("money_limit_ask"),function()
        local shopController = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
        shopController:enter(ShopCurViewType.PAY)
      end)
      GameData:Instance():getCurrentScene():addChildView(pop)
      return
    end
    
    Arena:Instance():reqPVPArenaBuyChanceC2S(cost)
  end)
  GameData:Instance():getCurrentScene():addChildView(pop)
end

function ArenaView:onBackHandler()
  local controller = ControllerFactory:Instance():create(ControllerType.HOME_CONTROLLER)
  controller:enter()
end

function ArenaView:buildAwardList()
  local function scrollViewDidScroll(view)
    --print("scrollViewDidScroll")
  end
  
  local function scrollViewDidZoom(view)
      print("scrollViewDidZoom")
  end
  
  local function tableCellTouched(table,cell)
      print("cell touched at index: " .. cell:getIdx())
   end
  
   local function cellSizeForTable(table,idx) 
      return 105,280
   end
  
   local function tableCellAtIndex(tableView, idx)
      local cell = tableView:dequeueCell()
      if nil == cell then
        cell = CCTableViewCell:new()  
      else
        cell:removeAllChildrenWithCleanup(true)
      end
      cell:setIdx(idx)
      
      local awardItem = ArenaAwardListItem.new(idx + 1)
      cell:addChild(awardItem)
      
      return cell
  end
  
  local function numberOfCellsInTableView(val)
     local length = #AllConfig.arena_top
     return length
  end
  
  local mSize = self.nodeAwardList:getContentSize()
  local tableView = CCTableView:create(mSize)
  tableView:setDirection(kCCScrollViewDirectionVertical)
  tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  tableView:setClippingToBounds(true)
  
  --tableView:setBounceable(false)
  self.nodeAwardList:addChild(tableView)
  --registerScriptHandler functions must be before the reloadData function
  tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  tableView:registerScriptHandler(scrollViewDidZoom,CCTableView.kTableViewZoom)
  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)  
  tableView:reloadData()
  self.tableView = tableView
end


function ArenaView:onExit()
  self:cancleSearchHandler()
	CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(self, "APP_ENTER_BACKGROUND")
	CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(self, "APP_WILL_ENTER_FOREGROUND")
end

function ArenaView:updateView(arena)
  if arena == nil then
    return
  end
  local selfPlayer = arena:getSelfPlayer()
  
  if selfPlayer == nil then
    return
  end
  
  self.label_battle_score:setString(selfPlayer:getScore()>0 and selfPlayer:getScore().."" or string._tran(Consts.Strings.HIT_ARENA_NO_SCORE))
  self.label_battle_rank:setString(arena:getSelfRankNum()>0 and arena:getSelfRankNum().."" or string._tran(Consts.Strings.HIT_ARENA_NO_RANK) )
  self.label_battle_keepwin:setString(selfPlayer:getKeepWin()>0 and selfPlayer:getKeepWin().."" or string._tran(Consts.Strings.HIT_ARENA_NO_KEEP_WIN))
  --local rankNum = arena:getSelfRankNum()
    
  local rankId = selfPlayer:getRank()
  local rankInfo = AllConfig.arena_rank[rankId]
  self.label_current_rank:setString(string.format(Consts.Strings.ARENAVIEW_CURRENT_RANK,rankInfo.rank_min_lv,rankInfo.rank_max_lv))
  
  --clear str
  for i = 1,10 do
     self["name_"..i]:setString("")
     self["num_"..i]:setString("")
  end
  
  local rankIndex = 1
  local rankList = arena:getRankList()
  -- reset str
  if rankList ~= nil then
     for key, rank in pairs(rankList) do
		self["name_"..rankIndex]:setString(rank:getName().."")
		self["num_"..rankIndex]:setString(rank:getScore().."")
		rankIndex = rankIndex + 1
		if rankIndex > 10 then
			break
		end
     end
  end
  
  self:stopAllActions()
  local areanClosed = function()
    self.btn_search:setEnabled(false)
    self.btnBuyCount:setVisible(false)
    self.btnBuyCount:setEnabled(false)
    self.label_remain_time:setString(string._tran(Consts.Strings.ARENAVIEW_FINISH))
  end
  
  if arena:getSeverState() == "ARENA_OPEN" then
      if self.btn_search ~= nil then
         self.btn_search:setEnabled(true)
      end
      local leftTime = arena:getLeftTime()
      print("leftTime",leftTime)
      if leftTime > 0 then
         self.label_remain_time:setString(Clock.format(leftTime,Clock.Type.NODAY))
         self:schedule(function()
           if leftTime <= 0 then
             areanClosed()
             self:cancleSearch()
             return
           end
           leftTime = leftTime - 1
           self.label_remain_time:setString(Clock.format(leftTime,Clock.Type.NODAY))
         end,1)
      else
        areanClosed()
      end
      
  else
      if self.btn_search ~= nil then
         self.btn_search:setEnabled(false)
      end
      self:cancleSearchHandler()
      areanClosed()
  end
  
  local vipLevelId = GameData:Instance():getCurrentPlayer():getVipLevelId()
  local searchTimesRemain = rankInfo.search_max_count + AllConfig.vipinitdata[vipLevelId].Arena_activity_count_charge - selfPlayer:getSearchTime()
  self.btnBuyCount:setVisible(searchTimesRemain <= 0)
  if searchTimesRemain <= 0 then
    searchTimesRemain = 0
    if self.btn_search ~= nil then
         self.btn_search:setEnabled(false)
    end
    self:cancleSearchHandler()
  end
  
  self.label_remain_times:setString(searchTimesRemain.."")

end

function ArenaView:searchTargetHandler()
	if GameData:Instance():getCurrentPlayer():isEnabledEnterBattle() == false then
		return
	end

  self.nodeCancle:setVisible(true)
  self.btn_search:setVisible(false)
  self._timeCount = 0
  local matchingStr = _tr("searching_target_for_arena").."......"
  self.label_searching:setString(matchingStr)
  self:schedule(function()
     self._timeCount = self._timeCount + 1
     self.label_searching:setString(matchingStr..self._timeCount)
     --print("time count")
   end,1)
  
  self.btnBuyCount:setVisible(false)
  Arena:Instance():reqPVPArenaSearchC2S(false)
end

function ArenaView:cancleSearchHandler()
  if Arena:Instance():getIsSearching() == true then
    Arena:Instance():reqPVPArenaSearchC2S(true)
  end
end

function ArenaView:cancleSearch()
  self:stopAllActions()
  self.nodeCancle:setVisible(false)
  self.btn_search:setVisible(true)
  self:updateView(Arena:Instance())
end


return ArenaView