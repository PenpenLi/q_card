require("model.battle.event.BattleBaseEvent")

BattleSkillEvent = class("BattleSkillEvent",BattleBaseEvent)

function BattleSkillEvent:ctor(type,infomation)
  self:setType(type)
  self:setInfo(PbRegist.unpackStruct("CardSkillEvent",infomation))
end

function BattleSkillEvent:execute(battle,battleView)
  printf("BattleSkillEvent:execute")
  if self:checkContinueEvent(battle) == true then
    local info = self:getInfo()
    local duration = 0
    local d = 0
    local delay_src_anim = 0
    local delay_dst_anim = 0
    
    
    local card = battle:getCardByIndex(info.attacker)
    
    battleView:cameraMove(card)
    
    local cardView = battleView:getCardByIndex(info.attacker)
    
    if cardView:getIsPlayedDialogueByActionType(BattleConfig.ActionTypeUseSkill) ~= true then
       cardView:playActionDialogue(battle,battleView,BattleConfig.ActionTypeUseSkill)
    end
    
    cardView:update()
    local skillInfo = AllConfig.cardskill[info.skill_id]
    if  skillInfo == nil then
      return
    end 
    
    local skillEffect = AllConfig.skilleffect[skillInfo.skill_effect_id]
    
    local delay_src_config = skillEffect.selft_effect_time
    local delay_dst_config = skillEffect.target_effect_time
    
    if AllConfig.unit[cardView:getData():getInfoId()].unit_show > 0 and cardView:getData():getIsPrimary() == true then
       d = cardView:playPreUseSkill(skillInfo,battleView)
       cardView:wait(d)
    end
    
    d = cardView:playUseSkill(skillInfo)
    delay_src_anim = d
    delay_src_anim = delay_src_anim * 0.5
    
    if delay_src_config > 0 then
      if delay_src_config/1000 < d then 
        delay_src_anim = delay_src_config/1000
      end
    end
    
    duration = gt_time(d,delay_src_anim)
    cardView:wait(delay_src_anim)

    duration = duration - delay_src_anim
    if duration < 0 then
      duration = 0
    end
    
    ---
    -- to show be attacked anim
    
    local sound_effect = 0
    if skillEffect ~= nil then
      sound_effect = skillEffect.sound_effect
      if sound_effect ~= 0 then
        _playSnd(BattleSkillHitSfx[sound_effect])
      end
    end
    
    for key, target in pairs(info.target) do
      -- update datas
      local targetCard = battle:getCardByIndex(target)
      local targetCardView = battleView:getCardByIndex(target)
      targetCardView:update()
      d = targetCardView:playSufferSkill(skillInfo)
      delay_dst_anim = d
      duration = gt_time(d,duration)
    end
    
    if info.wall_group ~= -1 then
      local targetWallView = battleView:getWallByIndex(info.wall_group)
      if targetWallView ~= nil then
         d = targetWallView:playSufferSkill(skillInfo)
         delay_dst_anim = d
         duration = gt_time(d,duration)
      end
      
    end
    
    
    if delay_dst_config > 0 then
      if delay_dst_config/1000 < delay_dst_anim then 
        delay_dst_anim = delay_dst_config/1000
      else
        delay_dst_anim = delay_dst_anim * 0.5
      end
    else
      delay_dst_anim = delay_dst_anim * 0.5
    end
   
    cardView:wait(delay_dst_anim)
    
    duration = duration - delay_dst_anim
    if duration < 0 then
      duration = 0
    end
    
    -- show move effect
    for key, move in pairs(info.move) do
      local targetCardView = battleView:getCardByIndex(move.target)
      local from = battleView:getPosByIndex(move.from)
      local to = battleView:getPosByIndex(move.to)
      local targetCard = battle:getCardByIndex(move.target)
      targetCard:setPos(move.to)

      targetCardView:playShift(battle,battleView,from,to)
      targetCardView:playFieldEffect(battle,battleView)
    end    
    
    for key, effect in pairs(info.effect) do
      local targetCardView = battleView:getCardByIndex(effect.target)
      targetCardView:playExtraEffect(battle,battleView,effect.skill_effect_id)
    end
    
    if skillEffect.is_shake == 1 then
      battleView:shake()
    end
    
    for key, skill_damage in pairs(info.skill_damage) do
      local damage_times = 1
      if skill_damage.skill_id ~= 0 then
        local subSkillinfo = AllConfig.cardskill[skill_damage.skill_id]
        local skillEffect = AllConfig.skilleffect[subSkillinfo.skill_effect_id]
        damage_times = skillEffect.damage_times
      end
      if skill_damage.is_attack_wall == true then
        local targetWall = battle:getWallByIndex(skill_damage.target)
        local targetWallView = battleView:getWallByIndex(skill_damage.target)
        if targetWallView ~= nil then
          targetWallView:playOnDamage(skill_damage.damage,skill_damage.damage_type,damage_times)
          targetWall:setHp(skill_damage.final_hp)
          targetWallView:updateWallView()
        end
      else
        local targetCard = battle:getCardByIndex(skill_damage.target)
        local targetCardView = battleView:getCardByIndex(skill_damage.target)
        if skill_damage.damage_type == PbDamageType.DamageMiss then
          d = targetCardView:playMiss(battle,battleView)
          targetCardView:playOnDamage(skill_damage.damage,skill_damage.damage_type,1)
          duration = gt_time(d,duration)
        else
          targetCardView:playOnDamage(skill_damage.damage,skill_damage.damage_type,damage_times)
          if skill_damage.damage_type == PbDamageType.DamageCure then
            -- do nothing
          else
            d = targetCardView:shake(battle,battleView)
            duration = gt_time(d,duration)
          end        
        end
        
        -- if target is boss,change to boss obj
        if targetCard:getIsBoss() == true then
          local boss = battle:getBoss()
          boss:setHp(skill_damage.final_hp)
          local bossInfoView = battleView:getBossInfoView()
          bossInfoView:updateView()
        else
          targetCard:setHp(skill_damage.final_hp)
          targetCardView:updateCardView()
        end
      end

    end
    
    printf("duration:%f",duration)
    cardView:wait(duration + 0.2)
  else
    printf("battle has been canceled.")
  end

end