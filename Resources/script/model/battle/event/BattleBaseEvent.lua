require("model.battle.BattleConfig")

BattleBaseEvent = class("BattleBaseEvent")

function BattleBaseEvent:ctor()
  
end

function BattleBaseEvent:execute(battle,battleView)
  

end

function BattleBaseEvent:checkContinueEvent(battle)
  if battle:getEventLoop() == nil then
    return false
  else
    return true
  end
  
end

------
--  Getter & Setter for
--      BattleBaseEvent._Info 
-----
function BattleBaseEvent:setInfo(Info)
  self._Info = Info
end

function BattleBaseEvent:getInfo()
  return self._Info
end

------
--  Getter & Setter for
--      BattleBaseEvent._Type 
-----
function BattleBaseEvent:setType(Type)
	self._Type = Type
end

function BattleBaseEvent:getType()
	return self._Type
end
