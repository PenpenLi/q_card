

require("view.shop.component.VipInfoItem")

VipInfoView = class("VipInfoView", BaseView)



function VipInfoView:ctor()
  VipInfoView.super.ctor(self)

  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("closeCallback",VipInfoView.closeCallback)
  pkg:addFunc("buyCallback",VipInfoView.buyCallback)

  pkg:addProperty("node_pop","CCNode")
  pkg:addProperty("node_container","CCNode")
  pkg:addProperty("bn_close","CCControlButton")
  pkg:addProperty("bn_buy","CCControlButton")
  pkg:addProperty("sprite9_bg","CCScale9Sprite")

  local layer,owner = ccbHelper.load("VipInfoView.ccbi","VipInfoViewCCB","CCLayer",pkg)
  self:addChild(layer)

  self:init()
end

function VipInfoView:createVipPopView()
  local view = VipInfoView.new()
  view.node_pop:setScale(0.2)
  view.node_pop:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6) )

  return view
end 

function VipInfoView:onEnter()
  echo("---VipInfoView:onEnter---")
  self:showInfoList()
end

-- function VipInfoView:onExit()
--   echo("---VipInfoView:onExit---")
-- end


function VipInfoView:checkTouchPosition(x, y)
    local size = self.sprite9_bg:getContentSize()
    local pos = self.sprite9_bg:convertToNodeSpace(ccp(x,y))
    if pos.x < 0 or pos.x > size.width or pos.y < 0 or pos.y > size.height then 
      -- self:close()
      return true
    end
  return false
end 

function VipInfoView:init()
  self.priority = -300

  self.bn_close:setTouchPriority(self.priority-1)
  self.bn_buy:setTouchPriority(self.priority-1)

  --register touch
  self:addTouchEventListener(function(event, x, y)

                                if event == "began" then
                                  self.isOutViewPre = self:checkTouchPosition(x, y)
                                  return true
                                elseif event == "ended" then
                                  local isOutView = self:checkTouchPosition(x, y)
                                  if isOutView == true and self.isOutViewPre == true then 
                                    self:closeCallback()
                                  end
                                end
                            end,
              false, self.priority, true)
  self:setTouchEnabled(true)


  --init vipinfo data
  self.infoArray = {}
  for k, v in pairs(AllConfig.vipprerogative) do
    local item = {title = v.title, desc = v.directions}
    table.insert(self.infoArray, item)
  end
end 


function VipInfoView:closeCallback()
  echo(" close vip view")
  self:removeFromParentAndCleanup(true)
end

function VipInfoView:buyCallback()
  echo(" buyCallback")
  self:closeCallback()
  -- Pay:Instance():autoBuyVipCard()
end


function VipInfoView:gotoViewByVipInfoIdx(idx)
  echo("VipInfoView:gotoViewByVipInfoIdx, idx=", idx)
  local entryFlag = true

  if idx == 0 then --战役
    local controller = ControllerFactory:Instance():create(ControllerType.SCENARIO_CONTROLLER)
    controller:enter()
    
  elseif idx == 1 then --vip成就
	  local controller = ControllerFactory:Instance():create(ControllerType.ACHIEVEMENT_CONTROLLER)
	  controller:enter(6, ViewType.vip_info)

  elseif idx == 2 then --商城集市
    if GameData:Instance():checkSystemOpenCondition(13, true) == false then 
      return 
    end 
    if ControllerFactory:Instance():getCurrentControllerType() == ControllerType.SHOP_CONTROLLER then

  	  local baseView = self:getDelegate()
  	  baseView:tabControlOnClick(ShopCurViewType.JiShi-1)
  	  baseView:getTabMenu():setItemSelectedByIndex(ShopCurViewType.JiShi)
    else
      local controller = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
      controller:enter(ShopCurViewType.JiShi)
    end

  elseif idx == 3 then --商场特惠
    if GameData:Instance():checkSystemOpenCondition(14, true) == false then 
      return 
    end 

    if ControllerFactory:Instance():getCurrentControllerType() == ControllerType.SHOP_CONTROLLER then
      local baseView = self:getDelegate()
      baseView:tabControlOnClick(ShopCurViewType.TeHui-1)
      baseView:getTabMenu():setItemSelectedByIndex(ShopCurViewType.TeHui)
    else
  	  local controller = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
  	  controller:enter(ShopCurViewType.TeHui)
    end
  elseif idx == 4 then --好友
    if GameData:Instance():checkSystemOpenCondition(11, true) == false then 
      return 
    end 
    local controller =  ControllerFactory:Instance():create(ControllerType.FRIEND_CONTROLLER)
    controller:enter(ViewType.vip_info)

  elseif idx == 5 or idx == 6 then --典藏
    if GameData:Instance():checkSystemOpenCondition(15, true) == false then 
      return 
    end 

    if ControllerFactory:Instance():getCurrentControllerType() == ControllerType.SHOP_CONTROLLER then
      local baseView = self:getDelegate()
      baseView:tabControlOnClick(ShopCurViewType.DianCang-1)
      baseView:getTabMenu():setItemSelectedByIndex(ShopCurViewType.DianCang)
    else
  	  local controller = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
  	  controller:enter(ShopCurViewType.DianCang)
    end

  elseif idx == 7 then --grown plan
    Activity:instance():entryActView(ActMenu.GROW_PLAN, false)

  elseif idx == 8 then --Vip Gift
    Activity:instance():entryActView(ActMenu.VIP_SIGNIN, false)

  elseif idx == 9 then --Boss
    if GameData:Instance():checkSystemOpenCondition(5, true) == false then 
      return 
    end 
    Activity:instance():entryActView(ActMenu.BOSS, false)

  elseif idx == 10 then --聚宝盆
    Activity:instance():entryActView(ActMenu.MONEY_TREE, false)

  elseif idx == 11 then --精英副本
    local controller = ControllerFactory:Instance():create(ControllerType.SCENARIO_CONTROLLER)
    controller:enter()
  elseif idx == 12 then --活动副本
    local controller = ControllerFactory:Instance():create(ControllerType.ACTIVITY_STAGE_CONTROLLER)
    controller:enter()  
  else 
    echo("invalid index for vipinfo")  
  end

  if entryFlag == true then 
    self:closeCallback()
  end  
end


function VipInfoView:showInfoList()

  local function cellSizeForTable(tableview,idx)
    return self.CellHeight,self.CellWidth
  end
  
  local function tableCellAtIndex(tableview, idx)
    echo("cellAtIndex = "..idx, self:getDelegate())
    local cell = tableview:dequeueCell()
    if nil == cell then
      cell = CCTableViewCell:new()
    else
      cell:removeAllChildrenWithCleanup(true)
    end

    local node = VipInfoItem.new(idx%2)
    node:setDelegate(self)
    node:setIdx(idx)
    node:setTitle(self.infoArray[idx+1].title)
    node:setDescString(self.infoArray[idx+1].desc)
    node:setBtnPriority(self.priority-1)
    cell:addChild(node)
    
    return cell
  end
  

  local function numberOfCellsInTableView(tableview)
    return self.totalCells
  end


  local size = self.node_container:getContentSize()
  self.CellWidth = size.width 
  self.CellHeight = 120
  self.totalCells = table.getn(self.infoArray)

  echo("remove old tableview")
  self.node_container:removeAllChildrenWithCleanup(true)

  local tableView = CCTableView:create(size)
  tableView:setDirection(kCCScrollViewDirectionVertical)
  tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  self.node_container:addChild(tableView)
  tableView:setTouchPriority(self.priority-1)

  --tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  --tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)

  tableView:reloadData()
end

