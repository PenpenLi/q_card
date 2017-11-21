

require("view.BaseView")
require("model.home.Liveness")


LivenessDayView = class("LivenessDayView", BaseView)

function LivenessDayView:ctor()
  LivenessDayView.super.ctor(self)

  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("closeCallback",LivenessDayView.closeCallback)
  pkg:addFunc("giftCallback1",LivenessDayView.giftCallback1)
  pkg:addFunc("giftCallback2",LivenessDayView.giftCallback2)
  pkg:addFunc("giftCallback3",LivenessDayView.giftCallback3)
  pkg:addFunc("giftCallback4",LivenessDayView.giftCallback4)
  pkg:addFunc("giftCallback5",LivenessDayView.giftCallback5)
  pkg:addFunc("giftCallback6",LivenessDayView.giftCallback6)
  pkg:addProperty("node_liveness","CCNode")
  pkg:addProperty("node_container","CCNode")
  pkg:addProperty("node_progress","CCNode")
  pkg:addProperty("node_box1","CCNode")
  pkg:addProperty("node_box2","CCNode")
  pkg:addProperty("node_box3","CCNode")
  pkg:addProperty("node_box4","CCNode")
  pkg:addProperty("node_box5","CCNode")
  pkg:addProperty("node_box6","CCNode")
  pkg:addProperty("sprite_bg","CCSprite")
  pkg:addProperty("sprite_arrow","CCSprite")
  pkg:addProperty("label_liveness","CCLabelTTF")
  pkg:addProperty("label_value1","CCLabelBMFont")
  pkg:addProperty("label_value2","CCLabelBMFont")
  pkg:addProperty("label_value3","CCLabelBMFont")
  pkg:addProperty("label_value4","CCLabelBMFont")
  pkg:addProperty("label_value5","CCLabelBMFont")
  pkg:addProperty("label_value6","CCLabelBMFont")
  pkg:addProperty("bn_gift1","CCControlButton")
  pkg:addProperty("bn_gift2","CCControlButton")
  pkg:addProperty("bn_gift3","CCControlButton")
  pkg:addProperty("bn_gift4","CCControlButton")
  pkg:addProperty("bn_gift5","CCControlButton")
  pkg:addProperty("bn_gift6","CCControlButton")
  pkg:addProperty("bn_close","CCControlButton")


  local layer,owner = ccbHelper.load("LivenessDayView.ccbi","LivenessDayViewCCB","CCLayer",pkg)
  self:addChild(layer)
end


function LivenessDayView:createLivenessDayView()
  local view = LivenessDayView.new()
  view:init()
  return view
end 

function LivenessDayView:init()
  echo("=== LivenessDayView:init === ")

  self.priority = -200
  self.node_liveness:setPositionX(display.cx)

  net.registMsgCallback(PbMsgId.AskForLivenessPointGiftResult,self,LivenessDayView.fetchBonusResutl)
  self.dataArray = Liveness:instance():getValidLivenessItems()


  local player = GameData:Instance():getCurrentPlayer()
  local gainedValue = player:getGainedLivenessValue()
  local totalValue = player:getTotalLivenessVal()
  local percent = 0
  self.totalCells = table.getn(self.dataArray)
  echo("==== totalValue, totalCells=", totalValue, self.totalCells)

  if totalValue ~=nil and gainedValue ~= nil then 
    self.label_liveness:setString(string.format("%d/%d", gainedValue, totalValue))
    percent = math.min(100, 100*gainedValue/300)
  end 

  --set btn and label 
  local labelArr = {self.label_value1, self.label_value2, self.label_value3, self.label_value4, self.label_value5,self.label_value6}
  self.bnArr = {self.bn_gift1, self.bn_gift2, self.bn_gift3, self.bn_gift4, self.bn_gift5, self.bn_gift6}
  self.boxNodeArr = {self.node_box1, self.node_box2, self.node_box3, self.node_box4, self.node_box5, self.node_box6}

  self.bonusInfo = Liveness:instance():getLivenessBonusArray()

  local boxAnimIndex = -1
  for i=1, 6 do 
    if gainedValue >= self.bonusInfo[i].value then 
      labelArr[i]:setFntFile("img/client/widget/words/card_name/lead_number_nor.fnt")
    else 
      labelArr[i]:setFntFile("img/client/widget/words/card_name/lead_number_huise.fnt")
    end 
    labelArr[i]:setString(string.format("%d", self.bonusInfo[i].value))

    self.bnArr[i]:setTouchPriority(self.priority-3)
    if gainedValue ~= nil and gainedValue >= self.bonusInfo[i].value then 
      boxAnimIndex = i 
    end 
  end 
  self.bn_close:setTouchPriority(self.priority-3)

  --top circle anim
  local bgSize = self.sprite_bg:getContentSize()
  local imgCircle = _res(3022057)
  if imgCircle ~= nil then
    imgCircle:setPosition(ccp(bgSize.width/2, bgSize.height-40))
    local action = CCRotateBy:create(2.7, 360)
    imgCircle:runAction(CCRepeatForever:create(action))
    self.sprite_bg:addChild(imgCircle,-1)
  end 

  --top star anim
  local starAnim = _res(6010020)
  if starAnim ~= nil then 
    starAnim:setPosition(ccp(bgSize.width/2, bgSize.height-40))
    self.sprite_bg:addChild(starAnim, 10)
  end

  --box anim 
  if boxAnimIndex > 0 then 
    --play anim from has awarded index to boxAnimIndex
    for i=1, boxAnimIndex do 
      local awardFlag = player:getLivenessAwardInfo(i)
      echo("====awardInfo:", i, awardFlag)
      if awardFlag < 1 then 
        self:setBoxAnimState(i, true)
      else 
        self:setBoxAnimState(i, false)
      end 
    end 
  end 

  local action = CCSequence:createWithTwoActions(CCFadeTo:create(0.8, 100),CCFadeTo:create(1.0, 255))
  self.sprite_arrow:runAction(CCRepeatForever:create(action))

  --progress bar
  local progressBg = CCSprite:createWithSpriteFrameName("live_progress0.png")
  local progressFg = CCSprite:createWithSpriteFrameName("live_progress1.png")
  self.progresser = ProgressBarView.new(progressBg, progressFg)
  self.progresser:setPercent(percent, 1)
  self.node_progress:addChild(self.progresser)  

  --regist touch
  -- self:addTouchEventListener(function(event, x, y)
  --                               if event == "began" then
  --                                 self.preTouchFlag = self:checkTouchOutsideView(x, y)
  --                                 return true 
  --                               elseif event == "ended" then
  --                                 local curFlag = self:checkTouchOutsideView(x, y)
  --                                 if self.preTouchFlag == true and curFlag == true then
  --                                   echo(" touch out of region: close popup") 
  --                                   self:close()
  --                                 end 
  --                               end
  --                           end,
  --             false, self.priority, true)
  -- self:setTouchEnabled(true)

  --show item list 
  self:showLivenessItemList(self.dataArray)
end 


function LivenessDayView:checkTouchOutsideView(x, y)
  local size = self.sprite_bg:getContentSize()
  local pos = self.sprite_bg:convertToNodeSpace(ccp(x, y))
  if pos.x < 0 or pos.x > size.width or pos.y < 0 or pos.y > size.height then 
    return true 
  end
  return false  
end 

function LivenessDayView:onExit()
  echo("=== LivenessDayView:onExit")
  net.unregistAllCallback(self)
--  if self.loading ~= nil then 
--    self.loading:remove()
--    self.loading = nil
--  end   
  _hideLoading() 
end 

function LivenessDayView:close()
  echo(" LivenessDayView:close")
  -- net.unregistAllCallback(self)
  -- self:removeFromParentAndCleanup(true)
  -- if self.loading ~= nil then 
  --   self.loading:remove()
  --   self.loading = nil
  -- end  
  if self:getDelegate() ~= nil then 
    self:getDelegate():closeLivenessViews()
  end 
end

function LivenessDayView:setBoxAnimState(index, bAnim)
  if index > 0 then 
    if bAnim == true then 
      local array = CCArray:create()
      array:addObject(CCRotateBy:create(0.1, -10))
      array:addObject(CCRotateBy:create(0.2, 20))
      array:addObject(CCRotateBy:create(0.1, -10))
      local seq = CCSequence:create(array)
      self.bnArr[index]:runAction(CCRepeatForever:create(seq))

      local imgCircle = _res(3022057)
      if imgCircle ~= nil then
        imgCircle:setScale(0.2)
        imgCircle:setPosition(ccp(0, 0))
        local action = CCRotateBy:create(3.0, 360)
        imgCircle:runAction(CCRepeatForever:create(action))
        self.boxNodeArr[index]:addChild(imgCircle)
      end 

      local starAni = _res(6010021)
      if starAni ~= nil then 
        starAni:setPosition(ccp(0, 0))
        self.boxNodeArr[index]:addChild(starAni)
      end     
    else 
      self.bnArr[index]:stopAllActions()
      self.bnArr[index]:setRotation(0)
      self.bnArr[index]:setEnabled(false) --has reward
      self.boxNodeArr[index]:removeAllChildrenWithCleanup(true)
    end 
  end 
end 

function LivenessDayView:checkDisplayPopToCleanBag(bonusArray)
  local needClean = false 
  local isEnough1 = true 
  local isEnough2 = true
  local isEnough3 = true
  local str = " "


  for k, v in pairs(bonusArray) do
    if v.iType == 6 then 
      isEnough1 = GameData:Instance():getCurrentPackage():checkItemBagEnoughSpace(1)
      str = _tr("bag is full,clean up?")
    end 
    if v.iType == 8 then 
      isEnough2 = GameData:Instance():getCurrentPackage():checkCardBagEnoughSpace(1)
      str = _tr("card bag is full,clean up?")
    end 
    if v.iType == 7 then 
      isEnough3 = GameData:Instance():getCurrentPackage():checkEquipBagEnoughSpace(1)
      str = _tr("equip bag is full,clean up?")
    end     
  end 

  if (isEnough1 == false) or (isEnough2 == false) or (isEnough3 == false) then
    local pop = PopupView:createTextPopupWithPath({leftNorBtn = "button-nor-zhengli.png",
                                                   leftSelBtn = "button-sel-zhengli.png",
                                                   text = str,
                                                   leftCallBack = function()
                                                      if isEnough1 == false then
                                                        return self:goToItemView()
                                                      end 
                                                      if isEnough2 == false then 
                                                        return self:goToCardBagView()
                                                      end
                                                      if isEnough3 == false then 
                                                        return self:goToEquipBagView()
                                                      end
                                                  end})
    self:addChild(pop,100)
    needClean = true
  end 

  return needClean
end 


function LivenessDayView:giftCallback1()
  self:fetchCallback(1)
end 

function LivenessDayView:giftCallback2()
  self:fetchCallback(2)
end 

function LivenessDayView:giftCallback3()
  self:fetchCallback(3)
end 

function LivenessDayView:giftCallback4()
  self:fetchCallback(4)
end 

function LivenessDayView:giftCallback5()
  self:fetchCallback(5)
end 

function LivenessDayView:giftCallback6()
  self:fetchCallback(6)
end 

function LivenessDayView:closeCallback()
  self:close()
end 

function LivenessDayView:fetchCallback(bonusIndex)
  _playSnd(SFX_CLICK)

  local bonusArray = self.bonusInfo[bonusIndex].bonus 
  if self:checkDisplayPopToCleanBag(bonusArray) == true then 
    return 
  end 

  local function startToGetBonus(isOk)
    echo("startToGetBonus--", isOk)
    if isOk == true then
      _showLoading()
      local data = PbRegist.pack(PbMsgId.AskForLivenessPointGift, {award_id = bonusIndex})
      net.sendMessage(PbMsgId.AskForLivenessPointGift, data)
      --self.loading = Loading:show()
    end
  end

  local pop = PopupView:createBonusPopup(bonusArray, startToGetBonus, false)
  local title = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("huoyuedulingjiang.png")
  if title ~= nil then 
    pop.sprite5_title:setDisplayFrame(title)
  end 
  local player = GameData:Instance():getCurrentPlayer()
  local gainedValue = player:getGainedLivenessValue()
  
  local flag = player:getLivenessAwardInfo(bonusIndex)
  if flag >= 1 or gainedValue < self.bonusInfo[bonusIndex].value then --has fetch or poor condition, then disable menu
    local disFrame = CCSprite:createWithSpriteFrameName("lingqu2.png")
    pop.bn_startReward:setDisabledImage(disFrame)
    pop.bn_startReward:setEnabled(false)
  end

  self:addChild(pop)
end 

function LivenessDayView:fetchBonusResutl(action,msgId,msg)
  echo("---LivenessDayView:fetchBonusResutl, boxId=", msg.state, msg.award_id)

--  if self.loading ~= nil then 
--    self.loading:remove()
--    self.loading = nil
--  end
  _hideLoading()

  if msg.state == "Ok" then 
    local tbl = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client_sync)
    if tbl ~= nil then
      local offsetY = (table.getn(tbl) - 1) * 50
      for k,v in pairs(tbl) do 
        echo("---gain: ", v.configId)
        local numStr = string.format("+%d", v.count)
        offsetY = offsetY - 90
        Toast:showIconNumWithDelay(numStr, v.iconId, v.iType, v.configId, ccp(display.width/2, display.height*0.4 + offsetY), 0.5*(k-1))
      end
      
      _playSnd(SFX_ITEM_ACQUIRED)
    end

    local player = GameData:Instance():getCurrentPlayer()
    if self:getParent() ~= nil then 
      self:setBoxAnimState(msg.award_id, false)
    else 
      echo("==== LivenessDayView parent is nil !!!!")
    end 
    player:setLivenessAwardInfo(msg.award_id, 1)
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
    --update tips
    CCNotificationCenter:sharedNotificationCenter():postNotification(EventType.UPDATE_TIP)

  elseif msg.state == "HasReceived" then 
    Toast:showString(self, _tr("has award"), ccp(display.width/2, display.height*0.4))
  elseif msg.state == "NeedPoint" then 
    Toast:showString(self, _tr("not enought liveness"), ccp(display.width/2, display.height*0.4))
  end
end

function LivenessDayView:showLivenessItemList(itemArray)

  -- local function tableCellTouched(tbView,cell)
  -- end
  
  local function cellSizeForTable(tbView,idx)
    return self.cellHeight,self.cellWidth
  end
  
  local function tableCellAtIndex(tbView, idx)
    local cell = tbView:dequeueCell()
    if nil == cell then
      cell = CCTableViewCell:new()
    else
      cell:removeAllChildrenWithCleanup(true)
    end

    local item = itemArray[idx+1] --GameData:Instance():getCurrentPlayer():getLivenessItem(idx)
    local fontName = "Courier-Bold"
    local fontSize = 22 
    local labelDesc = CCLabelTTF:create(item.desc, fontName, fontSize)
    labelDesc:setColor(ccc3(255, 239, 165))
    labelDesc:setPosition(ccp(labelDesc:getContentSize().width/2, self.cellHeight/2))
    cell:addChild(labelDesc)

    -- local strTimes = string.format("(%d/%d)", item.counts, item.countsMax)
    local strTimes = string.format("(%d/%d)", item.counts, item.totalCounts)
    local labelTimes = CCLabelTTF:create(strTimes, fontName, fontSize)
    labelTimes:setColor(ccc3(2, 233, 236))
    labelTimes:setPosition(ccp(300, self.cellHeight/2))
    cell:addChild(labelTimes)

    --label 
    if item.gainedVal > 0 then 
      local label = CCLabelTTF:create(string.format("+%d", item.gainedVal), fontName, fontSize)
      label:setColor(ccc3(6, 255, 0))
      label:setPosition(ccp(380, self.cellHeight/2))
      cell:addChild(label)
    end 

    local sprite = nil 
    if item.id < 0 then 
      sprite = CCSprite:createWithSpriteFrameName("live_done.png")
      sprite:setPosition(ccp(self.cellWidth-sprite:getContentSize().width/2-20, self.cellHeight/2))
      cell:addChild(sprite)
    else 
      sprite = CCSprite:createWithSpriteFrameName("live_goto.png")
      if sprite ~= nil then 
        local menu = CCMenu:create()
        menu:setTouchPriority(self.priority-3)
        local menuItem = CCMenuItemSprite:create(sprite, nil, nil)
        menuItem:registerScriptTapHandler(handler(self, LivenessDayView.gotoView))
        menuItem:setTag(item.iType)
        menu:addChild(menuItem)
        menu:setPosition(ccp(self.cellWidth-menuItem:getContentSize().width/2-20, self.cellHeight/2))
        cell:addChild(menu)

        if Liveness:instance():checkHasTipForItem(item) then 
          local tip = TipPic.new() 
          local x, y = menu:getPosition()
          tip:setPosition(ccp(x-60, y))
          cell:addChild(tip)
        end 
      end       
    end  

    return cell
  end
  
  local function numberOfCellsInTableView(tbView)
    return self.totalCells
  end


  echo("remove old tableview")
  self.node_container:removeAllChildrenWithCleanup(true)

  local size = self.node_container:getContentSize()
  self.cellWidth = size.width 
  self.cellHeight = 60

  --create tableview
  local tableView = CCTableView:create(size)
  tableView:setDirection(kCCScrollViewDirectionVertical)
  tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  tableView:setTouchPriority(self.priority-1)
  self.node_container:addChild(tableView)

  --tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  -- tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)

  tableView:reloadData()
end

function LivenessDayView:goToItemView() -- 跳到行囊界面
  local controller = ControllerFactory:Instance():create(ControllerType.BAG_CONTROLLER)
  controller:enter()
end

function LivenessDayView:goToCardBagView() -- 跳到卡牌背包界面
  local controller = ControllerFactory:Instance():create(ControllerType.CARDBAG_CONTROLLER)
  controller:enter(false)
end

function LivenessDayView:goToEquipBagView() -- 跳到装备背包界面
  local controller = ControllerFactory:Instance():create(ControllerType.CARDBAG_CONTROLLER)
  controller:enter(true)
end

function LivenessDayView:gotoView(idx)
  echo("=== gotoView:", idx, type(idx))

  local entryFlag = true

  if idx ~=nil and type(idx) == "number" then  
    --check condition
    local canEntry, str = Liveness:instance():getConditionByType(idx)
    if canEntry == false then 
      Toast:showString(self, str, ccp(display.cx, display.height*0.4))
      return
    end 

    GameData:Instance():pushViewType(ViewType.liveness)

    if idx == 0 then --矿场
      local controller = ControllerFactory:Instance():create(ControllerType.MINING_CONTROLLER)
      controller:enter()

    elseif idx == 1 or idx == 19 then --日常任务
      local controller = ControllerFactory:Instance():create(ControllerType.QUEST_CONTROLLER)
      controller:enter(nil)
      controller:gotoDailyTask()

    elseif idx == 2 or idx == 3 then --点将
      local controller = ControllerFactory:Instance():create(ControllerType.LOTTERY_CONTROLLER)
      controller:enter()

    elseif idx == 4 then --官职俸禄
      local controller = ControllerFactory:Instance():create(ControllerType.ACHIEVEMENT_CONTROLLER)
      controller:enter(AchievementType.Official)

    elseif idx == 5 then --精英副本
      if Scenario:Instance():getLastEliteCheckPoint() ~= nil then
        local controller = ControllerFactory:Instance():create(ControllerType.SCENARIO_CONTROLLER)
        controller:enter()
        controller:gotoEliteStage()
      else
        Toast:showString(GameData:Instance():getCurrentScene(),_tr("elite not open"), ccp(display.cx, display.height*0.4))
      end
    elseif idx == 6 then --征战
      local controller = ControllerFactory:Instance():create(ControllerType.EXPEDITION_CONTROLLER)
      controller:enter()

    elseif idx == 7 or idx == 8 then --犒赏三军
      Activity:instance():entryActView(ActMenu.ARMY, false)

    elseif idx == 9 then --每日登陆(每日签到)
      -- Activity:instance():entryActView(ActMenu.DAILY_SIGNIN, false)

    elseif idx == 10 or idx == 11 then --boss
      Activity:instance():entryActView(ActMenu.BOSS, false)

    elseif idx == 12 then --活动VIP签到
      Activity:instance():entryActView(ActMenu.VIP_SIGNIN, false)

    elseif idx == 13 then --活动摇钱树
      Activity:instance():entryActView(ActMenu.MONEY_TREE, false)

    elseif idx == 14 then --商城集市
      local controller = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
      controller:enter(ShopCurViewType.JiShi)

    elseif idx == 15 then --升级
      local controller = ControllerFactory:Instance():create(ControllerType.BAG_CONTROLLER)
      controller:enter()  

    elseif idx == 16 then --修行
      local controller = ControllerFactory:Instance():create(ControllerType.LEVELUP_CONTROLLER)
      controller:enter(4, nil)

    elseif idx == 17 then --商城特惠
      local controller = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
      controller:enter(ShopCurViewType.TeHui)

    elseif idx == 18 then --商城典藏购买体力丹
      local controller = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
      controller:enter(ShopCurViewType.DianCang)
      
    elseif idx == 20 then --普通关卡
      local stage = Scenario:Instance():getLastNormalStage()
      local controller = ControllerFactory:Instance():create(ControllerType.SCENARIO_CONTROLLER)
      controller:enter()
      controller:gotoStageById(stage:getStageId())
    else 
      echo("==== invalid liveness type !!!!")
      GameData:Instance():popViewType() --当前页面不入栈
    end 

    if entryFlag == true then 
      self:close()
    end
  end 
end 

function LivenessDayView:getContentRect()
  local size = self.sprite_bg:getContentSize()
  local ap = self.sprite_bg:getAnchorPoint()
  local x, y = self.sprite_bg:getPosition()
  local orgPos = ccp(x-size.width*ap.x, y-size.height*ap.y)
  local pos = self.sprite_bg:getParent():convertToWorldSpace(orgPos)
  local offsetX = (display.width-size.width)/2
  return CCRectMake(pos.x+offsetX, pos.y, size.width, size.height)
end 
