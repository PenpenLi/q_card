

Toast = class("Toast", function() 
    return CCNode:create()
    end)


function Toast:ctor()
end


function Toast:showString(target, str, pos,...)
	Toast:showStringWithEndAction(target, str, pos,nil,...)
end
function Toast:showStringWithEndAction(target, str, pos, callback,...)
  -- if target == nil then 
  --   echo("Toast: null target !")
  --   return 
  -- end

  if str == nil then 
    echo("Toast: empty string !")
    return 
  end

  str = string.format(str,...)
  local toast = Toast.new()

  local function actionEnd()
    if toast.target ~= nil then 
      local label = toast.target:getChildByTag(233)
      if label then 
        echo("action end0")
        toast.target:removeChild(label, true)
        toast.target = nil 
      end 
    end
	if(callback) then
		callback()
	end
  end

  toast.target = GameData:Instance():getCurrentScene()  -- =target

--  local label = nil
--  if kTargetIphone == targetPlatform or kTargetIpad == targetPlatform then
--    label = CCLabelTTF:create(string, "fzcyjt", 28)
--  else
--    label = CCLabelTTF:create(string, "fzcyjt.ttf", 28)
--  end

  --for new stroke
  --[[local pLabel = CCLabelTTF:create(str,"Courier-Bold",28,CCSize(400, 0),kCCTextAlignmentCenter)
  pLabel:setFontFillColor(ccc3(255, 255, 0))
  local targetPlatform = CCApplication:sharedApplication():getTargetPlatform()
  if targetPlatform == kTargetWindows then
    pLabel:setColor(ccc3(255, 255, 0))
  end
  pLabel:enableStroke(ccc3(0,0,0),2,true)]]

  local pLabel = ui.newTTFLabelWithOutline( {
	  text = str,
	  font = "Courier-Bold",
	  size = 28,
	  color = ccc3(255, 255, 0), -- 使用纯黄色
	  align = ui.TEXT_ALIGN_CENTER,
	  valign = ui.TEXT_VALIGN_TOP,
	  dimensions = CCSize(400, 0),
	  outlineColor =ccc3(0,0,0) }
  )

 -- label:setColor(sgRED)
  pLabel:setPosition(pos)
  toast:addChild(pLabel)
  toast:setTag(233)
  toast.target:addChild(toast, 9000)

  local array = CCArray:create()
  array:addObject(CCMoveBy:create(1.3, ccp(0, 70)))
  array:addObject(CCDelayTime:create(0.4))
  array:addObject(CCFadeOut:create(1.0))
  array:addObject(CCCallFunc:create(actionEnd))
  local action = CCSequence:create(array)
  pLabel:runAction(action)
end



function Toast:showStringImg(target, imgId, pos)
  -- if target == nil then 
  --   echo("Toast: null target !")
  --   return 
  -- end  

  local toast = Toast.new()

  local function actionEnd()
    if toast.target ~= nil then 
      local label = toast.target:getChildByTag(234)
      if label then 
        echo("action end1")
        toast.target:removeChild(label, true)
        toast.target = nil 
      end 
    end
  end

  toast.target = GameData:Instance():getCurrentScene()

  --test img
  local sprite = CCSprite:create("buttonBackground.png")

  sprite:setPosition(pos)
  toast:addChild(sprite)
  toast:setTag(234)
  toast.target:addChild(toast)

  local array = CCArray:create()
  array:addObject(CCMoveBy:create(1.3, ccp(0, 70)))
  array:addObject(CCDelayTime:create(0.4))
  array:addObject(CCFadeOut:create(1.0))
  array:addObject(CCCallFunc:create(actionEnd))
  local action = CCSequence:create(array)
  sprite:runAction(action)  
end


function Toast:showIconStringImg(target, iconId, strImgId, pos)

  if target == nil then 
    echo("Toast: null target !")
    return 
  end  

  --if target:getChildByTag(235) then 
  --  echo("stop last Toast")
  --  target:removeChildByTag(235)
  --end

  local toast = Toast.new()

  local function actionEnd()
    if toast.target ~= nil then 
      local label = toast.target:getChildByTag(235)
      if label then 
        echo("action end2")
        toast.target:removeChild(label, true)
        toast.target = nil 
      end 
    end
  end

  toast.target = GameData:Instance():getCurrentScene()


  --test
  local sprite1 = CCSprite:create("buttonBackground.png")
  local sprite2 = CCSprite:create("buttonBackground.png")

  local w1 = sprite1:getContentSize().width 
  local w2 = sprite2:getContentSize().width 

  sprite1:setAnchorPoint(ccp(0,0))
  sprite2:setAnchorPoint(ccp(0,0))

  sprite1:setPosition(ccp(0,0))
  sprite2:setPosition(ccp(w1+20, 0))


  local node = CCNodeRGBA:create()
  
  node:addChild(sprite1)
  node:addChild(sprite2)
  node:setPosition(ccpSub(pos, ccp((w1+w2)/2, 0)))
  node:setCascadeOpacityEnabled(true)
  toast:addChild(node)
  toast:setTag(235)
  toast.target:addChild(toast)

  local array = CCArray:create()
  array:addObject(CCMoveBy:create(1.3, ccp(0, 70)))
  array:addObject(CCDelayTime:create(0.4))
  array:addObject(CCFadeOut:create(1.0))
  array:addObject(CCCallFunc:create(actionEnd))
  local action = CCSequence:create(array)
  node:runAction(action)  
end

function Toast:showIconAndNum(picIdOrPathName,bgId,str,pos,isChip, frameId, fntName)
  
  if picIdOrPathName == nil then 
    return 
  end

  if pos == nil then
     pos = ccp(display.cx,display.cy)
  end
  
	local toast = Toast.new()
	local function actionEnd()
		if toast.target ~= nil then
			local label = toast.target:getChildByTag(235)
			if label then
				echo("action end2")
				toast.target:removeChild(label, true)
				toast.target = nil
			end
		end
	end
	toast.target = GameData:Instance():getCurrentScene()

	local sprite1 = nil --CCSprite:create("tongqian.png")
  if type(picIdOrPathName) == "number" then
    if picIdOrPathName == 3050050 then --coind
      picIdOrPathName = 3059002
    elseif picIdOrPathName == 3050049 then --money
      picIdOrPathName = 3059003
    elseif picIdOrPathName == 3059046 then --card soul 
      picIdOrPathName = 3059042 
    end

    sprite1 = _res(picIdOrPathName)
  else
    sprite1 = display.newSprite(picIdOrPathName)
  end

  if sprite1 == nil then
    echo(" invalid sprite !!")
    return
  end

	local w1 = sprite1:getContentSize().width
  if w1 > 95 and type(picIdOrPathName) == "number" then
    sprite1:setScale(95/w1)
  end

	w1 = sprite1:boundingBox().size.width

  if fntName == nil then 
    fntName = "img/client/widget/words/float_number/number.fnt"
  end 
	local labelFont = CCLabelBMFont:create(str, fntName) -- CCSprite:create("buttonBackground.png")
	sprite1:setPosition(ccp(sprite1:boundingBox().size.width/2,sprite1:boundingBox().size.height/2))
	labelFont:setPosition(ccp(w1+ labelFont:getContentSize().width/2 + 10 ,sprite1:boundingBox().size.height/2.0-4))

	local node =  CCNodeRGBA:create() --CCLayerColor:create(ccc4(0,0,0,100)) --
	node:setAnchorPoint(ccp(0.5,0.5))
	local height = math.max(sprite1:boundingBox().size.height, labelFont:getContentSize().height)
	node:setContentSize(CCSizeMake(sprite1:boundingBox().size.width+ labelFont:getContentSize().width+10,height))

  --background image
  if bgId ~= nil then 
    local bgImg = _res(bgId)
    if bgImg ~= nil then 
      bgImg:setPosition(ccp(sprite1:getPosition()))
      node:addChild(bgImg)
    end
  end

  --icon
	node:addChild(sprite1)
  if frameId ~= nil then 
    local frameImg = _res(frameId)
    if frameImg ~= nil then 
      frameImg:setPosition(ccp(sprite1:getPosition()))
      node:addChild(frameImg)
    end
  end

	node:addChild(labelFont)
	node:setPosition(pos)
	node:setCascadeOpacityEnabled(true)
	toast:addChild(node)
	toast:setTag(235)
	toast.target:addChild(toast)
	if isChip ~= nil and isChip == true then
		local sprite_suipian = CCSprite:create("img/common/suipian.png")
		sprite_suipian:setAnchorPoint(ccp(0,0))
		sprite_suipian:setPosition(ccp(4,sprite_suipian:getContentSize().height*2+5))
    node:addChild(sprite_suipian,1,1)
	end

	local array = CCArray:create()
	array:addObject(CCMoveBy:create(1.3, ccp(0, 80)))
	array:addObject(CCDelayTime:create(0.4))
	array:addObject(CCFadeOut:create(1.0))
	array:addObject(CCCallFunc:create(actionEnd))
	local action = CCSequence:create(array)
	node:runAction(action)
end

function Toast:showStringNum(numStr,pos, fntName)
	local toast = Toast.new()
	local function actionEnd()
		if toast.target ~= nil then
			local label = toast.target:getChildByTag(235)
			if label then
				echo("action end2")
				toast.target:removeChild(label, true)
				toast.target = nil
			end
		end
	end
	toast.target = GameData:Instance():getCurrentScene()

  if fntName == nil then 
    fntName = "img/client/widget/words/float_number/number.fnt"
  end 

	local labelFont = CCLabelBMFont:create(numStr, fntName) -- CCSprite:create("buttonBackground.png")
	labelFont:setPosition(ccp( labelFont:getContentSize().width/2 ,labelFont:getContentSize().height/2.0))
	local node =  CCNodeRGBA:create() --CCLayerColor:create(ccc4(0,0,0,100)) --
	node:setAnchorPoint(ccp(0.5,0.5))
	node:setContentSize(CCSizeMake(labelFont:getContentSize().width+10,labelFont:getContentSize().height))
	node:addChild(labelFont)
	node:setPosition(pos)
	node:setCascadeOpacityEnabled(true)
	toast:addChild(node)
	toast:setTag(235)
	toast.target:addChild(toast)

	local array = CCArray:create()
	array:addObject(CCMoveBy:create(1.3, ccp(0, 80)))
	array:addObject(CCDelayTime:create(0.4))
	array:addObject(CCFadeOut:create(1.0))
	array:addObject(CCCallFunc:create(actionEnd))
	local action = CCSequence:create(array)
	node:runAction(action)
end

function Toast:showIcon(iconPath, pos)

	local toast = Toast.new()
	local function actionEnd()
		if toast.target ~= nil then
			local label = toast.target:getChildByTag(234)
			if label then
				echo("action end1")
				toast.target:removeChild(label, true)
				toast.target = nil
			end
		end
	end

	toast.target = GameData:Instance():getCurrentScene()

	--test img
	local sprite = CCSprite:create(iconPath)

	sprite:setPosition(pos)
	toast:addChild(sprite)
	toast:setTag(234)
	toast.target:addChild(toast)

	local array = CCArray:create()
    array:addObject(CCFadeIn:create(1.0))
	array:addObject(CCMoveBy:create(1.3, ccp(0, 70)))
	array:addObject(CCDelayTime:create(0.4))
	array:addObject(CCFadeOut:create(1.0))
	array:addObject(CCCallFunc:create(actionEnd))
	local action = CCSequence:create(array)
	sprite:runAction(action)
end


function Toast:showIconAndNumWithDelay(picId,bgId,str,pos, delay, isChip, frameId, fntName)
  local toast = Toast.new()

  local function timerCallback(dt)
    if toast.scheduler ~= nil then 
      CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(toast.scheduler)
      toast:showIconAndNum(picId, bgId, str, pos, isChip, frameId, fntName)
    end
  end

  if delay > 0 then 
    toast.scheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(timerCallback, delay, false)
  else 
    toast:showIconAndNum(picId, bgId, str, pos, isChip, frameId, fntName)
  end
end

--new api 
function Toast:showIconNum(str, picIdOrPathName, itemType, configId, pos, fntName)
  local toast = Toast.new()
  toast.target = GameData:Instance():getCurrentScene()

  local sprite1 = nil
  if picIdOrPathName ~= nil then 
    if type(picIdOrPathName) == "number" then
      if picIdOrPathName == 3050050 then --coind
        picIdOrPathName = 3059002
      elseif picIdOrPathName == 3050049 then --money
        picIdOrPathName = 3059003
      elseif picIdOrPathName == 3059046 then --card soul 
        picIdOrPathName = 3059042 
      elseif picIdOrPathName == 3050070 then --竞技场荣誉点
        picIdOrPathName = 3059069 
      elseif picIdOrPathName == 3050071 then --公会点
        picIdOrPathName = 3059070
      elseif picIdOrPathName == 3059072 then --通天塔
        picIdOrPathName = 3059071
      end
      sprite1 = _res(picIdOrPathName)
    else
      sprite1 = display.newSprite(picIdOrPathName)
    end
  else 
    sprite1 = GameData:Instance():getCurrentPackage():getItemSprite(nil, itemType, configId, 0)
  end 

  if sprite1 == nil then
    echo(" invalid sprite !!")
    return
  end

  local node =  CCNodeRGBA:create()
  node:setAnchorPoint(ccp(0.5,0.5))
  node:addChild(sprite1)

  if fntName == nil then 
    fntName = "img/client/widget/words/float_number/number.fnt"
  end 
  --string 
  local labelFont = CCLabelBMFont:create(str, fntName) -- CCSprite:create("buttonBackground.png")
  labelFont:setPosition(ccp(sprite1:getContentSize().width/2+ labelFont:getContentSize().width/2 + 10 ,0))
  node:addChild(labelFont)

  node:setPosition(pos)
  node:setCascadeOpacityEnabled(true)
  toast:addChild(node)
  toast:setTag(235)
  toast.target:addChild(toast, 2000)

  --play anim
  local function actionEnd()
    if toast.target ~= nil then
      local label = toast.target:getChildByTag(235)
      if label then
        echo("action end2")
        toast.target:removeChild(label, true)
        toast.target = nil
      end
    end
  end

  local array = CCArray:create()
  array:addObject(CCMoveBy:create(1.3, ccp(0, 80)))
  array:addObject(CCDelayTime:create(0.4))
  array:addObject(CCFadeOut:create(1.0))
  array:addObject(CCCallFunc:create(actionEnd))
  local action = CCSequence:create(array)
  node:runAction(action)
end

function Toast:showIconNumWithDelay(str, picIdOrPathName, itemType, configId, pos, delay, fntName)
  local toast = Toast.new()

  local function timerCallback(dt)
    if toast.scheduler ~= nil then 
      CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(toast.scheduler)
      toast:showIconNum(str, picIdOrPathName, itemType, configId, pos, fntName)
    end
  end

  if delay > 0 then
    toast.scheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(timerCallback, delay, false)
  else 
    toast:showIconNum(str, picIdOrPathName, itemType, configId, pos, fntName)
  end
end

-- example 
  --Toast:showString(self, "兽王吊坠", ccp(100, 200))
  --Toast:showStringImg(self, imgId, ccp(100, 300))
  --Toast:showIconStringImg(self, imgId1, imgId2, ccp(100,300))