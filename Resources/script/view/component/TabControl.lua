require("view.BaseView")
require("view.component.TabControlItem")
TabControl = class("TabControl",BaseView)

function TabControl:ctor()
  TabControl.super.ctor(self)
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("contentSizeNode","CCNode")
  pkg:addProperty("menuContainer","CCNode")
  pkg:addProperty("spriteLeft","CCSprite")
  pkg:addProperty("spriteRight","CCSprite")
  local layer,owner = ccbHelper.load("TabControl.ccbi","TabControlCCB","CCLayer",pkg)
  self:addChild(layer)
  self.spriteRight:setVisible(false)
  self.spriteLeft:setVisible(false)
  self._lastSelectedIdx = 0
  self._menuArray = {}
  self._allMenuItems = {}
  --self._tipFlag = {}
  
  self._cellWidth = 135
  self._cellHeight = 140

  local function scrollViewDidScroll(tableView)
    if tableView ~= nil then
      if self:getIsScrollLock() == true then
         if self._lockX ~= nil then
            tableView:getContainer():setPositionX(self._lockX)
         end
         return
      end
          
      if tableView:isDragging() == false then         
        local item =  self._allMenuItems[ self._lastSelectedIdx+1] 
        if item ~= nil then
          item:setSelected(true)
        end
      end 

      if #self._menuArray <= 4 then
         return
      end
      
      if tableView:getContainer():getPositionX() >= 0 then
         self.spriteLeft:setVisible(false)
      else
         self.spriteLeft:setVisible(true)
      end
      if tableView:getContainer():getPositionX() <= tableView:minContainerOffset().x then
         self.spriteRight:setVisible(false)
      else
         self.spriteRight:setVisible(true)
      end
    end
  end
  
  local function tableCellTouched(table,cell)
    print("cell touched at index: " .. cell:getIdx())
    if self._lastSelectedIdx == cell:getIdx() then
      return
    end
    
    self:setIsScrollLock(false)

    -- local lastcell = table:cellAtIndex(self._lastSelectedIdx)
    --local item =  self._allMenuItems[ self._lastSelectedIdx+1]   --tolua.cast(lastcell:getChildByTag(456),TabControlItem)
    
    --local menuItem  =  self._allMenuItems[cell:getIdx() +1]local menuItem  =  self._allMenuItems[cell:getIdx() +1] --tolua.cast(cell:getChildByTag(456),TabControlItem)
    
    local result = self:getDelegate():tabControlOnClick(cell:getIdx()) 
    if result == false then
      echo(" open menu fail...")
      local item = self._allMenuItems[ self._lastSelectedIdx+1]
      if item ~= nil then
        item:setSelected(true) --re-highlight last menu item
      end
      
      local menuItem  =  self._allMenuItems[cell:getIdx() +1]
      if menuItem ~= nil then
        menuItem:setSelected(false)
      end
      return
    end
    
    local item = self._allMenuItems[ self._lastSelectedIdx+1]
	  if item ~= nil then
		  item:setSelected(false)
	  end
      
    
    local menuItem  =  self._allMenuItems[cell:getIdx() +1]
    if menuItem ~= nil then
        menuItem:setSelected(true)
    end
    
    self._lastSelectedIdx = cell:getIdx()
  end
  
  local function cellSizeForTable(table,idx) 
      local size =self._menuArray[idx+1][3]
      if (size ~= nil) then
        return size.height, size.width
      end
      return self._cellHeight,self._cellWidth
  end
  
   local function tableCellHighLight(table, cell)
    local idx = cell:getIdx()
    local item = self._allMenuItems[idx+1]
    
    for key, m_item in pairs(self._allMenuItems) do
        if m_item ~= item then
           m_item:setSelected(false)
        end
    end
    
    if item ~= nil then
      item:setSelected(true)
    end
   
  end 

  local function tableCellUnhighLight(table, cell)
    local idx = cell:getIdx()
    
    if idx == self._lastSelectedIdx then
       return
    end
    
    local item = self._allMenuItems[idx+1]
    if item ~= nil then
      item:setSelected(false)
    end
  end
  
  local function tableRecycleHandler(tableView,cell)
    self._allMenuItems[cell:getIdx()+1] = nil
  end
  
  local function tableCellAtIndex(tableview, idx)
	local menuItemCfg = self._menuArray[idx+1]
    local nor = display.newSprite(menuItemCfg[1])
    nor:setAnchorPoint(CCPointMake(0,0))
    nor:setPosition(CCPointMake(0, 0))
        
    local highlighted = display.newSprite(menuItemCfg[2])
    highlighted:setAnchorPoint(CCPointMake(0,0))
    highlighted:setPosition(CCPointMake(0, 0))
   
    local hitImage = nil
	
  	if(menuItemCfg[4]) then
  		hitImage = display.newSprite(menuItemCfg[4])
  		highlighted:setAnchorPoint(CCPointMake(0,0))
  		highlighted:setPosition(menuItemCfg[5])
  	end
  	
    local cell = tableview:dequeueCell()
    if nil == cell then
      cell = CCTableViewCell:new()
    else
      cell:removeAllChildrenWithCleanup(true)
    end
    
   
    local menuItem = TabControlItem.new(menuItemCfg)
    menuItem:setHighlightedTexture(highlighted)
    menuItem:setNormalTexture(nor,hitImage)
    menuItem:setNewTipImgVisible(menuItemCfg[8] or false)
    menuItem:setTipVisible(menuItemCfg[6]) --self._tipFlag[idx+1])    
    cell:addChild(menuItem)
    menuItem:setSelected(false) 
    cell:setIdx(idx)
    self._allMenuItems[idx+1] = nil
	  self._allMenuItems[idx+1] = menuItem
	  if self._lastSelectedIdx == cell:getIdx() then
        menuItem:setSelected(true) 
    end
    return cell
   end
  
   local function numberOfCellsInTableView(val)
      local length = table.getn(self._menuArray)
     return length
   end

  local size = CCSizeMake(self.menuContainer:getContentSize().width, self.menuContainer:getContentSize().height+8)
  local tableView = CCTableView:create(size)
  tableView:setDirection(kCCScrollViewDirectionHorizontal)
  self.menuContainer:addChild(tableView)
--registerScriptHandler functions must be before the reloadData function
  tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  tableView:registerScriptHandler(tableCellHighLight,CCTableView.kTableCellHighLight)
  tableView:registerScriptHandler(tableCellUnhighLight,CCTableView.kTableCellUnhighLight)
  tableView:registerScriptHandler(tableRecycleHandler,CCTableView.kTableCellWillRecycle)
  
  --tableView:reloadData()
  tableView:setTouchPriority(-2)
  self._tableView = tableView
  self:setIsScrollLock(false)
end 

-- hitInfo {img,position,show}
function TabControl:setMenuArray(menuArray,hitInfo)
  self._allMenuItems = {}
  local _menuArray={}
  for n,v in ipairs(menuArray) do
	local group_value = {
		img_normal = v[1],
		img_highlight= v[2],
		cell_size= v[3],
		img_tip= v[4] or hitInfo and hitInfo.img,
		tip_position= v[5] or hitInfo and hitInfo.position or ccp(0,0),
		show_tip= v[6] or hitInfo and hitInfo.show or false
	}
	_menuArray[n] = {
		group_value.img_normal,
		group_value.img_highlight,
		group_value.cell_size,
		group_value.img_tip,
		group_value.tip_position,
		group_value.show_tip
	}	
  end
  self._menuArray = _menuArray
  
  if table.getn(self._menuArray) > 4 then
     self.spriteRight:setVisible(true)
     self.spriteLeft:setVisible(true)
  else
     self.spriteRight:setVisible(false)
     self.spriteLeft:setVisible(false)
  end
  self._tableView:reloadData()

  --init tip invisible by default
  --for i=1, table.getn(menuArray) do 
  --  self._tipFlag[i] = _menuArray[i][6] --false
  --end
end

function TabControl:getMenuArray()
  return self._menuArray
end

function TabControl:getContentSize()
  return self.contentSizeNode:getContentSize()
end

function TabControl:setItemSelectedByIndex(index, offsetX)
  if index > 4 and index <= table.getn(self._menuArray) then 
    self._tableView:setContentOffset(ccp(-self._cellWidth*(index-4), 0))
  end

  if offsetX ~= nil then 
    self._tableView:setContentOffset(ccp(offsetX, 0))
  end

	for i=1,table.getn(self._allMenuItems) do
		if i == index and self._allMenuItems[i] ~= nil then
			self._allMenuItems[i]:setSelected(true)
			self._lastSelectedIdx = i -1
		elseif self._allMenuItems[i]~= nil then
			self._allMenuItems[i]:setSelected(false)
		end
	end
end

function TabControl:onExit()
  self._tableView:unregisterAllScriptHandler()
  -- echo("TabControl:onExint()")
  self._tableView = nil
end

function TabControl:onCleanup()
  echo("TabControl:onCleanup()")
end

function TabControl:getItemByIndex(index)
  local item = nil 
  if index > 0 and index <= table.getn(self._allMenuItems) then 
    item = self._allMenuItems[index]
  end 

  return item
end 

function TabControl:getMenuItems()
	return self._allMenuItems
end

function TabControl:setTipImgVisible(index, isVisible)
  --self._tipFlag[index] = isVisible
  self._menuArray[index][6] = isVisible
  local tabItem = self:getItemByIndex(index)
  if tabItem ~= nil then
    local tip = tabItem:getTipImg()
    if tip ~= nil then 
      tip:setVisible(isVisible)
    end 
  end 
end

function TabControl:setNewTipImgVisible(index, isVisible)
  self._menuArray[index][8] = isVisible
  local tabItem = self:getItemByIndex(index)
  if tabItem ~= nil then
    local tip = tabItem:getNewTipImg()
    if tip ~= nil then 
      tip:setVisible(isVisible)
    end 
  end 
end

function TabControl:getTableView()
	return self._tableView
end

function TabControl:setContentOffsetX(offsetX)
  self._tableView:setContentOffset(ccp(offsetX, 0))
end

function TabControl:getContentOffsetX()
  return self._tableView:getContentOffset().x
end

------
--  Getter & Setter for
--      GameBottomBar._IsScrollLock 
-----
function TabControl:setIsScrollLock(IsScrollLock)
  self._IsScrollLock = IsScrollLock
    if self._tableView ~= nil then
        local targetX = self._tableView:getContainer():getPositionX()
        --local targetY =  self._tableView:getContainer():getPositionY()
        self._lockX = targetX
    end
end

function TabControl:getIsScrollLock()
  return self._IsScrollLock
end

return TabControl