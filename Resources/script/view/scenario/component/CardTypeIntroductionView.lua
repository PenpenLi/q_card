CardTypeIntroductionView = class("CardTypeIntroductionView",BaseView)
function CardTypeIntroductionView:ctor(delegate,stage)
  self._touchEnabled = false
  self._stage = stage
  self:setDelegate(delegate)
  self:setNodeEventEnabled(true)
   --color layer
  local layerColor = CCLayerColor:create(ccc4(0,0,0,125), display.width, display.height)
  self:addChild(layerColor)
  local pic = display.newSprite(AllConfig.newcard[self._stage:getStageId()].path)
  self:addChild(pic)
  pic:setPosition(ccp(display.cx,display.cy))
  local touchTip = display.newSprite("#touch_screen_tip.png")
  self:addChild(touchTip)
  touchTip:setPosition(ccp(display.cx,display.cy - pic:getContentSize().height/2 - 20 ))
  local animation = CCSequence:createWithTwoActions(CCScaleTo:create(0.8, 0.9), CCScaleTo:create(0.8, 1.0))
  touchTip:runAction(CCRepeatForever:create(animation))
  self:setTouchEnabled(true)
  self:addTouchEventListener(handler(self,self.onTouch),false, -128, true)
  
end

------
--  Getter & Setter for
--      CardTypeIntroductionView._BattleController 
-----
function CardTypeIntroductionView:setBattleController(BattleController)
	self._BattleController = BattleController
end

function CardTypeIntroductionView:getBattleController()
	return self._BattleController
end

function CardTypeIntroductionView:onTouch(event,x,y)
   if self._touchEnabled == false then
      return
   end
   
   if event == "began" then
      return true
   elseif event == "moved" then
      
   elseif event == "ended" then
      self._touchEnabled = false
      transition.execute(self,CCEaseElasticIn:create(CCScaleTo:create(0.5,0.1),0.6),
      {
         onComplete = function()
            --self:getParent():removeChild(self,true)
            self:removeFromParentAndCleanup(true)
         end,
      })

   end
end

function CardTypeIntroductionView:onEnter()
  self._touchEnabled = true
  self:setScale(0.2)
  self:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6) )
end

function CardTypeIntroductionView:onExit()
    self:getDelegate():triggerStageTroopIntroduction(self:getBattleController())       
--    if  self:getBattleController() ~= nil then
--       if self:getBattleController():getBattleView() ~= nil then
--          self:getBattleController():getBattleView():battleGuideTrggier()
--       end
--    end
end

return CardTypeIntroductionView