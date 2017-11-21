EquipLockItem = class("EquipLockItem",function()
  return display.newNode()
end)
function EquipLockItem:ctor(equipmentArrTable)
  print("equipmentArrTable:")
  dump(equipmentArrTable)
  self:setNodeEventEnabled(true)
  self:setAnchorPoint(ccp(0.5,0.5))
   local bg = display.newSprite("#equipment_refresh_btn_lock1.png")
  self:addChild(bg)
  self._bg = bg
  local lockBg = display.newSprite("#equipment_refresh_btn_lock2.png")
  self:addChild(lockBg)
  self._lockBg = lockBg
  self:setIsLocked(false)
  
  local labelPer = CCLabelBMFont:create(equipmentArrTable.name, "client/widget/words/card_name/xilian_word.fnt") 
  labelPer:setAnchorPoint(ccp(1,0.5))
  self:addChild(labelPer)
  labelPer:setPosition(-10,10)
  
  local labelValue = CCLabelTTF:create("","Courier-Bold",22)
  labelValue:setAnchorPoint(ccp(0,0.5))
  labelValue:setString(""..equipmentArrTable.data)
  self:addChild(labelValue)
  labelValue:setPosition(-7,10)
  
  if equipmentArrTable.propItem ~= nil then
    local labelArea = CCLabelTTF:create(equipmentArrTable.propItem.min.."~"..equipmentArrTable.propItem.max,"Courier-Bold",22)
    labelArea:setAnchorPoint(ccp(0.5,0.5))
    self:addChild(labelArea)
    labelArea:setPosition(0,-15)
    self._labelArea = labelArea
  end
  
  self:setPropType(equipmentArrTable.eType)
  self:setPropId(equipmentArrTable.id)
  
end

------
--  Getter & Setter for
--      EquipLockItem._PropId 
-----
function EquipLockItem:setPropId(PropId)
	self._PropId = PropId
end

function EquipLockItem:getPropId()
	return self._PropId
end

------
--  Getter & Setter for
--      EquipLockItem._Delegate 
-----
function EquipLockItem:setDelegate(Delegate)
	self._Delegate = Delegate
end

function EquipLockItem:getDelegate()
	return self._Delegate
end

------
--  Getter & Setter for
--      EquipLockItem._PropType 
-----
function EquipLockItem:setPropType(PropType)
	self._PropType = PropType
end

function EquipLockItem:getPropType()
	return self._PropType
end

function EquipLockItem:switchLock()
  if self:getIsLocked() == true then
    self:setIsLocked(false)
  else
    self:setIsLocked(true)
  end
  if self:getDelegate() ~= nil then
    self:getDelegate():updateCost()
  end
end

function EquipLockItem:onEnter()
  
end

function EquipLockItem:onExit()
  self:setDelegate(nil)
end

function EquipLockItem:getContentSize()
  return self._bg:getContentSize()
end

------
--  Getter & Setter for
--      EquipLockItem._IsLocked 
-----
function EquipLockItem:setIsLocked(IsLocked)
  self._IsLocked = (IsLocked == true)
  self._lockBg:setVisible(self._IsLocked == true)
  self._bg:setVisible(self._IsLocked ~= true)
end

function EquipLockItem:getIsLocked()
  return self._IsLocked
end

return EquipLockItem