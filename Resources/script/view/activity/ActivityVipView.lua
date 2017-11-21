
require("view.BaseView")
require("view.component.Loading")
require("view.component.PopupView")
require("view.activity.ActivityVipListItem")


ActivityVipView = class("ActivityVipView", BaseView)



function ActivityVipView:ctor()

  ActivityVipView.super.ctor(self)

  --1. load levelup view ccbi
  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("rechargeCallback",ActivityVipView.rechargeCallback)
  pkg:addFunc("buyCallback",ActivityVipView.buyCallback)
  pkg:addProperty("node_img","CCNode")
  pkg:addProperty("node_listContainer","CCNode")

  local layer,owner = ccbHelper.load("ActivityVipView.ccbi","ActivityVipViewCCB","CCLayer",pkg)
  self:addChild(layer)
end

function ActivityVipView:init()
  echo("---ActivityVipView:init---")

  net.registMsgCallback(PbMsgId.AskForVipGiftResult, self, ActivityVipView.fetchResult)

  --init list size
  local topHeight = self:getDelegate():getTopMenuSize().height
  local bottomHeight = self:getDelegate():getScene():getBottomContentSize().height

  local imgHeight = self.node_img:getContentSize().height
  self.node_img:setPositionY(display.height-topHeight-imgHeight)

  --for node list position
  self.node_listContainer:setContentSize(CCSizeMake(640,  display.height-topHeight-imgHeight-bottomHeight))
  self.node_listContainer:setPosition(ccp((display.width-640)/2 ,bottomHeight))

end

function ActivityVipView:onEnter()
  echo("---ActivityVipView:onEnter---")
  self:init()
  self.bonusArray = Activity:instance():getAllVipBonus()
  self:showBonusList(self.bonusArray)
end

function ActivityVipView:onExit()
  echo("---ActivityVipView:onExit---")

  net.unregistAllCallback(self)
end


function ActivityVipView:rechargeCallback()
  echo("rechargeCallback")
  _playSnd(SFX_CLICK)
  self:getDelegate():goToShopPayView()
end 

function ActivityVipView:setIsTouch(isTouch)
  self._isTouch = isTouch
end 

function ActivityVipView:getIsTouch()
  return self._isTouch
end



function ActivityVipView:showBonusList(bonusArray)
  echo("showBonusList")

  local function tableCellTouched(tableview,cell)
    self:setIsTouch(true)
  end
  
  local function cellSizeForTable(tableview,idx)
    return self.cellHeight,self.cellWidth
  end
  
  local function tableCellAtIndex(tableview, idx)
    echo("cellAtIndex = "..idx)
    local cell = tableview:dequeueCell()

    if nil == cell then 
      cell = CCTableViewCell:new() 
    else 
      cell:removeAllChildrenWithCleanup(true) 
    end 

    local item = nil
    item = ActivityVipListItem.new()
    item:setDelegate(self)
    item:setBonus(bonusArray[idx+1].bonus)
    item:setIsFetched(bonusArray[idx+1].hasFetched)
    item:setCanFetch(bonusArray[idx+1].canFetched)
    item:setDayIndex(bonusArray[idx+1].dayIndex)

    cell:addChild(item)
    return cell
  end
  
  local function numberOfCellsInTableView(tableview)
    return self.totalCells
  end

  if bonusArray == nil then
    echo("empty list data !!!")
    return
  end

  self.node_listContainer:removeAllChildrenWithCleanup(true)

  local size = self.node_listContainer:getContentSize()
  self.cellWidth = size.width
  self.cellHeight = 164
  self.totalCells = table.getn(bonusArray)

  self.tableView = CCTableView:create(size)
  self.tableView:setDirection(kCCScrollViewDirectionVertical)
  self.tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  self.tableView:setTouchPriority(-200)
  self.node_listContainer:addChild(self.tableView)

  self.tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  self.tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  self.tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  self.tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)

  self.tableView:reloadData()
end

function ActivityVipView:fetchVipBonus(dayIndex)
  local flag = GameData:Instance():getCurrentPlayer():getIsVipState()
  if flag == false then --not vip state
    echo(" not vip state ")
    local pop = PopupView:createTextPopupWithPath({leftNorBtn = "goumai.png",leftSelBtn = "goumai1.png",
                                                 text = _tr("not vip,buy it?"),
                        leftCallBack = function() return self:getDelegate():goToShopPayView() end}) 
    self:getDelegate():getScene():addChild(pop,100)
  else
    _showLoading()
    net.sendMessage(PbMsgId.AskForVipGift)
    --self.loading = Loading:show()
  end
end

function ActivityVipView:fetchResult(action,msgId,msg)

  echo("ActivityVipView:fetchResult: ", msg.state)
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
    if self.tableView ~= nil then 
      self.bonusArray = Activity:instance():getAllVipBonus()
      self:showBonusList(self.bonusArray)
    else 
      echo("  nil table view !!!")
    end

    --update tip 
    self:getDelegate():getBaseView():updateTopTip(ActMenu.VIP_SIGNIN)
    self:getDelegate():getScene():getBottomBlock():updateBottomTip(3)

  elseif msg.state == "NeedItemBagCell" then 
    Toast:showString(self, _tr("bag is full"), ccp(display.width/2, display.height*0.4))
  elseif msg.state == "NeedVip" then 
    Toast:showString(self, _tr("pls buy vip firstly"), ccp(display.width/2, display.height*0.4))
  elseif msg.state == "NoRightForToday" then
    Toast:showString(self, _tr("cannot award today"), ccp(display.width/2, display.height*0.4))
  elseif msg.state == "NeedCleanBags" then
    Toast:showString(self, _tr("bag is full"), ccp(display.width/2, display.height*0.4))
  end
end
