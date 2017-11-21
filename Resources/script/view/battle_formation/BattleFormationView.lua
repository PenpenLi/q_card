require("view.battle_formation.BattleFormationCardView")
require("view.battle_formation.BattleFormationListView")
require("view.battle.BattleCardView")
require("view.battle.BattleFieldView") 
require("model.battle.Battle") 
require("model.bable.Bable") 

BattleFormationView = class("BattleFormationView",BaseView)
local touchPriority = -512
function BattleFormationView:ctor(selfIsAttacker,battleInformationIdx,isPopMode)
  self:setNodeEventEnabled(true)
  self:initPosition()
  if selfIsAttacker == nil then
    selfIsAttacker = true
  end
  self._selfIsAttacker = selfIsAttacker
  self._selfOrgIsAttacker = selfIsAttacker
  self._battleInformationIdx = battleInformationIdx
  printf("self._battleInformationIdx:"..self._battleInformationIdx)
  if isPopMode == nil then
    isPopMode = true
  end
  self.UNIT_TAG = {433,434}
  
  self._isPopMode = isPopMode
  --if self._isPopMode == true then
    self:setTouchEnabled(true)
    self:addTouchEventListener(handler(self,self.onTouch),false, touchPriority, true)
  --end
  
  self._touchEnabled = true
  self._battleCardsView = {}
  self._fieldView = {}
  self._wallsView = {}
  self._targetGuidePos = -1
  self._btns = {}
  self._cardOwnerType = BattleConfig.CardOwnerTypeAll
  
end

function BattleFormationView:onEnter()
  BattleFormation:Instance():setView(self)
  display.addSpriteFramesWithFile("common/component_list_pop.plist", "common/component_list_pop.png")
  display.addSpriteFramesWithFile("battle_formation/battle_formation.plist", "battle_formation/battle_formation.png")
  
  self._battleFormationNameNode = display.newNode()
  self:addChild(self._battleFormationNameNode,100)
  
  --color layer
  if self._isPopMode ~= true then
    local layerColor = CCLayerColor:create(ccc4(0,0,0,168), display.width*2.0, display.height*2.0)
    self:addChild(layerColor)
  end
  --battle view
  local battle = Battle.new(false,false)
  self.battle = battle

  self:setupBg(battle)
  self:setupFields(battle)
  -- battle wall
  self:setupWall(battle)
      
  local popSize = CCSizeMake(615,400)
  self._popSize = popSize
  
  
  local bg = display.newScale9Sprite("#component_list_pop_bg.png",display.cx,display.cy,popSize)
  self:addChild(bg)
  self._popupBg = bg
  
  if self._battleInformationIdx == BattleFormation.BATTLE_INDEX_BABLE then
     --BattleConfig.CardOwnerTypeSelf = 1
     --BattleConfig.CardOwnerTypeFriend = 2
     self._cardOwnerType = BattleConfig.CardOwnerTypeSelf
     local switchFunc = function(CardOwnerType,updateRightNow)
        
        self._myCardsMenuItem:unselected()
        self._friendCardsMenuItem:unselected()
        
        if CardOwnerType == BattleConfig.CardOwnerTypeSelf then
          self._myCardsMenuItem:selected()
        elseif CardOwnerType == BattleConfig.CardOwnerTypeFriend then
          self._friendCardsMenuItem:selected()
        end
        self._cardOwnerType =  CardOwnerType
        
        if updateRightNow == nil then
          updateRightNow = true
        end
        
        if updateRightNow == true then
          self:buildCardPages(BattleFormation.BATTLE_INDEX_BABLE)
          --self:updateView(BattleFormation.BATTLE_INDEX_BABLE)
        end
     end
      
     local normal = display.newSprite("#battle_formation_mycards2.png")
     local highted = display.newSprite("#battle_formation_mycards1.png")
     local disabled = display.newSprite("#battle_formation_mycards1.png")
     local myCardsMenu,myCardsMenuItem = UIHelper.ccMenuWithSprite(normal,highted,disabled,
      function() switchFunc(BattleConfig.CardOwnerTypeSelf)
     end)
     myCardsMenu:setTouchPriority(touchPriority)
     bg:addChild(myCardsMenu)
     myCardsMenu:setPosition(ccp(90,428))
     self._myCardsMenuItem = myCardsMenuItem
     
     local normal = display.newSprite("#battle_formation_friendcards2.png")
     local highted = display.newSprite("#battle_formation_friendcards1.png")
     local disabled = display.newSprite("#battle_formation_friendcards1.png")
     local friendCardsMenu,friendCardsMenuItem = UIHelper.ccMenuWithSprite(normal,highted,disabled,
      function() switchFunc(BattleConfig.CardOwnerTypeFriend)
     end)
     bg:addChild(friendCardsMenu)
     friendCardsMenu:setTouchPriority(touchPriority)
     friendCardsMenu:setPositionX(myCardsMenu:getPositionX() + normal:getContentSize().width/2 + 70)
     friendCardsMenu:setPositionY(428)
     self._friendCardsMenuItem = friendCardsMenuItem
     
     switchFunc(self._cardOwnerType,false)
     
     Bable:instance():setBattleFormationView(self)
  end
  
  local bgline = display.newSprite("#battle_formation_line.png")
  bg:addChild(bgline)
  bgline:setPosition(bg:getContentSize().width/2,bg:getContentSize().height - 60)
  
  local p_offsetY = 0
  if self._selfIsAttacker == true then
    p_offsetY = popSize.height/2 + 15
  else
    p_offsetY = -(popSize.height/2 + 15)
  end
  self._popupBg:setPosition(ccp(display.cx,display.cy + p_offsetY))

  local titleStr = display.newSprite("#battle_formation_title_str.png")
  bg:addChild(titleStr)
  titleStr:setPosition(bg:getContentSize().width/2,bg:getContentSize().height - titleStr:getContentSize().height)
  
  local allCards = GameData:Instance():getCurrentPackage():getAllCards()
  local cards = {}
  for key, card in pairs(allCards) do
  	if card:getCradIsWorkState() == false then
  	 table.insert(cards,card)
  	end
  end
  
  if #cards > 8 then
    --arrow
    local arrowLeft = display.newSprite("#tab-image-jiantou.png")
    local arrowRight = display.newSprite("#tab-image-jiantou.png")
    arrowRight:setScaleX(-1)
    bg:addChild(arrowLeft)
    bg:addChild(arrowRight)
    
    arrowLeft:setPosition(ccp(45,popSize.height/2 - 20))
    arrowRight:setPosition(ccp(popSize.width - 45,popSize.height/2 - 20))
  end
  
  local leaderCostNode = display.newNode()
  bg:addChild(leaderCostNode)
  leaderCostNode:setPosition(ccp(175,360))
  self._leaderCostNode = leaderCostNode
  
  local leaderStr = display.newSprite("#battle_formation_cost_str.png")
  leaderCostNode:addChild(leaderStr)
  leaderStr:setPosition(ccp(-90,0))
  
  local showText = "0/"..GameData:Instance():getCurrentPlayer():getLeadShip()
  local label = CCLabelBMFont:create(showText, "client/widget/words/card_name/lead_number_nor.fnt")
  --label:setPosition(ccp(display.cx - 150,display.cy + 207))
  --leaderStr:setPosition(ccp(230,205))
  leaderCostNode:addChild(label)
  self._costLabelNormal = label
  
  
  local label_red = CCLabelBMFont:create(showText, "client/widget/words/card_name/lead_number_add.fnt")
  --label_red:setPosition(ccp(0,0))
  leaderCostNode:addChild(label_red)
  self._costLabelRed = label_red
  
  local labelCardCounts = CCLabelTTF:create("", "Courier-Bold",22)
  labelCardCounts:setColor( ccc3(255,255,255))
  leaderCostNode:addChild(labelCardCounts)
  labelCardCounts:setPosition(ccp(295,0))
  self._labelCardCounts = labelCardCounts

  local nor = display.newSprite("#battle_formation_back_nor.png")
  local sel = display.newSprite("#battle_formation_back_sel.png")
  local dis = display.newSprite("#battle_formation_back_sel.png")
  local closeBtn,menuItem = UIHelper.ccMenuWithSprite(nor,sel,dis, 
      function()
        if self._isPopMode == true then
          if self._battleInformationIdx == BattleFormation.BATTLE_INDEX_BABLE then
            self:saveBattleFormation()
          else
            self:popModleCloseHandler()
          end
        else
          if self._battleInformationIdx == BattleFormation.BATTLE_INDEX_PVP 
          and self._selfOrgIsAttacker == false then
            local controller = ControllerFactory:Instance():create(ControllerType.EXPEDITION_CONTROLLER)
            controller:enter()
          elseif self._battleInformationIdx == BattleFormation.BATTLE_INDEX_RANK_MATCH 
          and self._selfOrgIsAttacker == false then
            local controller = ControllerFactory:Instance():create(ControllerType.PVP_RANK_MATCH_CONTROLLER)
            controller:enter()
          else
            local controller = ControllerFactory:Instance():create(ControllerType.PLAY_STATES_CONTROLLER)
            controller:enter(1)
          end
        end
      end)
  self:addChild(closeBtn,3000)
  table.insert(self._btns,closeBtn)
--  closeBtn:setPositionX(display.cx + popSize.width/2 - nor:getContentSize().width/2 + 10)
--  closeBtn:setPositionY(display.cy + popSize.height/2 - nor:getContentSize().height/2 + 10 + p_offsetY)
  closeBtn:setPosition(ccp(display.width - 50,display.height - 55))
  closeBtn:setTouchPriority(touchPriority)
  _registNewBirdComponent(105104,menuItem)
  
  self:updateView(self._battleInformationIdx)
  self:buildMenus(popSize)
  self:showDelegateButtons(false)
  
  self:setIsScrollLock(_executeNewBird())
 
end

function BattleFormationView:updateBattleViewAndExit()
  local battleView = self:getDelegate()
  if battleView ~= nil then
     battleView:setSelfCardsVisible(true)
     battleView:setEnabledCardEnterEffect(false)
     battleView:updateView(self._battleInformationIdx)
     _executeNewBird()
     
  else
    self:removeFromParentAndCleanup(true)
  end
end

function BattleFormationView:setupWall(battle)

  if self._selfIsAttacker ~= true then
    -- setup red wall
    if battle:getIsBossBattle() ~= true then
      local redWallPos = ccp(display.cx,display.cy)
      redWallPos.y = redWallPos.y + BattleConfig.BattleFieldHeight * 0.5
      printf("redWallPos[%f,%f]",redWallPos.x,redWallPos.y)
      local wall = BattleWall.new()
      wall:setGroup(BattleConfig.BattleSide.Red)
      local redWall = BattleWallView.new(wall,battle)
      redWall:setPosition(redWallPos.x,display.size.height + 100)
      self:addChild(redWall,99)
      self:addWallView(BattleConfig.BattleSide.Red,redWall)
      transition.execute(redWall, CCMoveTo:create(0.5,redWallPos))
    end
  end
end

function BattleFormationView:addWallView(group,wallView)
  printf("BattleFormationView:addWallView:%d",group)
  self._wallsView[group] = wallView
end

function BattleFormationView:popModleCloseHandler(isFromSaveResultFunc)
 
--  if isFromSaveResultFunc ~= true and self._battleInformationIdx == BattleFormation.BATTLE_INDEX_BABLE then
--    if self:saveBattleFormation() == false then
--      return
--    end
--  end

  self:updateBattleViewAndExit()
  
  --[[if self._battleInformationIdx == BattleFormation.BATTLE_INDEX_BABLE then
    if isFromSaveResultFunc ~= true then
      if self:saveBattleFormation() == false then
        return
      end
    end
    local haveSelfCard = false
    local haveFriendCard = false
    local friendId = 0
    for key, battleCardView in pairs(self._battleCardsView) do
      if battleCardView.orgCard:getOwnerType() == BattleConfig.CardOwnerTypeFriend then
        haveFriendCard = true
        friendId = battleCardView.orgCard:getId() - 10000
      elseif battleCardView.orgCard:getOwnerType() == BattleConfig.CardOwnerTypeSelf then
        haveSelfCard = true
      end
    end
    
    if haveSelfCard == false then
      Toast:showString(GameData:Instance():getCurrentScene(), "至少选择一张自己的武将", ccp(display.cx, display.cy))
      return
    end
  
    if haveFriendCard == true then
      Bable:instance():reqBableChoiceFriendCardC2S(friendId,self)
    else
      self:updateBattleViewAndExit()
    end
  else
     self:updateBattleViewAndExit()
  end]]
end


------
--  Getter & Setter for
--      BattleFormationView._IsScrollLock 
-----
function BattleFormationView:setIsScrollLock(IsScrollLock)
  self._IsScrollLock = IsScrollLock
end

function BattleFormationView:getIsScrollLock()
  return self._IsScrollLock
end

function BattleFormationView:showDelegateButtons(visible)
  if self._isPopMode == true then
    local battleView = self:getDelegate()
    if battleView ~= nil then
      battleView:showButtons(visible)
    end
  end
end

function BattleFormationView:updateView(battleInformationIdx)
  
  if battleInformationIdx ~= nil then
    --self._selfIsAttacker = BattleFormation:Instance():checkBattleFormationIdxIsAttack(battleInformationIdx)
    if self._selfOrgIsAttacker == true then
      self._battleInformationIdx = battleInformationIdx
    end
  end
  
  self._isSettingLeader = false
  if self._leaderTipStr ~= nil then
    self._leaderTipStr:setVisible(false)
  end
          
  for key, battleCardView in pairs(self._battleCardsView) do
    battleCardView:removeFromParentAndCleanup(true)
  end
  self._battleCardsView = {}
  
--  if battleInformationIdx ~= nil and self._selfOrgIsAttacker == true then
--   self._battleInformationIdx = battleInformationIdx
--  end
  
  local m_battleInformationIdx = self._battleInformationIdx
  if battleInformationIdx ~= nil then
    m_battleInformationIdx = battleInformationIdx
  end
  
  if self._selfOrgIsAttacker == true then
    local popSize = self._popSize
    local p_offsetY = 0
    self._selfIsAttacker = BattleFormation:Instance():checkBattleFormationIdxIsAttack(m_battleInformationIdx)
    if self._selfIsAttacker == true then
      p_offsetY = popSize.height/2 + 15
    else
      p_offsetY = -(popSize.height/2 + 15)
    end
    self._popupBg:setPosition(ccp(display.cx,display.cy + p_offsetY))
  end
  
  self:buildCardPages(m_battleInformationIdx)
  self:initBattleCards(m_battleInformationIdx)
  self:updateLeaderCost()
  self:updateBattleFormationName()
end

function BattleFormationView:updateBattleFormationName()
  self._battleFormationNameNode:removeAllChildrenWithCleanup(true)
  local titleName = ""
  if self._battleInformationIdx == BattleFormation.BATTLE_INDEX_NORMAL_1 then
    titleName = "#battle_formation_attack_name1.png"
  elseif self._battleInformationIdx == BattleFormation.BATTLE_INDEX_NORMAL_2 then
    titleName = "#battle_formation_attack_name2.png"
  elseif self._battleInformationIdx == BattleFormation.BATTLE_INDEX_NORMAL_3 then
    titleName = "#battle_formation_attack_name3.png"
  elseif self._battleInformationIdx == BattleFormation.BATTLE_INDEX_PVP then
    titleName = "#battle_formation_pvp_name.png"
  elseif self._battleInformationIdx == BattleFormation.BATTLE_INDEX_RANK_MATCH then
    titleName = "#battle_formation_rank_match_name.png"
  elseif self._battleInformationIdx == BattleFormation.BATTLE_INDEX_BABLE then
  end
  if titleName ~= "" then
    local spr = display.newSprite(titleName)
    self._battleFormationNameNode:addChild(spr)
    spr:setPosition(display.cx,display.height - spr:getContentSize().height/2 - 15)
  end
end

function BattleFormationView:buildMenus(popSize)
  local globalOffsetX =  (display.width - 640)/2 + 12
  local offsetX = (display.width - popSize.width)/2
  local buttonDistance = 160

  --save btn
  local nor = display.newSprite("#battle_formation_btn_baocunzhenxing.png")
  local sel = display.newSprite("#battle_formation_btn_baocunzhenxing1.png")
  local dis = display.newSprite("#battle_formation_btn_baocunzhenxing1.png")
  local saveBtn,menuItem = UIHelper.ccMenuWithSprite(nor,sel,dis, 
      function()
        _executeNewBird() 
        self:saveBattleFormation()
      end)
  self:addChild(saveBtn)
  saveBtn:setPositionX(display.cx - buttonDistance - offsetX + globalOffsetX)
  saveBtn:setPositionY(60)
  saveBtn:setTouchPriority(touchPriority)
  _registNewBirdComponent(105101,menuItem)
  table.insert(self._btns,saveBtn)
  
  --leader btn
  local nor = display.newSprite("#battle_formation_btn_sheweizhushuai.png")
  local sel = display.newSprite("#battle_formation_btn_sheweizhushuai1.png")
  local dis = display.newSprite("#battle_formation_btn_sheweizhushuai1.png")
  local leaderBtn,menuItem = UIHelper.ccMenuWithSprite(nor,sel,dis, 
      function()
        self:setLeaderCard()
      end)
  self:addChild(leaderBtn)
  leaderBtn:setPositionX(display.cx - offsetX + globalOffsetX)
  leaderBtn:setPositionY(60)
  leaderBtn:setTouchPriority(touchPriority)
  _registNewBirdComponent(105102,menuItem)
  table.insert(self._btns,leaderBtn)
  
  -- load btn
  local nor = display.newSprite("#battle_formation_btn_zairuzhenxing.png")
  local sel = display.newSprite("#battle_formation_btn_zairuzhenxing1.png")
  local dis = display.newSprite("#battle_formation_btn_zairuzhenxing1.png")
  local loadBtn,menuItem = UIHelper.ccMenuWithSprite(nor,sel,dis, 
      function()
        local listView = BattleFormationListView.new(self._selfIsAttacker,self._battleInformationIdx)
        listView:setDelegate(self)
        self:addChild(listView,3000)
      end)
  self:addChild(loadBtn)
  loadBtn:setPositionX(display.cx + buttonDistance - offsetX + globalOffsetX)
  loadBtn:setPositionY(60)
  loadBtn:setTouchPriority(touchPriority)
  _registNewBirdComponent(105102,menuItem)
  table.insert(self._btns,loadBtn)
  
  if self._battleInformationIdx == BattleFormation.BATTLE_INDEX_BABLE then
    saveBtn:setPositionX(saveBtn:getPositionX() + 80)
    leaderBtn:setPositionX(leaderBtn:getPositionX() + 80)
    loadBtn:setVisible(false)

    --saveBtn:setVisible(false)
    --loadBtn:setVisible(false)
  end
end

function BattleFormationView:setLeaderCard()
  if self._isSettingLeader == true then
    return
  end
  
  if #self._battleCardsView <= 0 then
    Toast:showString(GameData:Instance():getCurrentScene(), _tr("select_cards_to_battle_formation"), ccp(display.cx, display.cy))
    return
  end
  
  self._isSettingLeader = true
  
  if self._leaderTipStr == nil then
    self._leaderTipStr = display.newSprite("#battle_formation_tip_str_leader.png")
    self:addChild(self._leaderTipStr)
    local y_offset = 185
    if self._selfIsAttacker == true then
      y_offset = -185
    end
    self._leaderTipStr:setPosition(ccp(display.cx,display.cy + y_offset))
  end
  self._leaderTipStr:setVisible(true)
  self._leaderTipStr:stopAllActions()
  local sequence = CCSequence:createWithTwoActions(CCDelayTime:create(1.5), CCFadeIn:create(1.0))
  local seq = CCSequence:createWithTwoActions(CCFadeOut:create(1.0), sequence)
  self._leaderTipStr:runAction(CCRepeatForever:create(seq))
  
  for key, battleCardView in pairs(self._battleCardsView) do
    local sequence = CCSequence:createWithTwoActions(CCDelayTime:create(1.5), CCFadeOut:create(1.0))
    local seq = CCSequence:createWithTwoActions(CCFadeIn:create(1.0), sequence)
    battleCardView:runAction(CCRepeatForever:create(seq))
  end
end

function BattleFormationView:checkSaveEnabled()
  local hasLeader = 0
  for key, battleCardView in pairs(self._battleCardsView) do
    if battleCardView:getData():getIsPrimary() == true then
      hasLeader = hasLeader + 1
    end
  end
  
  assert(hasLeader <= 1,"leader count must less than 1,now has "..hasLeader)
  if hasLeader == 1 then
  else
    return false
  end
  return true
end

function BattleFormationView:checkExitEnabled()
  if self._battleInformationIdx == BattleFormation.BATTLE_INDEX_BABLE then
    local haveSelfCard = false
    local haveFriendCard = false
    local friendId = 0
    for key, battleCardView in pairs(self._battleCardsView) do
      if battleCardView.orgCard:getOwnerType() == BattleConfig.CardOwnerTypeFriend then
        haveFriendCard = true
        friendId = battleCardView.orgCard:getId() - 10000
      elseif battleCardView.orgCard:getOwnerType() == BattleConfig.CardOwnerTypeSelf then
        haveSelfCard = true
      end
    end
    
    if haveSelfCard == false then
      Toast:showString(GameData:Instance():getCurrentScene(), _tr("select_self_card_atleast1"), ccp(display.cx, display.cy))
      return false
    end
  
    return self:checkSaveEnabled()
  else
    return true
  end
end

function BattleFormationView:saveBattleFormation(isSettingLeader)
  local function saveResult()
    if self._isPopMode == true then
      if isSettingLeader ~= true then
        local isFromSaveFunc = true
        self:popModleCloseHandler(isFromSaveFunc)
      end
    end
  end
  
  local checkHaveSameRootCard = function(targetCard)
    local rootCardsCount = 0
    local rootId = targetCard:getData():getUnitRoot()
    for key, battleCardView in pairs(self._battleCardsView) do
      if battleCardView:getData():getUnitRoot() == rootId then
        rootCardsCount = rootCardsCount + 1
      end
    end
    print("rootCardsCount:",rootCardsCount)
    return rootCardsCount > 1
  end
  
  local haveSameRootCard = false
  local hasLeader = 0
  for key, battleCardView in pairs(self._battleCardsView) do
    if battleCardView:getData():getIsPrimary() == true then
      hasLeader = hasLeader + 1
    end
    
    if haveSameRootCard == false then
      haveSameRootCard = checkHaveSameRootCard(battleCardView)
    end
  end
  
  if haveSameRootCard == true then
    Toast:showString(GameData:Instance():getCurrentScene(),_tr("cannot_set_two_same_battle_card"), ccp(display.cx, display.cy))
    return true
  end
  
  assert(hasLeader <= 1,"leader count must less than 1,now has "..hasLeader)
  if hasLeader == 1 then
  else
    self:setLeaderCard()
    return false
  end

  local battleCards = {}
  for key, battleCardView in pairs(self._battleCardsView) do
    local card = {}
    local pos = self:turnPos(battleCardView.tempPos)
    card.pos = pos
    card.card = battleCardView:getData():getId()
    local leader = 0
    if battleCardView:getData():getIsPrimary() == true then
     leader = 1
    end
    card.leader = leader
    if self._battleInformationIdx == BattleFormation.BATTLE_INDEX_BABLE then
      card.ownerType = battleCardView:getData():getOwnerType()
    end
    table.insert(battleCards,card)
  end
  
  if self._battleInformationIdx == BattleFormation.BATTLE_INDEX_BABLE then
    local haveSelfCard = false
    local haveFriendCard = false
    local friendId = 0
    for key, battleCardView in pairs(self._battleCardsView) do
      if battleCardView.orgCard:getOwnerType() == BattleConfig.CardOwnerTypeFriend then
        haveFriendCard = true
        friendId = battleCardView.orgCard:getId() - 10000
      elseif battleCardView.orgCard:getOwnerType() == BattleConfig.CardOwnerTypeSelf then
        haveSelfCard = true
      end
    end
    
    if haveSelfCard == false then
      Toast:showString(GameData:Instance():getCurrentScene(), _tr("select_self_card_atleast1"), ccp(display.cx, display.cy))
      return false
    end
  
    if haveFriendCard == true then
      BattleFormation:Instance():reqSaveBattleFormationC2S(self._battleInformationIdx,battleCards,isSettingLeader)
      Bable:instance():reqBableChoiceFriendCardC2S(friendId,saveResult)
      return false
    end
  end

  BattleFormation:Instance():reqSaveBattleFormationC2S(self._battleInformationIdx,battleCards,isSettingLeader,saveResult)
  return true
end

function BattleFormationView:onExit()
  self:showDelegateButtons(true)
  display.removeSpriteFramesWithFile("common/component_list_pop.plist", "common/component_list_pop.png")
  display.removeSpriteFramesWithFile("battle_formation/battle_formation.plist", "battle_formation/battle_formation.png")
  self.battle:destory()
  self.battle = nil
  self._cloneTipCardView = nil
  self._battleCardsView = nil
  BattleFormation:Instance():setView(nil)
  Bable:instance():setBattleFormationView(self)
end

local function getIdlePos(is_Defender,battleCards)
    local startPos = 4
    local endPos = 15
    
    if is_Defender == true then
       startPos = 16
       endPos = 27
    end

    local pos = startPos
    for m_pos = startPos, endPos do
       local posIsIdle = true
       for key, m_card in pairs(battleCards) do
           if m_card.tempPos == m_pos then
              posIsIdle = false
              break
           end
       end
       if posIsIdle == true then
          pos = m_pos
          break
       end 
    end
    return pos
end

function BattleFormationView:onTouch(event,x,y)
  --print("event:"..event,x,y)
  if event == "began" then
    self._touchStepX = x
    self._touchStepY = y
    local battleView = self:getDelegate()
    if battleView ~= nil then
      battleView:setSelfCardsVisible(false)
    end
  end
  
  if self._touchEnabled == false then
    return true
  end
  
  local startDragPos = 4
  local endDragPos = 15
  if self._selfIsAttacker == false then
    startDragPos = 16
    endDragPos = 27
  end
  
  local function checkOverField()
   -- get an new Pos
    local touchOverFieldView = self:getTouchedNode(self._fieldView,x,y) -- touchover an fiedView
    if  touchOverFieldView ~= self._overFieldView then
      --[[if touchOverFieldView ~= nil then -- touchover an new target fieldView
         if self._moveCardView ~= nil then
            --if touchOverFieldView.tempPos >= 4 and touchOverFieldView.tempPos <= 15 then
               local direction = 1
               if self._moveCardView:getData():getIsMySide() == false then
                  direction = -1
               end
               self._troopIntroductionView:areaWithUnitTypeAndPos(self._moveCardView:getData():getType(),touchOverFieldView.tempPos,direction)
            --end
         end
      end]]
    end
    self._overFieldView = touchOverFieldView
  end
  
  if event == "began" then
    self._touchStepX = x
    self._touchStepY = y
    
    self._moveCardView = nil
    local m_cardView = self:getTouchedNode(self._battleCardsView,x,y) --touchover an cardView
    if m_cardView ~= nil and m_cardView:getDragEnabled() == true then
       self._moveCardView = m_cardView
    end
    
    if self._moveCardView ~= nil then
      checkOverField()
      
      if self._moveCardView.tempPos >= startDragPos and self._moveCardView.tempPos <= endDragPos then
        self._moveCardView:setZOrder(99)
        self._startPos =  self:getPosByIndex(self._moveCardView.tempPos)
        
        if self._isSettingLeader == true then
          for key, battleCardView in pairs(self._battleCardsView) do
            battleCardView:getData():setIsPrimary(false)
            if self._moveCardView:getData():getId() == battleCardView:getData():getId() then
              battleCardView:getData():setIsPrimary(true)
            end
            battleCardView:stopAllActions()
            battleCardView:updateCardView()
            battleCardView:runAction(CCFadeIn:create(0.25))
          end
          self._isSettingLeader = false
          if self._leaderTipStr ~= nil then
            self._leaderTipStr:setVisible(false)
          end
          self:saveBattleFormation(true)
          self._moveCardView = nil
          return true
        end
      else
        self._moveCardView = nil
      end
    end
    return true
  elseif event == "moved" then
    if self._moveCardView ~= nil then
      if self._moveCardView.tempPos >= startDragPos and self._moveCardView.tempPos <= endDragPos then
         self._moveCardView:setPosition(ccp(x,y))
      end

      if  self._isMoving == true then
        return true
      end
      
      checkOverField()
      
      if self._posChangePreview == true then
        self:autoChangePosition(x,y)
      end
    end
  elseif event == "ended" then
    --printf("ended")
    --[[if math.abs(self._touchStepX-x) < 30 and math.abs(self._touchStepY-y) < 30 
    and x > display.cx - 250 and x < display.cx + 250
    then
       local targetCard = UIHelper.getTouchedNode(self._cardViewConArray,x,y)
       if targetCard ~= nil and self._isSettingLeader ~= true then
          echo("tap:",targetCard:getCard():getName())
          if self._tipMove ~= nil then
            return true
          end
          
          local currentLevel = GameData:Instance():getCurrentPlayer():getLevel()
          local total = AllConfig.charlevel[currentLevel].unit_slot_unlock
          
          if targetCard:getSelected() == false and #self._battleCardsView >= total then
            local str = ""
            if total < 8 then
              str = "当前等级最多上阵"..total.."张卡牌"
            else
              str = "最多上阵"..total.."张卡牌"
            end
            Toast:showString(GameData:Instance():getCurrentScene(),str, ccp(display.cx, display.cy))
            return true
          end
          
          if targetCard:getSelected() == false then
            local cost = self:getCurrentLeaderCost()
            local targetCardCost = targetCard:getCard():getLeadCost()
            local targetTotalCost = targetCardCost + cost
            if targetTotalCost > GameData:Instance():getCurrentPlayer():getLeadShip() then
              local offset = targetTotalCost - GameData:Instance():getCurrentPlayer():getLeadShip()
              Toast:showString(GameData:Instance():getCurrentScene(), "上阵该武将还差"..offset.."领导力", ccp(display.cx, display.cy))
              return true
            end
          end

          targetCard:setSelected(not targetCard:getSelected())
          if targetCard:getSelected() == true then
            local battleCardView = self:buildBattleCardViewByCard(targetCard:getCard())
            local pos = getIdlePos(not self._selfIsAttacker,self._battleCardsView)
            local position = self:getPosByIndex(pos)
            battleCardView:setPosition(position)
            battleCardView.tempPos = pos
            self:addChild(battleCardView)
            table.insert(self._battleCardsView,battleCardView)
          else
            for key, battleCardView in pairs(self._battleCardsView) do
            	if battleCardView:getData():getId() == targetCard:getCard():getId() then
            	 battleCardView:removeFromParentAndCleanup(true)
            	 table.remove(self._battleCardsView,key)
            	end
            end
          end
          self:updateLeaderCost()
          _executeNewBird()
       end
    end
    ]]
    
    
    if self._moveCardView == nil then
      return true
    end
    
    --clear over field
    self._overFieldView = nil

    self._touchEnabled = false
    self:autoChangePosition(x,y)
    
    if self._overFieldView ~= nil then
      --print("if self._overFieldView ~= nil ")
       if self._overFieldView:getData():getPos() < startDragPos or self._overFieldView:getData():getPos() > endDragPos then
          self._overFieldView = nil
       end
    end
    
    --print("self._overFieldView: ",self._overFieldView)

    if self._overFieldView == nil or self._overFieldView:getIsLocked() == true then
      self._isMoving = true
      transition.execute(self._moveCardView, CCMoveTo:create(0.2,self._startPos),
        {
          --delay = 1.0,
          --easing = "backout",
          onComplete = function()
            --self._troopIntroductionView:areaWithUnitTypeAndPos(self._moveCardView:getData():getType(),self._moveCardView.tempPos)
            self._moveCardView = nil
            self._touchEnabled = true
            self._overFieldView = nil
            self._isMoving = false
          end,
        })
    else
      self._isMoving = true
      self._moveCardView:stopAllActions() 
   
      transition.execute(self._moveCardView, CCMoveTo:create(0.2,self._targetPos),
        {
          --delay = 1.0,
          --easing = "backout",
          onComplete = function()
            --change card Pos
            if  self._overCardView ~= nil then
              self._overCardView.tempPos = self._moveCardView.tempPos
            end
            --change card Pos
            self._moveCardView.tempPos = self._overFieldView:getData():getPos()

            echo("NowPos:",self._overFieldView:getData():getPos(),"expected:",self._targetGuidePos)
            if self._moveCardView.tempPos == self._targetGuidePos then
--               if self._startBtn ~= nil then
--                 self._startBtn:setVisible(true)
--               end
               if self._tipMove ~= nil then
                  self._tipMove:removeFromParentAndCleanup(true)
                  self._tipMove = nil
               end
               self:showButtons(true)
               
               if self._cloneTipCardView ~= nil then
                for key, cardView in pairs(self._cloneTipCardView) do
                	if self._moveCardView:getData():getId() == cardView:getData():getId() then
                	 cardView.tempPos = self._targetGuidePos
                	 break
                	end
                end
                self._battleCardsView = self._cloneTipCardView
               end
               _executeNewBird()
               self._targetGuidePos = -1
            end
  
            self._moveCardView = nil
            self._touchEnabled = true
            self._overFieldView = nil
            self._isMoving = false
          end,
        })
    end
    
  end
end

function BattleFormationView:getCurrentLeaderCost()
  local cost = 0
  for key, battleCardView in pairs(self._battleCardsView) do
    if battleCardView.orgCard:getOwnerType() == BattleConfig.CardOwnerTypeSelf then
      cost = cost + battleCardView:getData():getLeadCost()
    end
  end
  return cost
end

function BattleFormationView:updateLeaderCost()
  --update cost
  local cost = self:getCurrentLeaderCost()
  local showText = cost.."/"..GameData:Instance():getCurrentPlayer():getLeadShip()
  self._costLabelNormal:setVisible(false)
  self._costLabelRed:setVisible(false)
  if cost > GameData:Instance():getCurrentPlayer():getLeadShip() then
    self._costLabelRed:setVisible(true)
    self._costLabelRed:setString(showText)
  else
    self._costLabelNormal:setVisible(true)
    self._costLabelNormal:setString(showText)
  end
  
  local currentLevel = GameData:Instance():getCurrentPlayer():getLevel()
  local total = AllConfig.charlevel[currentLevel].unit_slot_unlock
  
  local str = _tr("playstated%{current_count}%{max_count}",{current_count = #self._battleCardsView,max_count = total})
  self._labelCardCounts:setString(str)
  --self._labelCardCounts:setString("已上阵:"..#self._battleCardsView.."/"..total)
end

function BattleFormationView:getTouchedNode(toTouchArray,x,y)
  local isGetedNode = false
  local touchedNode = nil
  
  for key, element in pairs(toTouchArray) do
  	local contentSize = element:getContentSize()
  	local position = element:getParent():convertToNodeSpace(ccp(x + contentSize.width/2,y + contentSize.height/2 ))
    --if toTouchArray[i]:getData():getPos() >= 4 and toTouchArray[i]:getData():getPos() <= 15 then
      isGetedNode = element:boundingBox():containsPoint(position)
    --end

    if isGetedNode == true then
      touchedNode = element
      break
    end
  end
  return touchedNode
end

function BattleFormationView:autoChangePosition(x,y)
  local startDragPos = 4
  local endDragPos = 15
  if self._selfIsAttacker == false then
    startDragPos = 16
    endDragPos = 27
  end
  
  local touchOverFieldView = self:getTouchedNode(self._fieldView,x,y) -- touchover an fiedView
  if  touchOverFieldView ~= self._overFieldView then
    if touchOverFieldView ~= nil then -- touchover an new target fieldView
      --self._targetPos = ccp(touchOverFieldView:getPositionX(),touchOverFieldView:getPositionY())
      self._targetPos = self:getPosByIndex(touchOverFieldView:getData():getPos())
      self._overCardView = self:getCardViewByCardPos(touchOverFieldView:getData():getPos())
      if self._overCardView ~= nil and self._overCardView.tempPos >= startDragPos and self._overCardView.tempPos <= endDragPos then
        self._lastOverCardView = self._overCardView
        self._isMoving = true
        transition.execute(self._overCardView, CCMoveTo:create(0.2,self._startPos),
          {
            onComplete = function()
              self._isMoving = false
            end,
          })

      end

    else -- out of any fieldView
      if self._lastOverCardView ~= nil then
        self._isMoving = true
        local backPos = self:getPosByIndex(self._lastOverCardView.tempPos)
        transition.execute(self._lastOverCardView, CCMoveTo:create(0.2,backPos),
          {
            onComplete = function()
              self._isMoving = false
              self._lastOverCardView = nil
              self._overCardView = nil
            end,
          })
      end
    end
    self._overFieldView = touchOverFieldView
  else
  -- touchOver at the same fieldView
  end
end

function BattleFormationView:buildBattleCardViewByCard(card)
  local cardConfigId = card:getConfigId()
  local battleCard = BattleCard.new()
  battleCard:initAttrById(cardConfigId)
  battleCard:setId(card:getId())
  battleCard:setType(AllConfig.unit[cardConfigId].unit_type)
  battleCard:setIsPrimary(card:getIsBoss())
  battleCard:setOwnerType(card:getOwnerType())
  if self._battleInformationIdx == BattleFormation.BATTLE_INDEX_BABLE then
    local hpper = card:getCardHpperByHpType(Card.CardHpTypeBable)
    local maxhp = 100
    battleCard:setHp(maxhp * hpper / 10000)
    battleCard:setMaxHp(maxhp)
  end
  battleCard:setGroup(BattleConfig.BattleSide.Blue)
  local battleCardView = BattleCardView.new()
  battleCardView:init(battleCard)
  battleCardView.tempPos = 0
  battleCardView.orgCard = card
  
  return battleCardView
end

function BattleFormationView:getCardViewByCardPos(posIndex)
  local mCardView = nil
  for key, cardView in pairs(self._battleCardsView) do
    if cardView.tempPos == posIndex then
      mCardView = cardView
      break
    end
  end
  return mCardView
end

local mScale = 1.0
local itemW = 100 * mScale
local itemH = 100 * mScale

function BattleFormationView:buildCardPages(battleInformationIdx)
  if self.tableView ~= nil then
    self.tableView:removeFromParentAndCleanup(true)
    self.tableView = nil 
  end
  
  --all cards to select
  local cards = BattleFormation:Instance():getCardsByBattleFormationIdx(battleInformationIdx,self._cardOwnerType)
  
  local function getCenterPosition(tableView)
    local x, y = tableView:getParent():getPosition()
    local pos = tolua.cast(tableView:getParent():getParent():convertToWorldSpace(ccp(x, y)), "CCPoint")
    return pos
  end
  
  local function sortTables(a, b)
     if a.tempSelected == b.tempSelected then
       if a:getPos() == b:getPos() then
         if a:getMaxGrade() == b:getMaxGrade() then
            if a:getGrade() == b:getGrade() then
              if a:getLevel() == b:getLevel() then
                return a:getConfigId() < b:getConfigId()
              end
              return a:getLevel() > b:getLevel()
            end
            return a:getGrade() > b:getGrade()
         end
         return a:getMaxGrade() > b:getMaxGrade()
       end
       return a:getPos() > b:getPos()
     end
     return a.tempSelected > b.tempSelected
  end
  
  local function sortBableCards(a,b)
    if a:getBableIsAlive() == b:getBableIsAlive() then
      if a.tempSelected == b.tempSelected then
       if a:getPos() == b:getPos() then
         if a:getMaxGrade() == b:getMaxGrade() then
            if a:getGrade() == b:getGrade() then
              if a:getLevel() == b:getLevel() then
                return a:getConfigId() < b:getConfigId()
              end
              return a:getLevel() > b:getLevel()
            end
            return a:getGrade() > b:getGrade()
         end
         return a:getMaxGrade() > b:getMaxGrade()
       end
       return a:getPos() > b:getPos()
     end
     return a.tempSelected > b.tempSelected
   end
   
   return a:getBableIsAlive() > b:getBableIsAlive()
  end
    
  
  if battleInformationIdx == BattleFormation.BATTLE_INDEX_BABLE then
    table.sort(cards,sortBableCards)
  else
    table.sort(cards,sortTables)
  end
  
  
  local function scrollViewDidScroll(tableview)
    if self:getIsScrollLock() == true then
        tableview:getContainer():setPositionX(0)
    end
  end
  
--  local function tableRecycleHandler(tableView,cell)
----    local cardIdx = cell:getIdx()*2 + 1
----    self._cardViewConArray[cardIdx] = nil
--  end
  
  local function tableCellTouched(tableView,cell)
      printf("cell touched at index: " .. cell:getIdx())
         self:setIsScrollLock(false)
         local centerPos = getCenterPosition(tableView)
        -- print("centerPos:",centerPos.x,centerPos.y,self._touchStepY)
         local targetCard = nil
         if self._touchStepY > centerPos.y - 23 then
            targetCard = cell:getChildByTag(self.UNIT_TAG[1])
         else
            targetCard = cell:getChildByTag(self.UNIT_TAG[2])
         end
         
         if targetCard ~= nil and self._isSettingLeader ~= true then
            echo("tap:",targetCard:getCard():getName())
            if self._tipMove ~= nil then
              return true
            end
            
            if battleInformationIdx == BattleFormation.BATTLE_INDEX_BABLE then
              if targetCard:getCard():getCardHpperByHpType(Card.CardHpTypeBable) <= 0 then
                local str = _tr("selected_card_is_dead")
                Toast:showString(GameData:Instance():getCurrentScene(),str, ccp(display.cx, display.cy))
                return
              end
            end
            
            local currentLevel = GameData:Instance():getCurrentPlayer():getLevel()
            local total = AllConfig.charlevel[currentLevel].unit_slot_unlock
            
            if targetCard:getSelected() == false and #self._battleCardsView >= total then
              local str = ""
              if total < 8 then
                --str = "当前等级最多上阵"..total.."张卡牌"
                str = _tr("playstated_max_%{count}_current",{count = total})
              else
                --str = "最多上阵"..total.."张卡牌"
                str = _tr("playstated_max_%{count}_all",{count = total})
              end
              Toast:showString(GameData:Instance():getCurrentScene(),str, ccp(display.cx, display.cy))
              return true
            end
            
            if targetCard:getSelected() == false then
              local cost = self:getCurrentLeaderCost()
              local targetCardCost = targetCard:getCard():getLeadCost()
              local targetTotalCost = targetCardCost + cost
              if targetTotalCost > GameData:Instance():getCurrentPlayer():getLeadShip() then
                local offset = targetTotalCost - GameData:Instance():getCurrentPlayer():getLeadShip()
                Toast:showString(GameData:Instance():getCurrentScene(), _tr("need_more%{count}_leader_ship",{count = offset}), ccp(display.cx, display.cy))
                return true
              end
              
              local haveSameRootCard = false
              local haveSelfCard = false
              local haveFriendCard = false
              for key, battleCardView in pairs(self._battleCardsView) do
                if battleCardView:getData():getUnitRoot() == targetCard:getCard():getUnitRoot() then
                  haveSameRootCard = true
                end
                
                if battleCardView.orgCard:getOwnerType() == BattleConfig.CardOwnerTypeFriend then
                  haveFriendCard = true
                elseif battleCardView.orgCard:getOwnerType() == BattleConfig.CardOwnerTypeSelf then
                  haveSelfCard = true
                end
              end
              
              if haveSameRootCard == true then
                Toast:showString(GameData:Instance():getCurrentScene(),_tr("cannot_set_two_same_battle_card"), ccp(display.cx, display.cy))
                return true
              end
              
              if haveFriendCard == true and targetCard:getCard():getOwnerType() == BattleConfig.CardOwnerTypeFriend then
                Toast:showString(GameData:Instance():getCurrentScene(),_tr("only1friend_for_help"), ccp(display.cx, display.cy))
                return true
              end

            end
  
            targetCard:setSelected(not targetCard:getSelected())
            if targetCard:getSelected() == true then
              local battleCardView = self:buildBattleCardViewByCard(targetCard:getCard())
              local pos = getIdlePos(not self._selfIsAttacker,self._battleCardsView)
              local position = self:getPosByIndex(pos)
              battleCardView:setPosition(position)
              battleCardView.tempPos = pos
              self:addChild(battleCardView)
              table.insert(self._battleCardsView,battleCardView)
              if self._battleInformationIdx == BattleFormation.BATTLE_INDEX_BABLE then
                local cardsFormation = BattleFormation:Instance():getCardsFormationByBattleIndex(battleInformationIdx)
                local haveInfo = false
                for key, battleCardInfo in pairs(cardsFormation) do
                  if battleCardInfo.card == targetCard:getCard():getId() then
                    haveInfo = true
                    battleCardInfo.pos = pos
                    local leader = 0
                    if targetCard:getCard():getIsBoss() == true then
                      leader = 1
                    end
                    battleCardInfo.leader = leader
                    battleCardInfo.ownerType = targetCard:getCard():getOwnerType()
                  end
                end
                if haveInfo == false then
                  local battleCardInfo = {}
                  battleCardInfo.card = targetCard:getCard():getId()
                  battleCardInfo.pos = pos
                  local leader = 0
                  if targetCard:getCard():getIsBoss() == true then
                    leader = 1
                  end
                  battleCardInfo.leader = leader
                  battleCardInfo.ownerType = targetCard:getCard():getOwnerType()
                  table.insert(cardsFormation,battleCardInfo)
                end
                
              end
            else
              for key, battleCardView in pairs(self._battleCardsView) do
                if battleCardView:getData():getId() == targetCard:getCard():getId() then
                 battleCardView:removeFromParentAndCleanup(true)
                 table.remove(self._battleCardsView,key)
                 
                 if self._battleInformationIdx == BattleFormation.BATTLE_INDEX_BABLE then
                   local cardsFormation = BattleFormation:Instance():getCardsFormationByBattleIndex(battleInformationIdx)
                   for key, battleCardInfo in pairs(cardsFormation) do
                     --print(battleCardInfo.card,battleCardInfo.pos,battleCardInfo.leader)
                     if battleCardInfo.card == targetCard:getCard():getId()
                     and battleCardInfo.ownerType == targetCard:getCard():getOwnerType()
                     then
                        table.remove(cardsFormation,key)
                     end
                   end
                 end
                 
                end
              end
            end
            
            --for test
            local cardsFormation = BattleFormation:Instance():getCardsFormationByBattleIndex(battleInformationIdx)
            dump(cardsFormation)
            
            self:updateLeaderCost()
            self:setIsScrollLock(_executeNewBird())
         end
--      end
   end
  
   local function cellSizeForTable(table,idx) 
      return itemH + 4,128
   end
  
   local function tableCellAtIndex(tableView, idx)
--           idx   idx+1
--      1,2   0      1        idx + idx + 1
--      3,4   1      2        
--      5,6   2      3
--      7,8   3      4

      local cell = tableView:dequeueCell()
      local cardIdx = idx*2 + 1
      
      if nil ~= cell then
        cell:removeFromParentAndCleanup(true)
        cell = nil
      end
      cell = CCTableViewCell:new()
      for j = 1, 2 do
        local card = cards[cardIdx]
        --print("cardIdx:",cardIdx)
        if card ~= nil then
          card:setIsBoss(false)
          local cardView = BattleFormationCardView.new(card,self._battleInformationIdx)
          cardView:setScale(mScale)
          cardView:setTag(self.UNIT_TAG[j])
          local headSize = cardView:getContentSize()
          local distanceX = 6
          local distanceY = 32
          local offsetY = 5
          itemW = headSize.width
          itemH = headSize.height
          cell:addChild(cardView)
          cardView:setPositionX(itemW*0.5)
          cardView:setPositionY(((itemH + distanceY) *(2 - j)) + itemH)
--          self._cardViewConArray[cardIdx] = cardView
          _registNewBirdComponent(105000 + cardIdx,cardView)
          cardView:setSelected(card.tempSelected > 0)
          cardIdx = cardIdx + 1
        end
      end
     
      return cell
  end
  
  local function numberOfCellsInTableView(val)
     return math.round(#cards/2)
  end
  
   if self.tableView == nil then
    local scrollViewSizeWidth = self._popupBg:getContentSize().width
    local scrollViewSizeHeight = 320
    
    local offsetX = 60
    local offsetY = 0
    
    local scrollViewSize = CCSizeMake(scrollViewSizeWidth - offsetX*2,scrollViewSizeHeight)
 
    local tableView = CCTableView:create(scrollViewSize)
    tableView:setDirection(kCCScrollViewDirectionHorizontal)
    tableView:setClippingToBounds(true)
    self._popupBg:addChild(tableView)
    tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
    tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
    tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
    tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)  
    --tableView:registerScriptHandler(tableRecycleHandler,CCTableView.kTableCellWillRecycle)
    tableView:setPosition(offsetX,offsetY)
    tableView:setTouchPriority(touchPriority)
    self.tableView = tableView
  end
  self.tableView:reloadData()
end

function BattleFormationView:turnPos(pos)
  if self._selfIsAttacker == false then
    pos = 31 - pos
  end
  return pos
end

function BattleFormationView:initBattleCards(battleInformationIdx)
  
  local function getCardById(cards,cardId)
    local targetCard = nil
    for key, card in pairs(cards) do
    	if card:getId() == cardId then
    	 targetCard = card
    	 break
    	end
    end
    
    return targetCard
  end
  
  
  --BattleConfig.CardOwnerTypeSelf = 1
     --BattleConfig.CardOwnerTypeFriend = 2
  --   self._cardOwnerType = BattleConfig.CardOwnerTypeSelf
     
     
  local cardsFormation = BattleFormation:Instance():getCardsFormationByBattleIndex(battleInformationIdx)
  for key, battleCardInfo in pairs(cardsFormation) do
  	print(battleCardInfo.card,battleCardInfo.pos,battleCardInfo.leader)
  	local cards = GameData:Instance():getCurrentPackage():getAllCards()
  	if battleInformationIdx == BattleFormation.BATTLE_INDEX_BABLE then
--  	 if self._cardOwnerType == BattleConfig.CardOwnerTypeSelf then
--  	   cards = Bable:instance():getCardsForBattle()
--  	 elseif self._cardOwnerType == BattleConfig.CardOwnerTypeFriend then
--  	   cards = Bable:instance():getFriendCards()
--  	 end
     cards = Bable:instance():getAllCards()

  	end
  	
  	local targetCard = getCardById(cards,battleCardInfo.card)
  	
  	assert(targetCard ~= nil,"Invailed card,id:"..battleCardInfo.card)
    targetCard:setIsBoss(battleCardInfo.leader > 0)
    local battleCardView = self:buildBattleCardViewByCard(targetCard)
    --battleCardView.leader = battleCardInfo.leader
    self:addChild(battleCardView)
    local pos = self:turnPos(battleCardInfo.pos)
    local position = self:getPosByIndex(pos)
    battleCardView:setPosition(position)
    battleCardView.tempPos = pos
    table.insert(self._battleCardsView,battleCardView)
  end
end


function BattleFormationView:initPosition()
  -- init position
  self._positions = {}
  local paddingX = (BattleConfig.BattleFieldWidth - BattleConfig.BattleFieldLen * BattleConfig.BattleFieldCol ) / (BattleConfig.BattleFieldCol - 1)
  local validRow = BattleConfig.BattleFieldRow - BattleConfig.BattleFieldWallCols * 2 -- the rows of the main battle fields without walls
  local paddingY = (BattleConfig.BattleFieldHeight - BattleConfig.BattleFieldLen * validRow ) / validRow
  --printf("validRow:%d,paddingX:%f,paddingY:%f",validRow,paddingX,paddingY)
  local orinPos = ccp(display.cx,display.cy)
  orinPos.x = orinPos.x - paddingX * 0.5 - BattleConfig.BattleFieldLen * BattleConfig.BattleFieldCol * 0.5 - paddingX * (BattleConfig.BattleFieldCol * 0.5 - 1)
  orinPos.y = orinPos.y - validRow * 0.5 * (BattleConfig.BattleFieldLen + paddingY)
  orinPos.x = orinPos.x + (BattleConfig.BattleFieldLen) * 0.5
  orinPos.y = orinPos.y + (BattleConfig.BattleFieldLen) * 0.5
  for i = 0, BattleConfig.BattleFieldCount - 1 do
    self._positions[i] = ccp(0,0)
  end
  local wallHeight = BattleConfig.BattleFieldWallLength/BattleConfig.BattleFieldRow
  for i = BattleConfig.BattleFieldBegin + BattleConfig.BattleFieldWallLength, BattleConfig.BattleFieldEnd - BattleConfig.BattleFieldWallLength - 1 do
    local index = i - BattleConfig.BattleFieldWallLength
    local row = math.floor(index/BattleConfig.BattleFieldCol)
    local col = index % BattleConfig.BattleFieldCol
    local pos = ccp(orinPos.x + BattleConfig.BattleFieldLen * col + paddingX * col,orinPos.y + BattleConfig.BattleFieldLen * row + paddingY * row)
    if row >= validRow * 0.5 then
      -- at the centre point,you should set the gap size
      pos.y = pos.y + 24
    end
    self._positions[i] = pos
    --printf("pos[%d][index = %d,row = %d,col = %d,x = %f,y = %f]",i,index,row,col,pos.x,pos.y)
  end
end

function BattleFormationView:getPosByIndex(pos_index)
  local pos = self._positions[pos_index]
  return ccp(pos.x,pos.y)
end

function BattleFormationView:getFieldViewByIndex(index)
  return self._fieldView[index]
end

function BattleFormationView:getFieldViewByPos(pos)
  local fieldView = nil
  for key, field in pairs(self._fieldView) do
    if field:getData():getPos() == pos then
       fieldView = field
       break
    end
  end
  return fieldView
end

function BattleFormationView:setupBg(battle)
  if self._isPopMode == true then
    return  
  end

  local bgPos = display.p_center
  local viewConfig = battle:getViewConfig()
  local bg = _res(viewConfig.bg)
  bg:setPosition(bgPos)
  self:addChild(bg)
  
end

function BattleFormationView:setupFields(battle)
  self._fieldView = {}
  -- setup fields
  local fields = {}
  for i = BattleConfig.BattleFieldBegin, BattleConfig.BattleFieldEnd do
    fields[i] = "Wall"
  end
  for i = BattleConfig.BattleFieldBegin + BattleConfig.BattleFieldWallLength, BattleConfig.BattleFieldEnd - BattleConfig.BattleFieldWallLength - 1 do
    fields[i] = BattleField.new(i)
  end
  
  for key, field in pairs(fields) do
    if field ~= "Wall" then
      local pos = self:getPosByIndex(field:getPos())
      local battleFieldView = BattleFieldView.new(field,battle)
      battleFieldView:setPosition(pos)
      self:addChild(battleFieldView)
      self:addFieldView(field:getIndex(),battleFieldView)
      battleFieldView:setVisible(not self._isPopMode)
    else
      -- the wall field
    end
  end
end

function BattleFormationView:addFieldView(index,fieldView)
  self._fieldView[index] = fieldView
end

function BattleFormationView:tipMoveCard(startPos,toPos)
   self._targetGuidePos = toPos
   local fieldViews = {}
   local fieldViewStart = nil
   local fieldViewTarget = nil
   
   self._cloneTipCardView = clone(self._battleCardsView)
    
   fieldViewStart = self:getFieldViewByPos(startPos)
   fieldViewTarget = self:getFieldViewByPos(toPos)
   table.insert(fieldViews,fieldViewStart)
   table.insert(fieldViews,fieldViewTarget)
   
   self._fieldView = fieldViews
   
   local cardsViews = {}
   local moveEnabledCardViewStart = self:getCardViewByCardPos(startPos)
   local moveEnabledCardViewTarget = self:getCardViewByCardPos(toPos)
   
   if moveEnabledCardViewStart ~= nil then
      table.insert(cardsViews,moveEnabledCardViewStart)
   end
   
   if moveEnabledCardViewTarget ~= nil then
      moveEnabledCardViewTarget:setDragEnabled(false)
      table.insert(cardsViews,moveEnabledCardViewTarget)
   end
   
   self._battleCardsView = cardsViews
   
   self._tipMove = GuideBattleView.new()
   self:addChild(self._tipMove,9999)
   self._tipMove:startMove(self:getPosByIndex(startPos),self:getPosByIndex(toPos))
   --hideButtons()
   self:showButtons(false)
end

function BattleFormationView:showButtons(visible)
  for key, btn in pairs(self._btns) do
  	btn:setVisible(visible)
  end
end

return BattleFormationView