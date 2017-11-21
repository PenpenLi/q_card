require("model.battle.event.BattleBaseEvent")

BattleCombineSkillEvent = class("BattleCombineSkillEvent",BattleBaseEvent)

function BattleCombineSkillEvent:ctor(type,infomation)
  self:setType(type)
  self:setInfo(PbRegist.unpackStruct("CardCombineSkillEvent",infomation))
end

function BattleCombineSkillEvent:execute(battle,battleView)
  printf("BattleCombineSkillEvent:execute")
  if self:checkContinueEvent(battle) == true then
    local info = self:getInfo()
    dump(info)
    battleView:execCombineSkillEvent(battle,info)
  else
    printf("battle has been canceled.")
  end

end