ScenarioDialogView = class("ScenarioDialogView",BaseView)
function ScenarioDialogView:ctor(text,picId,dialogueType)
  self._text = text
  self._picId = picId
  self:setNodeEventEnabled(true)
  
  local opacity = 255
--  if dialogueType == StageConfig.DialogueTypeStage then
--    opacity = 255
--  end
  
   --color layer
  local layerScale = 2
  local layerColor = CCLayerColor:create(ccc4(0,0,0,opacity), display.width*layerScale, display.height*layerScale)
  self:addChild(layerColor)
  layerColor:setPosition(-(display.width*layerScale - display.width)/2,-(display.height*layerScale - display.height)/2)
  
  self._nodeRoot = display.newNode()
  self:setCascadeOpacityEnabled(true)
  self:addChild(self._nodeRoot)
  self._dialogueType = dialogueType
  
  if self._dialogueType == StageConfig.DialogueTypeChapter then
    local pkg = ccbRegisterPkg.new(self)
    pkg:addProperty("labelDialog","CCLabelTTF")
    pkg:addProperty("labelChapterDesc","CCLabelTTF")
    pkg:addProperty("containerPicture","CCNode")
    pkg:addProperty("containerChapterPic","CCNode")
    pkg:addProperty("nodeChapter","CCNode")
    pkg:addProperty("nodeRoot","CCNode")
    local layer,owner = ccbHelper.load("ScenarioDialog.ccbi","ScenarioDialogCCB","CCLayer",pkg)
    self:addChild(layer)
    
    self.containerChapterPic:setScale(1.25)
    self.labelDialog:setDimensions(CCSizeMake(500, 0))
    self.labelDialog:setString("")
    self.labelChapterDesc:setDimensions(CCSizeMake(500, 0))
    self.labelChapterDesc:setString("")
    
     --self.nodeRoot:setCascadeOpacityEnabled(true)
    self.nodeRoot:removeFromParentAndCleanup(false)
    self._nodeRoot:addChild(self.nodeRoot)
  end
  
  self._touchEnabled = false
  self:setTouchEnabled(true)
  self:addTouchEventListener(handler(self,self.onTouch),false, -128, true)
  
end

function ScenarioDialogView:onEnter()
  if self._dialogueType == StageConfig.DialogueTypeChapter then
     if self._text ~= nil then
       self.labelChapterDesc:setString(self._text)
     end
     self._nodeRoot:setVisible(false)
     self.nodeChapter:setVisible(true)
     local pic = _res(self._picId)
     if pic ~= nil then
        pic:setCascadeOpacityEnabled(true)
        pic:setAnchorPoint(ccp(0.5,0.5))
        pic:setPositionY(90)
        self.containerChapterPic:addChild(pic)
     end
    -- self:runAction(CCFadeIn:create(2.0))
     self:setScale(0.2)
     self:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6) )
  elseif self._dialogueType == StageConfig.DialogueTypeStage then
--    self._ccbLayer:setVisible(false)
--    if self._text ~= nil then
--       self.labelDialog:setString(self._text)
--    end
--    self._nodeRoot:setVisible(true)
--    self.nodeChapter:setVisible(false)

    local pic = _res(self._picId)
    if pic ~= nil then
        pic:setCascadeOpacityEnabled(true)
        --pic:setAnchorPoint(ccp(0.5,0))
        --pic:setPositionY(-110)
        --self.containerPicture:addChild(pic)
        self:addChild(pic)
        pic:setPosition(display.cx,display.cy)
        --pic:setScale(0.8)
    end
    
    local shadowWidth = display.width
    local shadowHeight = 208
    
    local showTxt = function()
      if self._text ~= nil then
        local label = CCLabelTTF:create("","Courier-Bold",26,CCSizeMake(520,0),kCCTextAlignmentLeft)
        label:setAnchorPoint(ccp(0, 1)) 
        self:addChild(label)
        label:setPosition(ccp(display.cx - 520*0.5,90))
        label:setString(self._text)
      end
    end
    
    local shadowSize = CCSizeMake(shadowWidth,shadowHeight)
    local topShadow = display.newScale9Sprite("#scenario_worldview_bg.png",display.cx, display.height + shadowHeight/2 , shadowSize)
    self:addChild(topShadow)
    topShadow:setScaleY(-1)
    topShadow:runAction(CCMoveTo:create(0.3,(ccp(display.cx, display.height - shadowHeight/2 ))))
    
    local bottomShadow = display.newScale9Sprite("#scenario_worldview_bg.png",display.cx,-shadowHeight/2 , shadowSize)
    self:addChild(bottomShadow)
    
    local array = CCArray:create()
    array:addObject(CCMoveTo:create(0.3,(ccp(display.cx,shadowHeight/2 ))))
    array:addObject(CCCallFunc:create(showTxt))
    bottomShadow:runAction(CCSequence:create(array))
    
  end
  
  
  self._touchEnabled = true
end

function ScenarioDialogView:onExit()
  if self._dialogueType == StageConfig.DialogueTypeChapter then
     --self:getDelegate():triggerGuides()
     _executeNewBird()
  elseif self._dialogueType == StageConfig.DialogueTypeStage then
     --self:getDelegate():triggerStageTroopIntroduction(self:getBattleController())
     self:getBattleController():getBattleView():showButtons()
     self:getDelegate():checkNewCard(self:getBattleController())
  end
  
end

------
--  Getter & Setter for
--      ScenarioDialogView._BattleController 
-----
function ScenarioDialogView:setBattleController(BattleController)
	self._BattleController = BattleController
end

function ScenarioDialogView:getBattleController()
	return self._BattleController
end

function ScenarioDialogView:onTouch(event,x,y)

   if self._touchEnabled == false then
      return
   end
   
   if event == "began" then
      return true
   elseif event == "moved" then
      
   elseif event == "ended" then
       if self._dialogueType == StageConfig.DialogueTypeStage then
          self._touchEnabled = false
          transition.execute(self,CCEaseElasticIn:create(CCScaleTo:create(0.5,0.1),0.6),
          {
               onComplete = function()
                  self:removeFromParentAndCleanup(true)
               end,
          })
          
       else
          self:removeFromParentAndCleanup(true)
       end
       
   end
end


return ScenarioDialogView