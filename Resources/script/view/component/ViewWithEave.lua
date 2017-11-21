require("view.component.EaveView")
require("view.component.TabControl")
require("view.help.HelpView")
ViewWithEave = class("ViewWithEave",BaseView)

function ViewWithEave:ctor()
  ViewWithEave.super.ctor(self)
  local eave = EaveView.new()
  self:addChild(eave)
  eave:setDelegate(self)
  self._eave = eave
  
  self:setListContainer(eave:getNodeListViewContainer())
  
  self._tabMenu = TabControl.new()
  self._tabMenu:setDelegate(self)
  self:addChild(self._tabMenu)

  self:setTabControlEnabled(true)
  self:setNodeEventEnabled(true)
--  self:setKeypadEnabled(true)

  local function KeypadHandler(strEvent)
	  if "backClicked" == strEvent then
		  if ControllerFactory:Instance():getCurrentControllerType() ~= ControllerFactory.BATTLE_CONTROLLER then
		    self:onBackHandler()
		  end
	  elseif "menuClicked" == strEvent then

	  end
  end
  self:addKeypadEventListener(KeypadHandler)
end

-- overwrite the 'onBackHandler' function at the Class extended ViewWithEave
function ViewWithEave:onBackHandler()
  --printf("[ViewWithEave]: overwrite the 'onBackHandler' function at the Class extended ViewWithEave")
  _playSnd(SFX_CLICK_BACK)
end

-- overwrite the 'onHelpHandler' function at the Class extended ViewWithEave
function ViewWithEave:onHelpHandler()
  --printf("[ViewWithEave]: overwrite the 'onHelpHandler' function at the Class extended ViewWithEave")
  _playSnd(SFX_CLICK)
end

function ViewWithEave:setListContainer(ListContainer)
  self._ListContainer = ListContainer
end

-- addChild list view at this container
function ViewWithEave:getListContainer()
  return self._ListContainer
end

function ViewWithEave:getNodeContainer()
  return self:getEaveView():getNodeContainer()
end

-- screen size subtract top , bottom and eave
function ViewWithEave:getCanvasContentSize()
  local width = display.size.width
  local height = 0
  if self:getTabControlEnabled() == true then
    height = display.size.height - (self._eave.sprite_shortbg:getContentSize().height + self._tabMenu:getContentSize().height + GameData:Instance():getCurrentScene():getBottomContentSize().height )
  else
    height = display.size.height - (self._eave.sprite_shortbg:getContentSize().height + GameData:Instance():getCurrentScene():getBottomContentSize().height )
  end
  local ccsize = CCSizeMake(display.size.width,height)
  return ccsize
end

-- then title texture to show
function ViewWithEave:setTitleTextureName(textureName)
  self._eave:setTitleTextureName(textureName)
end

function ViewWithEave:getTitleTextureName()
  return self._eave:getTitleTextureName()
end

function ViewWithEave:getEaveContentSize()
  return self._eave:getContentSize()
end

function ViewWithEave:getEaveBottomPositionY()
 return self._eave:getEaveBottomPositionY()
end

-- show or hide the yellow background
function ViewWithEave:setScrollBgVisible(val)
	--self._eave:setBackGroundVisible(val)
end

function ViewWithEave:getScrollBgVisible()
	--return self._eave:getBackGroundVisible()
end

function ViewWithEave:getEaveView()
	return self._eave
end

------
--  Getter & Setter for
--      ViewWithEave._tabControlEnabled 
--      show or hide the tabControl
-----
function ViewWithEave:setTabControlEnabled(tabControlEnabled)
	self._tabControlEnabled = tabControlEnabled
	self._tabMenu:setVisible(tabControlEnabled)
	self._eave.sprite_largebg:setVisible(tabControlEnabled)
	--self:resetBackGround()
end

function ViewWithEave:getTabControlEnabled()
	return self._tabControlEnabled
end

-- tabControl click index
function ViewWithEave:tabControlOnClick(idx)
	--printf("[ViewWithEave]:tabControlOnClick:"..idx)
	_playSnd(SFX_CLICK)
end

-- not use, pls use the "setTabControlEnabled" function insted
function ViewWithEave:setTabControlVisible(flag)
--  self._tabMenu:setVisible(flag)  
end

function ViewWithEave:setDelegate(controller) --set controller with a scene
  self._controller = controller
  --self:resetBackGround()
end

------
--  Getter & Setter for
--      ViewWithEave._HelpEnabled 
-----
function ViewWithEave:setHelpEnabled(HelpEnabled)
	self._HelpEnabled = HelpEnabled
	self._eave.btnHelp:setVisible(HelpEnabled)
end

function ViewWithEave:getHelpEnabled()
	return self._HelpEnabled
end

------
--  Getter & Setter for
--      ViewWithEave._menuArray 
-----
function ViewWithEave:setMenuArray(menuArray,hitInfo)	
	self._tabMenu:setMenuArray(menuArray,hitInfo)
end

function ViewWithEave:getMenuArray()
	return self._tabMenu:getMenuArray()
end
function ViewWithEave:setMenuItemTip(idx,bShow)
	self._tabMenu:getItemByIndex(idx):setTipVisible(bShow)
end
function ViewWithEave:isMenuItemTipVisible(idx)
	self._tabMenu:getItemByIndex(idx):isTipVisible()
end
--function ViewWithEave:resetBackGround()
--  local currentScene = nil
--  if self._controller ~= nil then
--     currentScene = self._controller:getScene()
--  else
--     currentScene = GameData:Instance():getCurrentScene()
--  end
--  if currentScene ~= nil then
--   local bgTargetHeight = self._eave:getBackgroundHeight()
--    if self._tabControlEnabled == true then
--      bgTargetHeight = currentScene:getMiddleContentSize().height-self:getEaveContentSize().height - self._tabMenu:getContentSize().height
--    else
--      bgTargetHeight = currentScene:getMiddleContentSize().height-self:getEaveContentSize().height
--    end
--    self._eave:setBackgroundHeight(bgTargetHeight)
--  end
--end

function ViewWithEave:getTabMenu()
  return self._tabMenu
end

function ViewWithEave:setEmptyImgVisible(isVisible)
  self._eave:setEmptyImgVisible(isVisible)
end 

return ViewWithEave