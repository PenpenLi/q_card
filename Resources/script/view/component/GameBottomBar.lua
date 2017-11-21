require("view.component.TabControlItem")
require("view.battle_formation.BattleFormationView")
GameBottomBar = class("GameBottomBar", function()
    return display.newLayer()
end)

function GameBottomBar:ctor()
  self.UNIT_TAG = 333
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("contentSize","CCNode")
  pkg:addProperty("spriteLeftArrow","CCSprite")
  pkg:addProperty("spriteRightArrow","CCSprite")
  pkg:addProperty("btnHome","CCMenuItemImage")
  pkg:addFunc("homeClickHandler",GameBottomBar.homeClickHandler)
  local layer,owner = ccbHelper.load("GameBottomBlockNode.ccbi","GameBottomBlockCCB","CCNode",pkg)
  self:addChild(layer)
  
  self._lastSelectedIdx = 0
  self._menuArray = {}
  self._allMenuItems = {}
  self._touchEnabled = true
  
  self:buildTableView()
  local menuArray = {
     --{"#common-image-shouye.png","#common-image-shouye1.png"},
     {"#common-image-zhanyi.png","#common-image-zhanyi1.png"},
     {"#common-image-zhengzhan.png","#common-image-zhengzhan1.png"},
     {"#common-image-huodong.png","#common-image-huodong1.png"},
     {"#common-image-shangcheng.png","#common-image-shangcheng1.png"},
     {"#common-image-tujian.png","#common-image-tujian1.png"},
     {"#common-image-xitong.png","#common-image-xitong1.png" }
   }
   
   if ChannelManager:getCurrentLoginChannel() == '360' then
     table.insert(menuArray,{"#common-image-acount.png","#common-image-acount1.png"})
   end
   
  self:setMenuArray(menuArray)
end 

function GameBottomBar:homeClickHandler()
  self:tabControlOnClick(0)
end

function GameBottomBar:buildTableView()
    local function scrollViewDidScroll(tableView)
      --print("scrollViewDidScroll")

      if tableView ~= nil then
          if self:getIsScrollLock() == true then
             if self._lockX ~= nil then
                tableView:getContainer():setPositionX(self._lockX)
             end
             return
          end
      
          if tableView:getContainer():getPositionX() >= 0 then
             self.spriteLeftArrow:setVisible(false)
          else
             self.spriteLeftArrow:setVisible(true)
          end
          if tableView:getContainer():getPositionX() <= tableView:minContainerOffset().x then
             self.spriteRightArrow:setVisible(false)
          else
             self.spriteRightArrow:setVisible(true)
          end
      end
    end
    
    local function tableCellTouched(table,cell)
      self:setIsScrollLock(false)
      self:tabControlOnClick(cell:getIdx()+1)
    end
    
    local function cellSizeForTable(table,idx) 
        return 110,106
    end
    
     local function tableCellHighLight(table, cell)
      local idx = cell:getIdx()
      local item = self._allMenuItems[idx+1]
      if item ~= nil then
        item:setSelected(true)
      end
    end 
  
    local function tableCellUnhighLight(table, cell)
      local idx = cell:getIdx()
      local item = self._allMenuItems[idx+1]
      if item ~= nil then
        item:setSelected(false)
      end
    end
    
    local function tableCellAtIndex(tableview, idx)
      local menuItem = nil 
      local cell = tableview:dequeueCell()
      if nil == cell then
        cell = CCTableViewCell:new()
      else
        cell:removeAllChildrenWithCleanup(true)
      end
      menuItem = TabControlItem.new()
      cell:addChild(menuItem)
      menuItem:setPositionX(106/2)
      menuItem:setPositionY(110/2 + 10)
      menuItem:stopAllActions()
      menuItem:setTag(self.UNIT_TAG)
      
      local nor = display.newSprite(self._menuArray[idx+1][1])
      local highlighted = display.newSprite(self._menuArray[idx+1][2])
      menuItem:setHighlightedTexture(highlighted)   
      menuItem:setNormalTexture(nor,idx == 1)
      
      --update tip and rejust tip position, --should be updated after entry home view
      if GameData:Instance():getInitSysComplete() == true then 
        local flag = self:getTipStateForIndex(idx+1)  
        echo(" === bottom menu tip flag =", flag)
        menuItem:setTipVisible(flag)
      end
      local tipImg = menuItem:getTipImg()
      
      if tipImg:getIsAnimation() == true then --expedition
        tipImg:setPosition(ccp(nor:getContentSize().width/2 - 20, nor:getContentSize().height/2))
      else
        tipImg:setPosition(ccp(40, 40))
      end

      --cell:addChild(menuItem)
      menuItem:setSelected(false) 

      cell:setIdx(idx)
      self._allMenuItems[idx+1] = menuItem
      
      if idx == 0 and ControllerFactory:Instance():getCurrentControllerType() ~= ControllerType.SCENARIO_CONTROLLER 
      and GameData:Instance():checkSystemOpenCondition(20, false) == false 
      then
        local anim_node = cell:getChildByTag(6789)
        if anim_node == nil then
          anim_node = display.newNode()
          anim_node:setTag(6789)
          cell:addChild(anim_node)
        else
          anim_node:removeAllChildrenWithCleanup(true)
        end
      
        local guideAnimation,offsetX,offsetY,duration = _res(5020133)
        guideAnimation:setScale(0.75)
        guideAnimation:setPosition(ccp(offsetX + 55,offsetY + 65))
        anim_node:addChild(guideAnimation)
        guideAnimation:getAnimation():play("default")
      end
      
      return cell
     end
    
     local function numberOfCellsInTableView(val)

       return #self._menuArray
     end
    
    local tableView = CCTableView:create(CCSizeMake(self.contentSize:getContentSize().width,130))
    self._tableView = tableView
    tableView:setDirection(kCCScrollViewDirectionHorizontal)
    self.contentSize:addChild(tableView)
    --tableView:setPositionY(7)
    tableView:setPositionY(-15)
    self.btnHome:setPositionY(-15 + 7)
    
  --registerScriptHandler functions must be before the reloadData function
    tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
    tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
    tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
    tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
    tableView:registerScriptHandler(tableCellHighLight,CCTableView.kTableCellHighLight)
    tableView:registerScriptHandler(tableCellUnhighLight,CCTableView.kTableCellUnhighLight)
    --tableView:reloadData()
    tableView:setTouchPriority(-128)
    self:scrollByIndex(1)
    self:setIsScrollLock(false)
end

function GameBottomBar:setMenuArray(menuArray)
  self._menuArray = menuArray
  self._tableView:reloadData()
end

function GameBottomBar:getMenuArray()
  return self._menuArray
end

function GameBottomBar:getContentSize()
  return self.contentSizeNode:getContentSize()
end

------
--  Getter & Setter for
--      GameBottomBar._ScrollByIndex 
-----
function GameBottomBar:scrollByIndex(ScrollByIndex)
	self._ScrollByIndex = ScrollByIndex
	local targetX = 0
	local targetY =  self._tableView:getContainer():getPositionY()
	if ScrollByIndex >= 5 then
	   targetX = -(ScrollByIndex-4)*106
	end
	
  self._lockX = targetX

	transition.execute( self._tableView:getContainer(), CCMoveTo:create(0.15,ccp(targetX,targetY)))
	
	 local cellNum = table.getn(self._menuArray)
   for i = 0,cellNum  do
       self._tableView:updateCellAtIndex(i)
   end
end

function GameBottomBar:getScrollIndex()
  return self._ScrollByIndex
end

------
--  Getter & Setter for
--      GameBottomBar._IsScrollLock 
-----
function GameBottomBar:setIsScrollLock(IsScrollLock)
  self._IsScrollLock = IsScrollLock
    if self._tableView ~= nil then
        local targetX = 0
        local targetY =  self._tableView:getContainer():getPositionY()
        if self:getScrollIndex() > 6 then
           targetX = -(self:getScrollIndex()-6)*106
        end
        self._lockX = targetX
    end
end

function GameBottomBar:getIsScrollLock()
  return self._IsScrollLock
end


function GameBottomBar:setItemSelectedByIndex(index)
  for i=1,table.getn(self._allMenuItems) do
    if i == index and self._allMenuItems[i] ~= nil then
      self._allMenuItems[i]:setSelected(true)
      self._lastSelectedIdx = i -1
    elseif self._allMenuItems[i]~= nil then
      self._allMenuItems[i]:setSelected(false)
    end
  end
end

function GameBottomBar:onExit()
  self._tableView:unregisterAllScriptHandler()
  echo("GameBottomBar:onExit()")
  self._tableView = nil
end

function GameBottomBar:onCleanup()
  echo("GameBottomBar:onCleanup()")
end

function GameBottomBar:setBottomTouchEnabled(enabledTouch)
  self._touchEnabled = enabledTouch
  if enabledTouch == true then
     self:tipScenario()
  end
end

function GameBottomBar:tabControlOnClick(idx)
    if  self._touchEnabled == false then
        return
    end
   
    local pop = nil
    local controllerType = ControllerType.HOME_CONTROLLER 
    if idx == 0 then
        controllerType = ControllerType.HOME_CONTROLLER
    elseif idx == 1 then
        controllerType = ControllerType.SCENARIO_CONTROLLER
    elseif idx == 2 then
        if GameData:Instance():checkSystemOpenCondition(4, true) == false then 
          return 
        end  
        controllerType = ControllerType.EXPEDITION_CONTROLLER
    elseif idx == 3 then
        controllerType = ControllerType.ACTIVITY_CONTROLLER
    elseif idx == 4 then
        if GameData:Instance():checkSystemOpenCondition(16, true) == false then 
          return 
        end 
        controllerType = ControllerType.SHOP_CONTROLLER
    elseif idx == 5 then
        controllerType = ControllerType.CARD_ILLUSTRATED_CONTROLLER
    elseif idx == 6 then
        controllerType = ControllerType.SYSTEM_CONTROLLER
    elseif idx == 7 then
        --controllerType = ControllerType.GUILD_CONTROLLER
    elseif  idx == 8 then
        --if ChannelManager:getCurrentLoginChannel() == '360' then
            --local loginfun = function()
              --local registController = ControllerFactory:Instance():create(ControllerType.REGIST_CONTROLLER)
              --registController:enter()
              --registController:setSwitchFlag(true)
              --registController:logout()
            --end
            --local  pop = PopupView:createTextPopup(_tr("confirm_to_switch_account?"), function() return loginfun()  end)
            --GameData:Instance():getCurrentScene():addChildView(pop,100)
            --return
        --else
          --controllerType = ControllerType.ARENA_CONTROLLER
        --end
    end
    self:enterController(controllerType)
end

function GameBottomBar:enterController(controllerType)
  --self:closePlayerInfo()
  if GameData:Instance():getCurrentScene():getIsDroping() == true then
     return
  end
  
  if ControllerFactory:Instance():getCurrentControllerType() ==  controllerType then
     return
  end

  GameData:Instance():resetViewType()
  if  controllerType  ~= ControllerType.REGIST_CONTROLLER
  and controllerType  ~= ControllerType.BATTLE_CONTROLLER then
      -- play bgm
      _playBgm(BGM_MAIN)
  end
   
  local controller = ControllerFactory:Instance():create(controllerType)
  if controller ~= nil then
    controller:enter()
  end
  
  self:updateBottomTip(1)
end


--function GameBottomBar:closePlayerInfo()
--  GameData:Instance():getCurrentScene():getTopBlock():closePlayerInfoHandler()
--end

function GameBottomBar:tipScenario()
    
   local cell = self._tableView:cellAtIndex(0)
   if cell ~= nil then
        local menuItem = cell:getChildByTag(self.UNIT_TAG)
        if menuItem ~= nil then
          menuItem:stopAllActions()
          menuItem:setScale(1.0)
          
          local anim_node = cell:getChildByTag(6789)
          if anim_node == nil then
            anim_node = display.newNode()
            anim_node:setTag(6789)
            cell:addChild(anim_node)
          else
            anim_node:removeAllChildrenWithCleanup(true)
          end
          
          
          if  ControllerFactory:Instance():getCurrentControllerType() ~= ControllerType.SCENARIO_CONTROLLER 
          and GameData:Instance():checkSystemOpenCondition(20, false) == false 
          and Guide:Instance():getGuideLayer() == nil
          then
            --[[local strength = 5.0
            local times = 2
            local array = CCArray:create()
            local s_duration = 0.6/(times * 2)
            for i = 1, times do
              array:addObject(CCScaleTo:create(s_duration,1.15,1.10))
              array:addObject(CCScaleTo:create(s_duration,1.0,1.0))
            end
            array:addObject(CCDelayTime:create(3.0))
            local action = CCSequence:create(array)
            menuItem:runAction(CCRepeatForever:create(action))
            ]]
            
            
            local guideAnimation,offsetX,offsetY,duration = _res(5020133)
            guideAnimation:setScale(0.75)
            guideAnimation:setPosition(ccp(offsetX + 55,offsetY + 65))
            anim_node:addChild(guideAnimation)
            guideAnimation:getAnimation():play("default")
          end
        else
           printf("GameBottomBar:tipScenario(),get menuItem failed!")
        end
    else
       printf("GameBottomBar:tipScenario(),get cell failed!")
    end

end



function GameBottomBar:getSize()
  return self.contentSize:getContentSize()
end

function GameBottomBar:getTipStateForIndex(idx)
  local isTipVisible = false 

  if idx == 1 then --battle
    
    --[[for i = 1, Scenario:Instance():getMaxChapterId() do
      local chapter = Scenario:Instance():getChapterById(i)
      local stagesToFight = Scenario:Instance():getEliteStagesToHookByChapter(chapter)
      if #stagesToFight > 0
      and ControllerFactory:Instance():getCurrentControllerType() ~= ControllerType.SCENARIO_CONTROLLER
      then
        isTipVisible = true
        break
      end
    end]]
    
    
  elseif idx == 2 then --expedition
    if  GameData:Instance():getExpeditionInstance() ~= nil then
       if GameData:Instance():getExpeditionInstance():getHasNewReport()== true
       and ControllerFactory:Instance():getCurrentControllerType() ~= ControllerType.EXPEDITION_CONTROLLER
       then
          isTipVisible = true
       end
    end
  elseif idx == 3 then --activity
    local flag = Activity:instance():getHasNewTip()
    if flag == true  then 
      isTipVisible = true
    end
  elseif idx == 4 then --shop
	  if Shop:instance():getTipsFlag(ShopCurViewType.JiShi) == true then 
		  isTipVisible = true
	  end
  elseif idx == 5 then --illustrated
  elseif idx == 6 then --system
  end

  return isTipVisible
end

function GameBottomBar:updateBottomTip(index)
  echo("updateBottomTip")

  local function updateTip(i)
    local cell = self._tableView:cellAtIndex(i-1)
    if cell ~= nil then
      local tabItem = cell:getChildByTag(self.UNIT_TAG)
      if tabItem ~= nil then
        local isTipShow = self:getTipStateForIndex(i)
        echo("getTipStateForIndex:", i, isTipShow)
        tabItem:setTipVisible(isTipShow)
      end
    end
  end

  if index == nil then --update all
    for i = 1, #self._menuArray do
      updateTip(i)
    end
  else 
    if index <= #self._menuArray then 
      updateTip(index)
    end 
  end 
end

return GameBottomBar  