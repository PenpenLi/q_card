require("model.battle.event.BattleBaseEvent")

BattleAttackEvent = class("BattleAttackEvent",BattleBaseEvent)

BattleAttackEventState = enum({"Normal","Miss","Block","Critical"})

function BattleAttackEvent:ctor(type,infomation)
  self:setType(type)
  self:setInfo(PbRegist.unpackStruct("CardAttackEvent",infomation))
end

function BattleAttackEvent:execute(battle,battleView)
  printf("BattleAttackEvent:execute")
  if self:checkContinueEvent(battle) == true then
    local info = self:getInfo()
    dump(info)
    local duration = 0
    local d = 0
    local delay_src_anim = 0.15
    local delay_dst_anim = 0.2
    
    local card = battle:getCardByIndex(info.attacker)
    
    battleView:cameraMove(card)
    
    local cardView = battleView:getCardByIndex(info.attacker)
    if cardView:getIsPlayedDialogueByActionType(BattleConfig.ActionTypeNormalAttack) ~= true then
       cardView:playActionDialogue(battle,battleView,BattleConfig.ActionTypeNormalAttack)
    end
    
    if info.is_force_melee == false then
       _playSnd(PbTroopAttackSfx[card:getType()])
    elseif info.is_force_melee == true then
       _playSnd(PbTroopAttackSfx[PbTroopType.Infantry])
    end
    
     --add
    
     
    local forceMelee = info.is_force_melee
    local attackType = PbAttackType.AttackNormal
    if forceMelee == true then
      attackType = PbAttackType.AttackForceMelee
    end
    local unitTypeConfig = AllConfig.unittype[card:getType()]
    assert(unitTypeConfig,string.format("Invalid unitTypeConfig,type:%d",card:getType()))

    local anim_config_src = PbTroopAnim[card:getType()][attackType].src
    local anim_config_dst = PbTroopAnim[card:getType()][attackType].dst
    assert(anim_config_src)
    assert(anim_config_dst)
    
    local delay_src_config = anim_config_src.delay
    local delay_dst_config = anim_config_dst.delay
    
    
    d = cardView:playAttackSrc(card,info.is_force_melee,battle,battleView)
    
    if delay_src_config > 0 then
      if delay_src_config/1000 < d then 
        delay_src_anim = delay_src_config/1000
      end
    end
    
    duration = gt_time(d,duration)
    cardView:wait(delay_src_anim)
    duration = duration - delay_src_anim
    if duration < 0 then
      duration = 0
    end
    
    ---
    -- to show be attacked anim
    for key, sub_attack in pairs(info.sub_attack) do
      if sub_attack.is_attack_wall then
        local targetWall = battle:getWallByIndex(sub_attack.target)
        local targetWallView = battleView:getWallByIndex(sub_attack.target)
        d = targetWallView:playAttackDst(card,targetWall,targetWallView,info.is_force_melee,battle,battleView)
        duration = gt_time(d,duration)
      else
  	    -- update datas
        local targetCard = battle:getCardByIndex(sub_attack.target)
        local targetCardView = battleView:getCardByIndex(sub_attack.target)
        targetCardView:update()
        d = targetCardView:playAttackDst(card,targetCard,targetCardView,info.is_force_melee,battle,battleView)
        duration = gt_time(d,duration)
      end
    end
    
    if delay_dst_config > 0 then
      if delay_dst_config/1000 < d then 
        delay_dst_anim = delay_dst_config/1000
      else
        --delay_dst_anim = delay_dst_anim * 0.5
      end
    else
      --delay_dst_anim = delay_dst_anim * 0.5
    end
    
    cardView:wait(delay_dst_anim)
    duration = duration - delay_dst_anim
    if duration < 0 then
      duration = 0
    end
    
    
    ---
    -- to show damage anim
    for key, sub_attack in pairs(info.sub_attack) do
      if sub_attack.is_attack_wall then
        local targetWall = battle:getWallByIndex(sub_attack.target)
        local targetWallView = battleView:getWallByIndex(sub_attack.target)
        if sub_attack.damage_type == PbDamageType.DamageMiss then
          -- do nothing
        else
          targetWallView:playOnDamage(sub_attack.damage,sub_attack.damage_type)
        end
        targetWall:setHp(sub_attack.final_hp)
        targetWallView:updateWallView()
      else
        -- update datas
        local targetCard = battle:getCardByIndex(sub_attack.target)
        local targetCardView = battleView:getCardByIndex(sub_attack.target)
        if sub_attack.damage_type == PbDamageType.DamageMiss then
          d = targetCardView:playMiss(battle,battleView)
          duration = gt_time(d,duration)
        else
          d = targetCardView:shake(battle,battleView)
          duration = gt_time(d,duration)
        end
        targetCardView:playOnDamage(sub_attack.damage,sub_attack.damage_type)
        -- if target is boss,change to boss obj
        if targetCard:getIsBoss() == true then
          local boss = battle:getBoss()
          boss:setHp(sub_attack.final_hp)
          local bossInfoView = battleView:getBossInfoView()
          bossInfoView:updateView()
        else
          targetCard:setHp(sub_attack.final_hp)
          targetCardView:updateCardView()
        end
        
      end
    end
    
    for key, effect in pairs(info.effect) do
    	local targetCardView = battleView:getCardByIndex(effect.target)
    	targetCardView:playExtraEffect(battle,battleView,effect.skill_effect_id)
    end
    
    for key, skill_damage in pairs(info.skill_damage) do
      local targetCard = battle:getCardByIndex(skill_damage.target)
      local targetCardView = battleView:getCardByIndex(skill_damage.target)
      if skill_damage.damage_type == PbDamageType.DamageMiss then
        -- do nothing
      else
        targetCardView:playOnDamage(skill_damage.damage,skill_damage.damage_type)
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
    cardView:wait(duration)
  else
    printf("battle has been canceled.")
  end

end
