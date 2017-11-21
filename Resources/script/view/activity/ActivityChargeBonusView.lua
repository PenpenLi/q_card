
require("view.BaseView")
require("view.activity.ActivityChargeListItem")

ActivityChargeBonusView = class("ActivityChargeBonusView", BaseView)

function ActivityChargeBonusView:ctor(menuIndex)

  ActivityChargeBonusView.super.ctor(self)

  --1. load levelup view ccbi
  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("chargeCallback",ActivityChargeBonusView.chargeCallback)
  
  pkg:addProperty("node_img","CCNode")
  pkg:addProperty("node_listContainer","CCNode")
  pkg:addProperty("sprite_charge","CCSprite")
  pkg:addProperty("sprite_consume","CCSprite")
  pkg:addProperty("label_chargeCount","CCLabelTTF")

  pkg:addProperty("label_preLeftTime","CCLabelTTF")
  pkg:addProperty("label_leftTime","CCLabelTTF")

  local layer,owner = ccbHelper.load("ActivityChargeBonusView.ccbi","ActivityChargeBonusViewCCB","CCLayer",pkg)
  self:addChild(layer)

  self.menuType = menuIndex 
end


function ActivityChargeBonusView:init()
  echo("---ActivityChargeBonusView:init---")
  self.priority = - 200 
  --init list size
  local topHeight = self:getDelegate():getTopMenuSize().height
  local bottomHeight = self:getDelegate():getScene():getBottomContentSize().height

  local imgHeight = self.node_img:getContentSize().height
  self.node_img:setPositionY(display.height-topHeight-imgHeight)

  --for node list position
  self.node_listContainer:setContentSize(CCSizeMake(640,  display.height-topHeight-imgHeight-bottomHeight))
  self.node_listContainer:setPosition(ccp((display.width-640)/2 ,bottomHeight))

  self.curProgression = 0 
  if self.menuType == ActMenu.CHARGE_BONUS then 
    self.sprite_charge:setVisible(true)
    self.sprite_consume:setVisible(false)
    self.curProgression = Activity:instance():getActProgress(ACI_ID_CHARGE_BONUS)
  elseif self.menuType == ActMenu.MONEY_CONSUME then 
    self.sprite_charge:setVisible(false)
    self.sprite_consume:setVisible(true)
    self.curProgression = Activity:instance():getActProgress(ACI_ID_CONSUME_MONEY)
  end 

  local str = string.format("%d",self.curProgression)
  self.label_chargeCount:setString("")
  local outlineLabel = ui.newTTFLabelWithOutline( {
                                            text = str,
                                            font = self.label_chargeCount:getFontName(),
                                            size = self.label_chargeCount:getFontSize(),
                                            x = 0,
                                            y = 0,
                                            color = ccc3(255, 234, 0),
                                            align = ui.TEXT_ALIGN_LEFT,
                                            --valign = ui.TEXT_VALIGN_TOP,
                                            --dimensions = self.label_info:getContentSize(),
                                            outlineColor =ccc3(0,0,0),
                                            pixel = 2
                                            }
                                          )
  local x = self.label_chargeCount:getPositionX() - outlineLabel:getContentSize().width/2 
  local y = self.label_chargeCount:getPositionY()
  outlineLabel:setPosition(ccp(x, y))
  self.label_chargeCount:getParent():addChild(outlineLabel)

  self.label_preLeftTime:setString(_tr("left time"))
end

function ActivityChargeBonusView:onEnter()
  echo("---ActivityChargeBonusView:onEnter---")
  self:init()
  if self.menuType == ActMenu.CHARGE_BONUS then 
    self.bonusArray = Activity:instance():getChargeBonus()

  elseif self.menuType == ActMenu.MONEY_CONSUME then 
    self.bonusArray = Activity:instance():getMoneyConsumeBonus()
  end 
  self:showBonusList(self.bonusArray)

  self:showLeftTime()
end

function ActivityChargeBonusView:onExit()
  echo("---ActivityChargeBonusView:onExit---")

  -- net.unregistAllCallback(self)
end


function ActivityChargeBonusView:chargeCallback()
  echo("chargeCallback")
  _playSnd(SFX_CLICK)
  self:getDelegate():goToShopPayView()
end 


function ActivityChargeBonusView:setIsTouch(isTouch)
  self._isTouch = isTouch
end 

function ActivityChargeBonusView:getIsTouch()
  return self._isTouch
end


function ActivityChargeBonusView:showBonusList(bonusArray)
  echo("showBonusList")

  local function tableCellTouched(tableview,cell)
    self:setIsTouch(true)
  end
  
  local function cellSizeForTable(tableview,idx)
    return self.cellHeight,self.cellWidth
  end
  
  local function tableCellAtIndex(tableview, idx)
    echo("cellAtIndex = "..idx)
    local cell = tableview:dequeueCell()

    if nil == cell then 
      cell = CCTableViewCell:new() 
    else 
      cell:removeAllChildrenWithCleanup(true) 
    end 

    local item = ActivityChargeListItem.new(self.menuType)
    item:setDelegate(self)
    item:setBonus(bonusArray[idx+1], self.curProgression)
    item:setIndex(idx)

    cell:addChild(item)
    return cell
  end
  
  local function numberOfCellsInTableView(tableview)
    return self.totalCells
  end

  if bonusArray == nil then
    echo("empty list data !!!")
    return
  end

  self.node_listContainer:removeAllChildrenWithCleanup(true)

  local size = self.node_listContainer:getContentSize()
  self.cellWidth = size.width
  self.cellHeight = 164
  self.totalCells = table.getn(bonusArray)

  local tbview = CCTableView:create(size)
  tbview:setDirection(kCCScrollViewDirectionVertical)
  tbview:setVerticalFillOrder(kCCTableViewFillTopDown)
  tbview:setTouchPriority(self.priority)
  self.node_listContainer:addChild(tbview)

  tbview:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tbview:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tbview:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tbview:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)

  tbview:reloadData()
end

function ActivityChargeBonusView:showLeftTime()
  if self.label_leftTime:isVisible() == false then 
    return 
  end
  local actId = ACI_ID_CHARGE_BONUS
  if self.menuType == ActMenu.MONEY_CONSUME then 
    actId = ACI_ID_CONSUME_MONEY
  end 
  self.leftTime = Activity:instance():getActivityLeftTime(actId)

  local function updateLeftTime()
    if self.leftTime <= 0 then 
      echo("=== is close time for act")
      self:stopAllActions()
      self.label_leftTime:setString("00:00:00")
      --返回首页
      self:getDelegate():displayHomeView()
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
