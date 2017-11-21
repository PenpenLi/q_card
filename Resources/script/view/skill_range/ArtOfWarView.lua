require("view.skill_range.ArtOfWarListItem")
ArtOfWarView = class("ArtOfWarView",BaseView)
function ArtOfWarView:ctor()
  self:setTouchEnabled(true)
  self:addTouchEventListener(handler(self,self.onTouch),false, -128, true)
  
  self:setNodeEventEnabled(true)
  self._currentPage = 0
  self._isDragging = false
  
end

function ArtOfWarView:onEnter()
  --color layer
  local layerColor = CCLayerColor:create(ccc4(0,0,0,125), display.width, display.height)
  self:addChild(layerColor)

  self._nodeContainer = display.newNode()
  self:addChild(self._nodeContainer)
  
  --create 4 pages
  local listPage1 = display.newSprite("img/skill_range/art_of_war_cardtype.png")
  self._nodeContainer:addChild(listPage1)
  listPage1:setPosition(ccp(display.cx,display.cy))
  
  local listPage2 = display.newSprite("img/skill_range/art_of_war_first.png")
  self._nodeContainer:addChild(listPage2)
  listPage2:setPosition(ccp(display.width + display.cx,display.cy))
   
  local listPage3 = self:createListByType(0)
  self._nodeContainer:addChild(listPage3)
  listPage3:setPosition(ccp(display.width*2,0))
 
     
  local listPage4 = self:createListByType(1)
  self._nodeContainer:addChild(listPage4)
  listPage4:setPosition(ccp(display.width*3,0))
 
  
  --create tip
  local touchTip = display.newSprite("#touch_screen_tip.png")
  self:addChild(touchTip)
  touchTip:setPosition(ccp(display.cx,display.cy - 845/2 - 20 ))
  local animation = CCSequence:createWithTwoActions(CCScaleTo:create(0.8, 0.9), CCScaleTo:create(0.8, 1.0))
  touchTip:runAction(CCRepeatForever:create(animation))
  
  --create points
  local gradeContainer = CCMenu:create()
  self:addChild(gradeContainer)
  gradeContainer:setPosition(ccp(display.cx - 35*4/2,display.cy - 845/2 + 30 ))
  self._gradeArr = {}
  for i = 1, 4 do
    local gradeSelectItem = CCMenuItemImage:create()
    local nor_frame =  display.newSpriteFrame("atr_of_wall/art_of_war_page_item_sel.png")
    local disabled_frame = display.newSpriteFrame("atr_of_wall/art_of_war_page_item_nor.png")
    gradeSelectItem:setNormalSpriteFrame(nor_frame)
    gradeSelectItem:setSelectedSpriteFrame(disabled_frame)
    gradeSelectItem:setDisabledSpriteFrame(disabled_frame)
    gradeContainer:addChild(gradeSelectItem)
    gradeSelectItem:registerScriptTapHandler(handler(self,self.onClickGradeSwitch))
    gradeSelectItem:setPositionX(35*(i-1))
    gradeSelectItem.index = i
    self._gradeArr[i] = gradeSelectItem
  end
  self._gradeArr[1]:selected()
end

function ArtOfWarView:onClickGradeSwitch(dp,target)
   if target.index - 1 == self._currentPage then
     target:selected()
     return
   end
   self._currentPage = target.index -1
   local targetX = -display.width * self._currentPage
   self._isTweening = true
   transition.execute(self._nodeContainer, CCMoveTo:create(0.15,ccp(targetX,self._nodeContainer:getPositionY())),
   {
      onComplete = function()
         self._isTweening = false
         self._isDragging = false
         
         for key, point in pairs(self._gradeArr) do
             point:unselected()
         end
         self._gradeArr[self._currentPage+1]:selected()
      end,
   })
   
end

function ArtOfWarView:onExit()
  --exit
  if self:getDelegate() ~= nil then
     -- delegate is battle view
     self:getDelegate():battleGuideTrggier()
  end
end

function ArtOfWarView:onTouch(event,x,y)
  if event == "began" then
     if self._isTweening == true then
         return false
     end
     self._oldX = x
     self._startX = self._nodeContainer:getPositionX()
     self._startTouchX = x
     self._startTouchY = y
     return true
  elseif event == "moved" then
     if self._isDragging == false then
        if math.abs(x - self._oldX) > 15 then
           self._isDragging = true
        end
     else
         local m_offset = x - self._oldX
         if self._currentPage == 0 or self._currentPage == 3 then
            m_offset = m_offset/2
         end
         self._nodeContainer:setPositionX(self._nodeContainer:getPositionX() + m_offset)
     end
  
     self._oldX = x
  elseif event == "ended" then
     local offsetX = self._startX - self._nodeContainer:getPositionX()
     if math.abs(offsetX) > 10 then
       local targetX = 0
       if offsetX < 0 then  -- left
          self._currentPage = self._currentPage - 1
          if self._currentPage < 0 then
             self._currentPage = 0
          end
          targetX = -display.width * self._currentPage
       elseif offsetX > 0 then -- right
          self._currentPage = self._currentPage + 1
          if self._currentPage > 3 then
             self._currentPage = 3
          end
          targetX = -display.width * self._currentPage
       end
       self._isTweening = true
       transition.execute(self._nodeContainer, CCMoveTo:create(0.15,ccp(targetX,self._nodeContainer:getPositionY())),
       {
          onComplete = function()
             self._isTweening = false
             self._isDragging = false
             
             for key, point in pairs(self._gradeArr) do
             	   point:unselected()
             end
             self._gradeArr[self._currentPage+1]:selected()
          end,
       })
    else
       if math.abs(self._startTouchX -x) < 10 and math.abs(self._startTouchY -y) < 10 then
          self:removeFromParentAndCleanup(true)
       end
    end
  end
end

function ArtOfWarView:createListByType(type)
    
    assert(AllConfig.battlehelp ~= nil ,"BattleHelp data error")
    assert(type == 0 or type == 1,"BattleHelp type error")
    
    local con = display.newNode()
    
    --create background frame
    local frame = display.newSpriteFrame("atr_of_wall/art_of_war_bg.png")
    local bg =  CCScale9Sprite:createWithSpriteFrame(frame)
    bg:setContentSize(CCSizeMake(625,845))
    --bg:setAnchorPoint(ccp(0,0))
    bg:setPosition(ccp(display.cx,display.cy))
    con:addChild(bg)
    
    -- create content
    local listContainer = display.newNode()
    listContainer:setAnchorPoint(ccp(0,0))
    
    local idx = 0
    for id, listInfo in pairs(AllConfig.battlehelp) do
    	 if listInfo.type == type then
    	    local listItem = ArtOfWarListItem.new()
    	    listContainer:addChild(listItem)
    	    listItem:setData(listInfo)
    	    listItem:setPosition(ccp(0,119*idx))
    	    idx = idx + 1
    	 end
    end
    
    listContainer:setContentSize(CCSizeMake(640,119*idx))
    
    --create scrollView
    local scrollView = CCScrollView:create()
    scrollView:setViewSize(CCSizeMake(bg:getContentSize().width,bg:getContentSize().height-140))
    scrollView:setContentSize(CCSizeMake(640,119*idx))
    scrollView:setDirection(kCCScrollViewDirectionVertical)
    scrollView:setClippingToBounds(true)
    scrollView:setBounceable(true)
    
    scrollView:setContainer(listContainer)
    scrollView:setTouchPriority(-128)
    
    con:addChild(scrollView)
    scrollView:setPosition(ccp(10,display.cy - scrollView:getViewSize().height/2 - 140/2))
    scrollView:setTag(1000)
    -- scroll to top
    listContainer:setPosition(ccp(0, scrollView:getViewSize().height - listContainer:getContentSize().height))
    
    if type == 0 then
      --create title sprite
      local title3 = display.newSprite("#atr_of_wall/art_of_war_title_middle.png")
      con:addChild(title3)
      title3:setPosition(ccp(display.cx,scrollView:getPositionY() + scrollView:getViewSize().height + 85))
      local sonTitle3 = display.newSprite("#atr_of_wall/art_of_war_buff_str.png")
      con:addChild(sonTitle3)
      sonTitle3:setAnchorPoint(ccp(0,0.5))
      sonTitle3:setPosition(ccp(display.cx - 275,scrollView:getPositionY() + scrollView:getViewSize().height+18))
    elseif type == 1 then
      local title4 = display.newSprite("#atr_of_wall/art_of_war_title_last.png")
      con:addChild(title4)
      title4:setPosition(ccp(display.cx,scrollView:getPositionY() + scrollView:getViewSize().height + 85))
      local sonTitle4 = display.newSprite("#atr_of_wall/art_of_war_str.png")
      con:addChild(sonTitle4)
      sonTitle4:setAnchorPoint(ccp(0,0.5))
      sonTitle4:setPosition(ccp(display.cx - 275,scrollView:getPositionY() + scrollView:getViewSize().height + 18))
    end
    
    return con
end

return ArtOfWarView