CollectionEquipment = class("CollectionEquipment")
function CollectionEquipment:ctor(configId)
  self:setHasOwend(false)
  self:setConfigId(configId)
  self:setIconId(AllConfig.equipment[configId].equip_icon)
  self:setRank(AllConfig.equipment[configId].equip_rank)
  self:setEquipType(AllConfig.equipment[configId].equip_type)
  self:setEquipRoot(AllConfig.equipment[configId].equip_root)
  self:setRootName(AllConfig.equipment[configId].root_name)
end

------
--  Getter & Setter for
--      CollectionEquipment._ConfigId 
-----
function CollectionEquipment:setConfigId(ConfigId)
	self._ConfigId = ConfigId
end

function CollectionEquipment:getConfigId()
	return self._ConfigId
end

------
--  Getter & Setter for
--      CollectionEquipment._RootName 
-----
function CollectionEquipment:setRootName(RootName)
	self._RootName = RootName
end

function CollectionEquipment:getRootName()
	return self._RootName
end
------
--  Getter & Setter for
--      CollectionEquipment._EquipRoot 
-----
function CollectionEquipment:setEquipRoot(EquipRoot)
	self._EquipRoot = EquipRoot
end

function CollectionEquipment:getEquipRoot()
	return self._EquipRoot
end

------
--  Getter & Setter for
--      CollectionEquipment._EquipType 
-----
function CollectionEquipment:setEquipType(EquipType)
	self._EquipType = EquipType
end

function CollectionEquipment:getEquipType()
	return self._EquipType
end

------
--  Getter & Setter for
--      CollectionEquipment._Rank 
-----
function CollectionEquipment:setRank(Rank)
	self._Rank = Rank
end

function CollectionEquipment:getRank()
	return self._Rank
end

------
--  Getter & Setter for
--      CollectionEquipment._IconId 
-----
function CollectionEquipment:setIconId(IconId)
	self._IconId = IconId
end

function CollectionEquipment:getIconId()
	return self._IconId
end
------
--  Getter & Setter for
--      CollectionEquipment._HasOwend 
-----
function CollectionEquipment:setHasOwend(HasOwend)
	self._HasOwend = HasOwend
end

function CollectionEquipment:getHasOwend()
	return self._HasOwend
end

return CollectionEquipment