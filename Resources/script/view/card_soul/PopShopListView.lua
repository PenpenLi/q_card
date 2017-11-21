
require("view.BaseView")
require("model.card_soul.CardSoul")
require("view.card_soul.CardSoulShopListItem")
require("view.card_soul.CardSoulShopPopup")

PopShopListView = class("PopShopListView", BaseView)

function PopShopListView:ctor(shopType, prority)
  PopShopListView.super.ctor(self)

  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("closeCallback",PopShopListView.closeCallback)
  pkg:addFunc("refreshCallback",PopShopListView.refreshCallback)

  pkg:addProperty("node_list","CCNode") 
  pkg:addProperty("node_title","CCNode") 
  pkg:addProperty("node_refresh","CCNode") 
  pkg:addProperty("bn_close","CCControlButton")
  pkg:addProperty("bn_refresh","CCControlButton")
  pkg:addProperty("label_preLeft","CCLabelTTF")
  pkg:addProperty("label_currencyCount","CCLabelTTF")
  pkg:addProperty("label_preRefreshTime","CCLabelTTF")
  pkg:addProperty("label_refreshTime","CCLabelBMFont")
  pkg:addProperty("label_preRefreshCounts","CCLabelTTF")
  pkg:addProperty("label_refreshCounts","CCLabelBMFont")
  pkg:addProperty("sprite_currency","CCSprite")


  local layer,owner = ccbHelper.load("PopShopListView.ccbi","PopShopListViewCCB","CCLayer",pkg)
  self:addChild(layer)
  
  self.shopType = shopType 
  self.priority = prority or -200

  CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("img/common/common.plist","img/common/common.png")
end

function PopShopListView:onEnter()
  self.cols = 3 

  self.bn_close:setTouchPriority(self.priority)
  self.bn_refresh:setTouchPriority(self.priority)
  self.node_refresh:setVisible(self.shopType ~= ShopCurViewType.Bable)

  net.registMsgCallback(PbMsgId.PlayerStoreInfoS2C,self,PopShopListView.updateListForRefresh)  --自动刷新
  net.registMsgCallback(PbMsgId.PlayerRefreshStoreResultS2C,self,PopShopListView.refreshResult) --手动刷新
  net.registMsgCallback(PbMsgId.InstanceRefresh,self,PopShopListView.systomRefresh)    --零点更新


  self.label_preLeft:setString(string._tran(Consts.Strings.FASTBUG_HIT_HAVE))
  if self.shopType == ShopCurViewType.JingJiChang then 
    self.node_title:addChild(CCSprite:create("img/cardSoul/title_jingjichang.png"))
  elseif self.shopType == ShopCurViewType.GongHui then 
    self.node_title:addChild(CCSprite:create("img/cardSoul/title_gonghui.png"))
  elseif self.shopType == ShopCurViewType.Bable then 
    self.node_title:addChild(CCSprite:create("img/cardSoul/title_tongtian.png"))
  end 
  self:setCurrencyIcon(self.shopType, self.sprite_currency)

  self:updateCurrencyCount()

  GameData:Instance():getCurrentScene():setTopVisible(false)
  GameData:Instance():getCurrentScene():setBottomVisible(false)
  
  self:initOutLineLabel()
  Shop:instance():setTipsNewData(self.shopType, false)

  self:showListView()

  self:addTouchEventListener(function(event, x, y)
                                          return true 
                                        end,
                                        false, self.priority+3, true)
  self:setTouchEnabled(true)
end 

function PopShopListView:onExit()
  net.unregistAllCallback(self)
  -- if (self.shopType == ShopCurViewType.GongHui) or (self.shopType == ShopCurViewType.JingJiChang) then 
  -- else 
  --   GameData:Instance():getCurrentScene():setTopVisible(true)
  --   GameData:Instance():getCurrentScene():setBottomVisible(true)
  -- end 
  local flag = self:getTopBottomVisibleWhenExit()
  if flag then 
    GameData:Instance():getCurrentScene():setTopVisible(flag)
    GameData:Instance():getCurrentScene():setBottomVisible(flag)
  end 
end 

function PopShopListView:setTopBottomVisibleWhenExit(isVisible)
  self._barVisible = isVisible 
end 

function PopShopListView:getTopBottomVisibleWhenExit()
  if self._barVisible == nil then 
    self._barVisible = true 
  end 

  return self._barVisible
end 

function PopShopListView:showListView()

  self.dataArray = Shop:instance():getShopData(self.shopType) 
  self.dataLen = #self.dataArray
  echo("showListView, dataLen=", self.dataLen)

  -- local function scrollViewDidScroll(view)
  -- end

  local function tableCellTouched(tbView,cell)   
    self:setIsTouchEvent(true)
  end

  local function tableCellAtIndex(tbView, idx)
    -- echo("tableCellAtIndex = "..idx)
    local cell = tbView:dequeueCell()

    if nil == cell then
      cell = CCTableViewCell:new()
    else 
      cell:removeAllChildrenWithCleanup(true)
    end 

    local item = CardSoulShopListItem.new()
    if item ~= nil then 
      -- item:setButtonEnableDelegate(function() return self:getListButtonEnable() end)
      local data = {}
      local count = math.min(self.cols, self.dataLen-idx*self.cols)
      for i=1, count do 
        data[i] = self.dataArray[idx*self.cols+i]
      end 
      item:setPriority(self.priority+2)
      item:setIdx(idx)
      item:setChips(data)
      item:setDelegate(self)
      item:setAnchorPoint(ccp(0,0))
      item:setScale(0.92)
      cell:addChild(item)
    end 

    return cell
  end
  
  local function cellSizeForTable(tbView,idx)
    return self.cellHeight,self.cellWidth
  end

  local function numberOfCellsInTableView(tableview)
    return self.totalCells
  end


  self.node_list:removeAllChildrenWithCleanup(true)
  local listSize = self.node_list:getContentSize()
  self.cellWidth = listSize.width 
  self.cellHeight = 186
  self.totalCells = math.ceil(#self.dataArray/self.cols)

  --create table view
  self.tableView = CCTableView:create(listSize)
  self.node_list:addChild(self.tableView)
  self.tableView:setDirection(kCCScrollViewDirectionVertical)
  self.tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  self.tableView:setTouchPriority(self.priority+1)

  -- self.tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  self.tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  self.tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  self.tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  self.tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  self.tableView:reloadData()

  local freeLimit = Shop:instance():getTotalFreeRefreshCount(self.shopType)
  local payLimit = Shop:instance():getTotalPayRefreshCount(self.shopType)
  local usedCount = Shop:instance():getUsedFreeRefreshCount(self.shopType)
  echo("=== showRefreshCounts: used, total", usedCount, freeLimit)
  self.label_refreshCounts:setString(string.format("%d/%d", math.max(0,freeLimit-usedCount), freeLimit))

  echo("=== showRefreshCounts: used, total, limit", usedCount, freeLimit, payLimit)
  self.bn_refresh:setEnabled(payLimit<0 or usedCount<payLimit)
  
  self:showRefreshTime()
end

function PopShopListView:showPopupToBuy(chipIndex)
  echo("=== chipIndex", chipIndex)
  local item = self.dataArray[chipIndex]
  local pop = CardSoulShopPopup.new()
  pop:setDelegate(self)
  pop:setDataIndex(chipIndex)
  pop:setData(item)
  GameData:Instance():getCurrentScene():addChildView(pop)
end 

function PopShopListView:updateCurrencyCount()
  local player = GameData:Instance():getCurrentPlayer()
  if self.shopType == ShopCurViewType.JingJiChang then 
    self.label_currencyCount:setString(string.format("%d", player:getRankPoint()))
  elseif self.shopType == ShopCurViewType.GongHui then 
    self.label_currencyCount:setString(string.format("%d", player:getGuildPoint()))
  elseif self.shopType == ShopCurViewType.Bable then 
    self.label_currencyCount:setString(string.format("%d", player:getBablePoint()))
  end 
end 

function PopShopListView:closeCallback()
  self:removeFromParentAndCleanup(true)
end 

function PopShopListView:refreshCallback()
  local totalFreeCount = Shop:instance():getTotalFreeRefreshCount(self.shopType)
  local usedfreeCounts = Shop:instance():getUsedFreeRefreshCount(self.shopType)
  if usedfreeCounts < totalFreeCount then -- 免费刷新
    local data = PbRegist.pack(PbMsgId.PlayerRefreshStoreC2S, {type=self.shopType, use_money=0})
    net.sendMessage(PbMsgId.PlayerRefreshStoreC2S, data)
    self:addMaskLayer()
  else --元宝刷新
    local needMoney = Shop:instance():getPayRefreshCost(self.shopType)
    local function useMoneyToRefresh()
      if GameData:Instance():getCurrentPlayer():getMoney() >= needMoney then
        local data = PbRegist.pack(PbMsgId.PlayerRefreshStoreC2S, {type=self.shopType, use_money=1})
        net.sendMessage(PbMsgId.PlayerRefreshStoreC2S, data)
        self:addMaskLayer()
      else
        local pop = PopupView:createTextPopup(_tr("not_enough_money_to_refresh"), function()
                                local controller = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
                                controller:enter(ShopCurViewType.PAY)   
                             end)
        self:addChild(pop,100)
      end 
    end 

    local str = _tr("ask_pay%{coin}to_refresh",{coin = needMoney})
    local pop = PopupView:createTextPopup(str, useMoneyToRefresh)
    self:addChild(pop, 100)       
  end 
end 

function PopShopListView:refreshResult(action,msgId,msg)
  echo("=== refreshResult:", msg.error)
  if msg.error == "NO_ERROR_CODE" then 
    -- GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)
    -- Shop:instance():initShopData(msg)
    self:performWithDelay(function()
                self:updateListForRefresh()
                end, 0.5) 
  else    
    Shop:instance():handleErrorCode(msg.error)
    self:removeMaskLayer()
  end 
end 

function PopShopListView:systomRefresh(action,msgId,msg)
  local totalCount = Shop:instance():getTotalFreeRefreshCount(self.shopType)
  local usedCount = Shop:instance():getUsedFreeRefreshCount(self.shopType)
  echo("=== PopShopListView:systomRefresh: used, total", usedCount, totalCount)
  self.label_refreshCounts:setString(string.format("%d/%d", math.max(0,totalCount-usedCount), totalCount))
end 

function PopShopListView:buyItem(index, count)
  echo("===buyItem:", index, count)

  self.buyIndex = index
  local buyCount = count or 1 
  if buyCount < 1 then 
    return 
  end 

  --卡牌碎片不需校验背包格子
  if self.viewType ~= ShopCurViewType.Soul and self:checkIsBagSpaceEnough() == false then 
    echo("=== no engough bag space")
    return 
  end 

  local shopItem = self.dataArray[self.buyIndex]
  local currencyType = shopItem:getCurrencyType()
  local needCurrency = shopItem:getDiscountPrice()
  if Shop:instance():checkHasEnoughCurrency(currencyType, needCurrency, true) == false then 
    return 
  end 
  Shop:instance():setView(self)
  Shop:instance():reqBuyItem(shopItem, buyCount)
end 

function PopShopListView:updateView() --buyItemResult
  if self.tableView ~= nil then 
    local idx = math.floor((self.buyIndex-1)/self.cols)
    self.tableView:updateCellAtIndex(idx)
  end 
  self:updateCurrencyCount()
end 

function PopShopListView:updateListForRefresh()
  echo("=== PopShopListView:updateListForRefresh")

  Shop:instance():setTipsNewData(self.shopType, false)
  
  local function updataTableView()
    self:showListView()

--    if self.loading ~= nil then 
--      self.loading:remove()
--      self.loading = nil 
--    end 
    _hideLoading()
    self:removeMaskLayer()

    local pop = GameData:Instance():getCurrentScene():getChildByTag(666)
    if pop ~= nil then 
      pop:removeFromParentAndCleanup(true)
    end 
  end
  --self.loading = Loading:show()
  _showLoading()
  local array = CCArray:create()
  array:addObject( CCDelayTime:create(0.5))
  array:addObject( CCCallFunc:create(updataTableView))
  self:runAction( CCSequence:create(array) )
end

function PopShopListView:getTimeStr(timeSec)
  local str = "00:00"
  if timeSec > 3600 then 
    str = math.floor(timeSec/3600).._tr("hour")
  elseif timeSec > 0 then 
    str = string.format("%02d:%02d", math.floor(timeSec/60), math.mod(timeSec,60))
  end 
  
  return str 
end 

function PopShopListView:showRefreshTime()

  local function updataRefreshTime(dt)
    self.leftSec = self.leftSec - 1 

    if self.leftSec <= 0 then
      self.label_refreshTime:setString("00:00")
      if self.refreshTimer ~= nil then 
        self:unschedule(self.refreshTimer) 
        self.refreshTimer = nil 
      end 
    else 
      self.label_refreshTime:setString(self:getTimeStr(self.leftSec))
    end
  end

  if self.refreshTimer ~= nil then 
    self:unschedule(self.refreshTimer)
    self.refreshTimer = nil 
  end 

  self.leftSec = Shop:instance():getLeftRefreshTime(self.shopType)
  if self.leftSec > 0 then  
    self.label_refreshTime:setString(self:getTimeStr(self.leftSec))
    self.refreshTimer = self:schedule(updataRefreshTime, 1.0)
  else 
    self.label_refreshTime:setString("00:00")
  end 
  echo("===showRefreshTime:left", self.leftSec)
end 

function PopShopListView:setIsTouchEvent(isTouchEvent)
  self._isTouch = isTouchEvent
end 

function PopShopListView:getIsTouchEvent()
  return self._isTouch
end 

function PopShopListView:checkIsBagSpaceEnough()
  local isEnough1 = GameData:Instance():getCurrentPackage():checkItemBagEnoughSpace(1) 
  if isEnough1 == false then
    local pop = PopupView:createTextPopupWithPath({leftNorBtn = "button-nor-zhengli.png",
                                                   leftSelBtn = "button-sel-zhengli.png",
                                                   text = _tr("bag is full,clean up?"),
                                                   leftCallBack = function()                                                    
                                                      return self:getDelegate():goToItemView()
                                                  end})
    self:getDelegate():getScene():addChild(pop,100)
  end 

  return isEnough1
end 

function PopShopListView:addMaskLayer()
  echo("=== addMaskLayer")
  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
  end 

  self.maskLayer = Mask.new({opacity=0, priority = -1000})
  self:addChild(self.maskLayer)

  self:performWithDelay(handler(self, PopShopListView.removeMaskLayer), 5.0)
end 

function PopShopListView:removeMaskLayer()
  echo("=== removeMaskLayer")
  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
    self.maskLayer = nil 
  end 
end 

function PopShopListView:setCurrencyIcon(shopType, spriteObj)

  local frame = nil 

  if shopType == ShopCurViewType.JingJiChang then 
    frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("currency_jingjichang.png")

  elseif shopType == ShopCurViewType.GongHui then 
    frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("currency_gonghui.png")

  elseif shopType == ShopCurViewType.Bable then 
    frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("currency_bable.png")

  elseif shopType == ShopCurViewType.Soul then 
    frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("currency_soul.png") 
  end 

  if frame and spriteObj then 
    spriteObj:setDisplayFrame(frame)
  end   
end 

function PopShopListView:initOutLineLabel()
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
