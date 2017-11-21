require("view.BaseView")
require("view.component.Loading")
require("view.component.PopupView")
require("view.component.TipsInfo")
require("view.activity.ActivityLevelupListItem")

ActivityBonusLevelupView = class("ActivityBonusLevelupView", BaseView)


function ActivityBonusLevelupView:ctor()

  ActivityBonusLevelupView.super.ctor(self)

  --1. load levelup view ccbi
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("node_info","CCNode")
  pkg:addProperty("node_bonus","CCNode")

  pkg:addProperty("label_info","CCLabelTTF")


  local layer,owner = ccbHelper.load("ActivityBonusLevelupView.ccbi","ActivityBonusLevelupViewCCB","CCLayer",pkg)
  self:addChild(layer) 
end

function ActivityBonusLevelupView:init()
  echo("---ActivityBonusLevelupView:init---")

  self.label_info:setString("")
  local outlineLabel = ui.newTTFLabelWithOutline( {
                                            text = _tr("level_bonus_title"),
                                            font = self.label_info:getFontName(),
                                            size = self.label_info:getFontSize(),
                                            x = 0,
                                            y = 0,
                                            color = ccc3(255, 234, 0),
                                            align = ui.TEXT_ALIGN_LEFT,
                                            --valign = ui.TEXT_VALIGN_TOP,
                                            dimensions = self.label_info:getContentSize(),
                                            outlineColor =ccc3(0,0,0),
                                            pixel = 2
                                            }
                                          )

  outlineLabel:setPosition(ccp(self.label_info:getPosition()))
  self.label_info:getParent():addChild(outlineLabel)  


  net.registMsgCallback(PbMsgId.AskForLevelRewardResult, self, ActivityBonusLevelupView.askForLevelRewardResult)

  --show bonus list
  local topHeight = self:getDelegate():getTopMenuSize().height
  local bottomHeight = self:getDelegate():getScene():getBottomContentSize().height
  local infoHeight = self.node_info:getContentSize().height 
  self.node_info:setPosition(ccp((display.width-640)/2, display.height-topHeight-infoHeight))
  local h3 = display.height - topHeight - bottomHeight - infoHeight
  self.node_bonus:setContentSize(CCSizeMake(display.width, h3))
  self.node_bonus:setPosition(ccp((display.width-640)/2, bottomHeight))

  self.bonusArray = Activity:instance():getLevelBonus()
  self:showBonusList(self.bonusArray)

  self:registerTouchEvent() 
end

function ActivityBonusLevelupView:onEnter()
  echo("---ActivityBonusLevelupView:onEnter---")
  self:init()
end

function ActivityBonusLevelupView:onExit()
  echo("---ActivityBonusLevelupView:onExit---")
  net.unregistAllCallback(self)
end

function ActivityBonusLevelupView:pointIsInListRect(touch_x, touch_y)
  local isInRect = false 

  local x, y = self.node_bonus:getPosition()
  local width = self.node_bonus:getContentSize().width
  local height = self.node_bonus:getContentSize().height

  if touch_x > x and touch_x < x+width and touch_y > y and touch_y < y+height then
    isInRect = true
  end

  self:setListButtonEnable(isInRect)

  return isInRect
end

function ActivityBonusLevelupView:registerTouchEvent()
    local function onTouch(eventType, x, y)
        if eventType == "began" then
          self:pointIsInListRect(x,y)
          return false
        end
    end
  
  self:addTouchEventListener(onTouch, false, -129, true)
  self:setTouchEnabled(true)

  self:setListButtonEnable(true)
end

function ActivityBonusLevelupView:setListButtonEnable(isEnable)
  self._isBnEnable = isEnable
end 

function ActivityBonusLevelupView:getListButtonEnable()
  return self._isBnEnable
end 

function ActivityBonusLevelupView:showBonusList(bonusGroup)
  echo("showBonusList")

  local function tableCellTouched(tableview,cell)

  end
  
  local function cellSizeForTable(tableview,idx)
    return self.cellHeight,self.cellWidth
  end
  
  local function tableCellAtIndex(tableview, idx)
    local cell = tableview:dequeueCell()
    if nil == cell then
      cell = CCTableViewCell:new()
    else
      cell:removeAllChildrenWithCleanup(true)
    end

    local playerLevel = GameData:Instance():getCurrentPlayer():getLevel()
    local rewardIndex = GameData:Instance():getCurrentPlayer():getLevelReward()
    local level = bonusGroup[idx+1].level 
    local hasRewarded = bonusGroup[idx+1].hasFetched 
    local node = ActivityLevelupListItem.new(level, playerLevel, hasRewarded, bonusGroup[idx+1].data)
    node:setDelegate(self)
    node:setTouchRectDelegate(function() return self:getListButtonEnable() end)
    node:setListIndex(idx)
    cell:addChild(node)

    return cell
  end
  

  local function numberOfCellsInTableView(tableview)
    return self.totalCells
  end

  self.cellWidth = 640
  self.cellHeight = 174
  self.totalCells = table.getn(bonusGroup)

  self.node_bonus:removeAllChildrenWithCleanup(true)

  self.tableView = CCTableView:create(self.node_bonus:getContentSize())
  self.tableView:setDirection(kCCScrollViewDirectionVertical)
  self.tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  self.node_bonus:addChild(self.tableView)

  -- self.tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  self.tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  self.tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  self.tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  self.tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)

  self.tableView:reloadData()
end


function ActivityBonusLevelupView:checkDisplayPopToCleanBag(idx)
  local needClean = false 

  local isEnough1 = true 
  local isEnough2 = true
  local isEnough3 = true
  local str = " "
  local tbl = self.bonusArray[idx+1].data 
  for k, v in pairs(tbl) do
    if v[1] == 6 then 
      isEnough1 = GameData:Instance():getCurrentPackage():checkItemBagEnoughSpace(1)
      str = _tr("bag is full,clean up?")
    end 
    if isEnough1 and v[1] == 8 then 
      isEnough2 = GameData:Instance():getCurrentPackage():checkCardBagEnoughSpace(1)
      str = _tr("card bag is full,clean up?")
    end 
    if isEnough1 and isEnough2 and v[1] == 7 then 
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
                                                        return self:getDelegate():goToItemView()
                                                      end 
                                                      if isEnough2 == false then 
                                                        return self:getDelegate():goToCardBagView()
                                                      end
                                                      if isEnough3 == false then 
                                                        return self:getDelegate():goToEquipBagView()
                                                      end
                                                  end})
    self:getDelegate():getScene():addChild(pop,100)
    needClean = true
  end 

  return needClean
end 

function ActivityBonusLevelupView:askForLevelRewardResult(action,msgId,msg)
--  if self.loading ~= nil then
--    self.loading:remove()
--    self.loading = nil
--  end
  _hideLoading()

  echo("ActivityBonusLevelupView:askForLevelRewardResult:", msg.state)
  if msg.state == "Ok" then
    _playSnd(SFX_ITEM_ACQUIRED)

    --show gained bonus
    local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client_sync)
    for i=1,table.getn(gainItems) do
      echo("----gained:", gainItems[i].configId, gainItems[i].count)
      local str = string.format("+%d", gainItems[i].count)
      Toast:showIconNumWithDelay(str, gainItems[i].iconId, gainItems[i].iType, gainItems[i].configId, ccp(display.width/2,display.height*0.5-i*40), 0.3*(i-1))
    end

    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)

    if self.tableView then 
      -- self.tableView:updateCellAtIndex(self.highlightIdx)
      self.bonusArray = Activity:instance():getLevelBonus()
      self:showBonusList(self.bonusArray)    
    end 

    --update tip 
    self:getDelegate():getBaseView():updateTopTip(ActMenu.LEVELUP_BONUS)
    self:getDelegate():getScene():getBottomBlock():updateBottomTip(3)

  elseif msg.state == "FailedForLevel" then
    Toast:showString(self, _tr("poor level"), ccp(display.width/2, display.height*0.4))
  elseif msg.state == "BagNeedCleanUp" then
    Toast:showString(self, _tr("bag is full"), ccp(display.width/2, display.height*0.4))
    -- self:checkDisplayPopToCleanBag(self.highlightIdx)
  end
end


function ActivityBonusLevelupView:fetchCallback(idx)
  echo("fetchCallback:", idx)

  local rewardIndex = GameData:Instance():getCurrentPlayer():getLevelReward()
  if idx > rewardIndex then 
    Toast:showString(self, _tr("fetch fron bonus firstly"), ccp(display.width/2, display.height*0.4))
    return 
  end

  self.highlightIdx = idx 

  if self:checkDisplayPopToCleanBag(idx) == false then 
    _showLoading()
    local data = PbRegist.pack(PbMsgId.AskForLevelReward)
    net.sendMessage(PbMsgId.AskForLevelReward, data)
    --self.loading = Loading:show()
  end
end
