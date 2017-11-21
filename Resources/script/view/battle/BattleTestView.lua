require("model.battle.Battle")
require("model.battle.BattleCard")
require("view.battle.BattleCardDamageView")
require("view.battle.BattleCardSkillView")
require("view.battle.BattleCardStatusView")
require("view.battle.BattleCardEnhanceView")

BattleTestView = class("BattleTestView", BaseView)


function BattleTestView:ctor()
  local card = self:newCard(14050401,BattleConfig.BattleSide.Red)
  local cardView = BattleCardView.new(card)
  cardView:setPosition(ccp(320,880))
  self:addChild(cardView,99)
  cardView:init(card)
  cardView:setActionSign(-1)
  self._cardview1 = cardView
  
  local card = self:newCard(14050401,BattleConfig.BattleSide.Blue)
  local cardView = BattleCardView.new(card)
  cardView:setPosition(ccp(320,880 - 100))
  self:addChild(cardView,99)
  cardView:init(card)
  
  local skillNode = display.newNode()
  self:addChild(skillNode)
  self._skillNode = skillNode
  
  self._cardview2 = cardView
  self._startResId = 7010001
  self._startBtn =  UIHelper.ccMenu("test_img/mission-button-nor-shuaxin.png","test_img/mission-button-sel-shuaxin.png",function(pSender)
--   self:onPlaySkill(250301)
--    self:onPlaySkill(450101)
--      self:onPlaySkill(250801)
--    self:playAnim(5020059)
--    self:playParticular()
--    self:playSequence()
 --   self:playCcbiAnim()
      self:addCcbiAnimSkill()
  end)
  self._startBtn:setPosition(display.cx - 200,100)
  self:addChild(self._startBtn)
  
  self._startBtn =  UIHelper.ccMenu("test_img/mission-button-nor-shuaxin.png","test_img/mission-button-sel-shuaxin.png",function(pSender)
   self:onPlaySkill2(250301)
  end)
  self._startBtn:setPosition(display.cx ,100)
  self:addChild(self._startBtn)
  
  local arrays = {450101,250301}
  local count = 0
  self._startBtn =  UIHelper.ccMenu("test_img/mission-button-nor-shuaxin.png","test_img/mission-button-sel-shuaxin.png",function(pSender)
   self:playAnim(arrays[count%2 + 1])
   count = count + 1
  end)
  self._startBtn:setPosition(display.cx + 200,100)
  self:addChild(self._startBtn)
  
  local ani = _res(7010015)
  assert(ani ~= nil)
  self:addChild(ani)
  ani:setPosition(ccp(display.cx,display.cy))
  ani:getAnimation():play("default")
  
  
  self:addCcbiAnimLayer()
end

function BattleTestView:onPlaySkill(skill_id)
  local skillInfo = AllConfig.cardskill[skill_id]
  
  if skillInfo ~= nil then
    local duration = 0
    duration = self._cardview1:playUseSkill(skillInfo)
    self:performWithDelay(function () 
      local suffer__skill_duration = self._cardview2:playSufferSkill(skillInfo)
    end,duration)
  end
end

function BattleTestView:onPlaySkill2(skill_id)
  local skillInfo = AllConfig.cardskill[skill_id]
  if skillInfo ~= nil then
    local duration = self._cardview2:playUseSkill(skillInfo)
    self:performWithDelay(function () 
      local suffer__skill_duration = self._cardview1:playSufferSkill(skillInfo)
    end,duration)
  end
end

function BattleTestView:playAnim(id)
   local anim,offsetX,offsetY = _res(id)
   anim:setPosition(ccp(320 + offsetX,480 + offsetY))
   self:addChild(anim)
   anim:getAnimation():play("default")
end

function BattleTestView:playParticular()
  local node = display.newNode()
  node:setPosition(ccp(320 ,480 ))
  node:setCascadeOpacityEnabled(true)
  self:addChild(node)
  
--  local particle = CCParticleSystemQuad:create("img/client/particle/02.plist");
  local particle,offsetX,offsetY,duration = _res(6010001)
  particle:setPosition(ccp(offsetX,offsetY))
  node:addChild(particle)
  
  local time = 1.618
  local array = CCArray:create()
  local fadeOut = CCEaseOut:create(CCFadeOut:create(time),0.1)
  local move = CCEaseOut:create(CCMoveBy:create(time,ccp(0,300)),0.1)
  local spawn = CCSpawn:createWithTwoActions(fadeOut,move)
  array:addObject(spawn)
  array:addObject(CCRemoveSelf:create())
  local action = CCSequence:create(array)
  node:runAction(action)
  
end

function BattleTestView:addCcbiAnimSkill()
  --[[local animationOwener = {}
  local pkg = ccbRegisterPkg.new(animationOwener)
  pkg:addProperty("mAnimationManager","CCBAnimationManager")
  pkg:addFunc("time_distance",function() end)
  local skillAnimation,owner = ccbHelper.load("skill_bow_src.ccbi","skill_bow_src","CCNode",pkg)
  self:addChild(skillAnimation)
  --animationOwener.mAnimationManager:runAnimationsForSequenceNamedTweenDuration(animationOwener.mAnimationManager:getRunningSequenceName(),0)
  local sequenceName = animationOwener.mAnimationManager:getRunningSequenceName()
  local sequenceDur = animationOwener.mAnimationManager:getSequenceDuration(sequenceName)
  
  print("getRunningSequenceDur:",sequenceDur)]]
  
  self._skillNode:removeAllChildrenWithCleanup(true)
  print("play:",self._startResId)
  local anim,offsetX,offsetY,duration = _res(self._startResId)
  self._skillNode:addChild(anim)
  anim:setPosition(ccp(offsetX + display.cx,offsetY + display.cy))
  anim:getAnimation():play("default")  
  print("duration:",duration)
  
  self._startResId = self._startResId + 1
  
end

function BattleTestView:addCcbiAnimLayer()
  local node = display.newNode()
  node:setPosition(ccp(0 ,0 ))
  node:setCascadeOpacityEnabled(true)
  self:addChild(node)
  
  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("fight_anim_end",BattleTestView.onFightAnimEnd)
  pkg:addProperty("mAnimationManager","CCBAnimationManager")
  pkg:addProperty("character_l","CCSprite")
  pkg:addProperty("character_r","CCSprite")
  local layer,owner = ccbHelper.load("MicroFight.ccbi","MicroFight","CCLayer",pkg)
  assert(layer)
  node:addChild(layer)
  self._fightAnimLayer = layer
  self._fightAnimLayer:setVisible(false)
end

function BattleTestView:onFightAnimEnd()
--  assert(false)
end

function BattleTestView:playCcbiAnim()
  self._fightAnimLayer:setVisible(true)
  self.mAnimationManager:runAnimationsForSequenceNamed("Fight")
end

function BattleTestView:playSequence()
  local node = display.newNode()
  node:setPosition(ccp(320 ,480 ))
  node:setCascadeOpacityEnabled(true)
  self:addChild(node)
  
  local anim,offsetX,offsetY,duration = _res(5020019)
  anim:setPosition(ccp(offsetX,offsetY))
  node:addChild(anim)
  anim:getAnimation():play("default")   
end

function BattleTestView:newCard(id,group)
    local monsterCard = BattleCard.new()
    monsterCard:initAttrById(id)
    monsterCard:setPos(0)
    monsterCard:setInfoId(id)
    monsterCard:setType(1)
    monsterCard:setGroup(group)
    return monsterCard
end