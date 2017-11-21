require("model.Card")

BattleCard = class("BattleCard",Card)

function BattleCard:ctor()
  local hp = 1.0
  self:setHp(hp)
  self:setMaxHp(hp)
  self:setInitHpRatio(10000)
  local angry = 2.0
  self:setAngry(1.0)
  self:setMaxAngry(angry)
end

function BattleCard:accept(card)
  self:initAttrById(card.card_id)
  self:setInfoId(card.card_id)
  self:setIndex(card.index)
  local hp = card.init_hp
  self:setInitHpRatio(card.init_hpper)
  self:setHp(hp * card.init_hpper / 10000)
  self:setMaxHp(hp)
  self:setAngry(card.init_angry)
  self:setMaxAngry(100)
  self:setPos(card.init_pos)
  self:setGroup(card.group)
  self:setOriginalGroup(card.group)
  self:setType(card.type)
  self:setIsPrimary(card.is_primary)
  self:setIsRotate(card.is_rotate)
  self:setIsBoss(false)
  self:setDamageBear(card.damage_bear)
  self:setDamageOut(card.damage_out)
end

function BattleCard:onChangeValue(info)
  if info.change_type == "ChangeTypeAngry" then
    self:setAngry(info.change_value)
    echo("info.change_value:"..info.change_value)
  elseif info.change_type == "ChangeTypeMaxHp" then
    self:setHp(info.change_value * self:getInitHpRatio() / 10000)
    self:setMaxHp(info.change_value)
  elseif info.change_type == "ChangeTypeCurHp" then
    self:setHp(info.change_value)
  elseif info.change_type == "ChangeTypeGroup" then
    self:setGroup(info.change_value)
  end
end

------
--  Getter & Setter for
--      BattleCard._InitHpRatio 
-----
function BattleCard:setInitHpRatio(InitHpRatio)
	self._InitHpRatio = InitHpRatio
end

function BattleCard:getInitHpRatio()
	return self._InitHpRatio
end

------
--  Getter & Setter for
--      BattleCard._DamageBear 
-----
function BattleCard:setDamageBear(DamageBear)
	self._DamageBear = DamageBear
end

function BattleCard:getDamageBear()
	return self._DamageBear
end

------
--  Getter & Setter for
--      BattleCard._DamageOut 
-----
function BattleCard:setDamageOut(DamageOut)
	self._DamageOut = DamageOut
end

function BattleCard:getDamageOut()
	return self._DamageOut
end

------
--  Getter & Setter for
--      BattleCard._View
-----
function BattleCard:setView(View)
  self._View = View
end

function BattleCard:getView()
  return self._View
end

------
--  Getter & Setter for
--      BattleCard._AttackFix 
-----
function BattleCard:setAttackFix(AttackFix)
	self._AttackFix = AttackFix
end

function BattleCard:getAttackFix()
	return self._AttackFix
end

------
--  Getter & Setter for
--      BattleCard._HpFix 
-----
function BattleCard:setHpFix(HpFix)
	self._HpFix = HpFix
end

function BattleCard:getHpFix()
	return self._HpFix
end

------
--  Getter & Setter for
--      BattleCard._Index
-----
function BattleCard:setIndex(Index)
  self._Index = Index
end

function BattleCard:getIndex()
  return self._Index
end

------
--  Getter & Setter for
--      BattleCard._InfoId
-----
function BattleCard:setInfoId(InfoId)
  self._InfoId = InfoId
  self._ConfigId = self._InfoId
end

function BattleCard:getInfoId()
  return self._InfoId
end


------
--  Getter & Setter for
--      BattleCard._Hp
-----
function BattleCard:setHp(Hp)
  self._Hp = Hp
end

function BattleCard:getHp()
  return self._Hp
end

------
--  Getter & Setter for
--      BattleCard._MaxHp
-----
function BattleCard:setMaxHp(MaxHp)
  self._MaxHp = MaxHp
end

function BattleCard:getMaxHp()
  return self._MaxHp
end

------
--  Getter & Setter for
--      BattleCard._Angry
-----
function BattleCard:setAngry(Angry)
  self._Angry = Angry
end

function BattleCard:getAngry()
  return self._Angry
end

------
--  Getter & Setter for
--      BattleCard._MaxAngry
-----
function BattleCard:setMaxAngry(MaxAngry)
  self._MaxAngry = MaxAngry
end

function BattleCard:getMaxAngry()
  return self._MaxAngry
end


------
--  Getter & Setter for
--      BattleCard._Pos
-----
function BattleCard:setPos(Pos)
  self._Pos = Pos
  self:setPosition(Pos)
end

function BattleCard:getPos()
  return self._Pos
end


------
--  Getter & Setter for
--      BattleCard._IsPrimary
-----
function BattleCard:setIsPrimary(IsPrimary)
  self._IsPrimary = IsPrimary
end

function BattleCard:getIsPrimary()
  return self._IsPrimary
end

------
--  Getter & Setter for
--      BattleCard._Group
-----
function BattleCard:setGroup(Group)
  self._Group = Group
  
  if self:getView() ~= nil then
    self:getView():setGroupView(Group)
  end
end

function BattleCard:getGroup()
  return self._Group
end

------
--  Getter & Setter for
--      BattleCard._OriginalGroup 
-----
function BattleCard:setOriginalGroup(OriginalGroup)
	self._OriginalGroup = OriginalGroup
end

function BattleCard:getOriginalGroup()
	return self._OriginalGroup
end

------
--  Getter & Setter for
--      BattleCard._IsRotate
-----
function BattleCard:setIsRotate(IsRotate)
  self._IsRotate = IsRotate
end

function BattleCard:getIsRotate()
  return self._IsRotate
end

------
--  Getter & Setter for
--      BattleCard._Type
-----
function BattleCard:setType(Type)
  self._Type = Type
end

function BattleCard:getType()
  return self._Type
end

------
--  Getter & Setter for
--      BattleCard._IsMySide
-----
function BattleCard:setIsMySide(IsMySide)
  self._IsMySide = IsMySide
end

function BattleCard:getIsMySide()
  return self._IsMySide
end

------
--  Getter & Setter for
--      BattleCard._IsBoss 
-----
function BattleCard:setIsBoss(IsBoss)
	self._IsBoss = IsBoss
end

function BattleCard:getIsBoss()
	return self._IsBoss
end


