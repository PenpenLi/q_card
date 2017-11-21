
require("view.BaseView")
require("view.home.ActivityMissionItem")
require("view.component.TabControlEx")

ActivityMissionView = class("ActivityMissionView", BaseView)

function ActivityMissionView:ctor()
  ActivityMissionView.super.ctor(self)

  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("closeCallback",ActivityMissionView.closeCallback)
  pkg:addFunc("dayCallback1",ActivityMissionView.dayCallback1)
  pkg:addFunc("dayCallback2",ActivityMissionView.dayCallback2)
  pkg:addFunc("dayCallback3",ActivityMissionView.dayCallback3)
  pkg:addFunc("dayCallback4",ActivityMissionView.dayCallback4)
  pkg:addFunc("dayCallback5",ActivityMissionView.dayCallback5)
  pkg:addFunc("dayCallback6",ActivityMissionView.dayCallback6)
  pkg:addFunc("dayCallback7",ActivityMissionView.dayCallback7)
  pkg:addFunc("onBuyDiscount",ActivityMissionView.onBuyDiscount)
  pkg:addProperty("layer_mask","CCLayerColor")
  pkg:addProperty("node_card","CCNode") 
  pkg:addProperty("node_container","CCNode") 
  pkg:addProperty("node_tab","CCNode") 
  pkg:addProperty("node_discount","CCNode") 
  pkg:addProperty("node_icon","CCNode") 
  pkg:addProperty("sprite_day1","CCSprite") 
  pkg:addProperty("sprite_day2","CCSprite") 
  pkg:addProperty("sprite_day3","CCSprite") 
  pkg:addProperty("sprite_day4","CCSprite") 
  pkg:addProperty("sprite_day5","CCSprite") 
  pkg:addProperty("sprite_day6","CCSprite") 
  pkg:addProperty("sprite_day7","CCSprite") 
  pkg:addProperty("bn_close","CCControlButton")
  pkg:addProperty("bn_day1","CCControlButton")
  pkg:addProperty("bn_day2","CCControlButton")
  pkg:addProperty("bn_day3","CCControlButton")
  pkg:addProperty("bn_day4","CCControlButton")
  pkg:addProperty("bn_day5","CCControlButton")
  pkg:addProperty("bn_day6","CCControlButton")
  pkg:addProperty("bn_day7","CCControlButton")
  pkg:addProperty("bn_buy","CCControlButton")
  pkg:addProperty("label_preLeftTime","CCLabelTTF") 
  pkg:addProperty("label_leftTime","CCLabelTTF") 
  pkg:addProperty("label_iconName","CCLabelTTF") 
  pkg:addProperty("label_oldPrice","CCLabelTTF") 
  pkg:addProperty("label_newPrice","CCLabelTTF") 

  local layer,owner = ccbHelper.load("ActivityMissionView.ccbi","ActivityMissionViewCCB","CCLayer",pkg)
  self:addChild(layer)
  
  self.priority = -200

  self.tabMenus = {
      {"#act_7day_battle0.png",       "#act_7day_battle1.png"},
      {"#act_7day_card0.png",         "#act_7day_card1.png"},
      {"#act_7day_equip_build0.png",  "#act_7day_equip_build1.png"},
      {"#act_7day_task0.png",         "#act_7day_task1.png"},
      {"#act_7day_meiri0.png",        "#act_7day_meiri1.png"},
      {"#act_7day_jingji0.png",       "#act_7day_jingji1.png"},
      {"#act_7day_jingying0.png",     "#act_7day_jingying1.png"},
      {"#act_7day_skill0.png",        "#act_7day_skill1.png"},
      {"#act_7day_soul0.png",         "#act_7day_soul1.png"},
      {"#act_7day_tianfu0.png",      "#act_7day_tianfu1.png"},
      {"#act_7day_zhengzhan0.png",   "#act_7day_zhengzhan1.png"},
      {"#act_7day_dengji0.png",      "#act_7day_dengji1.png"},
      {"#act_7day_equip_xilian0.png", "#act_7day_equip_xilian1.png"},
      {"#act_7day_huaxiong0.png",    "#act_7day_huaxiong1.png"}
    }

end

function ActivityMissionView:onEnter()
  GameData:Instance():getCurrentScene():setBottomVisible(false)

  net.registMsgCallback(PbMsgId.ReqActivityMissionAwardResult,self,ActivityMissionView.fetchBonusResult)
  net.registMsgCallback(PbMsgId.ReqGetOddsAwardResult,self,ActivityMissionView.reqGetOddsAwardResult)
  net.registMsgCallback(PbMsgId.InstanceRefresh,self,ActivityMissionView.resetTimeInfo) --零点更新

  self.bn_close:setTouchPriority(self.priority-1)
  self.bn_day1:setTouchPriority(self.priority-1)
  self.bn_day2:setTouchPriority(self.priority-1)
  self.bn_day3:setTouchPriority(self.priority-1)
  self.bn_day4:setTouchPriority(self.priority-1)
  self.bn_day5:setTouchPriority(self.priority-1)
  self.bn_day6:setTouchPriority(self.priority-1)
  self.bn_day7:setTouchPriority(self.priority-1)
  self.bn_buy:setTouchPriority(self.priority-1)

  self:resetTimeInfo()
  self:showLeftTime()


  local card = _res(1042510)
  if card then 
    card:setScale(300/card:getContentSize().width)
    card:setAnchorPoint(ccp(0.5, 0))
    card:setPosition(ccp(0, -20))
    self.node_card:addChild(card)
  end 

  self.layer_mask:addTouchEventListener(function(event, x, y)
                                          return true 
                                        end,
                                        false, self.priority+1, true)
  self.layer_mask:setTouchEnabled(true)

  -- net.registMsgCallback(PbMsgId.RankInformationS2C, self, ActivityMissionView.updateList)
  self._imgDays = {self.sprite_day1, self.sprite_day2, self.sprite_day3, self.sprite_day4, self.sprite_day5, self.sprite_day6, self.sprite_day7}

  self:highlightInfoByDay(1)

end 

function ActivityMissionView:onExit()
  GameData:Instance():getCurrentScene():setBottomVisible(true)
  net.unregistAllCallback(self)
end 



function ActivityMissionView:highlightInfoByDay(day)
  if day > self.validDayIndex then 
    Toast:showString(self,_tr("act_open_after_%{day}", {day=day}), ccp(display.cx, display.cy))
    return 
  end 

  if self.selectedDay and self.selectedDay == day then 
    return 
  end 

  self.selectedDay = day 

  --highlight icon 
  for i=1, #self._imgDays do 
    self._imgDays[i]:setVisible(i==day)
  end 

  self.missionData = Activity:instance():getActMissionByDay(day)
  self:showMission(self.missionData[1]) --first tab bonus
  self:showTabMenu(self.missionData)
  self:updateDayTips(day)
  self:updateTabTips(day)
end 

function ActivityMissionView:closeCallback()
  self:removeFromParentAndCleanup(true)

  --手动关闭时回到首页，通知首页更新tips状态
  CCNotificationCenter:sharedNotificationCenter():postNotification(EventType.UPDATE_TIP)  
end 

function ActivityMissionView:dayCallback1()
  self:highlightInfoByDay(1)
end 

function ActivityMissionView:dayCallback2()
  self:highlightInfoByDay(2)
end 

function ActivityMissionView:dayCallback3()
  self:highlightInfoByDay(3)
end 

function ActivityMissionView:dayCallback4()
  self:highlightInfoByDay(4)
end 

function ActivityMissionView:dayCallback5()
  self:highlightInfoByDay(5)
end 

function ActivityMissionView:dayCallback6()
  self:highlightInfoByDay(6)
end 

function ActivityMissionView:dayCallback7() 
  self:highlightInfoByDay(7)
end 


function ActivityMissionView:showTabMenu(missionData)
  self.node_tab:removeAllChildrenWithCleanup(true)

  local membership
  local menuArray = {}
  --mission tab 
  if missionData then 
    for k, v in pairs(missionData) do 
      membership = v[1].rawData.membership
      table.insert(menuArray, self.tabMenus[membership])
    end 
  end 

  --discount tab 
  table.insert(menuArray, {"#act_7day_banjia0.png", "#act_7day_banjia1.png"})

  self.tabCtrl = TabControlEx.new(CCSizeMake(552, 57), 160, self.priority-1)
  self.tabCtrl:setDelegate(self)
  self.tabCtrl:setBgVisible(false)
  self.tabCtrl:setPosition(ccp(0, -13))
  self.node_tab:addChild(self.tabCtrl)
  self.tabCtrl:setMenuArray(menuArray)
  self.tabCtrl:setItemSelectedByIndex(1) 
end 

function ActivityMissionView:tabControlOnClick(idx)
  if idx+1 <= #self.missionData then 
    self:showMission(self.missionData[idx+1])
    self:updateTabTips(idx+1)
  else 
    self:showDisCountInfo(self.selectedDay)
  end 
end 

function ActivityMissionView:setIsValidTouch(isTouch)
  self._isValidTouch = isTouch
end 

function ActivityMissionView:getIsValidTouch()
  return self._isValidTouch
end 

function ActivityMissionView:showMission(dataArray)

  local function tableCellTouched(tbView,cell)
    self:setIsValidTouch(true)
  end
  
  local function tableCellAtIndex(tbView, idx)
    local item = nil
    local cell = tbView:dequeueCell()
    if cell == nil then
      cell = CCTableViewCell:new()
      item = ActivityMissionItem.new(self.priority)
      item:setDelegate(self)
      item:setData(dataArray[idx+1])
      item:setIndex(idx)
      item:setTag(100)
      cell:addChild(item)
    else 
      item = cell:getChildByTag(100)
      if item ~= nil then
        item:setData(dataArray[idx+1])
        item:setIndex(idx)
      end
    end

    return cell
  end

  local function cellSizeForTable(tbView,idx)
    return self.cellHeight, self.cellWidth
  end 

  local function numberOfCellsInTableView(tbView)
    return self.totalCells
  end

  self.totalCells = #dataArray 
  self.cellWidth = 535
  self.cellHeight = 146

  echo("remove old tableview")
  self.node_container:removeAllChildrenWithCleanup(true)
  self.node_discount:setVisible(false)

  --create tableview
  self.tableView = CCTableView:create(self.node_container:getContentSize())
  self.tableView:setDirection(kCCScrollViewDirectionVertical)
  self.tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  self.tableView:setTouchPriority(self.priority-1)
  self.node_container:addChild(self.tableView)

  --self.tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  self.tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  self.tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  self.tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  self.tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  self.tableView:reloadData()
end 

function ActivityMissionView:showDisCountInfo(day)
  echo("showDisCountInfo", day)

  local buyFlag = Activity:instance():getActMissDisCountBuyFlag(day) 
  self.node_discount:setVisible(true)
  
  self.node_container:removeAllChildrenWithCleanup(true)
  self.node_icon:removeAllChildrenWithCleanup(true)
  self.bn_buy:setEnabled(not buyFlag)

  local function tipsCallback(obj, configId, pos)
    if self.node_discount:isVisible() then 
      TipsInfo:showTip(obj, configId, nil, pos, nil, true)
    end 
  end 

  self.discountArray = {}
  local item = AllConfig.activity_odds[day]
  if item then 
    --set icon & name 
    local dropId = item.bonus[1] 
    local drop_data = AllConfig.drop[dropId].drop_data 
    local props = drop_data[1].array 
    local configId = props[2] > 100 and props[2] or props[1]
    local tipArgs = {callbackFunc=tipsCallback, priority = self.priority}
    local icon = GameData:Instance():getCurrentPackage():getItemSprite(nil, props[1], configId, props[3],nil, tipArgs) 
    if icon then 
      icon:setScale(0.9)
      self.node_icon:addChild(icon)

      local name = ""
      if props[1] == 7 then 
        name = AllConfig.equipment[configId].name 
      elseif props[1] == 8 then 
        name = AllConfig.unit[configId].unit_name 
      else 
        if AllConfig.item[configId] then 
          name = AllConfig.item[configId].item_name 
        end 
      end 
      self.label_iconName:setString(name)

      table.insert(self.discountArray, props)
    end 

    --set price
    self.label_oldPrice:setString(_tr("old_price_%{num}", {num=item.cost_originalprice}))
    self.label_newPrice:setString(_tr("new_price_%{num}", {num=item.cost}))
  end 
end 

function ActivityMissionView:fetchBonus(idx, itemData)
  echo("===fetchBonus ")
  --req data 
  _showLoading()
  local data = PbRegist.pack(PbMsgId.ReqActivityMissionAward, {activity_type=itemData.rawData.activity_type, mission_id=itemData.rawData.id})
  net.sendMessage(PbMsgId.ReqActivityMissionAward,data)

--  self.loading = Loading:show() 
  self:addMaskLayer()
  self.curIdx = idx 
end 

function ActivityMissionView:fetchBonusResult(action,msgId,msg)
  echo("=== fetchBonusResult:", msg.state)

--  if self.loading ~= nil then 
--    self.loading:remove()
--    self.loading = nil
--  end 
  _hideLoading()

  if msg.state == "Ok" then 
    --toast bonus 
    local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client_sync)
    for i = 1,table.getn(gainItems) do
      local str = string.format("+%d", gainItems[i].count)
      Toast:showIconNumWithDelay(str, gainItems[i].iconId, gainItems[i].iType, gainItems[i].configId, ccp(display.cx,display.cy-i*40), 0.3*(i-1))
    end

    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
    Activity:instance():setActMissionState(msg.mission_id, true, nil, nil)

    if self.tableView then 
      self.tableView:updateCellAtIndex(self.curIdx)
    end 
  else
    Shop:instance():handleErrorCode(msg.state)
  end 

  self:removeMaskLayer()
end 

function ActivityMissionView:onBuyDiscount()
  if self.node_discount:isVisible() then 
    local item = AllConfig.activity_odds[self.selectedDay] 
    local curMoney = GameData:Instance():getCurrentPlayer():getMoney() 
    if curMoney < item.cost then 
      -- Toast:showString(curScene, _tr("not enough money"), ccp(display.cx, display.cy))   
      GameData:Instance():notifyForPoorMoney()  
      return 
    end 

    if self.discountArray and Activity:instance():checkHasEnoughSpace(self.discountArray) == false then 
      return 
    end 


    echo("=== onBuyDiscount, id:", item.id)
    _showLoading()
    local data = PbRegist.pack(PbMsgId.ReqGetOddsAward, {activity_id=item.id})
    net.sendMessage(PbMsgId.ReqGetOddsAward,data)

    --self.loading = Loading:show() 
    self:addMaskLayer() 

    self.bn_buy:setEnabled(false)
  end 
end 

function ActivityMissionView:reqGetOddsAwardResult(action,msgId,msg)
  echo("=== reqGetOddsAwardResult:", msg.state)

--  if self.loading ~= nil then 
--    self.loading:remove()
--    self.loading = nil
--  end 
  _hideLoading()

  if msg.state == "Ok" then 
    local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client_sync)
    for i = 1,table.getn(gainItems) do
      local str = string.format("+%d", gainItems[i].count)
      Toast:showIconNumWithDelay(str, gainItems[i].iconId, gainItems[i].iType, gainItems[i].configId, ccp(display.cx,display.cy-i*40), 0.3*(i-1))
    end

    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync) 

    Activity:instance():setActMissionState(nil, nil, self.selectedDay, true)

  else
    Shop:instance():handleErrorCode(msg.state)
    self.bn_buy:setEnabled(true)
  end 
  self:removeMaskLayer()
end 

function ActivityMissionView:addMaskLayer()
  echo("=== addMaskLayer")
  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
  end 

  self.maskLayer = Mask.new({opacity=0, priority = -1000})
  self:addChild(self.maskLayer)

  self:performWithDelay(handler(self, ActivityMissionView.removeMaskLayer), 6.0)
end 

function ActivityMissionView:removeMaskLayer()
  echo("=== removeMaskLayer")
  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
    self.maskLayer = nil 
  end 
end 

function ActivityMissionView:showLeftTime()

  local function getTimeStr(timeSec)
    local str = "00:00:00"
    if timeSec > 24 * 3600 then 
      str = _tr("day %{count}", {count=math.floor(timeSec/(24*3600))})
    elseif timeSec > 0 then  
      local hour = math.floor(timeSec/3600)
      local min = math.floor((timeSec-hour*3600)/60)
      local sec = timeSec - hour*3600 - min*60
      str = string.format("%02d:%02d:%02d", hour, min, sec)
    end 

    return str 
  end 

  local function updataCloseTime(dt)
    self.leftSec = self.leftSec - 1 

    if self.leftSec <= 0 then
      self.label_leftTime:setString("00:00:00")
      if self.closeTimer ~= nil then 
        self:unschedule(self.closeTimer)
        self.closeTimer = nil 
      end 
    else 
      self.label_leftTime:setString(getTimeStr(self.leftSec))
    end
  end

  self.label_preLeftTime:setString(_tr("rebase left time"))

  if self.closeTimer ~= nil then 
    self:unschedule(self.closeTimer)
    self.closeTimer = nil 
  end 

  if self.leftSec > 0 then 
    self.label_leftTime:setString(getTimeStr(self.leftSec))
    self.closeTimer = self:schedule(updataCloseTime, 1.0)
  else 
    self.label_leftTime:setString("00:00:00")
  end 
  echo("===showLeftTime:left", self.leftSec)
end 

function ActivityMissionView:updateDayTips(exceptDay)
  if self.dayTips == nil then 
    self.dayTips = {}
    local tbl = {self.sprite_day1, self.sprite_day2, self.sprite_day3, self.sprite_day4, self.sprite_day5, self.sprite_day6, self.sprite_day7}
    local tip, size, pos 
    for i=1, #tbl do 
      size = tbl[i]:getContentSize()
      pos = ccpAdd(ccp(tbl[i]:getPosition()), ccp(size.width/2-10, size.height/2-3))
      tip = TipPic.new() 
      tip:setPosition(pos)
      tbl[i]:getParent():addChild(tip)
      self.dayTips[i] = tip 
    end 
  end 

  local stateArray,_ = Activity:instance():getActMissionTipsState()
  for i=1, 7 do 
    self.dayTips[i]:setVisible(stateArray[i] and (i <= self.validDayIndex))
  end 

  --当前选中不显示tips
  self.dayTips[exceptDay]:setVisible(false)
end

function ActivityMissionView:updateTabTips(exceptId)
  local tbl = {false, false}

  for i, items in pairs(self.missionData) do 
    for k, v in pairs(items) do 
      if v.award_is_get < 1 and ((v.rawData.jump_type~=18 and v.progress>=v.rawData.var) or (v.rawData.jump_type==18 and (v.progress > 0 and v.progress<=v.rawData.var))) then 
        tbl[i] = true 
        break 
      end        
    end 
  end 

  for i=1, #self.missionData do 
    self.tabCtrl:setTipImgVisible(i, tbl[i])   
  end 

  if exceptId and exceptId <= #self.missionData then 
    self.tabCtrl:setTipImgVisible(exceptId, false)
  end 
end 


function ActivityMissionView:resetTimeInfo()
  self.leftSec = Activity:instance():getIsServerOpenActValid() 
  self.validDayIndex = 7 - math.floor(self.leftSec/(24*3600))
  echo("====leftSec, validDayIndex", self.leftSec, self.validDayIndex)
end 
