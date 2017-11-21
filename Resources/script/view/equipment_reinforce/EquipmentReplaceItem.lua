EquipmentReplaceItem = class("EquipmentReplaceItem",function()
  return display.newNode()
end)
function EquipmentReplaceItem:ctor(idx,lastAttr,newAttr)
  self:setNodeEventEnabled(true)
  self:setAnchorPoint(ccp(0.5,0.5))
  
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("nodeSize","CCNode")
  pkg:addProperty("spriteArrow","CCSprite")
  pkg:addProperty("bmLabelPerPropName","CCLabelBMFont")
  pkg:addProperty("bmLabelAfterPropName","CCLabelBMFont")
  pkg:addProperty("bmLabelAfterPropValue","CCLabelBMFont")
  pkg:addProperty("bmLabelPrePropValue","CCLabelBMFont")
  pkg:addProperty("labelPreArea","CCLabelTTF")
  pkg:addProperty("labelAfterArea","CCLabelTTF")
  
  local ccbi,owner = ccbHelper.load("equipment_replace_item.ccbi","equipment_replace_item","CCNode",pkg)
  self:addChild(ccbi)
  self.labelPreArea:setString("")
  self.labelAfterArea:setString("")
  self.spriteArrow:setVisible(false)
  
  local id = lastAttr[idx].id
  self.bmLabelPerPropName:setString(lastAttr[idx].name)
  self.bmLabelPrePropValue:setString(lastAttr[idx].data)
  
  if lastAttr[idx].propItem ~= nil then
    self.labelPreArea:setString("(MAX"..lastAttr[idx].propItem.max..")")
  end
  
  for key, info in pairs(newAttr) do
    if info.id == id then
      self.spriteArrow:setVisible(true)
    	self.bmLabelAfterPropName:setString(info.name)
    	self.bmLabelAfterPropValue:setString(info.data)
    	if info.propItem ~= nil then
        self.labelAfterArea:setString("(MAX"..info.propItem.max..")")
      end
      break
    end
  end
 
end

function EquipmentReplaceItem:getContentSize()
  return self.nodeSize:getContentSize()
end

return EquipmentReplaceItem