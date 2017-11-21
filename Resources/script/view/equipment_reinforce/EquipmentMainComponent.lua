require("view.equipment_reinforce.EquipmentChangeListView")
EquipmentMainComponent = class("EquipmentMainComponent",function()
  return display.newNode()
end)
function EquipmentMainComponent:ctor(equipmentData)
  self:setNodeEventEnabled(true)
  
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("node_equipment","CCNode")
  pkg:addProperty("label_name","CCLabelTTF")
  pkg:addProperty("label_level","CCLabelTTF")
  pkg:addProperty("node_blue_lock","CCNode")
  pkg:addProperty("node_pur_lock","CCNode")
  pkg:addProperty("node_gold_lock","CCNode")
  
  pkg:addProperty("spriteComponentBg","CCSprite")
  
  for i = 1 ,5 do
    pkg:addProperty("equip_star_"..i,"CCSprite")
  end
  pkg:addProperty("node_1_per","CCNode")
  pkg:addProperty("node_2_per","CCNode")
  pkg:addProperty("node_3_per","CCNode")
  pkg:addProperty("node_4_per","CCNode")
  
  pkg:addProperty("bmLabelPerBaseName","CCLabelBMFont")
  pkg:addProperty("bmLabelPerBaseValue","CCLabelTTF")
  
  pkg:addProperty("bmLabelPer1Name","CCLabelBMFont")
  pkg:addProperty("bmLabelPer1Value","CCLabelTTF")
  
  pkg:addProperty("bmLabelPer2Name","CCLabelBMFont")
  pkg:addProperty("bmLabelPer2Value","CCLabelTTF")
  
  pkg:addProperty("bmLabelPer3Name","CCLabelBMFont")
  pkg:addProperty("bmLabelPer3Value","CCLabelTTF")
  
  pkg:addProperty("bmLabelPer4Name","CCLabelBMFont")
  pkg:addProperty("bmLabelPer4Value","CCLabelTTF")
  
  pkg:addProperty("btnGoLevelUp","CCControlButton")
  pkg:addProperty("btnGoGradeUp","CCControlButton")
  pkg:addProperty("btnGoRefresh","CCControlButton")
  
  pkg:addProperty("btnChangEquipJpn","CCMenuItemImage")
  pkg:addProperty("btnUnload","CCMenuItemImage")
  pkg:addProperty("btnChangEquip","CCMenuItemImage")
  
  
  pkg:addFunc("refreshHandler",EquipmentMainComponent.refreshHandler)
  pkg:addFunc("gradeUpHandler",EquipmentMainComponent.gradeUpHandler)
  pkg:addFunc("lvUpHandler",EquipmentMainComponent.lvUpHandler)
  pkg:addFunc("onClickChangeEquipHandler",EquipmentMainComponent.onClickChangeEquipHandler)
  
  pkg:addFunc("unLoadHandler",EquipmentMainComponent.unLoadHandler)
  
  
  
  local mainComponent,owner = ccbHelper.load("equipment_reinforce_main.ccbi","equipment_reinforce_main","CCNode",pkg)
  self:addChild(mainComponent)
  
  if GameData:Instance():getLanguageType() == LanguageType.JPN then
    self.btnChangEquipJpn:setVisible(true)
    self.btnUnload:setVisible(true)
    self.btnChangEquip:setVisible(false)
  else
    self.btnChangEquipJpn:setVisible(false)
    self.btnUnload:setVisible(false)
    self.btnChangEquip:setVisible(true)
  end
  
  local tipPos = ccp(70,70)
  self._lvUpTip = TipPic.new()
  self.btnGoLevelUp:addChild(self._lvUpTip)
  self._lvUpTip:setPosition(tipPos)
  
  self._gradeUpTip = TipPic.new()
  self.btnGoGradeUp:addChild(self._gradeUpTip)
  self._gradeUpTip:setPosition(tipPos)
  
  self:setEquipmentData(equipmentData)
  
  local touchPriority = -200
  self.btnGoLevelUp:setTouchPriority(touchPriority)
  self.btnGoGradeUp:setTouchPriority(touchPriority)
  self.btnGoRefresh:setTouchPriority(touchPriority)
  self:setPosition(display.cx,display.cy)
  
  self:setIsLockedControllButtons(false)
  
  _registNewBirdComponent(124001,self.btnGoLevelUp)
  _registNewBirdComponent(124002,self.btnGoGradeUp)
  
  local enabledTurnExclusive = false
  local card = equipmentData:getCard()
  if card ~= nil and  GameData:Instance():getLanguageType() ~= LanguageType.JPN then
    if equipmentData:getEquipType() == EquipmentReinforceConfig.EquipmentTypeWeapon
    and card:getActiveEquipId() > 0 
    and card:getActiveEquipId() ~= equipmentData:getRootId()
    then
      enabledTurnExclusive = true
    end
  end
  
  if enabledTurnExclusive == false then
    _executeNewBird()
  else
    _showLoading()
    local action = transition.sequence({
        CCDelayTime:create(0.45),
        CCCallFunc:create(function()
          _hideLoading()
          _executeNewBird()
        end),
    })
    GameData:Instance():getCurrentScene():runAction(action)
    
  end
  
  
  
end

function EquipmentMainComponent:unLoadHandler()
  local canChange = GameData:Instance():checkSystemOpenCondition(32,true)
  if canChange ~= true then
    return
  end

  local startEquipment = self:getEquipmentData()
  EquipmentReinforce:Instance():reqChangeEquipment("UnDress",{startEquipment:getCard():getId()},startEquipment:getId())
end

------
--  Getter & Setter for
--      EquipmentMainComponent._IsLockedControllButtons 
-----
function EquipmentMainComponent:setIsLockedControllButtons(IsLockedControllButtons)
	self._IsLockedControllButtons = IsLockedControllButtons
	local equipmentData = self:getEquipmentData()
	
	local enabledTurnExclusive = false
  local card = equipmentData:getCard()
  if card ~= nil and  GameData:Instance():getLanguageType() ~= LanguageType.JPN then
    if equipmentData:getEquipType() == EquipmentReinforceConfig.EquipmentTypeWeapon
    and card:getActiveEquipId() > 0 
    and card:getActiveEquipId() ~= equipmentData:getRootId()
    then
      enabledTurnExclusive = true
    end
    self._IsLockedControllButtons = false
  end
	
	self.btnGoLevelUp:setEnabled(not self._IsLockedControllButtons)
  self.btnGoGradeUp:setEnabled(not self._IsLockedControllButtons)
  self.btnGoRefresh:setEnabled(not self._IsLockedControllButtons)
  
  if self._IsLockedControllButtons == false then
   local lvUpEnabled = GameData:Instance():checkSystemOpenCondition(29,false)
   local gradeUpEnabled = GameData:Instance():checkSystemOpenCondition(24,false)
   local refreshEnabled = GameData:Instance():checkSystemOpenCondition(26,false)
   self.btnGoLevelUp:setEnabled(lvUpEnabled)
   self.btnGoGradeUp:setEnabled(gradeUpEnabled)
   self.btnGoRefresh:setEnabled(refreshEnabled)
  
   if equipmentData:getGrade() < 3 then
     self.btnGoRefresh:setEnabled(false)
   end
  end
     
  --update tip
  self._lvUpTip:setVisible(false)
  self._gradeUpTip:setVisible(false)
  
  if self._IsLockedControllButtons ~= true and card ~= nil then
    local lvUpEnabled = EquipmentReinforce:Instance():getEquipmentsLvUpEnabled(card,equipmentData:getEquipType()) 
    self._lvUpTip:setVisible(lvUpEnabled)
    
    local gradeUpEnabled = EquipmentReinforce:Instance():getEquipmentsGradeUpEnabled(card,equipmentData:getEquipType()) 
    self._gradeUpTip:setVisible(gradeUpEnabled)
  end
	
end

function EquipmentMainComponent:getIsLockedControllButtons()
	return self._IsLockedControllButtons
end

function EquipmentMainComponent:getContentSize()
  return self.spriteComponentBg:getContentSize()
end

function EquipmentMainComponent:onEnter()
  
end

function EquipmentMainComponent:onExit()
  
end

function EquipmentMainComponent:refreshHandler()
  self:getParent():onClickRefreshHandler()
end

function EquipmentMainComponent:gradeUpHandler()
  self:getParent():onClickGradeUpHandler()
  _executeNewBird()
end

function EquipmentMainComponent:lvUpHandler()
  self:getParent():onClickLevelUpHandler()
  _executeNewBird()
end

function EquipmentMainComponent:onClickChangeEquipHandler()
  --self:getParent():onClickChangeEquipHandler()
  local canChange = GameData:Instance():checkSystemOpenCondition(32,true)
  if canChange ~= true then
    return
  end
  
  local equipment = self:getEquipmentData()
  local card = equipment:getCard()
  local equipmentChangeListView = EquipmentChangeListView.new(card,equipment:getEquipType())
  self:getParent():addChild(equipmentChangeListView)
end

function EquipmentMainComponent:updateView()
  --clear
  self.node_equipment:removeAllChildrenWithCleanup(true)
  self.bmLabelPerBaseName:setString("")
  self.bmLabelPerBaseValue:setString("")
  for i = 1 ,4 do
    self["bmLabelPer"..i.."Name"]:setString("")
    self["bmLabelPer"..i.."Value"]:setString("")
  end
  
  local card = self:getCard()
  local equipmentType = self:getEquipmentData():getEquipType()
  
  local equipmentData = nil
  if equipmentType == EquipmentReinforceConfig.EquipmentTypeWeapon then
    equipmentData = card:getWeapon()
  elseif equipmentType == EquipmentReinforceConfig.EquipmentTypeArmor then
    equipmentData = card:getArmor()
  elseif equipmentType == EquipmentReinforceConfig.EquipmentTypeAccessory then
    equipmentData = card:getAccessory()
  end
  
  assert(equipmentData ~= nil)
  
  if equipmentData ~= self:getEquipmentData() then
    self:setEquipmentData(equipmentData)
    return
  end
  
  self:setIsLockedControllButtons(false)
  
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
  
  local attrTbl = equipmentData:getSkillAttrExt()
  dump(attrTbl)
  local attrCount = 0
  for i = 1, table.getn(attrTbl) do 
    if attrTbl[i].genType == 1 then --base
      self.bmLabelPerBaseName:setString(attrTbl[i].name)
      self.bmLabelPerBaseValue:setString(toint("  "..attrTbl[i].data))
    else  --random
      attrCount = attrCount + 1     
      if attrCount <= 4 then 
        self["bmLabelPer"..attrCount.."Name"]:setString(attrTbl[i].name)
        self["bmLabelPer"..attrCount.."Value"]:setString(attrTbl[i].data.."")
      end
    end
  end
  
  self.node_blue_lock:setVisible(false)
  self.node_pur_lock:setVisible(false)
  self.node_gold_lock:setVisible(false)
  
  self.node_1_per:setVisible(false)
  self.node_2_per:setVisible(false)
  self.node_3_per:setVisible(false)
  self.node_4_per:setVisible(false)
  
  if equipmentData:getGrade() < 3 then
     self.node_blue_lock:setVisible(true)
     self.node_pur_lock:setVisible(true)
     self.node_gold_lock:setVisible(true)
  elseif equipmentData:getGrade() == 3 then
     self.node_pur_lock:setVisible(true)
     self.node_gold_lock:setVisible(true)
     self.node_1_per:setVisible(true)
     self.node_2_per:setVisible(true)
  elseif equipmentData:getGrade() == 4 then
     self.node_1_per:setVisible(true)
     self.node_2_per:setVisible(true)
     self.node_3_per:setVisible(true)
     self.node_gold_lock:setVisible(true)
  else
     self.node_1_per:setVisible(true)
     self.node_2_per:setVisible(true)
     self.node_3_per:setVisible(true)
     self.node_4_per:setVisible(true)
  end
  
end

------
--  Getter & Setter for
--      EquipmentMainComponent._Card 
-----
function EquipmentMainComponent:setCard(Card)
	self._Card = Card
end

function EquipmentMainComponent:getCard()
	return self._Card
end

------
--  Getter & Setter for
--      EquipmentMainComponent._EquipmentData 
-----
function EquipmentMainComponent:setEquipmentData(EquipmentData)
	self._EquipmentData = EquipmentData
	if EquipmentData == nil then
	   return
	end
	self:setCard(EquipmentData:getCard())
	self:updateView()
end

function EquipmentMainComponent:getEquipmentData()
	return self._EquipmentData
end

return EquipmentMainComponent