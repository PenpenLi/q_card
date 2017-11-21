require("model.battle.event.BattleBaseEvent")

BattleDropItemEvent = class("BattleDropItemEvent",BattleBaseEvent)

function BattleDropItemEvent:ctor(type,infomation)
  self:setType(type)
  self:setInfo(PbRegist.unpackStruct("CardDropItemEvent",infomation))
end

function BattleDropItemEvent:execute(battle,battleView)
  printf("BattleDropItemEvent:execute")
  if self:checkContinueEvent(battle) == true then
    local info = self:getInfo()
    dump(info)
    local fieldView = battleView:getFieldViewByIndex(info.drop_item_pos)
    fieldView:playDropItem()
    
    battle:setDropCount(battle:getDropCount() + 1)
    battleView:updateDropCount(battle:getDropCount())
  else
    printf("battle has been canceled.")
  end

end