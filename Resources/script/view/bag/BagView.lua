
require("view.component.ViewWithEave")
require("view.component.PopupView")
require("view.component.Toast")
require("view.component.Loading")
require("view.card_levelup.PopupUseExpPropView")
require("model.bag.BagPropsData")

BagView = class("BagView", ViewWithEave)


function BagView:ctor(viewIndex)
  BagView.super.ctor(self)

  --1. load levelup view ccbi
  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("saleCallback",BagView.saleCallback)
  -- pkg:addFunc("useCallback",BagView.useCallback)
  pkg:addFunc("startMergeCallback",BagView.startMergeCallback)
  pkg:addFunc("touchCailiao1",BagView.touchCailiao1)
  pkg:addFunc("touchCailiao2",BagView.touchCailiao2)
  pkg:addFunc("touchCailiao3",BagView.touchCailiao3)

  pkg:addProperty("node_listContainer","CCNode")
  pkg:addProperty("node_props","CCNode")
  pkg:addProperty("node_merge","CCNode")
  pkg:addProperty("node_page","CCNode")

  pkg:addProperty("sprite_star1","CCSprite")
  pkg:addProperty("sprite_star2","CCSprite")
  pkg:addProperty("sprite_star3","CCSprite")
  pkg:addProperty("sprite_star4","CCSprite")
  pkg:addProperty("sprite_star5","CCSprite")
  pkg:addProperty("sprite_star6","CCSprite")
  pkg:addProperty("sprite_star7","CCSprite")
  pkg:addProperty("sprite_star8","CCSprite")
  pkg:addProperty("sprite_star9","CCSprite")
  pkg:addProperty("sprite_star10","CCSprite")
  pkg:addProperty("sprite_cailiao1","CCSprite")
  pkg:addProperty("sprite_cailiao2","CCSprite")
  pkg:addProperty("sprite_cailiao3","CCSprite")

  pkg:addProperty("label_preSale","CCLabelTTF")
  pkg:addProperty("label_preCost","CCLabelTTF")
  pkg:addProperty("label_propsName","CCLabelTTF")
  pkg:addProperty("label_sale","CCLabelTTF")
  pkg:addProperty("label_propDesc","CCLabelTTF")

  pkg:addProperty("label_cailiao1","CCLabelTTF")
  pkg:addProperty("label_cailiao2","CCLabelTTF")
  pkg:addProperty("label_cailiao3","CCLabelBMFont")
  pkg:addProperty("label_mergeCost","CCLabelTTF")

  pkg:addProperty("bn_merge","CCControlButton")
  pkg:addProperty("bn_sale","CCControlButton")
  pkg:addProperty("bn_use","CCControlButton")

  local layer,owner = ccbHelper.load("BagView.ccbi","BagViewCCB","CCLayer",pkg)
  self:addChild(layer)
  
  self.bn_use:addHandleOfControlEvent(handler(self,BagView.useCallback),CCControlEventTouchDown)

  self:setViewIndex(viewIndex)
end


function BagView:onEnter()
  echo("---BagView:onEnter---")

  self:setTitleTextureName("bag-paibian.png")

  local menuArray = {
      {"#bn_daoju0.png","#bn_daoju1.png"},
      {"#bn_kapaisuipian0.png","#bn_kapaisuipian1.png"},
      {"#bn_zhuangbeisuipian0.png","#bn_zhuangbeisuipian1.png"},
      {"#bn_hecheng0.png","#bn_hecheng1.png"}
    }
  self:setMenuArray(menuArray)
  self:getTabMenu():setItemSelectedByIndex(1)

  --init var
  self.curPage = -1
  self.cellWidth = self.node_listContainer:getContentSize().width
  self.cellHeight = self.node_listContainer:getContentSize().height
  self.propsRow = 3
  self.propsCol = 5
  self.sellNum = 0
  self.highlightItem = 1 
  self.touch_x = 0
  self.touch_y = 0

  self:initOutLineLabel()
  self.label_preSale:setString(_tr("sale"))
  self.label_preCost:setString(_tr("cost"))
  self.dataInstance = BagPropsData.new(self)

  self:gotoView(self:getViewIndex(), highlightPropId)
  self:getTabMenu():setItemSelectedByIndex(self:getViewIndex())
  self:getEaveView().btnHelp:setVisible(false)
  
  _registNewBirdComponent(111001,self.bn_use)
  _executeNewBird()
end 

function BagView:onExit()
  echo("---BagView:onExit---")
  self.dataInstance:exit()
end

function BagView:updateListData(viewIndex)
  if viewIndex == 1 then --props view
    self.listData = self.dataInstance:getPropsData()
  elseif viewIndex == 2 then --card chip view
    self.listData = self.dataInstance:getCardChipData()
  elseif viewIndex == 3 then --equip chip view
    self.listData = self.dataInstance:getEquipChipData()
  elseif viewIndex == 4 then --merge view
    self.listData = self.dataInstance:getMergeData()
  end
end 

function BagView:gotoView(index, highlightPropId)
  echo("BagView:gotoView", index)

  CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("img/bag/bag.plist") --fixed bug1715
  self:setViewIndex(index)

  if index == 1 then --props view
    self.node_props:setVisible(true)
    self.node_merge:setVisible(false)
  elseif index == 2 then --card chip view

  elseif index == 3 then --equip chip view

  elseif index == 4 then --merge view
    if GameData:Instance():checkSystemOpenCondition(9, true) == false then 
      return false 
    end 
  end

  self.curPage = -1

  self:updateListData(self:getViewIndex())

  self:resetView(index)
  self:setPageIndexByOffset(0)

  if highlightPropId ~= nil then 
    for k, v in pairs(self.listData) do 
      if v:getId() == highlightPropId then
        self.highlightItem = k
        break
      end
    end
  end 

  self:showPropsList()
  
  return true
end

function BagView:resetView(index)
  local num = table.getn(self.listData)
  self.totalCells = math.max(5, math.ceil(num/(self.propsRow*self.propsCol)))

  self.highlightItem = 1

  if index <= 3 then 
    self.node_props:setVisible(true)
    self.node_merge:setVisible(false)
    if num > 0 then
      self.bn_sale:setEnabled(true)
      self.bn_use:setEnabled(true)
    else
      self.bn_sale:setEnabled(false)
      self.bn_use:setEnabled(false)
    end
    --reset 
    self:setHighlightStar(0, 0)
    self.pOutLinePropName:setString(" ")
    self.label_propDesc:setString("") 
    self.label_sale:setString("")
  else 
    self.node_props:setVisible(false)
    self.node_merge:setVisible(true) 
    if num > 0 then
      self.bn_merge:setEnabled(true)
    else
      self.bn_merge:setEnabled(false)
    end
    --reset 
    self.sprite_cailiao1:removeAllChildrenWithCleanup(true)
    self.sprite_cailiao2:removeAllChildrenWithCleanup(true)
    self.sprite_cailiao3:removeAllChildrenWithCleanup(true)
    self.label_cailiao1:setString("")
    self.label_cailiao2:setString("")
    self.label_cailiao3:setString("")
    self.label_mergeCost:setString("")
  end 
end

function BagView:dispViewInfo(viewIndex, item)
  if item == nil then 
    self:resetView(viewIndex)
    return 
  end

  if viewIndex <= 3 then 
    --self.label_propsName:setString(item:getName())
    self.pOutLinePropName:setString(item:getName())
    self.label_propDesc:setString(item:getDescStr())
    self.label_sale:setString(string.format("%d",item:getSalePrice()))
    self:setHighlightStar(item:getGrade(), item:getMaxGrade())

    local itemType = item:getItemType()
    local grade = item:getGrade()

    --判断可否被使用
    if itemType==iType_HuFu or itemType==iType_BoxKey or itemType==iType_JinNang or itemType==iType_Bable
      or itemType==iType_GuaJiQuan or itemType==iType_WuJin or itemType==iType_Exchange 
      or (itemType==iType_HunShi and grade==5) or (itemType==iType_JunLingZhuang and grade==5)
      or (itemType==iType_SkillBook and grade==5) or (itemType==iType_XuanTie and grade==5) 
      or itemType==iType_ExpeditionMedicine or itemType==iType_ArenaMedicine or itemType==iType_JingjiMedicine 
      then 
      self.bn_use:setEnabled(false)
    else
      self.bn_use:setEnabled(true)
    end

    local maxbagCount = GameData:Instance():getCurrentPlayer():getMaxItemBagCount()
    if self:getViewIndex() == 1 and self.highlightItem > maxbagCount then 
      self.bn_use:setEnabled(false)
      self.bn_sale:setEnabled(false)
    else 
      self.bn_sale:setEnabled(item:getSaleFlag() > 0)
    end
    
  else 

    --for merge view
    self.sprite_cailiao1:removeAllChildrenWithCleanup(true)
    self.sprite_cailiao2:removeAllChildrenWithCleanup(true)
    self.sprite_cailiao3:removeAllChildrenWithCleanup(true)
    self.label_cailiao1:setString("")
    self.label_cailiao2:setString("")
    self.label_cailiao3:setString("")

    self.dataInstance:setCoinEnough(false)

    local combineSummary = AllConfig.combinesummary[item:getConfigId()]
    if combineSummary == nil then 
      echo("invalid combineSummary !!")
      return
    end

    self.matsInfo = {}
    local package = GameData:Instance():getCurrentPackage()
    local nodeMats = {self.sprite_cailiao1, self.sprite_cailiao2}
    local labelMats = {self.label_cailiao1, self.label_cailiao2}
    local iconSize = nodeMats[1]:getContentSize()
    local myCoins = GameData:Instance():getCurrentPlayer():getCoin()
    local needCoins = 0 
    local index = 1 
    local canCombineCount = 50

    for k, v in pairs(combineSummary.consume) do 
      local dataItem = v.array
      if dataItem[1] == 4 then 
        needCoins = dataItem[3]        
      else 
        if index > #nodeMats then 
          break 
        end 
        self.matsInfo[index] = dataItem --backup
        local sprite = package:getItemSprite(nil, dataItem[1], dataItem[2], dataItem[3], false)
        if sprite ~= nil then         
          sprite:setPosition(ccp(iconSize.width/2, iconSize.height/2))
          nodeMats[index]:addChild(sprite)

          local ownNum = package:getPropsNumByConfigId(dataItem[2])
          local exceptNum = dataItem[3]   

          if ownNum >= exceptNum then 
            labelMats[index]:setColor(ccc3(32,143,0))
            canCombineCount = math.min(canCombineCount, math.floor(ownNum/exceptNum))            
          else 
            labelMats[index]:setColor(ccc3(201,1,1))
            canCombineCount = 0 
          end

          labelMats[index]:setString(string.format("%d/%d", ownNum, exceptNum)) 
          index = index + 1 
        end         
      end 
    end 
    self.dataInstance:setMergedCountMax(canCombineCount*combineSummary.count)
    self.dataInstance:setCoinEnough(myCoins >= needCoins)
    self.label_mergeCost:setString(""..needCoins)
    self.dataInstance:setCombineCost(needCoins)
    --target
    local sprite3 = package:getItemSprite(nil, combineSummary.target_type, combineSummary.target_item, self.dataInstance:getMergedCountMax())
    if sprite3 ~= nil then
      sprite3:setPosition(ccp(iconSize.width/2, iconSize.height/2))
      self.sprite_cailiao3:addChild(sprite3)
      -- self.self.label_cailiao3:setString(""..self.dataInstance:getMergedCountMax())
    end
    
    --enable/disable button
    self.bn_merge:setEnabled(self.dataInstance:getMergedCountMax() > 0)
    echo("=== combine, configId, canCombineNum", item:getConfigId(), self.dataInstance:getMergedCountMax())
  end
end 

function BagView:setViewIndex(viewIndex)
  self._viewIndex = viewIndex 
end 

function BagView:getViewIndex()
  return self._viewIndex or 1 
end 

function BagView:initOutLineLabel()
  --coint name
  self.label_propsName:setString("")
  self.pOutLinePropName = ui.newTTFLabelWithOutline( {
                                            text = " ",
                                            font = self.label_propsName:getFontName(),
                                            size = self.label_propsName:getFontSize(),
                                            x = 0,
                                            y = 0,
                                            color = ccc3(255, 234, 0),
                                            align = ui.TEXT_ALIGN_LEFT,
                                            --valign = ui.TEXT_VALIGN_TOP,
                                            --dimensions = CCSize(200, 30),
                                            outlineColor =ccc3(0,0,0),
                                            pixel = 2
                                            }
                                          )
  -- self.label_propsName:addChild(self.pOutLinePropName)
  self.pOutLinePropName:setPosition(ccp(self.label_propsName:getPosition()))
  self.label_propsName:getParent():addChild(self.pOutLinePropName)  
end

function BagView:onBackHandler()
  echo("BagView:backCallback")
  BagView.super:onBackHandler()
  
  self:getController():goBackView()
end

function BagView:tabControlOnClick(idx)
  _playSnd(SFX_CLICK)

  local propId = nil 
  if self.highlightItem <= table.getn(self.listData) then
    propId = self.listData[self.highlightItem]:getId()
  end 
  echo("=== propId=", propId)
  return self:gotoView(idx+1, propId)
end

function BagView:setController(controller)
  self._controller = controller
end

function BagView:getController()
  return self._controller
end


function BagView:saleCallback()
  echo("BagView:saleCallback")

  _playSnd(SFX_CLICK)

  local leftNum = table.getn(self.listData)
  if leftNum < 1 then 
    echo(" empty props !!!")
    return
  end 

  if self.highlightItem > leftNum then 
    echo("invalid props item !!")
    return 
  end 

  local item = self.listData[self.highlightItem]
  self.dataInstance:sellToSystem(item)
end


function BagView:useCallback()
  echo("BagView:useCallback")

  _playSnd(SFX_CLICK)

  if table.getn(self.listData) < 1 then
    echo(" empty props !!!")
    return
  end

  local item = self.listData[self.highlightItem]
  if self.highlightItem <= table.getn(self.listData) then
    if item:getIsMergedProps() == true then
      if self:gotoView(4, item:getId()) == true then 
        self:getTabMenu():setItemSelectedByIndex(4)
      end 
    else 
      if item:getItemType() == iType_ExpCard then
        local popupUseExpPropView = PopupUseExpPropView.new(item,self.dataInstance,CCSizeMake(615,650))
        popupUseExpPropView:setCloseCallBack(function() self:updateList() end)
        self:addChild(popupUseExpPropView,100)
        return
      end
      self.dataInstance:useItem(item)
    end
  end
end


function BagView:startMergeCallback()
  echo(" === BagView:startMergeCallback ===")
  _playSnd(SFX_CLICK)

  if table.getn(self.listData) < 1 then
    echo(" empty props !!!")
    return
  end

  if self.dataInstance:getCoinEnough() == false then
    Toast:showString(self, _tr("not enough coin"), ccp(display.cx, display.cy))
    return
  end

  if self.highlightItem <= table.getn(self.listData) then
    local item = self.listData[self.highlightItem]
    self.dataInstance:startMerge(item)
  end
end 

function BagView:touchCailiao1()
  if self.highlightItem <= table.getn(self.listData) then 
    if self.matsInfo and #self.matsInfo >= 1 then 
      TipsInfo:showTip(self.sprite_cailiao1, self.matsInfo[1][2])
    end 
  end
end 

function BagView:touchCailiao2()
  if self.highlightItem <= table.getn(self.listData) then 
    if self.matsInfo and #self.matsInfo >= 2 then 
      TipsInfo:showTip(self.sprite_cailiao2, self.matsInfo[2][2])
    end 
  end
end

function BagView:touchCailiao3()
  if self.highlightItem <= table.getn(self.listData) then 
    local id = self.listData[self.highlightItem]:getConfigId()
    local configId = AllConfig.combinesummary[id].target_item
    if AllConfig.combinesummary[id].target_type == 7 then --new equip, attr should be null
      local equip = Equipment.new()
      equip:setConfigId(configId) 
      local equipOrbit =  EquipOrbitCard.new({equipData = equip})
      equipOrbit:show() 
    else 
      TipsInfo:showTip(self.sprite_cailiao3, configId)
    end 
  end
end

function BagView:getTableViewCenterPos()
  local x, y = self.node_listContainer:getPosition()
  local pos = tolua.cast(self.node_listContainer:getParent():convertToWorldSpace(ccp(x, y)), "CCPoint")
  local size = self.node_listContainer:getContentSize()

  return ccp(pos.x + size.width/2, pos.y + size.height/2)
end

function BagView:setHighlightStar(starNum, maxNum)
  local starArray = {self.sprite_star1, self.sprite_star2, self.sprite_star3, self.sprite_star4, self.sprite_star5,
                     self.sprite_star6, self.sprite_star7, self.sprite_star8, self.sprite_star9, self.sprite_star10}
  local starW = self.sprite_star1:getContentSize().width
  --local start_x = self.label_propsName:getPositionX() + self.label_propsName:getContentSize().width + 5
  local start_x = self.label_propsName:getPositionX() + self.pOutLinePropName:getContentSize().width + 5

  for i=1, 10 do 
    starArray[i]:setVisible(false)
  end
  for i = 1, 5 do 
    if i <= starNum then 
      starArray[5+i]:setVisible(true)
      starArray[5+i]:setPositionX(start_x + starW * i)
    elseif i <= maxNum then 
      starArray[i]:setVisible(true)
      starArray[i]:setPositionX(start_x + starW * i)
    end
  end
end 


-------------------------------------table view----------------------------------------
function BagView:registerTouchEvent()
    local function onTouch(eventType, x, y)
        if eventType == "began" then
          self.touch_x = x
          self.touch_y = y
          self.isTouchEnd = false
          return true
        elseif eventType == "ended" then
          self.isTouchEnd = true
        end
    end
  
  self:addTouchEventListener(onTouch)
  self:setTouchEnabled(true)
end

function BagView:setHighlightProps()
  if self.listData == nil then
    return
  end

  local prosArrLen = table.getn(self.listData)
  if prosArrLen <= 0 then 
    self:resetView(self:getViewIndex())
    return
  end

  
  if self.highlightItem > prosArrLen then 
    self.highlightItem = prosArrLen
  end

  --show view info
  local item = self.listData[self.highlightItem]
  self:dispViewInfo(self:getViewIndex(), item)
  echo(" setHighlightProps: highlight props , index = ", item:getConfigId(), self.highlightItem)

  --show highlight box
  local curCellIndex = math.floor((self.highlightItem-1)/(self.propsRow*self.propsCol))
  local itemWidth = self.cellWidth/self.propsCol
  local itemHeight = self.cellHeight/self.propsRow

  local row = math.floor((self.highlightItem-curCellIndex*self.propsRow*self.propsCol - 1)/self.propsCol)  --up-->down 0~2
  local col = (self.highlightItem-1)%self.propsCol          --left-->right 0~4
  local pos = ccp(col*itemWidth+itemWidth/2, self.cellHeight-(row+1)*itemHeight+itemHeight/2)
  -- echo("=====pos", pos.x, pos.y, row, col)

  if self.tableView ~= nil then 
    local highlightBox = nil 
    if self.preCellIndex == nil then --init
      self.preCellIndex = 0
    end
    -- echo("--curCellIndex, preCellIndex=", curCellIndex, self.preCellIndex)
    if curCellIndex == self.preCellIndex then 
      local curCell = self.tableView:cellAtIndex(curCellIndex)
      if curCell ~= nil then 
        local node = curCell:getChildByTag(100)
        if node ~= nil then 
          highlightBox = node:getChildByTag(128)
          if highlightBox == nil then
            highlightBox = CCSprite:createWithSpriteFrameName("highlight-box.png")
            highlightBox:setTag(128)                    
            node:addChild(highlightBox)
          end
        end
      end 
    else
      --remove highlightBox from preCell
      local preCell = self.tableView:cellAtIndex(self.preCellIndex)
      if preCell ~= nil then 
        local node = preCell:getChildByTag(100)
        if node ~= nil then 
          local box = node:getChildByTag(128)
          if box ~= nil then 
            node:removeChild(box, true)
          end
        end
      end

      --add highlightBox to current Cell
      local curCell = self.tableView:cellAtIndex(curCellIndex)
      if curCell ~= nil then 
        local node = curCell:getChildByTag(100)
        if node ~= nil then           
          highlightBox = node:getChildByTag(128)
          if highlightBox == nil then 
            highlightBox = CCSprite:createWithSpriteFrameName("highlight-box.png")                
            highlightBox:setTag(128)
            node:addChild(highlightBox)
          end 
          self.preCellIndex = curCellIndex
        end
      end 
    end

    -- set cell position
    local offsetX = -curCellIndex*self.cellWidth
    self.tableView:setContentOffset(ccp(offsetX, 0))
    self:setPageIndexByOffset(offsetX)
    if highlightBox ~= nil then 
      highlightBox:setPosition(pos)  
    end
  end
end

function BagView:setPageIndexByOffset(viewOffsetX)

  if self.pagesArray == nil then 
    self.pagesArray = {}
    local pages = math.max(5, self.totalCells)
    self.pagesArray[1] = CCSprite:createWithSpriteFrameName("page_index_1.png")
    self.node_page:addChild(self.pagesArray[1], 20)
    self.pagesArray[1]:setVisible(false)
    for i=1, pages do 
      self.pagesArray[i+1] = CCSprite:createWithSpriteFrameName("page_index_0.png") 
      self.node_page:addChild(self.pagesArray[i+1])
      self.pagesArray[i+1]:setVisible(false)
    end 
  end 

  echo("=== setPageIndexByOffset",  self.totalCells, #self.pagesArray)

  --page扩展
  if self.totalCells + 1 > #self.pagesArray then 
    echo("== extend page..")
    for i=#self.pagesArray+1, self.totalCells+1 do 
      self.pagesArray[i] = CCSprite:createWithSpriteFrameName("page_index_0.png") 
      self.pagesArray[i]:setVisible(false)
      self.node_page:addChild(self.pagesArray[i])
    end     
  end 

  if self.totalCells > 1 then 
    local index = -math.floor((viewOffsetX+self.cellWidth*0.66)/self.cellWidth ) + 1
    index = math.min(self.totalCells, math.max(1, index))
    if self.curPage ~= index then 
      self.curPage = index

      local idxWidth = math.max(20, self.pagesArray[1]:getContentSize().width)
      local pos_x = self.node_page:getPositionX() - self.totalCells*idxWidth/2

      for i=2, #self.pagesArray do 
        if i <= self.totalCells+1 then 
          self.pagesArray[i]:setVisible(true)
          self.pagesArray[i]:setPositionX(pos_x + (i-2)*idxWidth)
        else 
          self.pagesArray[i]:setVisible(false)
        end
      end
      --hightlight page
      self.pagesArray[1]:setVisible(true)
      self.pagesArray[1]:setPositionX(pos_x+(index-1)*idxWidth)
    end
  end 
end

function BagView:checkBuyCells(itemIdx)
  if self:getViewIndex() ~= 1 then --just for props view can buy cell
    return 
  end

  local player = GameData:Instance():getCurrentPlayer()
  local ownCellsNum = player:getMaxItemBagCount()
  local hasBuyNum = player:getAddedBuyItemBagCount()
  -- echo("-----index, bag num=", itemIdx, ownCellsNum, hasBuyNum)
  if itemIdx > ownCellsNum and itemIdx then 
    local function startToBuyCell()
      local startCellIdx = math.floor((ownCellsNum - 1)/(self.propsRow*self.propsCol))
      local endCellIdx = math.floor((itemIdx - 1)/(self.propsRow*self.propsCol))
      self.dataInstance:buyItemCell(itemIdx-ownCellsNum, startCellIdx, endCellIdx)
    end

    --get cost money
    local costMoney = 0
    for i = ownCellsNum+1, itemIdx do 
      costMoney = costMoney + GameData:Instance():getCurrentPackage():getBagCellPrice(i-(ownCellsNum-hasBuyNum))
    end
    local str = _tr("open bag cell%{count}", {count = costMoney})
    local pop = PopupView:createTextPopup(str, startToBuyCell)
    self:addChild(pop)
  end  
end 

function BagView:showPropsList()
  local viewOffsetX = 0
  local preViewOffsetX = 0

  self._isDragging = false
  CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("img/bag/bag.plist") --fixed bug1715

  local function scrollViewDidScroll(view)
    if self._isDragging ~= view:isDragging() then 
      self._isDragging = view:isDragging()

      if self._isDragging == true then 
        preViewOffsetX = view:getContentOffset().x
      else
        local offset_x = view:getContentOffset().x
        --local idx = math.floor(-offset_x/self.cellWidth + 0.5)
        local idx = self.curPage - 1

        local gap = preViewOffsetX - offset_x
        if math.abs(gap) > 15 then
           if gap < 0 then
              idx =  idx - 1
           elseif gap > 0 then
              idx = idx + 1
           end
        end

        if idx < 0 then 
          idx = 0
        end 
        if idx >= self.totalCells then
          idx = self.totalCells - 1
        end

        local destPosX = -idx*self.cellWidth

        local function moveEnd()
          self:setPageIndexByOffset(destPosX)
        end
        local moveto = CCMoveTo:create(0.2, ccp(destPosX, view:getContainer():getPositionY()))
        local easeOut = CCEaseExponentialOut:create(moveto)
        local seq = CCSequence:createWithTwoActions(easeOut, CCCallFunc:create(moveEnd))
        if self.tableView ~= nil then
          self.tableView:getContainer():runAction(seq)
        end
      end
    end
  end
  
  -- return current highlight item's index and center position
  local function getPropsIndexAndPos(cellIdx, touchPoint, viewOffsetX)
    --convert to relative position in current page
    local pos_x = touchPoint.x - viewOffsetX - cellIdx*self.cellWidth
    local pos_y = touchPoint.y
    
    local itemWidth = self.cellWidth/self.propsCol
    local itemHeight = self.cellHeight/self.propsRow

    --row and col for current item, and the index of row is from top to bottom 
    local col = math.floor(pos_x/itemWidth)
    local row = self.propsRow - math.floor(pos_y/itemHeight) - 1

    --the index of focus props in propsArray
    local propsIdx = cellIdx*(self.propsRow*self.propsCol) + row*self.propsCol + col + 1

    --current item' center point 
    local pos = ccp(col*itemWidth, (self.propsRow-row-1)*itemHeight)
    -- echo("index=", propsIdx, pos.x, pos.y, row, col)
    return propsIdx, pos
  end

  local function tableCellTouched(tableview,cell)
    local cellIndex = cell:getIdx()
    local touchPos = tolua.cast(self.node_listContainer:convertToNodeSpace(ccp(self.touch_x, self.touch_y)), "CCPoint")
    local offsetX = tableview:getContentOffset().x
    local itemIdx, itemPos = getPropsIndexAndPos(cellIndex, touchPos, offsetX)
    local ownCellsNum = GameData:Instance():getCurrentPlayer():getMaxItemBagCount()
    local bagCountLimit = GameData:Instance():getCurrentPlayer():getItemCountLimit()

    if self:getViewIndex() == 1 then --props view
      if itemIdx <= bagCountLimit then 
        if itemIdx <= ownCellsNum and itemIdx <= table.getn(self.listData) then
          self.highlightItem = itemIdx
          self:setHighlightProps()

          _executeNewBird()
        else 
          self:checkBuyCells(itemIdx)
        end 
      end 
    else 
      if itemIdx <= table.getn(self.listData) then
        self.highlightItem = itemIdx
        self:setHighlightProps()
      end 
    end  
  end
  
  local function cellSizeForTable(tableview,idx)
    return self.cellHeight,self.cellWidth
  end
  
  local function tableCellAtIndex(tableview, idx)
    --echo("cell index= ", idx)

    local maxCountPerPage = self.propsRow*self.propsCol
    local curPageItemsNum = 0
    if self.listData ~= nil then 
      curPageItemsNum = table.getn(self.listData)
      if idx > 0 then 
        curPageItemsNum = curPageItemsNum - idx * maxCountPerPage
      end
      curPageItemsNum = math.min(maxCountPerPage, curPageItemsNum)
    end
    echo("tableCellAtIndex: cellIdx, curPageItemsNum=", idx, curPageItemsNum)

    local itemWidth = self.cellWidth/self.propsCol
    local itemHeight = self.cellHeight/self.propsRow
    local bgSize = 95
    local cell = tableview:dequeueCell()
    if nil == cell then
      cell = CCTableViewCell:new()
    else 
      cell:removeAllChildrenWithCleanup(true)
    end

    local regNewGuideForExpCard = false 
    --show items
    local node = CCNode:create()
    local maxbagCount = GameData:Instance():getCurrentPlayer():getMaxItemBagCount()
    local package = GameData:Instance():getCurrentPackage()
    for i=1, maxCountPerPage do
      local sprite = nil
      local sprite_lock = nil 
      local sprite_combinable = nil 

      local arrIdx = maxCountPerPage*idx + i
      --props image
      if i <= curPageItemsNum then 
        local item = self.listData[arrIdx] 
        sprite = package:getItemSprite(nil, 6, item:getConfigId(), item:getCount())

        local itemType = item:getItemType()   
        if itemType == iType_CardChip or itemType == iType_EquipChip then
          if item:getChipCanCombined() == true then 
            sprite_combinable = CCSprite:createWithSpriteFrameName("combinable.png")
          end
        end

        --注册新手引导--体力药水/Q卡好礼宝箱
        if idx == 0 then 
          if regNewGuideForExpCard == false and itemType == iType_ExpCard then 
            _registNewBirdComponent(111024, sprite)
            regNewGuideForExpCard = true 
          end 
        end 
        
        if itemType == iType_ItemBoxQKa then 
          _registNewBirdComponent(111025, sprite)

          --转圈动画
          if GameData:Instance():getCurrentPlayer():getLevel() >= item:getRequireLevel() then 
            local anim,offsetX,offsetY,duration = _res(5020152)
            if anim ~= nil then
              anim:setPosition(ccp(0, 0))
              sprite:addChild(anim)
              anim:getAnimation():play("default")
            end
          end 
        end 

      else 
        sprite = CCSprite:createWithSpriteFrameName("kongbai_kuang.png")
      end 

      --show lock img
      if arrIdx > maxbagCount and self:getViewIndex() == 1 then 
        sprite_lock = CCSprite:createWithSpriteFrameName("bag-suo.png")
      end

      local x = (i-1)%self.propsCol*itemWidth+itemWidth/2
      local y = (self.propsRow-1-math.floor((i-1)/self.propsCol))*itemHeight+itemHeight/2
      if sprite ~= nil then 
        sprite:setPosition(ccp(x, y))
        node:addChild(sprite)

        if sprite_combinable ~= nil then
          sprite_combinable:setAnchorPoint(ccp(0,0))
          sprite_combinable:setPosition(ccp(x-bgSize/2, y-bgSize/2))
          node:addChild(sprite_combinable)
        end 
      end

      if sprite_lock ~= nil then 
        sprite_lock:setPosition(ccp(x, y))
        node:addChild(sprite_lock)        
      end
    end 

    --show highlight box
    if curPageItemsNum >= 1 then 
      if self.highlightItem >= 1 then --and self.highlightItem < curPageItemsNum then 
        local cellIndex = math.floor((self.highlightItem-1)/maxCountPerPage)
        if cellIndex == idx then 
        local index =  self.highlightItem 
        if idx > 0 then 
          index = index - idx * maxCountPerPage
        end

        local x = (index-1)%self.propsCol*itemWidth+itemWidth/2
        local y = (self.propsRow-1-math.floor((index-1)/self.propsCol))*itemHeight+itemHeight/2
        local highlightBox = CCSprite:createWithSpriteFrameName("highlight-box.png")
        highlightBox:setTag(128)
        highlightBox:setPosition(ccp(x,y))
        node:addChild(highlightBox)
        end
      end
    end
    node:setTag(100)
    cell:addChild(node)

    return cell
  end
  
  local function numberOfCellsInTableView(tableview)
    return self.totalCells
  end


  self:registerTouchEvent()
  self.node_listContainer:removeAllChildrenWithCleanup(true)

  self.tableView = CCTableView:create(self.node_listContainer:getContentSize())
  self.tableView:setDirection(kCCScrollViewDirectionHorizontal)
  self.node_listContainer:addChild(self.tableView)
  self.tableView:setBounceable(false) --disable deaccelerateScrolling

  self.tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  --tableView:registerScriptHandler(scrollViewDidZoom,CCTableView.kTableViewZoom)
  self.tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  self.tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  self.tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  self.tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  self.tableView:reloadData()

  --default highlight index_1
  self:setHighlightProps()
end

function BagView:resortChip()
  GameData:Instance():getCurrentPackage():sortProsForChip(self.listData)
end 

function BagView:updateCell(cellIdx, permitHighlight, needUpdateData)
  if needUpdateData then 
    self:updateListData(self:getViewIndex())
  end 
  
  if cellIdx == nil then 
    cellIdx = math.floor((self.highlightItem - 1)/(self.propsRow*self.propsCol))
  end 
  self.tableView:updateCellAtIndex(cellIdx)
  if permitHighlight == nil or permitHighlight == false then 
    self:setHighlightProps()
  end 
end 

function BagView:updateList()
  echo(" == updateList ==")
  self:updateListData(self:getViewIndex())
  self:showPropsList()
end 

function BagView:highlightPropsByConfigId(configId)
  local found = false 

  for k, v in pairs(self.listData) do 
    if v:getConfigId() == configId then 
      self.highlightItem = k 
      found = true 
      break 
    end 
  end 
  echo("=== highlightPropsByConfigId:", configId, found)
  if found then 
    self:setHighlightProps()
  end 
end 
