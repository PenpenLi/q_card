require("model.battle.event.BattleBaseEvent")

BattleWallChangeValueEvent = class("BattleWallChangeValueEvent",BattleBaseEvent)

function BattleWallChangeValueEvent:ctor(type,infomation)
  self:setType(type)
  self:setInfo(PbRegist.unpackStruct("WallChangeValueEvent",infomation))
end

function BattleWallChangeValueEvent:execute(battle,battleView)
  printf("BattleWallChangeValueEvent:execute")
  if self:checkContinueEvent(battle) == true then
    local info = self:getInfo()
    dump(info)
    -- update datas
    local targetWall = battle:getWallByIndex(info.wall_group)
    targetWall:onChangeValue(info)
    -- update views
    local wallView = battleView:getWallByIndex(info.wall_group)
    wallView:updateWallView()
  else
    printf("battle has been canceled.")
  end

end