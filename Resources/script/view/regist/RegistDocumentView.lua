RegistDocumentView = class("RegistDocumentView",BaseView)
function RegistDocumentView:ctor(loginView,type)
  self:setNodeEventEnabled(true)
  self:setTouchEnabled(true)
  
  self._loginView = loginView
  self._type = type
  
  local frame = display.newSpriteFrame("regist_txt_bg.png")
  local bg =  CCScale9Sprite:createWithSpriteFrame(frame)
  bg:setAnchorPoint(ccp(0,0))
  self:addChild(bg)
  self._bg = bg
  
  self:addTouchEventListener(
    function(event, x, y)
      return true
    end,false, -300, true)
end

function RegistDocumentView:onEnter()
  --color layer
  local layerColor = CCLayerColor:create(ccc4(0,0,0,125), display.width, display.height)
  self:addChild(layerColor)
  
  assert(AllConfig.login ~= nil,"AllConfig.login can not be nil")
  
  local contentText = display.newNode()
  contentText:setAnchorPoint(ccp(0,0))
  local t_height = 0
  local begin = 1
  local totalLength = #AllConfig.login
  if GameData:Instance():getLanguageType() == LanguageType.JPN then
    if self._type == 8 then
      totalLength = 63
    elseif self._type == 9 then
      begin = 64
    end
  end
  
  
  --for i = 1, #AllConfig.login do
  for i = totalLength,begin,-1 do 
      if AllConfig.login[i] ~= nil then
    	  local str = AllConfig.login[i].text
        local label = CCLabelTTF:create(str,"Courier-Bold",20,CCSizeMake(550,0),kCCTextAlignmentLeft)
        label:setAnchorPoint(ccp(0,0))
        contentText:addChild(label)
        label:setPositionY(t_height)
        t_height = t_height + label:getContentSize().height+3
      end
  end
  contentText:setContentSize(CCSizeMake(550,t_height))
  local viewSize = CCSizeMake(550,720)
  local scrollView =  CCScrollView:create()
  self:addChild(scrollView)
  scrollView:setViewSize(viewSize)
  scrollView:setContentSize(contentText:getContentSize())
  scrollView:setDirection(kCCScrollViewDirectionVertical)
  scrollView:setClippingToBounds(true)
  scrollView:setBounceable(true)
  scrollView:setDelegate(self)
  scrollView:setContainer(contentText)
  scrollView:setPosition(ccp(display.cx - viewSize.width/2,display.cy - viewSize.height/2))
  
  scrollView:setTouchPriority(-300)
  self._scrollView = scrollView
  
  local tSize = CCSizeMake(590,760)
  self._bg:setContentSize(tSize)
  self._bg:setPosition(ccp(display.cx - tSize.width/2,display.cy - tSize.height/2))
  
  -- scroll to top
  contentText:setPosition(ccp(0, viewSize.height - contentText:getContentSize().height))
  
  --close btn 
  local nor = display.newSprite("#regist_btn_guanbi_nor.png")
  local sel = display.newSprite("#regist_btn_guanbi_sel.png")
  local dis = display.newSprite("#regist_btn_guanbi_sel.png")
  local closeBtn = UIHelper.ccMenuWithSprite(nor,sel,dis,function()
     if self._loginView ~= nil then
      self._loginView:setDocumentIsOpen(false)
     end
     self:removeFromParentAndCleanup(true)
  end)
  closeBtn:setTouchPriority(-300)
  self:addChild(closeBtn)
  closeBtn:setPosition(ccp(display.cx,display.cy - tSize.height/2  - 50))
end

function RegistDocumentView:onTouch(event, x,y)
--  if event == "began" then
--    self._startY = y
--    return true
--  elseif event == "moved" then
--  elseif event == "ended" then
--    if math.abs(self._startY - y) < 10 then
--       self:removeFromParentAndCleanup(true)
--    end
--  end
end

return RegistDocumentView