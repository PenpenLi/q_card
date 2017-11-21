
require("view.BaseView")
require("view.enhance.PropsBuyOrUseItem")


PropsBuyOrUseView = class("PropsBuyOrUseView", BaseView)


function PropsBuyOrUseView:ctor(isBuy)
  PropsBuyOrUseView.super.ctor(self)

  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("node_container","CCNode")
  pkg:addProperty("layer_mask","CCLayerColor")

  local layer,owner = ccbHelper.load("PropsBuyOrUseView.ccbi","PropsBuyOrUseViewCCB","CCLayer",pkg)
  self:addChild(layer)

  self.isBuy = isBuy
end

function PropsBuyOrUseView:onEnter()
  echo("---PropsBuyOrUseView:onEnter---")
  net.registMsgCallback(PbMsgId.OpenBoxResult, self, PropsBuyOrUseView.openBoxResult)
  net.registMsgCallback(PbMsgId.BuyItemFromShopResult,self,PropsBuyOrUseView.buyExpCardResult)
  CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self, handler(self,PropsBuyOrUseView.loadingTimeout),EventType.LOADING_TIMEOUT)

  self.touchPriority = -200
  self.data = self:getDelegate():dataInstance():getAllExpCards(self.isBuy)
  for k, v in pairs(self.data) do 
    v.selected = false
  end   
  self:showExpCardsList(self.data, self.isBuy)


  self.layer_mask:addTouchEventListener(handler(self,self.onTouchMaskLayer), false, self.touchPriority, true)
  self.layer_mask:setTouchEnabled(true)

  self:addTouchEventListener(handler(self,self.onTouch), false, self.touchPriority-10, true)
  self:setTouchEnabled(true)  
end 

function PropsBuyOrUseView:onExit()
  echo("---PropsBuyOrUseView:onExit---")
  net.unregistAllCallback(self)
  CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(self,EventType.LOADING_TIMEOUT)
end 

--用来拦截touch事件往下流，优先级最低
function PropsBuyOrUseView:onTouchMaskLayer(event, x,y)
  if event == "began" then
    local size = self.node_container:getContentSize()
    local pos = self.node_container:convertToNodeSpace(ccp(x, y))
    if pos.x < 0 or pos.x > size.width or pos.y < 0 or pos.y > size.height then 
      self.inViewRect = false 
    else 
      self.inViewRect = true 
    end 

    return true 

  elseif event == "ended" then
    if self.inViewRect == false then 
      local size = self.node_container:getContentSize()
      local pos = self.node_container:convertToNodeSpace(ccp(x, y))
      if pos.x < 0 or pos.x > size.width or pos.y < 0 or pos.y > size.height then 
        self:close()
      end 
    end 
  end 
end 

--用来判断点击区域是否在有效范围内,优先级最高
function PropsBuyOrUseView:onTouch(event, x,y)
  if event == "began" then
    local size = self.node_container:getContentSize()
    local pos = self.node_container:convertToNodeSpace(ccp(x, y))
    if pos.x < 0 or pos.x > size.width or pos.y < 0 or pos.y > size.height then 
      self.inViewRect = false 

      self:close()
    else 
      self.inViewRect = true 
    end 

    return false 

  elseif event == "ended" then
    if self.inViewRect == false then 
      local size = self.node_container:getContentSize()
      local pos = self.node_container:convertToNodeSpace(ccp(x, y))
      if pos.x < 0 or pos.x > size.width or pos.y < 0 or pos.y > size.height then 
        self:close()
      end 
    end 
  end 
end 


function PropsBuyOrUseView:showExpCardsList(itemArray, isBuy)

  local function tableCellTouched(tbView,cell)
    local idx = cell:getIdx()
    for k, v in pairs(itemArray) do 
      if k == idx+1 then 
        v.selected = not v.selected
      else 
        v.selected = false
      end 
    end 

    -- local offset = tbView:getContentOffset()
    tbView:reloadData()
    if idx >= 3 then 
      tbView:setContentOffset(ccp(0, 0))
    end 
  end
  
  local function tableCellAtIndex(tbView, idx)
    local cell = tbView:dequeueCell()
    if nil == cell then
      cell = CCTableViewCell:new()
    else
      cell:removeAllChildrenWithCleanup(true)
    end

    local node = PropsBuyOrUseItem.new()
    node:setDelegate(self)
    node:setIdx(idx)
    node:setTouchPriority(self.touchPriority-5)
    node:setData(itemArray[idx+1], self.isBuy)
    node:setDetailVisible(itemArray[idx+1].selected)
    cell:addChild(node)
    return cell
  end

  local function cellSizeForTable(tbView,idx)
    if itemArray[idx+1].selected == true then 
      return 331, self.cellWidth
    end 
    return 131, self.cellWidth
  end 

  local function numberOfCellsInTableView(tbView)
    return self.totalCells
  end

  echo("remove old tableview")
  self.node_container:removeAllChildrenWithCleanup(true)

  local size = self.node_container:getContentSize()
  self.cellWidth = size.width
  -- self.cellHeight = 131
  self.totalCells = #itemArray
  echo("===totalcells", self.totalCells)

  --create tableview
  self.tableView = CCTableView:create(size)
  self.tableView:setDirection(kCCScrollViewDirectionVertical)
  self.tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  self.tableView:setTouchPriority(self.touchPriority-1)
  self.node_container:addChild(self.tableView)

  --self.tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  self.tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  self.tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  self.tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  self.tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)

  self.tableView:reloadData()
end

function PropsBuyOrUseView:close()
  self:removeFromParentAndCleanup(true)
end 

function PropsBuyOrUseView:buyAndUseExpCard(cellId, num,idx)
  if self:checkHasEnoughCell(true) == false then 
    return 
  end
    
  self.curIdx = idx
  self.selectedNum = num

  echo("=== buyAndUseExpCard:", cellId, num, idx)
  _showLoading()
  local data = PbRegist.pack(PbMsgId.BuyItemFromShop,{cell_id = cellId,count = num})
  net.sendMessage(PbMsgId.BuyItemFromShop, data)

  --self.loading = Loading:show()
  self:addMaskLayer()
end 

function PropsBuyOrUseView:buyExpCardResult(action,msgId,msg)
  echo("=== buyExpCardResult:", msg.state)
  _hideLoading()
  self:removeMaskLayer()

  if msg.state == "Ok" then
    local package = GameData:Instance():getCurrentPackage()
    package:parseClientSyncMsg(msg.client_sync)

    local configId = self.data[self.curIdx+1]:getConfigId()
    local props = package:getPropsByConfigId(configId)
    local sysId = props:getId()
    self:openBox(sysId, self.selectedNum, self.curIdx)

  elseif msg.state =="NoSuchCell" then
    Toast:showString(self, _tr("the_goods_does_not_exist"), ccp(display.cx, display.cy))
  elseif msg.state == "NotEnoughCurrency" then
    Toast:showString(self, _tr("Don't_have_enough_gold_to_buy"), ccp(display.cx, display.cy))
  elseif msg.state == "PlayerBuyLimit" then
    Toast:showString(self, _tr("buy_limit"), ccp(display.cx, display.cy))
  elseif msg.state == "NeedMoreBagCell" then
    Toast:showString(self, _tr("Backpack_grid_is_not_enough"), ccp(display.cx, display.cy))
  elseif msg.state == "NoSuchCard" then
    Toast:showString(self, _tr("dose_not_exist_this_card"), ccp(display.cx, display.cy))
  elseif msg.state == "ItemBagIsFull" then
    Toast:showString(self, _tr("Backpack_grid_is_not_enough"), ccp(display.cx, display.cy))
  elseif msg.state == "NeedVip" then
    Toast:showString(self, _tr("Can_only_buy_VIP_players"), ccp(display.cx, display.cy))
  end

  if msg.state ~= "Ok" then
--    if self.loading ~= nil then 
--      self.loading:remove()
--      self.loading = nil 
--    end
  end 
end 

function PropsBuyOrUseView:openBox(propsId, num, idx)
  if self:checkHasEnoughCell(false) == false then 
    return 
  end

  self.curIdx = idx
  self.curPropsId = propsId 
  self.selectedNum = num  
  
  _showLoading()
  local data = PbRegist.pack(PbMsgId.OpenBox, {item_id = propsId, count = num})
  net.sendMessage(PbMsgId.OpenBox, data)

 
--  if self.loading == nil then 
--    self.loading = Loading:show()
--  end 
  self:addMaskLayer()
end 

function PropsBuyOrUseView:openBoxResult(action,msgId,msg)
  echo("=== open box result:", msg.state)
  _hideLoading()
--  if self.loading ~= nil then 
--    self.loading:remove()
--    self.loading = nil
--  end 
  self:removeMaskLayer()

  if msg.state == "Ok" then
    local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client_sync)
    local len = #gainItems
    for i=1, len do
      echo("----gained:", gainItems[i].iType, gainItems[i].count)
    end

    _playSnd(SFX_ITEM_ACQUIRED)

      --show toast
    if len == 1 then 
      local numStr = string.format("+%d", gainItems[1].count)
      Toast:showIconNum(numStr, gainItems[1].iconId, gainItems[1].iType, gainItems[1].configId, ccp(display.cx, display.cy))

    elseif len >= 2 then
      local pop = PopupView:createRewardPopup(gainItems)
      self:addChild(pop)
    end 

    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)

    if self.isBuy == false and self.tableView ~= nil then 
      self.data = self:getDelegate():dataInstance():getAllExpCards(self.isBuy)
      for k, v in pairs(self.data) do 
        if self.curIdx + 1 ~= k then 
          v.selected = false
        end 
      end 
      -- self.tableView:reloadData()
      self:showExpCardsList(self.data, self.isBuy)
    end 

  elseif msg.state == "ItemCountError" then
    Toast:showString(self, _tr("box num wrong"), ccp(display.width/2, display.height*0.4))
  elseif msg.state == "NoSuchItem" then
    Toast:showString(self, _tr("no such box"), ccp(display.width/2, display.height*0.4))
  elseif msg.state == "NeedMoreBagCell" then
    Toast:showString(self, _tr("need more bag cell"), ccp(display.width/2, display.height*0.4))
  elseif msg.state == "NeedKeyItem" then
    Toast:showString(self, _tr("no key"), ccp(display.width/2, display.height*0.4))
  --elseif msg.state == "NeedBoxType" then
  elseif msg.state == "NeedMoreKey" then
    Toast:showString(self, _tr("no enough key"), ccp(display.width/2, display.height*0.4))
  elseif msg.state == "NeedCharLv" then
    Toast:showString(self, _tr("poor level"), ccp(display.width/2, display.height*0.4))
  end
end

function PropsBuyOrUseView:checkHasEnoughCell(isBuy)
  --check bag/cardbag is full or not
  local isEnough1 = true 
  local isEnough2 = true  
  local str = ""
  local hasEnoughCell = true 

  isEnough1 = GameData:Instance():getCurrentPackage():checkCardBagEnoughSpace(1)
  if isEnough1 == false then 
    str = _tr("card bag is full,clean up?")
    if isBuy == true then --need check bag when buy&use 
      isEnough2 = GameData:Instance():getCurrentPackage():checkItemBagEnoughSpace(1)
      if isEnough2 == false then 
        str = _tr("bag is full,clean up?")
      end 
    end 
  end 

  if (isEnough1 == false) or (isEnough2 == false) then
    local pop = PopupView:createTextPopupWithPath({leftNorBtn = "button-nor-zhengli.png",
                                                   leftSelBtn = "button-sel-zhengli.png",
                                                   text = str,
                                                   leftCallBack = function()
                                                      if isEnough1 == false then
                                                        return self:goToCardBagView()
                                                      end 
                                                      if isEnough2 == false then 
                                                        return self:goToItemView()
                                                      end
                                                  end})
    self:addChild(pop,100)

    hasEnoughCell = false 
  end 

  return hasEnoughCell 
end 

function PropsBuyOrUseView:goToItemView() -- 跳到行囊界面
  self:close()
  local bagController = ControllerFactory:Instance():create(ControllerType.BAG_CONTROLLER)
  bagController:enter()
end

function PropsBuyOrUseView:goToCardBagView() -- 跳到卡牌背包界面
  self:close()
  local cardBagController = ControllerFactory:Instance():create(ControllerType.CARDBAG_CONTROLLER)
  cardBagController:enter(false)
end

function PropsBuyOrUseView:loadingTimeout()
  self.loading = nil 
  _hideLoading()
  self:removeMaskLayer()
end 

function PropsBuyOrUseView:addMaskLayer()
  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
  end 

  self.maskLayer = Mask.new({opacity=0, priority = -1000})
  self:addChild(self.maskLayer)
end 

function PropsBuyOrUseView:removeMaskLayer()
  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
    self.maskLayer = nil 
  end 
end 

function PropsBuyOrUseView:onValidTouch()
  return self.inViewRect
end 
