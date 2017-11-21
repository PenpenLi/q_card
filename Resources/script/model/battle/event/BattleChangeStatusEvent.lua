require("model.battle.event.BattleBaseEvent")

BattleChangeStatusEvent = class("BattleChangeStatusEvent",BattleBaseEvent)

function BattleChangeStatusEvent:ctor(type,infomation)
  self:setType(type)
  self:setInfo(PbRegist.unpackStruct("CardSkillStatusEvent",infomation))
end

function BattleChangeStatusEvent:execute(battle,battleView)
  printf("BattleChangeStatusEvent:execute")
  if self:checkContinueEvent(battle) == true then
    local info = self:getInfo()
    dump(info)
    -- update datas
    local targetCard = battle:getCardByIndex(info.target)
    -- update views
    local cardView = battleView:getCardByIndex(info.target)
    cardView:execChangeStatusEvent(battle,battleView,info)
  else
    printf("battle has been canceled.")
  end

end