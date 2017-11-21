require("view.BaseView")
require("view.component.ProgressBarView")
require("view.component.ItemSourceView")

CardSurmountView = class("CardSurmountView", BaseView)

function CardSurmountView:ctor(card, priority)
  CardSurmountView.super.ctor(self)

  --1. load levelup view ccbi
  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("closeCallback",CardSurmountView.closeCallback)
  pkg:addFunc("startSurmount",CardSurmountView.startSurmount)

  pkg:addProperty("layer_mask","CCLayerColor")
  pkg:addProperty("layer_mask2","CCLayerColor")

  pkg:addProperty("node_oldCard","CCNode")
  pkg:addProperty("node_newCard","CCNode")
  pkg:addProperty("node_info2","CCNode")
  pkg:addProperty("node_largeCard","CCNode")

  pkg:addProperty("bn_close","CCControlButton")
  pkg:addProperty("bn_surmount","CCControlButton")

  pkg:addProperty("sprite_cailiao1","CCSprite")
  pkg:addProperty("sprite_cailiao2","CCSprite")
  pkg:addProperty("sprite_cailiao3","CCSprite")
  pkg:addProperty("sprite_cailiao4","CCSprite")
  pkg:addProperty("sprite_wenhao1","CCSprite")
  pkg:addProperty("sprite_wenhao2","CCSprite")
  pkg:addProperty("sprite_wenhao3","CCSprite")
  pkg:addProperty("sprite_wenhao4","CCSprite")
  pkg:addProperty("sprite_beidongji","CCSprite")
  pkg:addProperty("sprite9_bg","CCScale9Sprite")

  pkg:addProperty("label_oldName","CCLabelTTF")
  pkg:addProperty("label_newName","CCLabelTTF")
  pkg:addProperty("info1_lv1","CCLabelTTF")
  pkg:addProperty("info1_lv2","CCLabelTTF")
  pkg:addProperty("info1_hp1","CCLabelTTF")
  pkg:addProperty("info1_hp2","CCLabelTTF")
  pkg:addProperty("info1_atk1","CCLabelTTF")
  pkg:addProperty("info1_atk2","CCLabelTTF")

  pkg:addProperty("info2_lv1","CCLabelTTF")
  pkg:addProperty("info2_lv2","CCLabelTTF")
  pkg:addProperty("info2_hp1","CCLabelTTF")
  pkg:addProperty("info2_hp2","CCLabelTTF")
  pkg:addProperty("info2_atk1","CCLabelTTF")
  pkg:addProperty("info2_atk2","CCLabelTTF")
  pkg:addProperty("info2_wu1","CCLabelTTF")
  pkg:addProperty("info2_wu2","CCLabelTTF")
  pkg:addProperty("info2_zhi1","CCLabelTTF")
  pkg:addProperty("info2_zhi2","CCLabelTTF")
  pkg:addProperty("info2_tong1","CCLabelTTF")
  pkg:addProperty("info2_tong2","CCLabelTTF")  
  pkg:addProperty("info2_beidong1","CCLabelTTF")
  pkg:addProperty("info2_beidong2","CCLabelTTF")

  pkg:addProperty("label_cailiao1","CCLabelTTF")
  pkg:addProperty("label_cailiao2","CCLabelTTF")
  pkg:addProperty("label_cailiao3","CCLabelTTF")
  pkg:addProperty("label_cailiao4","CCLabelTTF")
  pkg:addProperty("label_preCost","CCLabelTTF")
  pkg:addProperty("label_cost","CCLabelTTF")


  local layer,owner = ccbHelper.load("CardSurmountView.ccbi","CardSurmountViewCCB","CCLayer",pkg)
  self:addChild(layer)

  self.card = card 
  self.priority = priority or -128 

  net.registMsgCallback(PbMsgId.CardTurnbackResult, self, CardSurmountView.CardTurnbackResult)

  
end

function CardSurmountView:onEnter()
  if self.card == nil then 
    return 
  end 
  self.enhanceChangeFlag = false 

  self:init()
  self:showMidCardInfo1()
  _executeNewBird()
end 

function CardSurmountView:onExit()
  net.unregistAllCallback(self)

  --不允许放在这里更新，因为有可能会跳转到其他模块
  -- if self:getDelegate() then 
  --   if self.enhanceChangeFlag then 
  --     self:getDelegate():updateView()
  --   end 
  -- end 
end 

function CardSurmountView:init()
  _registNewBirdComponent(106011, self.bn_surmount)
  _registNewBirdComponent(106015, self.bn_close)

  self.label_preCost:setString(_tr("cost"))
  self.bn_close:setTouchPriority(self.priority)
  self.bn_surmount:setTouchPriority(self.priority)

  self.layer_mask:addTouchEventListener(function(event, x, y)

                                          local size = self.sprite9_bg:getContentSize()
                                          local pos = self.sprite9_bg:convertToNodeSpace(ccp(x, y))
                                          if pos.x < 0 or pos.x > size.width or pos.y < 0 or pos.y > size.height then 
                                            self:closeCallback()
                                          end 
                                          return true 
                                        end,
                                        false, self.priority+1, true)
  self.layer_mask:setTouchEnabled(true)
  --
  self.layer_mask2:addTouchEventListener(function(event, x, y)
                                          if self.layer_mask2:isVisible() and self.isSurmounting == false then 
                                            self.layer_mask2:setVisible(false)
                                            self.node_info2:setVisible(false)
                                            
                                            self:showMidCardInfo1()
                                            _executeNewBird() 
                                            return true 
                                          end 
                                          return false 
                                        end,
                                        false, self.priority-1, true)
  self.layer_mask2:setTouchEnabled(true)
end 

function CardSurmountView:showMidCardInfo1()
 
  
  self.layer_mask2:setVisible(false)
  self.node_info2:setVisible(false)

  --show mid-cards infos
  self.node_oldCard:removeAllChildrenWithCleanup(true)
  self.node_newCard:removeAllChildrenWithCleanup(true)

  local midCard1 = MiddleCardHeadView.new()
  midCard1:setCard({card = self.card})
  midCard1:setScale(135/midCard1:getContentSize().width)
  midCard1:setPosition(-midCard1:getContentSize().width/2, 0)
  midCard1:setNameVisible(false)
  self.node_oldCard:addChild(midCard1)
  self.label_oldName:setString(self.card:getName())


  local nextHp,nextAtk
  local curLevel = self.card:getLevel()
  local skill = self.card:getSkill()
  self.curWu = self.card:getStrengthByLevel(curLevel)
  self.curZhi = self.card:getIntelligenceByLevel(curLevel)
  self.curTong = self.card:getDominanceByLevel(curLevel)
  self.curHp = self.card:getHpByLevel(curLevel)
  self.curAtk = self.card:getAttackByLevel(curLevel)
  self.curMaxLevel = self.card:getMaxLevel()
  --被动技
  local pSkillId = AllConfig.unit[self.card:getConfigId()].talent 
  if pSkillId > 0 then 
    self.curPassiveSkill = AllConfig.cardskill[pSkillId].skill_level 
  end 

  --default 
  self.nextWu = self.curWu 
  self.nextZhi = self.curZhi 
  self.nextTong = self.curTong 
  self.nextHp = self.curHp 
  self.nextAtk = self.curAtk 
  self.nextPassiveSkill = self.curPassiveSkill 

  self.nextMaxLevel = self.curMaxLevel

  local oldConfigId = self.card:getConfigId()
  local target = AllConfig.combinesummary[oldConfigId]
  if target and target.target_type == 8 then 

    local tmpCard = clone(self.card)
    local skill = tmpCard:getSkill()
    tmpCard:setConfigId(target.target_item)
    self.nextWu = tmpCard:getStrengthByLevel(curLevel)
    self.nextZhi = tmpCard:getIntelligenceByLevel(curLevel)
    self.nextTong = tmpCard:getDominanceByLevel(curLevel)
    self.nextHp = tmpCard:getHpByLevel(curLevel)
    self.nextAtk = tmpCard:getAttackByLevel(curLevel)
    local pSkillId = AllConfig.unit[tmpCard:getConfigId()].talent 
    if pSkillId > 0 then 
      self.nextPassiveSkill = AllConfig.cardskill[pSkillId].skill_level 
    end 

    local midCard2 = MiddleCardHeadView.new()
    midCard2:setCard({card = tmpCard})
    midCard2:setPosition(-midCard2:getContentSize().width/2, 0)
    midCard2:setNameVisible(false)
    self.node_newCard:addChild(midCard2) 

    midCard2:setScale(1.2)
    midCard2:runAction(CCScaleTo:create(0.3, 135/midCard2:getContentSize().width))

    self.label_newName:setString(AllConfig.unit[target.target_item].unit_name)

    self.nextMaxLevel = AllConfig.unit[target.target_item].max_level 
  end 

  self.info1_lv1:setString(string.format("%d/%d", curLevel, self.curMaxLevel))
  self.info1_hp1:setString(string.format("%d", self.curHp))
  self.info1_atk1:setString(string.format("%d", self.curAtk))

  self.info1_lv2:setString(string.format("%d/%d", curLevel, self.nextMaxLevel))
  self.info1_hp2:setString(string.format("%d", self.nextHp))
  self.info1_atk2:setString(string.format("%d", self.nextAtk))


  self:showMatInfo(self.card) 
end 

function CardSurmountView:showLargeCardInfo2(isUpdateInfo, isAnim, animEndFunc)
  if isUpdateInfo == nil or isUpdateInfo == false then 
    self.layer_mask2:setVisible(true) 
    self.node_info2:setVisible(true) 

    self.node_largeCard:removeAllChildrenWithCleanup(true)

    self.LargeCard = CardHeadLargeView.new(self.card)
    self.LargeCard:setScale(480/self.LargeCard:getHeight())
    self.LargeCard:setPositionY(self.LargeCard:getScale()*self.LargeCard:getHeight()/2)
    self.node_largeCard:addChild(self.LargeCard) 
  end 

  local curLevel = self.card:getLevel()

  self.info2_lv1:setString(string.format("%d/%d", curLevel, self.curMaxLevel))
  self.info2_lv2:setString(string.format("%d/%d", curLevel, self.nextMaxLevel))
  self.info2_hp1:setString(string.format("%d", self.curHp))
  self.info2_hp2:setString(string.format("%d", self.nextHp))
  self.info2_atk1:setString(string.format("%d", self.curAtk))
  self.info2_atk2:setString(string.format("%d", self.nextAtk))
  self.info2_wu1:setString(string.format("%d", self.curWu))
  self.info2_wu2:setString(string.format("%d", self.nextWu))
  self.info2_zhi1:setString(string.format("%d", self.curZhi))
  self.info2_zhi2:setString(string.format("%d", self.nextZhi))  
  self.info2_tong1:setString(string.format("%d", self.curTong))
  self.info2_tong2:setString(string.format("%d", self.nextTong)) 

  if self.curPassiveSkill and self.curPassiveSkill > 0 then 
    self.sprite_beidongji:setVisible(true)
    self.info2_beidong1:setVisible(true)
    self.info2_beidong2:setVisible(true)
    self.info2_beidong1:setString(string.format("%d", self.curPassiveSkill))
    self.info2_beidong2:setString(string.format("%d", self.nextPassiveSkill))
  else 
    self.sprite_beidongji:setVisible(false)
    self.info2_beidong1:setVisible(false)
    self.info2_beidong2:setVisible(false)
  end 




  if isAnim then 
    self.node_info2:setScale(0.2)
    local x,y = self.node_info2:getPosition()
    self.node_info2:setPosition(ccp(x-50, y+40))

    local array = CCArray:create()
    -- array:addObject(CCMoveBy:create(0, ccp(-50, 40)))    
    array:addObject(CCEaseElasticInOut:create(CCMoveBy:create(1.0, ccp(50, -40))))
    array:addObject(CCCallFunc:create(function() self.layer_mask2:setVisible(true) end ))
    if animEndFunc then 
      array:addObject(CCCallFunc:create(animEndFunc))
    end 

    local act = CCSpawn:createWithTwoActions(CCSequence:create(array), CCEaseElasticInOut:create(CCScaleTo:create(1.0, 1.0), 0.3))
    self.node_info2:runAction(act)

    self.layer_mask2:setOpacity(0)
    self.layer_mask2:setVisible(true)
    self.layer_mask2:runAction(CCFadeTo:create(0.6, 220))
  end 
end 

function CardSurmountView:resetMaterialInfo()
  self.sprite_wenhao1:setVisible(true)
  self.sprite_wenhao2:setVisible(true)
  self.sprite_wenhao3:setVisible(true)
  self.sprite_wenhao4:setVisible(true)
  self.sprite_cailiao1:removeAllChildrenWithCleanup(true)
  self.sprite_cailiao2:removeAllChildrenWithCleanup(true)
  self.sprite_cailiao3:removeAllChildrenWithCleanup(true)
  self.sprite_cailiao4:removeAllChildrenWithCleanup(true)
  self.label_cailiao1:setString("")
  self.label_cailiao2:setString("")
  self.label_cailiao3:setString("")
  self.label_cailiao4:setString("")
  self.label_cost:setString("")
end 


function CardSurmountView:showMatInfo(card)
  if card == nil then 
    return 
  end

  self:setIsMatEnough(false)
  local combineSummary = AllConfig.combinesummary[card:getConfigId()]
  if combineSummary == nil then 
    echo("invalid combineSummary !!", card:getConfigId())
    return
  end 

  --clear
  self:resetMaterialInfo()

  if card:getGrade() == card:getMaxGrade() then 
    echo(" has reach the max grade.")
    return
  end

  self.coinCost = 0
  self.totalMeterialNum = 0
  self.consumeCardsArray = {}
  self.needMaterialArray = {}
  
  local iconSize = self.sprite_cailiao1:getContentSize()
  local pos = ccp(iconSize.width/2, iconSize.height/2)

  local materialNode = {self.sprite_cailiao1, self.sprite_cailiao2, self.sprite_cailiao3, self.sprite_cailiao4}
  local materialLabel = {self.label_cailiao1, self.label_cailiao2, self.label_cailiao3, self.label_cailiao4}
  local wenhaoArray = {self.sprite_wenhao1, self.sprite_wenhao2, self.sprite_wenhao3, self.sprite_wenhao4}

  local dataItem
  for k, v in pairs(combineSummary.consume) do 
    dataItem = v.array
    if dataItem[1] == 4 or dataItem[1] == 5 then 
      self.coinCost = dataItem[3]
    else 
      table.insert(self.needMaterialArray, {iType = dataItem[1], configId = dataItem[2], count = dataItem[3]})
    end 
  end 

  self.totalMeterialNum = #self.needMaterialArray
  self.label_cost:setString(""..self.coinCost)
  -- local color = self:getIsCoinEnough() and ccc3(69, 20, 1) or ccc3(201,1,1)
  -- self.label_cost:setColor(color)
  
  local function tipsCallback(obj, configId, pos)
    if obj and configId then 
      -- TipsInfo:showTip(obj, configId, nil, pos, nil, true)

      local view = ItemSourceView.new(configId, self.priority-2)
      self:addChild(view)
    end 
  end 

  --show materials info
  for k, v in pairs(self.needMaterialArray) do 
    local iconId, metNum, id, iconBgId = Enhance:instance():getIconNumByType(v.iType, v.configId, card:getId())
    local tipArgs = {callbackFunc=tipsCallback, priority = self.priority}
    local item = GameData:Instance():getCurrentPackage():getItemSprite(nil, v.iType, v.configId, 0, false, tipArgs)
    if item then 
      item:setPosition(ccp(materialNode[k]:getContentSize().width/2, materialNode[k]:getContentSize().height/2))
      materialNode[k]:addChild(item)
      wenhaoArray[k]:setVisible(false)

      if v.iType == 8 and id then 
        table.insert(self.consumeCardsArray, id)
      end 
    end 

    materialLabel[k]:setString(string.format("%d/%d", metNum, v.count)) 
    if metNum >= v.count then 
      materialLabel[k]:setColor(ccc3(32,143,0))
      self:setIsMatEnough(true)
    else 
      materialLabel[k]:setColor(ccc3(201,1,1))
      self:setIsMatEnough(false)
    end
  end 
end 

function CardSurmountView:setIsMatEnough(isEnough)
  self._isMatEnough = isEnough
end

function CardSurmountView:getIsMatEnough()
  return self._isMatEnough
end

function CardSurmountView:getIsCoinEnough()
  return GameData:Instance():getCurrentPlayer():getCoin() >= self.coinCost
end

function CardSurmountView:closeCallback()
  self:removeFromParentAndCleanup(true)
  _executeNewBird() 
end 

function CardSurmountView:startSurmount()

  if self.isSurmounting then 
    echo("is surmounting...")
    return 
  end 
  
  Guide:Instance():removeGuideLayer()
  
  if self.card == nil then 
    Toast:showString(self, _tr("please select card"), ccp(display.cx, display.cy))
    return
  end

  if self.card:getGrade() == self.card:getMaxGrade() then
    Toast:showString(self, _tr("card_has_max_grade"), ccp(display.cx, display.cy))
    return
  end

  if self:getIsMatEnough() == false then 
    Toast:showString(self, _tr("not enough material"), ccp(display.cx, display.cy))
    return
  end

  if self:getIsCoinEnough() == false then 
    Toast:showString(self, _tr("not enough coin"), ccp(display.cx, display.cy))
    return
  end

  local function reqToSurmount()
    echo(" reqToSurmount...")
    for i=1, table.getn(self.consumeCardsArray) do 
      echo(" consume id=", self.consumeCardsArray[i])
    end
    
    _showLoading()
    local data = PbRegist.pack(PbMsgId.CardTurnback, {config_id=self.card:getConfigId(), card_id=self.card:getId(), consume_id=self.consumeCardsArray})
    net.sendMessage(PbMsgId.CardTurnback, data)

    --show waiting
    --self.loading = Loading:show()
    self.isSurmounting = true  
    
     --backup battle ability for toast
    local battleCards = GameData:Instance():getCurrentPackage():getBattleCards()
    self.preBattleAbility = GameData:Instance():getBattleAbilityForCards(battleCards)   
  end

  --check leadship for battle card

  local isOnAnyBattleFormation,battleFormationIdxs = self.card:getHasBattleFormation()
  local canGradeUp = true
  local overflowFormationIdxs = {}
  if isOnAnyBattleFormation == true then
    local leadship = GameData:Instance():getCurrentPlayer():getLeadShip()    
    for key, battleFormationIdx in pairs(battleFormationIdxs) do
      local cards = BattleFormation:Instance():getBattleFormationCards(battleFormationIdx,BattleConfig.CardOwnerTypeSelf)
      local leadCost = 0
      for k,v in pairs(cards) do 
        leadCost = leadCost + v:getLeadCost()
      end 
      
      local targetId = AllConfig.combinesummary[self.card:getConfigId()].target_item
      leadCost = leadCost + AllConfig.unit[targetId].lead_cost - AllConfig.unit[self.card:getConfigId()].lead_cost
      print("battleFormationIdx:",battleFormationIdx,"leadCost:",leadCost,"leadship:",leadship)
      if leadCost > leadship then
        canGradeUp = false
        table.insert(overflowFormationIdxs,battleFormationIdx)
      end
    end
  end
  
  if canGradeUp == true then
    reqToSurmount()
  else
    local battleFormationStr = ""
    for key, IDX in pairs(overflowFormationIdxs) do
    	battleFormationStr = battleFormationStr.." ".._tr(IDX).." "
    end
    local pop = PopupView:createTextPopup(_tr("leadship_exceed%{battleidx}_after_surmounted2",{battleidx = battleFormationStr}), nil, true)
    self:addChild(pop)
  end
  
  
  --[[if self.card:getIsOnBattle() == true then 
    local leadship = GameData:Instance():getCurrentPlayer():getLeadShip()    
    local cartable = GameData:Instance():getCurrentPackage():getBattleCards()
    local leadCost = 0
    for k,v in pairs(cartable) do 
      leadCost = leadCost + v:getLeadCost()
    end 

    local targetId = AllConfig.combinesummary[self.card:getConfigId()].target_item
    leadCost = leadCost + AllConfig.unit[targetId].lead_cost - AllConfig.unit[self.card:getConfigId()].lead_cost
    if leadCost > leadship then
      local pop = PopupView:createTextPopup(_tr("leadship_exceed%{battleidx}_after_surmounted2"), nil, true)
      self:addChild(pop)
    else 
      reqToSurmount()
    end
  else 
    reqToSurmount()
  end]]
end 

function CardSurmountView:CardTurnbackResult(action,msgId,msg)
  echo("CardTurnbackResult:", msg.state)

--  if self.loading ~= nil then 
--    self.loading:remove()
--    self.loading = nil
--  end 
  _hideLoading()

  if msg.state == "Ok" then 
    self.enhanceChangeFlag = true 
    
    self.preGrade = self.card:getGrade()
    echo("================ pre grade:", self.card:getGrade(), self.card:getImproveGrade(), self.card:getConfigId())
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
    echo("================ after grade:", self.card:getGrade(), self.card:getImproveGrade(), self.card:getConfigId())

    self:playSurmountAnim()

    if self:getDelegate() then 
      if self.enhanceChangeFlag then 
        self:getDelegate():updateView()
      end 
    end 

  else 
    self.isSurmounting = false 

    if msg.state == "NeedMoreItem" then
      Toast:showString(self, _tr("not enough material"), ccp(display.cx, display.cy))
    else 
      Enhance:instance():handleErrorCode(msg.state)
    end 
  end 
end 

function CardSurmountView:playSurmountAnim()
  --setp 3. play star anim
  local function playStarAnim()
    if self.LargeCard ~= nil then 
      local card = self.LargeCard:getCard()      
      local animObj
      if self.preGrade < card:getGrade() then 
        animObj = self.LargeCard:getStarObj(card:getGrade())
      else 
        self.LargeCard:setSubRank(card:getConfigId())
        animObj = self.LargeCard:getSubRankLabel()
      end 

      if animObj ~= nil then 
        local function actEnd()
          echo("===========act end")
          self.LargeCard:setCard(card:getConfigId())
          self:showLargeCardInfo2(true)
          self:removeMaskLayer()
          GameData:Instance():getCurrentPlayer():toastBattleAbility(self.preBattleAbility)         
        end 
        local array = CCArray:create()
        array:addObject(CCScaleTo:create(0.5, 3.0))
        array:addObject(CCScaleTo:create(0.5, 1.0))
        array:addObject(CCCallFunc:create(actEnd))

        animObj:setVisible(true)
        animObj:runAction(CCSequence:create(array))
      end 
      
      self.isSurmounting = false 
    end
  end

  --setp 2. play round anim
  local function playRuondAnim()
    local anim,offsetX,offsetY,duration = _res(5020099)
    if anim ~= nil then
      -- local nodeSize = self.LargeCard:getContentSize()
      local scale = self.LargeCard:getScale()
      anim:setPosition(ccp(0, 250))
      self.node_largeCard:addChild(anim)
      anim:getAnimation():play("default")

      self:performWithDelay(function ()
                              anim:removeFromParentAndCleanup(true)
                              playStarAnim()
                            end, duration*0.9)
    else 
      self:removeMaskLayer()
    end
  end

  local function showInfoAndPlayRoundAnim()  
    self:showLargeCardInfo2(false, true, playRuondAnim)
  end 


  --setp 1. play eat anim
  if self.totalMeterialNum ~= nil then 
    local duration_time = 0
    local spriteArray = {self.sprite_cailiao1, self.sprite_cailiao2, self.sprite_cailiao3, self.sprite_cailiao4}
    for i=1, self.totalMeterialNum do 
      local anim,offsetX,offsetY,duration = _res(5020100)
      if anim ~= nil then
        self:addChild(anim)
        duration_time = duration
        local pos = spriteArray[i]:getParent():convertToWorldSpace(ccp(spriteArray[i]:getPosition()))
        anim:setPosition(pos)
        anim:getAnimation():play("default")

        self:performWithDelay(function ()
                                anim:removeFromParentAndCleanup(true)
                                echo("remove animation")
                                self:resetMaterialInfo()
                                showInfoAndPlayRoundAnim()
                              end, duration)
      end
    end

    if duration_time > 0 then 
      self:addMaskLayer()
    end 
  end
end

function CardSurmountView:addMaskLayer()
  echo("=== addMaskLayer")
  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
  end 

  self.maskLayer = Mask.new({opacity=0, priority = -1000})
  self:addChild(self.maskLayer)

  self.maskLayerTimer = self:performWithDelay(handler(self, CardSurmountView.removeMaskLayer), 6.0)
end 

function CardSurmountView:removeMaskLayer()
  echo("=== removeMaskLayer")
  if self.maskLayerTimer then 
    self:stopAction(self.maskLayerTimer)
    self.maskLayerTimer = nil 
  end 

  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
    self.maskLayer = nil 
  end 

--  if self.loading ~= nil then 
--    self.loading:remove()
--    self.loading = nil
--  end  
end 
