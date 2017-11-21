require("helper.ccbHelper")
require("helper.ccbRegisterPkg")

UIHelper = {}
local isNeedScrollList = false

function UIHelper.getTouchedNode(toTouchArray,x,y,anchorPoint)
  local isGetedNode = false
  local touchedNode = nil
  --for i = 1, table.getn(toTouchArray) do
  for key, touchNode in pairs(toTouchArray) do
    local contentSize = touchNode:getContentSize()
    if anchorPoint == nil then
       anchorPoint = ccp(0.5,0.5)
    end
    local  position = touchNode:getParent():convertToNodeSpace(ccp(x + contentSize.width*anchorPoint.x,y + contentSize.height*anchorPoint.y ))  --获取 x,y 相对于touchNode:getParent()坐标系的坐标点
    isGetedNode = touchNode:boundingBox():containsPoint(position)
    if isGetedNode == true then
      touchedNode = touchNode
      break
    end
  end
  return touchedNode
end

function UIHelper.normalBtn(name,pos,call,textures,buttonSize,labelSize,labelColor)
  if textures == nil then
    textures = {"#empty.png","#empty.png"}
  else
    assert(#textures >= 2)
  end
  
  local buttonSize = CCSizeMake(150,50)

  local pBackgroundButton = display.newScale9Sprite(textures[1],pos.x,pos.y,buttonSize)

  local pTitleButtonLabel = CCLabelTTF:create(_tr(name), "Marker Felt", labelSize or 22)
  local m_labelColor = labelColor or ccc3(159, 168, 176)
  pTitleButtonLabel:setColor(m_labelColor)
  
  local pControlButton = CCControlButton:create(pTitleButtonLabel,pBackgroundButton)
  pControlButton:setBackgroundSpriteForState(pBackgroundHighlightedButton, CCControlStateHighlighted)
  pControlButton:addHandleOfControlEvent(call,CCControlEventTouchDown)
  pControlButton:setPosition(pos or ccp(0,0))
  pControlButton:setContentSize(buttonSize)
  return pControlButton
  
end

function UIHelper.ccMenu(normal,highted,callBack)
  
    local menuItem = CCMenuItemImage:create(normal, highted)  
    menuItem:setPosition(0, 0)
    menuItem:registerScriptTapHandler(callBack)
    local   ccMenu = CCMenu:createWithItem(menuItem)  
    ccMenu:setVisible(true)  
    
    return ccMenu
end

function UIHelper.ccMenuWithSprite(normal,highted,disabled,callBack)
  
    local menuItem = CCMenuItemImage:create()  
    if normal ~= nil then
       menuItem:setNormalImage(normal)
    end
    
    if highted ~= nil then
       menuItem:setSelectedImage(highted)
    end
    
    if disabled ~= nil then
       menuItem:setDisabledImage(disabled)
    end
    menuItem:setPosition(0, 0)
    if callBack ~= nil then
       menuItem:registerScriptTapHandler(callBack)
    end
    
    local ccMenu = CCMenu:createWithItem(menuItem)  
    ccMenu:setPosition(0,0)
    ccMenu:setVisible(true)  
    
    return ccMenu,menuItem
end

function UIHelper.ccMenuItemImageWithSprite(normal,highted,disabled,callBack)
    local menuItem = CCMenuItemImage:create()  
    if normal ~= nil then
       menuItem:setNormalImage(normal)
    end
    
    if highted ~= nil then
       menuItem:setSelectedImage(highted)
    end
    
    if disabled ~= nil then
       menuItem:setDisabledImage(disabled)
    end
    menuItem:setPosition(0, 0)
    echo("callBack:",callBack)
    if callBack ~= nil then
       menuItem:registerScriptTapHandler(callBack)
    end
    
    return menuItem
end

function UIHelper.convertBgToEditBox(bg,plHolderStr,fontSize,ccColor3B,isFlagPassword,maxLength)
  if bg ~= nil then
    local parent = bg:getParent()
    if parent ~= nil then
      bg:removeFromParentAndCleanup(false)
    end
    if plHolderStr == nil then
      plHolderStr = ""
    end
    if fontSize == nil then
      fontSize = 10
    end
--    if maxLength == nil then
--       maxLength = 12
--    end
    local pos = ccp(bg:getPositionX(),bg:getPositionY())
    local size = bg:getContentSize()
    local editBox = CCEditBox:create(size,bg)
    editBox:setAnchorPoint(ccp(0,0))
    if ccColor3B == nil then
		  ccColor3B = ccc3(255,255,255)
	  end
	  editBox:setPlaceholderFontColor(ccColor3B)
    --editBox:setFontSize(fontSize)
    editBox:setPlaceholderFontSize(fontSize)
    editBox:setPlaceHolder(plHolderStr)
    if ccColor3B == nil then
		   ccColor3B = ccc3(255,255,255)
	  end
    editBox:setFontColor(ccColor3B)
    editBox:setReturnType(kKeyboardReturnTypeDone)
    editBox:setPosition(pos)

    if maxLength ~= nil then
        editBox:setMaxLength(maxLength)
    end

    if isFlagPassword ~=nil and isFlagPassword == true  then
        editBox:setInputFlag(0)      --kEditBoxInputFlagPassword =0
    end
    parent:addChild(editBox)
    return editBox
  else
    return nil
  end

end

function UIHelper.showScrollListView(param)
	local object = param.object
	local totalCount = param.totalCount
	local index = param.index
  local totalCellsCount = param.totalCells

	if index < totalCount  and isNeedScrollList == true then
	  if index%2 == 0 then
	     object:setPosition(ccp(-800,0))
	  else
	     object:setPosition(ccp(800,0))
	  end
		
		local function action()
			object:runAction(CCMoveTo:create(0.05*(index+1),ccp(0,0)))
		end
		object:performWithDelay(action,0.1)
		if index+1 >= totalCount then
			isNeedScrollList =  false
		end

		if totalCellsCount ~= nil and (index+1 >= totalCellsCount) then 
			isNeedScrollList =  false
		end
	end
end

function UIHelper.setIsNeedScrollList(isNeed)
	isNeedScrollList = isNeed
end

function UIHelper.getIsNeedScrollList()
	return isNeedScrollList
end

function UIHelper.showLoading()
  GameData:Instance():getCurrentScene():showLoading()
end

function UIHelper.hideLoading()
  GameData:Instance():getCurrentScene():hideLoading()
end

_showLoading = UIHelper.showLoading
_hideLoading = UIHelper.hideLoading
