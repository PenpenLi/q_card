require("controller.BaseController")
require("view.card_formation.CardFormationListView")
require("view.card_formation.CardFormationDetailView")
require("view.component.SceneWithTopBottom")
require("model.PlayStates")
require("model.equipment_reinforce.EquipmentReinforce")

PlayStatesController = class("PlayStatesController",BaseController)

function PlayStatesController:ctor()
  PlayStatesController.super.ctor(self,"PlayStatesController")
  self.playStates = PlayStates.new()
  self.playStatesView = nil
  self._m_nSoundId = nil
end

function PlayStatesController:enter(idx, isOnBattlePlaystates)
  echo("enterPlaystates",idx)
  if idx == nil then
     idx = 1
  end
  PlayStatesController.super.enter(self)
  self:setScene(GameData:Instance():getCurrentScene())
  self:enterByIdx(idx, isOnBattlePlaystates)
end

function PlayStatesController:enterByIdx(idx,isOnBattlePlaystates)
  echo("enterByIdx:", idx,isOnBattlePlaystates)

  if isOnBattlePlaystates == nil then
     isOnBattlePlaystates = false
  end
 
  GameData:Instance():pushViewType(ViewType.playstate, {idx, isOnBattlePlaystates})
  
  self.playStates:setCurrentShowCardByIdx(idx-1, isOnBattlePlaystates)
  
  if isOnBattlePlaystates == true then
    self:enterPlayStatesView(isOnBattlePlaystates)
  else
    self:enterPrePlaystatesView()
  end
end

function PlayStatesController:enterInfoView(idx,isOnBattlePlaystates)
  print("enterInfoView:", idx,isOnBattlePlaystates)
  if idx == nil then
     idx = 1
  end

  GameData:Instance():pushViewType(ViewType.playstate, {idx, isOnBattlePlaystates})

  PlayStatesController.super.enter(self)
  self:setScene(GameData:Instance():getCurrentScene())
  self.playStates:setCurrentShowCardByIdx(idx-1, isOnBattlePlaystates)

  if isOnBattlePlaystates == false then 
    self.playStates:setPreViewTabType(2)
    local cards = GameData:Instance():getCurrentPackage():getIdleCards()
    if #cards <= 0 then 
      self:enterPrePlaystatesView()
      return 
    end 
  else  
    self.playStates:setPreViewTabType(1)
  end 

  self:enterPlayStatesView(isOnBattlePlaystates)
end 

function PlayStatesController:enterPrePlaystatesView()
  --local playStatesView = PrePlaystatesView.new(self.playStates)
  local playStatesView = CardFormationListView.new(CCSizeMake(615,780),self.playStates)
  playStatesView:setDelegate(self)
  self:getScene():replaceView(playStatesView,true,false)
end

-- goIntoBattle
function PlayStatesController:goIntoBattle(position,card)
  self.playStates:goIntoBattle(position,card)
end

-- goDownFromBattle
function PlayStatesController:goDownFromBattle(card)
  if card == nil then
    return
  end 
  self.playStates:goDownFromBattle(card)
end

--removeEquipmentFromCard
--function PlayStatesController:removeEquipmentFromCard(equipment)
--  if equipment == nil then
--    return
--  end 
--  echo("playstates controller:",equipment:getId())
--  local toRemoveEquipment = equipment
--  self.playStates:removeEquipmentFromCard(toRemoveEquipment)
--end

--assembleEquipmentToCard
function PlayStatesController:changeCardEquipmentC2S(dressOrUnDress,equipmentId)
  --printf("assembleEquipment"..equipmentId.."ToCard"..cardId)
  self.playStates:changeCardEquipmentC2S(dressOrUnDress,equipmentId)
end

--resetMasterCard
function PlayStatesController:resetMasterCard()
  self.playStates:resetMasterCard()
end

--QuickExchangeCard
function PlayStatesController:quickExchangeCard(targetCard)
  self.playStates:quickExchangeCard(targetCard)
end

function PlayStatesController:enterPlayStatesView(isOnBattlePlaystate)
  printf("enter playStatesView")
  --local playStatesView = PlayStatesView.new(self.playStates,isOnBattlePlaystate)
  local playStatesView = CardFormationDetailView.new(self.playStates,isOnBattlePlaystate)
  self.playStates:setPlayStatesView(playStatesView)
  playStatesView:setDelegate(self)
  playStatesView:enter()
  --playStatesView:setCurrentShowCard(card)
  self:getScene():replaceView(playStatesView,true,false)
end

function PlayStatesController:playDubbingByCard(card)
  if card == nil then
     return
  end
  
  GameData:Instance():playDubbingByCard(card)
--  local randomDubbingId = card:getRandomDubbing()
--  print("randomDubbingId:",randomDubbingId)
--  if randomDubbingId ~= 0 then
--     if self._m_nSoundId ~= nil then
--        SoundManager.stopEffect(self._m_nSoundId)
--        self._m_nSoundId = nil
--     end
--     self._m_nSoundId = SoundManager.playEffect("img/"..AllConfig.sounds[randomDubbingId].sounds_path)
--  end
end

function PlayStatesController:changeCurrentCard(card)
  self:playDubbingByCard(card)
  self.playStates:setCurrentShowCard(card)
end

function PlayStatesController:enterSelectListView(type,position,isAddCard,isFromPreView)
  local playStatesListView = PlayStatesListView.new(self.playStates,type,position,isAddCard,isFromPreView)
  self.playStates:setPlayStatesView(playStatesListView)
  playStatesListView:setDelegate(self)
  
  self:getScene():replaceView(playStatesListView)
  playStatesListView:enter()
  self:getScene():setTopVisible(true)
end

function PlayStatesController:exit()
   PlayStatesController.super.exit(self)
   echo("PlayStatesController:exit()")
   self.playStates:destroy()
   self:getScene():setBottomVisible(true)
   self:getScene():setTopVisible(true)
end

function PlayStatesController:updateViewType(card)
  if card ~= nil then 
    local idx = self.playStates:getCurrentShowCardIdx() + 1
    local _,isOnBattle = card:getIsOnBattle()
    local listType = self.playStates:getPreViewTabType()
    echo("==== updateViewType: idx, isOnbattle", idx, isOnBattle)
    GameData:Instance():pushViewType(ViewType.playstate, {idx, isOnBattle})
  end 
end 

return PlayStatesController
