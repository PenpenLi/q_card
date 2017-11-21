require("view.skill_range.ArtOfWarView")
require("view.battle_formation.BattleFormationListView")
SkillRangeInfoView = class("SkillRangeInfoView",BaseView)
function SkillRangeInfoView:ctor(fightType,delegate)
  SkillRangeInfoView.super.ctor(self)
  self._fightType = fightType
  self:setDelegate(delegate)
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("labelHp","CCLabelTTF")
  pkg:addProperty("labelAtk","CCLabelTTF")
  pkg:addProperty("labelCardName","CCLabelTTF")
  pkg:addProperty("labelActivitySkillName","CCLabelTTF")
  pkg:addProperty("labelCardType","CCLabelTTF")
  pkg:addProperty("label_zhudongji","CCLabelTTF")
  pkg:addProperty("containerHead","CCNode")
  pkg:addProperty("containerSkillRangeIcon","CCNode") 
  pkg:addProperty("nodeCardType","CCNode")
  pkg:addProperty("btnArtOfWar","CCMenu") 
  pkg:addProperty("btnChangeBattleFormation","CCMenu") 
  pkg:addProperty("btnEditBattleFormation","CCMenu") 
  
  pkg:addProperty("artOfWarMenuItem","CCMenuItemImage") 
  pkg:addProperty("loadBattleFormationMenuItem","CCMenuItemImage") 
  pkg:addProperty("editBattleFormationMenuItem","CCMenuItemImage") 
    
  pkg:addFunc("clickBtnHandler",SkillRangeInfoView.clickBtnHandler) 
  pkg:addFunc("clickBtnChangeFormationHandler",SkillRangeInfoView.clickBtnChangeFormationHandler)  
  pkg:addFunc("editBattleFormationHandler",SkillRangeInfoView.editBattleFormationHandler)  
  
  local node,owner = ccbHelper.load("SkillRangeInfo.ccbi","SkillRangeInfoCCB","CCNode",pkg)
  self:addChild(node)

  self.label_zhudongji:setString(_tr("zhudongji"))
  
  if fightType == "PVP_REAL_TIME" then
    self.btnArtOfWar:setVisible(false)
    self.btnChangeBattleFormation:setVisible(false)
    self.btnEditBattleFormation:setVisible(false)
  elseif fightType == "PVE_BABLE" then
    self.btnEditBattleFormation:setPositionX(self.btnEditBattleFormation:getPositionX() - 90)
    self.btnChangeBattleFormation:setVisible(false)
    local cardsFormation = BattleFormation:Instance():getCardsFormationByBattleIndex(BattleFormation.BATTLE_INDEX_BABLE)
    dump(cardsFormation)
    if #cardsFormation <= 0 then
      self:editBattleFormationHandler()
    else
      local hasLeader = false
      for key, battleCardInfo in pairs(cardsFormation) do
        if battleCardInfo.leader == 1 then
          hasLeader = true
          break
        end
      end
      if hasLeader == false then
        self:editBattleFormationHandler()
      end
    end
  end
  
  _registNewBirdComponent(105105,self.loadBattleFormationMenuItem)
  _registNewBirdComponent(105106,self.editBattleFormationMenuItem)
  
  
  
end

function SkillRangeInfoView:editBattleFormationHandler()
  local battleView = self:getDelegate()
  if battleView == nil then
    return 
  end
  
  local battleFormationIdx = BattleFormation:Instance():getCurrentAttackBattleFormationIdx()
--  local isAttack = battleView:getBattleData():getSelfIsAttacker()
--  if isAttack ~= true then
--    
--    battleFormationIdx = BattleFormation:Instance():getCurrentAttackBattleFormationIdx()
--  end
--  
  if self._fightType == "PVE_BABLE" then
    battleFormationIdx = BattleFormation.BATTLE_INDEX_BABLE
  end

  local battleFormationView = BattleFormationView.new(true,battleFormationIdx,true)
  battleFormationView:setDelegate(battleView)
  battleView:addChild(battleFormationView,5000)
  battleView:setSelfCardsVisible(false)
  battleView:setEnabledCardEnterEffect(false)
  self:runAction(CCMoveTo:create(0.3,ccp(0,120)))
  
  local offsetY = 0
  if self._fightType == "PVP_REAL_TIME" then
    offsetY = display.cy - 45
  end
  
  if battleView._countLabel ~= nil then
    battleView._countLabel:runAction(CCMoveTo:create(0.25,ccp(display.width/2,display.height - (65 + offsetY))))
  end
 
  if battleView._countLabeltop ~= nil then
    battleView._countLabeltop:runAction(CCMoveTo:create(0.25,ccp(display.width/2,display.height - (25 + offsetY))))
  end
  
  if battleView._troopIntroductionView ~= nil then
    battleView._troopIntroductionView:removeAllChildrenWithCleanup(true)
    battleView._troopIntroductionView = nil
  end
  
end

function SkillRangeInfoView:clickBtnHandler()
  print("clickBtnHandler")
  local artOfWar = ArtOfWarView.new()
  artOfWar:setDelegate(self:getDelegate())
  self:getParent():addChild(artOfWar,2000)
  Guide:Instance():removeGuideLayer()
end

function SkillRangeInfoView:clickBtnChangeFormationHandler()
  local battleFormationList = BattleFormationListView.new(true,BattleFormation:Instance():getCurrentAttackBattleFormationIdx())
  battleFormationList:setIsFastSwitchInBattle(true)
  battleFormationList:setDelegate(self:getDelegate())
  self:getDelegate():addChild(battleFormationList,5000)
end

------
--  Getter & Setter for
--      SkillRangeInfoView._card 
-----
function SkillRangeInfoView:setCard(card)
	self._card = card
	if card ~= nil then
	    local configId = card:getConfigId()
	    self.labelHp:setString(string.format("%d", card:getHpFix()))
      self.labelAtk:setString(string.format("%d", card:getAttackFix()))
      
      self.nodeCardType:removeAllChildrenWithCleanup(true)
      local sptIcon = _res(PbTroopSpt[card:getSpecies()])
      sptIcon:setScale(0.5)
      self.nodeCardType:addChild(sptIcon)
      self.labelCardType:setString(AllConfig.unittype[card:getSpecies()].name)
      
      self.containerSkillRangeIcon:removeAllChildrenWithCleanup(true)
      local configId = card:getConfigId()
      if card:getSkill() ~= nil then
          self.labelActivitySkillName:setString(card:getSkill():getName())
          --self.lableSkillDescription:setString(card:getSkill():getDescription())
          
          local res = _res(card:getSkill():getRangeResId())
          if res ~= nil then
            self.containerSkillRangeIcon:addChild(res)
            if card:getPos() >= 4 and card:getPos() <= 15 then
            
            else
               res:setScaleY(-1)
            end
          end
      else
         self.labelActivitySkillName:setString(_tr("none"))
      end
      
--      local specialitySkillId =  AllConfig.unit[configId].talent
--      if specialitySkillId > 0 then
--         local specialitySkillName =  AllConfig.cardskill[specialitySkillId].skill_name
--         local specialitySkillInfo = AllConfig.cardskill[specialitySkillId].skill_description
--         self.labelPasiveSkillName:setString(specialitySkillName)
--      else
--         self.labelPasiveSkillName:setString("无")
--      end
      
      self.containerHead:removeAllChildrenWithCleanup(true)
      local cardHeadView = CardHeadView.new()
      cardHeadView:setScale(0.7)
      cardHeadView:setCard(card)
      self.containerHead:addChild(cardHeadView)
      self.labelCardName:setString(card:getName())
	end
end

function SkillRangeInfoView:getCard()
	return self._card
end

return SkillRangeInfoView