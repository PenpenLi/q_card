
require("view.BaseView")
require("view.component.TabControlItem")

TabControlEx = class("TabControlEx",BaseView)


--bgSize, menuItemWidth, priority : 菜单控件大小, 默认菜单宽度, 控件touch优先级
function TabControlEx:ctor(bgSize, menuItemWidth, priority)
  TabControlEx.super.ctor(self)

  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("menuContainer","CCNode")
  pkg:addProperty("spriteLeft","CCSprite")
  pkg:addProperty("spriteRight","CCSprite")
  pkg:addProperty("sprite9_bg","CCScale9Sprite")
  
  local layer,owner = ccbHelper.load("TabControlEx.ccbi","TabControlExCCB","CCLayer",pkg)
  self:addChild(layer)

  self._lastSelectedIdx = 0
  self._menuArray = {}
  self._allMenuItems = {}

  self._priority = priority or -200 

  --rejust size and pos 
  bgSize = bgSize or CCSizeMake(630, 74)

  self.sprite9_bg:setContentSize(bgSize) 
  local arrowSize = self.spriteLeft:getContentSize()
  self.spriteLeft:setPosition(ccp(arrowSize.width/2+4, bgSize.height/2))
  self.spriteRight:setPosition(ccp(bgSize.width-arrowSize.width/2-4, bgSize.height/2))
  self.menuContainer:setContentSize(CCSizeMake(bgSize.width-arrowSize.width*2-16, bgSize.height-4))
  self.menuContainer:setPosition(ccp(arrowSize.width+8, 2))

  self._cellWidth = menuItemWidth or 135
  self._cellHeight = self.menuContainer:getContentSize().height  
end 

function TabControlEx:setBgVisible(isVisible)
  self.sprite9_bg:setVisible(isVisible)
end 

function TabControlEx:showMenuList()
  
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
      return self._cellHeight, self._cellWidth
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
        
    local sel = display.newSprite(menuItemCfg[2])
    sel:setAnchorPoint(CCPointMake(0,0))
    sel:setPosition(CCPointMake(0, 0))
   
    local hitImage = nil
    if(menuItemCfg[4]) then
      hitImage = display.newSprite(menuItemCfg[4])
      sel:setAnchorPoint(CCPointMake(0,0))
      sel:setPosition(menuItemCfg[5])
    end
    
    local cell = tableview:dequeueCell()
    if nil == cell then
      cell = CCTableViewCell:new()
    else
      cell:removeAllChildrenWithCleanup(true)
    end
    
    local h, w = cellSizeForTable(tableview, idx)
    local menuItem = TabControlItem.new(menuItemCfg)
    menuItem:setHighlightedTexture(sel)
    menuItem:setNormalTexture(nor,hitImage)
    menuItem:setNewTipImgVisible(menuItemCfg[8] or false)
    menuItem:setTipVisible(menuItemCfg[6]) 
    menuItem:setSelected(self._lastSelectedIdx == idx) 
    menuItem:setPositionY((h-math.min(nor:getContentSize().height, h))/2)
    cell:addChild(menuItem)    
    cell:setIdx(idx)
    self._allMenuItems[idx+1] = nil
    self._allMenuItems[idx+1] = menuItem

    return cell
   end
  
   local function numberOfCellsInTableView(val)
     return table.getn(self._menuArray)
   end

   self.menuContainer:removeAllChildrenWithCleanup(true)

  local size = CCSizeMake(self.menuContainer:getContentSize().width, self.menuContainer:getContentSize().height+8)
  local tableView = CCTableView:create(size)
  tableView:setDirection(kCCScrollViewDirectionHorizontal)
  self.menuContainer:addChild(tableView)

  tableView:setTouchPriority(self._priority)
  tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  tableView:registerScriptHandler(tableCellHighLight,CCTableView.kTableCellHighLight)
  tableView:registerScriptHandler(tableCellUnhighLight,CCTableView.kTableCellUnhighLight)
  tableView:registerScriptHandler(tableRecycleHandler,CCTableView.kTableCellWillRecycle)
  
  tableView:reloadData()
  self._tableView = tableView
  self:setIsScrollLock(false)
end 

function TabControlEx:setMenuArray(menuArray,hitInfo)
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
  
  self._allMenuItems = {}
  self:showMenuList()
end

function TabControlEx:getMenuArray()
  return self._menuArray
end

function TabControlEx:getContentSize()
  return self.sprite9_bg:getContentSize()
end

function TabControlEx:setItemSelectedByIndex(index, offsetX)
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

function TabControlEx:onExit()
  self._tableView:unregisterAllScriptHandler()
  self._tableView = nil
end

function TabControlEx:onCleanup()
  echo("TabControlEx:onCleanup()")
end

function TabControlEx:getItemByIndex(index)
  local item = nil 
  if index > 0 and index <= table.getn(self._allMenuItems) then 
    item = self._allMenuItems[index]
  end 

  return item
end 

function TabControlEx:getMenuItems()
  return self._allMenuItems
end

function TabControlEx:setTipImgVisible(index, isVisible)
  self._menuArray[index][6] = isVisible
  local tabItem = self:getItemByIndex(index)
  if tabItem ~= nil then
    local tip = tabItem:getTipImg()
    if tip ~= nil then 
      tip:setVisible(isVisible)
    end 
  end 
end

function TabControlEx:setNewTipImgVisible(index, isVisible)
  self._menuArray[index][8] = isVisible
  local tabItem = self:getItemByIndex(index)
  if tabItem ~= nil then
    local tip = tabItem:getNewTipImg()
    if tip ~= nil then 
      tip:setVisible(isVisible)
    end 
  end 
end

function TabControlEx:getTableView()
  return self._tableView
end

function TabControlEx:setContentOffsetX(offsetX)
  self._tableView:setContentOffset(ccp(offsetX, 0))
end

function TabControlEx:getContentOffsetX()
  return self._tableView:getContentOffset().x
end

function TabControlEx:setIsScrollLock(IsScrollLock)
  self._IsScrollLock = IsScrollLock
  if self._tableView ~= nil then
    local targetX = self._tableView:getContainer():getPositionX()
    self._lockX = targetX
  end
end

function TabControlEx:getIsScrollLock()
  return self._IsScrollLock
end

return TabControlEx