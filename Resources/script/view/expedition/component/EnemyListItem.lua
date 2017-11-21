require("view.Common")
EnemyListItem = class("EnemyListItem",BaseView)

function EnemyListItem:ctor(enemyData)
	local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("isSelectedHightLight","CCScale9Sprite")
  pkg:addProperty("nodePreviewContainer","CCnode")
  pkg:addProperty("lableName","CCLabelTTF")
  pkg:addProperty("lableTime","CCLabelTTF")
  pkg:addProperty("lableLevel","CCLabelTTF")
  pkg:addProperty("lablePreLevel","CCLabelTTF")
  pkg:addProperty("lableBattleDesc","CCLabelTTF")
  pkg:addProperty("nodePreviewContainer","CCNode")
  pkg:addProperty("nodeProtect","CCNode")
  pkg:addProperty("btnAttack","CCMenuItemImage")
  pkg:addFunc("onAttackClickHandler",EnemyListItem.onAttackClickHandler)
  local layer,owner = ccbHelper.load("ExpeditionEnemyListItem.ccbi","EnemyListItemCCB","CCLayer",pkg)
  self:addChild(layer)
  self.isSelectedHightLight:setVisible(false)
  self.nodeProtect:setVisible(false)
  self.lableTime:setString("")
  self:setData(enemyData)
  
  self.lablePreLevel:setString(_tr("level")..":")
  self.lableBattleDesc:setString(_tr("attack_you"))
end

function EnemyListItem:setSelected(Selected)
  self._Selected = Selected
  if self._Selected == true then
  end
end

function EnemyListItem:getSelected()
  return self._Selected
end

function EnemyListItem:setData(data)
  self._data = data
  if self._data ~= nil then
     self.lableName:setString(self._data:getPlayerName())
     self.lableLevel:setString(self._data:getLevel().."")
     
     self.nodePreviewContainer:removeAllChildrenWithCleanup(true)
     if self._data:getHeadId() ~= nil then
       local headIcon = nil
       if self._data:getHeadId() > 1 then
          headIcon = _res(self._data:getHeadId())
          headIcon:setScale(0.65)
       else
          headIcon = _res(3012502)
          headIcon:setScale(0.65)
       end
       if headIcon ~= nil then
          self.nodePreviewContainer:addChild(headIcon)
       end
    end
  end
end

function EnemyListItem:getData()
  return self._data
end

function EnemyListItem:onAttackClickHandler()

--   if GameData:Instance():getCurrentPlayer():getToken() <= 0 then
--       --local pop = PopupView:createTextPopup(_tr("need_more_token"), function() return end,true)
--       --GameData:Instance():getCurrentScene():addChildView(pop)
--	   Common.CommonFastBuyToken()
--       return
--   end
--   
--   local battleCards = GameData:Instance():getCurrentPackage():getBattleCards()
--    local battleCardsLength = table.getn(battleCards)
--    local cost = 0
--    for i = 1,battleCardsLength do
--        cost = cost + battleCards[i]:getLeadCost()
--    end
--    
--    local pop = nil
--    if GameData:Instance():getCurrentPlayer():getLeadShip() < cost then
--       pop = PopupView:createTextPopup(_tr("leadship_exceed_pls_off_battle"), function() return end,true)
--       GameData:Instance():getCurrentScene():addChildView(pop)
--       return
--   end
--   
--    if GameData:Instance():getCurrentPackage():checkItemBagEnoughSpace(1) == false then
--       pop = PopupView:createTextPopup(_tr("bag is full"), function() return end,true)
--       GameData:Instance():getCurrentScene():addChildView(pop)
--       return
--   elseif GameData:Instance():getCurrentPackage():checkCardBagEnoughSpace(1) == false then
--       pop = PopupView:createTextPopup(_tr("card bag is full"), function() return end,true)
--       GameData:Instance():getCurrentScene():addChildView(pop)
--       return
--   elseif GameData:Instance():getCurrentPackage():checkEquipBagEnoughSpace(1) == false then
--       pop = PopupView:createTextPopup(_tr("equip bag is full"), function() return end,true)
--       GameData:Instance():getCurrentScene():addChildView(pop)
--       return
--   else
--   end
   
  local currentTime = Clock:Instance():getCurServerUtcTime()
  if GameData:Instance():getExpeditionInstance():getSelfPvpBaseData():getProtectTime() > currentTime then
     local pop = PopupView:createTextPopup(_tr("revenge_protect_will_invalid"), function() 
        if self:getData() ~= nil then
           self:getDelegate():checkPvpFight(self:getData():getPlayerId())
        end
     end)
     GameData:Instance():getCurrentScene():addChildView(pop)
     return
  end
   
  if self:getData() ~= nil then
     self:getDelegate():checkPvpFight(self:getData():getPlayerId(),ExpeditionConfig.challengeTypeEnemy)
  end
end

return EnemyListItem