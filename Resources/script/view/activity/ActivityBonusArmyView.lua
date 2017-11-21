require("view.BaseView")
require("view.component.Loading")
require("view.component.PopupView")

ActivityBonusArmyView = class("ActivityBonusArmyView", BaseView)

function ActivityBonusArmyView:ctor()

  ActivityBonusArmyView.super.ctor(self)

  --1. load levelup view ccbi
  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("fetchCallback",ActivityBonusArmyView.fetchCallback)
  pkg:addProperty("sprite_zhubao","CCSprite")
  pkg:addProperty("label_preTime1","CCLabelTTF")
  pkg:addProperty("label_preTime2","CCLabelTTF")
  pkg:addProperty("label_firstTime","CCLabelTTF")
  pkg:addProperty("label_secondTime","CCLabelTTF")
  pkg:addProperty("menu_fetch","CCControlButton")
  
  local layer,owner = ccbHelper.load("ActivityBonusArmyView.ccbi","ActivityBonusArmyViewCCB","CCLayer",pkg)
  self:addChild(layer)

  self.label_preTime1:setString(string._tran(Consts.Strings.TIMES_1))
  self.label_preTime2:setString(string._tran(Consts.Strings.TIMES_2))
end

function ActivityBonusArmyView:init()
  echo("---ActivityBonusArmyView:init---")

  self.eatBeginTime1 = Activity:instance():getEatPattyTime(1) --12:00
  self.eatEndTime1 = Activity:instance():getEatPattyTime(2) --14:00
  self.eatBeginTime2 = Activity:instance():getEatPattyTime(3) --18:00
  self.eatEndTime2 = Activity:instance():getEatPattyTime(4) --20:00
  Activity:instance():setArmyDelegate(self)

  --regist msg handler
  net.registMsgCallback(PbMsgId.EatPattyResult, self, ActivityBonusArmyView.eatPattyResult)

  
  self:setInfoByFetchState(false)

  -- check can be fetch bonus
  local timeTable = Clock:Instance():getCurServerTimeAsTable()
  local curMin = timeTable.hour*60 + timeTable.min
  echo(" ------- current hour, min:", timeTable.hour, timeTable.min)
  echo(" ------- eat time1:", self.eatBeginTime1/60, self.eatEndTime1/60)
  echo(" ------- eat time2:", self.eatBeginTime2/60, self.eatEndTime2/60)
  if (curMin >= self.eatBeginTime1 and curMin <= self.eatEndTime1) or 
    (curMin >= self.eatBeginTime2 and curMin <= self.eatEndTime2) then 
    _showLoading()
    Activity:instance():askForCanEatPatty()
--    self.loading = Loading:show()
    self.askAndFetch = false 
  else 
    echo("==== invalid time to eat patty.")
    Activity:instance():setIsCanEatPatty(false)
  end

  --start to count down to enable/disable eat patty
  self:countDownEatPattyTime()


  --添加返回按钮
  local backImg = CCSprite:createWithSpriteFrameName("playstates-image-fanhui.png")
  local backImg1 = CCSprite:createWithSpriteFrameName("playstates-image-fanhui1.png")
  if backImg ~= nil then 
    local topHeight = self:getDelegate():getTopMenuSize().height 
    local menuSize = backImg:getContentSize()
    local menu = CCMenu:create()
    local menuItem = CCMenuItemSprite:create(backImg, backImg1, nil)
    menuItem:registerScriptTapHandler(handler(self, ActivityBonusArmyView.onBackHandler))
    menu:addChild(menuItem)
    menu:setPosition(ccp(display.cx + 320 - 50, display.height - topHeight - menuSize.height/2 - 20))
    self:addChild(menu)
  end 
end


function ActivityBonusArmyView:onEnter()
  echo("---ActivityBonusArmyView:onEnter---")
  self:init()
  CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self, handler(self,ActivityBonusArmyView.enterForeground),"APP_WILL_ENTER_FOREGROUND")
end

function ActivityBonusArmyView:onExit()
  echo("---ActivityBonusArmyView:onExit---")
  net.unregistAllCallback(self)
  
  Activity:instance():setArmyDelegate(nil)

  if self.scheduler ~= nil then 
    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduler)
    self.scheduler = nil
  end

  CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(self, "APP_WILL_ENTER_FOREGROUND")
end

function ActivityBonusArmyView:onBackHandler()
  self:getDelegate():goBackView()
end 

function ActivityBonusArmyView:fetchCallback()
  echo("fetchCallback")
  _playSnd(SFX_CLICK)

  local timeTable = Clock:Instance():getCurServerTimeAsTable()
  local curMin = timeTable.hour*60 + timeTable.min
  if (curMin >= self.eatBeginTime1 and curMin <= self.eatEndTime1) or 
    (curMin >= self.eatBeginTime2 and curMin <= self.eatEndTime2) then 
    _showLoading()
    local data = PbRegist.pack(PbMsgId.AskForCanEatPatty)
    net.sendMessage(PbMsgId.AskForCanEatPatty, data) 
    --self.loading = Loading:show()
    self.askAndFetch = true 
  else 
    Toast:showString(self, _tr("is not the time"), ccp(display.width/2, display.height*0.4))
  end
end

function ActivityBonusArmyView:eatPattyResult(action,msgId,msg)
  echo("eatPattyResult: ",msg.state)

--  if self.loading ~= nil then
--    self.loading:remove()
--    self.loading = nil
--  end
  _hideLoading()

  Activity:instance():setIsCanEatPatty(false)

  --update tip 
  self:getDelegate():getBaseView():updateTopTip(ActMenu.ARMY)
  self:getDelegate():getScene():getBottomBlock():updateBottomTip(3)

  if msg.state == "Ok" then
    self:setInfoByFetchState(false)

    --show bonus
    local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client_sync)
    for i=1,table.getn(gainItems) do
      echo("----gained:", gainItems[i].configId, gainItems[i].count)
      local str = string.format("+%d", gainItems[i].count)
      Toast:showIconNumWithDelay(str, gainItems[i].iconId, gainItems[i].iType, gainItems[i].configId, ccp(display.width/2,display.height*0.5-i*50), 0.5*(i-1))
    end
    
    --update 
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
  elseif msg.state == "NoRight" then
    Toast:showString(self, _tr("can not fetch award"), ccp(display.width/2, display.height*0.4))
  end
end


function ActivityBonusArmyView:countDownEatPattyTime()

  local function timerCallback(dt)
    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduler)
    self.scheduler = nil

    echo("timerCallback: state=", self.state)
    if self.state == 1 then
      self:setInfoByFetchState(true)
      Activity:instance():setIsCanEatPatty(true)
    elseif self.state == 2 then 
      self:setInfoByFetchState(false)
      Activity:instance():setIsCanEatPatty(false)
    end

    self.state, self.leftTime = Activity:instance():getStateAndLeftTimeForEatPatty(true)
    if self.state ~= 3 then 
      echo("== countDownEatPattyTime2: state, left sec =", self.state, self.leftTime)
      self.scheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(timerCallback, self.leftTime, false)
    end
  end

  --start to count down
  if self.scheduler ~= nil then 
    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduler)
    self.scheduler = nil
  end

  self.state, self.leftTime = Activity:instance():getStateAndLeftTimeForEatPatty(true)
  echo("==ActivityBonusArmyView:countDownEatPattyTime: state, left sec ="..self.state..self.leftTime)
  if self.state ~= 3 then 
    self.scheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(timerCallback, self.leftTime, false)
  end
end


function ActivityBonusArmyView:updateByMsgState(state)
  echo("updateByMsgState,askAndFetch= ", state, self.askAndFetch)

  if self.askAndFetch == false then -- just ask
--    if self.loading ~= nil then
--      self.loading:remove()
--      self.loading = nil
--    end
    _hideLoading()

    if state == "Ok" then
      self:setInfoByFetchState(true)
    end

  else --fetch bonus after ask

    if state == "Ok" then
      if self.askAndFetch == true then 
        --_showLoading()
        local data = PbRegist.pack(PbMsgId.EatPatty)
        net.sendMessage(PbMsgId.EatPatty, data)
        --self.loading = Loading:show()
      end
    elseif state == "TimeIsNotValid" then 
      Toast:showString(self, _tr("is not the time"), ccp(display.width/2, display.height*0.4))
    elseif state == "hasEatPattyCount" then 
      Toast:showString(self, _tr("has award all"), ccp(display.width/2, display.height*0.4))
    elseif state == "HasEatPatty" then 
      Toast:showString(self, _tr("has award"), ccp(display.width/2, display.height*0.4))
    else
      Toast:showString(self, _tr("system error"), ccp(display.width/2, display.height*0.4))
    end
  end
end

function ActivityBonusArmyView:enterForeground()
  echo("---enterForeground---")
  self:countDownEatPattyTime()
end

function ActivityBonusArmyView:setInfoByFetchState(canFetch)
  self.menu_fetch:setEnabled(canFetch)
  self.sprite_zhubao:setVisible(canFetch)

  --shining effect
  if self.shinning1 ~= nil then 
    self.shinning1:removeFromParentAndCleanup(true)
    self.shinning1 = nil 
  end 
  if self.shinning2 ~= nil then 
    self.shinning2:removeFromParentAndCleanup(true)
    self.shinning2 = nil 
  end 

  if canFetch then 
    self.shinning1 = _res(6010011)
    if self.shinning1 ~= nil then     
      self.shinning1:setPosition(ccp(display.cx-50, 360))
      self:addChild(self.shinning1)
    end

    self.shinning2 = _res(6010011)
    if self.shinning2 ~= nil then     
      self.shinning2:setPosition(ccp(display.cx+50, 360))
      self:addChild(self.shinning2)
    end
  end 
end 
