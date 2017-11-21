Award = class("Award")
function Award:ctor(msg)
  --required int32 rank  = 1;  //等级段
  --required bool  chance   = 2;  //是否有领取资格
  
  if msg ~= nil then
     self:updateMsg(msg)
  end
end

function Award:updateMsg(msg)
    self:setChance(msg.chance)
    self:setRank(msg.rank)
end

function Award:setChance(Chance)
	self._Chance = Chance
end

function Award:getChance()
	return self._Chance
end

function Award:setRank(Rank)
	self._Rank = Rank
end

function Award:getRank()
	return self._Rank
end

return Award