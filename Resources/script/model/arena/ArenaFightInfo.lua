ArenaFightInfo = class("ArenaFightInfo")
function ArenaFightInfo:ctor()
end

------
--  Getter & Setter for
--      ArenaFightInfo._TargetCards 
-----
function ArenaFightInfo:setTargetCards(TargetCards)
	self._TargetCards = TargetCards
end

function ArenaFightInfo:getTargetCards()
	return self._TargetCards
end

------
--  Getter & Setter for
--      ArenaFightInfo._SelfPlayer 
-----
function ArenaFightInfo:setSelfPlayer(SelfPlayer)
	self._SelfPlayer = SelfPlayer
end

function ArenaFightInfo:getSelfPlayer()
	return self._SelfPlayer
end

------
--  Getter & Setter for
--      ArenaFightInfo._TargetPlayer 
-----
function ArenaFightInfo:setTargetPlayer(TargetPlayer)
	self._TargetPlayer = TargetPlayer
end

function ArenaFightInfo:getTargetPlayer()
	return self._TargetPlayer
end

------
--  Getter & Setter for
--      ArenaFightInfo._MapInfo 
-----
function ArenaFightInfo:setMapInfo(MapInfo)
	self._MapInfo = MapInfo
end

function ArenaFightInfo:getMapInfo()
	return self._MapInfo
end

return ArenaFightInfo