require("view.component.GameTopBlock")
require("view.component.GameBottomBar")
require("view.component.DropItemView")
require("view.notice.NoticeView")
require("model.Achievement.Achievement")
require("model.quest.Quest")
require("view.BaseScene")
require("view.BaseView")

SceneWithTopBottom = class("SceneWithTopBottom",BaseScene)

function SceneWithTopBottom:ctor()
  SceneWithTopBottom.super.ctor(self)  
  
  local background = display.newSprite("img/common/common_background.png")
  self:addChild(background,-1)
  background:setPosition(ccp(display.cx,display.cy))
  
  local topBlock = GameTopBlock.new()
  self._topBlock = topBlock
  self:addChild(self._topBlock,1000)
 
  
  local bottomBlock = GameBottomBar.new()
  self._bottomBlock = bottomBlock
  self:addChild(self._bottomBlock,1000)
  self:setIsDroping(false)
  
  self:addChild(display.newNode(),1999,POPUP_NODE_ZORDER)
        
  self._displayContainer = display.newNode()
  self:addChild(self._displayContainer,2000)
  
  self._loadingContainer = display.newNode()
  self._loadingContainer:setNodeEventEnabled(true)
  self:addChild(self._loadingContainer,2001)
  
  local noticeView = NoticeView.new()
  self:addChild(noticeView)
  noticeView:setPositionY(140)
  self._noticeView = noticeView
  
  CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self,handler(self,SceneWithTopBottom.reConnectingHandelr),EventType.RECONNETING)
  CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self,handler(self,SceneWithTopBottom.reConnectSuccessHandelr),EventType.RECONNECT_SUCCESS)
  CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self,handler(self,SceneWithTopBottom.reConnectFailedHandelr),EventType.RECONNECT_FAILED)
  CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self,handler(self,SceneWithTopBottom.forceOfflineHandler),EventType.FORCE_OFFLINE)
  CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self,handler(self,SceneWithTopBottom.clientVersionChangedHandler),EventType.CLIENT_VERSION_CHANGED)
  CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self,handler(self,SceneWithTopBottom.playerLevelUpHandler),EventType.PLAYER_LEVEL_UP)
  -- CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self,handler(self,SceneWithTopBottom.newPlayerGuide),EventType.NEW_PLAYER_GUIDE)
  CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self, handler(self,SceneWithTopBottom.guideLayerRemove),GuideConfig.GuideLayerRemoved)
  CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self,handler(self,SceneWithTopBottom.applicationWillEnterForeground),"APP_ENTER_FOREGROUND")
  
end

function SceneWithTopBottom:showLoading()
  self:hideLoading()
  local maskBg = Mask.new({opacity = 80,priority = -1024})
  self._loadingContainer:addChild(maskBg)
  local loadingIcon = display.newSprite("#common_loading_icon.png")
  self._loadingContainer:addChild(loadingIcon)
  loadingIcon:setPosition(ccp(display.cx,display.cy))
  local action = CCRotateBy:create(3.0, 360)
  loadingIcon:runAction(CCRepeatForever:create(action))
  self._loadingContainer:performWithDelay(function () 
    self:hideLoading()
    local pop = PopupView:createTextPopup(_tr("connect_timeout"), nil,true)
    self:addChildView(pop)
  end,15)
end

function SceneWithTopBottom:hideLoading()
  self._loadingContainer:removeAllChildrenWithCleanup(true)
  self._loadingContainer:stopAllActions()
end

function SceneWithTopBottom:applicationWillEnterForeground()
  SoundManager._update()
  CCNotificationCenter:sharedNotificationCenter():postNotification("APP_WILL_ENTER_FOREGROUND")
end

function SceneWithTopBottom:getDisplayContainer()
	return self._displayContainer
end

function SceneWithTopBottom:clientVersionChangedHandler()
  
  self._displayContainer:removeAllChildrenWithCleanup(true)
  
  local loginfun = function()
    Guide:Instance():setGuideLayerTouchEnabled(true)
    Guide:Instance():removeGuideLayer()
    if ControllerFactory:Instance():getCurrentControllerType() ~=  ControllerType.REGIST_CONTROLLER then
      local controller = ControllerFactory:Instance():create(ControllerType.REGIST_CONTROLLER)
      controller:enter()
      controller:sdkLogout()
      controller:logout()
    end
     
    if ChannelManager:getCurrentLoginChannel() == 'uc' then
      self:performWithDelay(function() return GameEntry:instance():gotoLoginWin() end, 2.0)
      return
    end
    
    if UserLogin.gameExit~=nil then
      UserLogin:gameExit()
    end
  end
  
  Guide:Instance():setGuideLayerTouchEnabled(false)
  Guide:Instance():setGuideStepIdWhenOffLine(nil)
  local str = _tr("has_new_client_version")
  if device.platform == "ios" then
    --str = "您需要重新进入游戏来更新客户端的最新版本，点击确定退出游戏后请重新进入游戏"
  end
  
  local pop = PopupView:createTextPopup(str,loginfun,true)
  pop:setTouchCloseEnable(false)
  self:addChild(pop,100000)
end

function SceneWithTopBottom:addChildView(...)
  self._displayContainer:addChild(...)
end

function SceneWithTopBottom:playerLevelUpHandler()
  if self._levelAnimContainer == nil then
     self._levelAnimContainer = display.newNode()
     self:addChild(self._levelAnimContainer)
  end
  
   local pkg = ccbRegisterPkg.new(self)
   pkg:addProperty("mAnimationManager","CCBAnimationManager")
   pkg:addProperty("effectNode","CCNode")
   pkg:addFunc("playCompleteHandler",SceneWithTopBottom.removeLevelAnimation)
   pkg:addFunc("playEffect",function() 
      
   end)
   
   local layer,owner = ccbHelper.load("LevelUp.ccbi","LevelUpAnimationCCB","CCLayer",pkg)
   self:addChild(layer,600)
   self._animationLevelup = layer
   
   local effectAnim = _res(6010003)
   effectAnim:setPosition(ccp(0,150))
   
   self._levelAnimContainer:addChild(effectAnim,-1)
   self._levelAnimContainer:setPosition(self.effectNode:getPosition())
end

function SceneWithTopBottom:removeLevelAnimation()
--  if self.effectNode ~= nil then
--     self.effectNode:removeAllChildrenWithCleanup(true)
--  end
--  
  if self._levelAnimContainer ~= nil then
    self._levelAnimContainer:removeAllChildrenWithCleanup(true)
  end
  
  if self._animationLevelup ~= nil then
     self._animationLevelup:removeFromParentAndCleanup(true)
  end
end

function SceneWithTopBottom:reConnectingHandelr()
  if Guide:Instance():getCurrentGuideInfo() ~= nil then
     Guide:Instance():setGuideStepIdWhenOffLine(Guide:Instance():getCurrentGuideInfo():getCurrentStep())
  end
  self:hideLoading()
  if self._loadingshow == nil then
     self._loadingshow = Loading:show( { timeOutRemove = false } )
  end
  echo("reConnectingHandelr")
end

function SceneWithTopBottom:reConnectSuccessHandelr()
  if  self._loadingshow ~= nil then
    self._loadingshow:remove()
    self._loadingshow = nil 
  end
  self:hideLoading()
  echo("reConnectSuccessHandelr")
  Arena:Instance():setIsSearching(false)
end

function SceneWithTopBottom:reConnectFailedHandelr()
  if  self._loadingshow ~= nil then
    self._loadingshow:remove()
    self._loadingshow = nil 
  end
  self:hideLoading()
  Guide:Instance():setGuideLayerTouchEnabled(false)
  local reconnectHandler = function()
    if self._loadingshow == nil then
       self._loadingshow = Loading:show( { timeOutRemove = false } )
    end
    Guide:Instance():setGuideLayerTouchEnabled(true)
    net.sendAction(NetAction.REQ_CONNECT_GAME_SERVER,0,nil)
  end
  
  local pop = PopupView:createTextPopup(_tr("network_error_pls_retry"), reconnectHandler,true)
  pop:setTouchCloseEnable(false)
  pop.enabledExecuteNewBird = false
  self:addChild(pop,99999)
  -- pop.btnClose3:setVisible(false)
  echo("reConnectFailedHandelr")
end

function SceneWithTopBottom:forceOfflineHandler()
  if  self._loadingshow ~= nil then
    self._loadingshow:remove()
    self._loadingshow = nil 
  end
  self:hideLoading()
  Guide:Instance():setGuideLayerTouchEnabled(false)

  if self:getChildByTag(POPUP_NODE_ZORDER) ~= nil then
    self:removeChildByTag(POPUP_NODE_ZORDER)
  end
  Achievement:instance():cleanData()

  net.isActiveDisconnect = true
  
  Guide:Instance():removeGuideLayer()
  
  if self:getLoginNoticeView() ~= nil then
     self:getLoginNoticeView():removeFromParentAndCleanup(true)
     self:setLoginNoticeView(nil)
  end
  self._displayContainer:removeAllChildrenWithCleanup(true)
  
  -- back to login view
  --Guide:Instance():setGuideLayerTouchEnabled(true)
  Guide:Instance():removeGuideLayer()
  GameData:Instance():getCurrentAccount():reset()
  Guide:Instance():setGuideStepIdWhenOffLine(nil)
  if ControllerFactory:Instance():getCurrentControllerType() ~=  ControllerType.REGIST_CONTROLLER then
    local controller = ControllerFactory:Instance():create(ControllerType.REGIST_CONTROLLER)
    controller:enter()
    controller:sdkLogout()
    controller:logout()
  else
    if ControllerFactory:Instance():getCurController().view ~= nil then
       ControllerFactory:Instance():getCurController().view:reset()
    end
  end
  
  local pop = PopupView:createTextPopup(_tr("account_force_offline"), function()
		Guide:Instance():setGuideLayerTouchEnabled(true)
		if UserLogin.gameExit ~= nil then
      UserLogin:gameExit()
    end
		--self:addChild(RichLabel:create("A","",22,CCSizeMake(10,999),true,false))
	end,true)
  -- pop.btnClose3:setVisible(false)
  pop:setTouchCloseEnable(false)
  self:addChild(pop,100000)
  Quest:Instance():setGlobalMainTaskAwardPopView(nil)
  
end

function SceneWithTopBottom:getTopBlock()
  return self._topBlock
end

function SceneWithTopBottom:replaceView(view,fullScreen,enabledTransition)
  
  if enabledTransition == nil or enabledTransition == true then
     enabledTransition = true 
     _playSnd(SFX_SWAP_SCREEN)
  end
  
  self._viewContainer:removeAllChildrenWithCleanup(true)
  self._view = view
  
  self._topBlock:updateTopBar()
  
  if fullScreen == nil then
    fullScreen = false
  end
  
  if fullScreen == true then
    self:setTopVisible(false)
    self:setBottomVisible(false)
  else
    self:setTopVisible(true)
    self:setBottomVisible(true)
  end
  
  enabledTransition = false
  
  if view ~= nil then
      self._viewContainer:addChild(view)
      printf("replaced view")
      self._bottomBlock:setBottomTouchEnabled(false)
      if enabledTransition == true and self:getIsDroping() == false then
        self:setIsDroping(true)
        self._viewContainer:setPositionY(display.size.height)
        transition.execute(self._viewContainer, CCMoveTo:create(0.15,ccp(0,0)),
        {
             --easing = "backout",
             onComplete = function()
                self:onAfterReplacedView()
             end,
        })
      end

      if enabledTransition == false then
         self:onAfterReplacedView()
      end
  end
end

function SceneWithTopBottom:onAfterReplacedView()
  if ControllerFactory:Instance():getCurrentControllerType() ~= ControllerType.HOME_CONTROLLER 
  and ControllerFactory:Instance():getCurrentControllerType() ~= ControllerType.REGIST_CONTROLLER
  then
     Quest:Instance():alertMainTaskAwardPop()
  end
  
  CCNotificationCenter:sharedNotificationCenter():postNotification(GuideConfig.GuideTrigger)
  self:setIsDroping(false)
  self._bottomBlock:setBottomTouchEnabled(true)
  printf("after replaced view")
end




------
--  Getter & Setter for
--      SceneWithTopBottom._IsDroping 
-----
function SceneWithTopBottom:setIsDroping(IsDroping)
	self._IsDroping = IsDroping
end

function SceneWithTopBottom:getIsDroping()
	return self._IsDroping
end

function SceneWithTopBottom:setPlayerInfoVisible(isVisible)
  if isVisible == true then 
    self:setVisible(isVisible)
  end
  self._topBlock:setPlayerInfoVisible(isVisible)
end

function SceneWithTopBottom:getPlayerInfoVisible()
  return self._topBlock:getPlayerInfoVisible()
end

function SceneWithTopBottom:setTopVisible(isVisible)
  self._topBlock:setPlayerInfoVisible(isVisible)
	self._topBlock:setVisible(isVisible)
end

function SceneWithTopBottom:getTopVisible()
	return self._topBlock:isVisible()
end

function SceneWithTopBottom:setBottomVisible(isVisible)
  self._bottomBlock:setVisible(isVisible)
  if isVisible == true then
    self._bottomBlock:setPositionY(0)
  else
    self._bottomBlock:setPositionY(-1000)
  end
end

function SceneWithTopBottom:getBottomVisible()
  return self._bottomBlock:isVisible()
end

function SceneWithTopBottom:getTopContentSize()
	return self._topBlock:getSize()
end

function SceneWithTopBottom:getBottomContentSize()
	return self._bottomBlock:getSize()
end

function SceneWithTopBottom:getMiddleContentSize()
  return CCSizeMake(display.size.width,display.size.height - (self:getBottomContentSize().height+self:getTopContentSize().height))
end

function SceneWithTopBottom:getBottomBlock()
	return self._bottomBlock
end

------
--  Getter & Setter for
--      SceneWithTopBottom._LoginNoticeView 
-----
function SceneWithTopBottom:setLoginNoticeView(LoginNoticeView)
	self._LoginNoticeView = LoginNoticeView
end

function SceneWithTopBottom:getLoginNoticeView()
	return self._LoginNoticeView
end

function SceneWithTopBottom:getNoticeView()
  return self._noticeView
end

function SceneWithTopBottom:guideLayerRemove()
  _executeNewBird()
end 

return SceneWithTopBottom