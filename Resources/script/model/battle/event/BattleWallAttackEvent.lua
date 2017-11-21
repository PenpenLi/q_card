require("model.battle.event.BattleBaseEvent")

BattleWallAttackEvent = class("BattleWallAttackEvent",BattleBaseEvent)

BattleWallAttackEventState = enum({"Normal","Miss","Block","Critical"})

function BattleWallAttackEvent:ctor(type,infomation)
  self:setType(type)
  self:setInfo(PbRegist.unpackStruct("WallAttackEvent",infomation))
end

function BattleWallAttackEvent:execute(battle,battleView)
  printf("BattleWallAttackEvent:execute")
  if self:checkContinueEvent(battle) == true then
    local info = self:getInfo()
    dump(info)
    local duration = 0
    local d = 0
    local delay_src_anim = 0.1
    local delay_dst_anim = 0.2
    
    local wall = battle:getWallByIndex(info.attacker)
    local wallView = battleView:getWallByIndex(info.attacker)
    --_playSnd(PbTroopAttackSfx[card:getType()])
    d = wallView:playAttackSrc(wall,battle,battleView,info)
    duration = gt_time(d,duration)
    duration = duration - delay_src_anim
    if duration < 0 then
      duration = 0
    end
    
    wallView:wait(duration)
    
    -- target dst effect
     -- to show be attacked anim
    for key, sub_attack in pairs(info.sub_attack) do
        -- update datas
        local targetCard = battle:getCardByIndex(sub_attack.target)
        
        battleView:cameraMove(targetCard)
        
        local targetCardView = battleView:getCardByIndex(sub_attack.target)
        targetCardView:update()
        d = targetCardView:playAttackAnim(7010060,false)
        duration = gt_time(d,duration)
    end
    wallView:wait(delay_dst_anim)
    
--    local card = battle:getCardByIndex(info.target)
--    local cardView = battleView:getCardByIndex(info.target)
--    cardView:playAttackAnim(5020136,false)
    
  else
    printf("battle has been canceled.")
  end
end
