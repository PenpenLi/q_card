require("view.pvp_rank_match.PvpRankMatchPlayerDetailView")
require("view.pvp_rank_match.PvpRankMatchReportView")
require("view.pvp_rank_match.PvpRankMatchRuleView")
require("view.card_soul.PopShopListView")

PvpRankMatchView = class("PvpRankMatchView",BaseView)
function PvpRankMatchView:ctor(rankMatchReport)
  self:setNodeEventEnabled(true)
  
  local bg = display.newSprite("pvp_rank_match/pvp_rank_match_bg.png")
  self:addChild(bg)
  bg:setPosition(display.cx,display.cy)
  
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("background","CCScale9Sprite")
  
  pkg:addProperty("btnCleanCd","CCMenuItemImage")
  pkg:addProperty("btnRefresh","CCMenuItemImage")
  
  pkg:addProperty("nodeReset","CCNode")
  pkg:addProperty("nodeRefresh","CCNode")
  
    
  pkg:addProperty("labelTimesRemainTitle","CCLabelTTF")
  pkg:addProperty("labelHasCount","CCLabelTTF")
  pkg:addProperty("labelTotalCount","CCLabelTTF")
  pkg:addProperty("labelResetRemain","CCLabelTTF")
  pkg:addProperty("labelRefreshCost","CCLabelTTF")
  pkg:addProperty("labelMyRank","CCLabelBMFont")
  
  
  pkg:addProperty("nodeTargets","CCNode")
  pkg:addProperty("nodePlayer1","CCNode")
  pkg:addProperty("nodePlayer2","CCNode")
  pkg:addProperty("nodePlayer3","CCNode")
  
  pkg:addProperty("labelPlayerName1","CCLabelTTF")
  pkg:addProperty("labelRank1","CCLabelTTF")
  pkg:addProperty("labelBattle1","CCLabelTTF")
  pkg:addProperty("nodePlayerHead1","CCNode")
  
  pkg:addProperty("labelPlayerName2","CCLabelTTF")
  pkg:addProperty("labelRank2","CCLabelTTF")
  pkg:addProperty("labelBattle2","CCLabelTTF")
  pkg:addProperty("nodePlayerHead2","CCNode")
  
  pkg:addProperty("labelPlayerName3","CCLabelTTF")
  pkg:addProperty("labelRank3","CCLabelTTF")
  pkg:addProperty("labelBattle3","CCLabelTTF")
  pkg:addProperty("nodePlayerHead3","CCNode")

  pkg:addProperty("btnGoFight1","CCMenuItemImage")
  pkg:addProperty("btnGoFight2","CCMenuItemImage")
  pkg:addProperty("btnGoFight3","CCMenuItemImage")
  
  --banner
  pkg:addProperty("labelBannerName1","CCLabelTTF")
  pkg:addProperty("labelBannerName2","CCLabelTTF")
  pkg:addProperty("labelBannerName3","CCLabelTTF")
  pkg:addProperty("labelBannerFightValue1","CCLabelTTF")
  pkg:addProperty("labelBannerFightValue2","CCLabelTTF")
  pkg:addProperty("labelBannerFightValue3","CCLabelTTF")
  pkg:addProperty("bannerNode1","CCNode")
  pkg:addProperty("bannerNode2","CCNode")
  pkg:addProperty("bannerNode3","CCNode")
  
  pkg:addFunc("ruleHandler",PvpRankMatchView.ruleHandler)
  pkg:addFunc("rankListHandler",PvpRankMatchView.rankListHandler)
  pkg:addFunc("reportsHandler",PvpRankMatchView.reportsHandler)
  
  pkg:addFunc("refreshTargetHandler",PvpRankMatchView.refreshTargetHandler)
  pkg:addFunc("cleanCdHandler",PvpRankMatchView.cleanCdHandler)
  
  pkg:addFunc("closeHandler",PvpRankMatchView.closeHandler)
  
  pkg:addFunc("shopHandler",PvpRankMatchView.shopHandler)
  pkg:addFunc("battleFormationHandler",PvpRankMatchView.battleFormationHandler)
  
  

  local layer,owner = ccbHelper.load("pvp_rank_match.ccbi","pvp_rank_match","CCLayer",pkg)
  self:addChild(layer)
  
  self.labelTimesRemainTitle:setString(_tr("today_left_times"))
  self.labelResetRemain:setString("")
  self.labelTotalCount:setString("")
  self.labelMyRank:setScale(0.8)
  
  local function tapHandler(e,pSender)
    if GameData:Instance():getCurrentPlayer():isEnabledEnterBattle() == false then
      return
    end
  
    if self._targets ~= nil then
      
      local selfPlayer = PvpRankMatch:Instance():getSelfPlayer()
      local countRemain = selfPlayer:getRemainCountToday()
      
      local target = self._targets[pSender:getTag()]
      if countRemain > 0 then
        if self._leftCdTime > 0 then
          local price = AllConfig.rank_match[1].clear_cd_cost
          local pop = PopupView:createTextPopup(_tr("cost_%{price}_reset_cd",{price = price}), function()
           if GameData:Instance():getCurrentPlayer():getMoney() < price then
             GameData:Instance():notifyForPoorMoney()
             return
           end
           
           PvpRankMatch:Instance():reqPVPRankMatchClearCDC2S(target)
          end)
          
          GameData:Instance():getCurrentScene():addChildView(pop)
        else
          PvpRankMatch:Instance():reqPVPRankMatchFightCheckC2S(target)
        end
        
      else
        local price = AllConfig.rank_match[1].buy_count_cost
        local pop = PopupView:createTextPopup(_tr("ask_buy_rank_match%{price}",{price = price}), function()
          if GameData:Instance():getCurrentPlayer():getMoney() < price then
            GameData:Instance():notifyForPoorMoney()
            return
          end
   
          PvpRankMatch:Instance():reqPVPRankMatchBuyCountC2S(target)
        end)
        GameData:Instance():getCurrentScene():addChildView(pop)
      end
      
    end
  end
    
  self.btnGoFight1:registerScriptTapHandler(tapHandler)
  self.btnGoFight2:registerScriptTapHandler(tapHandler)
  self.btnGoFight3:registerScriptTapHandler(tapHandler)
  
  self._detailNode = display.newNode()
  self:addChild(self._detailNode)
  
  self._targetPlayerHeads = {}
  self:setTouchEnabled(true)
  self:addTouchEventListener(handler(self,self.onTouch))
end

function PvpRankMatchView:shopHandler()
  -- Toast:showString(GameData:Instance():getCurrentScene(),_tr("荣耀商城即将开启！"), ccp(display.cx, display.cy + 100))
  local view = PopShopListView.new(ShopCurViewType.JingJiChang)
  view:setTopBottomVisibleWhenExit(false)
  self:addChild(view) 
end

function PvpRankMatchView:battleFormationHandler()
  local controller = ControllerFactory:Instance():create(ControllerType.BATTLE_FORMATION_CONTROLLER)
  controller:enter(false,BattleFormation.BATTLE_INDEX_RANK_MATCH)
end

function PvpRankMatchView:onTouch(event,x,y)
  if event == "began" then
     
     local targetPlayerHead = UIHelper.getTouchedNode(self._targetPlayerHeads,x,y,ccp(0,0))
     if targetPlayerHead ~= nil  then
       
       local targetPlayer = self._targets[targetPlayerHead.playerIdx]
       self._detailNode:removeAllChildrenWithCleanup(true)
       local detailView = PvpRankMatchPlayerDetailView.new(targetPlayer)
       self._detailNode:addChild(detailView)
       
       local offsetX = (targetPlayerHead.playerIdx - 2) * 130
       detailView:setPosition(display.cx + offsetX,display.cy)
     end
     return true
  elseif event == "ended" then
     self._detailNode:removeAllChildrenWithCleanup(true)
  end
end

function PvpRankMatchView:ruleHandler()
  printf("ruleHandler")
  local ruleView = PvpRankMatchRuleView.new()
  self:addChild(ruleView)
end

function PvpRankMatchView:rankListHandler()
  printf("rankListHandler")
  local view = HomeRankView.new(RankEnum.Match)
  self:addChild(view)
end

function PvpRankMatchView:reportsHandler()
  printf("reportsHandler")
  local reports = PvpRankMatch:Instance():getRepotrs()
  printf("reports:"..#reports)
  local reportView = PvpRankMatchReportView.new()
  self:addChild(reportView)
  reportView:setLists(reports)
end

function PvpRankMatchView:refreshTargetHandler()
  printf("refreshTargetHandler")
  PvpRankMatch:Instance():reqPVPRankMatchSearchC2S()
end

function PvpRankMatchView:cleanCdHandler()
  printf("cleanCdHandler")
  local price = AllConfig.rank_match[1].clear_cd_cost
  local pop = PopupView:createTextPopup(_tr("cost_%{price}_reset_cd",{price = price}), function()
   if GameData:Instance():getCurrentPlayer():getMoney() < price then
     GameData:Instance():notifyForPoorMoney()
     return
   end
   
   PvpRankMatch:Instance():reqPVPRankMatchClearCDC2S()
  end)
  
  GameData:Instance():getCurrentScene():addChildView(pop)
  
end

function PvpRankMatchView:closeHandler()
  printf("closeHandler")
  GameData:Instance():gotoPreView()
end

function PvpRankMatchView:onEnter()
  net.registMsgCallback(PbMsgId.RankInformationS2C, self, PvpRankMatchView.updateBanner)
  PvpRankMatch:Instance():setView(self)
  _executeNewBird()
  self:updateView()
end

function PvpRankMatchView:onExit()
  net.unregistAllCallback(self)
  PvpRankMatch:Instance():setView(nil)
end

function PvpRankMatchView:cleanBannerView()
  self.labelBannerName1:setString("")
  self.labelBannerName2:setString("")
  self.labelBannerName3:setString("")
  self.labelBannerFightValue1:setString("")
  self.labelBannerFightValue2:setString("")
  self.labelBannerFightValue3:setString("")
  self.bannerNode1:removeAllChildrenWithCleanup(true)
  self.bannerNode2:removeAllChildrenWithCleanup(true)
  self.bannerNode3:removeAllChildrenWithCleanup(true)
end


function PvpRankMatchView:updateBanner()
  local ranks = GameData:Instance():getPlayersRank(RankEnum.Match)
  self:cleanBannerView()
  
  for key, rankInfo in pairs(ranks) do
  	print("rank:",key)
  	-- dump(rankInfo)
  	self["labelBannerName"..key]:setString(rankInfo.name)
  	if rankInfo.fight_value ~= nil then
  	 self["labelBannerFightValue"..key]:setString(_tr("fight_number_%{num}",{num = rankInfo.fight_value}))
  	end
  	local cardConfigId = 12050201
    if rankInfo.avatar > 1 then 
      cardConfigId = toint(rankInfo.avatar.."01")
    end
    if AllConfig.unit[cardConfigId] ~= nil then 
      local resId = AllConfig.unit[cardConfigId].unit_head_pic
      local icon = _res(resId)
      if icon ~= nil then 
        icon:setScale(70/icon:getContentSize().width)
        self["bannerNode"..key]:addChild(icon)
      end 
    end 
    
  	if key >= 3 then
  	 break
  	end
  end
  
end

function PvpRankMatchView:cleanMyInfoView()
  self.labelMyRank:setString("")
  self.nodePlayer1:setVisible(false)
  self.nodePlayer2:setVisible(false)
  self.nodePlayer3:setVisible(false)
  self.nodeRefresh:setVisible(false)
  self.nodeReset:setVisible(false)
  for i = 1, 3 do
    self["nodePlayer"..i]:setVisible(true)
    self["nodePlayerHead"..i]:removeAllChildrenWithCleanup(true)
    self["labelPlayerName"..i]:setString("")
    self["labelRank"..i]:setString("")
    self["labelBattle"..i]:setString("")
  end
  self.labelRefreshCost:setString("")
  self.labelResetRemain:setString("")
  self.labelHasCount:setString("")
  self.labelResetRemain:setString("")
end


function PvpRankMatchView:updateView()
  self:updateBanner()
  self:cleanMyInfoView()
  
  local selfPlayer = PvpRankMatch:Instance():getSelfPlayer()
  local targets = PvpRankMatch:Instance():getTargetPlayers()
  self._targets = targets
  self._targetPlayerHeads = {}
  self:stopAllActions()
  if selfPlayer ~= nil and targets ~= nil then
    self.labelMyRank:setString(selfPlayer:getRank().."")
    
    self.nodePlayer1:setVisible(false)
    self.nodePlayer2:setVisible(false)
    self.nodePlayer3:setVisible(false)
    for i = 1, #targets do
      local targetPlayer = targets[i]
      self["nodePlayer"..i]:setVisible(true)
      self["nodePlayerHead"..i]:removeAllChildrenWithCleanup(true)
      local headRes = _res(targetPlayer:getHead())
      headRes:setScale(0.68)
      self["nodePlayerHead"..i]:addChild(headRes)
      self["labelPlayerName"..i]:setString("Lv."..targetPlayer:getLevel().." "..targetPlayer:getName())
      self["labelRank"..i]:setString(_tr("rank_number%{num}",{num = targetPlayer:getRank()}))
      self["labelBattle"..i]:setString(_tr("fight_number_%{num}",{num = targetPlayer:getFightNumber()}))
      headRes.playerIdx = i
      table.insert(self._targetPlayerHeads,headRes)
    end
    
    local price = AllConfig.rank_match[1].clear_cd_cost
    self.labelRefreshCost:setString(price.."")
    
    self.labelResetRemain:setString("")
    
    local countRemain = selfPlayer:getMaxCountToday() - selfPlayer:getUsedCountToday()
    if countRemain <= 0 then
      self.labelHasCount:setColor(sgRED)
      countRemain = 0
      self.btnRefresh:setEnabled(false)
      self.btnCleanCd:setEnabled(false)
    else
      self.labelHasCount:setColor(sgGREEN)
      self.btnRefresh:setEnabled(true)
      self.btnCleanCd:setEnabled(true)
    end
    
    --assert(selfPlayer:getMaxCountToday() > 0)
    
    self.labelHasCount:setString(countRemain.."")
    --self.labelTotalCount:setString(selfPlayer:getMaxCountToday().."")
    
    local curTime = Clock:Instance():getCurServerUtcTime()
    local targetTime = selfPlayer:getLastFightTime() + AllConfig.rank_match[1].fight_cd
    if selfPlayer:getLastFightTime() <= 0 then
      self._leftCdTime = 0
    else
        self._leftCdTime = targetTime - curTime
    end
    
    if self._leftCdTime > 0 then
      self:startTimeCountDown()
      self.nodeRefresh:setVisible(false)
      self.nodeReset:setVisible(true)
    else
      self.nodeRefresh:setVisible(true)
      self.nodeReset:setVisible(false)
    end
    
    printf("selfPlayer:getLastFightTime():"..selfPlayer:getLastFightTime())
    printf("fight_cd:"..AllConfig.rank_match[1].fight_cd)
    printf("self._leftCdTime:"..self._leftCdTime)
  end
end

function PvpRankMatchView:startTimeCountDown()
  local updateTimeShow = function()
      if self._enabledCountDown == false then
        return 
      end
      self._leftCdTime = self._leftCdTime - 1
     
      if self._leftCdTime <= 0 then
         self:updateView()
         self.labelResetRemain:setString("")
      else 
          if self._leftCdTime > 86400 then --24*3600
            local timeStr = _tr("day %{count}", {count = math.ceil(self._leftCdTime/86400)})
            self.labelResetRemain:setString(_tr("after_%{time}_time_reset_cd",{time = timeStr}))
          else
            local hour = math.floor(self._leftCdTime/3600)
            local min = math.floor((self._leftCdTime%3600)/60)
            local sec = math.floor(self._leftCdTime%60)
            local timeStr = string.format("%02d:%02d:%02d", hour,min,sec)
            self.labelResetRemain:setString(_tr("after_%{time}_time_reset_cd",{time = timeStr}))
          end
      end
  end
  self:schedule(updateTimeShow,1/1)
end

return PvpRankMatchView