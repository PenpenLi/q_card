require("view.component.TipPic")
CardFormationListItemView = class("CardFormationListItemView",function()
   return display.newNode()
end)
function CardFormationListItemView:ctor()
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("labelCardName","CCLabelTTF")
  pkg:addProperty("levelLabel","CCLabelBMFont")
  pkg:addProperty("nodeCard","CCNode")
  pkg:addProperty("nodeSkillType","CCNode")
  pkg:addProperty("nodeWeapon","CCNode")
  pkg:addProperty("nodeArmor","CCNode")
  pkg:addProperty("nodeAccessory","CCNode")
  pkg:addProperty("spriteLv","CCSprite")
  pkg:addProperty("iconAddCard","CCSprite")
  pkg:addProperty("spriteLockIcon","CCSprite")
  pkg:addProperty("labelOpenLevel","CCLabelTTF")
  pkg:addProperty("menuStars","CCMenu")
  pkg:addProperty("btnStar1","CCMenuItemImage")
  pkg:addProperty("btnStar2","CCMenuItemImage")
  pkg:addProperty("btnStar3","CCMenuItemImage")
  pkg:addProperty("btnStar4","CCMenuItemImage")
  pkg:addProperty("btnStar5","CCMenuItemImage")
  
  --pkg:addFunc("onClickHandler",CardFormationListItemView.onClickHandler)
  
  local layer,owner = ccbHelper.load("PrePlayStatesItemView.ccbi","PrePlayStateItemView","CCNode",pkg)
  self:addChild(layer)
  
  self.nodeWeapon:setScale(0.4)
  self.nodeArmor:setScale(0.4)
  self.nodeAccessory:setScale(0.4)
  self.nodeSkillType:setScale(0.7)
  --self._delegate = delegate
  self:setNodeEventEnabled(true)
  
     
  self.tipImg = TipPic.new()
  self:addChild(self.tipImg)
  self.tipImg:setPosition(140,50)
  self.tipImg:setScale(1/0.9)
  
  self._menuStarsInitX = self.menuStars:getPositionX()
end

function CardFormationListItemView:onExit()

end

------
--  Getter & Setter for
--      CardFormationListItemView._Locked 
-----
function CardFormationListItemView:setLocked(Locked)
  self._Locked = Locked
  self.spriteLockIcon:setVisible(Locked)
  self.labelOpenLevel:setVisible(Locked)
  if Locked == true then
     self.iconAddCard:setVisible(false)
     self:setCard(nil)
  else
     if self:getCard() == nil then
        self.iconAddCard:setVisible(true)
     end
  end
end

function CardFormationListItemView:getLocked()
  return self._Locked
end

------
--  Getter & Setter for
--      CardFormationListItemView._Index 
-----
function CardFormationListItemView:setIndex(Index)
  self._Index = Index
  
  if Index <= AllConfig.charlevel[1].unit_slot_unlock then
    self:setLocked(false)
    self:setUnlockLevel(AllConfig.charlevel[1].level)
  else
    for i = 1, #AllConfig.charlevel do
      if Index == AllConfig.charlevel[i].unit_slot_unlock then
         if GameData:Instance():getCurrentPlayer():getLevel() >= AllConfig.charlevel[i].level then
            self:setLocked(false)
         else
            self:setUnlockLevel(AllConfig.charlevel[i].level)
            self:setLocked(true)
         end
         break
      end
    end
  end
end

function CardFormationListItemView:getIndex()
  return self._Index
end

------
--  Getter & Setter for
--      CardFormationListItemView._UnlockLevel 
-----
function CardFormationListItemView:setUnlockLevel(UnlockLevel)
  self._UnlockLevel = UnlockLevel
  self.labelOpenLevel:setString(_tr("%{level}level_open",{level = UnlockLevel}))
end

function CardFormationListItemView:getUnlockLevel()
  return self._UnlockLevel
end

--function CardFormationListItemView:onClickHandler()
--  self._delegate:onClickItemHandler(self)
--end
------
--  Getter & Setter for
--      CardFormationListItemView._Card 
-----
function CardFormationListItemView:setCard(Card)
	self._Card = Card
	self.nodeCard:removeAllChildrenWithCleanup(true)
	self.nodeSkillType:removeAllChildrenWithCleanup(true)
	self.labelCardName:setString("")
  self.levelLabel:setString("")
  self.spriteLv:setVisible(false)
  self.menuStars:setVisible(false)
	if Card ~= nil then
	   self:setLocked(false)
     self.iconAddCard:setVisible(false)
  
	   local cardHead = CardHeadView.new()
	   cardHead:setCard(Card)
     self.nodeCard:addChild(cardHead)
     cardHead.nodeLevelCon:stopAllActions()
     cardHead.nodeLevelCon:setVisible(false)
     
     self.labelCardName:setString(Card:getName())
     self.levelLabel:setString(Card:getLevel().."")
     
     self.spriteLv:setVisible(true)
     
     local skilltyperes = nil
      
      if AllConfig.unit[Card:getConfigId()].config%2 == 0 then
          skilltyperes = _res(3042002)
      else
          skilltyperes = _res(3042001)
      end
      
      if skilltyperes ~= nil then
         self.nodeSkillType:addChild(skilltyperes)
      end
      
      self.menuStars:setVisible(true)
      --update card star show
      for i=1, 5 do
        self["btnStar"..i]:setVisible(false)
        self["btnStar"..i]:setEnabled(false)
      end
      local maxRank = Card:getMaxGrade()
      
      local star_distance = 14
      self.menuStars:setPositionX(self._menuStarsInitX + star_distance*(5 - maxRank) )
      
      for i = 1, maxRank do
        self["btnStar"..i]:setVisible(true)
        self["btnStar"..i]:setEnabled(false)
      end
      
      local currentRank = Card:getGrade()
      for i=1, currentRank do
        self["btnStar"..i]:setEnabled(true)
      end
      
      
     
     --self.nodeSkillType:removeChildrenWithCleanup(true)
     --self.nodeSkillType:addChild()
     local iconSprite = nil
     if Card:getWeapon() == nil then  -- card has no weapon
        self.nodeWeapon:setVisible(false)
        --self.labelWeapon:setString("")
      else 
        self.nodeWeapon:removeAllChildrenWithCleanup(true)
        self.nodeWeapon:setVisible(true)
        
        iconSprite = DropItemView.new(Card:getWeapon():getConfigId())
        self.nodeWeapon:addChild(iconSprite)
        --self.labelWeapon:setString(Card:getWeapon():getName())

      end
      
      if Card:getArmor() == nil then  -- card has no armor
        self.nodeArmor:setVisible(false)
        --self.labelArmor:setString("")
      else 
        self.nodeArmor:setVisible(true)
        self.nodeArmor:removeAllChildrenWithCleanup(true)
        self.nodeArmor:setVisible(true)
       
        iconSprite = DropItemView.new(Card:getArmor():getConfigId())
        self.nodeArmor:addChild(iconSprite)
        --self.labelArmor:setString(Card:getArmor():getName())
      end
      
      if Card:getAccessory() == nil then  -- card has no accessory
        self.nodeAccessory:setVisible(false)
        --self.labelAccessory:setString("")
      else 
        self.nodeAccessory:removeAllChildrenWithCleanup(true)
        self.nodeAccessory:setVisible(true)
        
        iconSprite = DropItemView.new(Card:getAccessory():getConfigId())
        self.nodeAccessory:addChild(iconSprite)
        --self.labelAccessory:setString(Card:getAccessory():getName())
      end
      
--      local weaponLvUpEnabled = EquipmentReinforce:Instance():getEquipmentsLvUpEnabled(Card,EquipmentReinforceConfig.EquipmentTypeWeapon) 
--      local weaponGradeUpEnabled = EquipmentReinforce:Instance():getEquipmentsGradeUpEnabled(Card,EquipmentReinforceConfig.EquipmentTypeWeapon) 
--     
--      local armorLvUpEnabled = EquipmentReinforce:Instance():getEquipmentsLvUpEnabled(Card,EquipmentReinforceConfig.EquipmentTypeArmor) 
--      local armorGradeUpEnabled = EquipmentReinforce:Instance():getEquipmentsGradeUpEnabled(Card,EquipmentReinforceConfig.EquipmentTypeArmor) 
--
--      local accessoryLvUpEnabled = EquipmentReinforce:Instance():getEquipmentsLvUpEnabled(Card,EquipmentReinforceConfig.EquipmentTypeAccessory) 
--      local accessoryGradeUpEnabled = EquipmentReinforce:Instance():getEquipmentsGradeUpEnabled(Card,EquipmentReinforceConfig.EquipmentTypeAccessory) 
--        
--      local enabledTip = (Enhance:instance():isCardCanSurmounted(Card)
--      or weaponLvUpEnabled == true 
--      or weaponGradeUpEnabled == true
--      or armorLvUpEnabled == true
--      or armorGradeUpEnabled == true
--      or accessoryLvUpEnabled == true 
--      or accessoryGradeUpEnabled == true
--      )

      local enabledTip = GameData:Instance():getCurrentPackage():checkCardHasTip(Card)
      self.tipImg:setVisible(enabledTip)
   
  else
     self.tipImg:setVisible(false)
     if self:getLocked() == false then
        self.iconAddCard:setVisible(true)
     end   
	end
end

function CardFormationListItemView:getCard()
	return self._Card
end


return CardFormationListItemView