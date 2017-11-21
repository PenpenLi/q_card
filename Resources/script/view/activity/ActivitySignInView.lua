require("view.BaseView")
require("view.component.Loading")

ActivitySignInView = class("ActivitySignInView", BaseView)

function ActivitySignInView:ctor()
  ActivitySignInView.super.ctor(self)

  --1. load levelup view ccbi
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("node_sign","CCNode")
  pkg:addProperty("node_container","CCNode")
  pkg:addProperty("node_arrow","CCNode")  
  pkg:addProperty("label_title","CCLabelTTF")

  local layer,owner = ccbHelper.load("ActivitySignInView.ccbi","ActivitySignInViewCCB","CCLayer",pkg)
  self:addChild(layer)
end

function ActivitySignInView:init()
  echo("---ActivitySignInView:init---")

  --register msg
  net.registMsgCallback(PbMsgId.AskForMonthRewardResult, self, ActivitySignInView.signInRewardResult)

  self.node_sign:setPositionX((display.width-self.node_sign:getContentSize().width)/2)

  self.label_title:setString("")
  self.outlineTitle = ui.newTTFLabelWithOutline( {
                                            text = " ",
                                            font = self.label_title:getFontName(),
                                            size = self.label_title:getFontSize(),
                                            x = 0,
                                            y = 0,
                                            color = ccc3(255, 234, 0),
                                            align = ui.TEXT_ALIGN_LEFT,
                                            --valign = ui.TEXT_VALIGN_TOP,
                                            -- dimensions = self.label_title:getContentSize(),
                                            outlineColor =ccc3(0,0,0),
                                            pixel = 2
                                            }
                                          )

  self.outlineTitle:setPosition(ccp(self.label_title:getPosition()))
  self.label_title:getParent():addChild(self.outlineTitle)

  --bonus info
  self.signInBonus, self.animEffectArr = Activity:instance():getSignInBonus()
  self:showSigninIcons(self.signInBonus)
end

function ActivitySignInView:onEnter()
  echo("---ActivitySignInView:onEnter---")
  self:init()
end

function ActivitySignInView:onExit()
  echo("---ActivitySignInView:onExit---")
  net.unregistAllCallback(self)
end

--show 30 days' icon
function ActivitySignInView:showSigninIcons(bonusGroup)
  self.totalCol = 6
  self.totalRow = 5
  self.gridWidth = self.node_sign:getContentSize().width/self.totalCol
  self.gridHeight = self.node_sign:getContentSize().height/self.totalRow
  local iconSize = 95
  local signedCount = Activity:instance():getSignedCount()
  local alreadySigned = Activity:instance():getIsAlreadySigned()
  local nextSignDay = signedCount 

  self.highlightIndex = -1

  --show 30 icons
  for i=1,  math.min(self.totalRow*self.totalCol, #bonusGroup) do 
    local row = math.floor(((i-1)/self.totalCol))
    local col = math.floor((i-1)%self.totalCol)
    local pos_x = col*self.gridWidth + self.gridWidth/2
    local pos_y = (self.totalRow-row-1)*self.gridHeight + self.gridHeight/2

    local itemInfo = bonusGroup[i][1]
    local node = GameData:Instance():getCurrentPackage():getItemSprite(nil, itemInfo[1], itemInfo[2], 0)
    node:setPosition(ccp(pos_x, pos_y))
    self.node_sign:addChild(node) 

    if i <= signedCount then 
      local mask = CCSprite:createWithSpriteFrameName("act_mengban.png")
      mask:setPosition(ccp(pos_x, pos_y))
      self.node_sign:addChild(mask, 19) 

      local selectedImg = CCSprite:createWithSpriteFrameName("gouxuan.png")
      selectedImg:setAnchorPoint(ccp(1,0))
      selectedImg:setPosition(ccp(pos_x+iconSize/2+12, pos_y-iconSize/2))
      self.node_sign:addChild(selectedImg, 20) 
    else 

      if self.animEffectArr[i] > 0 then 
        local shiningAnim = _res(6010011)
        if shiningAnim ~= nil then 
          shiningAnim:setPosition(ccp(pos_x, pos_y))
          self.node_sign:addChild(shiningAnim)
        end
      end

      if alreadySigned == false and (i == signedCount+1) then 
        nextSignDay = i 
        local anim,offsetX,offsetY,duration = _res(5020152)
        duration_time = duration
        if anim ~= nil then
          self.canSigninAnim = anim 
          anim:setPosition(ccp(pos_x, pos_y))
          self.node_sign:addChild(anim)
          anim:getAnimation():play("default")
        end
      end
    end 
  end

  --create highlight box for index--1
  self.highlightBox = CCSprite:createWithSpriteFrameName("xuanzhong2.png")
  self.node_sign:addChild(self.highlightBox)
  self:highlightCell(nextSignDay, false)

  self:regTouchEvent()
end 

function ActivitySignInView:highlightCell(index, aotoSignin)

  --check and sign in 
  if aotoSignin then 
    self:checkToSignIn(index)
  end

  if self.highlightIndex == index then 
    return 
  end 

  local row = math.floor(((index-1)/self.totalCol))
  local col = math.floor((index-1)%self.totalCol)
  local pos_x = col*self.gridWidth + self.gridWidth/2
  local pos_y = (self.totalRow-row-1)*self.gridHeight + self.gridHeight/2
  -- echo("===pos_x, pos_y", pos_x, pos_y)
  if self.highlightBox ~= nil then
    self.highlightBox:setPosition(ccp(pos_x, pos_y))
  end

  self.highlightIndex = index

  self.outlineTitle:setString(_tr("sign_title%{day}", {day=index}))

  self:showBonusList(self.signInBonus[index])
end 

function ActivitySignInView:updateSigninGrid(index)
  local row = math.floor(((index-1)/self.totalCol))
  local col = math.floor((index-1)%self.totalCol)
  local pos_x = col*self.gridWidth + self.gridWidth/2
  local pos_y = (self.totalRow-row-1)*self.gridHeight + self.gridHeight/2
  local iconSize = 95 
  local mask = CCSprite:createWithSpriteFrameName("act_mengban.png")
  -- mask:setAnchorPoint(ccp(0,0))
  mask:setPosition(ccp(pos_x, pos_y))
  self.node_sign:addChild(mask, 19) 

  local selectedImg = CCSprite:createWithSpriteFrameName("gouxuan.png")
  selectedImg:setAnchorPoint(ccp(1,0))
  selectedImg:setPosition(ccp(pos_x+iconSize/2+12, pos_y-iconSize/2))
  self.node_sign:addChild(selectedImg, 20) 
end 

function ActivitySignInView:regTouchEvent()
  local function onTouch(event, x,y)
    if event == "began" then
      local pos = self.node_sign:convertToNodeSpace(ccp(x, y))
      if pos.x >= 0 and pos.x <= self.totalCol*self.gridWidth and pos.y >= 0 and pos.y <= self.totalRow*self.gridHeight then 
        local col = math.floor(pos.x/self.gridWidth)
        local row = self.totalRow - math.floor(pos.y/self.gridHeight) - 1
        self.touchIndex = row*self.totalCol + col + 1
        return true
      else
        return false
      end
    elseif event == "ended" then
      local pos = self.node_sign:convertToNodeSpace(ccp(x, y))
      if pos.x >= 0 and pos.x <= self.totalCol*self.gridWidth and pos.y >= 0 and pos.y <= self.totalRow*self.gridHeight then 
        local col = math.floor(pos.x/self.gridWidth)
        local row = self.totalRow - math.floor(pos.y/self.gridHeight) - 1
        local touchIdx = row*self.totalCol + col + 1
        if touchIdx == self.touchIndex then 
          -- echo("==========touch index", touchIdx)
          self:highlightCell(touchIdx, true)
        end 
      end 
    end 
  end 
  self:addTouchEventListener(onTouch)
  self:setTouchEnabled(true)
end

function ActivitySignInView:checkToSignIn(index)
  local alreadySigned = Activity:instance():getIsAlreadySigned()
  if alreadySigned then 
    echo("==== has already signed")
    return false 
  end

  local signedCount = Activity:instance():getSignedCount()
  echo("signedCount, index = ", signedCount, index)
  if signedCount + 1 == index then 

    --start sign
    local str = ""
    local isEnough1 = true 
    local isEnough2 = true 
    local isEnough3 = true 
    for k, v in pairs(self.signInBonus[index]) do 
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

      return false 
    end 

    echo(" send msg for sign in....")
    net.sendMessage(PbMsgId.AskForMonthReward)
    return true
  end

  return false
end 

function ActivitySignInView:signInRewardResult(action,msgId,msg)
  echo("signInRewardResult", msg.state)

  if msg.state == "Ok" then
    -- if msg.month_reward ~= nil then 
    --   Activity:instance():setSignedRewardCount(msg.month_reward)
    -- end
    if self.canSigninAnim ~= nil then 
      self.canSigninAnim:removeFromParentAndCleanup(true)
    end

    echo("===pre count=", Activity:instance():getSignedCount())
    Activity:instance():updateSignInInfo(msg.month_reward)
    local signedCount = Activity:instance():getSignedCount()
    self:updateSigninGrid(signedCount)
    echo("===aft count=", Activity:instance():getSignedCount())

    if msg.client_sync ~= nil then 
      --show gained bonus
      local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client_sync)
      for i=1,table.getn(gainItems) do
        echo("----gained:", gainItems[i].configId, gainItems[i].count)
        local str = string.format("+%d", gainItems[i].count)
        Toast:showIconNumWithDelay(str, gainItems[i].iconId, gainItems[i].iType, gainItems[i].configId, ccp(display.width/2,display.height*0.5-i*40), 0.3*(i-1))
      end

      _playSnd(SFX_ITEM_ACQUIRED)

      local preCoin = GameData:Instance():getCurrentPlayer():getCoin()
      GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
      local aftCoin = GameData:Instance():getCurrentPlayer():getCoin()
      echo("===========preCoin,aftCoin:", preCoin,aftCoin)
    end

    --update tip 
    self:getDelegate():getBaseView():updateTopTip(ActMenu.DAILY_SIGNIN)
    self:getDelegate():getScene():getBottomBlock():updateBottomTip(3)

  elseif msg.state == "NoRight" then
    Toast:showString(self, _tr("has signed"), ccp(display.width/2, display.height*0.4))

  elseif msg.state == "NeedLoginedMore" then
    Toast:showString(self, _tr("sign error"), ccp(display.width/2, display.height*0.4))
  end
end

function ActivitySignInView:showBonusList(bonusGroup)
  echo("showBonusList")


  local function tableCellTouched(tableview,cell)
    local idx = cell:getIdx()
    local itype = bonusGroup[idx+1][1]
    local configId = bonusGroup[idx+1][2]
    local x = idx*self.cellWidth + tableview:getContentOffset().x + self.cellWidth/2
    local pos = ccp(x, self.cellHeight+10) 
    if itype == 20 then --将魂
      configId = itype
    end      
    TipsInfo:showTip(self.node_container, configId, nil, pos)
  end
  
  local function cellSizeForTable(tableview,idx)
    return self.cellHeight, self.cellWidth
  end
  
  local function tableCellAtIndex(tableview, idx)
    --echo("cellAtIndex = "..idx)
    local cell = tableview:dequeueCell()
    if nil == cell then
      cell = CCTableViewCell:new()
    else
      cell:removeAllChildrenWithCleanup(true)
    end

    local iconSize = 95
    local pos = ccp(self.cellWidth/2, self.cellHeight/2)
    local node = CCNode:create()
    local itemInfo = bonusGroup[idx+1]
    local node = GameData:Instance():getCurrentPackage():getItemSprite(nil, itemInfo[1], itemInfo[2], itemInfo[3])
    node:setPosition(pos)
    self.touchObjectsArray[idx+1] = node 
    cell:addChild(node)

    return cell
  end
  

  local function numberOfCellsInTableView(tableview)
    return self.totalCells
  end

  self.touchObjectsArray = {}

  local size = self.node_container:getContentSize()
  self.cellWidth = size.width/4
  self.cellHeight = size.height
  self.totalCells = table.getn(bonusGroup)
  self.node_container:removeAllChildrenWithCleanup(true)

  -- if self.totalCells < 4 and self.totalCells > 0 then
  --   size.width = self.totalCells * self.cellWidth
  -- end

  if self.totalCells > 4 then 
    self.node_arrow:setVisible(true)
  else 
    self.node_arrow:setVisible(false)
  end 
  self.tableView = CCTableView:create(size)
  self.tableView:setDirection(kCCScrollViewDirectionHorizontal)
  -- self.tableView:setBounceable(false)
  self.node_container:addChild(self.tableView)

  -- self.tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  self.tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  self.tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  self.tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  self.tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  self.tableView:reloadData()
end
