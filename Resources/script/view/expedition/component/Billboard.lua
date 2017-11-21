require("view.expedition.component.RankingListItem")
Billboard = class("Billboard",BaseView)

function Billboard:ctor()
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("bottomSize","CCScale9Sprite")
  pkg:addProperty("nodeButtonContent","CCNode")
  pkg:addProperty("nodeRankIconContainer","CCNode")
  pkg:addProperty("labelCurrentRank","CCLabelTTF")
  pkg:addProperty("labelCurrentRankArea","CCLabelTTF")
  pkg:addProperty("btnCurrentRank","CCMenuItemImage")
  pkg:addProperty("btnBestRank","CCMenuItemImage")
  pkg:addFunc("onGetBestRankHandler",Billboard.onGetBestRankHandler)
  pkg:addFunc("onCurrentRankHandler",Billboard.onCurrentRankHandler)
  
  local layer,owner = ccbHelper.load("ExpeditionBillboard.ccbi","BillBoardCCB","CCLayer",pkg)
  self:addChild(layer)
  self._listArray = {}
  self._lastSelectedIdx = 0
  
  
  local awardRank = 1
  
  if GameData:Instance():getExpeditionInstance():getSelfPvpBaseData() ~= nil then
     awardRank =  GameData:Instance():getExpeditionInstance():getSelfPvpBaseData():getRank() --currentRank
  end
  
  self.nodeRankIconContainer:removeAllChildrenWithCleanup(true)
  local iconSpr = _res(AllConfig.rank[awardRank].rank_pic)
  if iconSpr ~= nil then
     iconSpr:setScale(0.5)
     self.nodeRankIconContainer:addChild(iconSpr)
  end
  
  local iconNum = _res(AllConfig.rank[awardRank].rank_number)
  if iconNum ~= nil then
     --iconNum:setScale(0.8)
     self.nodeRankIconContainer:addChild(iconNum)
  end
  
  self.labelCurrentRank:setString(_tr(AllConfig.rank[awardRank].sub_rank_name..""))
  self.labelCurrentRankArea:setString(_tr("("..AllConfig.rank[awardRank].min_point.."-"..AllConfig.rank[awardRank].max_point..")"))
  self.btnCurrentRank:setVisible(false)
end

function Billboard:onCurrentRankHandler()
   local awardRank = 1
   if GameData:Instance():getExpeditionInstance():getSelfPvpBaseData() ~= nil then
     awardRank =  GameData:Instance():getExpeditionInstance():getSelfPvpBaseData():getRank() --currentRank
   end
   self.nodeRankIconContainer:removeAllChildrenWithCleanup(true)
   local iconSpr = _res(AllConfig.rank[awardRank].rank_pic)
   if iconSpr ~= nil then
      iconSpr:setScale(0.5)
      self.nodeRankIconContainer:addChild(iconSpr)
   end
  
  local iconNum = _res(AllConfig.rank[awardRank].rank_number)
  if iconNum ~= nil then
     --iconNum:setScale(0.8)
     self.nodeRankIconContainer:addChild(iconNum)
  end
  
   self.labelCurrentRank:setString(_tr(AllConfig.rank[awardRank].sub_rank_name..""))
   self.labelCurrentRankArea:setString(_tr("("..AllConfig.rank[awardRank].min_point.."-"..AllConfig.rank[awardRank].max_point..")"))
   self.btnCurrentRank:setVisible(false)
   self.btnBestRank:setVisible(true)
   self:setBillBoards(GameData:Instance():getExpeditionInstance():getPopularityRanks())
end

function Billboard:onGetBestRankHandler()
   print(#GameData:Instance():getExpeditionInstance():getHeroRanks())
   local awardRank = #AllConfig.rank
    self.nodeRankIconContainer:removeAllChildrenWithCleanup(true)
   local iconSpr = _res(AllConfig.rank[awardRank].rank_pic)
   if iconSpr ~= nil then
      iconSpr:setScale(0.5)
      self.nodeRankIconContainer:addChild(iconSpr)
   end
  
   local iconNum = _res(AllConfig.rank[awardRank].rank_number)
   if iconNum ~= nil then
     --iconNum:setScale(0.8)
     self.nodeRankIconContainer:addChild(iconNum)
   end
   self.labelCurrentRank:setString(_tr(AllConfig.rank[awardRank].sub_rank_name..""))
   self.labelCurrentRankArea:setString(_tr("("..AllConfig.rank[awardRank].min_point.."-"..AllConfig.rank[awardRank].max_point..")"))
   self.btnCurrentRank:setVisible(true)
   self.btnBestRank:setVisible(false)
   self:setBillBoards(GameData:Instance():getExpeditionInstance():getHeroRanks())
end

function Billboard:setBillBoards(billBoards)
     if billBoards ~= nil then
        self._listArray = billBoards
     else
        self._listArray = {}
     end
     
     self:getDelegate():setEmptyImgVisible(#self._listArray < 1)

--     if self.tableView ~= nil then
--        self.tableView:unregisterAllScriptHandler()
--     end
     self.nodeListContainer = self:getDelegate():getListContainer()
     --self.nodeListContainer:removeAllChildrenWithCleanup(true)
     
     if self.tableView == nil then
        self:buildTableView()
     end
     self.tableView:reloadData()
end

function Billboard:buildTableView()
  
  --self.tableView = nil
  
  local function scrollViewDidScroll(view)
    --print("scrollViewDidScroll")
  end
  
  local function scrollViewDidZoom(view)
      print("scrollViewDidZoom")
  end
  
  local function tableCellTouched(table,cell)
      print("cell touched at index: " .. cell:getIdx())

      local lastcell = table:cellAtIndex(self._lastSelectedIdx)
      if nil ~= lastcell then
        
      end
          
      self._lastSelectedIdx = cell:getIdx()
   end
  
   local function cellSizeForTable(table,idx) 
      return ConfigListCellHeight,ConfigListCellWidth
   end
  
   local function tableCellAtIndex(tableview, idx)
      local cell = tableview:dequeueCell()
      if nil == cell then
        cell = CCTableViewCell:new()  
      else
        cell:removeAllChildrenWithCleanup(true)
      end
      
      local item = RankingListItem.new(self._listArray[#self._listArray-idx])
      --:setRank(table.getn(self._listArray) - idx)
      item:setRankLabel(self._listArray[#self._listArray-idx]:getScore().."")
      item:setMaxKeepWinLabel(self._listArray[#self._listArray-idx]:getMaxKeepWin().."")
      --the templete select before make sure btn
      if idx == self._lastSelectedIdx then
        item:setSelected(true)
      else 
        item:setSelected(false)
      end
      
      item.btnChallenge:setVisible(false)
      
      cell:setIdx(idx)
      cell:addChild(item)
      
      local cellNum = math.ceil(tableview:getViewSize().height/ConfigListCellHeight)
      UIHelper.showScrollListView({object=item, totalCount=cellNum, index =idx})
      
      return cell
  end
  
   local function numberOfCellsInTableView(val)
     local length = table.getn(self._listArray)
     return length
  end
  
  local mSize = CCSizeMake(display.width,
 self:getDelegate():getCanvasContentSize().height - self.nodeButtonContent:getContentSize().height)
  
  self.nodeListContainer:setContentSize(mSize)
  self.nodeButtonContent:setPositionY(self.nodeListContainer:getPositionY() + self.nodeListContainer:getContentSize().height)
  
  local tableView = CCTableView:create(mSize)
  tableView:setDirection(kCCScrollViewDirectionVertical)
  tableView:setClippingToBounds(true)
  tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  --tableView:setBounceable(false)
  self.nodeListContainer:addChild(tableView)
  --registerScriptHandler functions must be before the reloadData function
  tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  tableView:registerScriptHandler(scrollViewDidZoom,CCTableView.kTableViewZoom)
  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  self.tableView = tableView
end

return Billboard