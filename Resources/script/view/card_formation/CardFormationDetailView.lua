require("view.component.DropItemView")
require("view.component.ProgressBarView")
require("view.card_levelup.CardLevelUpView")
require("view.equipment_reinforce.EquipmentReinforceView")
require("view.equipment_reinforce.EquipmentChangeListView")
require("view.card_formation.CardFormationLargePortraiView")
require("view.card_formation.CardFormationPropertyView")
require("view.card_formation.CardFormationCombineSkillView")
require("view.enhance.CardSurmountView")
require("view.enhance.CardSkillUpView")

CardFormationDetailView = class("CardFormationDetailView",BaseView)
function CardFormationDetailView:ctor(playStates,isOnBattlePlaystates)
  self:setNodeEventEnabled(true)
  self.playStates = playStates
  self.UNIT_TAG = 123
  
  if isOnBattlePlaystates == nil then
     isOnBattlePlaystates = true 
  end
  
  self._isOnBattlePlaystates = isOnBattlePlaystates
  self:setTouchEnabled(true)
  self:addTouchEventListener(handler(self,self.onTouch),false, -128, true)
  self._isTweeningPortrait = false
  self:init()
end

function CardFormationDetailView:onEnter()
  EquipmentReinforce:Instance():setPlaystatesView(self)
end

function CardFormationDetailView:init()
  --bg 
  local bg = display.newSprite("img/pvp_rank_match/pvp_rank_match_bg.png")
  self:addChild(bg)
  bg:setPosition(display.cx,display.cy)

  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("closeMenu","CCMenu")
  pkg:addProperty("closeMenuItem","CCMenuItemImage")
  pkg:addProperty("node_mask","CCNode")
  
  --right boader
  pkg:addProperty("nodeWeapon","CCNode")
  pkg:addProperty("nodeArmor","CCNode")
  pkg:addProperty("nodeAccessory","CCNode")
  
  pkg:addProperty("btnArmor","CCMenuItemImage")
  pkg:addProperty("btnWeapon","CCMenuItemImage")
  pkg:addProperty("btnAccessory","CCMenuItemImage")
  pkg:addProperty("btnLvUpEquip","CCMenuItemImage")
  pkg:addProperty("label_zhandouli","CCLabelBMFont")
  
  
  
  pkg:addFunc("weaponSelectHandler",CardFormationDetailView.weaponSelectHandler)
  pkg:addFunc("armorSelectHandler",CardFormationDetailView.armorSelectHandler)
  pkg:addFunc("accessorySelectHandler",CardFormationDetailView.accessorySelectHandler)
  
  
  --info board
  pkg:addProperty("btnAddCardExp","CCMenuItemImage")
  pkg:addProperty("btnAddStar","CCMenuItemImage")
  pkg:addProperty("btnAddSkillExp","CCMenuItemImage")
  
  pkg:addProperty("nodeActiviteSkillDesc","CCNode")
  pkg:addProperty("nodePasSkillDesc","CCNode")
  pkg:addProperty("nodeCommbineSkillDesc","CCNode")
  
  pkg:addProperty("containerBg","CCNode")
  pkg:addProperty("nodeProgressBar","CCNode")
  
  pkg:addProperty("menuStars","CCMenu")
  pkg:addProperty("btnStar1","CCMenuItemImage")
  pkg:addProperty("btnStar2","CCMenuItemImage")
  pkg:addProperty("btnStar3","CCMenuItemImage")
  pkg:addProperty("btnStar4","CCMenuItemImage")
  pkg:addProperty("btnStar5","CCMenuItemImage")
  pkg:addProperty("levelLabel","CCLabelBMFont")
  
  pkg:addProperty("btnCombineInfo","CCMenuItemImage")
  
  pkg:addFunc("propertyTipHandler",CardFormationDetailView.propertyTipHandler)
  pkg:addFunc("cardLevelUpHandler",CardFormationDetailView.cardLevelUpHandler)
  pkg:addFunc("combimeAlertHandler",CardFormationDetailView.combimeAlertHandler)
  
  
  --left board
  pkg:addProperty("nodeNameBoader","CCNode")
  pkg:addProperty("nodeUnitType","CCNode")
  pkg:addProperty("flagContainer","CCNode")
  pkg:addProperty("nodeUnitSkillType","CCNode")
  pkg:addProperty("labelName","CCLabelBMFont")
  pkg:addProperty("labelSubRank","CCLabelBMFont")
  
  pkg:addFunc("closeHandler",CardFormationDetailView.closeHandler)
  pkg:addFunc("LvUpEquipHandler",CardFormationDetailView.LvUpEquipHandler)
  pkg:addFunc("addStarHandler",CardFormationDetailView.addStarHandler)
  pkg:addFunc("addSkillExpHandler",CardFormationDetailView.addSkillExpHandler)


  local layer,owner = ccbHelper.load("card_formation_detail.ccbi","card_formation_detail","CCLayer",pkg)
  self:addChild(layer)
  
  --self.btnAddCardExp:setVisible(false)
  
  self.nodePortraitTblViewCon = display.newNode()
  self.node_mask:addChild(self.nodePortraitTblViewCon)
  
  self.btnStar1:setEnabled(false)
  self.btnStar2:setEnabled(false)
  self.btnStar3:setEnabled(false)
  self.btnStar4:setEnabled(false)
  self.btnStar5:setEnabled(false)
  self._menuStarsInitX = self.menuStars:getPositionX()
  
  local tipPos = ccp(80,80)
  self._weaponTip = TipPic.new()
  self.btnWeapon:addChild(self._weaponTip)
  self._weaponTip:setPosition(tipPos)
  
  self._armorTip = TipPic.new()
  self.btnArmor:addChild(self._armorTip)
  self._armorTip:setPosition(tipPos)
  
  self._accessoryTip = TipPic.new()
  self.btnAccessory:addChild(self._accessoryTip)
  self._accessoryTip:setPosition(tipPos)
  
  self._skillUpTip = TipPic.new()
  self.btnAddSkillExp:addChild(self._skillUpTip)
  self._skillUpTip:setPosition(ccp(87,52))
  self._skillUpTip:setVisible(false)
  
  self._levelUpTip = TipPic.new()
  self.btnAddCardExp:addChild(self._levelUpTip)
  self._levelUpTip:setPosition(ccp(87,52))
  self._levelUpTip:setVisible(false)
  
  self._1keyLevelUpEquipTip = TipPic.new()
  self.btnLvUpEquip:addChild(self._1keyLevelUpEquipTip)
  self._1keyLevelUpEquipTip:setPosition(ccp(100,65))
  self._1keyLevelUpEquipTip:setVisible(false)
  
  local addPos = ccp(40,40)
  local addWeaponIcon = display.newSprite("#card_formation_add_equipment.png")
  self.btnWeapon:addChild(addWeaponIcon)
  addWeaponIcon:setPosition(addPos)
  self._addWeaponIcon = addWeaponIcon
  
  local addArmorIcon = display.newSprite("#card_formation_add_equipment.png")
  self.btnArmor:addChild(addArmorIcon)
  addArmorIcon:setPosition(addPos)
  self._addArmorIcon = addArmorIcon
  
  local addAccessoryIcon = display.newSprite("#card_formation_add_equipment.png")
  self.btnAccessory:addChild(addAccessoryIcon)
  addAccessoryIcon:setPosition(addPos)
  self._addAccessoryIcon = addAccessoryIcon
end

function CardFormationDetailView:onExit()
  self.playStates:updateAbility(false)
  EquipmentReinforce:Instance():setPlaystatesView(nil)
  if EquipmentReinforce:Instance():getContainerView() ~= nil then
    EquipmentReinforce:Instance():getContainerView():removeFromParentAndCleanup(true)
  end
end

function CardFormationDetailView:cardLevelUpHandler()
  printf("cardLevelUpHandler")
  local card = self:getCurrentShowCard()
  if card ~= nil then
    local levelupView = CardLevelUpView.new(card,-256)
    levelupView:setDelegate(self)
    self:addChild(levelupView,200)
  end
end

function CardFormationDetailView:propertyTipHandler()
  local card = self:getCurrentShowCard()
  if card ~= nil then
    local cardFormationPropertyView = CardFormationPropertyView.new(card)
    self:addChild(cardFormationPropertyView)
  end
end

function CardFormationDetailView:combimeAlertHandler()
  local card = self:getCurrentShowCard()
  if card ~= nil then
    local alert = CardFormationCombineSkillView.new(self)
    self:addChild(alert)
  end
end

function CardFormationDetailView:enter()
  self._lastSelectedIdx =  self.playStates:getCurrentShowCardIdx()
  local cardData = nil
  local cards = {}
  if self._isOnBattlePlaystates == true then
     cards = self.playStates:getBattleCards()
  else
     cards = GameData:Instance():getCurrentPackage():getIdleCards()
  end
  cardData = cards[self._lastSelectedIdx + 1]
  if cardData == nil then
     self._lastSelectedIdx = #cards
  else
     self:getDelegate():playDubbingByCard(cardData)
  end

  
  self.nodeWeapon:setVisible(false)
  self.nodeArmor:setVisible(false)
  self.nodeAccessory:setVisible(false)

  self.tipImg = TipPic.new()
  self.tipImg:setPosition(87,52)
  self.btnAddStar:addChild(self.tipImg)
 
  self:buildLargePortraitList(self._lastSelectedIdx)
  

  self:setCurrentShowCard(cardData)
--  self:buildHeadList()
--  self:updateEquipSourceInfo()
--  self:doOpenLeftBoaderHandler(false)
--  self:setLock(_executeNewBird())
  _executeNewBird()
end

function CardFormationDetailView:buildLargePortraitList(idx)
    self._portraitViewCon = display.newNode()
    self.nodePortraitTblViewCon:addChild(self._portraitViewCon)
    self._portraitViewCon:setPositionX(-640)
    self._portraitViewArr = {}
    local maxlength = 8
    local cards = {}
    if self._isOnBattlePlaystates == true then
       cards = self.playStates:getBattleCards()
    else
       cards = GameData:Instance():getCurrentPackage():getIdleCards()
       if #cards > 8 then
         maxlength = #cards
       end
    end
    
    local cardIdx = idx + 1
    for i = 1, 3 do
       if i == 1 then
          cardIdx = cardIdx - 1
       end
       
       if i == 2 then
          cardIdx = cardIdx + 1
       end
       
       if i == 3 then
          cardIdx = cardIdx + 1
       end
       
       if cardIdx < 1 then
          cardIdx = maxlength
       end
       
       if cardIdx > maxlength then
          cardIdx = 1
       end
        
        --local portraitView = PlaystateCardGallery.new(cards[cardIdx],self._isOnBattlePlaystates)
        local portraitView = CardFormationLargePortraiView.new()
        portraitView:setCard(cards[cardIdx])
        portraitView:setDelegate(self:getDelegate())
        portraitView:setPositionX(640*(i-1))
        self._portraitViewCon:addChild(portraitView)
        table.insert(self._portraitViewArr,portraitView)
    end
    _registNewBirdComponent(106010,self.btnAddCardExp)
    _registNewBirdComponent(106004,self.btnAddStar)
    _registNewBirdComponent(106007,self.btnLvUpEquip)
    _registNewBirdComponent(106008,self.btnAddSkillExp)
   
    _registNewBirdComponent(106301,self.btnWeapon)
    _registNewBirdComponent(106302,self.btnArmor)
    _registNewBirdComponent(106303,self.btnAccessory)
    
    _registNewBirdComponent(106401,self.closeMenuItem)
    
end

function CardFormationDetailView:onTouch(event,x,y)
   if event == "began" then
      if self._isTweeningPortrait == true then
         return false
      end
      self._oldX = x
      
--      if y > display.height - 170 then
--        self._isDraggingTop = false
--        self._beganType = "top"
--        self._startX = x
--        return true
--      elseif y > 295 and y < display.height - 170 then
      if y > display.cy then
        self._beganType = "center"
        self._startX = self._portraitViewArr[2]:getPositionX()
        return true
      else
        return false
      end
   elseif event == "moved" then
      if self._beganType == "top" then
          self._oldX = x
      elseif self._beganType == "center" then
--          if self:getLock() == true then
--             return
--          end
          for key, m_portrait in pairs(self._portraitViewArr) do
              m_portrait:setPositionX(m_portrait:getPositionX() + (x - self._oldX))
          end
        
          self._oldX = x
      end
   elseif event == "ended" then
      
      local m_direction = 0
      if self._beganType == "top" then
       
      elseif self._beganType == "center" then
          local maxlength = 8
          local cards = {}
          if self._isOnBattlePlaystates == true then
             cards = self.playStates:getBattleCards()
          else
             cards = GameData:Instance():getCurrentPackage():getIdleCards()
             if #cards > 8 then
               maxlength = #cards
             end
          end
                    
         local selectIdx = self._lastSelectedIdx
         local offsetX = self._startX - self._portraitViewArr[2]:getPositionX()
         local maxCount = 3
         echo("ofsetX",offsetX)
         if math.abs(offsetX) > 10 then
             if offsetX < 0 then  -- left
                -- idx--
                selectIdx =  self._lastSelectedIdx - 1
                if selectIdx < 0 then
                    selectIdx = maxlength - 1
                end
                m_direction = -1
             elseif offsetX > 0 then -- right
                selectIdx = self._lastSelectedIdx + 1
                if  selectIdx > maxlength - 1 then
                   selectIdx = 0
                end
                m_direction = 1
             end
             
             if cards[selectIdx +  1] == nil then
                 m_direction = 0
             end

             self._isTweeningPortrait = true
             
             for key, m_portrait in pairs(self._portraitViewArr) do
                local targetX = 0
                if m_direction == -1 then
                   targetX = 640*(key-1) + 640
                elseif m_direction == 1 then
                   targetX = 640*(key-1) - 640
                else
                   targetX = 640*(key-1)
                end
                m_portrait:stopAllActions()
                transition.execute(m_portrait, CCMoveTo:create(0.15,ccp(targetX,m_portrait:getPositionY())),
                {
                  onComplete = function()
                    maxCount = maxCount - 1
                    print("maxCount:",maxCount)
                   
                    if maxCount == 0 then
                       if m_direction == -1 then
                          local m_idx = self._lastSelectedIdx + 1 + 1
                          if m_idx > maxlength then
                              m_idx = 1
                          end
                          table.insert(self._portraitViewArr,self._portraitViewArr[1])
                          table.remove(self._portraitViewArr,1)
                       elseif m_direction == 1 then
                          --self._portraitViewArr[#self._portraitViewArr]:setPositionX(640*2)
                          local m_idx = self._lastSelectedIdx + 1 - 1
                          if m_idx < 1 then
                              m_idx = maxlength
                           end
                          table.insert(self._portraitViewArr,1,self._portraitViewArr[#self._portraitViewArr])
                          table.remove(self._portraitViewArr,#self._portraitViewArr)
                       end

                       if m_direction ~= 0 then
                           self:touchAtHead(selectIdx)
                       end
                       self._isTweeningPortrait = false
                       
                    end
                  end,
                })
             
             end
         else
--            if self._currentShowCard ~= nil then
--              if y < 690 and y > 400 and x > display.cx - 200 and x < display.cx + 200 then
--                self:changeGeneralHandler()
--              end
--            else
--               if y < 690 and y > 400 and x > display.cx - 200 and x < display.cx + 200 then
--                 self:addCardToBattle()
--               end
--            end

            self:propertyTipHandler()
         end
         
      end
   end
end

function CardFormationDetailView:touchAtHead(idx)
      self._lastSelectedIdx = idx
      print("touchAtHead:~~~~~~~~~~~~~~~~",idx)
      local cards = {}
      if self._isOnBattlePlaystates == true then
        cards = self.playStates:getBattleCards()
      else
        cards = GameData:Instance():getCurrentPackage():getIdleCards()
      end

      local currentCard = cards[self._lastSelectedIdx+1]
      self:getDelegate():changeCurrentCard(currentCard)
      self:setCurrentShowCard(currentCard)
      self:resetPortraitViewList()
end

function CardFormationDetailView:resetPortraitViewList()
   local idx = self._lastSelectedIdx + 1
   local cardIdx = idx
   
    local maxlength = 8
    local cards = {}
    if self._isOnBattlePlaystates == true then
       cards = self.playStates:getBattleCards()
    else
       cards = GameData:Instance():getCurrentPackage():getIdleCards()
       if #cards > 8 then
         maxlength = #cards
       end
    end
   
   for i, _m_portrait in pairs(self._portraitViewArr) do
       if i == 1 then
          cardIdx = cardIdx - 1
       elseif i == 2 then
          cardIdx = cardIdx + 1
       elseif i == 3 then
          cardIdx = cardIdx + 1
       end
       
       if cardIdx < 1 then
          cardIdx = maxlength
       end
       if cardIdx > maxlength then
          cardIdx = 1
       end
       
       print("_m_portrait cardIdx:",i,cardIdx)
       _m_portrait:setCard(cards[cardIdx])
       _m_portrait:setPositionX(640*(i-1))
   end

end

function CardFormationDetailView:updateView()
  self.playStates:updateAbility(false)
  self:setCurrentShowCard(self:getCurrentShowCard())
end

function CardFormationDetailView:setCurrentShowCard(card)
  if EquipmentReinforce:Instance():getEquipmentSelectListView() ~= nil then
     EquipmentReinforce:Instance():getEquipmentSelectListView():removeFromParentAndCleanup(true)
     EquipmentReinforce:Instance():setEquipmentSelectListView(nil)
  end

  self.btnLvUpEquip:setVisible(card ~= nil and GameData:Instance():checkSystemOpenCondition(37,false))
  if card ~= nil then
   if card:getWeapon() ~= nil then
     if card:getActiveEquipId() > 0 and card:getActiveEquipId() ~= card:getWeapon():getRootId() then
       if GameData:Instance():getLanguageType() ~= LanguageType.JPN then
        self.btnLvUpEquip:setVisible(false)
       end
     end
   else
     if card:getArmor() == nil and card:getAccessory() == nil then
      self.btnLvUpEquip:setVisible(false)
     end
   end
  end

  self._weaponTip:setVisible(false)
  self._armorTip:setVisible(false)
  self._accessoryTip:setVisible(false)
  self._levelUpTip:setVisible(false)
  
  self._addWeaponIcon:setVisible(false)
  self._addArmorIcon:setVisible(false)
  self._addAccessoryIcon:setVisible(false)

  self._skillUpTip:setVisible(false)
  
  if self._expProgressBar == nil then
    local progressBar_bg = display.newSprite("#pg_bg.png")
    local progressBar_green = display.newSprite("#pg_green.png")
    local progressBar_yellow = display.newSprite("#pg_yellow.png")
    assert(progressBar_bg ~= nil)
    assert(progressBar_green ~= nil)
    assert(progressBar_yellow ~= nil)
    local progressBar = ProgressBarView.new(progressBar_bg, progressBar_green, progressBar_yellow)
    progressBar:setPercent(0, 1)
    progressBar:setPercent(0, 2)
    self.nodeProgressBar:addChild(progressBar)
    progressBar:setPosition(ccp(48,3))
    self._expProgressBar = progressBar
  end
  self._expProgressBar:setVisible(false)
   
  if card ~= nil then
    self:getDelegate():updateViewType(card)
    self._expProgressBar:setVisible(true)
    local curPercent = card:getExpPercentByLeve(card:getLevel(), card:getExperience())
    self._expProgressBar:setPercent(curPercent, 1)

    local weapons,startWeapon = EquipmentReinforce:Instance():getEquipmentsByCardAndEquipmentType(card,EquipmentReinforceConfig.EquipmentTypeWeapon)
    local armors,startArmor = EquipmentReinforce:Instance():getEquipmentsByCardAndEquipmentType(card,EquipmentReinforceConfig.EquipmentTypeArmor)
    local accessories,startAccessorie = EquipmentReinforce:Instance():getEquipmentsByCardAndEquipmentType(card,EquipmentReinforceConfig.EquipmentTypeAccessory)
    
    self._addWeaponIcon:setVisible(startWeapon == nil and #weapons > 0)
    self._addArmorIcon:setVisible(startArmor == nil and #armors > 0)
    self._addAccessoryIcon:setVisible(startAccessorie == nil and #accessories > 0)
    
    local weaponLvUpEnabled = EquipmentReinforce:Instance():getEquipmentsLvUpEnabled(card,EquipmentReinforceConfig.EquipmentTypeWeapon) 
    local weaponGradeUpEnabled = EquipmentReinforce:Instance():getEquipmentsGradeUpEnabled(card,EquipmentReinforceConfig.EquipmentTypeWeapon) 
    self._weaponTip:setVisible(weaponGradeUpEnabled == true)
    
    local armorLvUpEnabled = EquipmentReinforce:Instance():getEquipmentsLvUpEnabled(card,EquipmentReinforceConfig.EquipmentTypeArmor) 
    local armorGradeUpEnabled = EquipmentReinforce:Instance():getEquipmentsGradeUpEnabled(card,EquipmentReinforceConfig.EquipmentTypeArmor) 
    self._armorTip:setVisible(armorGradeUpEnabled == true)
    
    local accessoryLvUpEnabled = EquipmentReinforce:Instance():getEquipmentsLvUpEnabled(card,EquipmentReinforceConfig.EquipmentTypeAccessory)
    local accessoryGradeUpEnabled = EquipmentReinforce:Instance():getEquipmentsGradeUpEnabled(card,EquipmentReinforceConfig.EquipmentTypeAccessory) 
    self._accessoryTip:setVisible(accessoryGradeUpEnabled == true)
    
    -- tip lv up
    self._1keyLevelUpEquipTip:setVisible(weaponLvUpEnabled == true or armorLvUpEnabled == true or accessoryLvUpEnabled == true)
  end
  
  self.playStates:updateAbility()

  --update button state
  if card == nil then 
    self.btnAddStar:setVisible(false)
    self.btnAddSkillExp:setVisible(false)
    self.btnAddCardExp:setVisible(false)
    
    self.btnAddSkillExp:setEnabled(false)
    self.btnAddCardExp:setEnabled(false)
    
    self.btnAddStar:setEnabled(false)
    self.btnAddSkillExp:setEnabled(false)
    self.btnAddCardExp:setEnabled(false)
    --self.labelSkillLevelInfo:setString("")
  else 
    local curSkillLevel = card:getSkill():getLevel()
    local maxSkillLevel = card:getSkill():getMaxLevel()
    local color = (curSkillLevel==maxSkillLevel) and ccc3(32,143,0) or ccc3(255,255,255)
    self.btnAddStar:setEnabled(card:getGrade() < card:getMaxGrade())
    self.btnAddSkillExp:setEnabled(curSkillLevel < 100)
--    local enableLevel = (card:getLevel() < card:getMaxLevel()) and (card:getLevel() < GameData:Instance():getCurrentPlayer():getLevel())
--    self.btnAddCardExp:setEnabled(enableLevel)
    self.btnAddCardExp:setEnabled(true)
    
    --visible
    self.btnAddStar:setVisible(card:getGrade() < card:getMaxGrade())
    self.btnAddSkillExp:setVisible(curSkillLevel < 100)
    self.btnAddCardExp:setVisible(card:getLevel() < 100)
    
--    self.btnAddStar:setEnabled(true)
--    self.btnAddSkillExp:setEnabled(true)
    --self.btnAddCardExp:setEnabled(true)
    
    if GameData:Instance():checkSystemOpenCondition(8, false) == true then 
      self._skillUpTip:setVisible(Enhance:instance():canSkillUpForCard(card))
    end 
    
    self._levelUpTip:setVisible(card:getEnabledLevelUp())

  end 
  self._portraitViewArr[2]:setCard(card)
  self.tipImg:setVisible(false)
  self.nodeUnitSkillType:removeAllChildrenWithCleanup(true)
  self.nodeActiviteSkillDesc:removeAllChildrenWithCleanup(true)
  self.nodePasSkillDesc:removeAllChildrenWithCleanup(true)
  self.nodeCommbineSkillDesc:removeAllChildrenWithCleanup(true)
  self.nodeNameBoader:removeAllChildrenWithCleanup(true)
  self.nodeUnitType:removeAllChildrenWithCleanup(true)
  self.flagContainer:removeAllChildrenWithCleanup(true)
  self.labelName:setString("")
  self.levelLabel:setString("")
  self.btnCombineInfo:setVisible(false)
  
  if card ~= nil then
      --self.comSkillBg:setVisible(false)
      self._portraitViewCon:setVisible(true)
      self.menuStars:setVisible(true)
      self._currentShowCard = card
--      if self._currentShowCard:getIsBoss() == false then
--         self.btnSetBoss:setEnabled(true)
--      else
--         self.btnSetBoss:setEnabled(false)
--      end
      
--      local enabledSetBoss = GameData:Instance():checkSystemOpenCondition(31)
--      if enabledSetBoss == false then
--        self.btnSetBoss:setEnabled(false)
--      end
      
      self.tipImg:setVisible(Enhance:instance():isCardCanSurmounted(card))

      --[[
      self.labelHpValue:setString(string.format("%d", self._currentShowCard:getHp()))
      self.labelDamageValue:setString(string.format("%d", self._currentShowCard:getAttack()))
      self.labelDominanceValue:setString(string.format("%d", self._currentShowCard:getDominance()))
      self.labelIntelligenceValue:setString(string.format("%d", self._currentShowCard:getIntelligence()))
      self.labelStrength:setString(string.format("%d", self._currentShowCard:getStrength()))
      ]]

      local configId = card:getConfigId()
      
      local s = AllConfig.unit[configId].unit_cardname
      local name = ""
      local zh_idx = 1
      local zh_size = 3
      local zh_len = string.len(s)/zh_size
      for i= 1, zh_len do
        name = name..string.sub(s,zh_idx,string.len(s)/zh_len*i).."\n"
        zh_idx = zh_idx + zh_size
      end
      self.labelName:setString(name)
      self.levelLabel:setString(card:getLevel().."")
      
      if card:getGrade() >= 3 and card:getImproveGrade() > 0 then 
        local fntFileName
        if card:getGrade() < 4 then 
          fntFileName = "img/client/widget/words/change_number/change_number_blue.fnt"
        else 
          fntFileName = "img/client/widget/words/change_number/change_number_purple.fnt"
        end 
        self.labelSubRank:setFntFile(fntFileName)
        self.labelSubRank:setString(string.format("+%d", card:getImproveGrade()))
      else 
        self.labelSubRank:setString("")
      end 
      
      local val = GameData:Instance():getBattleAbilityForCards({card})
      self.label_zhandouli:setString(string.format("%d", val))
      
      local nameBoader = display.newSprite("#card_formation_quality_"..card:getGrade()..".png")
      self.nodeNameBoader:addChild(nameBoader)
      
      --update troop icon
       local sptIcon = nil
       sptIcon = _res(PbTroopSpt[card:getSpecies()])
       if sptIcon ~= nil then
          sptIcon:setScale(0.5)
          sptIcon:setPositionY(2)
          self.nodeUnitType:addChild(sptIcon)
       end  
       
      local skilltyperes = nil
      if AllConfig.unit[card:getConfigId()].config%2 == 0 then
          skilltyperes = _res(3042002)
      else
          skilltyperes = _res(3042001)
      end
      
      if skilltyperes ~= nil then
         skilltyperes:setScale(0.9)
         self.nodeUnitSkillType:addChild(skilltyperes)
      end
      
      if card:getSkill() ~= nil then
          local curSkillLevel = card:getSkill():getLevel()
          local maxSkillLevel = card:getSkill():getMaxLevel()
          local skillDesc = "「"..card:getSkill():getName().."」   ".._tr("level_%{lv1}/%{lv2}",{lv1 = curSkillLevel,lv2 = maxSkillLevel }).."\n"..GameData:Instance():formatSkillDesc(self:getCurrentShowCard())
          local dimension = CCSizeMake(335, 0)
          local color = ccc3(0, 0, 0)
          local label = RichLabel:create(skillDesc,"Courier-Bold",20, dimension, true,false)
          label:setColor(color)
          local labelSize = label:getTextSize()
          label:setPositionY(labelSize.height/2)
          self.nodeActiviteSkillDesc:addChild(label)
      else
         --self.labelActiveSkillNale:setString(_tr("none"))
         local label = CCLabelTTF:create(_tr("none"),"Courier-Bold",20)
         label:setAnchorPoint(ccp(0,0.5))
         local color = ccc3(0, 0, 0)
         label:setColor(color)
         self.nodeActiviteSkillDesc:addChild(label)
      end
      
      local specialitySkillId =  AllConfig.unit[configId].talent
      if specialitySkillId > 0 then
         local equipmentName = ""
         local activeEquipmentRootId = AllConfig.unit[configId].active_equipment
         if activeEquipmentRootId > 0 then
            equipmentName = GameData:Instance():getCurrentPlayer():getIllustratedInstance():getEquipmentByEquipRoot(activeEquipmentRootId):getRootName()
            equipmentName = "「"..equipmentName.."」 "
         end
         local skillDesc = equipmentName..AllConfig.cardskill[specialitySkillId].skill_description
         local dimension = CCSizeMake(435, 0)
         local color = ccc3(0, 0, 0)
         local label = RichLabel:create(skillDesc,"Courier-Bold",20, dimension, true,false)
         label:setColor(color)
         local labelSize = label:getTextSize()
         label:setPositionY(labelSize.height/2)
         self.nodePasSkillDesc:addChild(label)
      else
         local label = CCLabelTTF:create(_tr("none"),"Courier-Bold",20)
         label:setAnchorPoint(ccp(0,0.5))
         local color = ccc3(0, 0, 0)
         label:setColor(color)
         self.nodePasSkillDesc:addChild(label)
      end
       --[[
      local activeEquipmentRootId = AllConfig.unit[configId].active_equipment
      if activeEquipmentRootId > 0 then
        local equipmentName = GameData:Instance():getCurrentPlayer():getIllustratedInstance():getEquipmentByEquipRoot(activeEquipmentRootId):getRootName()
        if self:checkActiveEquipment(activeEquipmentRootId) == false then
          self.labelExclusiveEquipment:setColor(ccc3(138,138,138))
        else
          self.labelExclusiveEquipment:setColor(ccc3(255,255,255))
        end
        self.labelExclusiveEquipment:setString(equipmentName)
      else
        self.labelExclusiveEquipment:setColor(ccc3(255,255,255))
        self.labelExclusiveEquipment:setString(_tr("none"))
      end
      ]]
      local comboSkillId = AllConfig.unit[configId].combined_skill
      local isActiveComboSkill = nil
      if comboSkillId ~= nil and comboSkillId > 0 then
        local skillName = AllConfig.cardskill[comboSkillId].skill_name
        local isActive, comboSkillInfo = self:formatComboSkillName(comboSkillId)
        local dimension = CCSizeMake(385, 0)
        local color = ccc3(0, 0, 0)
        local label = RichLabel:create("「"..skillName.."」:"..comboSkillInfo,"Courier-Bold",20, dimension, true,false)
        label:setColor(color)
        local labelSize = label:getTextSize()
        label:setPositionY(labelSize.height/2)
        self.nodeCommbineSkillDesc:addChild(label)
        self.btnCombineInfo:setVisible(true)
      else
        local label = CCLabelTTF:create(_tr("none"),"Courier-Bold",20)
        label:setAnchorPoint(ccp(0,0.5))
        local color = ccc3(0, 0, 0)
        label:setColor(color)
        self.nodeCommbineSkillDesc:addChild(label)
      end
      
      --[[
      -- update bg
      if self._lastRank ~= self._currentShowCard:getGrade() then
         
         --self.containerBg:removeAllChildrenWithCleanup(true)
         self._lastRank = self._currentShowCard:getGrade()
         
         local zorder = 999
         if self._lastBg ~= nil then
           zorder = self._lastBg:getZOrder() - 1
           local time = 1.50
           local array = CCArray:create()
           local fadeOut = CCFadeOut:create(time)
           array:addObject(fadeOut)
           array:addObject(CCRemoveSelf:create())
           local action = CCSequence:create(array)
           self._lastBg:runAction(action)
         end
         
         local bg_pic = display.newSprite("img/playstates/bg/playstate_bj_"..self._currentShowCard:getGrade()..".png")
         bg_pic:setAnchorPoint(ccp(0.5,0))
         self.containerBg:addChild(bg_pic,zorder)
         
         self._lastBg = bg_pic
      end
      ]]
      
      --update country flag 
      local resId = 3022008
      if card:getCountry() == 1 then
        resId = 3022008
      elseif card:getCountry() == 2  then
        resId = 3022009
      elseif card:getCountry() == 3  then
        resId = 3022007
      elseif card:getCountry() == 4  then
        resId = 3022010
      end
      local countryFlag = _res(resId)
      if countryFlag ~= nil then
         countryFlag:setScale(0.5)
        self.flagContainer:addChild(countryFlag)
      end
      
      --update card star show
      for i=1, 5 do
        self["btnStar"..i]:setVisible(false)
        self["btnStar"..i]:setEnabled(false)
      end
      local maxRank = card:getMaxGrade()
      
      local star_distance = 18
      self.menuStars:setPositionX(self._menuStarsInitX + star_distance*(5 - maxRank) )
      
      for i = 1, maxRank do
        self["btnStar"..i]:setVisible(true)
        self["btnStar"..i]:setEnabled(false)
      end
      
      local currentRank = card:getGrade()
      for i=1, currentRank do
        self["btnStar"..i]:setEnabled(true)
      end
      
      --update Equipment show
      local showEquipmentLevel = function(iconSprite,lv)
        local size = iconSprite:getContentSize()
        local pos = ccp(26-size.width/2, 20-size.height/2)
        local lvIcon = display.newSprite("#playstates-image-lv.png")
        if lvIcon ~= nil then 
          lvIcon:setPosition(pos)
          iconSprite:addChild(lvIcon)
          local label = CCLabelBMFont:create(lv.."", "client/widget/words/card_name/number_skillup.fnt")
          if label ~= nil then 
            label:setPosition(ccp(pos.x + lvIcon:getContentSize().width/2 + label:getContentSize().width/2 + 4, pos.y))
            iconSprite:addChild(label)
          end 
        end 
      end
      
      
      local iconSprite = nil
      local coulerBoader = nil
      local iconWidth = 95
      local equipNodeTable = {self.nodeArmor,self.nodeAccessory,self.nodeWeapon}
      if self._currentShowCard:getWeapon() == nil then  -- card has no weapon
        self.nodeWeapon:setVisible(false)
        --self.labelWeapon:setString("")
      else 
        self.nodeWeapon:removeAllChildrenWithCleanup(true)
        self.nodeWeapon:setVisible(true)
        local equipData = self._currentShowCard:getWeapon()
        iconSprite = DropItemView.new(equipData:getConfigId())
        self.nodeWeapon:addChild(iconSprite)
        --self.labelWeapon:setString(equipData:getName())
        
        showEquipmentLevel(iconSprite,equipData:getLevel())
        
      end
      
      if self._currentShowCard:getArmor() == nil then  -- card has no armor
        self.nodeArmor:setVisible(false)
        --self.labelArmor:setString("")
      else 
        self.nodeArmor:setVisible(true)
        self.nodeArmor:removeAllChildrenWithCleanup(true)
        self.nodeArmor:setVisible(true)
       
        local equipData = self._currentShowCard:getArmor()
        iconSprite = DropItemView.new(equipData:getConfigId())
        self.nodeArmor:addChild(iconSprite)
        --self.labelArmor:setString(equipData:getName())
        
        showEquipmentLevel(iconSprite,equipData:getLevel())
      end
      
      if self._currentShowCard:getAccessory() == nil then  -- card has no accessory
        self.nodeAccessory:setVisible(false)
        --self.labelAccessory:setString("")
      else 
        self.nodeAccessory:removeAllChildrenWithCleanup(true)
        self.nodeAccessory:setVisible(true)
        
        local equipData = self._currentShowCard:getAccessory()
        iconSprite = DropItemView.new(equipData:getConfigId())
        self.nodeAccessory:addChild(iconSprite)
        --self.labelAccessory:setString(equipData:getName())
        
        showEquipmentLevel(iconSprite,equipData:getLevel())
      end

    -- add Exclusive mark
      local activeEquipmentRootId = AllConfig.unit[configId].active_equipment
      if activeEquipmentRootId > 0 then
        local isHaveExclusive,index = self:checkActiveEquipment(activeEquipmentRootId)
        if isHaveExclusive == true  then
          local exclusiveFont = display.newSprite("#exclusive_font.png")
          exclusiveFont:setPosition(ccp(-30,20))
               
          local array = CCArray:create()
          array:addObject(CCFadeOut:create(0.8))
          array:addObject(CCFadeIn:create(0.8))
          local action = CCRepeatForever:create(CCSequence:create(array))
          exclusiveFont:runAction(action)
    
          equipNodeTable[index]:addChild(exclusiveFont)
        end
      end

    --[[if comboSkillId ~= nil and comboSkillId > 0 then
      self.comSkillBg:setVisible(true)
      local comboSkillName =  AllConfig.cardskill[comboSkillId].skill_name
      if isActiveComboSkill~= nil and isActiveComboSkill == false then
        self.comSkillBg:removeChildByTag(10)
        self.comSkillName:setString(comboSkillName)
        self.comSkillName:setFntFile("client/widget/words/card_name/comboskill_1.fnt")
      elseif isActiveComboSkill ~= nil and isActiveComboSkill == true then
        self.comSkillName:setFntFile("client/widget/words/card_name/comboskill.fnt")
        self.comSkillName:setString(comboSkillName)
        self.comSkillBg:removeChildByTag(10)
        local anim,offsetX,offsetY,duration = _res(5020179)
        if anim ~= nil then
          anim:setPosition(ccp(self.comSkillBg:getContentSize().width/2.0,self.comSkillBg:getContentSize().height/2.0 ))
          self.comSkillBg:addChild(anim,10,10)
          anim:getAnimation():play("default")
        end
      end
    end]]
    
    printf("k_property_hit:"..card:getPropertyByType(k_property_hit))
    printf("k_property_evade:"..card:getPropertyByType(k_property_evade))
    printf("k_property_tough:"..card:getPropertyByType(k_property_tough))
    printf("k_property_block:"..card:getPropertyByType(k_property_block))
    printf("k_property_precision:"..card:getPropertyByType(k_property_precision))
    printf("k_property_damage_increase:"..card:getPropertyByType(k_property_damage_increase))
    printf("k_property_damage_reduce:"..card:getPropertyByType(k_property_damage_reduce))
  else
      printf("tip user goOnBattle")
      --self.comSkillBg:setVisible(false)
      self._currentShowCard = card
      --self.btnSetBoss:setVisible(false)
      self.menuStars:setVisible(false)
      self.flagContainer:removeAllChildrenWithCleanup(true)
      
      
      self.nodeAccessory:setVisible(false)
      --self.labelAccessory:setString("")
      
      self.nodeArmor:setVisible(false)
      --self.labelArmor:setString("")
      
      self.nodeWeapon:setVisible(false)
      --self.labelWeapon:setString("")
        
      --[[if self._lastBg == nil then
         local bg_pic = display.newSprite("img/playstates/bg/playstate_bj_1.png")
         bg_pic:setAnchorPoint(ccp(0.5,0))
         self.containerBg:addChild(bg_pic,999)
      end]]
  end

end

function CardFormationDetailView:getCurrentShowCard()
  return self._currentShowCard
end

function CardFormationDetailView:closeHandler()
  self:getDelegate():enterPrePlaystatesView()
end

function CardFormationDetailView:addStarHandler()
  if GameData:Instance():checkSystemOpenCondition(10, true) == false then 
    return false 
  end 
  
--  local card = self:getCurrentShowCard()
--   if card ~= nil then
--      self:getDelegate():updateViewType(card)
--
--      local controller = ControllerFactory:Instance():create(ControllerType.LEVELUP_CONTROLLER)
--      controller:enter(2,card)
--   end

  local card = self:getCurrentShowCard()
  if card ~= nil then
    local addStarView = CardSurmountView.new(card,-256)
    addStarView:setDelegate(self)
    self:addChild(addStarView)
  end
end

function CardFormationDetailView:addSkillExpHandler()
  if GameData:Instance():checkSystemOpenCondition(8, true) == false then 
    return false 
  end 
  
  local card = self:getCurrentShowCard()
  if card ~= nil then
    local skilllupView = CardSkillUpView.new(card,-256)
    skilllupView:setDelegate(self)
    self:addChild(skilllupView)
  end
end

function CardFormationDetailView:LvUpEquipHandler()
  local card = self:getCurrentShowCard()
  local weapon = card:getWeapon()
  local totalCost = 0
  local equipmentCount = 0
  local currentCoin = GameData:Instance():getCurrentPlayer():getCoin()
  if weapon ~= nil then
    local lvUpEnabled,cost,targetLevel = EquipmentReinforce:Instance():getEquipLvUpEnabledAndCost(weapon,true,currentCoin)
    if lvUpEnabled == true then
      currentCoin = currentCoin - totalCost
      totalCost = totalCost + cost
      equipmentCount = equipmentCount + 1
    end
  end
  
  local accessory = card:getAccessory()
  if accessory ~= nil then
    currentCoin = currentCoin - totalCost
    local lvUpEnabled,cost,targetLevel = EquipmentReinforce:Instance():getEquipLvUpEnabledAndCost(accessory,true,currentCoin)
    if lvUpEnabled == true then
      totalCost = totalCost + cost
      equipmentCount = equipmentCount + 1
    end
  end
  
  local armor = card:getArmor()
  if armor ~= nil then
    currentCoin = currentCoin - totalCost
    local lvUpEnabled,cost,targetLevel = EquipmentReinforce:Instance():getEquipLvUpEnabledAndCost(armor,true,currentCoin)
    if lvUpEnabled == true then
      totalCost = totalCost + cost
      equipmentCount = equipmentCount + 1
    end
  end
  
  if equipmentCount > 0 and card ~= nil then
    if totalCost > 150000 then
      local str = _tr("cost_%{price}_to_lvup_equipment",{price = totalCost})
      --local str = _tr("cost_%{price}_to_lvup_%{count}_equipment",{price = totalCost,count = equipmentCount})
      local pop = PopupView:createTextPopup(str, function()
         EquipmentReinforce:Instance():reqEquipStrengthen(card,EquipmentReinforceConfig.StrengthenCardEquipment)
      end)
      GameData:Instance():getCurrentScene():addChildView(pop)
    else
      EquipmentReinforce:Instance():reqEquipStrengthen(card,EquipmentReinforceConfig.StrengthenCardEquipment)
    end
  else
    Toast:showString(GameData:Instance():getCurrentScene(),_tr("have_not_quipment_to_lvup"), ccp(display.cx, display.cy + 170))
    return
  end
  
--  if card ~= nil then
--    EquipmentReinforce:Instance():reqEquipStrengthen(card,EquipmentReinforceConfig.StrengthenCardEquipment)
--  end
end

function CardFormationDetailView:checkActiveEquipment(activeEquipmentRootId)
  local equipmentData = AllConfig.equipment
  local equipIndex = SelectListType.CARD

  if self._currentShowCard:getWeapon() ~= nil then
    local configId = self._currentShowCard:getWeapon():getConfigId()
    local rootId = AllConfig.equipment[configId].equip_root
    if rootId == activeEquipmentRootId then
      equipIndex = SelectListType.WEAPON
      return true,equipIndex
    end
  end

  if self._currentShowCard:getArmor() ~= nil then
    local configId = self._currentShowCard:getArmor():getConfigId()
    local rootId = AllConfig.equipment[configId].equip_root 
    if rootId == activeEquipmentRootId then
      equipIndex = SelectListType.ARMOR
      return true,equipIndex
    end
  end

  if self._currentShowCard:getAccessory() ~= nil then
    local configId = self._currentShowCard:getAccessory():getConfigId()
    local rootId = AllConfig.equipment[configId].equip_root
    if rootId == activeEquipmentRootId then
      equipIndex = SelectListType.ACCESSORY
      return true,equipIndex
    end
  end

  return false,equipIndex

end

function CardFormationDetailView:checkIsbattleCard(unitRootId)
  local battleCardArray = self.playStates:getBattleCards()
  for k, v in pairs(battleCardArray) do
    local configId = v:getConfigId()
    local rootId  = math.floor(configId/100)
    if rootId == unitRootId then
      return true
    end
  end
  return false
end


function CardFormationDetailView:formatComboSkillName(curComboSkillId)

  

  local comboSkillInfo = AllConfig.cardskill[curComboSkillId].skill_description
  local n = {"n1","n2","n3","n4","n5" }
  local name = {"name1","name2","name3","name4","name5"}

  local function getValue()
    n[1] = AllConfig.cardskill[curComboSkillId].n1 or 0
    n[2] = AllConfig.cardskill[curComboSkillId].n2 or 0
    n[3] = AllConfig.cardskill[curComboSkillId].n3 or 0
    n[4] = AllConfig.cardskill[curComboSkillId].n4 or 0
    n[5] = AllConfig.cardskill[curComboSkillId].n5 or 0
  end
  getValue()
  local isActive = true
  for i = 1, 5, 1 do
    if n[i] >0 then
      local configId = n[i]*100+1
      local isBattleCard = self:checkIsbattleCard(n[i])
      if isBattleCard == false then
        local strName = AllConfig.unit[configId].unit_name
        name[i] = "<color><value>7500145</>"..strName.."</>"
        isActive = false
      else
        name[i] = AllConfig.unit[configId].unit_name
      end
    else
      name[i] = ""
    end
  end

  local formatStr = string.format(comboSkillInfo,name[1],name[2],name[3],name[4],name[5])
  return isActive,formatStr
end


------
--  Getter & Setter for
--      CardFormationDetailView._SelectList 
-----
function CardFormationDetailView:setSelectList(SelectList)
  self._SelectList = SelectList
end

function CardFormationDetailView:getSelectList()
  return self._SelectList
end

function CardFormationDetailView:weaponSelectHandler(eventName,control,controlEvent)
  
  
  if self._addWeaponIcon:isVisible() == false 
  and GameData:Instance():checkSystemOpenCondition(29, true) == false 
  then 
    return
  end

  if self._currentShowCard == nil then
    return
  end
  
  
  local equip = self:getCurrentShowCard():getWeapon()
  if equip == nil then
    --self:getDelegate():enterSelectListView(SelectListType.WEAPON)
    local changeListView = EquipmentChangeListView.new(self:getCurrentShowCard(),EquipmentReinforceConfig.EquipmentTypeWeapon)
    self:addChild(changeListView,100)
    self:setSelectList(changeListView)
  else
    local equipmentCom = EquipmentReinforceView.new(equip)
    GameData:Instance():getCurrentScene():addChildView(equipmentCom)
  end
  
  --self:getDelegate():enterSelectListView(SelectListType.WEAPON)
end

function CardFormationDetailView:accessorySelectHandler(eventName,control,controlEvent)
  if self._addAccessoryIcon:isVisible() == false 
  and GameData:Instance():checkSystemOpenCondition(29, true) == false
  then 
    return
  end
  
  if self._currentShowCard == nil then
    return
  end
  
  local equip = self:getCurrentShowCard():getAccessory()
  if equip == nil then
    local changeListView = EquipmentChangeListView.new(self:getCurrentShowCard(),EquipmentReinforceConfig.EquipmentTypeAccessory)
    self:addChild(changeListView,100)
    self:setSelectList(changeListView)
  else
    local equipmentCom = EquipmentReinforceView.new(equip)
    GameData:Instance():getCurrentScene():addChildView(equipmentCom)
    --[[if self:getCurrentShowCard():getActiveEquipId() > 0 and self:getCurrentShowCard():getActiveEquipId() ~= equip:getRootId() then
      equipmentCom:showSideComponentByType(EquipmentReinforceConfig.ComponentTypeSideTurnExclusive)
    end]]
  end
  
  --self:getDelegate():enterSelectListView(SelectListType.ACCESSORY)
end

function CardFormationDetailView:armorSelectHandler(eventName,control,controlEvent)
  if self._addArmorIcon:isVisible() == false 
  and GameData:Instance():checkSystemOpenCondition(29, true) == false
  then 
    return
  end

  if  self._currentShowCard == nil then
    return
  end
  
  local equip = self:getCurrentShowCard():getArmor()
  if equip == nil then
    local changeListView = EquipmentChangeListView.new(self:getCurrentShowCard(),EquipmentReinforceConfig.EquipmentTypeArmor)
    self:addChild(changeListView,100)
    self:setSelectList(changeListView)
  else
    local equipmentCom = EquipmentReinforceView.new(equip)
    --self:addChild(equipmentCom,100)
    GameData:Instance():getCurrentScene():addChildView(equipmentCom)
    --[[if self:getCurrentShowCard():getActiveEquipId() > 0 and self:getCurrentShowCard():getActiveEquipId() ~= equip:getRootId() then
      equipmentCom:showSideComponentByType(EquipmentReinforceConfig.ComponentTypeSideTurnExclusive)
    end]]
  end
  --self:getDelegate():enterSelectListView(SelectListType.ARMOR)
end


return CardFormationDetailView