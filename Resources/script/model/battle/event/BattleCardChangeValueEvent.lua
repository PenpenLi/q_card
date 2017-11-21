require("model.battle.event.BattleBaseEvent")

BattleCardChangeValueEvent = class("BattleCardChangeValueEvent",BattleBaseEvent)

function BattleCardChangeValueEvent:ctor(type,infomation)
  self:setType(type)
  self:setInfo(PbRegist.unpackStruct("CardChangeValueEvent",infomation))
end

function BattleCardChangeValueEvent:execute(battle,battleView)
  printf("BattleCardChangeValueEvent:execute")
  if self:checkContinueEvent(battle) == true then
    local info = self:getInfo()
    dump(info)
    -- update datas
    local targetCard = battle:getCardByIndex(info.card_index)
    targetCard:onChangeValue(info)
    -- update views
    local cardView = battleView:getCardByIndex(info.card_index)
    cardView:updateCardView(targetCard)
  else
    printf("battle has been canceled.")
  end

end