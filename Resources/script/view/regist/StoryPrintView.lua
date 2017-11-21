StoryPrintView = class("StoryPrintView",BaseView)
function StoryPrintView:ctor(str,isEnterBattle)
  self:setNodeEventEnabled(true)
  self:setTouchEnabled(true)
  self:addTouchEventListener(handler(self,self.onTouch),false, -128, true)
  self._str = str
  self._isEnterBattle = isEnterBattle
  self._printFinished = false
  
end

function StoryPrintView:onEnter()
    
    if self._showTextNode == nil then
       self._showTextNode = display.newNode()
       self:addChild(self._showTextNode,300)
    else
       self._showTextNode:removeAllChildrenWithCleanup(true)
    end
    
    local str = self._str
    
     --color layer
--    local layerColor = CCLayerColor:create(ccc4(0,0,0,255), display.width, display.height)
--    self._showTextNode:addChild(layerColor)
    
    local bg = display.newSprite("regist/story_print_bg.png")
    self._showTextNode:addChild(bg)
    bg:setPosition(display.cx,display.cy)

    local str_show = ""
    local strIdx = 1
    local tab = {}
    local _, count = string.gsub(str, "[^\128-\193]", "")
    for uchar in string.gfind(str, "[%z\1-\127\194-\244][\128-\191]*") do 
      tab[#tab+1] = uchar 
    end

    --local label = CCLabelTTF:create("","Courier-Bold",26,CCSizeMake(520,0),kCCTextAlignmentLeft)
    local label = CCLabelBMFont:create("", "client/widget/words/card_name/battle_story.fnt")
    label:setAlignment(kCCTextAlignmentLeft)
    label:setString("")
    label:setWidth(520)
    label:setLineBreakWithoutSpace(true)
    label:setAnchorPoint(ccp(0, 1))
    --self.label:setColor(cc.color.RED)  
    self._showTextNode:addChild(label,300)
    label:setPosition(ccp(display.cx - 520*0.5,display.cy + 100))
    self._label = label

    local function updateText()
      if strIdx > #tab then 
         self:stopAllActions()
         print("print text finished")
         self._printFinished = true
         self:performWithDelay(function() self:onTouch("ended",display.cx,display.cy)  end,2)
         --self:setTouchEnabled(true)
         return
      end
      --print("setString:",tab[strIdx])
      str_show = str_show..tab[strIdx]
      label:setString(str_show)
      
      strIdx = strIdx + 1
    end
    self:schedule(updateText, 0.05)   
end


function StoryPrintView:onTouch(event,x,y)
   
   if self._printFinished == false then
      self:stopAllActions()
      self._printFinished = true 
      self._label:setString(self._str)
      return
   end

   if event == "began" then
      return true
   elseif event == "moved" then
   elseif event == "ended" then
      self:setTouchEnabled(false)
      self:stopAllActions()
      
      if self._isEnterBattle == true then
         local battleController = ControllerFactory:Instance():create(ControllerType.BATTLE_CONTROLLER)
         battleController:enter(false,false,true)
      else
         local createPlayerNameController = ControllerFactory:Instance():create(ControllerType.CREATE_PLAYER_NAME_CONTROLLER)
         createPlayerNameController:enter()
      end
   end
end

function StoryPrintView:onExit()
  self._isEnterBattle = nil
end

return StoryPrintView