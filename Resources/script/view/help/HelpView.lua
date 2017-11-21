
HelpView = class("HelpView",BaseView)


ArrowDir = enum({"LeftDown", "RightDown", "CenterDown","LeftUp", "RightUp","CenterUp", "LeftLeftUp", "LeftLeftDown", "RightRightUp", "RightRightDown"})


function HelpView:ctor()
  HelpView.super.ctor(self)
  local colorLayer = CCLayerColor:create(ccc4(0, 0, 0, 100), display.width, display.height)
  self:addChild(colorLayer)

  self.hasBox = false 

  self:regTouchEvent()
end

function HelpView:onEnter()
  Guide:Instance():removeGuideLayer()
end

function HelpView:onExit()
  _executeNewBird()
  -- UIHelper.triggerGuide(10107,CCRectMake(0,0,0,0),emRight)
  -- UIHelper.triggerGuide(11430,CCRectMake(0,0,0,0),emRight)
  -- UIHelper.triggerGuide(11607,CCRectMake(0,0,0,0),emRight)
end

function HelpView:regTouchEvent()
  
  local function onTouch(eventType, x, y)
    if eventType == "began" then
      self._startX = x
      self._startY = y
      return true 
    elseif eventType == "ended" then
        if math.abs(self._startX - x) > 10 or  math.abs(self._startY - y) > 10 then
          
        else
          self:removeFromParentAndCleanup(true) 
        end
    end
  end

  self:addTouchEventListener(onTouch,false, -300, true)
  self:setTouchEnabled(true)
end


function HelpView:addHelpItem(helpId, object, offset, arrowDirection)

  if object == nil then 
    echo(" nil object or position")
    return
  end

  --calc pos to display tip
  local pos = ccp(object:getPosition())
  if object:getParent() ~= nil then
    pos = object:getParent():convertToWorldSpace(pos)
  end

  if offset ~= nil then 
    pos.x = pos.x + offset.x 
    pos.y = pos.y + offset.y
  end

  --create help item
  local node = self:initItem(helpId, pos, arrowDirection)
  node:setPosition(pos)
  self:addChild(node) 
end

function HelpView:addHelpBox(helpId, offset, isDispFull)
  self.hasBox = true 

  local node = self:initItemBox(helpId, offset, isDispFull)
  self:addChild(node) 
end 

function HelpView:initItem(helpId, pos, arrowDirection)

  self._img = CCScale9Sprite:create("img/help/help_frame0.png")
  if self._img == nil then 
    return 
  end

  self._img:setAnchorPoint(ccp(0,0))

  --title
  local title = AllConfig.help[helpId].title
  local outlineLabel = ui.newTTFLabelWithOutline( {
                                            text = title,
                                            font = "Courier-Bold",
                                            size = 22,
                                            x = 0,
                                            y = 0,
                                            color = ccc3(255, 234, 0),
                                            align = ui.TEXT_ALIGN_LEFT,
                                            --valign = ui.TEXT_VALIGN_TOP,
                                            --dimensions = self.label_info:getContentSize(),
                                            outlineColor =ccc3(0,0,0),
                                            pixel = 2
                                            }
                                          )
  --desc
  local desc = AllConfig.help[helpId].content
  local labelDesc = RichLabel:create(desc,"Courier-Bold",20, CCSizeMake(270, 0),true,false)
  labelDesc:setColor(ccc3(69,27,0)) --默认颜色
  local size = labelDesc:getTextSize()
  local offset = 20 
  self._img:setContentSize(CCSizeMake(size.width+offset*2, size.height+30+offset*2))
  outlineLabel:setPosition(ccp(offset, size.height+offset+20))
  labelDesc:setPosition(ccp(offset, size.height+offset))
  self._img:addChild(outlineLabel, 100)
  self._img:addChild(labelDesc, 100)

  self:setArrow(self._img, pos, arrowDirection)

  local node = CCNode:create()
  node:setPosition(pos)
  node:addChild(self._img)
  return node 
end


function HelpView:setArrow(bgImg, pos, direction)
  if bgImg == nil then 
    return 
  end

  direction =  direction or ArrowDir.LeftDown

  local arrow = CCSprite:create("img/help/help_arrow.png")
  if arrow ~= nil then 
    local bgSize = bgImg:getContentSize()
    local arrSize = arrow:getContentSize()
    local x = 0
    local y = 0 
    
    if direction == ArrowDir.LeftLeftDown then 
      arrow:setAnchorPoint(ccp(0, 0))
      arrow:setRotation(-90)
      arrow:setFlipX(true)
      x = 14
      y = (bgSize.height - arrSize.width)*0.3

      bgImg:setPosition(ccp(arrSize.height-x, -y))

    elseif direction == ArrowDir.LeftLeftUp then 
      arrow:setAnchorPoint(ccp(0, 0))
      arrow:setRotation(-90)
      x = 14
      y = (bgSize.height - arrSize.width)*0.6
      bgImg:setPosition(ccp(arrSize.height-x, -y-arrSize.width*0.6))

    elseif direction == ArrowDir.RightRightDown then 
      arrow:setAnchorPoint(ccp(1, 0))
      arrow:setRotation(90)
      x = bgSize.width - 14
      y = (bgSize.height - arrSize.width)*0.3
      bgImg:setPosition(ccp(-(arrSize.height+x), -y))

    elseif direction == ArrowDir.RightRightUp then 
      arrow:setAnchorPoint(ccp(1, 0))
      arrow:setRotation(90)
      arrow:setFlipX(true)
      x = bgSize.width - 14
      y = (bgSize.height - arrSize.width)*0.6
      bgImg:setPosition(ccp(-(arrSize.height+x), -y-arrSize.width*0.6))

    elseif direction == ArrowDir.LeftUp then 
      arrow:setAnchorPoint(ccp(0, 0))
      arrow:setFlipX(true)
      x = (bgSize.width-arrSize.width)*0.2
      y = bgSize.height - 13
      bgImg:setPosition(ccp(-x, -(y+arrSize.height)))

    elseif direction == ArrowDir.CenterUp then 
      arrow:setAnchorPoint(ccp(0, 0))
      arrow:setFlipX(true)
      x = (bgSize.width-arrSize.width)*0.5
      y = bgSize.height - 13
      bgImg:setPosition(ccp(-x, -(y+arrSize.height)))

    elseif direction == ArrowDir.RightUp then 
      arrow:setAnchorPoint(ccp(0, 0))
      x = (bgSize.width-arrSize.width)*0.8
      y = bgSize.height - 13
      bgImg:setPosition(ccp(-x-arrSize.width*0.8, -(y+arrSize.height-13)))

    elseif direction == ArrowDir.LeftDown then 
      arrow:setFlipY(true)
      arrow:setFlipX(true)
      arrow:setAnchorPoint(ccp(0, 1))
      x = (bgSize.width-arrSize.width)*0.2
      y = 14  
      bgImg:setPosition(ccp(-x-arrSize.width*0.2, arrSize.height-y))

    elseif direction == ArrowDir.CenterDown then 
      arrow:setFlipY(true)
      arrow:setAnchorPoint(ccp(0, 1))
      x = (bgSize.width-arrSize.width)*0.5
      y = 14   
      bgImg:setPosition(ccp(-x-arrSize.width*0.8, arrSize.height-y))

    elseif direction == ArrowDir.RightDown then 
      arrow:setFlipY(true)
      arrow:setAnchorPoint(ccp(0, 1))
      x = (bgSize.width-arrSize.width)*0.8
      y = 14
      bgImg:setPosition(ccp(-x-arrSize.width*0.8, arrSize.height-y))

    else 
      arrow:setAnchorPoint(ccp(0, 0))
      arrow:setRotation(-90)
      arrow:setFlipX(true)
      x = 14
      y = (bgSize.height - arrSize.width)*0.3
      bgImg:setPosition(ccp(-x-arrSize.width*0.2, arrSize.height-y))
    end

    arrow:setPosition(ccp(x, y))
    bgImg:addChild(arrow, 101)
  end 
end 

function HelpView:initItemBox(helpId, offset, isDispFull)
  local bgImg = CCScale9Sprite:create("img/help/help_frame1.png")
  if bgImg == nil then 
    return 
  end 

  local bgWidth = 610 
  local bgHeight = 170
  local cellWidth = 540 
  local cellHeight = 90

  --title
  local title = AllConfig.help[helpId].title
  local outlineLabel = ui.newTTFLabelWithOutline( {
                                            text = title,
                                            font = "Courier-Bold",
                                            size = 22,
                                            x = 0,
                                            y = 0,
                                            color = ccc3(255, 234, 0),
                                            align = ui.TEXT_ALIGN_LEFT,
                                            --valign = ui.TEXT_VALIGN_TOP,
                                            --dimensions = self.label_info:getContentSize(),
                                            outlineColor =ccc3(0,0,0),
                                            pixel = 2
                                            }
                                          )

  --desc
  local desc = AllConfig.help[helpId].content.."\n"
  local labelDesc = RichLabel:create(desc,"Courier-Bold",20, CCSizeMake(cellWidth, 0),true,false)
  labelDesc:setColor(ccc3(69,27,0)) --默认颜色
  local textSize = labelDesc:getTextSize()

  local offsetx = (bgWidth-cellWidth)/2
  local node = CCNode:create()

  --add desc first
  if isDispFull == nil or isDispFull == false then 
    --重新封装RichLabel,使得锚点在(0,0), node的contentsize()为字串大小,否则滑动scrollview会出问题
    local nodeDesc = CCNode:create()
    nodeDesc:setContentSize(textSize)
    labelDesc:setPosition(ccp(0, textSize.height))
    nodeDesc:addChild(labelDesc)

    local scrollView = CCScrollView:create()
    scrollView:setContentSize(textSize)
    scrollView:setViewSize(CCSizeMake(cellWidth, cellHeight))
    scrollView:setDirection(kCCScrollViewDirectionVertical)
    scrollView:setClippingToBounds(true)
    scrollView:setBounceable(true)

    nodeDesc:setPosition(ccp(0, -(textSize.height-cellHeight)))
    scrollView:setContainer(nodeDesc)
    scrollView:setTouchPriority(-301)
    
    scrollView:setPosition(ccp(offsetx, 20))
    node:addChild(scrollView, 1)
  else 
    bgHeight = math.max(bgHeight, 86+textSize.height)
    labelDesc:setPosition(ccp(offsetx, bgHeight-56))
    node:addChild(labelDesc, 1)
  end 

  --add title
  outlineLabel:setPosition(ccp(offsetx, bgHeight-40))
  node:addChild(outlineLabel, 1)

  --add bg img 
  bgImg:setContentSize(CCSizeMake(bgWidth, bgHeight))
  bgImg:setAnchorPoint(ccp(0, 0))
  node:addChild(bgImg, 0)

  local pos = ccp((display.width-bgWidth)/2, display.height-bgHeight-50)
  if offset ~= nil then 
    pos = ccpAdd(pos, offset)
  end 
  node:setPosition(pos)

  return node 
end 
