require("model.battle.event.BattleBaseEvent")

BattleMoveEvent = class("BattleMoveEvent",BattleBaseEvent)

function BattleMoveEvent:ctor(type,infomation)
  self:setType(type)
  self:setInfo(PbRegist.unpackStruct("CardMoveEvent",infomation))
end

function BattleMoveEvent:execute(battle,battleView)
  printf("BattleMoveEvent:execute")
  if self:checkContinueEvent(battle) == true then
    local info = self:getInfo()
    dump(info)
    -- update datas
    local targetCard = battle:getCardByIndex(info.card_index)
    targetCard:setPos(info.to)
    
    battleView:cameraReset()
    
    local from = battleView:getPosByIndex(info.from)
    local to = battleView:getPosByIndex(info.to)
    printf("card move from[%f,%f] to[%f,%f]",from.x,from.y,to.x,to.y)
    
    -- update views
    local cardView = battleView:getCardByIndex(info.card_index)
    cardView:stopAllActions()
    cardView:setPosition(from)
    if info.move_effect ~= nil and info.move_effect ~= 0 then
      cardView:playClash(targetCard,cardView,battle,battleView,from,to)
    else
      _playSnd(PbTroopMoveSfx[targetCard:getType()])
      cardView:playMove(targetCard,cardView,battle,battleView,from,to)
    end
    
    local info = self:getInfo()
    local cardView = battleView:getCardByIndex(info.card_index)
    cardView:playFieldEffect(battle,battleView)

  else
    printf("battle has been canceled.")
  end

end

function BattleMoveEvent:onQuitEvent(battle,battleView)
--  local info = self:getInfo()
--  local cardView = battleView:getCardByIndex(info.card_index)
----  if info.move_effect ~= nil and info.move_effect ~= 0 then
----    battleView:shake(1.0)
----    local d = cardView:shake(battle,battleView,12.0)
----    cardView:wait(d + 0.3)
----  else 
----  
----  end  
--  -- play territory effect
--  cardView:playFieldEffect(battle,battleView)
end

