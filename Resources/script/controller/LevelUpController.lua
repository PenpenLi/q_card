require("controller.BaseController")
require("view.enhance.LevelUpView")
require("view.enhance.SurmountView")
require("view.enhance.DismantleView")
require("view.enhance.SkillUpView")
require("view.enhance.CardListView")
require("model.Enhance")

LevelUpController = class("LevelUpController",BaseController)

function LevelUpController:ctor()
  LevelUpController.super.ctor(self)
end

function LevelUpController:enter(viewIdx, card)
  LevelUpController.super.enter(self)

  self.data = Enhance:instance()
  self.data:init()
  
  if nil == self:getScene() then
    self:setScene(GameData:Instance():getCurrentScene())
  end
  self.firstEngtry = true

  if viewIdx == nil then 
    viewIdx = 1
  end
  local viewType = ViewType.none 
  if viewIdx == 1 then 
    viewType = ViewType.enhance_levelup 
    self.data:setLevelUpCard(card)
    self:displayLevelUpView()
  elseif viewIdx == 2 then 
    viewType = ViewType.enhance_surmount 
    self.data:setSurmountedCard(card)
    self:displaySurmountView()
  elseif viewIdx == 3 then 
    viewType = ViewType.enhance_dismantle 
    self:displayDismantleView()
  elseif viewIdx == 4 then 
    viewType = ViewType.enhance_skillup
    self.data:setSkillCard(card)
    self:displaySkillView()
  end

  GameData:Instance():pushViewType(viewType, card)

  self.firstEngtry = false
end

function LevelUpController:exit()
  echo("---LevelUpController:exit---")
  LevelUpController.preView = nil 

  self.data:exit()
  LevelUpController.super.exit(self)
end

function LevelUpController:initDataForView(forViewIndex)
  if forViewIndex == 1 then  --level up
    self:dataInstance():setSurmountedCard(nil)
    self:dataInstance():setDismantleCards(nil)
    self:dataInstance():setSkillCard(nil)
  elseif forViewIndex == 2 then 
    self:dataInstance():setLevelUpCard(nil)
    self:dataInstance():setLevelUpCards(nil)
    self:dataInstance():setDismantleCards(nil)
    self:dataInstance():setSkillCard(nil)
  elseif forViewIndex == 3 then 
    self:dataInstance():setLevelUpCard(nil)
    self:dataInstance():setLevelUpCards(nil)
    self:dataInstance():setSurmountedCard(nil)
    self:dataInstance():setSkillCard(nil)
  elseif forViewIndex == 4 then 
    self:dataInstance():setLevelUpCard(nil)
    self:dataInstance():setLevelUpCards(nil)
    self:dataInstance():setSurmountedCard(nil)
    self:dataInstance():setDismantleCards(nil)
  end
end

function LevelUpController:dataInstance()
  return self.data
end

function LevelUpController:backCallback()
  echo("LevelUpController:backCallback")
  self:displayHomeView()
end

function LevelUpController:displayLevelUpView()
  if GameData:Instance():checkSystemOpenCondition(6, true) == false then 
    return false 
  end 

  self:initDataForView(1)

  local view = LevelUpView.new()
  view:setDelegate(self)
  
  if self.firstEngtry == true then 
    self:getScene():replaceView(view)
  else
    self:getScene():replaceView(view,false,false)
  end
  self.curViewIndex = 1

  return true
end

function LevelUpController:displaySurmountView()
  if GameData:Instance():checkSystemOpenCondition(10, true) == false then 
    return false 
  end 
  
  self:initDataForView(2)

  echo("LevelUpController:displaySurmountView")
  local view = SurmountView.new()
  view:setDelegate(self)
  self:getScene():replaceView(view,false,false)
  self.curViewIndex = 2

  return true
end

function LevelUpController:displayDismantleView()
  self:initDataForView(3)

  local view = DismantleView.new()
  view:setDelegate(self)
  self:getScene():replaceView(view,false,false)
  self.curViewIndex = 3
end

function LevelUpController:displaySkillView()
  if GameData:Instance():checkSystemOpenCondition(8, true) == false then 
    return false 
  end 

  self:initDataForView(4)

  local view = SkillUpView.new()
  view:setDelegate(self)
  self:getScene():replaceView(view,false,false)
  self.curViewIndex = 4

  return true 
end


function LevelUpController:goBackView()
  GameData:Instance():gotoPreView()
end

function LevelUpController:displayPreView()
  if self.curViewIndex == 1 then 
    self:displayLevelUpView()
  elseif self.curViewIndex == 2 then 
    self:displaySurmountView()
  elseif self.curViewIndex == 3 then 
    self:displayDismantleView()
  else --self.curViewIndex == 4 then 
    self:displaySkillView()
  end
end

function LevelUpController:disPlayCardListForLevelUp(selectType)
  local view = CardListView.new(selectType)
  view:setDelegate(self)
  local sourceCards = nil 
  if selectType == SelectType.SELECTE_ONE then 
    view:setIsUsedFor(CardListType.LEVEL_UP_CARD)
    sourceCards = self:dataInstance():getCardForLevelUp()
  else 
    view:setIsUsedFor(CardListType.LEVEL_UP_EATTEN_CARD)
    sourceCards = self:dataInstance():getCardToEatForLevelUp()
  end
  
  view:init(sourceCards)
  self:getScene():replaceView(view,false,false)
end

function LevelUpController:disPlayCardListForSurmount()
  local view = CardListView.new(SelectType.SELECTE_ONE)
  view:setDelegate(self)
  local sourceCards = self:dataInstance():getCardForSurmount()
  view:setIsUsedFor(CardListType.SURMOUNT)
  view:init(sourceCards)
  self:getScene():replaceView(view,false,false)
end

function LevelUpController:disPlayCardListForDismantle()
  local view = CardListView.new(SelectType.SELECTE_ALL)
  view:setDelegate(self)
  local sourceCards = self:dataInstance():getCardForDismantle()
  view:setIsUsedFor(CardListType.DISMANTLE)
  view:init(sourceCards)
  self:getScene():replaceView(view,false,false)
end

function LevelUpController:disPlayCardListForSkillUp()
  local view = CardListView.new(SelectType.SELECTE_ONE)
  view:setDelegate(self)
  local sourceCards = self:dataInstance():getCardsForSkillUp()
  view:setIsUsedFor(CardListType.SKILL_UP)
  view:init(sourceCards)
  self:getScene():replaceView(view,false,false)
end

function LevelUpController:goToItemView() -- 跳到行囊界面
  local bagController = ControllerFactory:Instance():create(ControllerType.BAG_CONTROLLER)
  bagController:enter()
end

function LevelUpController:setTabMenuVisible(isVisible)
  self.isTabVisible = isVisible
end 

function LevelUpController:getTabMenuVisible()
  -- return self.isTabVisible
  return false 
end 
