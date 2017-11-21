
require("view.component.ViewWithEave")
require("view.component.PopupView")
require("view.component.Toast")
require("view.play_states.PlayStatesCardListItem")
require("model.card_soul.CardSoul")

CardListView = class("CardListView", ViewWithEave)


SelectType = enum({"NONE", "SELECTE_ONE","SELECTE_ALL"})



function CardListView:ctor(selectType)

  CardListView.super.ctor(self)
  self:setTabControlEnabled(false)
  self:setScrollBgVisible(false)

  --1. load levelup view ccbi
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("node_fileter","CCNode")
  pkg:addProperty("node_listContainer","CCNode")
  pkg:addProperty("node_bottom","CCNode")
  pkg:addProperty("node_toolbarText1","CCNode")
  pkg:addProperty("node_toolbarText2","CCNode")

  pkg:addProperty("bn_selectAll","CCMenuItemSprite")


  pkg:addProperty("label_preFilterType","CCLabelTTF")
  pkg:addProperty("label_filterType","CCLabelTTF")
  -- pkg:addProperty("label_selectedNumPre","CCLabelTTF")
  pkg:addProperty("label_selectedNum","CCLabelTTF")
  pkg:addProperty("label_gainExpePre","CCLabelTTF")
  pkg:addProperty("label_gainExpe","CCLabelTTF")
  pkg:addProperty("label_coinCostPre","CCLabelTTF")
  pkg:addProperty("label_coinCost","CCLabelTTF")
  pkg:addProperty("label_coinCost2Pre","CCLabelTTF")
  pkg:addProperty("label_coinCost2","CCLabelTTF")
  pkg:addProperty("label_selectAll","CCLabelTTF")
  pkg:addProperty("sprite_selectAll","CCSprite")
  pkg:addProperty("bn_confirm","CCControlButton")

  pkg:addFunc("filterCallback",CardListView.filterCallback)
  pkg:addFunc("confirmCallback",CardListView.confirmCallback)
  pkg:addFunc("selectAllCallback",CardListView.selectAllCallback)



  local layer,owner = ccbHelper.load("CardListView.ccbi","CardListViewCCB","CCLayer",pkg)
  self:addChild(layer)
  
  self:setTitleTextureName("playstates-image-wujiang.png")
  self:getEaveView().btnHelp:setVisible(false)
  
  self.curListType = selectType
end



function CardListView:init(tbl)
  echo("-------CardListView:init-------")
  --self.selectedCount = 0

  self.label_preFilterType:setString(_tr("filter type"))
  self.label_selectAll:setString(_tr("select all"))
  self.label_coinCostPre:setString(_tr("cost")..":")
  self.label_gainExpePre:setString(_tr("gain")..":")
  self.label_coinCost2Pre:setString(_tr("cost")..":")
  self.label_filterType:setString(_tr("default"))
  
  self.node_bottom:setVisible(false)
  self.sprite_selectAll:setVisible(false)
  self.bn_confirm:setTouchPriority(-200)
  self:registerTouchEvent()

  self.dataArray = tbl
  if self.dataArray == nil then
    self.dataArray = {}
  end

  self.dataBackupArray = self.dataArray
  self.selectedBackUp = {}

  --init var
  self.gainExp = 0
  self.totalMoney = 0
  self.selectedCount = 0
  self.cellWidth = ConfigListCellWidth
  self.cellHeight = ConfigListCellHeight
  self.selectedCount = 0

  --init array
  local tmpCount = table.getn(self.dataArray)
  for i=1, tmpCount do
    if self.dataArray[i].isSelected == true then
      --backup orgin selected
      table.insert(self.selectedBackUp, self.dataArray[i]:getId())

      self.gainExp = self.gainExp + self.dataArray[i]:getGainedExpAfterEaten()
      if self:getIsUsedFor() == CardListType.LEVEL_UP_CARD or self:getIsUsedFor() == CardListType.LEVEL_UP_EATTEN_CARD then -- level up
        self.totalMoney = self.totalMoney + self.dataArray[i]:getCost()

      elseif self:getIsUsedFor() == CardListType.CARD_REBORN then
        local configId = self.dataArray[i]:getConfigId()
        self.totalMoney = self.totalMoney + AllConfig.unit[configId].dismantle_cost

      elseif self:getIsUsedFor() == CardListType.CARD_SOUL then
        self.totalMoney = self.totalMoney + self.dataArray[i]:getCardSoulCost()
      
      else
        self.totalMoney = self.totalMoney + self.dataArray[i]:getSalePrice()
      end
      self.selectedCount = self.selectedCount + 1
    end
  end

  echo("-- selectedCount,gainExp,totalMoney =", self.selectedCount,self.gainExp,self.totalMoney)
  if self.curListType == SelectType.SELECTE_ALL then 
    if self.selectedCount == tmpCount then 
      self.sprite_selectAll:setVisible(true)
    end 
  end

  --sort by default
  local package = GameData:Instance():getCurrentPackage()
  if self:getIsUsedFor() == CardListType.LEVEL_UP_EATTEN_CARD
    or self:getIsUsedFor() == CardListType.CARD_SOUL or self:getIsUsedFor() == CardListType.BABLE_SHARE then
    package:sortCards(self.dataArray, nil, SortType.RARE_UP, false)
  elseif self:getIsUsedFor() == CardListType.SURMOUNT then --surmount
    package:sortSurmountCards(self.dataArray, SortType.LEVEL_UP, SortType.RARE_UP) 

  elseif self:getIsUsedFor() == CardListType.CARD_REBORN then    --sort in CardSoulController
    package:sortCardsForRebornList(self.dataArray)
  else
    package:sortCards(self.dataArray, SortType.LEVEL_DOWN, SortType.RARE_DOWN)
  end

  UIHelper.setIsNeedScrollList(true)
end

function CardListView:onEnter()
  echo("---CardListView:onEnter---")
  self:showListView(self.dataArray)

  self:setListScrollEnable(true)
end 

function CardListView:onExit()
  echo("---CardListView:onExit---")
end


function CardListView:registerTouchEvent()
    local function onTouch(eventType, x, y)
        if eventType == "began" then
          --echo("---touch ", x, y)
          self:pointIsInListRect(x,y)
          return false
        end
    end
  self:setTouchEnabled(true)
  self:addTouchEventListener(onTouch, false, -300, true)
end

function CardListView:pointIsInListRect(touch_x, touch_y)

  local isInRect = false 

  local width = self.node_listContainer:getContentSize().width
  local height = self.node_listContainer:getContentSize().height

  local x, y = self.node_listContainer:getPosition()
  local pos_left = tolua.cast(self.node_listContainer:getParent():convertToWorldSpace(ccp(x, y)), "CCPoint")

  if touch_x > pos_left.x and touch_x < pos_left.x+width and touch_y > pos_left.y and touch_y < pos_left.y+height then
    isInRect = true
  end

  self:setListButtonEnable(isInRect)

  --echo("---pointIsInListRect:", isInRect)
  return isInRect
end

function CardListView:setListButtonEnable(isEnable)
  self._isBnEnable = isEnable
end 

function CardListView:getListButtonEnable()
  return self._isBnEnable
end 

function CardListView:onHelpHandler()
  CardListView.super:onHelpHandler()
end

function CardListView:onBackHandler()
  echo("CardListView:backCallback")

  for k,v in pairs(self.dataBackupArray) do 
    v.isSelected = false
  end

  local len = table.getn(self.selectedBackUp)
  if len >= 1 then
    for i=1, len do 
      for k,v in pairs(self.dataBackupArray) do 
        if self.selectedBackUp[i] == v:getId() then
          v.isSelected = true
        end
      end
    end
  end

  self:getDelegate():displayPreView()
end

function CardListView:filterCallback()
  echo("filter callback")

  local function filterResult(index)
    if index < 0 then 
      return 
    end

    local tbl = { _tr("pop_star_%{count}", {count=1}),
                  _tr("pop_star_%{count}", {count=2}),
                  _tr("pop_star_%{count}", {count=3}),
                  _tr("pop_star_%{count}", {count=4}),
                  _tr("pop_star_%{count}", {count=5}),
                  _tr("pop_expCard")
                }
    local colorTbl = {ccc3(199,198,198), ccc3(167,232,0),ccc3(0,176,228),ccc3(222,1,255),ccc3(255,223,14),ccc3(255,239,165)}

    self.label_filterType:setString(tbl[index])
    self.label_filterType:setColor(colorTbl[index])

    local package = GameData:Instance():getCurrentPackage()

    --reset data
    self.gainExp = 0
    self.totalMoney = 0
    self.selectedCount = 0    
    for k, v in pairs(self.dataBackupArray) do 
      v.isSelected = false
    end 

    if index < 6 then  --get part of data by rare
      self.dataArray = package:getItemsByRare(self.dataBackupArray, index)
    elseif index == 6 then 
      self.dataArray = Package:getExpCards(self.dataBackupArray)
    end

    self.sprite_selectAll:setVisible(false)
    self:showListView(self.dataArray)
  end

  --pop filter
  local pop = PopupView:createFilterPopup(filterResult)
  if self:getIsUsedFor() == CardListType.LEVEL_UP_EATTEN_CARD then -- level up eat cards
    pop.node4_expFilter:setVisible(true)
  end 
  self:addChild(pop)
end

function CardListView:removeItem(tbl, id)
  for i=1, table.getn(tbl) do 
    if tbl[i]:getId() == id then 
      table.remove(tbl, i)
      echo("---remove id:", id)
      break
    end
  end
end

function CardListView:confirmCallback()
  echo("confirmCallback")

  local array = {}
  for k,v in pairs(self.dataBackupArray) do 
    if v.isSelected == true then 
      table.insert(array, v)
    end
  end

  if self:getIsUsedFor() == CardListType.CARD_REBORN then
    CardSoul:instance():setRebornCards(array)
    
  elseif self:getIsUsedFor() == CardListType.LEVEL_UP_CARD or self:getIsUsedFor() == CardListType.LEVEL_UP_EATTEN_CARD then
    Enhance:instance():setLevelUpCards(array)

  elseif self:getIsUsedFor() == CardListType.CARD_SOUL then 
    CardSoul:instance():setRefinedCards(array)
  end

  self:getDelegate():displayPreView()
end

function CardListView:selectAllCallback()
  echo("select all")
  
  local arrayLen = table.getn(self.dataArray)

  self.totalMoney = 0
  self.gainExp = 0

  echo("arrayLen,self.selectedCount=",arrayLen,self.selectedCount)

  if self:getIsUsedFor() == CardListType.CARD_SOUL then 
    arrayLen = math.min(5, arrayLen)
  end 


  if arrayLen ~= self.selectedCount then
    for i=1, arrayLen do 
      self.dataArray[i].isSelected = true

      self.gainExp = self.gainExp + self.dataArray[i]:getGainedExpAfterEaten()

      if self:getIsUsedFor() == CardListType.LEVEL_UP_CARD or self:getIsUsedFor() == CardListType.LEVEL_UP_EATTEN_CARD then
        self.totalMoney = self.totalMoney + self.dataArray[i]:getCost()

      elseif self:getIsUsedFor() == CardListType.CARD_REBORN then
        local configId = self.dataArray[i]:getConfigId()
        self.totalMoney = self.totalMoney + AllConfig.unit[configId].dismantle_cost

      elseif self:getIsUsedFor() == CardListType.CARD_SOUL then
        self.totalMoney = self.totalMoney + self.dataArray[i]:getCardSoulCost()

      else
        self.totalMoney = self.totalMoney + self.dataArray[i]:getSalePrice()     
      end   
    end 

    self.selectedCount = arrayLen
    self.sprite_selectAll:setVisible(true)

  else 
    for i=1, #self.dataArray do 
      self.dataArray[i].isSelected = false
    end
    self.sprite_selectAll:setVisible(false)
    self.selectedCount = 0
  end 

  --local tableview = self.node_listContainer:getChildByTag(126)
  if self.tableView ~= nil then 
    echo("reload data")
    self.tableView:reloadData()
  end

  self:updateToolBar()
end


function CardListView:updateToolBar()
  --echo("---updateToolBar:selectedCount=", self.selectedCount)
  if self.selectedCount >= 1 then 
    self:getDelegate():getScene():setBottomVisible(false)

    self.label_selectedNum:setString(string.format("%d", self.selectedCount))
    -- self.pOutLineSelectNum:setString(string.format("%d", self.selectedCount))
    
    if self:getIsUsedFor() == CardListType.CARD_REBORN or self:getIsUsedFor() == CardListType.CARD_SOUL then 
      self.node_toolbarText1:setVisible(false)
      self.node_toolbarText2:setVisible(true)
      self.label_coinCost2:setString(string.format("%d", self.totalMoney))
      -- self.pOutLineCointCost2:setString( string.format("%d", self.totalMoney))      
    else 
      self.node_toolbarText1:setVisible(true)
      self.node_toolbarText2:setVisible(false)
      self.label_coinCost:setString(string.format("%d", self.totalMoney))
      self.label_gainExpe:setString(string.format("%d", self.gainExp))
      -- self.pOutLineCointCost:setString( string.format("%d", self.totalMoney))
      -- self.pOutLineGainedExp:setString( string.format("%d", self.gainExp))
    end

    if self.node_bottom:isVisible() == false then 
      self.node_bottom:setVisible(true)
      --show animation 
      self.node_bottom:setPositionY(-self.node_bottom:getContentSize().height)
      local moveto = CCMoveTo:create(0.6, ccp(display.width/2,0))
      local easeOut = CCEaseExponentialOut:create(moveto)
      self.node_bottom:runAction(easeOut)
    end
  else 
    self:getDelegate():getScene():setBottomVisible(true)
    self.node_bottom:setVisible(false)
  end
end

function CardListView:setIsUsedFor(val)
  self._isUsedFor = val
end

function CardListView:getIsUsedFor()
  if self._isUsedFor == nil then 
    self._isUsedFor = 0
  end

  return self._isUsedFor
end

function CardListView:setListScrollEnable(isEnabled)
  if isEnabled == false then
    self._lastY = 0
    if self.tableView ~= nil then 
      self._lastY = self.tableView:getContainer():getPositionY()
    end 
  end 

  self._listScrollEnable = isEnabled
end 

function CardListView:getListScrollEnable()
  return self._listScrollEnable
end 


function CardListView:showListView(listData)

  if listData == nil then 
    return
  end 
  
  echo("showListView")

  self.dataArray = listData
  self.cellItems = {}

  local totalCells = table.getn(listData)

  self:updateToolBar()


  local function scrollViewDidScroll(view)
    if self:getListScrollEnable() == false then 
      echo(" disable scroll...")
      self.tableView:getContainer():setPositionY(self._lastY)
    end 
  end

  local function tableCellTouched(tableview,cell)   
    local isSelected = 0
    local idx = cell:getIdx()
    local item = self.cellItems[idx+1] --cell:getChildByTag(100)
    --echo("touch idx =",idx, item)

    if item == nil then 
      echo("invalid item while touch !!")
      return
    end

    if self:getIsUsedFor() == CardListType.CARD_SOUL and (listData[idx+1].isSelected == false) and self.selectedCount >= 5 then 
      Toast:showString(self, string._tran(Consts.Strings.SOUL_SELECTED_COUNT_EXCEED), ccp(display.width/2, display.height*0.4))      
      return 
    end 

    --directly rerturn while touch hanpen for select one card
    if self.curListType == SelectType.SELECTE_ONE then
      if self:getIsUsedFor() == CardListType.LEVEL_UP_CARD or self:getIsUsedFor() == CardListType.LEVEL_UP_EATTEN_CARD then -- level up
        Enhance:instance():setLevelUpCard(listData[idx+1])
        Enhance:instance():setLevelUpCards(nil)

      elseif self:getIsUsedFor() == CardListType.SURMOUNT then
        Enhance:instance():setSurmountedCard(listData[idx+1])

      elseif self:getIsUsedFor() == CardListType.SKILL_UP then -- skill up
        Enhance:instance():setSkillCard(listData[idx+1])

      elseif self:getIsUsedFor() == CardListType.CARD_REBORN then --dismantle 
        local str 
        if listData[idx+1]:getIsOnBattle() then 
          str = _tr("battle_card_cannot_dismantled")
        elseif listData[idx+1]:getCradIsWorkState() then 
          str = _tr("working_card_cannot_dismanted")
        end 
        if str then 
          Toast:showString(self, str, ccp(display.cx, display.cy))
          return 
        end 

        CardSoul:instance():setRebornCards({listData[idx+1]})

      elseif self:getIsUsedFor() == CardListType.BABLE_SHARE then 
        Bable:instance():setSharedCard(listData[idx+1])

      else
        echo("invalid data....")
      end
      self:getDelegate():displayPreView()
      return
    end

    listData[idx+1].isSelected = not listData[idx+1].isSelected

    --highlight curIndex
    item:setSelectedIconVisible(listData[idx+1].isSelected)

    if listData[idx+1].isSelected == false then 
      self.sprite_selectAll:setVisible(false)
    end

    local configId = listData[idx+1]:getConfigId() 
    local dismantleCost = AllConfig.unit[configId].dismantle_cost

    --update toolbar info
    if listData[idx+1].isSelected == true then 
      self.gainExp = self.gainExp + listData[idx+1]:getGainedExpAfterEaten()

      if self:getIsUsedFor() == CardListType.LEVEL_UP_CARD or self:getIsUsedFor() == CardListType.LEVEL_UP_EATTEN_CARD then --level up
        self.totalMoney = self.totalMoney + listData[idx+1]:getCost()

      elseif self:getIsUsedFor() == CardListType.CARD_REBORN then
        self.totalMoney = self.totalMoney + dismantleCost

      elseif self:getIsUsedFor() == CardListType.CARD_SOUL then
        self.totalMoney = self.totalMoney + listData[idx+1]:getCardSoulCost()

      else
        self.totalMoney = self.totalMoney + listData[idx+1]:getSalePrice()
      end
      self.selectedCount = self.selectedCount + 1

    else 
      self.gainExp = self.gainExp - listData[idx+1]:getGainedExpAfterEaten()
      if self:getIsUsedFor() == CardListType.LEVEL_UP_CARD or self:getIsUsedFor() == CardListType.LEVEL_UP_EATTEN_CARD then --level up
        self.totalMoney = self.totalMoney - listData[idx+1]:getCost()

      elseif self:getIsUsedFor() == CardListType.CARD_REBORN then
        self.totalMoney = self.totalMoney - dismantleCost

      elseif self:getIsUsedFor() == CardListType.CARD_SOUL then
        self.totalMoney = self.totalMoney - listData[idx+1]:getCardSoulCost()

      else 
        self.totalMoney = self.totalMoney - listData[idx+1]:getSalePrice()
      end

      self.selectedCount = self.selectedCount - 1          
    end
    --update tool bar
    self:updateToolBar() 
  end
  
  local function tableCellHighLight(table, cell)    
    local idx = cell:getIdx()
    local item = self.cellItems[idx+1] --cell:getChildByTag(100)
    if item ~= nil then
      item:setSelectedHighlight(true)
    else 
      echo("tableCellHighLight: invalid item !!")
    end
  end 

  local function tableCellUnhighLight(table, cell)
    local idx = cell:getIdx()
    local item = self.cellItems[idx+1] --cell:getChildByTag(100)
    if item ~= nil then
      item:setSelectedHighlight(false)
    else 
      echo("tableCellUnhighLight: invalid item !!")
    end
  end

  local function cellSizeForTable(tableview,idx)
    return self.cellHeight,self.cellWidth
  end
  
  
  local function tableCellAtIndex(tableview, idx)
    --echo("cellAtIndex = "..idx)
    local cell = tableview:dequeueCell()
    local item = nil
    if nil == cell then
      cell = CCTableViewCell:new()
      item = PlayStatesCardListItem.new()
      cell:addChild(item)
    else
      item = cell:getChildByTag(100)
    end

    if item ~= nil then 
      local card = listData[idx+1]
      item:setCard(card)
      item:setButtonEnableDelegate(function() return self:getListButtonEnable() end)
      item:setSelected(false)
      item:setSelectedVisible(false)

      if self:getIsUsedFor() == CardListType.LEVEL_UP_CARD or self:getIsUsedFor() == CardListType.CARD_SOUL 
        or self:getIsUsedFor() == CardListType.CARD_REBORN or self:getIsUsedFor() == CardListType.BABLE_SHARE then 
        item:setLevelPreName(_tr("level")..string.format(":%d/%d", card:getLevel(),card:getMaxLevel()), ccc3(0, 255, 16))
        item:setLevelString("")

      elseif self:getIsUsedFor() == CardListType.LEVEL_UP_EATTEN_CARD then
        -- item:setLevelPreName("获得经验", nil)
        -- item:setLevelString(string.format("%d", card:getGainedExpAfterEaten()))
        item:setLevelPreName(_tr("gain exp %{count}", {count=card:getGainedExpAfterEaten()}), ccc3(0, 255, 16))
        item:setLevelString("")

      elseif self:getIsUsedFor() == CardListType.SURMOUNT then  --for surmount
        local str,color = Enhance:instance():getSurmountInfoByCard(card)
        item:setLevelPreName(str, color)
        item:setLevelString("")

      -- elseif self:getIsUsedFor() == CardListType.DISMANTLE then  --for dismantle        
      --   local str,color = Enhance:instance():getDropItemsName(card)
      --   item:setLevelPreName(str, color)
      --   item:setLevelString("")

      elseif self:getIsUsedFor() == CardListType.SKILL_UP then --skill up
        -- item:setLevelPreName("技能等级", nil)
        -- item:setLevelString(string.format("%d", card:getSkill():getLevel()))  
        item:setLevelPreName(_tr("skill level")..string.format("%d/%d", card:getSkill():getLevel(), card:getSkill():getMaxLevel()), ccc3(0, 255, 16))
        item:setLevelString("")              
      else 
        -- item:setLevelPreName("领导力",nil)
        -- item:setLevelString(card:getLeadCost())
        item:setLevelPreName(_tr("leadship %{count}", {count=card:getLeadCost()}), ccc3(0, 255, 16))
        item:setLevelString("")           
      end

      item:setSelectedVisible(true)
      item:setTag(100)

      if self.curListType == SelectType.SELECTE_ALL then 
        item:setSelectedIconVisible(listData[idx+1].isSelected)
      end

      self.cellItems[idx+1] = item --back up
    end

    if self.cellNumPerPage > 0 then 
      UIHelper.showScrollListView({object=item, totalCount=self.cellNumPerPage, index = idx})
    end 
    
    return cell
  end
  

  local function numberOfCellsInTableView(tableview)
    return totalCells
  end


  --remove tableview and kong.png
  self.node_listContainer:removeAllChildrenWithCleanup(true)



  if self.curListType == SelectType.SELECTE_ALL then 
    self.bn_selectAll:setVisible(true)
    self.label_selectAll:setVisible(true)
  else 
    self.bn_selectAll:setVisible(false)
    self.label_selectAll:setVisible(false)
  end

  --set position of tab menu and list container 
  local filterHeight = self.node_fileter:getContentSize().height
  local size = self:getCanvasContentSize()
  local w = 640 --size.width
  local h = size.height - filterHeight
  local bottomHeight = self:getDelegate():getScene():getBottomContentSize().height
  local pos_y = bottomHeight

  self.node_listContainer:setPosition(ccp((display.width-640)/2, pos_y))
  self.node_listContainer:setContentSize(CCSizeMake(w, h))

  self.node_fileter:setPositionY(bottomHeight+size.height - filterHeight+10)

  self.cellNumPerPage = math.ceil(h/self.cellHeight)
  if self.cellNumPerPage == 0 then 
    UIHelper.setIsNeedScrollList(false)
  end

  if totalCells == 0 then 
    self.sprite_selectAll:setVisible(false)
    self:setEmptyImgVisible(true)
  else 
    self:setEmptyImgVisible(false)
  end

  --create table view
  self.tableView = CCTableView:create(CCSizeMake(w, h))
  self.tableView:setDirection(kCCScrollViewDirectionVertical)
  self.tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  self.tableView:setTag(126)
  
  self.tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  self.tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  self.tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  self.tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  self.tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  self.tableView:registerScriptHandler(tableCellHighLight,CCTableView.kTableCellHighLight)
  self.tableView:registerScriptHandler(tableCellUnhighLight,CCTableView.kTableCellUnhighLight)  
  self.tableView:reloadData()
  self.node_listContainer:addChild(self.tableView)
end


