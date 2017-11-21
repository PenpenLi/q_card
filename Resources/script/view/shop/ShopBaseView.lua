
require("view.component.ViewWithEave")
require("view.shop.ShopSaleListItem")
require("view.shop.ShopTypeItem")
require("view.shop.ShopPayView")


ShopBaseView = class("ShopBaseView", ViewWithEave)

function ShopBaseView:ctor()
  ShopBaseView.super.ctor(self)
  
  self.priority = -100 
end 

function ShopBaseView:onEnter()
  echo("=== ShopBaseView:onEnter=== ")
  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("refreshCallback",ShopBaseView.refreshCallback)
  pkg:addProperty("listContainer","CCNode")
  pkg:addProperty("node_refresh","CCNode")
  pkg:addProperty("label_preRefreshTime","CCLabelTTF")
  pkg:addProperty("label_refreshTime","CCLabelBMFont")
  pkg:addProperty("label_preRefreshCounts","CCLabelTTF")
  pkg:addProperty("label_refreshCounts","CCLabelBMFont")
  pkg:addProperty("bn_refresh","CCControlButton")

  local layer,owner = ccbHelper.load("ShopBaseView.ccbi","ShopBaseViewCCB","CCLayer",pkg)
  self:addChild(layer)

  --tab menu
  local menuArray ={
                    {"#shop-button-nor-jishi.png","#shop-button-sel-jishi.png"} ,
                    {"#shop-button-nor-tehui.png","#shop-button-sel-tehui.png"},
                    {"#shop-button-nor-diancang.png","#shop-button-sel-diancang.png"},
                    {"#shop-button-nor-chongzhi.png","#shop-button-sel-chongzhi.png"},
                    {"#shop-button-nor-other.png","#shop-button-sel-other.png"}
                   }
  self:setMenuArray(menuArray)
  self:setTitleTextureName("shop-image-paibian.png")
  local viewIndex = self:getDelegate():getCurViewIndex()
  self:highlightMenuItem(viewIndex)

  self:initOutLineLabel()
  self.bn_refresh:setTouchPriority(self.priority)

  --vip btn
  -- local frame1 =  display.newSpriteFrame("bn_vip0.png")
  -- local frame2 =  display.newSpriteFrame("bn_vip1.png")
  -- local taskMenuItem = CCMenuItemImage:create()
  -- taskMenuItem:setNormalSpriteFrame(frame1)
  -- taskMenuItem:setSelectedSpriteFrame(frame2)
  -- self:getEaveView().btnHelp:getParent():addChild(taskMenuItem)
  -- taskMenuItem:setPosition(self:getEaveView().btnHelp:getPosition())
  -- taskMenuItem:registerScriptTapHandler(function()
  --                                        self:getDelegate():displayVipInfoView()
  --                                      end)
  --self:getEaveView().btnBack:setVisible(false)
  self:getEaveView().btnHelp:setVisible(false)

  --net.registMsgCallback(PbMsgId.PlayerBuyFormStoreResultS2C, self, ShopBaseView.buyFromStoreResult)
  net.registMsgCallback(PbMsgId.PlayerStoreInfoS2C, self, ShopBaseView.updateStoreList)
  net.registMsgCallback(PbMsgId.PlayerRefreshStoreResultS2C,self,ShopBaseView.refreshResult)
  net.registMsgCallback(PbMsgId.InstanceRefresh,self,ShopBaseView.updateRefreshCounts) --零点更新

  self:registerTouchEvent()

  --show list
  self:showView(viewIndex)
  
  Shop:instance():setView(self)
end 

function ShopBaseView:onExit()
  echo("=== ShopBaseView:onExit=== ")
  net.unregistAllCallback(self)
  Shop:instance():setView(nil)
end 

function ShopBaseView:onHelpHandler()
end 

function ShopBaseView:onBackHandler()
  echo("=== ShopBaseView:backCallback")
  ShopBaseView.super:onBackHandler()
  GameData:Instance():gotoPreView()
end

function ShopBaseView:refreshCallback()
  if self:getDelegate():getCurViewIndex() ~= ShopCurViewType.JiShi then 
    return 
  end 

  local totalFreeCount = Shop:instance():getTotalFreeRefreshCount(ShopCurViewType.JiShi)
  local usedfreeCounts = Shop:instance():getUsedFreeRefreshCount(ShopCurViewType.JiShi)
  if usedfreeCounts < totalFreeCount then -- 免费刷新
    _showLoading()
    local data = PbRegist.pack(PbMsgId.PlayerRefreshStoreC2S, {type=ShopCurViewType.JiShi, use_money=0})
    net.sendMessage(PbMsgId.PlayerRefreshStoreC2S, data)
    self:addMaskLayer()
  else --元宝刷新
    local needMoney = Shop:instance():getPayRefreshCost(ShopCurViewType.JiShi)
    local function useMoneyToRefresh()
      if GameData:Instance():getCurrentPlayer():getMoney() >= needMoney then
        _showLoading()
        local data = PbRegist.pack(PbMsgId.PlayerRefreshStoreC2S, {type=ShopCurViewType.JiShi, use_money=1})
        net.sendMessage(PbMsgId.PlayerRefreshStoreC2S, data)
        self:addMaskLayer()
      else
        local pop = PopupView:createTextPopup(_tr("not_enough_money_to_refresh"), function() return self:showView(ShopCurViewType.PAY) end)
        self:addChild(pop,100)
      end 
    end 

    local str = _tr("ask_pay%{coin}to_refresh",{coin = needMoney})
    local pop = PopupView:createTextPopup(str, useMoneyToRefresh)
    self:addChild(pop, 100)       
  end 
end 

function ShopBaseView:refreshResult(action,msgId,msg)
  echo("=== refreshResult:", msg.error)
  
  if msg.error == "NO_ERROR_CODE" then 
    -- GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)
    -- Shop:instance():initShopData(msg)
    self:performWithDelay(function()
                _hideLoading()
                self:updateStoreList()
                end, 0.5)
  else    
    _hideLoading()
    Shop:instance():handleErrorCode(msg.error)
  end 
  self:removeMaskLayer()
end 

function ShopBaseView:showView(viewIndex)
  echo("=== ShopBaseView:showView", viewIndex)
  
  if Shop:instance():checkEntryCondition(viewIndex) == false then 
    return false 
  end 

  if self.payView ~= nil then 
    echo("=== remove pay view...")
    self.payView:removeFromParentAndCleanup(true)
    self.payView = nil 
  end 

  self:getDelegate():setCurViewIndex(viewIndex)
  self:resizeListView()

  GameData:Instance():pushViewType(ViewType.shop, viewIndex)

  self:highlightMenuItem(viewIndex)

  if viewIndex == ShopCurViewType.PAY then 
    self.listContainer:removeAllChildrenWithCleanup(true)
    self.payView = ShopPayView.new()
    self.payView:setDelegate(self:getDelegate())
    self:addChild(self.payView)

  elseif viewIndex == ShopCurViewType.OtherShops then 
    local flag_jingjichang = GameData:Instance():checkSystemOpenCondition(41, false)
    local flag_bable = GameData:Instance():checkSystemOpenCondition(44, false)
    -- local flag_gonghui = GameData:Instance():checkSystemOpenCondition(43, false)
    local flag_gonghui = false 
    if Guild:Instance():getSelfHaveGuild() then 
      flag_gonghui = true 
    end 

    echo("===flag_jingjichang,flag_gonghui,flag_bable", flag_jingjichang,flag_gonghui,flag_bable)
    local viewData = {{shopType = ShopCurViewType.JingJiChang, canEntry = flag_jingjichang}, 
                      {shopType = ShopCurViewType.GongHui, canEntry = flag_gonghui}, 
                      {shopType = ShopCurViewType.Bable, canEntry = flag_bable}}
    self:showListView(viewData, true)

  else 
    local viewData = Shop:instance():getShopData(viewIndex) 
    self:showListView(viewData, false)

    if viewIndex == ShopCurViewType.JiShi then --clear tip flag 
      Shop:instance():setTipsNewData(ShopCurViewType.JiShi, false)
    else 
      local tipFlag = Shop:instance():getTipsFlag(ShopCurViewType.JiShi)
      self:getTabMenu():setTipImgVisible(1, tipFlag) 
    end 
  end 
  
  return true 
end 

function ShopBaseView:tabControlOnClick(idx)
  _playSnd(SFX_CLICK) 

  local result = true
  if idx == 0 then
    result = self:showView(ShopCurViewType.JiShi)
  elseif idx == 1 then 
    result = self:showView(ShopCurViewType.TeHui)
  elseif idx == 2 then
    result = self:showView(ShopCurViewType.DianCang)
  elseif idx == 3 then
    result = self:showView(ShopCurViewType.PAY)
  elseif idx == 4 then 
    result = self:showView(ShopCurViewType.OtherShops)
  end

  return result
end

function ShopBaseView:highlightMenuItem(viewIndex)
  local menuIdx = 1 
  if viewIndex == ShopCurViewType.JiShi then 
    menuIdx = 1 
  elseif viewIndex == ShopCurViewType.TeHui then 
    menuIdx = 2 
  elseif viewIndex == ShopCurViewType.DianCang then 
    menuIdx = 3 
  elseif viewIndex == ShopCurViewType.PAY then 
    menuIdx = 4 
  elseif viewIndex == ShopCurViewType.OtherShops then 
    menuIdx = 5
  end 
  self:getTabMenu():setItemSelectedByIndex(menuIdx) 
end 

function ShopBaseView:showListView(listData, isOtherShopsList)
  echo("ShopBaseView:showListView")

  if listData == nil then 
    return
  end 
  self.dataArray = listData

  -- local function scrollViewDidScroll(view)
  -- end

  local function tableCellTouched(tbView,cell)   
  end

  local function tableCellAtIndex(tbView, idx)
    -- echo("tableCellAtIndex = "..idx)
    local item = nil
    local cell = tbView:dequeueCell()
    if cell == nil then
      cell = CCTableViewCell:new()
      if isOtherShopsList then 
        item = ShopTypeItem.new()
      else 
        item = ShopSaleListItem.new()
      end 
      item:setIdx(idx)
      item:setData(self.dataArray[idx+1])
      item:setDelegate(self)
      item:setPriority(self.priority+1)      
      item:setTag(100)
      cell:addChild(item)
    else 
      item = cell:getChildByTag(100)
      if item ~= nil then
        item:setIdx(idx)
        item:setData(self.dataArray[idx+1])
        item:updateInfos()
      end
    end

    return cell
  end
  
  local function cellSizeForTable(tbView,idx)
    return self.cellHeight,self.cellWidth
  end

  local function numberOfCellsInTableView(tableview)
    return self.totalCells
  end


  self.listContainer:removeAllChildrenWithCleanup(true)

  local listSize = self.listContainer:getContentSize()
  self.cellWidth = listSize.width 
  self.cellHeight = 154 
  self.totalCells = #self.dataArray

  --create table view
  self.tableView = CCTableView:create(listSize)
  self.listContainer:addChild(self.tableView)
  self.tableView:setDirection(kCCScrollViewDirectionVertical)
  self.tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  self.tableView:setTouchPriority(self.priority+1)
  
  -- self.tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  self.tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  self.tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  self.tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  self.tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  self.tableView:reloadData()

  if self.node_refresh:isVisible() then 
    self:showRefreshTime()
    self:showRefreshCounts()
  end 
end

function ShopBaseView:resizeListView()
  local nodeRefreshHeight = 0
  local viewIndex = self:getDelegate():getCurViewIndex()
  if viewIndex == ShopCurViewType.JiShi then 
    nodeRefreshHeight = self.node_refresh:getContentSize().height 
    self.node_refresh:setVisible(true)
  else 
    self.node_refresh:setVisible(false)
  end 

  local bottomHeight = self:getDelegate():getScene():getBottomContentSize().height
  local offsetY = 10 
  local list_w = 640 --size.width
  local list_h = self:getCanvasContentSize().height - nodeRefreshHeight - offsetY
  self.node_refresh:setPositionY(bottomHeight+offsetY)
  self.listContainer:setPositionY(bottomHeight+nodeRefreshHeight+offsetY)
  self.listContainer:setContentSize(CCSizeMake(list_w, list_h))
 end 

function ShopBaseView:checkBagSpace(_type)
  local isEnough = true 
  local str = " "
  local package = GameData:Instance():getCurrentPackage()

  if _type == 6 and package:checkItemBagEnoughSpace(1) == false then
    str = _tr("bag is full,clean up?")
    isEnough = false 
  elseif _type == 7 and package:checkEquipBagEnoughSpace(1) == false then 
    str = _tr("equip bag is full,clean up?")
    isEnough = false 
  end  
  if _type == 8 and package:checkEquipBagEnoughSpace(1) == false then 
    str = _tr("card bag is full,clean up?")
    isEnough = false 
  end 
   
  if isEnough == false then
    local pop = PopupView:createTextPopupWithPath({leftNorBtn = "button-nor-zhengli.png",
                                                   leftSelBtn = "button-sel-zhengli.png",
                                                   text = str,
                                                   leftCallBack = function()
                                                      return self:getDelegate():gotoBagView(_type)
                                                  end})
    self:getDelegate():getScene():addChild(pop,100)
  end 

  return isEnough
end 


function ShopBaseView:registerTouchEvent()
    local function onTouch(eventType, x, y)
        if eventType == "began" then
          local listSize = self.listContainer:getContentSize()
          local pos = self.listContainer:convertToNodeSpace(ccp(x, y))
          if pos.x > 0 and pos.x < listSize.width and pos.y > 0 and pos.y < listSize.height then 
            self:setIsValidTouch(true) 
          else 
            self:setIsValidTouch(false) 
          end 

          return false
        end
    end
  
  self:addTouchEventListener(onTouch, false, self.priority, true)
  self:setTouchEnabled(true)
end

function ShopBaseView:setIsValidTouch(isValidTouch)
  self._validTouch = isValidTouch
end 

function ShopBaseView:getIsValidTouch()
  return self._validTouch
end

function ShopBaseView:buyItem(shopItem, idx)
  if self:getIsValidTouch() == false then 
    echo("=== touch out of view ...")
    return 
  end 

  if self:checkBagSpace(shopItem:getObjectType())==false then 
    return 
  end 

  --次数用完时, 如果下一VIP等级对应的购买上限 > 当前上限, 则提示用户
  local leftBuyCount = math.max(0, shopItem:getBuyLimit() - shopItem:getBuyTimes())
  local curLimit = shopItem:getBuyLimit() 
  local nextLimit = shopItem:getBuyLimit(true)
  echo("===cur/next vip limit:", curLimit, nextLimit)
  if curLimit > 0 and nextLimit > curLimit then 
    if leftBuyCount <= 0 then 
      local pop = PopupView:createTextPopupWithPath({leftNorBtn = "goumai.png",leftSelBtn = "goumai1.png",
                                                   text = _tr("add_buy_counts_after_vip_up"),
                                                   leftCallBack = function() 
                                                                    -- self:showView(ShopCurViewType.PAY)
                                                                    self:getDelegate():gotoVipPrivilegeView()
                                                                  end}) 
      self:getDelegate():getScene():addChild(pop,100)
      return 
    end 
  end 

  self.listIdx = idx 

  local function sendMsgToBuy(n)
    echo("@@@ ShopBaseView:buyItem: storeType, cell_id, name, buy_count", shopItem:getStoreType(), shopItem:getId(), shopItem:getName(), n)
--    local data = PbRegist.pack(PbMsgId.PlayerBuyFormStoreC2S, {type=shopItem:getStoreType(), store_item=shopItem:getId(),count=n})
--    net.sendMessage(PbMsgId.PlayerBuyFormStoreC2S, data)
--    self.loading = Loading:show()
    
    Shop:instance():reqBuyItem(shopItem,n)
  end 

  --有购买次数限制时,由于价格递增,所以禁止批量购买
  if self:getDelegate():getCurViewIndex() == ShopCurViewType.DianCang and shopItem:getBuyLimit() <= 0 then 
    local currency = shopItem:getCurrencyType()
    local player = GameData:Instance():getCurrentPlayer()
    local realPrice = shopItem:getDiscountPrice()
    local maxNum = 1
    if currency == 1 then 
      maxNum = math.floor(player:getCoin()/realPrice)
    elseif currency == 2 then
      maxNum = math.floor(player:getMoney()/realPrice)
    end

    echo("===currency, maxNum", currency, maxNum, realPrice)
    local pop = PopupView:createInputPopup(PopupType.INPUT_NUMBER_BUY,shopItem:getName(),realPrice,maxNum, function(n) return sendMsgToBuy(n) end, currency)
    self:addChild(pop, 100)
    pop:setScale(0.2)
    pop:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6))
  else 
    sendMsgToBuy(1)
  end 
end 

--[[function ShopBaseView:buyFromStoreResult(action,msgId,msg)
  echo("=== buyFromStoreResult:", msg.error)

  if self.loading ~= nil then 
    self.loading:remove()
    self.loading = nil
  end 

  if msg.error == "NO_ERROR_CODE" then 
    local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client)
    for i=1,table.getn(gainItems) do
      echo("----gained configId:", gainItems[i].configId)
      echo("----gained, count:", gainItems[i].count)
      local str = string.format("+%d", gainItems[i].count)
      Toast:showIconNumWithDelay(str, gainItems[i].iconId, gainItems[i].iType, gainItems[i].configId, ccp(display.cx,display.cy-i*40), 0.3*(i-1))
    end 
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)
    if self.tableView ~= nil then 
      self.tableView:updateCellAtIndex(self.listIdx)
    end 
  else 
    Shop:instance():handleErrorCode(msg.error)
  end 
end ]]

function ShopBaseView:updateView()
  print("updateView~~~~~")
  if self.tableView ~= nil then 
    self.tableView:updateCellAtIndex(self.listIdx)
  end 
end

function ShopBaseView:updateStoreList(action,msgId,msg)
  echo("=== updateStoreList:")
  if self:getDelegate():getCurViewIndex() == ShopCurViewType.JiShi then 
    Shop:instance():setTipsNewData(ShopCurViewType.JiShi, false)
    local viewData = Shop:instance():getShopData(ShopCurViewType.JiShi) 
    self:showListView(viewData, false)    
  end 
end 


function ShopBaseView:initOutLineLabel()
  self.label_preRefreshTime:setString("")
  local outline1 = ui.newTTFLabelWithOutline({
                                              text = _tr("shop_free_refresh_time"),
                                              font = self.label_preRefreshTime:getFontName(),
                                              size = self.label_preRefreshTime:getFontSize(),
                                              x = 0,
                                              y = 0,
                                              color = ccc3(255, 235, 0),
                                              align = ui.TEXT_ALIGN_LEFT,
                                              outlineColor =ccc3(0,0,0),
                                              pixel = 2
                                            }
                                          )
  local pos = ccp(self.label_preRefreshTime:getPositionX()-outline1:getContentSize().width-5, self.label_preRefreshTime:getPositionY())
  outline1:setPosition(pos)
  self.label_preRefreshTime:getParent():addChild(outline1) 

  self.label_preRefreshCounts:setString("")
  local outline2 = ui.newTTFLabelWithOutline({
                                              text = _tr("shop_free_refresh_count"),
                                              font = self.label_preRefreshCounts:getFontName(),
                                              size = self.label_preRefreshCounts:getFontSize(),
                                              x = 0,
                                              y = 0,
                                              color = ccc3(255, 235, 0),
                                              align = ui.TEXT_ALIGN_LEFT,
                                              outlineColor =ccc3(0,0,0),
                                              pixel = 2
                                            }
                                          )
  local pos2 = ccp(self.label_preRefreshCounts:getPositionX()-outline2:getContentSize().width-5, self.label_preRefreshCounts:getPositionY())
  outline2:setPosition(pos2)
  self.label_preRefreshCounts:getParent():addChild(outline2)  
end 


function ShopBaseView:showRefreshTime()

  local function updataRefreshTime(dt)
    self.leftSec = self.leftSec - 1 

    if self.leftSec <= 0 then
      self.label_refreshTime:setString("00:00")
      if self.refreshTimer ~= nil then 
        self:unschedule(self.refreshTimer)
        self.refreshTimer = nil 
      end 
    else 
      self.label_refreshTime:setString(string.format("%02d:%02d", math.floor(self.leftSec/60), math.mod(self.leftSec,60)))
    end
  end

  if self.refreshTimer ~= nil then 
    self:unschedule(self.refreshTimer)
    self.refreshTimer = nil 
  end 

  if self:getDelegate():getCurViewIndex() == ShopCurViewType.JiShi then 
    self.leftSec = Shop:instance():getLeftRefreshTime(ShopCurViewType.JiShi)
    if self.leftSec > 0 then 
      self.label_refreshTime:setString(string.format("%02d:%02d", math.floor(self.leftSec/60), math.mod(self.leftSec,60)))
      self.refreshTimer = self:schedule(updataRefreshTime, 1.0)
    else 
      self.label_refreshTime:setString("00:00")
    end 
  end 
end 

function ShopBaseView:showRefreshCounts()
  if self:getDelegate():getCurViewIndex() == ShopCurViewType.JiShi then 
    local freeLimit = Shop:instance():getTotalFreeRefreshCount(ShopCurViewType.JiShi)
    local payLimit = Shop:instance():getTotalPayRefreshCount(ShopCurViewType.JiShi)
    local usedCount = Shop:instance():getUsedFreeRefreshCount(ShopCurViewType.JiShi)
    self.label_refreshCounts:setString(string.format("%d/%d", math.max(0,freeLimit-usedCount), freeLimit))
    echo("=== showRefreshCounts: used, total, limit", usedCount, freeLimit, payLimit)
    self.bn_refresh:setEnabled(payLimit<0 or usedCount<payLimit)
  end 
end 

function ShopBaseView:updateRefreshCounts(action,msgId,msg)
  self:performWithDelay(handler(self, ShopBaseView.showRefreshCounts), 3.0)
end 

function ShopBaseView:addMaskLayer()
  echo("=== addMaskLayer")
  self:removeMaskLayer()

  self.maskLayer = Mask.new({opacity=0, priority = -1000})
  self:addChild(self.maskLayer)

  self.maskAction = self:performWithDelay(handler(self, ShopBaseView.removeMaskLayer), 6.0)
end 

function ShopBaseView:removeMaskLayer()
  echo("=== removeMaskLayer")
  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
    self.maskLayer = nil

    if self.maskAction ~= nil then 
      self:stopAction(self.maskAction)
      self.maskAction = nil 
    end 
  end 
end 

function ShopBaseView:gotoOtherShop(shopType)
  if shopType == ShopCurViewType.JingJiChang then 
    local view = PopShopListView.new(ShopCurViewType.JingJiChang)
    view:setTopBottomVisibleWhenExit(true)
    GameData:Instance():getCurrentScene():addChildView(view) 

  elseif shopType == ShopCurViewType.GongHui then 
    local view = PopShopListView.new(ShopCurViewType.GongHui,-300)
    view:setTopBottomVisibleWhenExit(true)
    GameData:Instance():getCurrentScene():addChildView(view)

  elseif shopType == ShopCurViewType.Bable then 
    local view = PopShopListView.new(ShopCurViewType.Bable)
    view:setTopBottomVisibleWhenExit(true)
    GameData:Instance():getCurrentScene():addChildView(view)
  end 
end 

