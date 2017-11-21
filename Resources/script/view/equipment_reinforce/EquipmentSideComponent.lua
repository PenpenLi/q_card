require("model.equipment_reinforce.EquipmentReinforceConfig")
require("view.equipment_reinforce.EquipLockItem")
require("view.equipment_reinforce.EquipmentReplaceItem")

EquipmentSideComponent = class("EquipmentSideComponent",function()
  return display.newNode()
end)
local commonIconScale = 0.8
function EquipmentSideComponent:ctor(componentType,equipmentData)
  self:initCcbi()
  self._EquipmentData = equipmentData
  
  --default
  self:setTouchesButtons({})
  self:setLockStates({})
  self.spriteIsMaxLevelUp:setVisible(false)
  self._maxLevelUpEnabled = self.spriteIsMaxLevelUp:isVisible()
  
  self:setComponentType(componentType)
end

function EquipmentSideComponent:getContentSize()
  return self.spriteComponentBg:getContentSize()
end

------
--  Getter & Setter for
--      EquipmentSideComponent._ComponentType 
-----
function EquipmentSideComponent:setComponentType(ComponentType)
  assert(ComponentType ~= nil,"EquipmentSideComponent:Must type an CommonentType when create this component")
  assert((ComponentType == EquipmentReinforceConfig.ComponentTypeSideLvUp 
       or ComponentType == EquipmentReinforceConfig.ComponentTypeSideGradeUp 
       or ComponentType == EquipmentReinforceConfig.ComponentTypeSideRefresh
       or ComponentType == EquipmentReinforceConfig.ComponentTypeSideTurnExclusive),
       "Invaild CommonentType")
  if ComponentType == self._ComponentType then
    return
  end
  
  self._ComponentType = ComponentType
  self:updateView()
end

function EquipmentSideComponent:getComponentType()
  return self._ComponentType
end

function EquipmentSideComponent:initCcbi()
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("nodeCommon","CCNode")
  pkg:addProperty("nodeRefresh","CCNode")
  pkg:addProperty("nodeGradeUp","CCNode")
  pkg:addProperty("nodeLvUp","CCNode")
  pkg:addProperty("nodeXilianCost","CCNode")
  
  pkg:addProperty("spriteComponentBg","CCSprite")
  
  --sample equipment info
  pkg:addProperty("node_equipment","CCNode")
  pkg:addProperty("label_name","CCLabelTTF")
  pkg:addProperty("label_level","CCLabelTTF")
  for i = 1 ,5 do
    pkg:addProperty("equip_star_"..i,"CCSprite")
  end
  
  --common
  pkg:addProperty("nodePreEquipmentIcon","CCNode")
  pkg:addProperty("nodeAfterEquipmentIcon","CCNode")
  
  pkg:addProperty("labelPreLv","CCLabelTTF")
  pkg:addProperty("labelAfterLv","CCLabelTTF")
  
  pkg:addProperty("nodeEquipInfoSample","CCNode")
  pkg:addProperty("nodeCoinCost","CCNode")
  pkg:addProperty("labelCoinCost","CCLabelTTF")
  
  --level up
  pkg:addProperty("labelLevelUpTip","CCLabelTTF")
  pkg:addProperty("bmLabelLevelUpPerBaseName","CCLabelBMFont")
  pkg:addProperty("bmLabelLevelUpPerBaseValue","CCLabelTTF")
  pkg:addProperty("bmLabelLevelUpPerBaseValuePlus","CCLabelTTF")
  pkg:addProperty("spriteIsMaxLevelUp","CCSprite")
  pkg:addProperty("spriteTipLevelUp","CCSprite")
  pkg:addProperty("btnLevelUp","CCControlButton")
  pkg:addProperty("btnCheckBox","CCMenuItemImage")
  pkg:addFunc("onClickLevelUpHandler",EquipmentSideComponent.onClickLevelUpHandler)
  pkg:addFunc("onClickMaxLvelUpCheckBoxHandler",EquipmentSideComponent.onClickMaxLvelUpCheckBoxHandler)
                   
  --grade up
  pkg:addProperty("bmLabelGradeUpPerBaseName","CCLabelBMFont")
  pkg:addProperty("bmLabelGradeUpPerBaseValue","CCLabelTTF")
  pkg:addProperty("bmLabelGradeUpPerBaseValuePlus","CCLabelTTF")
  
  pkg:addProperty("bmLabelGradeUpPerNew1Name","CCLabelBMFont")
  pkg:addProperty("bmLabelGradeUpPerNew1Value","CCLabelTTF")
  pkg:addProperty("bmLabelGradeUpPerNew1ValuePlus","CCLabelTTF")
  
  pkg:addProperty("bmLabelGradeUpPerNew2Name","CCLabelBMFont")
  pkg:addProperty("bmLabelGradeUpPerNew2Value","CCLabelTTF")
  pkg:addProperty("bmLabelGradeUpPerNew2ValuePlus","CCLabelTTF")
  
  pkg:addProperty("nodeGradeUpUnknowPer1","CCNode")
  pkg:addProperty("nodeGradeUpUnknowPer2","CCNode")
  
  pkg:addProperty("nodeGradeUpNewPer1","CCNode")
  pkg:addProperty("nodeGradeUpNewPer2","CCNode")
  
  pkg:addProperty("nodeGradeUpItemCost","CCNode")
  pkg:addProperty("labelGradeUpTip","CCLabelTTF")
  pkg:addProperty("btnGradeUp","CCControlButton")
  pkg:addProperty("btnGradeUpBack","CCControlButton")
  pkg:addFunc("backFromGradeUpHandler",EquipmentSideComponent.backFromGradeUpHandler)
  pkg:addFunc("onClickGradeUpHandler",EquipmentSideComponent.onClickGradeUpHandler)
  
  --turn exclusive
  pkg:addProperty("nodeTurnExclusive","CCNode")
  pkg:addProperty("nodePasiveSkillDesc","CCNode")
  pkg:addProperty("labelActiveSkillDesc","CCLabelTTF")
  pkg:addProperty("btnTurnExclusive","CCControlButton")
  pkg:addFunc("onClickTurnExclusiveHandler",EquipmentSideComponent.onClickTurnExclusiveHandler)
  
  --refresh
  pkg:addProperty("nodeAfterXilian","CCNode")
  pkg:addProperty("nodeBeforeXilian","CCNode")
  pkg:addProperty("btnRefresh","CCControlButton")
  pkg:addProperty("btnCancleReplece","CCControlButton")
  pkg:addProperty("btnDoReplece","CCControlButton")
  
  pkg:addFunc("onClickRefreshHandler",EquipmentSideComponent.onClickRefreshHandler)
  pkg:addFunc("doRelpeceHandler",EquipmentSideComponent.doRelpeceHandler)
  pkg:addFunc("cancleRepleceHandler",EquipmentSideComponent.cancleRepleceHandler)
  
  local sideComponent,owner = ccbHelper.load("equipment_reinforce_side.ccbi","equipment_reinforce_side","CCNode",pkg)
  self:addChild(sideComponent)
  
  local touchPriority = -200
  self.btnLevelUp:setTouchPriority(touchPriority)
  self.btnGradeUp:setTouchPriority(touchPriority)
  self.btnGradeUpBack:setTouchPriority(touchPriority)
  self.btnTurnExclusive:setTouchPriority(touchPriority)
  local menuCkeckBox = tolua.cast(self.btnCheckBox:getParent(),"CCMenu")
  menuCkeckBox:setTouchPriority(touchPriority)
  self.btnRefresh:setTouchPriority(touchPriority)
  self.btnCancleReplece:setTouchPriority(touchPriority)
  self.btnDoReplece:setTouchPriority(touchPriority)
  
  self.labelLevelUpTip:setString(_tr("equip_fast_level_tip"))
  
  self.labelActiveSkillDesc:setColor(sgVIOLET)
  self.labelActiveSkillDesc:setDimensions(CCSizeMake(220,0))
  
  
  
  _registNewBirdComponent(124101,self.btnCheckBox)
  _registNewBirdComponent(124102,self.btnLevelUp)
  _registNewBirdComponent(124201,self.btnGradeUp)
  _registNewBirdComponent(124501,self.btnTurnExclusive)
   
  --_executeNewBird()
end

function EquipmentSideComponent:doRelpeceHandler()
  EquipmentReinforce:Instance():reqEquipXiLianReplace(self:getEquipmentData())
end

function EquipmentSideComponent:cancleRepleceHandler()
  self:updateView()
end

function EquipmentSideComponent:onClickMaxLvelUpCheckBoxHandler()
  if self.spriteIsMaxLevelUp:isVisible() == true then
    self.spriteIsMaxLevelUp:setVisible(false)
  else
    self.spriteIsMaxLevelUp:setVisible(true)
  end
  self._maxLevelUpEnabled = self.spriteIsMaxLevelUp:isVisible()
  _executeNewBird()
  self:updateView()
end

------
--  Getter & Setter for
--      EquipmentSideComponent._EquipmentData 
-----
function EquipmentSideComponent:setEquipmentData(EquipmentData)
	self._EquipmentData = EquipmentData
	self:updateView()
end

function EquipmentSideComponent:getEquipmentData()
	return self._EquipmentData
end

function EquipmentSideComponent:updateView(isSuccess)

  self:stopAllActions()
  --before update view
  if isSuccess == true then
    local equipmentData = self:getEquipmentData()
    local componentType = self:getComponentType()
    if componentType == EquipmentReinforceConfig.ComponentTypeSideLvUp then
      
      local dur = 0.06
    
      local anim,offsetX,offsetY,duration1 = _res(5020210)
      anim:setPosition(ccp(offsetX,offsetY))
      anim:getAnimation():play("default") 
      anim:setScale(commonIconScale)
      self.nodePreEquipmentIcon:addChild(anim)
      
      local doupdate = function()
        local anim,offsetX,offsetY,duration2 = _res(5020209)
        anim:setPosition(ccp(offsetX,offsetY))
        anim:getAnimation():play("default") 
        self.nodeAfterEquipmentIcon:addChild(anim)
        self:performWithDelay(function () 
          self:doUpdateView(isSuccess)
        end,duration2)
      end
      
      self:performWithDelay(function () 
        doupdate()
      end,duration1)
      
      
    else
      self:doUpdateView(isSuccess)
    end
  else
    self:doUpdateView(isSuccess)
  end
end

function EquipmentSideComponent:doUpdateView(isSuccess)
  self:setCostItems({})
  local equipmentData = self:getEquipmentData()
  local componentType = self:getComponentType()
  
  self.nodeCommon:setVisible(false)
  self.nodeRefresh:setVisible(false)
  self.nodeGradeUp:setVisible(false)
  self.nodeLvUp:setVisible(false)
  self.nodeEquipInfoSample:setVisible(false)
  self.spriteTipLevelUp:setVisible(false)
  self.btnLevelUp:setEnabled(true)
  self.nodeCoinCost:setVisible(true)
  self.nodeTurnExclusive:setVisible(false)
  self:setTouchesButtons(nil)
  self:setTouchesButtons({})
  
  local attrTbl = equipmentData:getSkillAttrExt()
  local attrCount = 0
  local baseValue = 0
  for i = 1, table.getn(attrTbl) do 
    if attrTbl[i].genType == 1 then --base
      --level up
      self.bmLabelLevelUpPerBaseName:setString(attrTbl[i].name)
      baseValue = toint(attrTbl[i].data)
      self.bmLabelLevelUpPerBaseValue:setString(" "..baseValue)
      local oldPropValue = equipmentData:getBaseAttr() + equipmentData:getImproveAttr() * (equipmentData:getLevel() - 1)
      local newPropValue = equipmentData:getBaseAttr() + equipmentData:getImproveAttr() * equipmentData:getLevel()
      
      self.bmLabelLevelUpPerBaseValuePlus:setString("+"..(newPropValue - oldPropValue))
      
      --grade up
      self.bmLabelGradeUpPerBaseName:setString(attrTbl[i].name)
      self.bmLabelGradeUpPerBaseValue:setString(" "..baseValue)
      
      self.bmLabelGradeUpPerBaseValuePlus:setString("")
    else  --random
      attrCount = attrCount + 1     
      if attrCount <= 4 then 
        --self["bmLabelGradeUpPerNew"..attrCount.."Name"]:setString(attrTbl[i].name)
        --self["bmLabelGradeUpPerNew"..attrCount.."Value"]:setString(attrTbl[i].data.."")
      end
    end
  end
  
  --commom
  self.nodeAfterEquipmentIcon:removeAllChildrenWithCleanup(true)
  self.nodePreEquipmentIcon:removeAllChildrenWithCleanup(true)
  
  
  --sample
  self.node_equipment:removeAllChildrenWithCleanup(true)
  local equipmentIcon = DropItemView.new(equipmentData:getConfigId())
  self.node_equipment:addChild(equipmentIcon)
  self.label_name:setString(equipmentData:getName())
  self.label_level:setString("Lv."..equipmentData:getLevel())
  --show stars
  for i = 1 ,5 do
    if equipmentData:getGrade() >= i then
      self["equip_star_"..i]:setVisible(true)
    else
      self["equip_star_"..i]:setVisible(false)
    end
  end
  
  
  if componentType == EquipmentReinforceConfig.ComponentTypeSideLvUp then
   self.nodeCommon:setVisible(true)
   self.nodeLvUp:setVisible(true)
   
   --before info
   local levelStr = "Lv."..equipmentData:getLevel()
   local equipmentIcon = DropItemView.new(equipmentData:getConfigId())
   equipmentIcon:setScale(commonIconScale)
   self.nodePreEquipmentIcon:addChild(equipmentIcon)
   self.labelPreLv:setString(levelStr)
   
   -- after info
   equipmentIcon = DropItemView.new(equipmentData:getConfigId())
   equipmentIcon:setScale(commonIconScale)
   self.nodeAfterEquipmentIcon:addChild(equipmentIcon)
   
   local equipmentType = equipmentData:getEquipType()
   local equipmentLevel = equipmentData:getLevel()
   local totalCost = 0
   
   local getCostByLevelAndType = function(equipmentType,equipmentLevel)
     local cost = -1
     if AllConfig.equipmentimprovecost[equipmentLevel] == nil then
       return cost
     end
     
     if equipmentType == EquipmentReinforceConfig.EquipmentTypeWeapon then
      cost = AllConfig.equipmentimprovecost[equipmentLevel].weapon_cost
     elseif equipmentType == EquipmentReinforceConfig.EquipmentTypeArmor then
      cost = AllConfig.equipmentimprovecost[equipmentLevel].armor_cost
     elseif equipmentType == EquipmentReinforceConfig.EquipmentTypeAccessory then
      cost = AllConfig.equipmentimprovecost[equipmentLevel].decoration_cost
     end
     
     return cost
   end
   
   totalCost = getCostByLevelAndType(equipmentType,equipmentLevel)
   local currentCoin = GameData:Instance():getCurrentPlayer():getCoin()
   
   if totalCost <= currentCoin and totalCost >= 0 then
     self.labelCoinCost:setColor(sgGREEN)
   else
     self.labelCoinCost:setColor(sgRED)
     self.btnLevelUp:setEnabled(false)
   end
   
   local targetLevel = equipmentLevel + 1
   local card = equipmentData:getCard()
   local playerLevel = GameData:Instance():getCurrentPlayer():getLevel()
   
   if targetLevel <= playerLevel then --first check
     if self._maxLevelUpEnabled == true and totalCost < currentCoin then
        for i = equipmentLevel, #AllConfig.equipmentimprovecost do
          local tempTargetLevel = i+1
          local nextLevelCost = getCostByLevelAndType(equipmentType,tempTargetLevel)
        	local tmpTotalCost = totalCost + nextLevelCost
        	if tempTargetLevel + 1 <= playerLevel and nextLevelCost >= 0 then
        	   if currentCoin >= tmpTotalCost then
        	     totalCost = tmpTotalCost 
        	     targetLevel = tempTargetLevel
        	     print("targetLevel:",targetLevel)
        	     self.labelCoinCost:setColor(sgGREEN)
        	     local oldPropValue = equipmentData:getBaseAttr() + equipmentData:getImproveAttr() * (equipmentData:getLevel() - 1)
               local newPropValue = equipmentData:getBaseAttr() + equipmentData:getImproveAttr() * targetLevel
        	     --local addProp = equipmentData:getBaseAttr() + equipmentData:getImproveAttr() * targetLevel
               self.bmLabelLevelUpPerBaseValuePlus:setString("+"..(newPropValue - oldPropValue))
               targetLevel = targetLevel + 1
        	   else
        	     break
        	   end
        	else
        	   print("maxLevel:",playerLevel)
        	   break
        	end
        end
     end
   else
     self.btnLevelUp:setEnabled(false)
     self.spriteTipLevelUp:setVisible(true)
     self.nodeCoinCost:setVisible(false)
   end
   
   levelStr = "Lv."..targetLevel
   self.labelAfterLv:setString(levelStr)
   self.labelCoinCost:setString(totalCost.."")
   
   if equipmentData:getLevel() >= GameData:Instance():getCurrentPlayer():getMaxLevel() then
     self.nodeCommon:setVisible(false)
     self.nodeEquipInfoSample:setVisible(true)
     self.bmLabelLevelUpPerBaseValuePlus:setString("")
   else
     self.nodeCommon:setVisible(true)
     self.nodeEquipInfoSample:setVisible(false)
   end
   
   
  elseif componentType == EquipmentReinforceConfig.ComponentTypeSideGradeUp then
   self.nodeCommon:setVisible(true)
   self.nodeGradeUp:setVisible(true)
   
   -- reset
   self.nodeGradeUpUnknowPer1:setVisible(false)
   self.nodeGradeUpUnknowPer2:setVisible(false)
   self.nodeGradeUpNewPer1:setVisible(false)
   self.nodeGradeUpNewPer2:setVisible(false)
   self.btnGradeUp:setVisible(false)
   self.btnGradeUpBack:setVisible(false)
   
   --pre info
   local levelStr = "Lv."..equipmentData:getLevel()
   local equipmentIcon = DropItemView.new(equipmentData:getConfigId())
   equipmentIcon:setScale(commonIconScale)
   self.nodePreEquipmentIcon:addChild(equipmentIcon)
   self.labelPreLv:setString(levelStr)
   
   if isSuccess ~= true then
       -- after info
       local nextGradeId = equipmentData:getNextLevelID()
       if nextGradeId > 0 then
        equipmentIcon = DropItemView.new(nextGradeId)
        equipmentIcon:setScale(commonIconScale)
        self.nodeAfterEquipmentIcon:addChild(equipmentIcon)
        self.labelAfterLv:setString(levelStr)
        
        assert(AllConfig.equipment[nextGradeId] ~= nil,"AllConfig.equipment["..nextGradeId.."] is nil")
        local dependPropId = AllConfig.equipment[nextGradeId].depend_prop
        
        self.labelGradeUpTip:setString("")
        
        local oldPropValue = equipmentData:getBaseAttr() + equipmentData:getImproveAttr() * (equipmentData:getLevel() - 1)
        local newPropValue = AllConfig.equipment[nextGradeId].base_attr + AllConfig.equipment[nextGradeId].improve_attr * (equipmentData:getLevel() - 1)

        self.bmLabelGradeUpPerBaseValuePlus:setString(("+"..newPropValue - oldPropValue))
        
        if dependPropId > 0 then
          assert(AllConfig.propgroup[dependPropId] ~= nil,"AllConfig.propgroup["..dependPropId.."] is nil")
          local newPropsCount = AllConfig.propgroup[dependPropId].count
          printf("get count:"..newPropsCount)
          self.labelGradeUpTip:setString(_tr("equipment_will_get%{count}props_this_time",{count = newPropsCount}))
          --self.labelGradeUpTip:setString("本次进阶将获得"..newPropsCount.."条新属性")
          
          if newPropsCount == 1 then
            self.nodeGradeUpUnknowPer1:setVisible(true)
            self.nodeGradeUpUnknowPer2:setVisible(false)
          elseif newPropsCount >= 2 then
            self.nodeGradeUpUnknowPer1:setVisible(true)
            self.nodeGradeUpUnknowPer2:setVisible(true)
          end
        else
          self.labelGradeUpTip:setString(_tr("equipment_will_get%{count}props_this_time",{count = 0}))
        end
    else
--        local dependPropId = AllConfig.equipment[equipmentData:getConfigId()].depend_prop
--        self.labelGradeUpTip:setString("")
--        
--        if dependPropId > 0 then
--          assert(AllConfig.propgroup[dependPropId] ~= nil,"AllConfig.propgroup["..dependPropId.."] is nil")
--          local newPropsCount = AllConfig.propgroup[dependPropId].count
--          print("get count:",newPropsCount)
--          --self.labelGradeUpTip:setString(_tr("get%{count}props_this_time",{count = newPropsCount}))
--          self.labelGradeUpTip:setString("本次进阶获得了"..newPropsCount.."条新属性")
--          if newPropsCount == 1 then
--            self.nodeGradeUpUnknowPer1:setVisible(true)
--            self.nodeGradeUpUnknowPer2:setVisible(false)
--          elseif newPropsCount >= 2 then
--            self.nodeGradeUpUnknowPer1:setVisible(true)
--            self.nodeGradeUpUnknowPer2:setVisible(true)
--          end
--        end
     end
   end
   
   --before upgrade
   -- before info
   if isSuccess ~= true then
      self.btnGradeUp:setVisible(true)
      self.btnGradeUp:setEnabled(true)
      --cost
      self.nodeGradeUpItemCost:removeAllChildrenWithCleanup(true)
      self.labelCoinCost:setString("")
      
      if equipmentData:getGrade() < 5 then
        local equipConfigId = equipmentData:getConfigId()
        assert(AllConfig.equipmentcombine[equipConfigId] ~= nil,"equipment combine id not found:"..equipmentData:getConfigId())
      
        -- for new       
        local costCoin = 0
        local costLength = 0
        local costItems = {}
        for key, m_costGroup in pairs(AllConfig.equipmentcombine[equipConfigId].consume) do
        	local costType = m_costGroup.array[1]
        	local costConfigId = m_costGroup.array[2]
        	local costCount = m_costGroup.array[3]
        	
        	if costType ~= 4 then
            local dropItem = DropItemView.new(costConfigId,costCount,costType)
            local hasCount = GameData:Instance():getCurrentPackage():getPropsNumByConfigId(costConfigId)
            local color = nil
            if hasCount < costCount then
              color = ccc3(255, 00, 7)
            end
            dropItem:setShowString(hasCount.."/"..costCount,color)
            dropItem:setScale(commonIconScale)
            self.nodeGradeUpItemCost:addChild(dropItem)
            dropItem:setPositionX((dropItem:getContentSize().width)*costLength)
            self.nodeGradeUpItemCost:setPositionX((-dropItem:getContentSize().width*costLength)/2)
            table.insert(costItems,dropItem)
            costLength = costLength + 1
          else
            costCoin = costCoin + costCount
          end
        end
        self:setCostItems(costItems)
        
  
        -- for old      
  --      local itemCostId = AllConfig.equipmentcombine[equipConfigId].item_id1
  --      local costItemCount = AllConfig.equipmentcombine[equipConfigId].count1
  --      local dropItem = DropItemView.new(itemCostId)
  --      local hasCount = GameData:Instance():getCurrentPackage():getPropsNumByConfigId(itemCostId)
  --      dropItem:setShowString(hasCount.."/"..costItemCount)
  --      dropItem:setScale(commonIconScale)
  --      self.nodeGradeUpItemCost:addChild(dropItem)
  --      local costCoin = AllConfig.equipmentcombine[equipConfigId].cost
        
        local currentCoin = GameData:Instance():getCurrentPlayer():getCoin()
        if costCoin <= currentCoin then
          self.labelCoinCost:setColor(sgGREEN)
        else
          self.labelCoinCost:setColor(sgRED)
          self.btnGradeUp:setEnabled(false)
        end
        self.labelCoinCost:setString(costCoin.."")
     end
     
     if equipmentData:getGrade() < 5 then
       self.nodeCommon:setVisible(true)
       self.nodeEquipInfoSample:setVisible(false)
     else
       self.nodeCommon:setVisible(false)
       self.nodeEquipInfoSample:setVisible(true)
        self.btnGradeUp:setEnabled(false)
       self.labelGradeUpTip:setString(_tr("equipment_grade_max"))
     end
     
   else
      self.nodeCommon:setVisible(false)
      self.btnGradeUpBack:setVisible(true)
      self.nodeEquipInfoSample:setVisible(true)
      self.nodeGradeUpUnknowPer1:setVisible(false)
      self.nodeGradeUpUnknowPer2:setVisible(false)
      
      local anim,offsetX,offsetY,duration = _res(5020209)
      anim:setPosition(ccp(offsetX,offsetY))
      anim:getAnimation():play("default") 
      self.node_equipment:addChild(anim)
   end
   
  elseif componentType == EquipmentReinforceConfig.ComponentTypeSideRefresh then
    self.nodeRefresh:setVisible(true)
    if self._perXilian == nil then
      self._perXilian = display.newNode()
      self.nodeRefresh:addChild(self._perXilian)
    else
      self._perXilian:removeAllChildrenWithCleanup(true)
    end
    self.nodeXilianCost:removeAllChildrenWithCleanup(true)
    
    local randomArrCount = 0
    local maxRandomArrtCount = 4
    if isSuccess ~= true then
      self.nodeAfterXilian:setVisible(false)
      self.nodeBeforeXilian:setVisible(true)
      local touchesButtons = {}
      local touchStates = self:getLockStates()
      dump(attrTbl)
      for i = 1, table.getn(attrTbl) do 
        if attrTbl[i].genType == 1 then --base
          -- do nothing
        else  --random
          randomArrCount = randomArrCount + 1
          local perItem = EquipLockItem.new(attrTbl[i])
          perItem:setDelegate(self)
          self._perXilian:addChild(perItem)
          perItem:setPositionY((perItem:getContentSize().height + 3) * (maxRandomArrtCount - randomArrCount))
          perItem:setIsLocked(touchStates[randomArrCount])
          table.insert(touchesButtons,perItem)
        end
      end
      self:setTouchesButtons(touchesButtons)
    else
      self.nodeAfterXilian:setVisible(true)
      self.nodeBeforeXilian:setVisible(false)
      
      local newAttr = equipmentData:buildNewAttributeMap()
      assert(newAttr ~= nil)
      for i = 1, table.getn(attrTbl) do 
        if attrTbl[i].genType == 1 then --base
          -- do nothing
        else  --random
          randomArrCount = randomArrCount + 1
          local resultItem = EquipmentReplaceItem.new(i,attrTbl,newAttr)
          self._perXilian:addChild(resultItem)
          resultItem:setPositionY((resultItem:getContentSize().height) * (maxRandomArrtCount - randomArrCount) - 55)
        end
      end
    end
    
  elseif componentType == EquipmentReinforceConfig.ComponentTypeSideTurnExclusive then
    self.nodeCommon:setVisible(true)
    self.nodeTurnExclusive:setVisible(true)
    self.nodeCoinCost:setVisible(false)
    self.btnTurnExclusive:setEnabled(true)
    
    --before info
    local levelStr = "Lv."..equipmentData:getLevel()
    local equipmentIcon = DropItemView.new(equipmentData:getConfigId())
    equipmentIcon:setScale(commonIconScale)
    self.nodePreEquipmentIcon:addChild(equipmentIcon)
    self.labelPreLv:setString(levelStr)
    
    local card = equipmentData:getCard() 
    local rootId = card:getActiveEquipId()
    print("target :  rootId:",rootId,equipmentData:getGrade() - 1,equipmentData:getGrade())
    -- after info
    local afterConfigId = 0
    for key, equipment in pairs(AllConfig.equipment) do
    	if equipment.equip_root == rootId then
    	   if equipmentData:getGrade() == equipment.equip_rank + 1 
    	   and equipmentData:getQuality() == equipment.quality then
    	     afterConfigId = key
    	   end
    	end
    end
    
    assert(afterConfigId ~= 0)
    
    equipmentIcon = DropItemView.new(afterConfigId)
    equipmentIcon:setScale(commonIconScale)
    self.nodeAfterEquipmentIcon:addChild(equipmentIcon)
    --levelStr = "Lv."..math.floor((equipmentData:getLevel() + 1)/2)
    self.labelAfterLv:setString(levelStr)
    
    
    --labelActiveSkillDesc
    self.labelActiveSkillDesc:setVisible(false)
    self.nodePasiveSkillDesc:removeAllChildrenWithCleanup(true)
    if card:getActiveEquipId() > 0 then
      local telentId = AllConfig.unit[card:getConfigId()].talent
      if telentId > 0 then
        local skillDesc = AllConfig.cardskill[telentId].skill_description
        --self.labelActiveSkillDesc:setString(skillDesc)
        
        local dimension = CCSizeMake(200, 0)
        local color = ccc3(0, 0, 0)
        local label = RichLabel:create(skillDesc,"Courier-Bold",20, dimension, true,false)
        label:setColor(color)
        local labelSize = label:getTextSize()
        label:setPositionY(labelSize.height/2)
        self.nodePasiveSkillDesc:addChild(label)
        
      end
    else
      self.labelActiveSkillDesc:setString("")
    end
    
    if isSuccess == true then
      self.btnTurnExclusive:setEnabled(false)
      self.nodeEquipInfoSample:setVisible(true)
      self.nodeCommon:setVisible(false)
    end
  end
  
  self:updateCost()
  
  if isSuccess == true then
    if componentType ~= EquipmentReinforceConfig.ComponentTypeSideGradeUp then
      self:setCostItems({})
    end
  end
end

function EquipmentSideComponent:updateCost()
  
  local equipmentData = self:getEquipmentData()
  local componentType = self:getComponentType()
  if componentType == EquipmentReinforceConfig.ComponentTypeSideRefresh then
    self.nodeXilianCost:removeAllChildrenWithCleanup(true)
    local propsItems = self:getTouchesButtons()
    local lockedPropNum = 0
    for key, propItem in pairs(propsItems) do
    	if propItem:getIsLocked() == true then
    	  lockedPropNum = lockedPropNum + 1
    	end
    end
    assert(AllConfig.xilian ~= nil)
    local costInfo = nil
    for key, refresCostInfo in pairs(AllConfig.xilian) do
    	if equipmentData:getGrade() == refresCostInfo.equip_rank + 1
    	and equipmentData:getQuality() == refresCostInfo.quality
    	and lockedPropNum == refresCostInfo.lock_count then
    	  costInfo = refresCostInfo
    	  break
    	end
    end
    
    print(equipmentData:getGrade(),equipmentData:getQuality())
    assert(costInfo ~= nil,"Equipment refresh cost config error,equip_rank = "..(equipmentData:getGrade() -1)..",quality = "..equipmentData:getQuality()..",lock_count = "..lockedPropNum)
    
    --[[local costItemCount = costInfo["count"..lockedPropNum]
    local costItemConfigId = costInfo.item
    local costItem = DropItemView.new(costItemConfigId)
    local hasCount = GameData:Instance():getCurrentPackage():getPropsNumByConfigId(costItemConfigId)
    costItem:setShowString(hasCount.."/"..costItemCount)
    costItem:setScale(0.8)
    self.nodeXilianCost:addChild(costItem)]]
    
    local costCoin = 0
    local costLength = 0
    local costItems = {}
    for key, m_costGroup in pairs(costInfo.consume) do
      local costType = m_costGroup.array[1]
      local costConfigId = m_costGroup.array[2]
      local costCount = m_costGroup.array[3]
      
--      -- don't show coin
--      if costType ~= 4 then
--        local dropItem = DropItemView.new(costConfigId,costCount,costType)
--        local hasCount = GameData:Instance():getCurrentPackage():getPropsNumByConfigId(costConfigId)
--        dropItem:setShowString(hasCount.."/"..costCount)
--        dropItem:setScale(0.8)
--        self.nodeGradeUpItemCost:addChild(dropItem)
--        dropItem:setPositionX((dropItem:getContentSize().width)*costLength)
--        self.nodeXilianCost:setPositionX((-dropItem:getContentSize().width*costLength)/2)
--        costLength = costLength + 1
--      else
--        costCoin = costCoin + costCount
--      end

      -- show coin
      local dropItem = DropItemView.new(costConfigId,costCount,costType)
      if costType ~= 4 then
        local hasCount = GameData:Instance():getCurrentPackage():getPropsNumByConfigId(costConfigId)
        local color = nil
        if hasCount < costCount then
          color = ccc3(255, 00, 7)
        end
        dropItem:setShowString(hasCount.."/"..costCount,color)
      end
      dropItem:setScale(commonIconScale)
      self.nodeXilianCost:addChild(dropItem)
      dropItem:setPositionX((dropItem:getContentSize().width)*costLength)
      self.nodeXilianCost:setPositionX((-dropItem:getContentSize().width*costLength)/2)
      table.insert(costItems,dropItem)
      costLength = costLength + 1
    end
    self:setCostItems(costItems)
      
  end
end 

------
--  Getter & Setter for
--      EquipmentSideComponent._TouchesButtons 
-----
function EquipmentSideComponent:setTouchesButtons(TouchesButtons)
	self._TouchesButtons = TouchesButtons
end

function EquipmentSideComponent:getTouchesButtons()
	return self._TouchesButtons
end

------
--  Getter & Setter for
--      EquipmentSideComponent._LockStates 
-----
function EquipmentSideComponent:setLockStates(LockStates)
	self._LockStates = LockStates
end

function EquipmentSideComponent:getLockStates()
	return self._LockStates
end

------
--  Getter & Setter for
--      EquipmentSideComponent._CostItems 
-----
function EquipmentSideComponent:setCostItems(CostItems)
	self._CostItems = CostItems
end

function EquipmentSideComponent:getCostItems()
	return self._CostItems
end

function EquipmentSideComponent:backFromGradeUpHandler()
  self:updateView()
end

function EquipmentSideComponent:onClickLevelUpHandler()
  local op_type = EquipmentReinforceConfig.StrengthenOnce
  if self._maxLevelUpEnabled == true then
    op_type = EquipmentReinforceConfig.StrengthenNoLimit
  end
  EquipmentReinforce:Instance():reqEquipStrengthen(self:getEquipmentData(),op_type)
  _executeNewBird()
end

function EquipmentSideComponent:onClickGradeUpHandler()
  EquipmentReinforce:Instance():reqEquipTurnback(self:getEquipmentData())
  _executeNewBird()
end

function EquipmentSideComponent:onClickRefreshHandler()
  local equipmentData = self:getEquipmentData()
  local prop_infos = {}
  
  local touchStates = self:getLockStates()
  
  local touchesButton = self:getTouchesButtons()
  for key, button in pairs(touchesButton) do
    touchStates[key] = button:getIsLocked()
  	if button:getIsLocked() == true then
  	 table.insert(prop_infos,button:getPropId())
  	end
  end
  assert(#prop_infos < #touchesButton,"at least 1 prop to refresh")
  EquipmentReinforce:Instance():reqEquipXiLian(equipmentData,prop_infos)
end

function EquipmentSideComponent:onClickTurnExclusiveHandler()
  _executeNewBird()
  
  --[[if self:getEquipmentData():getLevel() > 1 then
    local pop = PopupView:createTextPopup(_tr("equipment_turn_exclusive_tip"),
      function()
        EquipmentReinforce:Instance():reqEquipTurnExclusive(self:getEquipmentData())
      end)
    GameData:Instance():getCurrentScene():addChildView(pop)
  else
     EquipmentReinforce:Instance():reqEquipTurnExclusive(self:getEquipmentData())
  end]]
  
  EquipmentReinforce:Instance():reqEquipTurnExclusive(self:getEquipmentData())
  
end

function EquipmentSideComponent:onCardTurnbackResult(msg)
   local msg_equipment = msg.client_sync.equipment
   print("equip")
   dump(msg_equipment)
   local equipConfigId = self:getEquipmentData():getConfigId()
   local dependId = AllConfig.equipment[equipConfigId].depend_prop
   if dependId > 0 then
     assert(AllConfig.propgroup[dependId] ~= nil,dependId)
     for key, equipment in pairs(msg_equipment) do
       local count = 0
       local newPropsCount = AllConfig.propgroup[dependId].count
       for i = newPropsCount, 1,-1 do
        count = count + 1
        self["nodeGradeUpNewPer"..count]:setVisible(true)
        local equipmentUpdate = equipment.object
        local newskill = equipmentUpdate.skill[#equipmentUpdate.skill - (i - 1)]
        local proptype = AllConfig.proptype[newskill.type]
        self["bmLabelGradeUpPerNew"..count.."Name"]:setString(proptype.name)
        local str = string.format(proptype.showformat,newskill.data / proptype.rate)
        self["bmLabelGradeUpPerNew"..count.."Value"]:setString(str)
       	print(proptype.name,str)
       end
       assert(count <= 2 ,"new per must less than 2,now has "..count)
       self.labelGradeUpTip:setString(_tr("equipment_get%{count}props_this_time",{count = count}))
       --self.labelGradeUpTip:setString("本次进阶获得了"..count.."条新属性")
     end
   end
   
end 

return EquipmentSideComponent