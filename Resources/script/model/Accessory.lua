require("model.Equipment")

Accessory = class("Accessory",Equipment)

function Accessory:ctor()
  Accessory.super.ctor(self)
end

function Accessory:setEvade(evade)
	self._evade = evade
end

function Accessory:getEvade()
	return self._evade
end

function Accessory:setCritical(critical)
	self._critical = critical
end

function Accessory:getCritical()
	return self._critical
end

function Accessory:setToughness(toughness)
	self._toughness = toughness
end

function Accessory:getToughness()
	return self._toughness
end

function Accessory:setBlock(block)
	self._block = block
end

function Accessory:getBlock()
	return self._block
end

function Accessory:setDamageReduce(damageReduce)
	self._damageReduce = damageReduce
end

function Accessory:getDamageReduce()
	return self._damageReduce
end

function Accessory:setReflect(reflect)
	self._reflect = reflect
end

function Accessory:getReflect()
	return self._reflect
end

return Accessory