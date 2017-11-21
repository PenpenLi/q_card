require("model.battle.Battle")
require("model.battle.BattleCard")
require("view.battle.BattleCardMoveEffect")
require("view.battle.BattleCardAttackEffect")
require("view.battle.BattleCardDamageView")
require("view.battle.BattleCardSkillView")
require("view.battle.BattleCardStatusView")
require("view.battle.BattleCardEnhanceView")
require("view.battle.BattleDialogueView")


local speed = 1.0

BattleCardView = class("BattleCardView",function()
    return display.newNode()
end)

local mScaleX = 1
local function fitSize(spt,width,height)
  local size = spt:getContentSize()
  local scaleX = width / size.width
  local scaleY = height / size.height
  if scaleX < scaleY then 
    scaleY = scaleX
  else 
    scaleX = scaleY 
  end
  
  spt:setScale(scaleX)
  mScaleX = scaleX
end

function BattleCardView:ctor()
	self:setNodeEventEnabled(true)
	self:setCascadeOpacityEnabled(true)
	self:setDragEnabled(true)
	self:setUseSkillCount(0)
	self:setIsGhostState(false)
	self:setIsPlayedNormalAttackDialogue(false)
	self:setIsPlayedUseSkillDialogue(false)
	self:setIsPlayedEnterTurnDialogue(false)
end

function BattleCardView:init(card)
  local unit = AllConfig.unit[card:getConfigId()]
  if unit == nil then
    printf("Can not found unit by id:%d",card:getConfigId())
    assert(false)
    return
  end

  local isOpsite = self:setGroupView(card:getGroup())
  self._isOpsite = isOpsite
  -- add card
  local nodeCard = display.newNode()
  nodeCard:setCascadeOpacityEnabled(true)
  self:addChild(nodeCard)
  self._nodeCard = nodeCard
    
    -- out frame
  local nodeColor = nil
  if isOpsite == true then
    nodeColor = _res(3034004)
  else
    nodeColor = _res(3034003)
  end
  self._nodeCard:addChild(nodeColor)
  self._nodeColor = nodeColor
  self:hideOutFrame()
  
    -- add frame
  local sptFrame = nil
  --sptFrame = _res(3021041 + unit.card_rank)
  local grade = unit.card_rank + 1
  local subGrade = unit.card_improve
  local smoothGrade = math.max(0, (grade-3)*3) + grade-1 + subGrade 
  
  
  sptFrame = _res(3022072 + smoothGrade)
  assert(sptFrame ~= nil)
  fitSize(sptFrame,100,100)
  self._nodeCard:addChild(sptFrame)  

  local sptCard = _res(unit.battle_head)
  echo(unit.battle_head)
  assert(sptCard ~= nil)
  fitSize(sptCard,150,150)
  sptCard:setPositionY(20)
  self._nodeCard:addChild(sptCard)
  
  if isOpsite == true then
    sptCard:setFlipX(true)
  end
  self._headCard = sptCard
  
  -- add frame top
  local sptFrameTop = nil
  sptFrameTop = _res(3022083 + smoothGrade)
  assert(sptFrameTop ~= nil)
  fitSize(sptFrameTop,100,100)
  self._nodeCard:addChild(sptFrameTop)  
  
  self:setContentSize(CCSizeMake(100,100))
  
  local largeCardContainer = display.newNode()
  
  --style1
  --[[local mask = DSMask:createMask(CCSizeMake(300,300))
  mask:setPositionX(-300/2)
  --mask:setPositionY(-((self:getContentSize().height/3)*2-13))
  mask:setPositionY(-85/2)
  self:addChild(mask)
  mask:addChild(largeCardContainer)
  largeCardContainer:setPositionX(300/2)
  largeCardContainer:setPositionY((self:getContentSize().height/3)*2)
  --largeCardContainer:setPositionY(-(self:getContentSize().height/3)*2)]]
  
  
  --style2
  self:addChild(largeCardContainer)
  largeCardContainer:setPositionY(20)
  
  local lscale = 1.0
  largeCardContainer:setScaleY(lscale)
  if isOpsite == true then
    lscale = -lscale
  end
  largeCardContainer:setScaleX(lscale)
  
  self._largeCardContainer = largeCardContainer

--    -- add frame
--  local sptFrame = nil
--  --sptFrame = _res(3021041 + unit.card_rank)
--  sptFrame = _res(3080114 + unit.card_rank)
--  assert(sptFrame ~= nil)
--  fitSize(sptFrame,100,100)
--  self._nodeCard:addChild(sptFrame)  

  local statusView = BattleCardStatusView.new()
--  self._effectNode:addChild(statusView)
  self._nodeCard:addChild(statusView)
  self._statusView = statusView
  
  -- add frame corner
  local sptFrameCorner = nil
  sptFrameCorner = _res(3022011 + unit.card_rank)
  assert(sptFrameCorner ~= nil)
  --sptFrameCorner:setPosition(ccp(29,-26))
  sptFrameCorner:setPosition(ccp(-39,-36))
  fitSize(sptFrameCorner,30,30)
  self._nodeCard:addChild(sptFrameCorner)  
  
--  local angryFullView = _res(5020019)
--  angryFullView:setPosition(ccp(29,-26))
--  self:addChild(angryFullView)
--  angryFullView:getAnimation():play("default") 
--  self._angryFullView = angryFullView
--  --self:setShowingAngryFull(false)
  local angryViewNode = display.newNode()
  --angryViewNode:setPosition(ccp(29,-26))
  angryViewNode:setPosition(ccp(-39,-36))
  self:addChild(angryViewNode)
  self._angryViewNode = angryViewNode

  
  local nodeIcon = display.newNode()
  --nodeIcon:setPosition(ccp(28,-28))
  nodeIcon:setPosition(ccp(-38,-38))
  nodeIcon:setCascadeOpacityEnabled(true)
  self._nodeCard:addChild(nodeIcon)
  self._nodePrimary = nodeIcon

  if card:getIsPrimary() == true then
    local sptPrimary = nil
  	if isOpsite then
  		sptPrimary = _res(3025009)
  	else
  		sptPrimary = _res(3025010)
  	end
    sptPrimary:setPosition(ccp(3,70))
    nodeIcon:addChild(sptPrimary)
    self._sptPrimary = sptPrimary
  end
  
  -- add hp bar node
  local nodeHp = display.newNode()
  nodeHp:setPosition(ccp(0,-52))
  nodeHp:setCascadeOpacityEnabled(true)
  self:addChild(nodeHp)
  self._nodeHp = nodeHp
  -- hp outframe
  local sptHpFrame = nil
  if isOpsite == false then
    sptHpFrame = _res(3025002)
  else
    sptHpFrame = _res(3025002)
  end
  nodeHp:addChild(sptHpFrame)
  
  -- tween hp bar
  self._tweenHpBar =  _res(3025012)
  self._tweenHpBar:setPosition(ccp(-43,0))
  self._tweenHpBar:setAnchorPoint(ccp(0.0,0.5))
  nodeHp:addChild(self._tweenHpBar)
  
  -- hp bar
  local sptHp = nil
  if isOpsite == true then
    sptHp = _res(3025003)
  else
    sptHp = _res(3025001)
  end
  sptHp:setAnchorPoint(ccp(0.0,0.5))
  sptHp:setPosition(ccp(-43,0))
  nodeHp:addChild(sptHp)
  self._sptHp = sptHp
  
  local enhanceView = BattleCardEnhanceView.new(self)
  enhanceView:setPosition(ccp(40,40))
  nodeIcon:addChild(enhanceView)
  self._enhanceView = enhanceView
  
  local effectNode = display.newNode()
  if self:getParent() ~= nil then
    self:getParent():addChild(effectNode,999)
  end
  self._effectNode = effectNode
  self._effectNode:setPosition(self:getPosition())
  
    -- add troop icon
  local sptIcon = nil
  assert(card:getType() ~= nil,"Invalid card:getType() should not be nil")
  sptIcon = _res(PbTroopSpt[card:getType()])

  if sptIcon ~= nil then  
    fitSize(sptIcon,18,20)
    --sptIcon:setFlipX(isOpsite)
    nodeIcon:addChild(sptIcon)
  end
  self._troopIcon = sptIcon
  
  
  local skillView = BattleCardSkillView.new()
  self._effectNode:addChild(skillView)
  self._skillView = skillView
  

  
  local damageView = BattleCardDamageView.new()
  self._effectNode:addChild(damageView)
  self._damageView = damageView
  
  self._card = card
  self._card:setView(self)
  self:updateCardView(card)
  
  if card:getIsBoss() == true then
     self._nodeHp:setVisible(false)
  end
  
  local fieldEffectNode = display.newNode()
  fieldEffectNode:setPosition(enhanceView:getPosition())
  nodeIcon:addChild(fieldEffectNode)
  self._fieldEffectNode = fieldEffectNode
  
  --local unitEffectIcon = display.newSprite("img/test_img/test_battle_plus.png")
  local unitEffectIcon = _res(3059047)
  self._nodeCard:addChild(unitEffectIcon)
  unitEffectIcon:setPosition(-45,45)
  self._unitEffectIcon = unitEffectIcon
  unitEffectIcon:setVisible(false)
  
--  local scheduler = CCDirector:sharedDirector():getScheduler()
--  self._update_entry = scheduler:scheduleScriptFunc(handler(self,BattleCardView.update), 1.0/10, false)
end

function BattleCardView:setGroupView(group)
  
  local isOpsite = false
  if group == BattleConfig.BattleSide.Blue then
    isOpsite = false
    self:setActionSign(1)
  else
    isOpsite = true
    self:setActionSign(-1)
  end
  self:setIsOpsite(isOpsite)
  
  return isOpsite
end

function BattleCardView:playActionDialogue(battle,battleView,actionType)
  --actionType: 1 normal attack 2 use skill 3 enter turn
  if battle:getFightType() == "PVE_NORMAL" then --or battle:getIsLocalPlay() == true 
     local stage = Scenario:Instance():getUnPassedLastStage()
     local dialogues = {}
     if stage ~= nil then
        local stageId = stage:getStageId()
        assert(AllConfig.dialogue ~= nil,"dialoge data error")
        for key, dialogue in pairs(AllConfig.dialogue) do
            if  dialogue.stage_id == stageId
            and dialogue.side == self:getData():getOriginalGroup()
            and dialogue.card_id == self:getData():getUnitRoot()
            and dialogue.type == 2
            and dialogue.time == actionType
            then
               table.insert(dialogues,dialogue)
            end
        end
     end
     
     local sortDialogues = function(a,b)
        if a.order == b.order then
           return a.id < b.id
        end
        return a.order < b.order
     end
     
     if #dialogues > 0 then
        table.sort(dialogues,sortDialogues)
        battleView:cameraReset()
        for i = 1, #dialogues do
          local dialogue = BattleDialogueView.new(dialogues[i])
          battleView:addChild(dialogue,3000)
          dialogue:pause()
          
          if actionType == BattleConfig.ActionTypeNormalAttack then
            self:setIsPlayedNormalAttackDialogue(true)
          elseif actionType == BattleConfig.ActionTypeUseSkill then
            self:setIsPlayedUseSkillDialogue(true)
          elseif actionType == BattleConfig.ActionTypeEnterTurn then
            self:setIsPlayedEnterTurnDialogue(true)
          end
        end
     end
     
  end
end

function BattleCardView:getIsPlayedDialogueByActionType(actionType)
  if actionType == BattleConfig.ActionTypeNormalAttack then
    return self:getIsPlayedNormalAttackDialogue()
  elseif actionType == BattleConfig.ActionTypeUseSkill then
    return self:getIsPlayedUseSkillDialogue()
  elseif actionType == BattleConfig.ActionTypeEnterTurn then
    return self:getIsPlayedEnterTurnDialogue()
  else
    return true
  end
end

------
--  Getter & Setter for
--      BattleCardView._IsPlayedNormalAttackDialogue 
-----
function BattleCardView:setIsPlayedNormalAttackDialogue(IsPlayedNormalAttackDialogue)
	self._IsPlayedNormalAttackDialogue = IsPlayedNormalAttackDialogue
end

function BattleCardView:getIsPlayedNormalAttackDialogue()
	return self._IsPlayedNormalAttackDialogue
end

------
--  Getter & Setter for
--      BattleCardView._IsPlayedUseSkillDialogue 
-----
function BattleCardView:setIsPlayedUseSkillDialogue(IsPlayedUseSkillDialogue)
	self._IsPlayedUseSkillDialogue = IsPlayedUseSkillDialogue
end

function BattleCardView:getIsPlayedUseSkillDialogue()
	return self._IsPlayedUseSkillDialogue
end

------
--  Getter & Setter for
--      BattleCardView._IsPlayedEnterTurnDialogue 
-----
function BattleCardView:setIsPlayedEnterTurnDialogue(IsPlayedEnterTurnDialogue)
	self._IsPlayedEnterTurnDialogue = IsPlayedEnterTurnDialogue
end

function BattleCardView:getIsPlayedEnterTurnDialogue()
	return self._IsPlayedEnterTurnDialogue
end

------
--  Getter & Setter for
--      BattleCardView._DragEnabled 
-----
function BattleCardView:setDragEnabled(DragEnabled)
  self._DragEnabled = DragEnabled
end

function BattleCardView:getDragEnabled()
  return self._DragEnabled
end


function BattleCardView:onCleanup()
  echo("BattleCardView:onCleanup()")
--  local scheduler = CCDirector:sharedDirector():getScheduler()
--  scheduler:unscheduleScriptEntry(self._update_entry)
end

function BattleCardView:onBeginBattle(battle,battleView)
  self:updateCardView(self._card)
  self:playFieldEffect(battle,battleView)
end

function BattleCardView:showUnitEffect(isShow)
  local show = isShow or false
  self._unitEffectIcon:setVisible(show)
end


--function BattleCardView:showTip()
--  if self._tipPic == nil then
--     local unitType = self:getData():getType()
--     print("unitType：",unitType,AllConfig.unittype[unitType].resource)
--     self._tipPic = _res(AllConfig.unittype[unitType].resource)
--     self:addChild(self._tipPic,100)
--     self._tipPic:setPositionY(72)
--     self._tipPic:runAction(CCFadeIn:create(0.8))
--     self:setZOrder(99)
--  end
--end
--
--function BattleCardView:hideTip()
--  if self._tipPic ~= nil then
--     local array = CCArray:create()
--     array:addObject(CCFadeOut:create(0.5)) 
--     array:addObject(CCRemoveSelf:create())
--     local action = CCSequence:create(array)
--     self._tipPic:runAction(action)
--     self._tipPic = nil
--  end
--end

function BattleCardView:update(dt)
  self._effectNode:setPosition(self:getPosition())
end

function BattleCardView:getData()
  return self._card
end

function BattleCardView:updateCardView()
  local card = self._card
  local percent = card:getHp()/card:getMaxHp()
  print("====percent", percent)
  -- assert(percent >= 0 and percent <= 1.1,string.format("Invalid percent:%f",percent))
  self._sptHp:setScaleX(percent)
  
  self._tweenHpBar:stopAllActions()
  --play tween hp bar
  local array = CCArray:create()
  array:addObject(CCDelayTime:create(0.2))
  array:addObject(CCScaleTo :create(0.2,percent,1))
  local action = CCSequence:create(array)
  self._tweenHpBar:runAction(action)
  
  local angry_percent = card:getAngry()/card:getMaxAngry()
  
  local currentAngry = card:getAngry()
  self._angryViewNode:removeAllChildrenWithCleanup(true)

  local angryAnimation = nil 
  if currentAngry > 0 and currentAngry < 50 then
    angryAnimation = _res(5020193)
    assert(angryAnimation ~= nil)
  elseif currentAngry >= 50 and currentAngry < 75 then
    angryAnimation = _res(5020194)
    assert(angryAnimation ~= nil)
  elseif currentAngry >= 75 and currentAngry < 100 then
    angryAnimation = _res(5020195)
    assert(angryAnimation ~= nil)
  elseif currentAngry >= 100 then
    angryAnimation = _res(5020196)
    assert(angryAnimation ~= nil)
  end
  
  if angryAnimation ~= nil then
     self._angryViewNode:addChild(angryAnimation)
     angryAnimation:getAnimation():play("default") 
  end

  if card:getAngry() == card:getMaxAngry() then
    self:setShowingAngryFull(true)
  else
    self:setShowingAngryFull(false)
  end
  
  if self._sptPrimary ~= nil then
    self._sptPrimary:setVisible(card:getIsPrimary())
  else
    if card:getIsPrimary() == true then
      local sptPrimary = nil
      if self._isOpsite then
        sptPrimary = _res(3025009)
      else
        sptPrimary = _res(3025010)
      end
      sptPrimary:setPosition(ccp(3,70))
      self._nodePrimary:addChild(sptPrimary)
      self._sptPrimary = sptPrimary
    end
  end
  
end

function BattleCardView:execEnterTurnEvent(battle,battleView,info)
  self._effectNode:setPosition(self:getPosition())
--  local duration = 1.06 * speed * CONFIG_DEFAULT_ANIM_DELAY_RATIO
  local duration = 0.06 * speed * CONFIG_DEFAULT_ANIM_DELAY_RATIO
  self:wait(duration)
end

function BattleCardView:execAlivekEvent(battle,battleView,info)
  local card = battle:getCardByIndex(info.card_index)
  printf("card[index = %d,pos = %d] change live state to:%s",info.card_index,card:getPos(),info.state)
  if info.state == "CardAliveStateDead" then
    self:playDead(battle,battleView,info)
  elseif info.state == "CardAliveStateAlive" then
    if info.isChangeGroup == true then
      self:playDead(battle,battleView,info)
    end
    self:playAlive()
  else
    assert(false)
  end
end

function BattleCardView:execSkillDamageEvent(battle,battleView,info)
  
  if info.damage_type == PbDamageType.DamageMiss then
    local durattion = self:playMiss()
    self:wait(durattion)
  else
    self:playOnDamage(info.damage,info.damage_type,1)
    if info.damage_type == PbDamageType.DamageCure then
      -- do nothing
    else
      local durattion = self:shake(battle,battleView)
      self:wait(durattion)
    end

  end

  self:updateCardView()
end

function BattleCardView:execChangeStatusEvent(battle,battleView,info)
  if info.status_id == 0 then
    self:playChangeProperty(info.action,info.property_id,info.property_type)
  else
    self:playChangeStatus(info.action,info.status_id)
  end
end

function BattleCardView:execDropItemEvent(battle,battleView,info)
end

function BattleCardView:playExtraEffect(battle,battleView,effect_id)
  local sptWord = nil
  
  if effect_id == PbExtraEffectId.Reduce then
    sptWord = _res(3033005)
    self._damageView:showWords(sptWord)
  elseif effect_id == PbExtraEffectId.Reflect then
    sptWord = _res(3033006)
    self._damageView:showWords(sptWord)
  elseif effect_id == PbExtraEffectId.React then
    sptWord = _res(3033007)
    self._damageView:showWords(sptWord)
  elseif effect_id == PbExtraEffectId.Resist then
    sptWord = _res(3033003)
    self._damageView:showWords(sptWord)
  elseif effect_id == PbExtraEffectId.Shield then
    sptWord = _res(3033008)
    self._damageView:showWords(sptWord)
  elseif effect_id == PbExtraEffectId.Immune then
    sptWord = _res(3033004)
    self._damageView:showWords(sptWord)
  elseif effect_id == PbExtraEffectId.Shake then
    battleView:shake(1.0)
--    local d = self:shake(battle,battleView,12.0)
  elseif effect_id == PbExtraEffectId.Restriction then
--    local array = CCArray:create()
--    array:addObject(CCScaleTo :create(0.2,1.3))
--    array:addObject(CCScaleTo :create(0.2,1))
--    local action = CCSequence:create(array)
--    self:runAction(action)
    
  elseif effect_id == PbExtraEffectId.BeRestriction then
--    local array = CCArray:create()
--    array:addObject(CCDelayTime:create(0.3))
--    array:addObject(CCScaleTo :create(0.2,0.7))
--    array:addObject(CCScaleTo :create(0.2,1))
--    local action = CCSequence:create(array)
--    self:runAction(action)

      --local playBeRestrictionEffect = function()
         local beRestrictionAnimation,offsetX,offsetY = _res(5020142)
         beRestrictionAnimation:setPosition( ccp(offsetX,offsetY))
         beRestrictionAnimation:getAnimation():play("default") 
         self._effectNode:addChild(beRestrictionAnimation,999)
      --end
      
      --self:performWithDelay(playBeRestrictionEffect,0.2)
  elseif effect_id == PbExtraEffectId.DoubleAngry then
     self:showAngryUp()
  elseif effect_id == PbExtraEffectId.ReduceAngry then
     self:showAngryLow()
  end
  
end

function BattleCardView:playFieldEffect(battle,battleView)
  self._fieldEffectNode:removeAllChildrenWithCleanup(true)
  self._attackUp = nil
  
  local field = battle:getFieldByIndex(self._card:getPos())
  local targetCard = self._card
  if field ~= nil then
    local territoryId = field:getType() * 1000 + targetCard:getType()
    local territory = AllConfig.territoryeffect[territoryId]
    if territory ~= nil then
      local count = table.nums(territory.prop)
      if count ~= 0 then
         local sptEffect = _res(3025011)
        self._damageView:addChild(sptEffect)
        sptEffect:setPosition(ccp(-25,20))
        sptEffect:setScale(0.1)
        local time = 0.8
        local exploidTime = time * 0.5
        local moveTime = time * 0.5
        local array = CCArray:create()
        local exploid = CCEaseBounceOut:create(CCScaleTo:create(exploidTime,1.2))
        array:addObject(exploid)
        local fadeOut = CCEaseOut:create(CCFadeOut:create(moveTime),0.1)
        local move = CCMoveBy:create(moveTime,ccp(0,50))
        local spawn = CCSpawn:createWithTwoActions(fadeOut,move)
        array:addObject(spawn)
        array:addObject(CCRemoveSelf:create())
        local action = CCSequence:create(array)
        sptEffect:runAction(action)
        
        local attackUp = _res(3031001)
        
        local height = 32
        local count = self._enhanceView:getCount()
        attackUp:setPosition(ccp(43,-count * height + height))
        self._fieldEffectNode:addChild(attackUp)
        self._attackUp = attackUp
      end
    end
  end
end

function BattleCardView:updateFieldEffectPosition()
   if self._attackUp ~= nil then
     if self._enhanceView:getPropertyAtkIconPosition() ~= nil then
        self._attackUp:setPosition(self._enhanceView:getPropertyAtkIconPosition())
     end
  end
end

function BattleCardView:onFinishPlayEvent(battle)
  printf("BattleCardView:onFinishPlayEvent")
  local event_loop = battle:getEventLoop()
  if event_loop ~= nil then
    printf(coroutine.status(event_loop))
    local success,error = coroutine.resume(event_loop)
    if not success then
      printf("event loop error:"..error)
      print(debug.traceback(event_loop, error)) 
    end
  else
    printf("event_loop is nil")
  end
end


function BattleCardView:onEnter()
  printf("BattleCardView:onEnter")
  
end

function BattleCardView:onExit()
  printf("BattleCardView:onExit")
end

function BattleCardView:wait(duration)
  local cur = coroutine.running()
  self:performWithDelay(function () 
  local success,error = coroutine.resume(cur)
    if not success then
      printf("coroutine error:"..error)
      print(debug.traceback(cur, error)) 
    end
  end,duration)
  coroutine.yield()

end

function BattleCardView:playMove(card,cardView,battle,battleView,from,to)
  BattleCardMoveEffect[card:getType()](card,cardView,battle,battleView,from,to)
end

function BattleCardView:playShift(battle,battleView,from,to)
  local duration = 0.2 * speed * CONFIG_DEFAULT_ANIM_DELAY_RATIO
  local array = CCArray:create()
  array:addObject(CCEaseOut:create(CCMoveTo:create(duration,to),0.1))
  array:addObject(CCCallFunc:create(function ()
    self._shaking = false
    local origin = battleView:getPosByIndex(self._card:getPos())
    self:setPosition(origin)
  end))  
  local action = CCSequence:create(array)
  self:runAction(action)
  self:wait(duration)
end

function BattleCardView:playClash(card,cardView,battle,battleView,from,to)
  local duration = 0.1 * speed * CONFIG_DEFAULT_ANIM_DELAY_RATIO
  local array = CCArray:create()
  local move = CCMoveTo:create(duration,to)
  array:addObject(move)
  local action = CCSequence:create(array)
  cardView:runAction(action)
  cardView:wait(duration)
end

function BattleCardView:playAttackSrc(fromcard,forceMelee,battle,battleView)
  return --[[self:playAttackLargeCardEffect() + ]]BattleCardAttackEffect[fromcard:getType()].execSrcAnim(fromcard,self,battle,battleView,forceMelee)
end

function BattleCardView:playAttackDst(fromcard,target,targetView,forceMelee,battle,battleView)
  return BattleCardAttackEffect[fromcard:getType()].execDstAnim(fromcard,target,targetView,battle,battleView,forceMelee)
end

function BattleCardView:playAttackLargeCardEffect()
  local duration = 0
  --local largePortrait = _res(self:getData():getUnitPic())
  local largePortrait = _res(self:getData():getBattlePic())
  if largePortrait == nil then
    return duration
  end
  self:setZOrder(99)
  --largePortrait:setAnchorPoint(ccp(0.5,0))
  --largePortrait:setPosition(ccp(0,0))
  --self._headCard:setVisible(false)
    
  self._largeCardContainer:removeAllChildrenWithCleanup(true)
  self._largeCardContainer:addChild(largePortrait)
  
--  local scale = 1.0
--  largePortrait:setScale(scale)
--  
  local zoomIn = 0.30
  local zoomOut = 0.25
  duration = zoomIn
  local array = CCArray:create()
  array:addObject(CCScaleTo:create(zoomIn,1.15,1.15))
  array:addObject(CCScaleTo:create(zoomOut,1.0,1.0))
  --array:addObject(CCDelayTime:create(0.1))
  array:addObject(CCCallFunc:create(function ()
    largePortrait:removeFromParentAndCleanup(true)
    --self._headCard:setVisible(true)
  end))
  local action = CCSequence:create(array)
  largePortrait:runAction(action)
  
  return duration
  
  --self:performWithDelay(callback,delay)
end

function BattleCardView:playAttackAnim(animId,is_flip_y)
  local armature_duration = self._skillView:playAttackAnim(animId,self,is_flip_y)
  return armature_duration
end

--[[function BattleCardView:playEffectAnim(skill_effect_id)
  local skillEffect = AllConfig.skilleffect[skill_effect_id]
  if skillEffect ~= nil then
    local duration = self._skillView:playEffectAnim(skillEffect,self)
    return duration
  end
end--]]

function BattleCardView:playMiss(battle,battleView)
  local sign = self:getActionSign()
  local time = 0.35
  local move_time = time * 0.5
  local distanceX = 25
  local distanceY = 0
  local array = CCArray:create()
  local move = CCMoveBy:create(move_time,ccp(sign * distanceX,-distanceY))
  local fade = CCFadeTo:create(move_time,100)
  local spawn = CCSpawn:createWithTwoActions(move,fade)
  local ease = CCEaseOut:create(spawn,0.2)
  array:addObject(ease)
  
  local move_back = CCMoveBy:create(move_time,ccp(sign * -distanceX,distanceY))
  local fade_back = CCFadeTo:create(move_time,255)
  local spawn_back = CCSpawn:createWithTwoActions(move_back,fade_back)
  local ease_back = CCEaseOut:create(spawn_back,0.2)
  array:addObject(ease_back)
  
  array:addObject(CCCallFunc:create(function ()
    local origin = battleView:getPosByIndex(self._card:getPos())
    self:setPosition(origin)
  end))
  local action = CCSequence:create(array)
  self:runAction(action)
  
  return time
end

function BattleCardView:playOnDamage(damage,damageType,damage_times)
  if damageType == PbDamageType.DamageBlock then
    _playSnd(SFX_BLOCK)
  end
  
  if damage_times == nil or damage_times == 0 then
    damage_times = 1
  end
  if damage_times ~= 1 then
    local sub_damage = damage / damage_times
    local delayTime = 0
    local delaySubDuration = 0.08
    for i=1, damage_times do
    	self._damageView:onDamage(sub_damage,damageType,delayTime,true)
    	delayTime = delayTime + delaySubDuration
    end
    local battleView = self:getParent()
    battleView:shake(1.0,damage_times)
    
    -- 0 fllow card 1 on same pos
    local showStyle = 0
    
    local line = self:getData():getPos()%4
    local offsetX = 0
    if line == 3 then
      offsetX = - 70
    end
    local startPos = ccp(self:getPositionX() + offsetX,self:getPositionY())
    local endPos = ccp(self:getPositionX() + offsetX,self:getPositionY() - 15)
    if showStyle > 0 then
       startPos = ccp(display.width + 200,display.cy)
       endPos = ccp(display.cx + 160,display.cy)
    end
    --show hit
    self._currentHit = 0
    local updateHit = function()
      if self._totalDamage ~= nil then
        self._currentHit = self._currentHit + 1
        if self._currentHit > damage_times then
          self._totalDamage:unschedule(self._timer)
          local array = CCArray:create()
          local delay = CCDelayTime:create(0.85)
          array:addObject(delay)
          
--          local moveAction = CCMoveTo:create(0.25,startPos)
--          array:addObject(moveAction)
          
          local callFunc = CCCallFunc:create(function()
            self._totalDamage:removeFromParentAndCleanup(true)
            self._totalDamage = nil
            self._hitLabel = nil
          end)
          array:addObject(callFunc)
          --array:addObject(CCRemoveSelf:create())
          local action = CCSequence:create(array)
          self._totalDamage:runAction(action)
        else
          --show hit 
          if self._hitLabel == nil then
            local hitLabel = CCLabelBMFont:create(self._currentHit.."", "client/widget/words/card_name/combin_number.fnt")
            self._hitLabel = hitLabel
            self._totalDamage:addChild(hitLabel)
            hitLabel:setPosition(ccp(5,0))
          else
            self._hitLabel:setString(self._currentHit.."")
          end
        end
      end
    end
    
    if self._totalDamage == nil then
      local totalDamage = display.newNode()
      totalDamage:setNodeEventEnabled(true)
      self._totalDamage = totalDamage
      
      battleView:addChild(totalDamage,1999)
      totalDamage:setPosition(startPos)
      
      local action = CCMoveTo:create(0.1,endPos)
      totalDamage:runAction(action)
      local totalDamageStr = _res(3022095)
      totalDamageStr:setPosition(ccp(-40,-50))
      totalDamage:addChild(totalDamageStr)
      
      local hitStr = _res(3022094)
      hitStr:setPosition(ccp(60,0))
      totalDamage:addChild(hitStr)
      
      local totalDamageValue = CCLabelBMFont:create("", "client/widget/words/battle_number/battle_number_red.fnt")
      totalDamage:addChild(totalDamageValue)
      totalDamageValue:setAnchorPoint(ccp(0,0.5))
      totalDamageValue:setPosition(ccp(totalDamageStr:getContentSize().width/2 + totalDamageStr:getPositionX() + 5,-45))
      totalDamageValue:setString(string.format("%d",damage))
      
      self._timer = totalDamage:schedule(updateHit,0.10)
    end
    
    updateHit()
      
    
  else
    self._damageView:onDamage(damage,damageType)
  end
end

function BattleCardView:playChangeStatus(changeAction,status)
  if changeAction == "Add" then
    self._statusView:addStatus(status)
  elseif changeAction == "Remove" then
    self._statusView:removeStatus(status)
  end
end

function BattleCardView:playChangeProperty(changeAction,property_id,property_type)
  if changeAction == "Add" then
    self._enhanceView:addProperty(property_id,property_type)
  elseif changeAction == "Remove" then
    self._enhanceView:removeProperty(property_id,property_type)
  end
end

function BattleCardView:playSkillInfo(skillInfo)
  
  local anim_duration = 1.0
  if self:getData():getIsPrimary() == true then
    return  anim_duration
  end
  
  local effectStyle = 2
    -- skill words
  local node = display.newNode()
  node:setCascadeOpacityEnabled(true)

  if effectStyle == 1 then
    node:setPosition(ccp(-40,0))
    self:addChild(node)
    local sptBg = _res(3034001)
    sptBg:setScale(1.2)
    node:addChild(sptBg)
    
    local label = CCLabelTTF:create(skillInfo.skill_name,"fzcyjt",22)
    label:setDimensions(CCSize(25,130))
    node:addChild(label)
    
    local array = CCArray:create()
    local fadeIn = CCEaseOut:create(CCFadeIn:create(anim_duration * 0.2),0.2)
    array:addObject(fadeIn)
    local delay = CCDelayTime:create(anim_duration * 0.6)
    array:addObject(delay)
    local fadeOut = CCEaseOut:create(CCFadeOut:create(anim_duration * 0.2),0.2)
    array:addObject(fadeOut)
    local remove = CCRemoveSelf:create()
    array:addObject(remove)
    local action = CCSequence:create(array)
    node:runAction(action)
  elseif effectStyle == 2 then
    self:getParent():addChild(node,4000)
    
--    local sptBg = display.newSprite("test_img/test02.png")
--    node:addChild(sptBg)
    
    local skillName = CCLabelBMFont:create(skillInfo.skill_name, "client/widget/words/card_name/battle_skillname.fnt")
    node:addChild(skillName)
    assert(skillName ~= nil)
    
    local offsetY = -50
    local moveDuration = 0.15
    local stayDuration = 0.25
    
    
    if self:getData():getGroup() == BattleConfig.BattleSide.Blue then
      node:setPositionX(display.width)
    end
    node:setPositionY(self:getPositionY() + offsetY)
    local array = CCArray:create()
    --local fadeIn = CCEaseOut:create(CCFadeIn:create(anim_duration * 0.2),0.2)
    --array:addObject(fadeIn)
    
    local move = CCMoveTo:create(anim_duration * moveDuration,ccp(self:getPositionX(),self:getPositionY()+ offsetY))
    array:addObject(move)
    local delay = CCDelayTime:create(anim_duration * stayDuration)
    array:addObject(delay)
    local fadeOut = CCEaseOut:create(CCFadeOut:create(anim_duration * 0.2),0.2)
    array:addObject(fadeOut)
    local remove = CCRemoveSelf:create()
    array:addObject(remove)
    local action = CCSequence:create(array)
    node:runAction(action)
    self:wait(anim_duration * (moveDuration + stayDuration))
  elseif effectStyle == 3 then
    self:getParent():addChild(node,4000)
    
    local sptBg = display.newSprite("test_img/test01.png")
    node:addChild(sptBg)
    sptBg:setPosition(display.cx,display.cy)
    local array = CCArray:create()
    local fadeIn = CCEaseOut:create(CCFadeIn:create(anim_duration * 0.2),0.2)
    array:addObject(fadeIn)
    local delay = CCDelayTime:create(anim_duration * 0.6)
    array:addObject(delay)
    local fadeOut = CCEaseOut:create(CCFadeOut:create(anim_duration * 0.2),0.2)
    array:addObject(fadeOut)
    local remove = CCRemoveSelf:create()
    array:addObject(remove)
    local action = CCSequence:create(array)
    node:runAction(action)
    self:wait(anim_duration * 0.4)
  end
  
  return anim_duration
end

function BattleCardView:playShadow()
  --local shadow = CcbiAnim.new("anim_CardAppear.ccbi","anim_CardAppear")
  
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("mAnimationManager","CCBAnimationManager")
  pkg:addProperty("spritePr1","CCSprite")
  pkg:addProperty("spritePr2","CCSprite")
  --pkg:addFunc("time_distance",function() end)
  local ccbiAnimation,owner = ccbHelper.load("anim_CardAppear.ccbi","anim_CardAppear","CCNode",pkg)
  self:addChild(ccbiAnimation)
  
  local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(self._headCard.frameName)
  
  local f = ccBlendFunc()
  f.src = GL_ONE
  f.dst = GL_ONE
   
  owner.spritePr1:setDisplayFrame(spriteFrame)
  owner.spritePr1:setBlendFunc(f)
  owner.spritePr2:setDisplayFrame(spriteFrame)
  owner.spritePr2:setBlendFunc(f)
  
  local sequenceName = owner.mAnimationManager:getRunningSequenceName()
  local duration = owner.mAnimationManager:getSequenceDuration(sequenceName)
 
  self:performWithDelay(function () 
    owner.mAnimationManager = nil
    ccbiAnimation:removeFromParentAndCleanup(true)
  end,duration)
end

------
--  Getter & Setter for
--      BattleCardView._UseSkillCount 
-----
function BattleCardView:setUseSkillCount(UseSkillCount)
	self._UseSkillCount = UseSkillCount
end

function BattleCardView:getUseSkillCount()
	return self._UseSkillCount
end

function BattleCardView:playPreUseSkill(skillInfo,battleView)
    local duration = 0
    local finishedPlayPreSkill = function()
      self._preUseSkillAnim:removeFromParentAndCleanup(true)
    end
    
    local pkg = ccbRegisterPkg.new(self)
    pkg:addFunc("play_end",finishedPlayPreSkill)
    pkg:addProperty("nodeHeader","CCSprite")
    pkg:addProperty("sprite_bg_orange","CCNode")
    pkg:addProperty("sprite_bg_blue","CCNode")
    pkg:addProperty("labelSkillName1","CCLabelBMFont")
    pkg:addProperty("labelSkillName2","CCLabelBMFont")
    
    
    pkg:addProperty("mAnimationManager","CCBAnimationManager")
    local layer,owner = ccbHelper.load("anim_CommanderShow.ccbi","BattleEffectCCB","CCLayer",pkg)
    battleView:addChild(layer,4000)
    self._preUseSkillAnim = layer
    local sequenceName = self.mAnimationManager:getRunningSequenceName()
    duration = self.mAnimationManager:getSequenceDuration(sequenceName)
    
    self.labelSkillName1:setString(skillInfo.skill_name)
    self.labelSkillName2:setString(skillInfo.skill_name)
    
    print("duration:",duration)

    if self:getData():getGroup() == BattleConfig.BattleSide.Blue then
       self.sprite_bg_orange:setVisible(false)
       self.sprite_bg_blue:setVisible(true)
    elseif self:getData():getGroup() == BattleConfig.BattleSide.Red then
       self.sprite_bg_orange:setVisible(true)
       self.sprite_bg_blue:setVisible(false)
    end
    
    local resId = self:getData():getUnitPic()
    if resId > 0 then
       local res = _res(resId)
       if res ~= nil then
          self.nodeHeader:addChild(res)
       end
    end
    --local skillEffect = AllConfig.skilleffect[skillInfo.skill_effect_id]
    --local anim,offsetX,offsetY,d,isFlipY = _res(skillEffect.self_effect)
    return duration
end

function BattleCardView:playUseSkill(skillInfo)
  _playSnd(SFX_SKILL_CAST)
  
  self:setUseSkillCount(self:getUseSkillCount() + 1)
  self:playSkillInfo(skillInfo)
  if self:getData():getMaxGrade() >= 4 then
    local largeEffect_duration = self:playAttackLargeCardEffect()
    self:wait(largeEffect_duration)
  end
  local armature_duration = self._skillView:playSrcSkillAnim(skillInfo,self)
  return armature_duration --[[+ largeEffect_duration]]
end

function BattleCardView:playSufferSkill(skillInfo)
  return self._skillView:playDstSkillAnim(skillInfo,self)
end

function BattleCardView:playAlive()
  
  local sptDead,offsetX,offsetY,duration = _res(7010074)
  sptDead:setPosition(ccp(offsetX,offsetY))
  self:addChild(sptDead,99)
  sptDead:getAnimation():play("default") 
  
  --local duration = 0.3 * speed * CONFIG_DEFAULT_ANIM_DELAY_RATIO
  local array = CCArray:create()
  array:addObject(CCShow:create())
  array:addObject(CCFadeIn:create(duration))
  local action = CCSequence:create(array)
  self._nodeCard:runAction(action)
  self:setZOrder(99)

  self:wait(duration)
  
  self._nodeHp:setVisible(not self:getData():getIsBoss())
  --self._angryFullView:setVisible(true)
  self._angryViewNode:setVisible(true)
  self._effectNode:setVisible(true)
  self._statusView:setVisible(true)
  self._fieldEffectNode:setVisible(true)
end

function BattleCardView:playDead(battle,battleView,info)
  _playSnd(SFX_UNIT_DEAD)
  
  self._nodeHp:setVisible(false)
  --self._angryFullView:setVisible(false)
  self._angryViewNode:setVisible(false)
  self._effectNode:setVisible(false)
  self._statusView:setVisible(false)
  self._fieldEffectNode:setVisible(false)
  
  local deadDelay = 0
  local sptDead = nil
  local duration = 1.16 --* CONFIG_DEFAULT_ANIM_DELAY_RATIO -- ccb animation duration
  local deadStrDuration = 0
  
  -- dead animation
  if self:getData():getIsPrimary() == true and info.canRevive == false and self:getIsGhostState() == false  then
    local pkg = ccbRegisterPkg.new(self)
    pkg:addFunc("play_end",function() end)
    pkg:addProperty("mAnimationManager","CCBAnimationManager")
    local layer,owner = ccbHelper.load("anim_CommaderDead.ccbi","CommaderDeadCCB","CCLayer",pkg)
    layer:setPosition(self:getPosition())
    battleView:addChild(layer,3000)
    sptDead = layer
  else
    local m_sptDead,offsetX,offsetY,d = _res(5020015)
    m_sptDead:setPosition(ccp(offsetX,offsetY))
    self:addChild(m_sptDead,99)
    m_sptDead:getAnimation():play("default") 
    sptDead = m_sptDead
    duration = d
  end
  
  -- screen zoom effect
  if self:getData():getIsPrimary() == true and info.canRevive == false and self:getIsGhostState() == false then  
    --local m_sptDeadStr,offsetX,offsetY,d = _res(5020162)
    --deadStrDuration = d
    local playDeadStrAnim = function()
      local resId = 5020162
      if battle:getSelfIsAttacker() == true then
         if self:getData():getOriginalGroup() == BattleConfig.BattleSide.Blue then
           resId = 5020163
         else
           resId = 5020162
         end
      else
         if self:getData():getOriginalGroup() == BattleConfig.BattleSide.Blue then
           resId = 5020162
         else
           resId = 5020163
         end
      end
      
      local m_sptDeadStr,offsetX,offsetY,d = _res(resId)
      battleView:addChild(m_sptDeadStr,2000)
      m_sptDeadStr:setPosition(ccp(offsetX + display.cx,offsetY + display.cy))
      m_sptDeadStr:getAnimation():play("default") 
    end
    
    local pos = battleView:getPosByIndex(self:getData():getPos())
    battleView:setAnchorPoint(ccp(pos.x/display.width,pos.y/display.height))
    
    local stayDuration = 1.25 * speed
    local scaleDuration = duration * 0.35 
    local scaleBackDuration = duration * 0.5
    
    -- zoom in
    local zoomInArray = CCArray:create()
    local to = ccp(display.cx - pos.x,display.cy - pos.y)
    local scale = CCEaseSineInOut:create(CCScaleTo:create(scaleDuration,3.0))
    local move = CCEaseSineInOut:create(CCMoveTo:create(scaleDuration,to))
    zoomInArray:addObject(CCSpawn:createWithTwoActions(move,scale))
    local actionZoomIn = CCSequence:create(zoomInArray)
    
    --zoom out
    local zoomOutArray = CCArray:create()
    local scaleBack = CCEaseSineOut:create(CCScaleTo:create(scaleBackDuration,1.0))
    local moveBack = CCEaseSineOut:create(CCMoveTo:create(scaleBackDuration,ccp(0,0)))
    zoomOutArray:addObject(CCSpawn:createWithTwoActions(scaleBack,moveBack))
    zoomOutArray:addObject(CCCallFunc:create(playDeadStrAnim)) 
    local actionZoomOut = CCSequence:create(zoomOutArray)
    local scaleBack = CCSequence:createWithTwoActions(CCDelayTime:create(stayDuration),actionZoomOut)
    
    local sequence = CCSequence:createWithTwoActions(actionZoomIn,scaleBack)
    battleView:runAction(sequence)
    
    deadDelay = scaleDuration + stayDuration + scaleBackDuration + deadStrDuration
  end
  
  local duration2 = 0.4 * speed * CONFIG_DEFAULT_ANIM_DELAY_RATIO
  local array = CCArray:create()
  array:addObject(CCFadeOut:create(duration2 * 0.7))
  array:addObject(CCHide:create())
  local action = CCSequence:create(array)
  self._nodeCard:runAction(action)
  
  self:wait(duration + deadDelay)
  
  sptDead:removeFromParentAndCleanup(true)
  
end

function BattleCardView:showAngryLow(group)
    local spt,offsetX,offsetY = _res(3033009)  
    spt:setPosition(ccp(0,20))
    spt:setZOrder(99)
    self._effectNode:addChild(spt)
    local duration = 0.6 * speed
    local array = CCArray:create()
    array:addObject(CCMoveBy:create(duration,ccp(0,-20)))
    array:addObject(CCRemoveSelf:create())
    local action = CCSequence:create(array)
    spt:runAction(action)
    
    self:setShowingAngryFull(false)
    self:wait(duration*0.5)
    
end

function BattleCardView:showAngryUp()
    local spt,offsetX,offsetY = _res(3033011)  
    spt:setPosition(ccp(0,20))
    spt:setZOrder(99)
    self._effectNode:addChild(spt)
    local duration = 0.6 * speed
    local array = CCArray:create()
    array:addObject(CCMoveBy:create(duration,ccp(0,20)))
    array:addObject(CCRemoveSelf:create())
    local action = CCSequence:create(array)
    spt:runAction(action)   
end

function BattleCardView:getOnFieldView(battle,battleView)
  if battleView == nil then
     battleView = self:getParent()
  end
  return battleView:getFieldView(self._card:getPos())
  
end

function BattleCardView:shake(battle,battleView,s)
  if self._shaking == nil then
    self._shaking = false
  end
  if self._shaking == true then
    return 0
  end
  local duration = 0.4 * speed 
  local gap = 0.3 * speed
  local strength = s or 6.0
  local times = 2
  local target = self
  local array = CCArray:create()
  local s_duration = duration/(times * 2)
  local origin = battleView:getPosByIndex(self._card:getPos())
  local origin_x,origin_y = origin.x,origin.y
--  print("origin_x:"..origin_x..",origin_y:"..origin_y)
  for i=1, times do
    local s_x =  strength + math.random(strength * 100)/100.0
    local s_y =  strength + math.random(strength * 100)/100.0
    array:addObject(CCMoveBy:create(s_duration,ccp(s_x,s_y)))
    array:addObject(CCMoveBy:create(s_duration,ccp(-s_x,-s_y)))
  end
  array:addObject(CCCallFunc:create(function ()
    self._shaking = false
    local origin = battleView:getPosByIndex(self._card:getPos())
    self:setPosition(origin)
  end))
  
  local action = CCSequence:create(array)
  target:runAction(action)
  --return duration + gap
  return 0
end

function BattleCardView:showOutFrame()
  self._nodeColor:setVisible(true)
end

function BattleCardView:hideOutFrame()
  self._nodeColor:setVisible(false)
end

function BattleCardView:showAsGhost()
  --self._nodeCard:setOpacity(125)
  self._nodeCard:runAction(CCFadeTo:create(0.15,125))
  self._nodeHp:setVisible(false)
  self:setIsGhostState(true)
end

------
--  Getter & Setter for
--      BattleCardView._IsGhostState 
-----
function BattleCardView:setIsGhostState(IsGhostState)
	self._IsGhostState = IsGhostState
end

function BattleCardView:getIsGhostState()
	return self._IsGhostState
end

------
--  Getter & Setter for
--      BattleCardView._ActionSign 
-----
function BattleCardView:setActionSign(ActionSign)
	self._ActionSign = ActionSign
end

function BattleCardView:getActionSign()
	return self._ActionSign
end

------
--  Getter & Setter for
--      BattleCardView._IsOpsite 
-----
function BattleCardView:setIsOpsite(IsOpsite)
	self._IsOpsite = IsOpsite
end

function BattleCardView:getIsOpsite()
	return self._IsOpsite
end

------
--  Getter & Setter for
--      BattleCardView._ShowingAngryFull 
-----
function BattleCardView:setShowingAngryFull(ShowingAngryFull)
  self._ShowingAngryFull = ShowingAngryFull
  
  --self._angryFullView:setVisible(ShowingAngryFull)
end

function BattleCardView:getShowingAngryFull()
  return self._ShowingAngryFull
end

