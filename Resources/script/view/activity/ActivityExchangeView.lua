require("view.BaseView")
require("view.component.Loading")
require("view.component.PopupView")
require("view.activity.ActivityExchangeListItem")


ActivityExchangeView = class("ActivityExchangeView", BaseView)


function ActivityExchangeView:ctor(menuIndex)
  ActivityExchangeView.super.ctor(self)

  --1. load levelup view ccbi
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("sprite_title","CCSprite")
  pkg:addProperty("node_title","CCNode")
  pkg:addProperty("node_listContainer","CCNode")
  pkg:addProperty("label_preLeftTime","CCLabelTTF")
  pkg:addProperty("label_leftTime","CCLabelTTF")

  local layer,owner = ccbHelper.load("ActivityExchangeView.ccbi","ActivityExchangeViewCCB","CCLayer",pkg)
  self:addChild(layer)

  self.label_preLeftTime:setString(_tr("left time"))

  -- self.label_preLeftTime:setVisible(false)
  -- self.label_leftTime:setVisible(false)
    
  if menuIndex == ActMenu.EXCHANGE then --Q卡兑换
    self.actId = ACI_ID_EXCHANGE
  elseif menuIndex == ActMenu.ZHONG_QIU then --中秋兑换
    self.actId = ACI_ID_MID_AUTUMN
    local sprite = CCSprite:create("img/activity/exchange_zhongqiujie.png")
    sprite:setPosition(ccp(self.sprite_title:getPosition()))
    self.sprite_title:getParent():addChild(sprite)
    self.sprite_title:removeFromParentAndCleanup(true)
    self.sprite_title = sprite
    -- self.sprite_title:setTexture(sprite:getTexture())
  end 

  self.node_title:setContentSize(self.sprite_title:getContentSize())
end

function ActivityExchangeView:init()
  echo("---ActivityExchangeView:init---")
  
  net.registMsgCallback(PbMsgId.UseWordGameItemResultS2C, self, ActivityExchangeView.exchangeResult)
  net.registMsgCallback(PbMsgId.InstanceRefresh,self,ActivityExchangeView.systomRefresh)    --零点更新

  --init list size
  local topHeight = self:getDelegate():getTopMenuSize().height
  local bottomHeight = self:getDelegate():getScene():getBottomContentSize().height

  local imgHeight = self.node_title:getContentSize().height
  self.node_title:setPosition(ccp(display.cx, display.height-topHeight-imgHeight/2))

  --for node list position
  self.node_listContainer:setContentSize(CCSizeMake(640,  display.height-topHeight-imgHeight-bottomHeight-20))
  self.node_listContainer:setPosition(ccp((display.width-640)/2 ,bottomHeight+20))

  self:registerTouchEvent()
  --show left time 
  self:showLeftTime()
  self.exchangeArray = Activity:instance():getExchangeArray(self.actId)
  self:showExchangeList(self.exchangeArray)
end

function ActivityExchangeView:onEnter()
  echo("---ActivityExchangeView:onEnter---")
  self:init()
end

function ActivityExchangeView:onExit()
  echo("---ActivityExchangeView:onExit---")
  net.unregistAllCallback(self)
end

function ActivityExchangeView:registerTouchEvent()
    local function onTouch(eventType, x, y)
        if eventType == "began" then
          self:pointIsInListRect(x,y)
          return false
        end
    end
  
  self:addTouchEventListener(onTouch, false, -300, true)
  self:setTouchEnabled(true)
end

function ActivityExchangeView:pointIsInListRect(xx, yy)
  local isInRect = false 
  local touchPoint = self.node_listContainer:convertToNodeSpace(ccp(xx, yy))
  local width = self.node_listContainer:getContentSize().width
  local height = self.node_listContainer:getContentSize().height
  
  if touchPoint.x > 0 and touchPoint.x < width and touchPoint.y > 0 and touchPoint.y < height then
    isInRect = true
  end
  -- echo("======", xx, yy, touchPoint.x, touchPoint.y, isInRect)
  self:setIsTouchInView(isInRect)

  return isInRect
end

function ActivityExchangeView:showLeftTime()
  if self.label_leftTime:isVisible() == false then 
    return 
  end

  self.leftTime = Activity:instance():getActivityLeftTime(self.actId)
  local function updateLeftTime()
    if self.leftTime <= 0 then 
      self:stopAllActions()
      self.label_leftTime:setString("00:00:00")
    else 
      self.leftTime = self.leftTime - 1

      if self.leftTime > 24*3600 then 
        self.label_leftTime:setString(_tr("day %{count}", {count=math.ceil(self.leftTime/(24*3600))}))
      else 
        local hour = math.floor(self.leftTime/3600)
        local min = math.floor((self.leftTime%3600)/60)
        local sec = math.floor(self.leftTime%60)
        self.label_leftTime:setString(string.format("%02d:%02d:%02d", hour,min,sec))
      end 
    end 
  end 

  if self.leftTime > 0 then 
    local interval = 1.0 
    if self.leftTime > 24*3600 then 
      interval = 60.0
      self.label_leftTime:setString(_tr("day %{count}", {count=math.ceil(self.leftTime/(24*3600))}))
    else 
      local hour = math.floor(self.leftTime/3600)
      local min = math.floor((self.leftTime%3600)/60)
      local sec = math.floor(self.leftTime%60)
      self.label_leftTime:setString(string.format("%02d:%02d:%02d", hour,min,sec))      
    end 
    self:schedule(updateLeftTime, interval)
  end 
end 

function ActivityExchangeView:setIsTouchInView(inViewRect)
  self.touchInView = inViewRect
end 

function ActivityExchangeView:getIsTouchInView()
  return self.touchInView 
end 

function ActivityExchangeView:showExchangeList(exchangeArray)
  echo("showExchangeList")

  local function cellSizeForTable(tbview,idx)
    return self.cellHeight,self.cellWidth
  end
  
  local function tableCellAtIndex(tbview, idx)
    -- echo("cellAtIndex = "..idx)
    local cell = tbview:dequeueCell()
    if nil == cell then
      cell = CCTableViewCell:new()
    else 
      cell:removeAllChildrenWithCleanup(true)
    end

    local item = nil
    item = ActivityExchangeListItem.new()      
    item:setDelegate(self)
    item:setItem(exchangeArray[idx+1])
    item:setIndex(idx)
    item:setTouchCheckDelegate(function() return self:getIsTouchInView() end)
    cell:addChild(item)
    return cell
  end
  
  local function numberOfCellsInTableView(tbview)
    return self.totalCells
  end

  if exchangeArray == nil then
    echo("empty list data !!!")
    return
  end

  local size = self.node_listContainer:getContentSize()
  self.cellWidth = size.width
  self.cellHeight = 204
  self.totalCells = #exchangeArray
  echo("w, h, len=", self.cellWidth, self.cellHeight, self.totalCells)
  self.node_listContainer:removeAllChildrenWithCleanup(true)

  self.tableView = CCTableView:create(size)
  self.tableView:setDirection(kCCScrollViewDirectionVertical)
  self.tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  self.node_listContainer:addChild(self.tableView)

  self.tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  self.tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  self.tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  self.tableView:reloadData()
end


function ActivityExchangeView:startExchange(idx, num)
  if num > 0  then 
    local itemId = self.exchangeArray[idx+1].id 
    echo("startExchange: idx, itemId, num=", idx, itemId, num)  
    _showLoading()
    local data = PbRegist.pack(PbMsgId.UseWordGameItemC2S, {gameId = itemId, count=num})
    net.sendMessage(PbMsgId.UseWordGameItemC2S, data)  
    --self.loading = Loading:show()
  end 
end


function ActivityExchangeView:exchangeResult(action,msgId,msg)
  echo("ActivityExchangeView:exchangeResult: ", msg.error)

--  if self.loading ~= nil then 
--    self.loading:remove()
--    self.loading = nil
--  end
  _hideLoading()

  if msg.error == "NO_ERROR_CODE" then
    --show gained bonus
    local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client)
    for i=1,table.getn(gainItems) do
      echo("----gained:", gainItems[i].configId, gainItems[i].count)
      local str = string.format("+%d", gainItems[i].count)
      Toast:showIconNumWithDelay(str, gainItems[i].iconId, gainItems[i].iType, gainItems[i].configId, ccp(display.width/2,display.height*0.5-i*40), 0.3*(i-1))
    end

    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)
    if self.tableView ~= nil then 
      local offset = self.tableView:getContentOffset()
      self.tableView:reloadData()
      self.tableView:setContentOffset(offset)
    end 
  elseif msg.error == "NOT_HAS_ENOUGH_ITEM" then 
    Toast:showString(self, _tr("not enough material"), ccp(display.width/2, display.height*0.4))
  elseif msg.error == "NEED_MORE_COIN" then 
    Toast:showString(self, _tr("not enough coin"), ccp(display.width/2, display.height*0.4))
  elseif msg.error == "NEED_MORE_MONEY" then 
    -- Toast:showString(self, _tr("not enough money"), ccp(display.width/2, display.height*0.4))  
    GameData:Instance():notifyForPoorMoney()  
  elseif msg.error == "WORD_GAME_CLOSE" then
    Toast:showString(self, _tr("activity is close"), ccp(display.width/2, display.height*0.4))
  elseif msg.error == "DAILY_COUNT_FULL" then
    Toast:showString(self, _tr("exchange_times_use_out"), ccp(display.width/2, display.height*0.4))  
  elseif msg.error == "SYSTEM_ERROR" then
    Toast:showString(self, _tr("system error"), ccp(display.width/2, display.height*0.4))
  else 
    Toast:showString(self, msg.error, ccp(display.width/2, display.height*0.4))
  end
end

function ActivityExchangeView:systomRefresh(action,msgId,msg)
  local leftSec = Activity:instance():getActivityLeftTime(ACI_ID_EXCHANGE)
  echo("===ActivityExchangeView:systomRefresh:", leftSec)
  if leftSec <= 0 then 
    --当前活动有可能结束,为了保险返回到首页
    self:getDelegate():displayHomeView()
  end 
end 

function ActivityExchangeView:goToItemView()
  self:getDelegate():goToItemView()
end 

function ActivityExchangeView:goToCardBagView()
  self:getDelegate():goToCardBagView()
end 
