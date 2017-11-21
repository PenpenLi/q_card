require("model.battle.event.BattleBaseEvent")

BattleCardEffectEvent = class("BattleCardEffectEvent",BattleBaseEvent)

function BattleCardEffectEvent:ctor(type,infomation)
  self:setType(type)
  self:setInfo(PbRegist.unpackStruct("CardEffectEvent",infomation))
end

function BattleCardEffectEvent:execute(battle,battleView)
  printf("BattleCardEffectEvent:execute")
  if self:checkContinueEvent(battle) == true then
    local info = self:getInfo()
    dump(info)
    -- update datas
    local targetCard = battle:getCardByIndex(info.card_index)
    -- update views
    local cardView = battleView:getCardByIndex(info.card_index)
    cardView:playExtraEffect(battle,battleView,info.skill_effect_id)
  else
    printf("battle has been canceled.")
  end

end