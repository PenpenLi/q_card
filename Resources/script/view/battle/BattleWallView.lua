require("model.battle.BattleWall")
require("model.battle.Battle")
require("view.battle.BattleCardAttackEffect")
require("view.battle.BattleCardDamageView")

BattleWallView = class("BattleWallView",function()
  return display.newNode()
end)

function BattleWallView:ctor(wall,battle)
  local group = wall:getGroup()
  local viewConfig = battle:getViewConfig()
  self:setNodeEventEnabled(true)
  self:setGroup(group)
  self:setPlayingHugeDamage(false)
  local sign = 1
  if self:getGroup() == BattleConfig.BattleSide.Blue then
    sign = 1
  else
    sign = -1
  end
  self:setActionSign(sign)
  
  
  self._tweenHpBar = _res(3025013)
  self._tweenHpBar:setAnchorPoint(ccp(0.0,0.5))
  
  self._redBar = _res(3025014)
  self._redBar:setVisible(false)
  self._redBar:setAnchorPoint(ccp(0.0,0.5))
  
  
  if group == BattleConfig.BattleSide.Red then
    print("wall Level:",wall:getLevel())
    local wallLevel = wall:getLevel()
    if wallLevel > #viewConfig.wall then
      wallLevel = #viewConfig.wall
    end
    local sptWall = _res(viewConfig.wall[wallLevel])
    --local sptWall = _res(viewConfig["wall_lv"..wall:getLevel()])
    --local sptWall = _res(viewConfig.wall[wall:getLevel()])
    self:addChild(sptWall,3)
    sptWall:setAnchorPoint(ccp(0.5,0.0))
    sptWall:setPosition(0,-30)
    
    -- hp bar
    local pos = ccp(0,20)
    local sptHpBarBg = _res(3025004)
    self:addChild(sptHpBarBg,3)
    sptHpBarBg:setPosition(pos)
    pos.x = pos.x - 65
    self._sptHpBarBg = sptHpBarBg
    
    self:addChild(self._tweenHpBar,3)
    self._tweenHpBar:setPosition(pos)
    
    local sptHpBar = _res(3025005)
    self:addChild(sptHpBar,3)
    sptHpBar:setPosition(pos)
    sptHpBar:setAnchorPoint(ccp(0.0,0.5))
    self._sptHpBar = sptHpBar
    
    self:addChild(self._redBar,3)
    self._redBar:setPosition(pos)
    
    --towner
    local sptTownerL = _res(viewConfig.Guard_Towner[wallLevel])
    self:addChild(sptTownerL,3)
    sptTownerL:setAnchorPoint(ccp(0.5,0.0))
    sptTownerL:setPosition(0,10)
--
--    local sptTownerR = _res(viewConfig.Guard_Towner[wall:getLevel()])
--    self:addChild(sptTownerR,3)
--    sptTownerR:setAnchorPoint(ccp(0.5,0.0))
--    sptTownerR:setPosition(0,20)

  elseif group == BattleConfig.BattleSide.Blue then
    sign = 1
    local sptWall = _res(viewConfig.barracks)
    self:addChild(sptWall,1)
    sptWall:setAnchorPoint(ccp(0.5,1.0))
    
    local pos = ccp(0,-14)
    local sptHpBarBg = _res(3025004)
    self:addChild(sptHpBarBg,3)
    sptHpBarBg:setPosition(pos)
    pos.x = pos.x - 65
    self._sptHpBarBg = sptHpBarBg
    
    self:addChild(self._tweenHpBar,3)
    self._tweenHpBar:setPosition(pos)
    
    local sptHpBar = _res(3025005)
    self:addChild(sptHpBar,3)
    sptHpBar:setPosition(pos)
    sptHpBar:setAnchorPoint(ccp(0.0,0.5))
    self._sptHpBar = sptHpBar
    
    self:addChild(self._redBar,3)
    self._redBar:setPosition(pos)
    
    
  else
    assert(false)
  end
  
  
  if sign == -1 then
    local tent_distance = 106
    local sptGreenTent = _res(viewConfig.green_tent)
    self:addChild(sptGreenTent,2)
    sptGreenTent:setPosition(ccp(-20,tent_distance))
  else
    local tent_distance = -145
    local sptBlueTent = _res(viewConfig.bue_tent)
    sptBlueTent:setPosition(ccp(-40,tent_distance))
    self:addChild(sptBlueTent,2)
  end
  

  local skillView = BattleCardSkillView.new()
  self:addChild(skillView,5)
  self._skillView = skillView

  local damageView = BattleCardDamageView.new()
  self:addChild(damageView,5)
  self._damageView = damageView
  
  self._wall = wall
  
--  if battle:getIsBossBattle() == true then
--     self._sptHpBarBg:setVisible(false)
--     self._sptHpBar:setVisible(false)
--  end
  
  self:updateWallView()
end

function BattleWallView:wait(duration)
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

function BattleWallView:playAttackSrc(wall,battle,battleView,info)
--  self._skillView:removeAllChildrenWithCleanup(true)
--  local sptWallAttackSrc,offsetX,offsetY,duration = _res(7010002)
--  sptWallAttackSrc:setPosition(ccp(offsetX - 198,offsetY + 55))
--  self._skillView:addChild(sptWallAttackSrc,99)
--  sptWallAttackSrc:getAnimation():play("default") 
--  sptWallAttackSrc:setRotation(-180)
  
  local offset = ccp(198,-55)
  if info ~= nil then
    for key, sub_attack in pairs(info.sub_attack) do
      local targetCard = battle:getCardByIndex(sub_attack.target)
      local targetCardView = battleView:getCardByIndex(sub_attack.target)
      if targetCardView:getPositionX() > display.cx then
        offset = ccp(-198,-55)
--        print("PosX~~~~~~~~~~~~~~~",targetCardView:getPositionX())
--        assert(false)
      end
    end
  end
  
  _playSnd(PbTroopAttackSfx[PbTroopType.Archer])
  local duration = self._skillView:playAttackAnim(7010059,self,true,offset)
  if duration > 0.443 then
    duration = 0.443
  end
--  sptWallAttackSrc,offsetX,offsetY = _res(7010003)
--  sptWallAttackSrc:setPosition(ccp(offsetX + 198,offsetY + 55))
--  self._skillView:addChild(sptWallAttackSrc,99)
--  sptWallAttackSrc:getAnimation():play("default") 
--  sptWallAttackSrc:setRotation(-180)
--  self:setZOrder(99)
  return duration
end

function BattleWallView:playAttackDst(fromcard,target,targetView,forceMelee,battle,battleView)
  return BattleCardAttackEffect.defaultDstAnim(fromcard,target,targetView,battle,battleView,forceMelee)
end

function BattleWallView:playSufferSkill(skillInfo)
  echo("BattleWallView:playSufferSkill")
  self:setZOrder(99)
  return self._skillView:playDstSkillAnim(skillInfo,self)
end

function BattleWallView:playAttackAnim(animId,is_flip_y)
  local armature_duration = self._skillView:playAttackAnim(animId,self,is_flip_y)
  return armature_duration
end

function BattleWallView:playOnDamage(damage,damageType,damage_times)
  _playSnd(SFX_CASTLE_HURT)
  if damage_times == nil or damage_times == 0 then
    damage_times = 1
  end
  self:setZOrder(99)
  if damage_times ~= 1 then
    local sub_damage = damage / damage_times
    local delayTime = 0
    for i=1, damage_times do
      self._damageView:onDamage(sub_damage,damageType,delayTime)
      delayTime = delayTime + 0.16
    end
    local battleView = self:getParent()
    
    --show hit
    -- 0 fllow card 1 on same pos
    local showStyle = 0

    local offsetX = 0
    local offsetY = 0
    if self:getGroup() == BattleConfig.BattleSide.Red then
       --offsetY = -15
    end
    
    local startPos = ccp(self:getPositionX() + offsetX,self:getPositionY())
    local endPos = ccp(self:getPositionX() + offsetX,self:getPositionY() + offsetY)
    if showStyle > 0 then
       startPos = ccp(display.width + 200,display.cy)
       endPos = ccp(display.cx + 160,display.cy)
    end
    
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

function BattleWallView:playHugeDamage()
  if self:getPlayingHugeDamage() == false then
    local sptHugeDamage = CCNode:create()
    local group = self:getGroup()
    if group == BattleConfig.BattleSide.Red then
      local spt = nil
      -- wall fire 01
      spt = _res(6010005)
      spt:setPosition(ccp(-100,30))
      sptHugeDamage:addChild(spt)
      
      -- wall fire 02
      spt = _res(6010005)
      spt:setPosition(ccp(0,80))
      sptHugeDamage:addChild(spt)
      
      -- wall fire 03
      spt = _res(6010005)
      spt:setPosition(ccp(130,60))
      sptHugeDamage:addChild(spt)
    else
      local spt = nil
      -- barrack fire 01
      spt = _res(6010005)
      spt:setPosition(ccp(-190,-110))
      sptHugeDamage:addChild(spt)
      
      -- barrack fire 02
      spt = _res(6010005)
      spt:setPosition(ccp(-40,-120))
      sptHugeDamage:addChild(spt)

      -- barrack fire 03
      spt = _res(6010005)
      spt:setPosition(ccp(20,-80))
      sptHugeDamage:addChild(spt)
            
      -- barrack fire 04
      spt = _res(6010005)
      spt:setPosition(ccp(150,-80))
      sptHugeDamage:addChild(spt)
      

    end
    if sptHugeDamage ~= nil then
      self:addChild(sptHugeDamage,7)
    end
    self:setPlayingHugeDamage(true)
  end
end

function BattleWallView:execSkillDamageEvent(battle,battleView,info)
  self:playOnDamage(info.damage,"AttackUnique",info.damage_type)
  self:updateWallView()
end

function BattleWallView:execbeCureEvent(battle,battleView,info)
  local  hp = info.be_cure_hp
  self._damageView:onDamage(hp,PbDamageType.DamageCure)
  self:updateWallView()
end


function BattleWallView:updateWallView()
  local wall = self._wall
  local percent = (wall:getHp()/wall:getMaxHp())
  
  if percent < BattleConfig.WallHugePercentLimit then
     self._sptHpBar:setVisible(false)
     self._redBar:setVisible(true)
  else
     self._sptHpBar:setVisible(true)
     self._redBar:setVisible(false)
  end
  
  self._sptHpBar:setScaleX(percent)
  self._redBar:setScaleX(percent)
  
  self._tweenHpBar:stopAllActions()
  --play tween hp bar
  local array = CCArray:create()
  array:addObject(CCDelayTime:create(0.2))
  array:addObject(CCScaleTo :create(0.2,percent,1))
  local action = CCSequence:create(array)
  self._tweenHpBar:runAction(action)
  
  if percent < BattleConfig.WallHugePercentLimit then
    self:playHugeDamage()
  end
  
end

------
--  Getter & Setter for
--      BattleWallView._Group
-----
function BattleWallView:setGroup(Group)
  self._Group = Group
end

function BattleWallView:getGroup()
  return self._Group
end

------
--  Getter & Setter for
--      BattleWallView._ActionSign 
-----
function BattleWallView:setActionSign(ActionSign)
  self._ActionSign = ActionSign
end

function BattleWallView:getActionSign()
  return self._ActionSign
end

------
--  Getter & Setter for
--      BattleWallView._PlayingHugeDamage 
-----
function BattleWallView:setPlayingHugeDamage(PlayingHugeDamage)
	self._PlayingHugeDamage = PlayingHugeDamage
end

function BattleWallView:getPlayingHugeDamage()
	return self._PlayingHugeDamage
end

