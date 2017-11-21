

require("view.BaseView")
require("view.home.DaySurpriseItem")


FestivalGiftView = class("FestivalGiftView", BaseView)

function FestivalGiftView:ctor(isDaySurprise)
  FestivalGiftView.super.ctor(self)

  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("closeCallback",FestivalGiftView.closeCallback)
  pkg:addProperty("node_surprise","CCNode")
  pkg:addProperty("node_container","CCNode")
  pkg:addProperty("sprite_bg","CCSprite")
  pkg:addProperty("layer_mask","CCLayerColor")
  pkg:addProperty("bn_close","CCControlButton")

  local layer,owner = ccbHelper.load("Act_DaySurpriseView.ccbi","DaySurpriseViewCCB","CCLayer",pkg)
  self:addChild(layer)
end

function FestivalGiftView:create()
  local view = FestivalGiftView.new()
  return view
end 

function FestivalGiftView:onEnter()
  echo("=== FestivalGiftView:onEnter")
  self:init()
end 

function FestivalGiftView:onExit()
  echo("=== FestivalGiftView:onExit")
  net.unregistAllCallback(self)
  _hideLoading()   
end 

function FestivalGiftView:init()
  echo("=== FestivalGiftView:init === ")

  self.priority = -200
  net.registMsgCallback(PbMsgId.FestivalGiftResultS2C, self, FestivalGiftView.fetchBonusResutl)

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

  self.bn_close:setTouchPriority(self.priority-11)

  --touch region check
  self:addTouchEventListener(function(event, x, y)
                                if event == "began" then
                                  self.preTouchFlag = self:checkTouchOutsideView(x, y)
                                  return self.preTouchFlag 
                                elseif event == "ended" then
                                  local curFlag = self:checkTouchOutsideView(x, y)
                                  if self.preTouchFlag == true and curFlag == true then
                                    echo(" touch out of region: close popup") 
                                    self:close()
                                  end 
                                end
                            end,
              false, self.priority-10, true)
  self:setTouchEnabled(true)

  --mask layer
  self.layer_mask:addTouchEventListener(function(event, x, y)
                                          return true 
                                        end,
                                        false, self.priority, true)
  self.layer_mask:setTouchEnabled(true)

  --show item list 
  local id 
  self.bonusArray, id = Activity:instance():getFestivalGifBonus()
  self.dayIndex = Activity:instance():getCurrentActDayIndex(id)
  self:showItemList(self.bonusArray)
end 

function FestivalGiftView:checkTouchOutsideView(x, y)

  --outside check 
  local size2 = self.sprite_bg:getContentSize()
  local pos2 = self.sprite_bg:convertToNodeSpace(ccp(x, y))
  if pos2.x < 0 or pos2.x > size2.width or pos2.y < 0 or pos2.y > size2.height then 
    return true 
  end

  --table view rect check
  local size1 = self.node_container:getContentSize()
  local pos1 = self.node_container:convertToNodeSpace(ccp(x, y))
  if pos1.x < 0 or pos1.x > size1.width or pos1.y < 0 or pos1.y > size1.height then 
    self:setIsTouchInViewRect(false)
  else 
    self:setIsTouchInViewRect(true)
  end

  return false  
end 

function FestivalGiftView:setIsTouchInViewRect(isTouchInView)
  self.isTouchInView = isTouchInView
end 

function FestivalGiftView:getIsTouchInViewRect()
  return self.isTouchInView 
end 

function FestivalGiftView:close()
  echo(" FestivalGiftView:close")
  self:removeFromParentAndCleanup(true)
end

function FestivalGiftView:closeCallback()
  self:close()
end 

function FestivalGiftView:fetchBonus(idx)
  echo("fetchBonus, idx =", idx)

  if self:checkDisplayPopToCleanBag(self.bonusArray[idx+1]) == false then 
    self.curIdx = idx
    _showLoading()
    net.sendMessage(PbMsgId.FestivalGiftQueryC2S) 
    
--    if self.loading ~= nil then 
--      self.loading:remove()
--      self.loading = nil
--    end
--    self.loading = Loading:show()  
  end 
end 

function FestivalGiftView:fetchBonusResutl(action,msgId,msg)
  echo("---FestivalGiftView:fetchBonusResutl:", msg.error)
--  if self.loading ~= nil then 
--    self.loading:remove()
--    self.loading = nil
--  end
  _hideLoading()

  if msg.error == "NO_ERROR_CODE" then
    local tbl = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client)
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
    
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)
    if self.tableView ~= nil and self.curIdx ~= nil then 
      self.tableView:updateCellAtIndex(self.curIdx)
    end 
        --update tips
    CCNotificationCenter:sharedNotificationCenter():postNotification(EventType.UPDATE_TIP)
  elseif msg.error == "NOT_OPEN" then 
    Toast:showString(self, _tr("act_not_open"), ccp(display.width/2, display.height*0.4))
  elseif msg.error == "HAS_GET_GIFT" then 
    Toast:showString(self, _tr("has award"), ccp(display.width/2, display.height*0.4))
  else 
    Toast:showString(self, _tr("get_award_faild"), ccp(display.width/2, display.height*0.4))
  end
end

function FestivalGiftView:showItemList(itemArray)

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

    --0: can fetch; 1:has fetch; 2:disable fetch 
    local fetchState = 2 
    local flag = GameData:Instance():getCurrentPlayer():getFestivalGiftFlag()
    if flag > 0 then
      if self.dayIndex == idx + 1 then 
        fetchState = 1 
      else 
        fetchState = 2 
      end 
    else 
      if self.dayIndex == idx + 1 then 
        fetchState = 0 
      else 
        fetchState = 2 
      end 
    end 

    echo("===idx, flag", idx, flag, self.dayIndex, fetchState)
    local node = DaySurpriseItem.new()
    node:setDelegate(self)
    node:setIndex(idx)
    node:setFetchState(fetchState)
    node:setBonus(itemArray[idx+1])
    node:setPositionX((self.cellWidth-540)/2)
    cell:addChild(node)
    return cell
  end
  
  local function numberOfCellsInTableView(tbView)
    return self.totalCells
  end

local function scrollViewDidScroll(view)
  -- echo("====offset:", view:getContentOffset().y)
end 

  echo("remove old tableview")
  self.node_container:removeAllChildrenWithCleanup(true)

  local size = self.node_container:getContentSize()
  self.cellWidth = size.width 
  self.cellHeight = 164
  self.totalCells = #itemArray

  --create tableview
  self.tableView = CCTableView:create(size)
  self.tableView:setDirection(kCCScrollViewDirectionVertical)
  self.tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  self.tableView:setTouchPriority(self.priority-1)
  self.node_container:addChild(self.tableView)

  self.tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  -- self.tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  self.tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  self.tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  self.tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)

  self.tableView:reloadData()

  local flag = GameData:Instance():getCurrentPlayer():getFestivalGiftFlag()
  if flag == 0 then
    local offsetY = math.min(self.tableView:getContentOffset().y+(self.dayIndex-1)*self.cellHeight, 0)
    self.tableView:setContentOffset(ccp(0, offsetY))
  end 
end

function FestivalGiftView:goToItemView() -- 跳到行囊界面
  local controller = ControllerFactory:Instance():create(ControllerType.BAG_CONTROLLER)
  controller:enter()
end

function FestivalGiftView:goToCardBagView() -- 跳到卡牌背包界面
  local controller = ControllerFactory:Instance():create(ControllerType.CARDBAG_CONTROLLER)
  controller:enter(false)
end

function FestivalGiftView:goToEquipBagView() -- 跳到装备背包界面
  local controller = ControllerFactory:Instance():create(ControllerType.CARDBAG_CONTROLLER)
  controller:enter(true)
end

function FestivalGiftView:checkDisplayPopToCleanBag(bonusArray)
  local needClean = false 
  local isEnough1 = true 
  local isEnough2 = true
  local isEnough3 = true
  local str = " "

  for k, v in pairs(bonusArray) do
    if v[1] == 6 then 
      isEnough1 = GameData:Instance():getCurrentPackage():checkItemBagEnoughSpace(1)
      str = _tr("bag is full,clean up?")
    end 
    if v[1] == 8 then 
      isEnough2 = GameData:Instance():getCurrentPackage():checkCardBagEnoughSpace(1)
      str = _tr("card bag is full,clean up?")
    end 
    if v[1] == 7 then 
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
