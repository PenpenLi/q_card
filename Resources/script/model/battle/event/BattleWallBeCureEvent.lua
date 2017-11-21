require("model.battle.event.BattleBaseEvent")

BattleWallBeCureEvent = class("BattleWallBeCureEvent",BattleBaseEvent)

function BattleWallBeCureEvent:ctor(type,infomation)
  self:setType(type)
  self:setInfo(PbRegist.unpackStruct("WallBeCureEvent",infomation))
end

function BattleWallBeCureEvent:execute(battle,battleView)
  printf("BattleWallBeCureEvent:execute")
  if self:checkContinueEvent(battle) == true then
    local info = self:getInfo()
    dump(info)
    local targetWall = battle:getWallByIndex(info.wall_group)
    targetWall:setHp(info.final_hp)
    -- update views
    local wallView = battleView:getWallByIndex(info.wall_group)
    wallView:execbeCureEvent(battle,battleView,info)
  else
    printf("battle has been canceled.")
  end
end