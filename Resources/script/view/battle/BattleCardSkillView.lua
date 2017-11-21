require("view.battle.BattleCardOffsetSumary")

BattleCardSkillView = class("BattleCardSkillView",function()
    return display.newNode()
end)

function BattleCardSkillView:ctor()
end

function BattleCardSkillView:playAttackAnim(animId,cardView,is_flip_y,offset)
  local duration = 0
  if animId ~= 0 then
    if offset == nil then
      offset = ccp(0,0)
    end
    printf("playNormalAttackAnim,animId:%d",animId)
    local node = display.newNode()
    node:setNodeEventEnabled(true)
    self:addChild(node)
    local anim,offsetX,offsetY,d,isFlipY = _res(animId)
    anim:setPosition(ccp(offsetX + offset.x,offsetY + offset.y))
    anim:setFlipY(isFlipY)  
    anim:getAnimation():play("default") 
    node:addChild(anim,999)
    
    if is_flip_y == nil then
      is_flip_y = false
    end
    if is_flip_y == true and cardView:getActionSign() == -1 then
      node:setRotation(-180)
    end

    node:performWithDelay(function ()
      node:removeFromParentAndCleanup(true)
    end,d)
    duration = d
--    duration = d + skillEffect.selft_effect_time
--    duration = d + BattleCardEffectTest[skillEffect.id].selft_effect_time/1000.0
--    assert(duration >= 0,string.format("Invalid duration:%d,effect id:%d",duration,skillEffect.id))
  end
  return duration
end

function BattleCardSkillView:playEffectAnim(skillEffect,cardView,offset)
  local duration = 0
  if skillEffect ~= nil and skillEffect.self_effect ~= 0 then
    
    printf("playSrcSkillAnim,skillInfo.skill_effect_id:%d,skillEffect.self_effect:%d",skillEffect.id,skillEffect.self_effect)
    local node = display.newNode()
    self:addChild(node)
    local anim,offsetX,offsetY,d,isFlipY = _res(skillEffect.self_effect)
    if BattleConfig.IsUseSumaryFile == true then
      if offset ~= nil then
        anim:setFlipY(offset.src_flip_y)
        anim:setPosition(offset.src)
      end
    else
      anim:setPosition(ccp(offsetX,offsetY))
      anim:setFlipY(isFlipY)  
    end
    
    anim:getAnimation():play("default") 
    node:addChild(anim,999)
    
    if skillEffect.is_src_flip_y == 1 and cardView:getActionSign() == -1 then
      node:setRotation(-180)
    end

    self:performWithDelay(function ()
      node:removeFromParentAndCleanup(true)
    end,d)
    duration = d
    assert(duration >= 0,string.format("Invalid duration:%d,effect id:%d",duration,skillEffect.id))
  end
  return duration
end

function BattleCardSkillView:playSrcSkillAnim(skillInfo,cardView)

  local skillEffect = AllConfig.skilleffect[skillInfo.skill_effect_id]
  local offset = BattleCardOffsetSumary[skillInfo.skill_effect_id]
  return self:playEffectAnim(skillEffect,cardView,offset)
end

function BattleCardSkillView:playDstSkillAnim(skillInfo,cardView)
  local skillEffect = AllConfig.skilleffect[skillInfo.skill_effect_id]
  local duration = 0
  if skillEffect ~= nil and skillEffect.target_effect ~= 0 then
    printf("playDstSkillAnim,skillInfo.skill_effect_id:%d,skillEffect.target_effect:%d",skillEffect.id,skillEffect.target_effect)
    local node = display.newNode()
    self:addChild(node)
    local anim,offsetX,offsetY,d,isFlipY = _res(skillEffect.target_effect)
    
    if BattleConfig.IsUseSumaryFile == true then
      local offset = BattleCardOffsetSumary[skillInfo.skill_effect_id]
      if offset ~= nil then
        anim:setFlipY(offset.dst_flip_y)
        anim:setPosition(offset.dst)
      end 
    else
      anim:setPosition(ccp(offsetX,offsetY))
      anim:setFlipY(isFlipY)      
    end

    anim:getAnimation():play("default") 
    node:addChild(anim,999)
    if skillEffect.is_dst_flip_y == 1 and cardView ~= nil and cardView:getActionSign() == -1 then
      node:setRotation(-180)
    end
    anim:getAnimation():play("default") 
    self:performWithDelay(function ()
      node:removeFromParentAndCleanup(true)
    end,d)
    duration = d
    assert(duration >= 0,string.format("Invalid duration:%d,effect id:%d",duration,skillEffect.id))
  end
  
  return duration
end