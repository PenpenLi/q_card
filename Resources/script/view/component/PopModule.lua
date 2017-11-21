PopModule = class("PopModule",BaseView)
function PopModule:ctor(popSize,touchPriority,touchEnabled)
  PopModule.super.ctor(self)
  assert(popSize ~= nil,"must create with a size")
  printf("popSize:"..popSize.width.." "..popSize.height)
  self._PopSize = popSize or CCSizeMake(615,650)
  self:setAutoDisposeEnabled(true)
  self:setMenuArray({})
  self._offsetX = 23
  self._offsetY = 25
  if touchPriority == nil then
    touchPriority = -256
  end
  self._baseTouchPriority = touchPriority
  
  if touchEnabled == true then
    self:setTouchEnabled(true)
    self:addTouchEventListener(function() return true end,false,self._baseTouchPriority,true)
  end
end

------
--  Getter & Setter for
--      PopModule._AutoDisposeEnabled 
-----
function PopModule:setAutoDisposeEnabled(AutoDisposeEnabled)
	self._AutoDisposeEnabled = AutoDisposeEnabled
end

function PopModule:getAutoDisposeEnabled()
	return self._AutoDisposeEnabled
end

------
--  Getter & Setter for
--      PopModule._PopSize 
-----
function PopModule:setPopSize(PopSize)
	self._PopSize = PopSize
end

function PopModule:getPopSize()
	return self._PopSize
end

------
--  Getter & Setter for
--      PopModule._ListContainer 
-----
function PopModule:setListContainer(ListContainer)
  self._ListContainer = ListContainer
end

function PopModule:getListContainer()
  return self._ListContainer
end

function PopModule:getCanvasContentSize()
  local width = self._PopSize.width - self._offsetX * 2
  local height = self._PopSize.height - self._titleBg:getContentSize().height - self._offsetY
  if #self:getMenuArray() > 0 then
    height = self._PopSize.height - 170
  end
  return CCSizeMake(width,height)
end

function PopModule:onEnter()
  display.addSpriteFramesWithFile("common/component_list_pop.plist", "common/component_list_pop.png")
  
  if self:getMaskbackGround() == nil then
   --color layer
   local layerColor = CCLayerColor:create(ccc4(0,0,0,200), display.width*2.0, display.height*2.0)
   self:addChild(layerColor)
  end
  
  local popSize = self._PopSize
  
  local bg = display.newScale9Sprite("#component_list_pop_bg.png",display.cx,display.cy,popSize)
  self:addChild(bg)
  self._popupBg = bg
  
  local titleBg = display.newScale9Sprite("#component_list_pop_itle_bg.png",0,0,CCSizeMake(popSize.width,67))
  self:addChild(titleBg)
  titleBg:setPosition(ccp(display.cx,display.cy + popSize.height/2 - titleBg:getContentSize().height/2 ))
  self._titleBg = titleBg
  
  local listContainer = display.newNode()
  self._popupBg:addChild(listContainer,10)
  listContainer:setPosition(ccp(self._offsetX,self._offsetY))
 
  self:setListContainer(listContainer)
  
  local nor = display.newSprite("#component_list_pop_btn_close.png")
  local sel = display.newSprite("#component_list_pop_btn_close1.png")
  local dis = display.newSprite("#component_list_pop_btn_close1.png")
  local closeBtn,menuItem = UIHelper.ccMenuWithSprite(nor,sel,dis,
      function()
        self:onCloseHandler()
      end)
  self:addChild(closeBtn)
  closeBtn:setPositionX(display.cx + popSize.width/2 - nor:getContentSize().width/2 + 10)
  closeBtn:setPositionY(display.cy + popSize.height/2 - nor:getContentSize().height/2 + 10)
  closeBtn:setTouchPriority(self._baseTouchPriority)
  self.closeBtn = menuItem
  
end

function PopModule:getPopBg()
	return self._popupBg
end

------
--  Getter & Setter for
--      PopModule._MaskbackGround 
-----
function PopModule:setMaskbackGround(MaskbackGround)
  if self._MaskbackGround ~= nil then
    self._MaskbackGround:removeFromParentAndCleanup(true)
  end
  
  if MaskbackGround ~= nil then
    self:addChild(MaskbackGround,0)
    MaskbackGround:setPosition(display.cx,display.cy)
  end

	self._MaskbackGround = MaskbackGround
	
end

function PopModule:getMaskbackGround()
	return self._MaskbackGround
end

------
--  Getter & Setter for
--      PopModule._TitleWithSprite 
-----
function PopModule:setTitleWithSprite(TitleWithSprite)
  local titleStr = self._TitleWithSprite
  
  if titleStr ~= nil then
    titleStr:removeFromParentAndCleanup(true)
  end
  
  if self._titleBg ~= nil then
    self._titleBg:addChild(TitleWithSprite)
    TitleWithSprite:setPosition(self._titleBg:getContentSize().width/2,self._titleBg:getContentSize().height/2)
  end
	self._TitleWithSprite = TitleWithSprite
	
	if self._titleTtf ~= nil then
	 self._titleTtf:setString("")
  end
end

function PopModule:getTitleWithSprite()
	return self._TitleWithSprite
end

------
--  Getter & Setter for
--      PopModule._TitleWithString 
-----
function PopModule:setTitleWithString(TitleWithString)
	self._TitleWithString = TitleWithString
	
	local titleStr = self._TitleWithSprite
  if titleStr ~= nil then
    titleStr:removeFromParentAndCleanup(true)
    self._TitleWithSprite = nil
  end
  
  if self._titleTtf == nil then
    local label = CCLabelTTF:create(TitleWithString,"Courier-Bold",30.0)
    self._titleBg:addChild(label)
    label:setPosition(self._titleBg:getContentSize().width/2,self._titleBg:getContentSize().height/2)
    self._titleTtf = label
  end
  
  self._titleTtf:setString(TitleWithString)
end

function PopModule:getTitleWithString()
	return self._TitleWithString
end

function PopModule:onCloseHandler()
  self:removeFromParentAndCleanup(true)
end

function PopModule:onExit()
  if self:getAutoDisposeEnabled() == true then
    self:dispose()
  end
end

function PopModule:dispose()
  display.removeSpriteFramesWithFile("common/component_list_pop.plist", "common/component_list_pop.png")
end

------
--  Getter & Setter for
--      PopModule._MenuArray 
-----
function PopModule:setMenuArray(MenuArray)
	self._MenuArray = MenuArray
	self:buildTabMenus()
end

function PopModule:getMenuArray()
	return self._MenuArray
end

function PopModule:buildTabMenus()
  --init tab menu 
  local menuArray = self:getMenuArray()
  
  if #menuArray <= 0 then
    if self._tabMenu ~= nil then
     self._tabMenu:setVisible(false)
    end
    return
  end
  
  local popSize = self._PopSize
  if self._tabMenu == nil then
    local menuSize = CCSizeMake(590, 74)
    local tabMenu = TabControlEx.new(menuSize, nil, self._baseTouchPriority)
    tabMenu:setDelegate(self)
    self:addChild(tabMenu)
    tabMenu:setPosition(display.cx - menuSize.width/2,display.cy + popSize.height/2 - 145)
    self._tabMenu = tabMenu
  end
  self._tabMenu:setVisible(true)
  self._tabMenu:setMenuArray(menuArray)
  --self._tabMenu:setItemSelectedByIndex(1)
end

------
--  Getter & Setter for
--      PopModule._TabMenu 
-----
function PopModule:setTabMenu(TabMenu)
	self._tabMenu = TabMenu
end

function PopModule:getTabMenu()
	return self._tabMenu
end


function PopModule:tabControlOnClick(idx)
  return true
end

return PopModule