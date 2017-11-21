require("model.equipment_reinforce.EquipmentReinforceConfig")
require("view.equipment_reinforce.EquipmentMainComponent")
require("view.equipment_reinforce.EquipmentSideComponent")
require("view.component.ItemSourceView")
EquipmentReinforceView = class("EquipmentReinforceView",BaseView)
function EquipmentReinforceView:ctor(equipmentData,card)
  self:setNodeEventEnabled(true)
  local layerColor = CCLayerColor:create(ccc4(0,0,0,185), display.width, display.height)
  self:addChild(layerColor)
  self:setEquipmentData(equipmentData)
  
  self:setTouchEnabled(true)
  self:addTouchEventListener(handler(self,self.onTouch),false,-128,true)
end

function  EquipmentReinforceView:checkTouchOutsideView(x,y)
  local mainComponent = self:getMainComponent()
  local size1 = mainComponent:getContentSize()
  local pos1 = mainComponent:convertToNodeSpace(ccp(x + size1.width/2, y + size1.height/2))
  if pos1.x < 0 or pos1.x > size1.width or pos1.y < 0 or pos1.y > size1.height then 
    local sideComponent = self:getSideComponent()
    if sideComponent ~= nil then
      local size2 = sideComponent:getContentSize()
      local pos2 = sideComponent:convertToNodeSpace(ccp(x + size2.width/2, y + size2.height/2))
      if pos2.x < 0 or pos2.x > size2.width or pos2.y < 0 or pos2.y > size2.height then 
        return true 
      end
    else
      return true
    end
  end
  return false  
end 

local function getTouchedNode(toTouchArray,x,y,anchorPoint)
  local isGetedNode = false
  local touchedNode = nil
  for i = 1, table.getn(toTouchArray) do
    local contentSize = toTouchArray[i]:getContentSize()
    print("size:",contentSize.width,contentSize.height)
    local position = toTouchArray[i]:getParent():convertToWorldSpace(ccp(toTouchArray[i]:getPositionX(),toTouchArray[i]:getPositionY()))
    print("pos:",position.x,position.y)
    local ccRect = CCRectMake(
        position.x - contentSize.width/2,
        position.y - contentSize.height/2,
        contentSize.width,
        contentSize.height)
        
    isGetedNode = ccRect:containsPoint(ccp(x,y))
    if isGetedNode == true then
      touchedNode = toTouchArray[i]
      break
    end
  end
  return touchedNode
end

function EquipmentReinforceView:onTouch(event,x,y)
  if event == "began" then
    self.preTouchFlag = self:checkTouchOutsideView(x,y)
    return true
  elseif event == "moved" then
  
  elseif event == "ended" then
  
    local curFlag = self:checkTouchOutsideView(x,y)
    if self.preTouchFlag == true and curFlag == true then
      echo(" touch out of region: close popup") 
      self:removeFromParentAndCleanup(true)
      return
    end 
                         
    local sideComponent = self:getSideComponent()
    if sideComponent ~= nil then
      if sideComponent:getComponentType() == EquipmentReinforceConfig.ComponentTypeSideRefresh then    
        local targetBtn = getTouchedNode(sideComponent:getTouchesButtons(),x,y)
        if targetBtn ~= nil then
          local unLockedCount = 0
          for key, button in pairs(sideComponent:getTouchesButtons()) do
            if button:getIsLocked() == false then
              unLockedCount = unLockedCount + 1
            end
          end
          
          if targetBtn:getIsLocked() == true then
            targetBtn:switchLock()
          else
            if unLockedCount > 1 then
              targetBtn:switchLock()
            end
          end
          
        end
      end
    
      local targetItem = getTouchedNode(sideComponent:getCostItems(),x,y)
      if targetItem ~= nil and targetItem:getConfigId() > 100 then
       print(targetItem:getConfigId())
       --TipsInfo:showTip(targetItem,targetItem:getConfigId(), nil)
       local sourceView = ItemSourceView.new(targetItem:getConfigId())
       self:addChild(sourceView)
      end
      
    end -- sideComponent ~= nil end
  end
end

------
--  Getter & Setter for
--      EquipmentReinforceView._EquipmentData 
-----
function EquipmentReinforceView:setEquipmentData(EquipmentData)
	self._EquipmentData = EquipmentData
	assert(EquipmentData ~= nil,"EquipmentData can not be nil")
	
	local enabledTurnExclusive = false
	local card = EquipmentData:getCard()
	if card ~= nil and GameData:Instance():getLanguageType() ~= LanguageType.JPN then
    if EquipmentData:getEquipType() == EquipmentReinforceConfig.EquipmentTypeWeapon
    and card:getActiveEquipId() > 0 
    and card:getActiveEquipId() ~= EquipmentData:getRootId()
    then
      self:showSideComponentByType(EquipmentReinforceConfig.ComponentTypeSideTurnExclusive)
      enabledTurnExclusive = true
    end
  end
	
	--main
	local mainComponent = self:getMainComponent()
	if mainComponent == nil then
	  mainComponent = EquipmentMainComponent.new(EquipmentData)
	  self:addChild(mainComponent)
	  mainComponent:setPosition(ccp(display.cx,display.cy))
	  self:setMainComponent(mainComponent,1)
	  EquipmentReinforce:Instance():setMainComponent(mainComponent)
	else
	  mainComponent:setEquipmentData(EquipmentData)
	end
	
	if GameData:Instance():getLanguageType() == LanguageType.JPN then
	  enabledTurnExclusive = false
	  mainComponent:setIsLockedControllButtons(false)
	end
	
	if enabledTurnExclusive == true then
	  mainComponent:stopAllActions()
	  mainComponent:setIsLockedControllButtons(true)
	  mainComponent:runAction(CCMoveTo:create(0.2,ccp(display.cx - 135,display.cy)))
	end
end

function EquipmentReinforceView:getEquipmentData()
	return self._EquipmentData
end

--EquipmentReinforceConfig.ComponentTypeSideLvUp = 2
--EquipmentReinforceConfig.ComponentTypeSideGradeUp = 3
--EquipmentReinforceConfig.ComponentTypeSideRefresh = 4
--EquipmentReinforceConfig.ComponentTypeSideTurnExclusive = 5

function EquipmentReinforceView:hideSideComponent(mainComponentToCenter)
  local sideComponent = self:getSideComponent()
  if sideComponent ~= nil then
    sideComponent:removeFromParentAndCleanup(true)
    self:setSideComponent(nil)
    EquipmentReinforce:Instance():setSideComponent(nil)
  end
  local mainComponent = self:getMainComponent()
  if mainComponent ~= nil then
    mainComponent:setIsLockedControllButtons(false)
    if mainComponentToCenter == nil or mainComponentToCenter == true then
      mainComponent:runAction(CCMoveTo:create(0.2,ccp(display.cx,display.cy)))
    end
  end
end

function EquipmentReinforceView:showSideComponentByType(componentType)
  local sideComponent = self:getSideComponent()
   
  if sideComponent == nil then
    sideComponent = EquipmentSideComponent.new(componentType,self:getEquipmentData())
    self:addChild(sideComponent)
    sideComponent:setPosition(ccp(display.cx + 165,display.cy))
    --sideComponent:runAction(CCMoveTo:create(0.2,ccp(display.cx + 165,display.cy)))
    self:setSideComponent(sideComponent)
    EquipmentReinforce:Instance():setSideComponent(sideComponent)
  else
    sideComponent:setVisible(true)
    sideComponent:setComponentType(componentType)
  end
  
  local mainComponent = self:getMainComponent()
  if mainComponent ~= nil then
    mainComponent:runAction(CCMoveTo:create(0.2,ccp(display.cx - 135,display.cy)))
    if GameData:Instance():getLanguageType() ~= LanguageType.JPN then
      mainComponent:setIsLockedControllButtons(componentType == EquipmentReinforceConfig.ComponentTypeSideTurnExclusive)
    end
  end

end

function EquipmentReinforceView:onClickLevelUpHandler()
  self:showSideComponentByType(EquipmentReinforceConfig.ComponentTypeSideLvUp)
end

function EquipmentReinforceView:onClickGradeUpHandler()
  self:showSideComponentByType(EquipmentReinforceConfig.ComponentTypeSideGradeUp)
end

function EquipmentReinforceView:onClickRefreshHandler()
  self:showSideComponentByType(EquipmentReinforceConfig.ComponentTypeSideRefresh)
end


------
--  Getter & Setter for
--      EquipmentReinforceView._MainComponent 
-----
function EquipmentReinforceView:setMainComponent(MainComponent)
	self._MainComponent = MainComponent
end

function EquipmentReinforceView:getMainComponent()
	return self._MainComponent
end

------
--  Getter & Setter for
--      EquipmentReinforceView._SideComponent 
-----
function EquipmentReinforceView:setSideComponent(SideComponent)
	self._SideComponent = SideComponent
end

function EquipmentReinforceView:getSideComponent()
	return self._SideComponent
end

function EquipmentReinforceView:onEnter()
  EquipmentReinforce:Instance():setContainerView(self)
end

function EquipmentReinforceView:onExit()
  EquipmentReinforce:Instance():setMainComponent(nil)
  EquipmentReinforce:Instance():setSideComponent(nil)
  EquipmentReinforce:Instance():setContainerView(nil)
end

return EquipmentReinforceView