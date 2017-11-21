BattleBoss = class("BattleBoss")

function BattleBoss:ctor()

end

function BattleBoss:accept(Boss)
  if Boss.boss_hp < 0 then
    printf(string.format("Invalid boss hp:%d",Boss.boss_hp))
    dump(Boss)
    assert(false)
    Boss.boss_hp = 1
  end
  self:setHp(Boss.boss_hp)
  self:setMaxHp(Boss.boss_maxhp)
  self:setGroup(Boss.group)
end

------
--  Getter & Setter for
--      BattleBoss._View 
-----
function BattleBoss:setView(View)
  self._View = View
end

function BattleBoss:getView()
  return self._View
end


------
--  Getter & Setter for
--      BattleBoss._Hp 
-----
function BattleBoss:setHp(Hp)
  self._Hp = Hp
end

function BattleBoss:getHp()
  return self._Hp
end

------
--  Getter & Setter for
--      BattleBoss._MaxHp 
-----
function BattleBoss:setMaxHp(MaxHp)
  self._MaxHp = MaxHp
end

function BattleBoss:getMaxHp()
  return self._MaxHp
end


------
--  Getter & Setter for
--      BattleBoss._Group 
-----
function BattleBoss:setGroup(Group)
  self._Group = Group
end

function BattleBoss:getGroup()
  return self._Group
end
