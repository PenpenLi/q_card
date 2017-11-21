DropItemView = class("DropItemView",function ()
  return display.newNode()
end)

function DropItemView:ctor(configId,count,type,isGray)
  self:setNodeEventEnabled(true)
  self:setCascadeOpacityEnabled(true)
  self._nodeContainer = display.newNode()
  self:setAnchorPoint(ccp(0.5,0.5))
  self:addChild(self._nodeContainer)
  self._nodeContainer:setAnchorPoint(ccp(0.5,0.5))
  self._nodeContainer:setPosition(95/2,95/2)
  self._isGray = isGray
  self:setCount(count)
  
  if configId == 0 then
    assert(type ~= nil)
  end
  self:setType(type)
  self:setConfigId(configId)
--  if type ~= nil then
--    assert(type == self:getType())
--  end
end

------
--  Getter & Setter for
--      DropItemView._Type 
-----
function DropItemView:setType(Type)
	self._Type = Type
end

function DropItemView:getType()
	return self._Type
end

------
--  Getter & Setter for
--      DropItemView._Count 
-----
function DropItemView:setCount(Count)
	 self._Count = Count
	 if self._countLabel ~= nil then
     self._countLabel:removeFromParentAndCleanup(true)
     self._countLabel = nil
   end
      
	 if Count ~= nil and Count > 1 then 
      local numStr = nil
      if Count > 10000 then 
        if Count%10000 >= 1000 then 
          numStr = string.format("%.1f", Count/10000).._tr("wan")
        else 
          numStr = _tr("wan_%{count}", {count=Count/10000})
        end
      else 
        numStr = string.format("%d", Count)
      end
      
      self:setShowString(numStr)
  end 
end

function DropItemView:setShowString(str,color)
   if self._countLabel ~= nil then
     self._countLabel:removeFromParentAndCleanup(true)
     self._countLabel = nil
   end
   local label = CCLabelBMFont:create(str, "client/widget/words/card_name/number_skillup.fnt")
   local labelSize = tolua.cast(label:getContentSize(),"CCSize")  
   label:setPosition(ccp(95/2-labelSize.width/2 , -95/2+labelSize.height/2+7))
   if color ~= nil then
    label:setColor(color)
   end
   
   self:addChild(label)
   self._countLabel = label
end

function DropItemView:getGrayRes(res)
  if not res then
    return nil
  end
  
  local grayIcon = nil
  if res.filePath ~= nil then
    grayIcon = GraySprite:create(res.filePath)
  elseif res.frameName ~= nil then
    grayIcon = GraySprite:createWithSpriteFrameName(res.frameName)
  end
  
  return grayIcon
end


function DropItemView:getCount()
	return self._Count
end

------
--  Getter & Setter for
--      DropItemView._Name 
-----
function DropItemView:setName(Name)
	self._Name = Name
end

function DropItemView:getName()
	return self._Name
end

------
--  Getter & Setter for
--      DropItemView._ConfigId 
-----
function DropItemView:setConfigId(ConfigId)
	 self._ConfigId = ConfigId
	 local type = 6
	 if ConfigId >= 1 and ConfigId <= 100 then
--	 or ConfigId == 4 --coin 
--   or ConfigId == 5 --money 
--   or ConfigId == 12 --token 
--   or ConfigId == 19 then -- telent point
     assert(ConfigId ~= 6 and ConfigId ~= 7 and ConfigId ~= 8)
	   type = ConfigId
   elseif ConfigId >= 20000000 and ConfigId <= 29999999 then --item
     type = 6
   elseif ConfigId >= 30000000 and ConfigId <= 39999999 then --equipment
     type = 7
   elseif ConfigId >= 10000000 and ConfigId <= 19999999 then --card
     type = 8
   elseif ConfigId == 0 then
     assert(self:getType() ~= nil)
     assert(self:getType() ~= 6 and self:getType() ~= 7 and self:getType() ~= 8)
     ConfigId = self:getType()
     self._ConfigId = ConfigId
   else
     echo("UNKNOW ITEM ID:",ConfigId)
     assert(false)
   end
  self:setType(type)
	local itemView = nil
	if self._ConfigId ~= nil then
	   local scale = 1
	   if self._Type == 6 or (ConfigId >= 1 and ConfigId <= 100) then
	      if AllConfig.item[ConfigId] ~= nil then
          local rank = AllConfig.item[ConfigId].rare
          local boader = _res(3021040+rank)
          self:addChild(boader)
          --scale = 0.85
          
          local m_quality = AllConfig.item[ConfigId].quality
          if m_quality > 0 then
             local qualityIcon = _res(3036000 + AllConfig.item[ConfigId].quality)
             self:addChild(qualityIcon)
             qualityIcon:setPosition(ccp(20,30))
          end

          itemView = _res(AllConfig.item[ConfigId].item_resource)

          self:setName(AllConfig.item[ConfigId].item_name)
          if AllConfig.item[ConfigId].item_type == 3 or AllConfig.item[ConfigId].item_type == 4 then -- 碎片
             if  AllConfig.item[ConfigId].item_type == 3 then
                scale = 0.66
             else
                local equipmentbg = _res(3059008 + rank)
                self:addChild(equipmentbg,-2)
             end
             local spText = display.newSprite("img/common/suipian.png")
             self:addChild(spText)
             spText:setPosition(-27,27)
          end
        else
          echo("Item ConfigId: "..ConfigId.." CAN NOT FIND")
        end
     elseif self._Type == 8 then
        local rank = AllConfig.unit[ConfigId].card_rank+1
        local boader = _res(3021040+rank)
        
        if self._isGray == true then
           boader = self:getGrayRes(boader)
        end
        self:addChild(boader)
        
        itemView = _res(AllConfig.unit[ConfigId].unit_head_pic)
        if self._isGray == true then
           itemView = self:getGrayRes(itemView)
        end
        
        scale = 0.66
        self:setName(AllConfig.unit[ConfigId].unit_name)
     elseif self._Type == 7 then
        if AllConfig.equipment[ConfigId] ~= nil then
--          local rank = AllConfig.equipment[ConfigId].rare
--          local equipmentbg = _res(3059008 + rank)
--          self:addChild(equipmentbg,-2)
--          
--          local boader = _res(3021040+rank)
--          self:addChild(boader,-2)
--          
--          local m_quality = AllConfig.equipment[ConfigId].quality
--          if m_quality > 0 then
--             local qualityIcon = _res(3036000 + AllConfig.equipment[ConfigId].quality)
--             self:addChild(qualityIcon)
--             qualityIcon:setPosition(ccp(20,30))
--          end
          
          local grade = AllConfig.equipment[ConfigId].equip_rank + 1
          
          local equipmentbg = _res(3059008 + grade)
          self:addChild(equipmentbg,-2)
          
          local subGrade = AllConfig.equipment[ConfigId].quality
          local smoothGrade = math.max(0, (grade-3)*3) + grade-1 + subGrade 
          
          local boader = _res(3021051 + smoothGrade)
          self:addChild(boader,-2)
  
          itemView = _res(AllConfig.equipment[ConfigId].equip_icon)
          self:setName(AllConfig.equipment[ConfigId].name)
        end
     end
     
     if itemView ~= nil then
        self._nodeContainer:removeAllChildrenWithCleanup(true)
        itemView:setScale(scale)
        self._nodeContainer:addChild(itemView)
        self._nodeContainer:setContentSize(CCSizeMake(95,95))
     end
  end
end

function DropItemView:getConfigId()
	return self._ConfigId
end

------
--  Getter & Setter for
--      DropItemView._ContentSize 
-----

function DropItemView:getContentSize()
	--return self._nodeContainer:getContentSize()
	local size = 95 * self:getScale()
	return CCSizeMake(size,size)
end

return DropItemView