
require("view.BaseView")
require("view.home.HomeActListItem")

HomeActView = class("HomeActView", BaseView)

function HomeActView:ctor()
  HomeActView.super.ctor(self)

  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("closeCallback",HomeActView.closeCallback)
  pkg:addFunc("ruleCallback",HomeActView.ruleCallback)
  pkg:addProperty("node_actList","CCNode") 
  pkg:addProperty("node_info","CCNode")
  pkg:addProperty("node_bonus","CCNode")
  pkg:addProperty("sprite_bg","CCSprite")
  pkg:addProperty("label_title","CCLabelTTF") 
  pkg:addProperty("bn_close","CCControlButton")
  pkg:addProperty("bn_rule","CCControlButton")

  local layer,owner = ccbHelper.load("HomeActView.ccbi","HomeActViewCCB","CCLayer",pkg)
  self:addChild(layer)
end

function HomeActView:onEnter()
  self.priority = -200
  self.isRuleVisible = false 

  self.bn_close:setTouchPriority(self.priority)
  self.bn_rule:setTouchPriority(self.priority)

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

  --show act list 
  self.highlightIndex = 0
  self.actListArray = Activity:instance():getHomeActData()
  self:showActsList(self.actListArray)
end 

function HomeActView:onExit()

end 

function HomeActView:checkTouchOutsideView(x, y)
  local size = self.sprite_bg:getContentSize()
  local pos = self.sprite_bg:convertToNodeSpace(ccp(x, y))
  if pos.x < 0 or pos.x > size.width or pos.y < 0 or pos.y > size.height then 
    return true 
  end

  return false  
end 

function HomeActView:closeCallback()
  self:removeFromParentAndCleanup(true)
end 

function HomeActView:ruleCallback()
  if self.bn_rule:isVisible() == true then 
    self.isRuleVisible = not self.isRuleVisible 
    if self.strRule then 
      self.strRule:setVisible(self.isRuleVisible)
    end 
  end 
end 


function HomeActView:showActsList(itemArray)


  local function tableCellTouched(tbView,cell)
    local curIdx = cell:getIdx()
    if self.highlightIndex == curIdx then 
      return 
    end 
    
    --unhighlight pre index     
    local preCell = tbView:cellAtIndex(self.highlightIndex)
    if preCell ~= nil then 
      local preItem = preCell:getChildByTag(100)
      if preItem ~= nil then 
        preItem:setSelected(false)
      end 
    end 
    --highlight current item 
    local item = cell:getChildByTag(100)
    if item ~= nil then 
      item:setSelected(true)
      self:highlightActByIdx(curIdx)
    end 
    self.highlightIndex = curIdx
  end

  local function tableCellAtIndex(tbView, idx)
    local item = nil
    local cell = tbView:dequeueCell()
    if cell == nil then
      cell = CCTableViewCell:new()
      item = HomeActListItem.new()
      item:setIdx(idx)
      item:setData(itemArray[idx+1])
      item:setSelected(self.highlightIndex==idx)
      item:setTag(100)
      cell:addChild(item)
    else 
      item = cell:getChildByTag(100)
      if item ~= nil then
        item:setIdx(idx)
        item:setData(itemArray[idx+1])
        item:setSelected(self.highlightIndex==idx)
        item:updateInfos()       
      end
    end

    return cell
  end

  local function cellSizeForTable(tbView,idx)
    return self.cellHeight, self.cellWidth
  end 

  local function numberOfCellsInTableView(tbView)
    return self.totalCells
  end

  local size = self.node_actList:getContentSize()
  self.totalCells = #itemArray 
  self.cellWidth = size.width 
  self.cellHeight = 88

  echo("remove old tableview")
  self.node_actList:removeAllChildrenWithCleanup(true)

  --create tableview
  local tableView = CCTableView:create(size)
  tableView:setDirection(kCCScrollViewDirectionVertical)
  tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  tableView:setTouchPriority(self.priority-1)
  self.node_actList:addChild(tableView)

  --tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)   
  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  tableView:reloadData()

  --highlight 
  self:highlightActByIdx(self.highlightIndex)
end 


function HomeActView:highlightActByIdx(idx)
  self:showActInfos(self.actListArray[idx+1])
end 

function HomeActView:showActInfos(actItem) 
  if actItem == nil then 
    return 
  end 

  self.bn_rule:setVisible(actItem.showrule > 0)

  --title 
  self.label_title:setString(actItem.activity_name)

  --desc & rule 
  -- self:updateInfoString(actItem.desc, actItem.rule, false)
  self.node_info:removeAllChildrenWithCleanup(true)

  local infoSizeMax = self.node_info:getContentSize()
  local desc = RichText.new(actItem.desc, infoSizeMax.width, 0, "Courier-Bold", 22)
  local pos_y = infoSizeMax.height - desc:getContentSize().height 
  desc:setPosition(ccp(0, pos_y))
  self.node_info:addChild(desc)

  pos_y = pos_y - 40 
  self.strRule = RichText.new(actItem.rule, infoSizeMax.width, 0, "Courier-Bold", 22)
  local ruleSize = self.strRule:getTextSize()
  if pos_y - ruleSize.height > 0 then 
    self.strRule:setPosition(ccp(0, pos_y-ruleSize.height))
    self.strRule:setVisible(actItem.showrule==0) --default
    self.node_info:addChild(self.strRule)  
  else 

    local viewSize = CCSizeMake(infoSizeMax.width, pos_y)
    local scrollView = CCScrollView:create()
    scrollView:setContentSize(ruleSize)
    scrollView:setViewSize(viewSize)
    scrollView:setDirection(kCCScrollViewDirectionVertical)
    scrollView:setClippingToBounds(true)
    scrollView:setBounceable(true)
    scrollView:setTouchPriority(self.priority-1)
    self.strRule:setPositionY(viewSize.height-ruleSize.height)
    scrollView:setContainer(self.strRule)
    self.node_info:addChild(scrollView)
  end 







end 
