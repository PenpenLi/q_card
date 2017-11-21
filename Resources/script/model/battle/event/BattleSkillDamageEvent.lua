require("model.battle.event.BattleBaseEvent")

BattleSkillDamageEvent = class("BattleSkillDamageEvent",BattleBaseEvent)

function BattleSkillDamageEvent:ctor(type,infomation)
  self:setType(type)
  self:setInfo(PbRegist.unpackStruct("CardSkillDamageEvent",infomation))
end

function BattleSkillDamageEvent:execute(battle,battleView)
  printf("BattleSkillDamageEvent:execute")
  if self:checkContinueEvent(battle) == true then
    local info = self:getInfo()
    dump(info)
    
    if info.target_type == PbTargetType.TargetCard then
      -- update datas
      local targetCard = battle:getCardByIndex(info.target)
      -- if target is boss,change to boss obj
      if targetCard:getIsBoss() == true then
        local boss = battle:getBoss()
        boss:setHp(info.final_hp)
        local bossInfoView = battleView:getBossInfoView()
        bossInfoView:updateView()
      else
        targetCard:setHp(info.final_hp)
      end
      -- update views
      local cardView = battleView:getCardByIndex(info.target)
      cardView:execSkillDamageEvent(battle,battleView,info)
    elseif info.target_type == PbTargetType.TargetWall then
      -- update datas
      local targetWall = battle:getWallByIndex(info.target)
      targetWall:setHp(info.final_hp)
      -- update views
      local wallView = battleView:getWallByIndex(info.target)
      wallView:execSkillDamageEvent(battle,battleView,info)
    else
      assert(false,string.format("Invalid target type:%s",info.target_type))
    end

  else
    printf("battle has been canceled.")
  end

end