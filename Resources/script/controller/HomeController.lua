require("controller.BaseController")
require("controller.LevelUpController")
require("controller.BagController")
require("controller.CardBagController")
require("controller.FriendController")
require("controller.AchievementController")
require("controller.MailController")
require("view.home.HomeView")
require("view.notice.login_notice.LoginNoticeView")

HomeController = class("HomeController",BaseController)

function HomeController:ctor()
  HomeController.super.ctor(self)
end

function HomeController:enter(showNotice)
  echo("---HomeController:enter---")
  HomeController.super.enter(self)
  --self._showNotice = showNotice or false
  self:setScene(GameData:Instance():getCurrentScene())
  self:displayHomeView()
  self:getScene():getNoticeView():setEnabledLocalNotice(true)
  
end

function HomeController:exit()
  echo("---HomeController:exit---")
  HomeController.super.exit(self)
  self:getScene():setTopVisible(true)
  self:getScene():getNoticeView():setEnabledLocalNotice(false)
end 

------
--  Getter & Setter for
--      HomeController._ShowNotice 
-----
function HomeController:setShowNotice(ShowNotice)
	self._showNotice = ShowNotice
end

function HomeController:getShowNotice()
	return self._showNotice
end

function HomeController:displayHomeView()
  self.homeView = HomeView.new()
  self.homeView:setDelegate(self)
  self:getScene():replaceView(self.homeView,false,true)
  self:getScene():setTopVisible(false)
  
  --[[if self._showNotice == true then
     self._showNotice = false
     local noticeView = LoginNoticeView.new()
     noticeView:setDelegate(self.homeView)
     self:getScene():addChild(noticeView,1000)
  end]]
end


function HomeController:ScrollerItemCallback(idx)
  if idx == 0  then 
    self:displayCardBagView()
  elseif idx == 1 then 
    self:displayLevelUpView()
  elseif idx == 2 then 
    self:displayBagView()
  elseif idx == 3 then
    self:dispFriendView()
  elseif idx == 4 then 
    local controller = ControllerFactory:Instance():create(ControllerType.QUEST_CONTROLLER)
    controller:enter()
  elseif idx == 5 then
    self:dispMailView()
  elseif idx == 6 then
    self:dispAchievements()
  end 
end 

function HomeController:displayLevelUpView()
  -- echo("displayLevelUpView")
  -- if GameData:Instance():checkSystemOpenCondition(6, true) == false then 
  --   return 
  -- end 

  -- local controller = ControllerFactory:Instance():create(ControllerType.LEVELUP_CONTROLLER)
  -- controller:enter(1,nil)
end

function HomeController:displayBagView()
  echo("displayBagView")
  local bagController = ControllerFactory:Instance():create(ControllerType.BAG_CONTROLLER)
  bagController:enter()
end

function HomeController:dispFriendView()
  if GameData:Instance():checkSystemOpenCondition(11, true) == false then 
    return 
  end 
  
  local controller =  ControllerFactory:Instance():create(ControllerType.FRIEND_CONTROLLER)
  controller:enter(ViewType.home)
end

function HomeController:enterPlaystates(idx)
  local playstatesController  = ControllerFactory:Instance():create(ControllerType.PLAY_STATES_CONTROLLER)
  playstatesController:enter(idx)
end

function HomeController:displayCardBagView()
  local cardBagController =  ControllerFactory:Instance():create(ControllerType.CARDBAG_CONTROLLER)
  cardBagController:enter()
end

function HomeController:dispMailView()
  local mailController = ControllerFactory:Instance():create(ControllerType.MAIL_CONTROLLER)
  mailController:enter(1)
end

function HomeController:dispAchievements()
  if GameData:Instance():checkSystemOpenCondition(39, true) == false then 
    return 
  end 

  local controller = ControllerFactory:Instance():create(ControllerType.ACHIEVEMENT_CONTROLLER)
  controller:enter()
end

function HomeController:dispTaskView()
  local controller = ControllerFactory:Instance():create(ControllerType.QUEST_CONTROLLER)
  if controller ~= nil then
    controller:enter()
  end
end 

function HomeController:getMenuSprite(idx)
  return self.homeView:getMenuSprite(idx)
end 

function HomeController:getHomeView()
  return self.homeView
end 

function HomeController:setLivenessShowFlag(showWhenEntry)
  self.livenessShowFlag = showWhenEntry
end 

function HomeController:getLivenessShowFlag()
  return self.livenessShowFlag
end 

function HomeController:setActMissionShowFlag(showWhenEntry)
  self.actMissionShowFlag = showWhenEntry
end 

function HomeController:getActMissionShowFlag()
  return self.actMissionShowFlag
end 