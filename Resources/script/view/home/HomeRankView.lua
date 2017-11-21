
require("view.BaseView")
require("view.home.HomeRankListItem")
require("view.component.TabControlEx")

HomeRankView = class("HomeRankView", BaseView)

function HomeRankView:ctor(rankType)
  HomeRankView.super.ctor(self)

  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("closeCallback",HomeRankView.closeCallback)
  pkg:addProperty("node_TabMenu","CCNode") 
  pkg:addProperty("node_list","CCNode") 
  pkg:addProperty("sprite9_bg","CCScale9Sprite")
  pkg:addProperty("layer_mask","CCLayerColor")
  pkg:addProperty("bn_close","CCControlButton")

  local layer,owner = ccbHelper.load("HomeRankView.ccbi","HomeRankViewCCB","CCLayer",pkg)
  self:addChild(layer)
  
  self.priority = -128
  self.rankType = rankType or RankEnum.Level 

  --init tab menu 
  local menuArray = {
      {"#bn_rank_level0.png","#bn_rank_level1.png"},
      {"#bn_rank_jingji0.png","#bn_rank_jingji1.png"}    
    }

  self.tabCtrl = TabControlEx.new(CCSizeMake(552, 74), nil, self.priority)
  self.tabCtrl:setDelegate(self)
  self.node_TabMenu:addChild(self.tabCtrl)

  self.tabCtrl:setMenuArray(menuArray)
  self.tabCtrl:setItemSelectedByIndex(self.rankType)

  --req data 
  local data = PbRegist.pack(PbMsgId.RankInformationQueryC2S)
  net.sendMessage(PbMsgId.RankInformationQueryC2S,data)
end

function HomeRankView:onEnter()
  
  self.bn_close:setTouchPriority(self.priority)

  net.registMsgCallback(PbMsgId.RankInformationS2C, self, HomeRankView.updateList)

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

  --show rank list 
  self:showViewByType(self.rankType)
end 

function HomeRankView:onExit()
  net.unregistAllCallback(self)
end 

function HomeRankView:tabControlOnClick(idx)
  _playSnd(SFX_CLICK) 

  local result = true
  if idx == 0 then
    self.rankType = RankEnum.Level 

  elseif idx == 1 then 
    self.rankType = RankEnum.Match
  end

  if result then 
    self:showViewByType(self.rankType)
  end 

  return result
end 

function HomeRankView:showViewByType(rankType)
  self.ranksArray = GameData:Instance():getPlayersRank(rankType)
  self:showRanksList(self.ranksArray)   
end 

function HomeRankView:updateList()
  local function updateTbView()
    echo("=== update list")
    self.ranksArray = GameData:Instance():getPlayersRank(self.rankType)
    self:showRanksList(self.ranksArray)
  end 

  self:performWithDelay(updateTbView, 0.5)
end 

function HomeRankView:checkTouchOutsideView(x, y)
  local size = self.sprite9_bg:getContentSize()
  local pos = self.sprite9_bg:convertToNodeSpace(ccp(x, y))
  if pos.x < 0 or pos.x > size.width or pos.y < 0 or pos.y > size.height then 
    return true 
  end

  return false  
end 

function HomeRankView:closeCallback()
  self:removeFromParentAndCleanup(true)
end 

function HomeRankView:showRanksList(itemArray)

  -- local function tableCellTouched(tbView,cell)
  -- end
  
  local function tableCellAtIndex(tbView, idx)
    local item = nil
    local cell = tbView:dequeueCell()
    if cell == nil then
      cell = CCTableViewCell:new()
      item = HomeRankListItem.new()
      item:setRankType(self.rankType)
      item:setData(itemArray[idx+1])
      item:setTag(100)
      cell:addChild(item)
    else 
      item = cell:getChildByTag(100)
      if item ~= nil then
        item:setData(itemArray[idx+1])
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

  self.totalCells = #itemArray 
  self.cellWidth = 557
  self.cellHeight = 109

  echo("remove old tableview")
  self.node_list:removeAllChildrenWithCleanup(true)
  local size = self.node_list:getContentSize()

  --create tableview
  self.tableView = CCTableView:create(size)
  self.tableView:setDirection(kCCScrollViewDirectionVertical)
  self.tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  self.tableView:setTouchPriority(self.priority-1)
  self.node_list:addChild(self.tableView)

  --self.tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  -- self.tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  self.tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  self.tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  self.tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  self.tableView:reloadData()
end 
