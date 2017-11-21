BattleDialogueView = class("BattleDialogueView",BaseView)
function BattleDialogueView:ctor(dialogue)
  self:setNodeEventEnabled(true)
  self._dialogue = dialogue
  self._touchEnabled = false
  self:setTouchEnabled(true)
  self:addTouchEventListener(handler(self,self.onTouch),false, -128, true)


end

function BattleDialogueView:onEnter()
  
  --color layer
  local layerColor = CCLayerColor:create(ccc4(0,0,0,125), display.width, display.height)
  self:addChild(layerColor)
  
  local dialogueNode = display.newNode()
  self:addChild(dialogueNode)

  --preload plist
  local plistId = AllConfig.frames[3059040].plist
  local plistName = AllConfig.plist[plistId].path
  CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(plistName)

  --str
  local label_name = CCLabelTTF:create(self._dialogue.name..":","Courier-Bold",28,CCSizeMake(385,0),kCCTextAlignmentLeft)
  local label_desc = CCLabelTTF:create(self._dialogue.desc or "","Courier-Bold",26,CCSizeMake(385,0),kCCTextAlignmentLeft)
  local nameSize = label_name:getContentSize() 
  local descSize = label_desc:getContentSize() 
  local strNode = display.newNode()
  label_desc:setPosition(ccp(descSize.width/2, descSize.height/2))
  label_name:setPosition(ccp(nameSize.width/2, descSize.height+nameSize.height/2+6))
  strNode:addChild(label_name) 
  strNode:addChild(label_desc)
  strNode:setContentSize(CCSizeMake(descSize.width, descSize.height+nameSize.height+6))
  dialogueNode:addChild(strNode, 3)

  --bg img 
  local img_bg = CCScale9Sprite:createWithSpriteFrameName(AllConfig.frames[3059040].playstates)
  local img_fg = CCScale9Sprite:createWithSpriteFrameName(AllConfig.frames[3059041].playstates)
  dialogueNode:addChild(img_bg, 0)
  dialogueNode:addChild(img_fg, 2)
  if img_fg:getContentSize().height < strNode:getContentSize().height then 
    img_fg:setContentSize(CCSizeMake(img_fg:getContentSize().width, strNode:getContentSize().height+10))
  end
  if img_fg:getContentSize().height+10 >= img_bg:getContentSize().height then 
    img_bg:setContentSize(CCSizeMake(img_bg:getContentSize().width, img_fg:getContentSize().height+20))
  end 
  
  local portrait = _res(self._dialogue.portrait_pic)
  assert(portrait ~= nil,"portrait res error")
  dialogueNode:addChild(portrait, 1)
  local scale = 0.8
  local toward = 1
  if self._dialogue.toward > 0 then
     toward = -1
  end
  portrait:setScaleX(scale*toward)
  portrait:setScaleY(scale)

  --rejust position
  local dialogueNodeY = 0
  if self._dialogue.direction == 1 then
     portrait:setPosition(ccp(-190,190))
     dialogueNodeY = 150
     img_fg:setPositionX(60)
     img_fg:setScaleX(-1)
     strNode:setPosition(ccp(85-strNode:getContentSize().width/2, -strNode:getContentSize().height/2))
     dialogueNode:setPositionX(-640)
  elseif  self._dialogue.direction == 2  then
     portrait:setPosition(ccp(190,190))
     dialogueNodeY = display.cy
     img_fg:setPositionX(-60)
     strNode:setPosition(ccp(-75-strNode:getContentSize().width/2, -strNode:getContentSize().height/2))
     dialogueNode:setPositionX(display.width + 640)
  end
  
  dialogueNode:setPositionY(dialogueNodeY)

  --action
  local move = CCMoveTo:create(0.25,ccp(display.cx,dialogueNodeY))
  dialogueNode:runAction(CCEaseOut:create(move,0.25))
  
  self._touchEnabled = true
end

function BattleDialogueView:onTouch(event,x,y)
   if self._touchEnabled == false then
      return
   end
   if event == "began" then
      return true
   elseif event == "moved" then
   elseif event == "ended" then
      self:removeFromParentAndCleanup(true)
   end
end

function BattleDialogueView:onExit()
  self:resume()
end

function BattleDialogueView:pause()
  self._cur = coroutine.running()
  coroutine.yield()
end

function BattleDialogueView:resume()
  local success,error = coroutine.resume(self._cur)
  if not success then
    printf("coroutine error:"..error)
    print(debug.traceback(cur, error)) 
  end
  self._cur = nil
end

return BattleDialogueView