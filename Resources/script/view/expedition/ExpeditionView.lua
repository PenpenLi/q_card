require("view.expedition.component.BattleReportList")
require("view.expedition.component.EnemyList")
require("view.expedition.component.WinningStreakView")
require("view.expedition.component.Billboard")
require("view.expedition.component.ExpeditionRankListPopView")
require("view.expedition.component.ExpeditionDailyAwardView")
require("view.component.MiddleCardHeadView")


ExpeditionView = class("ExpeditionView",ViewWithEave)

function ExpeditionView:ctor(controller,expedition)
  ExpeditionView.super.ctor(self)
  
  self:setDelegate(controller) 
  self.expedition = expedition
  
  self._isSearching = false
  
	local pkg = ccbRegisterPkg.new(self)
	
	pkg:addProperty("node_award_list_1","CCNode")
	pkg:addProperty("node_award_list_2","CCNode")
	pkg:addProperty("nodeCardContainer","CCNode")
	pkg:addProperty("nodeInfoContainer","CCNode")
	pkg:addProperty("nodeBattleContainer","CCNode")
	pkg:addProperty("nodeBoaderContainer","CCNode")
	pkg:addProperty("nodeAwardContainer","CCNode")
	pkg:addProperty("nodeRankIconContainer","CCNode")
	pkg:addProperty("animationContainer","CCNode")
	pkg:addProperty("nodeTokenCost","CCNode")
	pkg:addProperty("currentTableViewContainer","CCNode")
	pkg:addProperty("nextTableViewContainer","CCNode")
	pkg:addProperty("lebelPlayerName","CCLabelTTF")
	pkg:addProperty("labelLevel","CCLabelTTF") --,{outlineColor = ccc3(0,0,0),pixel = 2}
	pkg:addProperty("lebelTotal","CCLabelTTF")
	pkg:addProperty("lableKeepWinCount","CCLabelTTF")
	pkg:addProperty("labelLeftTime","CCLabelTTF")
	pkg:addProperty("currentAwardPreLabel","CCLabelTTF")
	pkg:addProperty("nextAwardPreLabel","CCLabelTTF")
	pkg:addProperty("lebelStopKeepWinAward","CCLabelTTF")
	pkg:addProperty("labelTokenCost","CCLabelTTF")
	pkg:addProperty("labelFightTokenCost","CCLabelTTF")
	pkg:addProperty("labelBufferPreCost","CCLabelTTF")

	pkg:addProperty("label_TelentPoint","CCLabelTTF")
	pkg:addProperty("dropTipLabel","CCLabelTTF")
	
	pkg:addProperty("labelCurrentRank","CCLabelBMFont")
	--pkg:addProperty("labelCurrentRank2","CCLabelTTF")
	pkg:addProperty("labelCurrentRankArea","CCLabelTTF")
	--pkg:addProperty("labelCurrentRankArea2","CCLabelTTF")
	pkg:addProperty("labelBattlePlus","CCLabelTTF")
	pkg:addProperty("labelAttackWin","CCLabelTTF") --,{outlineColor = ccc3(0,0,0),pixel = 2}
	pkg:addProperty("labelFsWin","CCLabelTTF")
	pkg:addProperty("labelScore","CCLabelTTF")
	pkg:addProperty("labelAttackWin","CCLabelTTF")
	pkg:addProperty("labelMostHit","CCLabelTTF")
	pkg:addProperty("labelNextRank","CCLabelBMFont")
	pkg:addProperty("labelCurrentRankName","CCLabelBMFont")
	pkg:addProperty("labelNextRankArea","CCLabelTTF")
	
	--pres
	pkg:addProperty("labelPreCost","CCLabelTTF")
	pkg:addProperty("labelFightPreCost","CCLabelTTF")
	pkg:addProperty("labelPreMaxWin","CCLabelTTF")
	pkg:addProperty("labelCurrentBattleScore","CCLabelTTF")
	pkg:addProperty("labelBattleDifWin","CCLabelTTF")
	pkg:addProperty("labelPreBattlePlus","CCLabelTTF")
	pkg:addProperty("currentAwardPreLabel","CCLabelTTF")
	pkg:addProperty("nextAwardPreLabel","CCLabelTTF")
	pkg:addProperty("labelBattleAtkWin","CCLabelTTF")
	
	pkg:addProperty("labelDailyBattleScore","CCLabelTTF")
	pkg:addProperty("labelDailyScore","CCLabelTTF")
	
	pkg:addProperty("btnSearch","CCMenuItemImage")
	pkg:addProperty("btnSearchStart","CCMenuItemImage")
	pkg:addProperty("btnStartBattle","CCMenuItemImage")
	pkg:addProperty("btnStartBattleBuffer","CCMenuItemImage")
	
	pkg:addProperty("btnGetAward","CCMenuItemImage")
	pkg:addProperty("btn_home_rank_list","CCMenuItemImage")
	pkg:addProperty("btnAddBuffer","CCMenuItemImage")
	pkg:addProperty("pvpBg","CCSprite")
	pkg:addProperty("searchBackground","CCSprite")
	
	pkg:addProperty("nodeSearchCost","CCNode")
	pkg:addProperty("nodeFightCost","CCNode")
	pkg:addProperty("nodeBufferCost","CCNode")
	
	pkg:addFunc("onStartPvpHandler",ExpeditionView.onStartPvpHandler)
	pkg:addFunc("onSearchPvpTargetHandler",ExpeditionView.onSearchPvpTargetHandler)
	pkg:addFunc("getAwardHandler",ExpeditionView.getAwardHandler)
	pkg:addFunc("onClickHomeRankList",ExpeditionView.onClickHomeRankList)
	pkg:addFunc("battleformationHandler",ExpeditionView.battleformationHandler)
	pkg:addFunc("onAddBufferHandler",function()
	   
	  
	  -- Common.CommonFastBuy(ShopItem.ExpeditionBuffer)
	  
	  
	  local item = GameData:Instance():getCurrentPackage():getPropsByConfigId(ShopItem.ExpeditionBuffer)
	  local count = 0
    if item ~= nil then
      count = item:getCount()
    end
    
    if count > 0 then
    
      local function useItemHandler()
        _showLoading()
        local data = PbRegist.pack(PbMsgId.UseItemC2S, {item = item:getId(), count = 1})
        net.sendMessage(PbMsgId.UseItemC2S, data) 
      end
      
      useItemHandler()
      
--      local pop = PopupView:createTextPopup(_tr("ask_use_item%{name}",{name = item:getName()}), useItemHandler)
--      GameData:Instance():getCurrentScene():addChildView(pop)
      
    else
      Common.CommonFastBuy(ShopItem.ExpeditionBuffer)
    end
	end)
	
	pkg:addFunc("onClickDailyAwardDetailHandler",function()
	   local popAward = ExpeditionDailyAwardView.new()
	   popAward:setScale(0.5)
     popAward:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6))
	   self:addChild(popAward)
	end)
	
	
	
  local layer,owner = ccbHelper.load("ExpeditionView.ccbi","ExpeditionViewCCB","CCLayer",pkg)
  self:getEaveView():getNodeContainer():addChild(layer)
  self._ccbView = layer
  
  _registNewBirdComponent(110001,self.btnSearch)
  _executeNewBird()
  
  self.labelBufferPreCost:setString(_tr("pre_cost_desc"))
  self.labelPreCost:setString(_tr("pre_cost_desc"))
  self.labelFightPreCost:setString(_tr("pre_cost_desc"))
  self.labelPreMaxWin:setString(_tr("battle_max_win"))
  self.labelCurrentBattleScore:setString(_tr("battle_cur_score"))
  self.labelBattleDifWin:setString(_tr("battle_dif_win"))
  self.labelPreBattlePlus:setString(_tr("battle_score_plus"))
  self.currentAwardPreLabel:setString(_tr("battle_next_award"))
  self.nextAwardPreLabel:setString(_tr("battle_next_award"))
  self.labelBattleAtkWin:setString(_tr("battle_atk_win"))
  self.dropTipLabel:setString("")
--  local dropTipStr = display.newSprite("#expedition_drop_str.png")
--  self.dropTipLabel:addChild(dropTipStr)
--  dropTipStr:setPositionY(-20)
  
  --init label show
--  self.labelCurrentRank2:setString("")
--  self.labelCurrentRankArea2:setString("")
  self.labelNextRank:setString("")
  self.labelNextRankArea:setString("")
  self.labelCurrentRank:setString("")
  self.labelCurrentRankArea:setString("")
  
  self.labelBattlePlus:setString("0")
  self.labelAttackWin:setString("0")
  self.labelFsWin:setString("0")
  self.labelScore:setString("0")
  
  self.labelTokenCost:setString("x"..AllConfig.battleinitdata[1].search_cost)
  self.labelFightTokenCost:setString("x"..AllConfig.battleinitdata[1].battle_cost)
  
  
  local menuArray = {
      {"#battle-button-nor-zhengzhan.png","#battle-button-sel-zhengzhan.png"},
      {"#battle-button-nor-zhanbao.png","#battle-button-sel-zhanbao.png"},
      {"#battle-button-nor-chouren.png","#battle-button-sel-chouren.png"},
      {"#battle-button-nor-xinxi.png","#battle-button-sel-xinxi.png"}--[[,
      {"#button-nor-fengyunbang.png","#button-sel-fengyunbang.png"},
      {"#button-nor-lianshengbang.png","#button-sel-lianshengbang.png"}--]]
  }
  self:setMenuArray(menuArray)

  self._currentPage = nil
  
  self.nodeListContainer = self:getListContainer()
  self.nodeBattleContainer:setVisible(true)
  self.nodeInfoContainer:setVisible(false)
  
  self:setTitleTextureName("#battle-image-paibian.png")
  
  local autoHideNode = display.newNode()
  self:addChild(autoHideNode)
  self._autoHideNode = autoHideNode
  
  local yPos = display.height - (GameData:Instance():getCurrentScene():getTopContentSize().height + 190)
  
  self.btn_home_rank_list:getParent():setPosition(50,yPos - 10)
  
  local protectCon = display.newNode()
  autoHideNode:addChild(protectCon)
  protectCon:setVisible(false)
  self._protectCon = protectCon
  
  local protectBg = display.newSprite("#expedition_mianzhan.png")
  protectCon:addChild(protectBg)
  protectCon:setPosition(ccp(display.width - protectBg:getContentSize().width/2,yPos - 80))
  
  self._labelProtectTime = ui.newTTFLabelWithOutline( 
      {
        text = "",size = 22,color = ccc3(0, 221, 0),
         align = ui.TEXT_ALIGN_LEFT,outlineColor =ccc3(0,0,0),pixel = 2
      })
  
  --self._labelProtectTime:setPosition(ccp(display.width - protectBg:getContentSize().width/2 - 25,yPos))
  self._labelProtectTime:setPosition(ccp(- 25,0))
  protectCon:addChild(self._labelProtectTime)
  
  self._protectLeftTime = 0
  local currentTime = Clock:Instance():getCurServerUtcTime()
  if self.expedition:getSelfPvpBaseData() ~= nil and self.expedition:getSelfPvpBaseData():getProtectTime() > currentTime then
     self._protectLeftTime = self.expedition:getSelfPvpBaseData():getProtectTime() - currentTime
  end
  
  
  self._sesonLeftTime = 0
  if self.expedition:getSeasonChangeTime() > currentTime then
     self._sesonLeftTime = self.expedition:getSeasonChangeTime() - currentTime
  end
  
  local tipNorDropIcon = display.newSprite("#expedition_drop_str.png")
  local tipSelDropIcon = display.newSprite("#expedition_drop_str.png")
  local tipDisDropIcon = display.newSprite("#expedition_drop_str.png")
  
  local btnShowCardDetail = UIHelper.ccMenuWithSprite(tipNorDropIcon,tipSelDropIcon,tipDisDropIcon,function()
    if self._cardHead ~= nil then
      self._cardHead:onClickHeadCallBack()
    end
  end)
  
  
  autoHideNode:addChild(btnShowCardDetail)
  self._tipDropIcon = btnShowCardDetail
  self._tipDropIcon:setPosition(ccp(display.width - tipNorDropIcon:getContentSize().width/2,yPos - 10))
  
  local cardHead = CardHeadView.new()
  autoHideNode:addChild(cardHead)
  cardHead:setCardByConfigId(12050801)
  cardHead:setLvVisible(false)
  cardHead:enableClick(true)
  --cardHead:setPosition(10,32)
  cardHead:setPosition(ccp(display.width - tipNorDropIcon:getContentSize().width/2 - 115,yPos - 10))
  cardHead:setScale(0.7)
  self._cardHead = cardHead
  
  local sesonRemainCon = display.newNode()
  autoHideNode:addChild(sesonRemainCon)
  sesonRemainCon:setVisible(false)
  self._sesonRemainCon = sesonRemainCon
  self._sesonRemainCon:setPosition(ccp(display.cx + 225,yPos))
  
  local remain_bg = display.newSprite("#expedition_time_remain_bg.png")
  sesonRemainCon:addChild(remain_bg)
  remain_bg:setPositionY(-18)
  
  local remain_title = display.newSprite("#expedition_seasion_remain.png")
  sesonRemainCon:addChild(remain_title)
  
  self._labelSeasionRemain = ui.newTTFLabelWithOutline( 
  {
    text = "",size = 22,color = ccc3(0, 221, 0),
     align = ui.TEXT_ALIGN_CENTER,outlineColor =ccc3(0,0,0),pixel = 2
  })
  sesonRemainCon:addChild(self._labelSeasionRemain)
  self._labelSeasionRemain:setPosition(ccp(0,-28))
  
  sesonRemainCon:setVisible(false)
  
  self:tabControlOnClick(0)
  
  GameData:Instance():getCurrentScene():getBottomBlock():updateBottomTip(2)
  
  local refreshedSeson = false
  
  local preStr = _tr("fight_protected")
  local updateTimeShow = function()
     --print("protect time:",self._protectLeftTime)
     --protect time
     if self._protectLeftTime <= 0 then
        self._protectCon:setVisible(false)
     else 
      if self._tabIdx == 0 then
         self._protectCon:setVisible(self.btnSearch:isVisible())
      end
      
      self._protectLeftTime = self._protectLeftTime - 1
      if self._protectLeftTime > 86400 then --24*3600
        local dayCount = math.ceil(self._protectLeftTime/86400)
        local dayStr = _tr("%{day}dayleft",{day = dayCount})
        self._labelProtectTime:setString(preStr..dayStr)
      else
        local hour = math.floor(self._protectLeftTime/3600)
        local min = math.floor((self._protectLeftTime%3600)/60)
        local sec = math.floor(self._protectLeftTime%60)
        self._labelProtectTime:setString(preStr..string.format("%02d:%02d:%02d", hour,min,sec))
      end
     end
     
     if self._sesonLeftTime < 0 then
        self._sesonRemainCon:setVisible(false)
        if refreshedSeson == false then
          refreshedSeson = true
          --self.expedition:reqPVPQueryDataC2S(true)
        end
     else
        if self._tabIdx == 0 then
         --self._sesonRemainCon:setVisible(self.btnSearch:isVisible())
         self._sesonRemainCon:setVisible(false)
        end
        
        self._sesonLeftTime = self._sesonLeftTime - 1
        self._labelSeasionRemain:setString(Clock.format(self._sesonLeftTime,Clock.Type.AUTODAYORTIME))
     end
      
      
     local timeLeft =  self.expedition:getLeftTime()
     if timeLeft <= 0 then
        if self._tabIdx == 0 and self._doorOpened == true then
           self.labelLeftTime:setString(_tr("%{second}sceondleft",{ second = 30 }))
           self._doorOpened = false
           self:tabControlOnClick(0)
        end
        return
     end
     
     self.labelLeftTime:setString(_tr("%{second}sceondleft",{ second = timeLeft }))
  end
  self:schedule(updateTimeShow,1/1)
  CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self,handler(self,ExpeditionView.initGuides),GuideConfig.GuideTrigger)
  CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self,handler(self,ExpeditionView.guideSceneClickContinue),GuideConfig.GuideLayerRemoved)
  
  if self._loadingshow == nil then
     self._loadingshow = Mask.new({opacity = 80,priority = -140})
     self:addChild(self._loadingshow)
  end

end

function ExpeditionView:addBufferResult(action,msgId,msg)
  _hideLoading()
  if msg.error == "NO_ERROR_CODE" then 
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)
    self:updateBufferStates()
  end 
end

function ExpeditionView:onStartPvpHandler()
   if self._isSearching == true then
      return
   end
   _playSnd(SFX_CLICK)
   
   local currentTime = Clock:Instance():getCurServerUtcTime()
   if self.expedition:getSelfPvpBaseData() ~= nil and self.expedition:getSelfPvpBaseData():getProtectTime() > currentTime then
     local pop = PopupView:createTextPopup(_tr("attack_protect_will_invalid"), function() 
        self:getDelegate():checkPvpFight()
        return
     end)
     GameData:Instance():getCurrentScene():addChildView(pop)
     return
   end
   self:getDelegate():checkPvpFight()
end

function ExpeditionView:initGuides()
   if self._loadingshow ~= nil then
    self._loadingshow:removeFromParentAndCleanup(true)
    self._loadingshow = nil 
   end
end

function ExpeditionView:guideSceneClickContinue()
  Guide:Instance():removeGuideLayer()
  CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(self,GuideConfig.GuideLayerRemoved)
end

function ExpeditionView:onEnter()
  if self.expedition:getIsRankChanged() == true then
    local lastRank = self.expedition:getSelfPvpBaseData():getLastRank()
    self:playRankUpAnimation(lastRank)
    self.expedition:getSelfPvpBaseData():setLastRank(self.expedition:getSelfPvpBaseData():getRank())
    self.expedition:setIsRankChanged(false)
  end
  
  net.registMsgCallback(PbMsgId.UseItemResultS2C, self, ExpeditionView.addBufferResult)
  
end

function ExpeditionView:onExit()
  net.unregistAllCallback(self)
  self.expedition:stopTimeCountDown()
  CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(self,GuideConfig.GuideTrigger)
  CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(self,GuideConfig.GuideLayerRemoved)
  GameData:Instance():getCurrentScene():getBottomBlock():updateBottomTip(2)
end

function ExpeditionView:onClickHomeRankList()
    self._cardHead:setVisible(false)
    self.expedition:reqRanks()
    local popRankList = ExpeditionRankListPopView.new()
    popRankList:setDelegate(self)
    self:addChild(popRankList)
end

function ExpeditionView:battleformationHandler()
  local controller = ControllerFactory:Instance():create(ControllerType.BATTLE_FORMATION_CONTROLLER)
  controller:enter(false,BattleFormation.BATTLE_INDEX_PVP)
end

function ExpeditionView:onSearchPvpTargetHandler()
   _playSnd(SFX_CLICK)
   
   self._doorOpened = true
   if self._isSearching == true then
      return
   end
   
   if GameData:Instance():getCurrentPlayer():getToken() < (AllConfig.battleinitdata[1].battle_cost + AllConfig.battleinitdata[1].search_cost) then
	    Common.CommonFastBuyToken()
      return
   end

  if GameData:Instance():getCurrentPlayer():isEnabledEnterBattle() == false then
    return
  end
   
   self.labelLeftTime:setString("")
   self:getDelegate():searchPvpTarget()
   self.btnSearch:setVisible(false)
   self.btn_home_rank_list:getParent():setVisible(false)
   self.nodeTokenCost:setVisible(true)
   self._autoHideNode:setVisible(false)
end


function ExpeditionView:onHelpHandler()
    local help = HelpView.new()
    help:addHelpBox(1003,nil,true)
    self:getDelegate():getScene():addChildView(help, 1000)
    ExpeditionView.super:onHelpHandler()
    Guide:Instance():removeGuideLayer()
end

function ExpeditionView:getAwardHandler()
   _playSnd(SFX_CLICK)
   self:getDelegate():reqAward(self._currentAwardRank)
end


function ExpeditionView:enter()
end

function ExpeditionView:updateBufferStates()
 
  local addBuffers = GameData:Instance():getCurrentPlayer():getAppendFighterBuffers().info
  local haveBuffer = false
  for key, buffer in pairs(addBuffers) do
    if buffer.fight_type == "PVP_NORMAL" then
      if #buffer.buff_id > 0 then
        haveBuffer = true
        if self._bufferUpAnim == nil then
          local anim,offsetX,offsetY,long = _res(5020219)
          if anim then
            anim:getAnimation():play("default")
            local animNode = display.newNode()
            self._bufferUpAnim = animNode
            --local btnFight = display.newSprite("#expedition_use_lue_duo.png")
            --animNode:addChild(btnFight)
            animNode:addChild(anim)
            animNode:setPosition(ccp(65,38))
            self.btnStartBattleBuffer:addChild(animNode,100)
          end
        end
        break
      end
    end
  end
  
  self.btnAddBuffer:setEnabled(not haveBuffer)
  
  if self.btnStartBattle:isVisible() then
    self.btnStartBattleBuffer:setVisible(haveBuffer)
    self.btnStartBattle:setVisible(not haveBuffer)
  else
    self.btnStartBattleBuffer:setVisible(false)
  end
  
  if self.btnSearch:isVisible() then
    self.btnStartBattleBuffer:setVisible(false)
  else
    self.nodeBufferCost:setVisible(not self.btnStartBattleBuffer:isVisible())
  end
  
  if self._autoHideNode then
    self._autoHideNode:setVisible(self.btnSearch:isVisible())
  end
end

function ExpeditionView:tabControlOnClick(idx)
  --echo(idx)
  self._doorOpened = false
  self._playOpenDoor = true
  self.expedition:reqRanks()
  self.expedition:stopTimeCountDown()
  if  self._currentPage ~= nil then
    self._currentPage:getParent():removeChild(self._currentPage,true)
    self._currentPage = nil
  end
  
  self:updateBufferStates()

  if self.expedition:getHasNewReport() == true then
     self:getTabMenu():setTipImgVisible(2,true)
  else
     self:getTabMenu():setTipImgVisible(2,false)
  end
  
  if idx == 0 or idx == 3 then
     self.pvpBg:setVisible(true)
     self.searchBackground:setVisible(true)
  else
     self.pvpBg:setVisible(false)
     self.searchBackground:setVisible(false)
     if self._searchOpenDoor ~= nil then
     self._searchOpenDoor:removeFromParentAndCleanup(true)
     self._searchOpenDoor = nil
    end
  end
  
  self.nodeListContainer:removeAllChildrenWithCleanup(true)
  self.nodeBattleContainer:setVisible(false)
  self.nodeInfoContainer:setVisible(false)
  self:setEmptyImgVisible(false)
  self.btn_home_rank_list:getParent():setVisible(false)
  
--  self._protectCon:setVisible(false)
--  self._sesonRemainCon:setVisible(false)

  self._autoHideNode:setVisible(false)
  
  UIHelper.setIsNeedScrollList(true)
  
  local hasRankAward,awardRank = self.expedition:checkHasAward()
  self:getTabMenu():setTipImgVisible(4,hasRankAward)
  
  if idx == 0 then
    if self._protectLeftTime > 0 then
      self._protectCon:setVisible(true)
    end
    self.nodeBattleContainer:setVisible(true)
    self.btnSearch:setVisible(true)
    self.btn_home_rank_list:getParent():setVisible(true)
    self.labelLeftTime:setVisible(false)
    self.btnSearchStart:setVisible(false)
    self.btnStartBattle:setVisible(false)

    self.btnAddBuffer:setVisible(false)
    self.nodeBoaderContainer:setVisible(false)
    self.nodeCardContainer:setVisible(false)
    --self.pvpBg:setVisible(false)
    self.searchBackground:setVisible(true)
    
    self.nodeTokenCost:setVisible(true)
    self.nodeTokenCost:setPosition(ccp(0,170))
    self.nodeSearchCost:setPositionX(0)
    self.nodeFightCost:setVisible(false)
    self.nodeBufferCost:setVisible(false)
    
    self.dropTipLabel:setVisible(true)
    
    self._autoHideNode:setVisible(true)
    
  elseif idx == 1 then
    self.expedition:setHasNewReport(false)
    self:getTabMenu():setTipImgVisible(2,false)
    self._currentPage = BattleReportList.new()
    self._currentPage:setDelegate(self)
    self._currentPage:enter()
    self._currentPage:setReports(self.expedition:getReports())
    
    self.nodeListContainer:addChild(self._currentPage)
  elseif idx == 2 then
    --echo("EMEYS:",table.getn(self.expedition:getEnemys()))
    self._currentPage = EnemyList.new(self,self.expedition:getEnemys())
    self.nodeListContainer:addChild(self._currentPage) 
  elseif idx == 3 then
    self.nodeInfoContainer:setVisible(true)
    self:setScrollBgVisible(true)
    self:getTabMenu():setTipImgVisible(4,false)
  elseif idx == 4 then
    self._currentPage = Billboard.new()
    self._currentPage:setDelegate(self)
    self._currentPage:setBillBoards(self.expedition:getPopularityRanks())

    self:addChild(self._currentPage)
  elseif idx == 5 then
    self._currentPage = WinningStreakView.new()
    self._currentPage:setDelegate(self)
    self._currentPage:setKeepWinRanks(self.expedition:getKeepWinRanks())
    
    self:addChild(self._currentPage)
    
--    self._currentPage = ExpeditionRankListPopView.new()
--    self._currentPage:setDelegate(self)
--    self:addChild(self._currentPage)
  else
  end
  
  if self._tabIdx ~= idx then
     ExpeditionView.super:tabControlOnClick(idx)
  end
  
  self._tabIdx = idx
  self:updateInfoShow()
end


function ExpeditionView:updateInfoShow()
  
  if self.expedition == nil or self.expedition:getSelfPvpBaseData() == nil then
      return
  end
--  local awardRank = self.expedition:getSelfPvpBaseData():getRank() --currentRank
--  if awardRank < 1 then
--     awardRank = 1
--  end

  local currentRank = self.expedition:getSelfPvpBaseData():getRank()
  -- show current rank info
  self.nodeRankIconContainer:removeAllChildrenWithCleanup(true)
  local iconSpr = _res(AllConfig.rank[currentRank].rank_pic)
  if iconSpr ~= nil then
     --iconSpr:setScale(0.8)
     self.nodeRankIconContainer:addChild(iconSpr)
  end
  local iconNum = _res(AllConfig.rank[currentRank].rank_number)
  if iconNum ~= nil then
     --iconNum:setScale(0.8)
     self.nodeRankIconContainer:addChild(iconNum)
  end 
  self.labelCurrentRankName:setString(AllConfig.rank[currentRank].sub_rank_name.."")
  --self.expedition:getRankByScore()
  self.labelBattlePlus:setString(AllConfig.rank[currentRank].rob_desc.."")
  self.labelAttackWin:setString(self.expedition:getSelfPvpBaseData():getAttackScore().."")
  self.labelFsWin:setString(self.expedition:getSelfPvpBaseData():getDefendScore().."")
  self.labelScore:setString(self.expedition:getSelfPvpBaseData():getScore().."")
  if self.expedition:getSelfPvpBaseData():getMaxKeepWin() ~= nil then
     self.labelMostHit:setString(self.expedition:getSelfPvpBaseData():getMaxKeepWin().."")
  end
  
  local dailyScore = self.expedition:getSelfPvpBaseData():getDailyScore()
  self.labelDailyScore:setString(dailyScore.."")
  
  local awards = self.expedition:getAwards()
  local hasRankAward,awardRank = self.expedition:checkHasAward()
  
  --[[if hasRankAward == false then
     if #awards > 0 then
       awardRank = awardRank + 1
     end
     self.btnGetAward:setEnabled(false)
  else
     self._currentAwardRank = awardRank
     self.btnGetAward:setEnabled(true)
     self.node_award_list_1:setVisible(true)
  end]]
  
  --new rule
  --start
    
  self.btnGetAward:setEnabled(hasRankAward)
  
  --end
  
 
  --clear str
  self.labelCurrentRank:setString("")
  self.labelCurrentRankArea:setString("")
  
  self.labelNextRank:setString("")
  self.labelNextRankArea:setString("")
  
   -- max rank
  if AllConfig.rank[awardRank] == nil then
    self.node_award_list_1:setVisible(false)
    return
  end
  self.node_award_list_1:setVisible(true)
 
  --award info
  print("first Rank:",awardRank,AllConfig.rank[awardRank].sub_rank_name)
  self.labelCurrentRank:setString(AllConfig.rank[awardRank].sub_rank_name.."")
  
  self.labelCurrentRankArea:setString("(".._tr("battle_score")..":"..AllConfig.rank[awardRank].min_point.."-"..AllConfig.rank[awardRank].max_point..")")
  print("(".._tr("battle_score")..":"..AllConfig.rank[awardRank].min_point.."-"..AllConfig.rank[awardRank].max_point..")")
  
  if AllConfig.rank[awardRank+1] ~= nil then
     self.node_award_list_2:setVisible(true)
     self.labelNextRank:setString(AllConfig.rank[awardRank+1].sub_rank_name.."")
     self.labelNextRankArea:setString("(".._tr("battle_score")..":"..AllConfig.rank[awardRank+1].min_point.."-"..AllConfig.rank[awardRank+1].max_point..")")
  else
     self.node_award_list_2:setVisible(false)
  end
  
  self.nodeAwardContainer:removeAllChildrenWithCleanup(true)
  self.currentTableViewContainer:removeAllChildrenWithCleanup(true)
  self.nextTableViewContainer:removeAllChildrenWithCleanup(true)
  self:buildAwardListWithRank(awardRank,true)
  if AllConfig.rank[awardRank+1] ~= nil then
     self:buildAwardListWithRank(awardRank + 1)
  end
end

function ExpeditionView:showPvpTargetInfo()
  --self.pvpBg:setVisible(true)
  self.searchBackground:setVisible(false)
  local pvpTarget = self.expedition:getPvpTarget()
  if pvpTarget ~= nil then
      self.nodeTokenCost:setVisible(true)
      self.nodeTokenCost:setPosition(ccp(0,0))
      self.nodeSearchCost:setPositionX(245)
      self.nodeFightCost:setVisible(true)
      self.nodeBufferCost:setVisible(true)
      self.dropTipLabel:setVisible(false)
      local cards = pvpTarget:getCards()
      local cardView = nil
      self.nodeCardContainer:removeAllChildrenWithCleanup(true)
      for i = 1, math.min(8, table.getn(cards)) do
        --show card header
        --local name = string.format("cardButton%d", i)
        cardView = MiddleCardHeadView.new()
        cardView:setCard({configId = cards[i]:getConfigId()})
        if i < 5 then
          cardView:setPositionX((cardView:getContentSize().width+15)*(i-1)+cardView:getContentSize().width/2)
        else
          cardView:setPositionX((cardView:getContentSize().width+15)*(i-5)+cardView:getContentSize().width/2)
          cardView:setPositionY((cardView:getContentSize().height+15)+20)
        end
        self.nodeCardContainer:addChild(cardView)
        self.nodeCardContainer:setPositionX(-320-40)
      end
  
  
    local pName = pvpTarget:getPlayerName()
    if pName ~= nil then
        self.lebelPlayerName:setString(pName)
    else
         self.lebelPlayerName:setString("")
    end

    local canGetCoin = pvpTarget:getAllCoin()
    local strToShow = self:numToClassifierStr(canGetCoin)
    
    self.lebelTotal:setString(strToShow)
    
    local stopKeepWin = pvpTarget:getKeepWin()
    local stopKeepWinCoin = 0
    for i = 1, #AllConfig.stopwinbonus do
       if stopKeepWin >= AllConfig.stopwinbonus[i].min_win and stopKeepWin <= AllConfig.stopwinbonus[i].max_win then
          for key, drop in pairs(AllConfig.stopwinbonus[i].bonus) do
            local type = drop.array[1]
            if type == 4 then
               local num = drop.array[3]
               stopKeepWinCoin = num
               break
            end
          end
          break
       end
    end
    
    --strToShow = self:numToClassifierStr(stopKeepWinCoin)
    self.lebelStopKeepWinAward:setString(""..stopKeepWinCoin)
    
    local canGetTelentPoint = pvpTarget:getTelentPoint()
    strToShow = self:numTalentPointToClassifierStr(canGetTelentPoint)
    self.label_TelentPoint:setString(strToShow)
    
    local pLevel = pvpTarget:getExp()
    if pLevel ~= nil then
        self.labelLevel:setString(pLevel.."")
    else
        self.labelLevel:setString("-")
    end
    
    self.lableKeepWinCount:setString(pvpTarget:getKeepWin())
    
    self.btnSearch:setVisible(false)
    self.btn_home_rank_list:getParent():setVisible(false)
    self.btnSearchStart:setVisible(true)
    self.labelLeftTime:setVisible(true)
    self.btnStartBattle:setVisible(true)

    self.btnAddBuffer:setVisible(true)
    self.nodeBoaderContainer:setVisible(true)
    self.nodeCardContainer:setVisible(true)
    
    self:updateBufferStates()
  end
end

function ExpeditionView:numTalentPointToClassifierStr(num)
   local strToShow = ""
    if num <= 0 then
       strToShow = _tr("none")
    elseif num > 0 and num <= 10 then
       strToShow = _tr("count_level_1")
    elseif num >= 11 and num <= 25 then
       strToShow = _tr("count_level_2")
    elseif num >= 26 and num <= 50 then
       strToShow = _tr("count_level_3")
    elseif num >= 51 and num <= 100 then
       strToShow = _tr("count_level_4")
    elseif num >100 then
       strToShow = _tr("count_level_5")
    end
    return strToShow
end

function ExpeditionView:numToClassifierStr(num)
  
    local strToShow = ""
    if num <= 0 then
       strToShow = _tr("none")
    elseif num <= 5000 then
       strToShow = _tr("count_level_1")
    elseif num <= 10000 then
       strToShow = _tr("count_level_2")
    elseif num <= 30000 then
       strToShow = _tr("count_level_3")
    elseif num <= 50000 then
       strToShow = _tr("count_level_4")
    elseif num > 50000 then
       strToShow = _tr("count_level_5")
    end
    return strToShow

end

function ExpeditionView:onUpdateShowHandler()
     self:showPvpTargetInfo()
end

function ExpeditionView:openDoorPlayFinished()
   self._isSearching = false
   self._playOpenDoor = false
end

function ExpeditionView:animationPlayFinished()
   if self._searchAnimation ~= nil then
      self._searchAnimation:getParent():removeChild(self._searchAnimation,true)
      self._searchAnimation = nil
   end
   self._isSearching = false
end

function ExpeditionView:playRankUpAnimation(fromRank)
  local currentRank = self.expedition:getSelfPvpBaseData():getRank()
  if fromRank >= currentRank then
    return
  end
  
  local owenner = {}
  
  local pkg = ccbRegisterPkg.new(owenner)
  pkg:addProperty("node_old_rank","CCSprite")
  pkg:addProperty("node_new_rank","CCSprite")
  pkg:addProperty("node_new_rank1","CCSprite")
  
  pkg:addProperty("mAnimationManager","CCBAnimationManager")
  pkg:addFunc("rankup_end",function()
    self._rankupAnimation:removeFromParentAndCleanup(true)
    self._rankupAnimation = nil
   end)
  local layer,owner = ccbHelper.load("anim_MilitaryRank.ccbi","anim_MilitaryRank","CCLayer",pkg)
  self._rankupAnimation = layer
  
  local iconSpr = _res(AllConfig.rank[currentRank].rank_pic)
  if iconSpr ~= nil then
     iconSpr = tolua.cast(iconSpr,"CCSprite")
     local spriteframe = iconSpr:displayFrame()
     owenner.node_new_rank1:setDisplayFrame(spriteframe)
  end
  
  local iconSpr = _res(AllConfig.rank[currentRank].rank_pic)
  if iconSpr ~= nil then
     --currentIcon:addChild(iconSpr)
     iconSpr = tolua.cast(iconSpr,"CCSprite")
     local spriteframe = iconSpr:displayFrame()
     owenner.node_new_rank:setDisplayFrame(spriteframe)
     local iconNum = _res(AllConfig.rank[currentRank].rank_number)
     if iconNum ~= nil then
       local frameSize = owenner.node_new_rank:getContentSize()
       iconNum:setPosition(ccp(frameSize.width/2,frameSize.height/2))
       owenner.node_new_rank:addChild(iconNum)
     end 
  end
 
  local iconSpr = _res(AllConfig.rank[fromRank].rank_pic)
  if iconSpr ~= nil then
     iconSpr = tolua.cast(iconSpr,"CCSprite")
     local spriteframe = iconSpr:displayFrame()
     owenner.node_old_rank:setDisplayFrame(spriteframe)
  end
  
  GameData:Instance():getCurrentScene():addChildView(self._rankupAnimation)
end

function ExpeditionView:updateView(showTargetInfo)
  self:updateInfoShow()
  
  if showTargetInfo == nil then
     showTargetInfo = true
  end
  
  if showTargetInfo == false then
      --self.pvpBg:setVisible(false)
      if self.expedition:getLeftTime() <= 1 then
         self.searchBackground:setVisible(true)
      end
      return
  end
  
  --UIHelper.triggerGuideWithObject(12203,self.btnStartBattle)
  
  if self._playOpenDoor == true then
    if self._searchOpenDoor ~= nil then
      self._searchOpenDoor:removeFromParentAndCleanup(true)
      self._searchOpenDoor = nil
    end
    local pkg = ccbRegisterPkg.new(self)
    pkg:addProperty("mAnimationManager","CCBAnimationManager")
    pkg:addFunc("onUpdateShowHandler",ExpeditionView.onUpdateShowHandler)
    pkg:addFunc("animationPlayFinished",ExpeditionView.openDoorPlayFinished)
    local layer,owner = ccbHelper.load("anim_OpenDoor.ccbi","anim_OpenDoorCCB","CCLayer",pkg)
    self._searchOpenDoor = layer
    self.searchBackground:setVisible(false)
    self.pvpBg:setVisible(false)
    self:getNodeContainer():addChild(self._searchOpenDoor,-10)
  else
    local pkg = ccbRegisterPkg.new(self)
    pkg:addProperty("mAnimationManager","CCBAnimationManager")
    pkg:addFunc("onUpdateShowHandler",ExpeditionView.onUpdateShowHandler)
    pkg:addFunc("animationPlayFinished",ExpeditionView.animationPlayFinished)
    local layer,owner = ccbHelper.load("anim_MapSearch02.ccbi","anim_MapSearch02CCB","CCLayer",pkg)
    self._searchAnimation = layer
    self:getNodeContainer():addChild(self._searchAnimation)
  end
  self._isSearching = true
end

function ExpeditionView:buildAwardListWithRank(awardRank,isCurrentRank)
   local con = self.currentTableViewContainer
   if isCurrentRank == true then
      con = self.currentTableViewContainer
   else
      con = self.nextTableViewContainer
   end
   con:removeAllChildrenWithCleanup(true)
   
   local configIdArr = {}
   local drops = GameData:Instance():getItemsWithDropsArray(AllConfig.rank[awardRank].first_get_bonus)

   local function tableCellTouched(tableView,cell)
      if self._tabIdx ~= 3 then
         return
      end
      local target = cell:getChildByTag(123)
      if target ~= nil then 
        --local size = target:getContentSize()
        local posOffset = ccp(45, 100)
        if target ~= nil then
           TipsInfo:showTip(cell,configIdArr[cell:getIdx()+1], nil, posOffset)
        end
      end
    end
  
    local function cellSizeForTable(tableView,idx)
      return 100,100
    end
  
    local function tableCellAtIndex(tableView, idx)
      local cell = tableView:cellAtIndex(idx)
      if nil == cell then
        cell = CCTableViewCell:new()
      else
        cell:removeAllChildrenWithCleanup(true)
      end
      
      print("awardRank:",awardRank)
      
      local awardInfo = drops[idx + 1]
      local type = awardInfo.type
      local dropItemId = awardInfo.configId
      local count = awardInfo.count
      local dropItemView = DropItemView.new(dropItemId,count,type)
      configIdArr[idx+1] = dropItemId
      if dropItemView ~= nil then
       dropItemView:setPositionX(50)
       dropItemView:setPositionY(50)
       dropItemView:setTag(123)
       cell:addChild(dropItemView)
      end
      
      return cell
    end
  
    local function numberOfCellsInTableView(tableView)
      return #drops
    end
    
    local currentRank = self.expedition:getSelfPvpBaseData():getRank() --currentRank
    --build tableview
    local size = con:getContentSize()
    self._scrollView = CCTableView:create(size)
    --self._scrollView:setContentSize(size)
    self._scrollView:setDirection(kCCScrollViewDirectionHorizontal)
    --registerScriptHandler functions must be before the reloadData function
    --self._scrollView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
    --self._scrollView:registerScriptHandler(scrollViewDidZoom,CCTableView.kTableViewZoom)
    self._scrollView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
    self._scrollView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    self._scrollView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
    self._scrollView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
    self._scrollView:reloadData()
    --self._scrollView:setTouchPriority(-999)
    
    con:addChild(self._scrollView)
    self._scrollView:setPositionY(20)

end


function ExpeditionView:onBackHandler()
  ExpeditionView.super:onBackHandler()
  self:getDelegate():goBackView()
end


return ExpeditionView