require("view.expedition.component.RankingListItem")
require("view.expedition.component.KeepWinListItem")
ExpeditionRankListPopView = class("ExpeditionRankListPopView",BaseView)
function ExpeditionRankListPopView:ctor()
  self:setTouchEnabled(true)
  self:addTouchEventListener(function() return true end,false,-128,true)
  self.expedition = GameData:Instance():getExpeditionInstance()
  self:setNodeEventEnabled(true)
end

function ExpeditionRankListPopView:onEnter()
  --color layer
  local layerColor = CCLayerColor:create(ccc4(0,0,0,215), display.width, display.height)
  self:addChild(layerColor)
  
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("btnKeepWin","CCMenuItemImage")
  pkg:addProperty("btnMaxRank","CCMenuItemImage")
  pkg:addProperty("btnPopRank","CCMenuItemImage")
  pkg:addProperty("list_arrow","CCSprite")
  pkg:addProperty("nodeListContainer","CCNode")
   pkg:addProperty("nodeButtonContent","CCNode")
  pkg:addProperty("nodeRankIconContainer","CCNode")
  pkg:addProperty("labelCurrentRank","CCLabelTTF")
  pkg:addProperty("labelCurrentRankArea","CCLabelTTF")
  pkg:addFunc("onClickKeepWinHandler",ExpeditionRankListPopView.onClickKeepWinHandler)
  pkg:addFunc("onClickPopRankHandler",ExpeditionRankListPopView.onClickPopRankHandler)
  pkg:addFunc("onClickMaxRankHandler",ExpeditionRankListPopView.onClickMaxRankHandler)
  
  local layer,owner = ccbHelper.load("ExpeditionRankListPopView.ccbi","ExpeditionRankListPopView","CCLayer",pkg)
  self:addChild(layer)
  
  local pos = ccp(self.list_arrow:getPositionX(),self.list_arrow:getPositionY())
  local anim = CCSequence:createWithTwoActions(CCMoveTo:create(0.2, ccp(pos.x,pos.y + 8)), CCMoveTo:create(0.4, pos))
  self.list_arrow:runAction(CCRepeatForever:create(anim))
  
  local closeBtn = UIHelper.ccMenuWithSprite(display.newSprite("#expedition_close_nor.png"),
          display.newSprite("#expedition_close_sel.png"),
          display.newSprite("#expedition_close_sel.png"),
          function()
            self:removeFromParentAndCleanup(true)
          end)
  self:addChild(closeBtn)
  closeBtn:setPositionX(display.cx)
  closeBtn:setPositionY(display.cy - 380)
  
  self._listType = 1
  self.nodeButtonContent:setVisible(false)
  self.btnKeepWin:setEnabled(false)
  self:buildTableView(self.expedition:getKeepWinRanks())
  
  GameData:Instance():getCurrentScene():setTopVisible(false)
  GameData:Instance():getCurrentScene():setBottomVisible(false)
end

function ExpeditionRankListPopView:onExit()
  GameData:Instance():getCurrentScene():setTopVisible(true)
  GameData:Instance():getCurrentScene():setBottomVisible(true)
  if self:getDelegate() ~= nil and self:getDelegate()._cardHead ~= nil then
    self:getDelegate()._cardHead:setVisible(true)
  end
end

function ExpeditionRankListPopView:onClickKeepWinHandler()
  self.btnKeepWin:unselected()
  self.btnMaxRank:unselected()
  self.btnPopRank:unselected()
  self.btnKeepWin:setEnabled(false)
  self.btnMaxRank:setEnabled(true)
  self.btnPopRank:setEnabled(true)
  self._isKeekWinList = true
  self._listType = 1
  self:buildTableView(self.expedition:getKeepWinRanks())
end

function ExpeditionRankListPopView:onClickPopRankHandler()
  self.btnKeepWin:unselected()
  self.btnMaxRank:unselected()
  self.btnPopRank:unselected()
  self.btnKeepWin:setEnabled(true)
  self.btnMaxRank:setEnabled(true)
  self.btnPopRank:setEnabled(false)
  self._isKeekWinList = false
  
  
  
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
  
  self._listType = 3
  
  self:buildTableView(self.expedition:getPopularityRanks())
end

function ExpeditionRankListPopView:onClickMaxRankHandler()
  self.btnKeepWin:unselected()
  self.btnMaxRank:unselected()
  self.btnPopRank:unselected()
  self.btnKeepWin:setEnabled(true)
  self.btnMaxRank:setEnabled(false)
  self.btnPopRank:setEnabled(true)
  self._listType = 2
  self:buildTableView(self.expedition:getHeroRanks())
end

function ExpeditionRankListPopView:buildTableView(lists)
  
  self._listArray = lists
  
  if self.tableView ~= nil then
     if self._listType == 3 then
        local mSize = self.nodeListContainer:getContentSize()
        self.tableView:setViewSize(CCSizeMake(mSize.width,mSize.height-self.nodeButtonContent:getContentSize().height))
        self.nodeButtonContent:setVisible(true)
     else
        local mSize = self.nodeListContainer:getContentSize()
        self.tableView:setViewSize(mSize)
        self.nodeButtonContent:setVisible(false)
     end
     
     self.tableView:reloadData()
     return
  end
  
  
  local function scrollViewDidScroll(view)
    --print("scrollViewDidScroll")
  end
  
  local function scrollViewDidZoom(view)
      print("scrollViewDidZoom")
  end
  
  local function tableCellTouched(table,cell)

   end
  
   local function cellSizeForTable(table,idx) 
      return 110,570
   end
  
   local function tableCellAtIndex(tableview, idx)
      local cell = tableview:dequeueCell()
      if nil == cell then
        cell = CCTableViewCell:new()  
      else
        cell:removeAllChildrenWithCleanup(true)
      end

      local item = nil 
       if self._listType == 1 then
          item = KeepWinListItem.new(self._listArray[idx+1],idx+1)
       else
          item = RankingListItem.new(self._listArray[idx+1],idx+1)
       end
      --item:setRank(idx+1)
      item:setDelegate(self:getDelegate():getDelegate())
      cell:setIdx(idx)
      if item ~= nil then
        cell:addChild(item)
      end
      
      local cellNum = math.ceil(tableview:getViewSize().height/110)
      UIHelper.showScrollListView({object=item, totalCount=cellNum, index =idx})
      
      return cell
  end
  
  local function numberOfCellsInTableView(val)
     return #self._listArray
  end
  
   local mSize = self.nodeListContainer:getContentSize()
--  local mSize = CCSizeMake(self.nodeListContainer:getContentSize().width,
--  self:getDelegate():getDelegate():getScene():getMiddleContentSize().height-self:getDelegate():getEaveContentSize().height-120-100)

  local tableView = CCTableView:create(mSize)
  tableView:setDirection(kCCScrollViewDirectionVertical)
  tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  tableView:setClippingToBounds(true)
  --tableView:setBounceable(false)
  self.nodeListContainer:addChild(tableView)
  --registerScriptHandler functions must be before the reloadData function
  tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  tableView:registerScriptHandler(scrollViewDidZoom,CCTableView.kTableViewZoom)
  --tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)  
  tableView:reloadData()
  tableView:setTouchPriority(-128)
  self.tableView = tableView
end


return ExpeditionRankListPopView