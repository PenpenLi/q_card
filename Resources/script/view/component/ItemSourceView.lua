
require("view.BaseView")


ItemSourceView = class("ItemSourceView", BaseView)

function ItemSourceView:ctor(configId, priority)
  ItemSourceView.super.ctor(self)

  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("sourceCallback",ItemSourceView.sourceCallback)
  pkg:addFunc("combineCallback",ItemSourceView.combineCallback)
  pkg:addProperty("node_tip","CCNode")
  pkg:addProperty("node_option","CCNode")
  pkg:addProperty("node_source","CCNode")
  pkg:addProperty("node_itemName","CCNode")
  pkg:addProperty("node_container","CCNode")
  pkg:addProperty("bn_source","CCControlButton")
  pkg:addProperty("bn_combine","CCControlButton")
  pkg:addProperty("layer_mask","CCLayerColor")

  local layer,owner = ccbHelper.load("ItemSourceView.ccbi","ItemSourceViewCCB","CCLayer",pkg)
  self:addChild(layer)
  self.tipConfigId = configId 
  self.tipPriority = priority or -300
end

function ItemSourceView:onEnter()
  if self.tipConfigId == nil then 
    return 
  end 

  self.bn_source:setTouchPriority(self.tipPriority-1)
  self.bn_combine:setTouchPriority(self.tipPriority-1) 
  self.orgPosX = self.node_option:getPositionX()

  self:showTipView(self.tipConfigId)
end 

function ItemSourceView:onExit()

end 

function ItemSourceView:showTipView(configId)
  echo("showTipView:", configId)

  self.node_option:setPositionX(self.orgPosX)
  self.node_source:setPositionX(self.orgPosX)

  self.isSourceVisible = false 
  self.node_tip:setVisible(true)
  self.node_option:setVisible(true)
  self.node_source:setVisible(false)

  self:setTipItemName(configId)
  self:setTipCombined(configId)

  self.layer_mask:addTouchEventListener(handler(self,self.onTouch), false, self.tipPriority, true)
  self.layer_mask:setTouchEnabled(true) 
end 

function ItemSourceView:setTipItemName(configId)
  local rareColor = {13027014, 11003904, 45284,14549503,16768782} --白绿蓝紫橙
  local nameColor = rareColor[1]
  local itemName = ""

  local flag = math.floor(configId/10000000)
  if configId < 100 then --虚拟道具
    flag = 2 
  end 

  if flag == 1 then -- card 
    itemName = AllConfig.unit[configId].unit_name
  elseif flag == 2 then -- props
    local item = AllConfig.item[configId]
    if item ~= nil then 
      nameColor = rareColor[item.rare]
      itemName = item.item_name
    end
  end 

  self.node_itemName:removeAllChildrenWithCleanup(true)
  local tipStr = "<font><fontname>Courier-Bold</><color><value>"..nameColor.."</>"..itemName.."</></>".."<n/>"
  local label = RichLabel:create(tipStr,"Courier-Bold",24, CCSizeMake(220, 0),true,false)
  label:setColor(ccc3(255,255,255)) --默认颜色
  local size = label:getTextSize()
  label:setPosition(ccp(-size.width/2, size.height/2))
  self.node_itemName:addChild(label)
end 

function ItemSourceView:setTipCombined(configId)
  echo("===setTipCombined", configId)
  local flag = math.floor(configId/10000000)
  if configId < 100 then --虚拟道具
    flag = 2 
  end 

  if flag == 1 then -- card 
    local canCombined = Enhance:instance():getHasChipForCard(configId)
    self.bn_combine:setEnabled(canCombined)
  elseif flag == 2 then -- props
    local itemType = AllConfig.item[configId].item_type
    local rare = AllConfig.item[configId].rare 
    if configId > 100 and (itemType == iType_SkillBook or ((itemType == iType_HunShi or itemType == iType_JunLingZhuang or itemType == iType_XuanTie) and rare > 2)) then --can combine
      self.bn_combine:setVisible(true)
      self.bn_combine:setEnabled(true)
    else 
      self.bn_combine:setVisible(false)
      self.bn_combine:setEnabled(false)
    end 
  end 
end 

function ItemSourceView:sourceCallback()
  echo("sourceCallback:configid=", self.tipConfigId)

  self:showSourceList(self.tipConfigId)

  --play page move anim
  self.isSourceVisible = not self.isSourceVisible
  local offsetX = self.node_source:getContentSize().width/2 + 30 
  local duration = 0.3
  local act1 = nil 
  local act2 = nil  
  if self.isSourceVisible then 
    self.node_source:setVisible(true)
    act1 = CCMoveBy:create(duration, ccp(-offsetX, 0))
    act2 = CCMoveBy:create(duration, ccp(offsetX, 0))
  else 
    act1 = CCMoveBy:create(duration, ccp(offsetX, 0))
    local move2 = CCMoveBy:create(duration, ccp(-offsetX, 0))
    local function actionEnd()
      self.node_source:setVisible(false)
      self.node_container:removeAllChildrenWithCleanup(true)
    end 
    act2 = CCSequence:createWithTwoActions(move2, CCCallFunc:create(function() return actionEnd() end))
  end 
  self.node_option:runAction(act1)
  self.node_source:runAction(act2)
end 

function ItemSourceView:combineCallback()
  local controller = ControllerFactory:Instance():create(ControllerType.BAG_CONTROLLER)
  controller:enter(4)
end 

function ItemSourceView:showSourceList(configId)
  
  local function cellSizeForTable(tbView,idx)
    return self.cellHeight,self.cellWidth
  end 

  local function numberOfCellsInTableView(tbView)
    return self.totalCells
  end

  local function tableCellTouched(tbView,cell)
    if self.node_source:isVisible() == false then 
      return 
    end

    local dataItem = self.sourceData[cell:getIdx()+1]
    if dataItem[1] == SourceType.CardFromStage or dataItem[1] == SourceType.ChipFromStage or dataItem[1] == SourceType.Charpter then 
      local stage = Scenario:Instance():getStageById(dataItem[2])
      if stage ~= nil then 
        local state = stage:getCheckPoint():getState()
        if state == StageConfig.CheckPointStateOpen 
          or state == StageConfig.CheckPointStateInProgress 
          or state == StageConfig.CheckPointStateFinished then 
          
          local eliteOpend = GameData:Instance():checkSystemOpenCondition(38, false)
          local isEliteStage = stage:getIsElite()
          if isEliteStage == true and eliteOpend == false then
          else  
            local controller = ControllerFactory:Instance():create(ControllerType.SCENARIO_CONTROLLER)
            controller:enter() 
            controller:gotoStageById(dataItem[2]) 
          end
         
        else 
          echo("=== not open")
        end 
      end 
    elseif dataItem[1] == SourceType.Lottery then --抽卡
      local controller = ControllerFactory:Instance():create(ControllerType.LOTTERY_CONTROLLER)
      controller:enter(ViewType.enhance_surmount)

    elseif dataItem[1] == SourceType.Arena then --武斗大会 
      local ret,hitstr = Arena:Instance():CanOpenCheck()
      if(not ret) then
        Toast:showString(GameData:Instance():getCurrentScene(), hitstr, ccp(display.cx, display.cy))
        return
      end

      if (Arena:Instance():getSeverState() == "ARENA_OPEN") then
        local controller = ControllerFactory:Instance():create(ControllerType.ARENA_CONTROLLER)
        controller:enter()
      else
        Activity:instance():entryActView(ActMenu.ARENA, false)
      end 

    elseif dataItem[1] == SourceType.SoulShop then --将魂商店 
      if GameData:Instance():checkSystemOpenCondition(27, true) == false then 
        return 
      end 
      local controller = ControllerFactory:Instance():create(ControllerType.CARD_SOUL_CONTROLLER)
      controller:enter(CardSoulMenu.SHOP) 

    elseif dataItem[1] == SourceType.Expedition then --征战
      if GameData:Instance():checkSystemOpenCondition(4, true) == false then 
        return 
      end 
      local controller = ControllerFactory:Instance():create(ControllerType.EXPEDITION_CONTROLLER)
      controller:enter()

    elseif dataItem[1] == SourceType.Gonghui then --公会
      if GameData:Instance():checkSystemOpenCondition(43, true) == false then 
        return 
      end       
      local controller = ControllerFactory:Instance():create(ControllerType.GUILD_CONTROLLER)
      controller:enter()

    elseif dataItem[1] == SourceType.JingJiChang then --竞技场
      if GameData:Instance():checkSystemOpenCondition(41, true) == false then 
        return 
      end 
      -- local controller = ControllerFactory:Instance():create(ControllerType.PVP_RANK_MATCH_CONTROLLER)
      -- controller:enter()
      self:cose()
      local view = PopShopListView.new(ShopCurViewType.JingJiChang, -500)
      view:setTopBottomVisibleWhenExit(false)
      GameData:Instance():getCurrentScene():addChildView(view)

    elseif dataItem[1] == SourceType.Bable then --通天塔
      if GameData:Instance():checkSystemOpenCondition(44, true) == false then 
        return 
      end       
      local controller = ControllerFactory:Instance():create(ControllerType.BABEL_CONTROLLER)
      controller:enter() 

    elseif dataItem[1] == SourceType.VipShop then --云游商店
      if Shop:instance():checkShopOpen(ShopCurViewType.VIP) then 
        local controller = ControllerFactory:Instance():create(ControllerType.SHOP_VIP_CONTROLLER)
        controller:enter()         
      end

    elseif dataItem[1] == SourceType.TimeAct then --限时活动
    elseif dataItem[1] == SourceType.Battle then --最新战役副本
      --跳到当前最新关卡
      local stage = Scenario:Instance():getLastNormalStage()
      local controller = ControllerFactory:Instance():create(ControllerType.SCENARIO_CONTROLLER)
      controller:enter()
      controller:gotoStageById(stage:getStageId())  

    elseif dataItem[1] == SourceType.SoulRefine then --提炼将魂
      if GameData:Instance():checkSystemOpenCondition(27, true) == false then 
        return 
      end 
      local controller = ControllerFactory:Instance():create(ControllerType.CARD_SOUL_CONTROLLER)
      controller:enter(CardSoulMenu.REFINE_CARD)       
    end 
  end 
  
  local function tableCellAtIndex(tbView, idx)
    local cell = tbView:dequeueCell()
    if nil == cell then
      cell = CCTableViewCell:new()
    else
      cell:removeAllChildrenWithCleanup(true)
    end

    local itemBg = nil 
    local label = nil 
    local offsetY = 0 
    local dataItem = self.sourceData[idx+1]
    if dataItem[1] == SourceType.CardFromStage or dataItem[1] == SourceType.ChipFromStage or dataItem[1] == SourceType.Charpter then 
      local stage = Scenario:Instance():getStageById(dataItem[2])
      if stage ~= nil then 
        local isEliteStage = stage:getIsElite()
        local state = stage:getCheckPoint():getState()
        local leftTimes = stage:getLeftTimesToday()
        echo("====isEliteStage, state, leftTimes:", isEliteStage, state, leftTimes)
        
        local eliteImg = nil 
        local disableImg = nil 
        
        if state == StageConfig.CheckPointStateOpen 
          or state == StageConfig.CheckPointStateInProgress 
          or state == StageConfig.CheckPointStateFinished then
           
          local eliteOpend = GameData:Instance():checkSystemOpenCondition(38, false)
          if eliteOpend == false and isEliteStage == true then
            itemBg = CCSprite:createWithSpriteFrameName("lv_bn_bg2.png")  
            disableImg = CCSprite:createWithSpriteFrameName("stage_disable2.png")
            if isEliteStage == true then 
              eliteImg = CCSprite:createWithSpriteFrameName("stage_jingying1.png")
            else 
              eliteImg = CCSprite:createWithSpriteFrameName("stage_putong1.png")
            end 
          else
            itemBg = CCSprite:createWithSpriteFrameName("lv_bn_bg0.png")
            if leftTimes == 0 then 
              disableImg = CCSprite:createWithSpriteFrameName("stage_disable1.png")
            end 
            if isEliteStage == true then 
              eliteImg = CCSprite:createWithSpriteFrameName("stage_jingying0.png")
            else 
              eliteImg = CCSprite:createWithSpriteFrameName("stage_putong0.png")
            end 
          end
          
        else 
          itemBg = CCSprite:createWithSpriteFrameName("lv_bn_bg2.png")  
          disableImg = CCSprite:createWithSpriteFrameName("stage_disable2.png")
          if isEliteStage == true then 
            eliteImg = CCSprite:createWithSpriteFrameName("stage_jingying1.png")
          else 
            eliteImg = CCSprite:createWithSpriteFrameName("stage_putong1.png")
          end 
        end 
        
        
        
        if itemBg ~= nil then 
          local itemBgSize = itemBg:getContentSize()
          if eliteImg ~= nil then 
            eliteImg:setPosition(ccp(15, itemBgSize.height/2))
            itemBg:addChild(eliteImg)
          end 
          if disableImg ~= nil then 
            disableImg:setPosition(ccp(itemBgSize.width-disableImg:getContentSize().width/2-14, itemBgSize.height/2))
            itemBg:addChild(disableImg)
          end
        end 

        local str = ""
        if dataItem[1] == SourceType.Charpter then 
          str = _tr("charpter_%{num}", {num=stage:getStageChapterId()})
        else 
          str = string.format("%d-%d", stage:getStageChapterId(), stage:getCheckPointIndex())
        end 
        label = CCLabelTTF:create(str, "Courier-Bold", 22)
      end 

    elseif dataItem[1] == SourceType.Lottery then 
      itemBg = CCSprite:createWithSpriteFrameName("lv_bn_dianjiang0.png")

    elseif dataItem[1] == SourceType.Arena then 
      itemBg = CCSprite:createWithSpriteFrameName("lv_bn_wudoudahui0.png")

    elseif dataItem[1] == SourceType.SoulShop then 
      itemBg = CCSprite:createWithSpriteFrameName("lv_bn_soul_shop0.png")
      
    elseif dataItem[1] == SourceType.Expedition then 
      itemBg = CCSprite:createWithSpriteFrameName("lv_bn_zhengzhan0.png")

    elseif dataItem[1] == SourceType.Gonghui then 
      itemBg = CCSprite:createWithSpriteFrameName("lv_bn_gonghui0.png")

    elseif dataItem[1] == SourceType.JingJiChang then 
      itemBg = CCSprite:createWithSpriteFrameName("lv_bn_jingjichang0.png")

    elseif dataItem[1] == SourceType.Bable then 
      itemBg = CCSprite:createWithSpriteFrameName("lv_bn_tongtianta0.png")

    elseif dataItem[1] == SourceType.VipShop then 
      itemBg = CCSprite:createWithSpriteFrameName("lv_bn_vipshop0.png")  

    elseif dataItem[1] == SourceType.TimeAct then 
      itemBg = CCSprite:createWithSpriteFrameName("lv_bn_xianshihuodong0.png")  

    elseif dataItem[1] == SourceType.Battle then 
      itemBg = CCSprite:createWithSpriteFrameName("lv_bn_zhanyi0.png")  

    elseif dataItem[1] == SourceType.SoulRefine then 
      itemBg = CCSprite:createWithSpriteFrameName("lv_bn_tilianjianghun0.png")
    end 

    if itemBg ~= nil then 
      offsetY = (self.cellHeight - itemBg:getContentSize().height)/2
      itemBg:setPosition(ccp(self.cellWidth/2, self.cellHeight/2+offsetY))
      cell:addChild(itemBg)
    end 
    if label ~= nil then 
      label:setColor(ccc3(255, 255, 255))
      label:setPosition(ccp(self.cellWidth/2, self.cellHeight/2+offsetY))
      cell:addChild(label)
    end 

    return cell
  end
  
  self.sourceData = Enhance:instance():getMaterialSource(configId)
  local size = self.node_container:getContentSize()
  self.cellWidth = size.width
  self.cellHeight = 70
  self.totalCells = #self.sourceData

  self.node_container:removeAllChildrenWithCleanup(true)

  --create tableview
  local tableView = CCTableView:create(size)
  tableView:setDirection(kCCScrollViewDirectionVertical)
  tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  tableView:setTouchPriority(self.tipPriority-1)
  self.node_container:addChild(tableView)

  --tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)

  tableView:reloadData()
end 


function ItemSourceView:onTouch(event, x,y)
  if event == "began" then
    if self.node_tip:isVisible()== false then 
      return false 
    end

    local size = self.node_option:getContentSize()
    if self.node_source:isVisible() then 
      size.width = size.width * 2 
    end
    local pos = self.node_option:convertToNodeSpace(ccp(x, y))
    if pos.x < 0 or pos.x > size.width or pos.y < 0 or pos.y > size.height then 
      self.inViewRect = false 
    else 
      self.inViewRect = true 
    end 

    return true 

  elseif event == "ended" then
    if self.inViewRect == false then 
      local size = self.node_option:getContentSize()
      if self.node_source:isVisible() then 
        size.width = size.width * 2
      end
      local pos = self.node_option:convertToNodeSpace(ccp(x, y))
      if pos.x < 0 or pos.x > size.width or pos.y < 0 or pos.y > size.height then 
        echo("onTouch, close tip...")
        self.layer_mask:removeTouchEventListener()

        -- self.node_tip:setVisible(false)
        self:cose()
      end 
    end 
  end
end


function ItemSourceView:cose()
  self:removeFromParentAndCleanup(true)
end 
