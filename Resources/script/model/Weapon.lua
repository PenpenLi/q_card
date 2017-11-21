require("model.Equipment")

Weapon = class("Weapon",Equipment)

function Weapon:ctor()
  Weapon.super.ctor(self)
end

function Weapon:setDamage(damage)
  self._damage = damage
end

function Weapon:getDamage()
  return self._damage
end

function Weapon:setIntelligence(intelligence)
  self._intelligence = intelligence
end

function Weapon:getIntelligence()
  return self._intelligence
end

function Weapon:setStrength(strength)
	self._strength = strength
end

function Weapon:getStrength()
	return self._strength
end

function Weapon:setHit(hit)
	self._hit = hit
end

function Weapon:getHit()
	return self._hit
end

function Weapon:setEvade(evade)
	self._evade = evade
end

function Weapon:getEvade()
	return self._evade
end

function Weapon:setCritical(critical)
	self._critical = critical
end

function Weapon:getCritical()
	return self._critical
end

function Weapon:setIsDebris(isDebris)
  self._isDebris = isDebris
end

function Weapon:getIsDebris()
  return self._isDebris
end

return Weapon
