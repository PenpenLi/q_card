Item = class("Item")
Item._name = ""
function Item:ctor()
end

Item._grade = 1

function Item:setId(id)
    self._id = id
end

function Item:getId()
    return self._id
end
------
--  Getter & Setter for
--      Item._ConfigId 
-----
function Item:setConfigId(ConfigId)
	self._ConfigId = ConfigId
end

function Item:getConfigId()
	return self._ConfigId
end

function Item:setSalePrice(SalePrice)
  self._SalePrice = SalePrice
end

function Item:getSalePrice()
  return self._SalePrice
end

function Item:setName(name)
	self._name = name
end

function Item:getName()
	return self._name
end

function Item:setGrade(grade)
  self._grade = grade
end

function Item:getGrade()
  return self._grade
end

function Item:setMaxGrade(grade)
  self._maxGrade = grade
end

function Item:getMaxGrade()
  return self._maxGrade
end


------
--  Getter & Setter for
--      Item._thumbnailTextureName 
-----
function Item:setThumbnailTextureName(thumbnailTextureName)
	self._thumbnailTextureName = thumbnailTextureName
end

function Item:getThumbnailTextureName()
	return self._thumbnailTextureName
end

------
--  Getter & Setter for
--      Item._integrityTextureName 
-----
function Item:setIntegrityTextureName(integrityTextureName)
	self._integrityTextureName = integrityTextureName
end

function Item:getIntegrityTextureName()
	return self._integrityTextureName
end

function Item:setIconId(iconId)
  self._iconId = iconId
end

function Item:getIconId()
  return self._iconId
end

return Item




