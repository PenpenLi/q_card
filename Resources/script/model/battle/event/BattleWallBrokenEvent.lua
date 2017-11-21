require("model.battle.event.BattleBaseEvent")

BattleWallBrokenEvent = class("BattleWallBrokenEvent",BattleBaseEvent)

function BattleWallBrokenEvent:ctor(type,infomation)
  self:setType(type)
  self:setInfo(PbRegist.unpackStruct("WallBrokenEvent",infomation))
end

function BattleWallBrokenEvent:execute(battle,battleView)
  

end