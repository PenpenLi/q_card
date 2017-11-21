require("view.BaseView")
require("view.component.Loading")
require("view.component.PopupView")
require("view.activity.ActivityGrowListItem")


ActivityGrowView = class("ActivityGrowView", BaseView)


function ActivityGrowView:ctor()

  ActivityGrowView.super.ctor(self)

  --1. load levelup view ccbi
  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("rechargeCallback",ActivityGrowView.rechargeCallback)
  pkg:addFunc("buyCallback",ActivityGrowView.buyCallback)
  pkg:addProperty("node_img","CCNode")
  pkg:addProperty("node_listContainer","CCNode")
  pkg:addProperty("bn_buy","CCControlButton")
  pkg:addProperty("sprite_title","CCSprite")

  local layer,owner = ccbHelper.load("ActivityGrowView.ccbi","ActivityGrowViewCCB","CCLayer",pkg)
  self:addChild(layer)
end

function ActivityGrowView:init()
  echo("---ActivityGrowView:init---")

  net.registMsgCallback(PbMsgId.AskForVipRebateResult, self, ActivityGrowView.fetchResult)
  net.registMsgCallback(PbMsgId.BuyVipTicketResultS2C, self, ActivityGrowView.buyResult)

  if Activity:instance():getActivityLeftTime(ACI_ID_GROW_PLAN) > 0  then 
    local title = CCSprite:create("img/activity/chengzhangjihua_1.png")
    self.sprite_title:setTexture(title:getTexture())
  end 
  
  local planFlag = GameData:Instance():getCurrentPlayer():getGrowPlanBuyFlag()
  if planFlag > 0 then 
    self.bn_buy:setEnabled(false)
  else 
    self.bn_buy:setEnabled(true)
  end

  --init list size
  local topHeight = self:getDelegate():getTopMenuSize().height
  local bottomHeight = self:getDelegate():getScene():getBottomContentSize().height

  local imgHeight = self.node_img:getContentSize().height
  self.node_img:setPositionY(display.height-topHeight-imgHeight)

  --for node list position
  self.node_listContainer:setContentSize(CCSizeMake(640,  display.height-topHeight-imgHeight-bottomHeight))
  self.node_listContainer:setPosition(ccp((display.width-640)/2 ,bottomHeight))
end

function ActivityGrowView:onEnter()
  echo("---ActivityGrowView:onEnter---")
  self:init()

  self.highlightIndex = 0
  self.plansArray = Activity:instance():getAllGrowthPlans()
  self:showPlanList(self.plansArray)
end

function ActivityGrowView:onExit()
  echo("---ActivityGrowView:onExit---")
  net.unregistAllCallback(self)
end


function ActivityGrowView:rechargeCallback()
  echo("rechargeCallback")
  _playSnd(SFX_CLICK)
  self:getDelegate():goToShopPayView()
end 

function ActivityGrowView:buyCallback()
  echo("buyCallback")
  _playSnd(SFX_CLICK)

  if self:checkToBuyGrowPlan() then 
    _showLoading()
    net.sendMessage(PbMsgId.BuyVipTicketC2S)
    --self.loading = Loading:show()       
  end 
end

function ActivityGrowView:buyResult(action,msgId,msg)
  echo("=== ActivityGrowView:buyResult: ", msg.error)

--  if self.loading ~= nil then 
--    self.loading:remove()
--    self.loading = nil
--  end
  _hideLoading()

  if msg.error == "NO_ERROR_CODE" then 
    GameData:Instance():getCurrentPlayer():setGrowPlanBuyFlag(1)
    self.bn_buy:setEnabled(false)
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)
    
    Toast:showString(self, _tr("buy_success"), ccp(display.cx, display.cy))

  elseif msg.error == "NEED_MORE_MONEY" then 
    -- Toast:showString(self, _tr("not enough money"), ccp(display.cx, display.cy))
    GameData:Instance():notifyForPoorMoney()
  elseif msg.error == "HAS_BUY_TICKET" then 
    Toast:showString(self, _tr("has buy,no need buy again"), ccp(display.cx, display.cy))
  elseif msg.error == "NOT_MONTH_VIP" then 
    Toast:showString(self, _tr("vip_poor_level"), ccp(display.cx, display.cy))
  elseif msg.error == "SYSTEM_ERROR" then 
    Toast:showString(self, _tr("system error"), ccp(display.cx, display.cy))
  end 
end

function ActivityGrowView:showPlanList(planArray)
  echo("showPlanList")

  local function cellSizeForTable(tableview,idx)
    return self.planCellHeight,self.planCellWidth
  end
  
  local function tableCellAtIndex(tableview, idx)
    --echo("cellAtIndex = "..idx)
    local cell = tableview:dequeueCell()
    local item = nil

    if nil == cell then
      cell = CCTableViewCell:new()
    else 
      cell:removeAllChildrenWithCleanup(true)
    end

    item = ActivityGrowListItem.new()      
    item:setDelegate(self)
    item:setPlan(planArray[idx+1])
    item:setIndex(idx)

    -- if GameData:Instance():getCurrentPlayer():getGrowPlanBuyFlag() <= 0 then
    --   item:setIsFetched(false, true)
    -- else 
    --   local count = GameData:Instance():getCurrentPlayer():getRewardCountForGrowPlan()
    --   if count > idx then 
    --     item:setIsFetched(true, false)
    --   else 
    --     item:setIsFetched(false, true)
    --   end 
    -- end

    cell:addChild(item)

    return cell
  end
  
  local function numberOfCellsInTableView(tableview)
    return self.planTotalCells
  end

  if planArray == nil then
    echo("empty list data !!!")
    return
  end

  local size = self.node_listContainer:getContentSize()
  self.planCellWidth = size.width
  self.planCellHeight = 164
  self.planTotalCells = table.getn(planArray)

  self.node_listContainer:removeAllChildrenWithCleanup(true)

  self.tableView = CCTableView:create(size)
  self.tableView:setDirection(kCCScrollViewDirectionVertical)
  self.tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  self.node_listContainer:addChild(self.tableView)

  self.tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  self.tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  self.tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  self.tableView:reloadData()
end


function ActivityGrowView:fetchGrowthBonus(idx)
  echo("ActivityGrowView:fetchGrowthBonus: idx=", idx)
  
  if self:checkToBuyGrowPlan() == false then 
    return 
  end 

  local player = GameData:Instance():getCurrentPlayer()
  if player:getGrowPlanBuyFlag() <= 0 then 
    Toast:showString(self, _tr("pls buy grow plan"), ccp(display.cx, display.cy))
  else 
    local nextRewardIndex = player:getRewardCountForGrowPlan()
    if player:getLevel() < self.plansArray[idx+1].level then
      Toast:showString(self, _tr("poor level"), ccp(display.cx, display.cy))
    elseif idx > nextRewardIndex then
      Toast:showString(self, _tr("fetch fron bonus firstly"), ccp(display.cx, display.cy))
    else
      self.highlightIndex = idx
      _showLoading()
      net.sendMessage(PbMsgId.AskForVipRebate)
      --self.loading = Loading:show()
    end
  end
end


function ActivityGrowView:fetchResult(action,msgId,msg)

  echo("ActivityGrowView:fetchResult: ", msg.state)
--  if self.loading ~= nil then 
--    self.loading:remove()
--    self.loading = nil
--  end
  _hideLoading()

  if msg.state == "Ok" then
    --show gained bonus
    local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client_sync)
    for i=1,table.getn(gainItems) do
      echo("----gained:", gainItems[i].configId, gainItems[i].count)
      local str = string.format("+%d", gainItems[i].count)
      Toast:showIconNumWithDelay(str, gainItems[i].iconId, gainItems[i].iType, gainItems[i].configId, ccp(display.width/2,display.height*0.5-i*40), 0.3*(i-1))
    end

    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
    echo("------highlightIndex ", self.highlightIndex)
    if self.tableView ~= nil then
      -- self.tableView:updateCellAtIndex(self.highlightIndex)
      self.plansArray = Activity:instance():getAllGrowthPlans()
      self:showPlanList(self.plansArray)      
    else
      echo("  nil table view !!!")
    end


    --update tip 
    self:getDelegate():getBaseView():updateTopTip(ActMenu.GROW_PLAN)
    self:getDelegate():getScene():getBottomBlock():updateBottomTip(3)

  elseif msg.state == "NeedMonthVip" then 
    Toast:showString(self, _tr("pls buy vip firstly"), ccp(display.width/2, display.height*0.4))
  elseif msg.state == "NeedLevel" then
    Toast:showString(self, _tr("poor level"), ccp(display.width/2, display.height*0.4))
  elseif msg.state == "NeedVipTicket" then
    Toast:showString(self, _tr("pls buy grow plan"), ccp(display.width/2, display.height*0.4))    
  end
end

function ActivityGrowView:checkToBuyGrowPlan()
  local flag = Activity:instance():getCanBuyGrowPlan()
  if flag == false then 
    local pop = PopupView:createTextPopupWithPath({leftNorBtn = "goumai.png",leftSelBtn = "goumai1.png",
                                                 text = _tr("grow_plan_buy_condition_%{lv}",{lv=2}),
                        leftCallBack = function() return self:getDelegate():gotoVipPrivilegeView() end}) 
    self:getDelegate():getScene():addChild(pop,100)
  end 

  return flag 
end 