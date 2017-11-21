require("view.BaseView")

CardRebornPop = class("CardRebornPop", BaseView)

function CardRebornPop:ctor(card, priority)
  CardRebornPop.super.ctor(self)

  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("closeCallback",CardRebornPop.closeCallback)
  pkg:addFunc("rebornCallback",CardRebornPop.rebornCallback)

  pkg:addProperty("layer_mask","CCLayerColor")
  pkg:addProperty("node_list","CCNode")
  pkg:addProperty("sprite9_bg","CCScale9Sprite")
  pkg:addProperty("label_title","CCLabelTTF")
  pkg:addProperty("label_preCost","CCLabelTTF")
  pkg:addProperty("label_cost","CCLabelTTF")
  pkg:addProperty("sprite_money","CCSprite")
  pkg:addProperty("sprite_coin","CCSprite")
  pkg:addProperty("sprite_arrowLeft","CCSprite")
  pkg:addProperty("sprite_arrowRight","CCSprite")
 

  local layer,owner = ccbHelper.load("CardRebornPop.ccbi","CardRebornPopCCB","CCLayer",pkg)
  self:addChild(layer)

  self.card = card 
  self.priority = priority or -128
end

function CardRebornPop:onEnter()
  net.registMsgCallback(PbMsgId.SmeltCardResult, self, CardRebornPop.rebornResult)

  self:init()

  --show bonus 
  self:showRebornBonus()

  --cost
  if self.card then 
    local item = AllConfig.unit[self.card:getConfigId()]
    self.currencyType = item.currency_type 
    self.cost = item.dismantle_cost 

    if self.currencyType == 1 then --coin 
      self.sprite_coin:setVisible(true)
      self.sprite_money:setVisible(false)
    else 
      self.sprite_coin:setVisible(false)
      self.sprite_money:setVisible(true)
    end 
    self.label_cost:setString(string.format("%d", self.cost))    
  end 
end 

function CardRebornPop:onExit()
  net.unregistAllCallback(self)

  if self.enhanceChangeFlag and self:getDelegate() then 
    self:getDelegate():updateView()
  end   
end 

function CardRebornPop:init()
  self.enhanceChangeFlag = false 

  self.label_preCost:setString(_tr("cost"))
  self.label_title:setString(_tr("reborn_material"))

  self.layer_mask:addTouchEventListener(function(event, x, y)
                                          if event == "began" then 
                                            local size = self.sprite9_bg:getContentSize()
                                            local pos = self.sprite9_bg:convertToNodeSpace(ccp(x, y))
                                            if pos.x < 0 or pos.x > size.width or pos.y < 0 or pos.y > size.height then 
                                              self:closeCallback()
                                            end 

                                            return true 
                                          end 
                                        end,
                                        false, self.priority, true)
  self.layer_mask:setTouchEnabled(true) 
end 

function CardRebornPop:showRebornBonus()
  if self.card == nil then 
    return  
  end 
  self.bonus = CardSoul:instance():getCardRebornMaterials(self.card)


  local function tipsCallback(obj, configId, pos)
    if self.isTouch then 
      TipsInfo:showTip(obj, configId, nil, pos, nil, true)
    end 
  end 

  local function tableCellTouched(tbView,cell)
    self.isTouch = true 
  end

  local function scrollViewDidScroll(tbView)
    self.isTouch = false 
  end 

  local function cellSizeForTable(tbView,idx)
    return self.cellHeight,self.cellWidth
  end
  
  local function numberOfCellsInTableView(tbView)
    return self.totalCells
  end

  local function tableCellAtIndex(tbView, idx)
    local cell = tbView:dequeueCell()
    if child == nil then 
      cell = CCTableViewCell:new()
    else 
      cell:removeAllChildrenWithCleanup(true)
    end

    local grid_w = toint(self.cellWidth/5) 
    local grid_h = toint(self.cellHeight/2)
    if self.isOneRow then 
      grid_h = self.cellHeight
    end 
    local curPageCount = math.min(10, #self.bonus-idx*10)
    for i=1, curPageCount do 
      local props = self.bonus[idx*10 + i] 
      local x = (i-1)%5 * grid_w + grid_w/2 
      local y = 
      self.cellHeight - math.floor((i-1)/5)*grid_h - grid_h/2 

      local configId = props[2] > 100 and props[2] or props[1]
      local tipArgs = {callbackFunc=tipsCallback, priority = self.priority}
      local icon = GameData:Instance():getCurrentPackage():getItemSprite(nil, props[1], configId, props[3],nil, tipArgs) 
      if icon then 
        icon:setPosition(ccp(x, y))
        cell:addChild(icon)
      end 
    end 

    return cell
  end
  
  self.node_list:removeAllChildrenWithCleanup(true)

  local size = self.node_list:getContentSize()
  self.cellWidth = size.width
  self.cellHeight = size.height 
  self.totalCells = math.ceil(#self.bonus/10)
  self.isOneRow = (#self.bonus <= 5)

  local tableView = CCTableView:create(size)
  self.node_list:addChild(tableView)

  tableView:setDirection(kCCScrollViewDirectionHorizontal)
  tableView:setTouchPriority(self.priority-1) 

  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  tableView:reloadData()

  self.sprite_arrowLeft:setVisible(self.totalCells > 1)
  self.sprite_arrowRight:setVisible(self.totalCells > 1)
end 

function CardRebornPop:closeCallback()
  self:removeFromParentAndCleanup(true)
end 

function CardRebornPop:rebornCallback()
  if self.card == nil then 
    return 
  end 
  --check bag space 
  if Activity:instance():checkHasEnoughSpace(self.bonus) == false  then 
    self:closeCallback()
    return 
  end 

  --check money
  local str = ""
  local own 
  if self.currencyType == 1 then --coin 
    own = GameData:Instance():getCurrentPlayer():getCoin()
    str = _tr("not enough coin")
  else 
    own = GameData:Instance():getCurrentPlayer():getMoney()
    str = _tr("not enough money")
  end 
  if self.cost > own then 
    Toast:showString(self, str, ccp(display.cx, display.cy))
    return 
  end 

  --send msg to dismantle 
  _showLoading()
  local data = PbRegist.pack(PbMsgId.SmeltCard, {card_id={self.card:getId()}})
  net.sendMessage(PbMsgId.SmeltCard, data)
  
  
--  self.loading = Loading:show() 
  self:addMaskLayer()
end 

function CardRebornPop:rebornResult(action,msgId,msg)
  echo("rebornResult: ",msg.state)

--  if self.loading ~= nil then
--    self.loading:remove()
--    self.loading = nil
--  end 
  _hideLoading()

  self:removeMaskLayer()

  if msg.state == "Ok" then 
    self.enhanceChangeFlag = true 

    local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client_sync)
    dump(gainItems, "====gainItems")
    local pop = PopupView:createRewardPopup(gainItems)
    GameData:Instance():getCurrentScene():addChildView(pop)

    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
    CardSoul:instance():setRebornCards({})
    self:closeCallback() 

  elseif msg.state == "NotEnoughCurrency" then
    if self.currencyType == 1 then --coin 
      Toast:showString(self, _tr("not enough coin"), ccp(display.cx, display.cy))
    else 
      Toast:showString(self, _tr("not enough money"), ccp(display.cx, display.cy))
    end 
  else
    Enhance:instance():handleErrorCode(msg.state)
  end
end

function CardRebornPop:addMaskLayer()
  echo("=== addMaskLayer")
  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
  end 

  self.maskLayer = Mask.new({opacity=0, priority = -1000})
  self:addChild(self.maskLayer)

  self.maskLayerTimer = self:performWithDelay(handler(self, CardRebornPop.removeMaskLayer), 6.0)
end 

function CardRebornPop:removeMaskLayer()
  echo("=== removeMaskLayer")
  if self.maskLayerTimer then    
    self:stopAction(self.maskLayerTimer)
    self.maskLayerTimer = nil 
  end 

  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
    self.maskLayer = nil 
  end 

--  if self.loading ~= nil then 
--    self.loading:remove()
--    self.loading = nil
--  end  
  _hideLoading()
end 
