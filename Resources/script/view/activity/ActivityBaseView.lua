
require("view.BaseView")
require("view.component.TipPic")


ActivityBaseView = class("ActivityBaseView", BaseView)

function ActivityBaseView:ctor(viewIndex)

  ActivityBaseView.super.ctor(self)

  --1. load levelup view ccbi
  local pkg = ccbRegisterPkg.new(self)

  pkg:addProperty("node_menu","CCNode")
  pkg:addProperty("node_menuContainer","CCNode")

  local layer,owner = ccbHelper.load("ActivityBaseView.ccbi","ActivityBaseViewCCB","CCLayer",pkg)
  self:addChild(layer)

  self.node_menu:setPositionY(display.height-self.node_menu:getContentSize().height)

  self:init(viewIndex)
end


function ActivityBaseView:onEnter()
  echo("=== ActivityBaseView:onEnter=== ")
  self:updateTopTip(nil)
  self:showTopMenus()
  _executeNewBird()
end 

function ActivityBaseView:onExit()
  echo("=== ActivityBaseView:onExit=== ")
  for i=1, self.totalMenus do 
    self._highlightBoxArray[i]:release()
  end
end 


function ActivityBaseView:init(viewIndex)

  self.menusArray = Activity:instance():getMenusArray()

  self.menuWidth = 110
  self.menuHeight = 100
  self.totalMenus = #self.menusArray


  --init 
  self._preSelectedIdx = 0
  if viewIndex ~= nil and viewIndex > 0 then 
    for k, v in pairs(self.menusArray) do 
      if viewIndex == v[1] then 
        self._preSelectedIdx = k-1
        break 
      end 
    end 
  end 

  self._highlightBoxArray = {}

  for i=1, self.totalMenus do 
    local highlightBox = CCSprite:createWithSpriteFrameName("xuanzhong2.png")
    highlightBox:retain()
    self._highlightBoxArray[i] = highlightBox
  end
end 

--idx: >= 0
function ActivityBaseView:setHighlighMenu(idx)

  self:setListScrollEnable(true)

  if self._preSelectedIdx ~= nil and self._preSelectedIdx ~= idx then 
    local box = self._highlightBoxArray[self._preSelectedIdx+1]
    if box ~= nil then 
      box:setVisible(false)
    end   

    local menuIdx = self.menusArray[idx+1][1]
    echo("==== touch menu:", menuIdx)
    local result = self:getDelegate():enterViewByIndex(menuIdx) 
    if result == false then
      echo(" open menu fail...")
      if box ~= nil then
        box:setVisible(true) --re-highlight last menu item
      end 
      return
    end

    local curBox = self._highlightBoxArray[idx+1]
    if curBox ~= nil then 
      curBox:setVisible(true)
    end 
    
    _executeNewBird()
  end 

  self._preSelectedIdx = idx
end 

function ActivityBaseView:getHighlighMenu()
  return self._preSelectedIdx
end 




function ActivityBaseView:showTopMenus()

  local function scrollViewDidScroll(view)
    if self:getListScrollEnable() == false then 
      echo("===== disable scroll... ")
      self.tableView:getContainer():setPositionX(self._lastX)
    end
  end

  local function tableCellTouched(tableview,cell)
    local idx = cell:getIdx()
    if self._preSelectedIdx == idx then
      return
    end
    self:setHighlighMenu(idx)
  end
  
  local function cellSizeForTable(tableview,idx)
    return self.menuHeight, self.menuWidth
  end
  
  local function numberOfCellsInTableView(tableview)
    return self.totalMenus
  end

  local function tableCellAtIndex(tableview, idx)
    -- echo("cell index= ", idx)
    local cell = tableview:dequeueCell()
    if cell == nil then 
      cell = CCTableViewCell:new()
    else 
      cell:removeAllChildrenWithCleanup(true)
    end
    cell:setContentSize(CCSizeMake(self.menuWidth,self.menuHeight))
    
    if idx == 1 then
      _registNewBirdComponent(116002,cell)
    end

    local centerPos = ccp(self.menuWidth/2, 50)
    local bg = CCSprite:createWithSpriteFrameName(self.menusArray[idx+1][2])
    bg:setPosition(centerPos)
    cell:addChild(bg)

    local highlightBox = self._highlightBoxArray[idx+1]
    highlightBox:removeFromParentAndCleanup(false)
    highlightBox:setPosition(centerPos)
    cell:addChild(highlightBox)
    if self:getHighlighMenu() == idx then 
      highlightBox:setVisible(true)
    else 
      highlightBox:setVisible(false)
    end

    local bgSize = bg:getContentSize()

    if self.menusArray[idx+1][3] ~= nil then 
      local limitImg = CCSprite:createWithSpriteFrameName(self.menusArray[idx+1][3])
      if limitImg ~= nil then 
        limitImg:setPosition(ccp(centerPos.x-bgSize.width/2+14, centerPos.y+bgSize.height/2-12))
        cell:addChild(limitImg)
      end
    end 

    --tip pic
    local menuType = self.menusArray[idx+1][1]
    local tipImg = TipPic.new()
    tipImg:setPosition(ccpAdd(centerPos, ccp(bgSize.width/2-5, bgSize.height/2-5)))
    tipImg:setVisible(self:getTipState(menuType)) --default invisible
    tipImg:setTag(100)
    cell:addChild(tipImg)
    
    return cell
  end
  
  self.node_menuContainer:removeAllChildrenWithCleanup(true)

  self.tableView = CCTableView:create(self.node_menuContainer:getContentSize())
  self.tableView:setDirection(kCCScrollViewDirectionHorizontal)
  self.node_menuContainer:addChild(self.tableView)

  self.tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  self.tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  self.tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  self.tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  self.tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  self.tableView:reloadData() 

  if self:getHighlighMenu() > 4 then 
    self.tableView:setContentOffset(ccp(-self.menuWidth*(self:getHighlighMenu()-4), 0))
  end 
end


function ActivityBaseView:getContentSize()
  return self.node_menu:getContentSize()
end

function ActivityBaseView:getMenuContainer()
  return self.node_menuContainer
end 

function ActivityBaseView:scrollToIndex(index)
  if index > 5 then 
    local x = -(index-5)*self.menuWidth
    self.tableView:setContentOffset(ccp(x, 0))
  end
end

function ActivityBaseView:getTipState(menuType)
  echo("===tip:", menuType, self._tipState[menuType])
  return self._tipState[menuType] 
end

function ActivityBaseView:updateTopTip(menuType)
  self._tipState = {}

  local flag3 = Activity:instance():getIsAlreadySigned()

  self._tipState[ActMenu.ARMY] = Activity:instance():getIsCanEatPatty()
  self._tipState[ActMenu.LEVELUP_BONUS] = Activity:instance():getHasBonusForLevelup()
  self._tipState[ActMenu.DAILY_SIGNIN] = not flag3
  self._tipState[ActMenu.BOSS] = Activity:instance():getBossTipFlag() --boss
  self._tipState[ActMenu.GROW_PLAN] = Activity:instance():getCanFetchGrowBonus()
  self._tipState[ActMenu.VIP_SIGNIN] = Activity:instance():getCanFetchVipGif()
  self._tipState[ActMenu.MONEY_TREE] = false --money tree
  self._tipState[ActMenu.REBATE_ONE] = false --rebate
  self._tipState[ActMenu.REBATE_TEN] = false --rebate
  self._tipState[ActMenu.EXCHANGE] = false --exchange
  self._tipState[ActMenu.ZHONG_QIU] = false --exchange
  self._tipState[ActMenu.CHARGE_REBATE] = false --充值送张飞
  self._tipState[ActMenu.ARENA] = false --武斗大会
  self._tipState[ActMenu.VIP_PRIVILEGE] = false --VIP特权
  self._tipState[ActMenu.CHARGE_BONUS] = false --累计充值

  if self.tableView ~= nil then 
    if menuType ~= nil then 
      local index = Activity:instance():getArrayIndexByMenuId(menuType)
      if index ~= nil then 
        self.tableView:updateCellAtIndex(index-1)
      end 
    else 
      self.tableView:reloadData() 
    end
  end 
end 

function ActivityBaseView:setListScrollEnable(isEnable)
  self._lastX = 0
  if isEnable == false and self.tableView ~= nil then
    self._lastX = self.tableView:getContainer():getPositionX()
  end
  self._listScrollEnable = isEnable
end 

function ActivityBaseView:getListScrollEnable()
  return self._listScrollEnable
end 

