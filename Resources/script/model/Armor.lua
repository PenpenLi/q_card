require("model.Equipment")

Armor = class("Armor",Equipment)

function Armor:ctor()
  Armor.super.ctor(self)
--  self:setConfigId(configId)
--  if configId == nil then
--    return
end

function Armor:setDominance(dominance)
	self._dominance = dominance
end

function Armor:getDominance()
	return self._dominance
end

function Armor:setEvade(evade)
	self._evade = evade
end

function Armor:getEvade()
	return self._evade
end

function Armor:setDamageReduce(damageReduce)
	self._damageReduce = damageReduce
end

function Armor:getDamageReduce()
	return self._damageReduce
end

function Armor:setToughness(tougness)
	self._tougness = tougness
end

function Armor:getToughness()
	return self._tougness
end

return Armor