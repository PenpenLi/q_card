EquipmentChangeListItem = class("EquipmentChangeListItem",function()
  return display.newNode()
end)
function EquipmentChangeListItem:ctor(equipmentData)
  self:setNodeEventEnabled(true)
  self:setAnchorPoint(ccp(0.5,0.5))
  
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("spriteListBg","CCScale9Sprite")
  pkg:addProperty("nodeEquipIcon","CCNode")
  pkg:addProperty("labelName","CCLabelTTF")
  pkg:addProperty("labelBasePropValue","CCLabelTTF")
  pkg:addProperty("nodeStars","CCNode")
  for i = 1 ,5 do
    pkg:addProperty("equip_star_"..i,"CCSprite")
  end
  
  for i = 1 ,4 do
    pkg:addProperty("bmLabelRandomPropName"..i,"CCLabelBMFont")
  end
  
  for i = 1 ,4 do
    pkg:addProperty("labelRandomPropValue"..i,"CCLabelTTF")
  end
  
  local ccbi,owner = ccbHelper.load("equipment_change_list_item.ccbi","equipment_change_list_item","CCNode",pkg)
  self:addChild(ccbi)
  
  for i = 1 ,4 do
    self["labelRandomPropValue"..i]:setString("")
  end
  
  self._nodeStarsInitX = self.nodeStars:getPositionX()
  self:setEquipmentData(equipmentData)
end

------
--  Getter & Setter for
--      EquipmentChangeListItem._EquipmentData 
-----
function EquipmentChangeListItem:setEquipmentData(EquipmentData)
	self._EquipmentData = EquipmentData
	
	if EquipmentData == nil then
    return
  end
  
  --show stars
  for i = 1 ,5 do
    if EquipmentData:getGrade() >= i then
      self["equip_star_"..i]:setVisible(true)
    else
      self["equip_star_"..i]:setVisible(false)
    end
  end
  
  for i = 1 ,4 do
    self["bmLabelRandomPropName"..i]:setString("")
    self["labelRandomPropValue"..i]:setString("")
  end
  
  --update equip star pos
  local rank = EquipmentData:getGrade()
  
  local star_distance = 10
  self.nodeStars:setPositionX(self._nodeStarsInitX + star_distance*(5 - rank) )

  self.labelName:setString(EquipmentData:getName().."  Lv."..EquipmentData:getLevel())
  
  --create icon
  self.nodeEquipIcon:removeAllChildrenWithCleanup(true)
  local icon = DropItemView.new(EquipmentData:getConfigId())
  self.nodeEquipIcon:addChild(icon)
  
  local attrTbl = EquipmentData:getSkillAttrExt()
  local attrCount = 0
  for i = 1, table.getn(attrTbl) do 
    if attrTbl[i].genType == 1 then --base
      self.labelBasePropValue:setString(attrTbl[i].name.." "..attrTbl[i].data)
    else  --random
      attrCount = attrCount + 1     
      if attrCount <= 4 then 
        self["bmLabelRandomPropName"..attrCount]:setString(attrTbl[i].name)
        self["labelRandomPropValue"..attrCount]:setString(attrTbl[i].data.."")
      end
    end
  end
  
end

function EquipmentChangeListItem:getEquipmentData()
	return self._EquipmentData
end

function EquipmentChangeListItem:getContentSize()
  return self.spriteListBg:getContentSize()
end

return EquipmentChangeListItem