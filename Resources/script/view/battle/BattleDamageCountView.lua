BattleDamageCountView = class("BattleDamageCountView",BaseView)
function BattleDamageCountView:ctor(normal_fight_result_msg,isReview,isBattleTest)
  self:setNodeEventEnabled(true)
  self._result_msg = normal_fight_result_msg
  self._isBattleTest = isBattleTest or false
  local battle_cards = {}
  local p_cards = self._result_msg.cards
  for key, p_card in pairs(p_cards) do
    local battleCard = BattleCard.new()
    battleCard:accept(p_card)
    battle_cards[key] = battleCard
    --print("Name:",battleCard:getName(),"DamageBear:",battleCard:getDamageBear(),"DamageOut:",battleCard:getDamageOut())
  end
  self._battle_cards = battle_cards
  self._isReview = isReview or false
  self:setTouchEnabled(true)
  self:addTouchEventListener(function() return true end,false,-128,true)
  
  
  local myCards = {}
  local targetCards = {}
  
  local maxDamageOut = 0
  local maxDamageBear = 0 
  
  for key, card in pairs(self._battle_cards) do
    if card:getDamageOut() > maxDamageOut then
       maxDamageOut = card:getDamageOut()
    end
    
    if card:getDamageBear() > maxDamageBear then
      maxDamageBear = card:getDamageBear()
    end
    
    if card:getGroup() == BattleConfig.BattleSide.Blue then
      table.insert(myCards,card)
    else
      table.insert(targetCards,card)
    end
    
  end
  self._maxDamageOut = maxDamageOut
  self._maxDamageBear = maxDamageBear
  
  self._myCards = myCards
  self._targetCards = targetCards
  
  local listLong = #targetCards
  if #myCards > #targetCards then
     listLong = #myCards
  end
  self._listLong = listLong
  
  self._isShowDamageOut = true
  
end

function BattleDamageCountView:onEnter()
      
  local pkg = ccbRegisterPkg.new(self)
  
  pkg:addProperty("node_container","CCNode")
  pkg:addProperty("title_damage_out","CCNode")
  pkg:addProperty("title_damage_bear","CCNode")
  pkg:addProperty("spriteArrow","CCSprite")
  pkg:addProperty("btnDamageOut","CCMenuItemSprite")
  pkg:addProperty("btnDamageBear","CCMenuItemSprite")
  pkg:addProperty("btnClose","CCMenuItemSprite")
  
  pkg:addFunc("damageOutHandler",BattleDamageCountView.damageOutHandler)
  pkg:addFunc("damageBearHandler",BattleDamageCountView.damageBearHandler)
  pkg:addFunc("closeHandler",BattleDamageCountView.closeHandler)
  
  --color layer
  local layerColor = CCLayerColor:create(ccc4(0,0,0,185), display.width, display.height)
  self:addChild(layerColor)

  local layer,owner = ccbHelper.load("battle_damage_count.ccbi","battle_damage_count","CCLayer",pkg)
  self:addChild(layer)
  self._ccbLayer = layer 
  
  local pos = ccp(self.spriteArrow:getPositionX(),self.spriteArrow:getPositionY())
  local anim = CCSequence:createWithTwoActions(CCMoveTo:create(0.2, ccp(pos.x,pos.y + 8)), CCMoveTo:create(0.4, pos))
  self.spriteArrow:runAction(CCRepeatForever:create(anim))

  self:buildList()
  
  if self._isReview == true then
    self.btnClose:setVisible(false)
  
    local closeBtn = UIHelper.ccMenuWithSprite(display.newSprite("#battle_result_close_nor.png"),
            display.newSprite("#battle_result_close_sel.png"),
            display.newSprite("#battle_result_close_sel.png"),
            function()
              if self._isBattleTest == true and UserLogin.gameExit ~= nil then
               UserLogin:gameExit()
               return
              end
              
              if BattleReportShare:Instance():getIsFromChat() == true then
                BattleReportShare:Instance():setIsFromChat(false)
                local controller = ControllerFactory:Instance():create(ControllerType.HOME_CONTROLLER)
                controller:enter()
                local chatView = ChatView.new(Chat.ChannelWorld)
                GameData:Instance():getCurrentScene():addChildView(chatView)  
              elseif BattleReportShare:Instance():getReviewFightType() == "PVP_NORMAL" then
                local expeditionController = ControllerFactory:Instance():create(ControllerType.EXPEDITION_CONTROLLER)
                expeditionController:setIsChallenge(false)
                expeditionController:enter()
              elseif BattleReportShare:Instance():getReviewFightType() == "PVE_NORMAL" then
                local controller = ControllerFactory:Instance():create(ControllerType.SCENARIO_CONTROLLER)
                controller:enter()
              else
                local controller = ControllerFactory:Instance():create(ControllerType.PVP_RANK_MATCH_CONTROLLER)
                controller:enter()
                controller:showReports()
              end
            end)
    self:addChild(closeBtn)
    closeBtn:setPositionX(display.cx + 90)
    closeBtn:setPositionY(display.cy - 360)
    
    local replayBtn = UIHelper.ccMenuWithSprite(display.newSprite("#battle_result_damage_btn_replay_nor.png"),
            display.newSprite("#battle_result_damage_btn_replay_sel.png"),
            display.newSprite("#battle_result_damage_btn_replay_sel.png"),
            function()
              if ControllerFactory:Instance():getCurrentControllerType() ==  ControllerType.BATTLE_CONTROLLER then
                 local battleController = ControllerFactory:Instance():getCurController()
                 if battleController ~= nil then
                    local battle = battleController:getBattle()
                    battleController:startReviewBattleWithResult(self._result_msg)
                 end
              end
              
            end)
    self:addChild(replayBtn)
    replayBtn:setPositionX(display.cx - 90)
    replayBtn:setPositionY(display.cy - 360)
    
  end
end

function BattleDamageCountView:onExit()
  
end

function BattleDamageCountView:buildList()
    self.btnDamageBear:setEnabled(true)
    self.btnDamageOut:setEnabled(true)
    if self._isShowDamageOut == true then
      self.title_damage_out:setVisible(true)
      self.title_damage_bear:setVisible(false)
      --self.btnDamageOut:selected()
      self.btnDamageOut:setEnabled(false)
      self.btnDamageBear:unselected()
    else
      self.title_damage_out:setVisible(false)
      self.title_damage_bear:setVisible(true)
      self.btnDamageOut:unselected()
      --self.btnDamageBear:selected()
      self.btnDamageBear:setEnabled(false)
    end
    
    if self._scrollView ~= nil then
       self._scrollView:reloadData()
       return
    end

    local function scrollViewDidScroll(view)
        
    end
  
    local function scrollViewDidZoom(view)
    end
  
    local function tableCellTouched(table,cell)
      
    end
  
    local function cellSizeForTable(table,idx)
      return 85,590
    end
  
    local function tableCellAtIndex(table, idx)
      local cell = table:cellAtIndex(idx)
      if nil == cell then
        cell = CCTableViewCell:new()
      else
        cell:removeAllChildrenWithCleanup(true)
      end
      
      local myCard = self._myCards[idx+1]
      if myCard ~= nil then
        local cardInfoView = self:buildCardInfoView(myCard)
        cell:addChild(cardInfoView)
        cardInfoView:setPositionX(50)
      end
      
      local targetCard = self._targetCards[idx+1]
      if targetCard ~= nil then
        local cardInfoView = self:buildCardInfoView(targetCard)
        cell:addChild(cardInfoView)
        cardInfoView:setPositionX(590/2+50+40)
      end
      return cell
    end
  
    local function numberOfCellsInTableView(val)
      return self._listLong 
    end
    
    --build tableview
    local size = self.node_container:getContentSize()
    self._scrollView = CCTableView:create(size)
    self._scrollView:setDirection(kCCScrollViewDirectionVertical)
    self._scrollView:setVerticalFillOrder(kCCTableViewFillTopDown)
    --registerScriptHandler functions must be before the reloadData function
    --self._scrollView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
    --self._scrollView:registerScriptHandler(scrollViewDidZoom,CCTableView.kTableViewZoom)
    self._scrollView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
    self._scrollView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    self._scrollView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
    self._scrollView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
    self._scrollView:reloadData()
    self._scrollView:setTouchPriority(-256)
    self.node_container:addChild(self._scrollView)
end

function BattleDamageCountView:damageOutHandler()
  if self._isShowDamageOut == true then
    return
  end

  self._isShowDamageOut = true
  self:buildList()
end

function BattleDamageCountView:damageBearHandler()
  if self._isShowDamageOut == false then
    return
  end
  
  self._isShowDamageOut = false
  self:buildList()
end

function BattleDamageCountView:closeHandler()
  self:removeFromParentAndCleanup(true)
end

function BattleDamageCountView:buildCardInfoView(card)
  local cardNode = display.newNode()
  local cardView = BattleCardView.new()
  cardNode:addChild(cardView)
  cardView:init(card)
  cardView:setScale(0.8)
  if card:getGroup() == BattleConfig.BattleSide.Red then
     cardView:setPositionX(160)
  end
  cardView:setPositionY(35)
  cardView._nodeHp:setVisible(false)
  
  --build progress bar
  local bg = CCSprite:createWithSpriteFrameName("battle_result_damage_progress_bg.png")
  local fg1 = nil
  
  if card:getGroup() == BattleConfig.BattleSide.Red then
    fg1 = CCSprite:createWithSpriteFrameName("battle_result_damage_progress_red.png")   
  else
    fg1 = CCSprite:createWithSpriteFrameName("battle_result_damage_progress_green.png") 
  end
  
  local progressBar = ProgressBarView.new(bg, fg1)
  progressBar:setLabelEnabled(false)
  progressBar:setAnchorPoint(ccp(0,0))
  local posX = 40
  if card:getGroup() == BattleConfig.BattleSide.Red then
    progressBar:setScaleX(-1)
    posX = 115
  end
  progressBar:setPosition(posX,5)
  progressBar:setPercent(0)
  progressBar:setFullPercentCallback(function() end)
  cardNode:addChild(progressBar)
  
  local label = CCLabelBMFont:create("0", "client/widget/words/card_name/number_skillup.fnt")
  --local labelSize = tolua.cast(label:getContentSize(),"CCSize")  
  --label:setPosition(ccp(40+labelSize.width/2, 47+labelSize.height/2))
  if card:getGroup() == BattleConfig.BattleSide.Red then
    label:setPosition(ccp(35, 47))
  else
    label:setPosition(ccp(135, 47))
  end
  
  cardNode:addChild(label)
  
  cardNode.label = label
  
  local damageFact = 0
  local damageMax = 0
  if self._isShowDamageOut == true then
    damageFact = card:getDamageOut()
    damageMax = self._maxDamageOut
  else
    damageFact = card:getDamageBear()
    damageMax = self._maxDamageBear
  end
  
  local percent = damageFact/damageMax * 100
  if percent > 0 then
     local pice_num = math.floor(math.ceil(damageFact/1000) + 0.5)
     local numCount = 0
  
     progressBar:setUpdateCallback(function()
        label:setString(numCount.."")
        numCount = numCount + pice_num
     end)
     
     progressBar:startProgressing(function() label:setString(damageFact.."") end,0,percent)
  else
     label:setString("0")
  end
  
  
  return cardNode
end

return BattleDamageCountView