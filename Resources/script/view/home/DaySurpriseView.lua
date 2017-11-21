

require("view.BaseView")
require("view.home.DaySurpriseItem")


DaySurpriseView = class("DaySurpriseView", BaseView)

function DaySurpriseView:ctor()
  DaySurpriseView.super.ctor(self)

  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("closeCallback",DaySurpriseView.closeCallback)
  pkg:addProperty("node_surprise","CCNode")
  pkg:addProperty("node_container","CCNode")
  pkg:addProperty("sprite_bg","CCSprite")
  pkg:addProperty("layer_mask","CCLayerColor")
  pkg:addProperty("bn_close","CCControlButton")

  local layer,owner = ccbHelper.load("Act_DaySurpriseView.ccbi","DaySurpriseViewCCB","CCLayer",pkg)
  self:addChild(layer)
end


function DaySurpriseView:create()
  local view = DaySurpriseView.new()
  view:init()

  return view
end 

function DaySurpriseView:init()
  echo("=== DaySurpriseView:init === ")

  self.priority = -200

  net.registMsgCallback(PbMsgId.QueryDrawCardRebateResultS2C, self, DaySurpriseView.fetchBonusResutl)


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
  self.bonusArray = Activity:instance():getDaySurpriseBonus()
  self:showItemList(self.bonusArray)
end 

function DaySurpriseView:checkTouchOutsideView(x, y)

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

function DaySurpriseView:setIsTouchInViewRect(isTouchInView)
  self.isTouchInView = isTouchInView
end 

function DaySurpriseView:getIsTouchInViewRect()
  return self.isTouchInView
end 

function DaySurpriseView:onExit()
  echo("=== DaySurpriseView:onExit")
  net.unregistAllCallback(self)
  if self.loading ~= nil then 
    self.loading:remove()
    self.loading = nil
  end    
end 

function DaySurpriseView:close()
  echo(" DaySurpriseView:close")
  -- net.unregistAllCallback(self)
  self:removeFromParentAndCleanup(true)
end

function DaySurpriseView:closeCallback()
  self:close()
end 

function DaySurpriseView:fetchBonus(idx)
  echo("fetchBonus, idx =", idx)
  self.curIdx = idx

  local rebateData = Activity:instance():getDaySurpriseRebateData() 
  if rebateData ~= nil then 
    if idx > rebateData.currentDrawCount then 
      Toast:showString(self, _tr("fetch fron bonus firstly"), ccp(display.width/2, display.height*0.4))
      return 
    end 

    local data = PbRegist.pack(PbMsgId.QueryDrawCardRebateC2S,{id = rebateData.rebateId})
    net.sendMessage(PbMsgId.QueryDrawCardRebateC2S, data)      
  end 
end 

function DaySurpriseView:fetchBonusResutl(action,msgId,msg)
  echo("---DaySurpriseView:fetchBonusResutl:", msg.error)

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

    CCNotificationCenter:sharedNotificationCenter():postNotification(EventType.UPDATE_TIP)
    
  -- elseif msg.error == "NOT_FOUND_ID" then 
  --   Toast:showString(self, _tr("has award"), ccp(display.width/2, display.height*0.4))
  elseif msg.error == "NO_REBATE" then 
    Toast:showString(self, _tr("has award"), ccp(display.width/2, display.height*0.4))
  -- elseif msg.error == "DATE_TIME_OUT" then 
  -- elseif msg.error == "NO_AWARD" then 
  else 
    Toast:showString(self, _tr("get_award_faild"), ccp(display.width/2, display.height*0.4))
  end
end

function DaySurpriseView:showItemList(itemArray)

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

    local fetchState = 0 --can fetch
    local rebateData = Activity:instance():getDaySurpriseRebateData() 
    if rebateData ~= nil then 
      if idx >= rebateData.rebateCount then 
        fetchState = 2 --disable fetch
      elseif idx+1 <= rebateData.currentDrawCount then 
          fetchState = 1 --has fetch
      end 
      echo("=== tableCellAtIndex, idx, fetched , count=", idx, rebateData.currentDrawCount, rebateData.rebateCount)
    end 

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

  --self.tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  -- self.tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  self.tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  self.tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  self.tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)

  self.tableView:reloadData()
end

function DaySurpriseView:goToItemView() -- 跳到行囊界面
  local controller = ControllerFactory:Instance():create(ControllerType.BAG_CONTROLLER)
  controller:enter()
end

function DaySurpriseView:goToCardBagView() -- 跳到卡牌背包界面
  local controller = ControllerFactory:Instance():create(ControllerType.CARDBAG_CONTROLLER)
  controller:enter(false)
end

function DaySurpriseView:goToEquipBagView() -- 跳到装备背包界面
  local controller = ControllerFactory:Instance():create(ControllerType.CARDBAG_CONTROLLER)
  controller:enter(true)
end
