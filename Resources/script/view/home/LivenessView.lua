

require("view.BaseView")
require("view.home.LivenessDayView")
require("view.home.LivenessWeekView")

LivenessView = class("LivenessView", BaseView)

function LivenessView:ctor()
  LivenessView.super.ctor(self)
  -- GameData:Instance():pushViewType(ViewType.home, true)
end

function LivenessView:onEnter() 
  self:init()
end 

function LivenessView:onExit()
end 

function LivenessView:init()
  local view1 = LivenessDayView:createLivenessDayView()
  local view2 = LivenessWeekView:createLivenessWeekView()
  view1:setDelegate(self)
  view2:setDelegate(self)

  self.node = display.newNode()
  self.contentWidth = 640
  local offsetx = -(display.width - self.contentWidth)/2
  view1:setPositionX(offsetx)
  view2:setPositionX(offsetx+self.contentWidth)
  self.node:addChild(view1)
  self.node:addChild(view2)
  -- self:addChild(self.node)

  --tableview content rect
  self.tblViewRect = view2:getTblViewRect()

  self.viewRect = view1:getContentRect()
  self.posXMin = -self.contentWidth
  self.posXMax = 0

  self.inViewRect = false 
  self.touchInTableViewRect = false

  --bg mask layer
  local colorLayer = CCLayerColor:create(ccc4(0,0,0,100))
  self:addChild(colorLayer)

  --clipping layer
  local maskLayer = DSMask:createMask(CCSizeMake(self.contentWidth, display.height))
  maskLayer:addChild(self.node)
  maskLayer:setPosition(ccp((display.width-self.contentWidth)/2, 0))
  self:addChild(maskLayer)

  maskLayer:addTouchEventListener(handler(self,self.onTouch), false, -200, true)
  maskLayer:setTouchEnabled(true) 

  if view2:canFetchBonus(false) == true then 
    self:gotoView(2, false)
  end 
end 

function LivenessView:onTouch(event, x,y)
  if event == "began" then
    -- echo("===x, y", x, y)
    if x < self.viewRect.origin.x or (x > self.viewRect.origin.x+self.viewRect.size.width)
      or y < self.viewRect.origin.y or y > (self.viewRect.origin.y+self.viewRect.size.height) then 
      echo(" touch out of size.")
      self.inViewRect = false 
    else 
      self.inViewRect = true       
    end 

    self.isMoving = false 
    self.touchX = x 
    self.touchBeginX = x 

    self.touchInTableViewRect = false 
    local tmp_x = self.node:getPositionX()
    if tmp_x <= -self.contentWidth then --current view is week liveness
      if self.tblViewRect:containsPoint(ccp(x-tmp_x, y)) == true then 
        echo("==== touch in tableview rect")
        self.touchInTableViewRect = true 
      end 
    end 

    return true 

  elseif event == "moved" then
    if self.inViewRect == true and self.touchInTableViewRect == false then       
      self.isMoving = true 
      local posX = self.node:getPositionX() + x-self.touchX
      if posX >= self.posXMin and posX <= self.posXMax then 
        self.node:setPositionX(posX)
      end 
      self.touchX = x 
    end 
  elseif event == "ended" then
    if self.inViewRect == true then 
      if self.isMoving == true and self.touchInTableViewRect == false then 
        if math.abs(self.touchBeginX-x) > 30 then 
          if self.touchBeginX < x then --to page 1
            self:gotoView(1, true)
          else --to page 2
            self:gotoView(2, true)
          end 
        end 
      end 
    else 
      self:closeLivenessViews()
    end 
  end
end 

function LivenessView:gotoView(index, bAnim)
  local targetPosX = self.posXMax --page 1 by default
  if index == 2 then 
    targetPosX = self.posXMin
  end 

  if bAnim ~= nil and bAnim == true then 
    local action = CCMoveTo:create(0.4, ccp(targetPosX, 0))
    self.node:runAction(CCEaseOut:create(action, 2))
  else 
    self.node:setPositionX(targetPosX)
  end 
end 

function LivenessView:closeLivenessViews()
  self:removeFromParentAndCleanup(true)
  
  -- GameData:Instance():pushViewType(ViewType.home, false)
end 
