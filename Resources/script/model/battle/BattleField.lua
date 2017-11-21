BattleField = class("BattleField")


function BattleField:ctor(pos)
  self:setPos(pos)
  self:setIndex(pos)
  self:setType(0)
end

function BattleField:accept(field)
  assert(self:getPos() == field.init_pos,"Invalid field:[pos = %d],but [field.init_pos = %d]",self:getPos(),field.init_pos)
  self:setType(field.type)
end

------
--  Getter & Setter for
--      BattleField._View 
-----
function BattleField:setView(View)
	self._View = View
end

function BattleField:getView()
	return self._View
end

function BattleField:setIndex(index)
  self._Index = index
end

function BattleField:getIndex()
  return self._Index
end
    
------
--  Getter & Setter for
--      BattleField._Pos 
-----
function BattleField:setPos(Pos)
	self._Pos = Pos
end

function BattleField:getPos()
	return self._Pos
end

------
--  Getter & Setter for
--      BattleField._Type 
-----
function BattleField:setType(Type)
	self._Type = Type
end

function BattleField:getType()
	return self._Type
end
