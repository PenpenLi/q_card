
require("view.BaseView")


HomeActFirstCharge = class("HomeActFirstCharge", BaseView)

function HomeActFirstCharge:ctor()
  HomeActFirstCharge.super.ctor(self)

  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("onCharge",HomeActFirstCharge.onCharge)
  pkg:addProperty("node_list","CCNode")
  pkg:addProperty("sprite_bg","CCSprite")
  pkg:addProperty("bn_charge","CCControlButton")

  local layer,owner = ccbHelper.load("HomeActFirstCharge.ccbi","HomeActFirstChargeCCB","CCLayer",pkg)
  self:addChild(layer)
end

function HomeActFirstCharge:onEnter()
  self.priority = -200

  self.bn_charge:setTouchPriority(self.priority)

  --reg touch event
  self:addTouchEventListener(function(event, x, y)
                                if event == "began" then
                                  self.preTouchFlag = self:checkTouchOutsideView(x, y)
                                  return true
                                elseif event == "ended" then
                                  local curFlag = self:checkTouchOutsideView(x, y)
                                  if self.preTouchFlag == true and curFlag == true then
                                    echo(" touch out of region: close popup") 
                                    self:closeCallback()
                                  end 
                                end
                            end,
              false, self.priority+1, true)
  self:setTouchEnabled(true)

  self:showBonusList()
end 

function HomeActFirstCharge:onExit()

end 

function HomeActFirstCharge:checkTouchOutsideView(x, y)
  local size = self.sprite_bg:getContentSize()
  local pos = self.sprite_bg:convertToNodeSpace(ccp(x, y))
  if pos.x < 0 or pos.x > size.width or pos.y < 0 or pos.y > size.height then 
    return true 
  end

  return false  
end 

function HomeActFirstCharge:closeCallback()
  self:removeFromParentAndCleanup(true)
end 

function HomeActFirstCharge:onCharge()
  self:closeCallback()

  local controller = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
  controller:enter(ShopCurViewType.PAY)  
end 

function HomeActFirstCharge:showBonusList()

  local itemArray = AllConfig.drop[103040100].drop_data


  local function tableCellTouched(tableview,cell)
    local x = cell:getIdx()*self.cellWidth + tableview:getContentOffset().x + self.cellWidth/2
    local index = cell:getIdx() + 1
    local item = itemArray[index].array
    local configId = item[2]
    TipsInfo:showTip(self.node_list, configId, nil, ccp(x, self.cellHeight+10))
  end

  local function cellSizeForTable(tableview,idx)
    return self.cellHeight,self.cellWidth
  end
  
  local function numberOfCellsInTableView(tableview)
    return self.totalCells
  end

  local function tableCellAtIndex(tableview, idx)
    echo("cell index= ", idx)

    local cell = tableview:dequeueCell()
    if child == nil then 
      cell = CCTableViewCell:new()
    else 
      cell:removeAllChildrenWithCleanup(true)
    end
    
    local itemInfo = itemArray[idx+1].array
    local node = GameData:Instance():getCurrentPackage():getItemSprite(nil, itemInfo[1], itemInfo[2], itemInfo[3])
    if node ~= nil then 
      local pos = ccp(self.cellWidth/2, self.cellHeight/2)
      node:setPosition(pos)
      cell:addChild(node)
    end

    return cell
  end
  
  self.node_list:removeAllChildrenWithCleanup(true)

  local size = self.node_list:getContentSize()
  self.cellWidth = size.width/4
  self.cellHeight = size.height
  
  self.totalCells = #itemArray


  local tbView = CCTableView:create(size)
  tbView:setDirection(kCCScrollViewDirectionHorizontal)
  tbView:setTouchPriority(self.priority-1) --for tip menu
  self.node_list:addChild(tbView)

  tbView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tbView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tbView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tbView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  tbView:reloadData()
end 