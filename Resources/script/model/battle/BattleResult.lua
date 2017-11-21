BattleResult = class("BattleResult")

BattleResultType = {["BlueGroupWin"] = 0,["RedGroupWin"] = 1,["TooMuchRound"] = 2}

function BattleResult:ctor()

end

function BattleResult:accept(result)
  self:setType(BattleResultType[result.result_type])
end

------
--  Getter & Setter for
--      BattleResult._Type 
-----
function BattleResult:setType(Type)
	self._Type = Type
end

function BattleResult:getType()
	return self._Type
end
