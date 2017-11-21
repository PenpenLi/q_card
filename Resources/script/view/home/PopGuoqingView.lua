
require("view.BaseView")



PopGuoqingView = class("PopGuoqingView", BaseView)

function PopGuoqingView:ctor()
  CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("img/activity/pop_zhongqiu.plist")
end

function PopGuoqingView:init(isAutoClose)

  local function closeCallback()
    self:removeFromParentAndCleanup(true)
  end 

  local colorLayer = CCLayerColor:create(ccc4(0, 0, 0, 200))
  self:addChild(colorLayer)


  self.bgImg = nil
  local downLoadChannel = ChannelManager:getCurrentDownloadChannel()
  if downLoadChannel ~= nil then 
    echo("=== charge platform =", downLoadChannel)
    if downLoadChannel == "appstore" or downLoadChannel == "googlePlay" then 
      self.bgImg = CCSprite:create("img/activity/act_guoqing_bg0.png")
    else 
      self.bgImg = CCSprite:create("img/activity/act_guoqing_bg1.png")
    end 
  end 
  
  if self.bgImg == nil then 
    return false 
  end

  local priority = -600
  self.bgImg:setPosition(display.cx, display.cy)
  self:addChild(self.bgImg)

  local menu = CCMenu:create()
  menu:setTouchPriority(priority-1)
  menu:setAnchorPoint(ccp(0.5,0.5))
  local menuItem = CCMenuItemImage:create()
  local norFrame =  display.newSpriteFrame("pop_zhongqiu_close0.png")
  local selFrame =  display.newSpriteFrame("pop_zhongqiu_close1.png")
  menuItem:setNormalSpriteFrame(norFrame)
  menuItem:setSelectedSpriteFrame(selFrame)
  menuItem:registerScriptTapHandler(closeCallback)
  menu:addChild(menuItem)

  local size = self.bgImg:getContentSize()
  menu:setPosition(ccp(size.width-40, size.height-20))
  self.bgImg:addChild(menu, 1)

  if isAutoClose == true then 
    --touch region check
    self:addTouchEventListener(function(event, x, y)
                                  if event == "began" then
                                    self.preTouchFlag = self:checkTouchOutsideView(x, y)
                                    return true
                                  elseif event == "ended" then
                                    local curFlag = self:checkTouchOutsideView(x, y)
                                    if self.preTouchFlag == true and curFlag == true then
                                      echo(" touch out of region: close popup") 
                                      closeCallback()
                                    end 
                                  end
                              end,
                false, priority, true)
    self:setTouchEnabled(true)
  end 

  return true 
end 

function PopGuoqingView:create(isAutoClose)
  local pop = PopGuoqingView.new()
  local result = pop:init(isAutoClose)
  if result then 
    -- pop.node_content:setScale(0.2)
    -- pop.node_content:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6))
    return pop 
  end 

  return nil 
end 

function PopGuoqingView:onEnter()

end 

function PopGuoqingView:onExit()

end 

function PopGuoqingView:checkTouchOutsideView(x, y)
  --outside check 
  local size2 = self.bgImg:getContentSize()
  local pos2 = self.bgImg:convertToNodeSpace(ccp(x, y))
  if pos2.x < 0 or pos2.x > size2.width or pos2.y < 0 or pos2.y > size2.height then 
    return true 
  end

  return false  
end 
