
BattleCardDamageView = class("BattleCardDamageView",function()
    return display.newNode()
end)

function BattleCardDamageView:ctor()
  self._count = 0
  self._word_show_count = 0
  local effectNode = CCNode:create()
  self:addChild(effectNode)
  effectNode:setPosition(ccp(0,40))
  self._effectNode = effectNode
end

function BattleCardDamageView:simpleAddChild(child,pos)
  local parent = self:getParent():getParent()
  parent:addChild(child)
  local originX = self:getParent():getPositionX()
  local originY = self:getParent():getPositionY()
  child:setPosition(ccp(pos.x + originX,pos.y + originY))
end

function BattleCardDamageView:onDamageType(damageType)
  
  local sptWord = nil
  if damageType == PbDamageType.DamageNormal then
    
  elseif damageType == PbDamageType.DamageMiss then
    sptWord = _res(3033002)
  elseif damageType == PbDamageType.DamageBlock then
    sptWord = _res(3033001)
  elseif damageType == PbDamageType.DamageCritical then
  end
  
  self:showWords(sptWord)
end

local WordPos = { ccp(0,-10),ccp(0,30) }
function BattleCardDamageView:showWords(sptWord)
  if sptWord ~= nil then
    self:addChild(sptWord)
    self._word_show_count = self._word_show_count + 1
    local type = self._word_show_count%2
    local pos = WordPos[type + 1]
    sptWord:setPosition(pos)
    sptWord:setScale(0.1)
    local time = 0.618
    local array = CCArray:create()
    local fadeOut = CCEaseOut:create(CCFadeOut:create(time),0.1)
    local exploid = CCEaseBounceOut:create(CCScaleTo:create(time,1.0))
    local spawn = CCSpawn:createWithTwoActions(fadeOut,exploid)
    array:addObject(spawn)
    array:addObject(CCRemoveSelf:create())
    local action = CCSequence:create(array)
    sptWord:runAction(action)
  end

end

--local DamageNumPos = { ccp(-20,10),ccp(10,15),ccp(-10,15),ccp(20,10) }
local DamageNumPos = { ccp(-20,-5),ccp(30,30),ccp(-30,0),ccp(20,40) }
--local DamageNumPos = { ccp(-20,-5),ccp(30,40),ccp(-30,0),ccp(20,70) }

function BattleCardDamageView:onDamage(damage,damageType,animDelayTime,multiDamage)
  local time = 0
  local strDamage = nil
  local sptDamage = nil
  forbiRandomPos = forbiRandomPos or false
  if animDelayTime == nil then
    animDelayTime = 0
  end

  if damageType == PbDamageType.DamageMiss then
    -- do nothing
  else
    -- guard
    if damage > 9999999 then
      damage = 9999999
    elseif damage < -9999999 then
      damage = -9999999
    end
    if damageType == PbDamageType.DamageCure then
      strDamage = string.format("+%d",damage)
      sptDamage = CCLabelBMFont:create(strDamage, "client/widget/words/battle_number/battle_number_green.fnt")
    else
      strDamage = string.format("-%d",damage)
      sptDamage = CCLabelBMFont:create(strDamage, "client/widget/words/battle_number/battle_number_red.fnt")
    end
    self._effectNode:addChild(sptDamage)
    
    local maxScale = 1.3  
    local distance = 30
    local array = CCArray:create()
    if animDelayTime ~= 0 then
      local delay = CCDelayTime:create(animDelayTime)
      array:addObject(delay)
    end
    if multiDamage == true then
      local pos = ccp(0,0)
      sptDamage:setPosition(pos)
    else
      self._count = self._count + 1
      local type = self._count%4
      local pos = DamageNumPos[type + 1]
      sptDamage:setPosition(pos)   
    end

--    if self._count%3 == 0 then
--    damageType = PbDamageType.DamageNormal
  if multiDamage == true then
        time = 0.35
        maxScale = 1.1
        distance = 50  
        
        local exploidTime = time * 0.7
        local fadeOutTime = time * 0.3
        sptDamage:setScale(0.6)
        
        local sub_array = CCArray:create()
        local exploid = CCEaseBounceOut:create(CCScaleTo:create(exploidTime,maxScale))
        sub_array:addObject(exploid)
        local fadeOut = CCEaseOut:create(CCFadeOut:create(fadeOutTime),0.2)
        sub_array:addObject(fadeOut)
        local sub_action = CCSequence:create(sub_array)
        
        local move = CCMoveBy:create(time,ccp(0,distance))
        local spawn = CCSpawn:createWithTwoActions(move,sub_action)
        array:addObject(spawn)
  
  else
    if damageType == PbDamageType.DamageCritical then
      time = 0.618
      maxScale = 1.618
      distance = 40    
      
      local exploidTime = time * 0.7
      local delayTime = time * 0.3
      sptDamage:setScale(0.6)
      
      local sub_array = CCArray:create()
      local exploid = CCEaseElasticOut:create(CCScaleTo:create(exploidTime,maxScale))
      sub_array:addObject(exploid)
      local delay = CCDelayTime:create(delayTime)
      sub_array:addObject(delay)
      local sub_action = CCSequence:create(sub_array)
      
      array:addObject(sub_action)
      
    else
        time = 0.4
        maxScale = 1.1
        distance = 30    
        
        local exploidTime = time * 0.7
        local fadeOutTime = time * 0.3
        sptDamage:setScale(0.6)
        
        local sub_array = CCArray:create()
        local exploid = CCEaseBounceOut:create(CCScaleTo:create(exploidTime,maxScale))
        sub_array:addObject(exploid)
        local fadeOut = CCEaseOut:create(CCFadeOut:create(fadeOutTime),0.2)
        sub_array:addObject(fadeOut)
        local sub_action = CCSequence:create(sub_array)
        
        local move = CCMoveBy:create(time,ccp(0,distance))
        local spawn = CCSpawn:createWithTwoActions(move,sub_action)
        array:addObject(spawn)
      end
  end    
    array:addObject(CCRemoveSelf:create())
    local action = CCSequence:create(array)
    sptDamage:runAction(action)
  end
  
  self:onDamageType(damageType)
end
