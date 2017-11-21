CollectionEquipmentView = class("CollectionEquipmentView",function ()
  return display.newNode()
end)
function CollectionEquipmentView:ctor(equipData)
  self:setData(equipData)
end

------
--  Getter & Setter for
--      CollectionEquipmentView._Data 
-----
function CollectionEquipmentView:setData(Data)
	self._Data = Data
	local equipData = Data
	self:removeAllChildrenWithCleanup(true)
	
	local rank = 5
	local equipmentIcon = nil
  local scale = 1
  local rank = equipData:getRank()
  
--  local bg = _res(3059009+rank)
--  bg:setScale(0.95)
--  self:addChild(bg)
  
  local typeIcon = nil
  if equipData:getEquipType() == 1 then
     typeIcon = display.newSprite("#gallery_bg_weapon.png")
  elseif equipData:getEquipType() == 2 then
     typeIcon = display.newSprite("#gallery_bg_armor.png")
  elseif equipData:getEquipType() == 3 then
     typeIcon = display.newSprite("#gallery_bg_as.png")
  end
  
  if typeIcon ~= nil then
     self:addChild(typeIcon)
  end
  
  
  local boader = _res(3021041+rank)
  self:addChild(boader)
  
  if equipData:getHasOwend() == false then
     equipmentIcon = display.newSprite("#gallery-imgage-wenhao.png")
     scale = 0.63
  else
     equipmentIcon = _res(equipData:getIconId())
  end
  equipmentIcon:setScale(scale)
 
  self:addChild(equipmentIcon)
  self:setContentSize(CCSizeMake(boader:getContentSize().width*1.12,boader:getContentSize().height*1.12))
	
end

function CollectionEquipmentView:getData()
	return self._Data
end

return CollectionEquipmentView