BattleWall = class("BattleWall")

function BattleWall:ctor()
  self:setLevel(1)
  self:setHp(1)
  self:setMaxHp(1)
end

------
--  Getter & Setter for
--      BattleWall._Type 
-----
function BattleWall:setType(Type)
	self._Type = Type
end

function BattleWall:getType()
	return self._Type
end

function BattleWall:accept(wall)
  self:setLevel(wall.level)
  self:setHp(wall.hp)
  self:setMaxHp(wall.hp)
  self:setGroup(wall.group)
  
end

function BattleWall:onChangeValue(info)
  if info.change_type == "ChangeTypeAngry" then
     
  elseif info.change_type == "ChangeTypeMaxHp" then
    self:setHp(info.change_value)
    self:setMaxHp(info.change_value)
  elseif info.change_type == "ChangeTypeCurHp" then
    self:setHp(info.change_value)
  end
end

------
--  Getter & Setter for
--      BattleWall._View 
-----
function BattleWall:setView(View)
	self._View = View
end

function BattleWall:getView()
	return self._View
end

  
------
--  Getter & Setter for
--      BattleWall._Level 
-----
function BattleWall:setLevel(Level)
	self._Level = Level
end

function BattleWall:getLevel()
	return self._Level
end

------
--  Getter & Setter for
--      BattleWall._Hp 
-----
function BattleWall:setHp(Hp)
	self._Hp = Hp
end

function BattleWall:getHp()
	return self._Hp
end

------
--  Getter & Setter for
--      BattleWall._MaxHp 
-----
function BattleWall:setMaxHp(MaxHp)
	self._MaxHp = MaxHp
end

function BattleWall:getMaxHp()
	return self._MaxHp
end


------
--  Getter & Setter for
--      BattleWall._Group 
-----
function BattleWall:setGroup(Group)
	self._Group = Group
end

function BattleWall:getGroup()
	return self._Group
end
