
require("view.BaseView")
require("view.component.Loading")
require("view.component.PopupView")
require("view.component.RichText")
require("view.activity.ActivityVipInfoItem")


ActivityVipInfoView = class("ActivityVipInfoView", BaseView)

function ActivityVipInfoView:ctor()

  ActivityVipInfoView.super.ctor(self)

  --1. load levelup view ccbi
  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("chargeCallback",ActivityVipInfoView.chargeCallback)
  pkg:addFunc("preInfoCallback",ActivityVipInfoView.preInfoCallback)
  pkg:addFunc("nextInfoCallback",ActivityVipInfoView.nextInfoCallback)

  pkg:addProperty("node_info1","CCNode")
  pkg:addProperty("node_listContainer","CCNode")
  pkg:addProperty("node_progress","CCNode")
  pkg:addProperty("node_viprank","CCNode")
  pkg:addProperty("node_cahrgeTip","CCNode")
  pkg:addProperty("label_tip1","CCLabelTTF") 
  pkg:addProperty("label_tip2","CCLabelTTF") 
  pkg:addProperty("label_tip3","CCLabelTTF") 
  pkg:addProperty("label_nextLevel","CCLabelBMFont") 
  pkg:addProperty("label_maxLevelTip","CCLabelTTF") 
  pkg:addProperty("sprite_money","CCSprite")
  pkg:addProperty("sprite_vip2","CCSprite")
  pkg:addProperty("sprite_vip3","CCSprite")
  pkg:addProperty("sprite_vipLevel","CCSprite")
  pkg:addProperty("sprite_fuli","CCSprite")
  pkg:addProperty("menu_vipSelect","CCMenu")
      
  local layer,owner = ccbHelper.load("ActivityVipInfoView.ccbi","ActivityVipInfoViewCCB","CCLayer",pkg)
  self:addChild(layer)
end


function ActivityVipInfoView:onEnter()
  echo("---ActivityVipInfoView:onEnter---")
  net.registMsgCallback(PbMsgId.BuyVipGiftResultS2c, self, ActivityVipInfoView.buyVipGiftResult)

  self.touchPriority = -200 
  
  --添加返回按钮
  local backImg = CCSprite:createWithSpriteFrameName("playstates-image-fanhui.png")
  local backImg1 = CCSprite:createWithSpriteFrameName("playstates-image-fanhui1.png")
  if backImg ~= nil then 
    local topHeight = self:getDelegate():getTopMenuSize().height 
    local menuSize = backImg:getContentSize()
    local menu = CCMenu:create()
    local menuItem = CCMenuItemSprite:create(backImg, backImg1, nil)
    menuItem:registerScriptTapHandler(handler(self, ActivityVipInfoView.onBackHandler))
    menu:addChild(menuItem)
    menu:setPosition(ccp(display.cx + 320 - 50, display.height - topHeight - menuSize.height/2))
    self:addChild(menu)
  end 

  --init list size
  local topHeight = self:getDelegate():getTopMenuSize().height
  local bottomHeight = self:getDelegate():getScene():getBottomContentSize().height

  local imgHeight = self.node_info1:getContentSize().height
  self.node_info1:setPositionY(display.height-topHeight-imgHeight)
  
  --progressBar
  local percent = 100 
  local player = GameData:Instance():getCurrentPlayer()
  local curVipLevel = player:getVipLevel()
  local curExp = player:getVipExp()
  local nextLevelExp = curExp
  if curVipLevel < 12 then 
    local curLevelExp = AllConfig.vipinitdata[curVipLevel+1].vip_exp 
    nextLevelExp = AllConfig.vipinitdata[curVipLevel+2].vip_exp 
    if nextLevelExp > curLevelExp then 
      percent = toint(100*(curExp-curLevelExp)/(nextLevelExp-curLevelExp))
    end 
  end 
  echo("===curExp, nextExp, percent", curExp, nextLevelExp, percent)

  local bg = CCSprite:createWithSpriteFrameName("vip_progress_bg.png")
  local fg1 = CCSprite:createWithSpriteFrameName("vip_progress_fg.png")
  local progressor = ProgressBarView.new(bg, fg1, nil)
  progressor:setPercent(percent, 1)
  self.node_progress:addChild(progressor)

  --vip curcle icon
  local lvBg = CCSprite:createWithSpriteFrameName("vip_icon.png")
  local lvIcon = CCSprite:createWithSpriteFrameName(string.format("vip_level_%d.png", curVipLevel))
  lvIcon:setPositionY(8)
  self.node_viprank:addChild(lvBg)
  self.node_viprank:addChild(lvIcon)
  self.node_viprank:setScale(0.9)

  --for node list position
  self.node_listContainer:setContentSize(CCSizeMake(640,  display.height-topHeight-imgHeight-bottomHeight))
  self.node_listContainer:setPosition(ccp((display.width-640)/2 ,bottomHeight))

  self:initLabel(nextLevelExp-curExp)

  self.infoData = Activity:instance():getVipInfoData()
  self:showInfoList(self.infoData) 

  self:initTouch()
end

function ActivityVipInfoView:onExit()
  echo("---ActivityVipInfoView:onExit---")
  net.unregistAllCallback(self)
end

function ActivityVipInfoView:chargeCallback()
  echo("chargeCallback")
  _playSnd(SFX_CLICK)
  self:getDelegate():goToShopPayView()
end 

function ActivityVipInfoView:preInfoCallback()
  echo("preInfoCallback")

  if self.isUpdating then 
    echo("== updating...")
    return 
  end 

  self.curPageIdx = self.curPageIdx - 1 
  if self.curPageIdx < 0 then 
    self.curPageIdx = 0
  end 

  self:scrollToPage(self.curPageIdx)
  if self.tableView then 
    self.tableView:updateCellAtIndex(self.curPageIdx)
    self.isUpdating = true 
    self:schedule(function() self.isUpdating = false end , 1.0)
  end 
end 

function ActivityVipInfoView:nextInfoCallback()
  echo("nextInfoCallback")
  if self.isUpdating then 
    echo("== updating...")
    return 
  end 

  self.curPageIdx = self.curPageIdx + 1 
  if self.curPageIdx >= self.totalCells then
    self.curPageIdx = self.totalCells - 1
  end
  self:scrollToPage(self.curPageIdx)
  if self.tableView then 
    self.tableView:updateCellAtIndex(self.curPageIdx)
    self.isUpdating = true 
    self:schedule(function() self.isUpdating = false end , 1.0)    
  end   
end 

function ActivityVipInfoView:onBackHandler()
  self:getDelegate():goBackView()
end 

function ActivityVipInfoView:setIsViewScrolling(isScrolling)
  self._isScrolling = isScrolling
end 

function ActivityVipInfoView:getIsViewScrolling()
  return self._isScrolling
end 

function ActivityVipInfoView:showInfoList(dataArray)
  echo("showInfoList")

  local preViewOffsetX = 0
  self._isDragging = false
  self.curPageIdx = 0

  local function scrollViewDidScroll(tblView)
    self:setIsViewScrolling(true)

    if self._isDragging ~= tblView:isDragging() then 
      self._isDragging = tblView:isDragging()

      if self._isDragging == true then 
        preViewOffsetX = tblView:getContentOffset().x
      else
        local offset_x = tblView:getContentOffset().x
        local gap = preViewOffsetX - offset_x
        if math.abs(gap) > 25 then
          if gap < 0 then
            self.curPageIdx =  self.curPageIdx - 1
          elseif gap > 0 then
            self.curPageIdx = self.curPageIdx + 1
          end
        end

        self:scrollToPage(self.curPageIdx)
      end
    end
  end

  local function tableCellTouched(tblView,cell)
    self:setIsViewScrolling(false)
  end
  
  local function cellSizeForTable(tblView,idx)
    return self.cellHeight,self.cellWidth
  end
  
  local function tableCellAtIndex(tblView, idx)
    echo("cellAtIndex = "..idx)
    local item = nil 
    local cell = tblView:dequeueCell()
    if nil == cell then 
      cell = CCTableViewCell:new() 
      item = ActivityVipInfoItem.new(self.cellHeight)
      item:setDelegate(self)
      item:setPriority(self.touchPriority+1)
      item:setIndex(idx) 
      item:setData(dataArray[idx+1])
      item:setTag(100)
      -- item:setPosition(ccp(0, (self.cellHeight-480)/2))
      cell:addChild(item)
    else 
      item = cell:getChildByTag(100)
      if item ~= nil then
        item:setIndex(idx) 
        item:setData(dataArray[idx+1])
      end 
    end 

    return cell
  end
  
  local function numberOfCellsInTableView(tblView)
    return self.totalCells
  end

  if dataArray == nil then
    echo("empty list data !!!")
    return
  end

  self.node_listContainer:removeAllChildrenWithCleanup(true)

  local size = self.node_listContainer:getContentSize()
  self.cellWidth = size.width
  self.cellHeight = size.height
  self.totalCells = table.getn(dataArray)
  self.tableView = CCTableView:create(size)
  self.tableView:setDirection(kCCScrollViewDirectionHorizontal)

  self.tableView:setTouchPriority(self.touchPriority)
  self.tableView:setBounceable(false)
  self.node_listContainer:addChild(self.tableView)
  self.tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  self.tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  self.tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  self.tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  self.tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)

  self.tableView:reloadData()

  --goto next level cell 
  local player = GameData:Instance():getCurrentPlayer()
  local curLevel = player:getVipLevel() 
  -- if curLevel > 0 and curLevel < 12 then 
  --   local validIdx = curLevel 
  --   for i=1, curLevel do 
  --     if player:getVipBuyRecord(i) == false then 
  --       validIdx = i 
  --       break 
  --     end 
  --   end 
  --   self.curPageIdx = validIdx-1
  --   echo("=====validIdx", validIdx)
  --   self.tableView:setContentOffset(ccp(-self.cellWidth*(validIdx-1), 0))
  -- end 
  echo("=====curLevel", curLevel)
  -- self.tableView:setContentOffset(ccp(-self.cellWidth*curLevel, 0))
  self.curPageIdx = curLevel 
  self.tableView:updateCellAtIndex(self.curPageIdx)
  local moveto = CCMoveTo:create(0.1, ccp(-self.cellWidth*self.curPageIdx, 0))
  self.tableView:getContainer():runAction(moveto)

  self:initGiftIcon(self.curPageIdx)
end 

function ActivityVipInfoView:scrollToPage(page)

  if page < 0 then 
    page = 0
  end 

  if page >= self.totalCells then
    page = self.totalCells - 1
  end
  if self.tableView ~= nil then 
    local destPosX = -page*self.cellWidth
    local moveto = CCMoveTo:create(0.3, ccp(destPosX, self.tableView:getContainer():getPositionY()))
    local easeOut = CCEaseExponentialOut:create(moveto)
    self.tableView:getContainer():runAction(easeOut)

    self:initGiftIcon(page)
  end 
end 

function ActivityVipInfoView:buyVipGift(idx, vipLevel, dropData)
  if self:checkBagSpaceByData(dropData) == false then 
    return 
  end 

  self.curIndex = idx 
  _showLoading()
  local data = PbRegist.pack(PbMsgId.BuyVipGiftC2S, {vip_level=vipLevel})
  net.sendMessage(PbMsgId.BuyVipGiftC2S, data)
  --self.loading = Loading:show()  
  self:addMaskLayer()
end 

function ActivityVipInfoView:buyVipGiftResult(action,msgId,msg)
  echo("=== buyVipGiftResult:", msg.error)

--  if self.loading ~= nil then 
--    self.loading:remove()
--    self.loading = nil
--  end 
  _hideLoading()

  if msg.error == "NO_ERROR_CODE" then 
    local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client)
    for i=1,table.getn(gainItems) do
      local str = string.format("+%d", gainItems[i].count)
      Toast:showIconNumWithDelay(str, gainItems[i].iconId, gainItems[i].iType, gainItems[i].configId, ccp(display.cx,display.cy-i*40), 0.3*(i-1))
    end 
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)

    if self.tableView ~= nil then 
      echo("updateCellAtIndex:", self.curIndex)
      self.tableView:updateCellAtIndex(self.curIndex)
    end 
  elseif msg.error == "NEED_VIP_LEVEL" then 
    Toast:showString(self, _tr("vip_poor_level"), ccp(display.cx, display.cy))

  elseif msg.error == "HAS_BUYED_GIFT" then 
    Toast:showString(self, _tr("has buy,no need buy again"), ccp(display.cx, display.cy))
    
  elseif msg.error == "NEED_MORE_MONEY" then 
    -- Toast:showString(self, _tr("not enough money"), ccp(display.cx, display.cy))
    GameData:Instance():notifyForPoorMoney()
  else
    Toast:showString(self, _tr("system error"), ccp(display.cx, display.cy))
  end 

  self:removeMaskLayer() 
end 

function ActivityVipInfoView:initLabel(stillNeedMoney)
  local curVipLevel = GameData:Instance():getCurrentPlayer():getVipLevel()

  if curVipLevel < 12 then 
    self.node_cahrgeTip:setVisible(true)
    self.label_maxLevelTip:setVisible(false)

    self.label_tip1:setString("")
    local tip1 = ui.newTTFLabelWithOutline( {
                                              text = _tr("vip_charge_again"),
                                              font = self.label_tip1:getFontName(),
                                              size = self.label_tip1:getFontSize(),
                                              x = 0,
                                              y = 0,
                                              color = ccc3(255, 255, 255),
                                              align = ui.TEXT_ALIGN_LEFT,
                                              outlineColor =ccc3(0,0,0),
                                              pixel = 2
                                              }
                                            )
    tip1:setPosition(ccp(self.label_tip1:getPosition()))
    self.label_tip1:getParent():addChild(tip1) 

    self.label_tip2:setString("")
    local tip2 = ui.newTTFLabelWithOutline( {
                                              text = ""..stillNeedMoney,
                                              font = self.label_tip2:getFontName(),
                                              size = self.label_tip2:getFontSize(),
                                              x = 0,
                                              y = 0,
                                              color = ccc3(255, 255, 255),
                                              align = ui.TEXT_ALIGN_LEFT,
                                              outlineColor =ccc3(0,0,0),
                                              pixel = 2
                                              }
                                            )
    tip2:setPosition(ccp(self.label_tip2:getPosition()))
    self.label_tip2:getParent():addChild(tip2) 

    self.label_tip3:setString("")
    local tip3 = ui.newTTFLabelWithOutline( {
                                              text = _tr("vip_will_levelup_to"),
                                              font = self.label_tip3:getFontName(),
                                              size = self.label_tip3:getFontSize(),
                                              x = 0,
                                              y = 0,
                                              color = ccc3(255, 255, 255),
                                              align = ui.TEXT_ALIGN_LEFT,
                                              outlineColor =ccc3(0,0,0),
                                              pixel = 2
                                              }
                                            )
    tip3:setPosition(ccp(self.label_tip3:getPosition()))
    self.label_tip3:getParent():addChild(tip3) 

    self.label_nextLevel:setString(string.format("%d", curVipLevel+1))
    --set position
    local moneyW = self.sprite_money:getContentSize()
    self.sprite_money:setPositionX(tip1:getPositionX()+tip1:getContentSize().width+moneyW.width/2)
    tip2:setPositionX(self.sprite_money:getPositionX()+moneyW.width/2)
    tip3:setPositionX(tip2:getPositionX()+tip2:getContentSize().width)
    local vip2_w = self.sprite_vip2:getContentSize().width 
    self.sprite_vip2:setPositionX(tip3:getPositionX()+tip3:getContentSize().width)
    self.label_nextLevel:setPositionX(self.sprite_vip2:getPositionX()+vip2_w)

  else 
    self.node_cahrgeTip:setVisible(false)
    self.label_maxLevelTip:setVisible(true)
    self.label_maxLevelTip:setString(_tr("vip_level_is_max"))
  end 

  -- self:initGiftIcon(curVipLevel)
end 

function ActivityVipInfoView:initGiftIcon(vipLevel)
  -- VIP x 福利
  local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(string.format("vip_lv_%d.png", vipLevel))
  if frame then 
    self.sprite_vipLevel:setDisplayFrame(frame)  
  end 
  local w = self.sprite_vipLevel:getContentSize().width + 10
  local x = self.sprite_vipLevel:getPositionX()
  self.sprite_vip3:setPositionX(x-w/2)
  self.sprite_fuli:setPositionX(x+w/2)
end 

function ActivityVipInfoView:checkBagSpaceByData(dataArray)

  local function checkBagSpace(_type)
    local isEnough = true 
    local str = " "
    local package = GameData:Instance():getCurrentPackage()

    if _type == 6 and package:checkItemBagEnoughSpace(1) == false then
      str = _tr("bag is full,clean up?")
      isEnough = false 
    elseif _type == 7 and package:checkEquipBagEnoughSpace(1) == false then 
      str = _tr("equip bag is full,clean up?")
      isEnough = false 
    elseif _type == 8 and package:checkEquipBagEnoughSpace(1) == false then 
      str = _tr("card bag is full,clean up?")
      isEnough = false 
    end 
     
    if isEnough == false then
      local pop = PopupView:createTextPopupWithPath({leftNorBtn = "button-nor-zhengli.png",
                                                     leftSelBtn = "button-sel-zhengli.png",
                                                     text = str,
                                                     leftCallBack = function()
                                                        if _type == 6 then 
                                                          self:getDelegate():goToItemView()
                                                        elseif _type == 7 then 
                                                          self:getDelegate():goToEquipBagView()
                                                        else
                                                          self:getDelegate():goToCardBagView()
                                                        end 
                                                    end})
      self:getDelegate():getScene():addChild(pop,100)
    end 
    
    return isEnough
  end 

  --start to check 
  local flag = true 
  if dataArray ~= nil then 
    for k, v in pairs(dataArray) do 
      if checkBagSpace(v.array[1]) == false then 
        flag = false 
        break 
      end 
    end 
  end 

  return flag 
end 

function ActivityVipInfoView:addMaskLayer()
  echo("=== addMaskLayer")
  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
  end 

  self.maskLayer = Mask.new({opacity=0, priority = -1000})
  self:addChild(self.maskLayer)

  self:performWithDelay(handler(self, ActivityVipInfoView.removeMaskLayer), 6.0)
end 

function ActivityVipInfoView:removeMaskLayer()
  echo("=== removeMaskLayer")
  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
    self.maskLayer = nil 
  end 
end 

function ActivityVipInfoView:setIsValidTouch(isValidTouch)
  self._isValidTouch = isValidTouch
end 

function ActivityVipInfoView:getIsValidTouch()
  return self._isValidTouch
end

function ActivityVipInfoView:initTouch()
  self:addTouchEventListener(function(event, x, y)
                                if event == "began" then                                 
                                  local size = self.node_listContainer:getContentSize()
                                  local pos = self.node_listContainer:convertToNodeSpace(ccp(x, y))
                                  if pos.x < 0 or pos.x > size.width or pos.y < 0 or pos.y > size.height then 
                                    self:setIsValidTouch(false)
                                  else 
                                    self:setIsValidTouch(true)
                                  end

                                  return false 
                                end
                            end,
              false, self.touchPriority, true)
  self:setTouchEnabled(true)
end 