require("view.pvp_rank_match.PvpRankMatchReportListItem")
PvpRankMatchReportView = class("PvpRankMatchReportView",BaseView)
function PvpRankMatchReportView:ctor()
  PvpRankMatchReportView.super.ctor(self)
  self:setNodeEventEnabled(true)
  
   --color layer
  local layerColor = CCLayerColor:create(ccc4(0,0,0,168), display.width*2.0, display.height*2.0)
  self:addChild(layerColor)
  
  local popSize = CCSizeMake(615,800)
  
  local bg = display.newScale9Sprite("#rank_match_bg.png",display.cx,display.cy,popSize)
  self:addChild(bg)
  self._popupBg = bg
  
  local titleBg = display.newScale9Sprite("#rank_match_title_bg.png",0,0,CCSizeMake(popSize.width,67))
  self:addChild(titleBg)
  titleBg:setPosition(ccp(display.cx,display.cy + popSize.height/2 - titleBg:getContentSize().height/2 ))
  self._titleBg = titleBg
  
  local titleStr = display.newSprite("#rank_match_report.png")
  titleBg:addChild(titleStr)
  titleStr:setPosition(titleBg:getContentSize().width/2,titleBg:getContentSize().height/2)
  
--  local label = CCLabelBMFont:create(self._currentCount.."/"..self._maxCount, "client/widget/words/card_name/number_skillup.fnt")
--  titleBg:addChild(label)
--  label:setPosition(ccp(215,50))

  self:setTouchEnabled(true)
  self:addTouchEventListener(function() return true end,false,-128,true)
  
  local nor = display.newSprite("#rank_match_close.png")
  local sel = display.newSprite("#rank_match_close.png")
  local dis = display.newSprite("#rank_match_close.png")
  local closeBtn = UIHelper.ccMenuWithSprite(nor,sel,dis,
      function()
        PvpRankMatch:Instance():setReportListContentOffset(nil)
        self:removeFromParentAndCleanup(true)
      end)
  self:addChild(closeBtn)
  closeBtn:setPositionX(display.cx + popSize.width/2 - nor:getContentSize().width/2 + 10)
  closeBtn:setPositionY(display.cy + popSize.height/2 - nor:getContentSize().height/2 + 10)
  closeBtn:setTouchPriority(-128)
  
  self:setLists({})
end

function PvpRankMatchReportView:onEnter()
  self:buildList()
end

function PvpRankMatchReportView:onExit()
  
end

function PvpRankMatchReportView:buildList()
  if self.tableView ~= nil then
    return
  end

  local function scrollViewDidScroll(view)
    --print("scrollViewDidScroll")
  end
  
  local function scrollViewDidZoom(view)
      print("scrollViewDidZoom")
  end
  
  local function tableCellTouched(table,cell)
      print("cell touched at index: " .. cell:getIdx())
   end
  
   local function cellSizeForTable(tableview,idx) 
      return 109,556
   end
  
   local function tableCellAtIndex(tableView, idx)
      local cell = tableView:dequeueCell()
      if nil == cell then
        cell = CCTableViewCell:new()  
      else
        cell:removeAllChildrenWithCleanup(true)
      end
      
      local item = PvpRankMatchReportListItem.new()
      item:setTableView(tableView)
      item:setData(self._Lists[idx + 1])
      cell:setIdx(idx)
      cell:addChild(item)
      
      local cellNum = math.ceil(tableView:getViewSize().height/109)
      UIHelper.showScrollListView({object=item, totalCount=cellNum, index =idx})
      
      return cell
  end
  
  local function numberOfCellsInTableView(val)
     return #self._Lists
  end
  
  
  local mSize = CCSizeMake(self._popupBg:getContentSize().width,self._popupBg:getContentSize().height - self._titleBg:getContentSize().height - 15)
  local tableView = CCTableView:create(mSize)
  tableView:setDirection(kCCScrollViewDirectionVertical)
  --tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  tableView:setClippingToBounds(true)
  
  --tableView:setBounceable(false)
  self._popupBg:addChild(tableView)
  tableView:setPosition(32,15)
  --tableView:setPosition(-mSize.width/2,-mSize.height/2)
  --registerScriptHandler functions must be before the reloadData function
  --tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  tableView:registerScriptHandler(scrollViewDidZoom,CCTableView.kTableViewZoom)
  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)  
  tableView:reloadData()
  self.tableView = tableView
  
  self.tableView:setTouchPriority(-128)
end


------
--  Getter & Setter for
--      PvpRankMatchReportView._Lists 
-----
function PvpRankMatchReportView:setLists(Lists)
	self._Lists = Lists
	
	if self.tableView == nil then
	 self:buildList()
	else
	 self.tableView:reloadData()
	end
	
	local contentOffset = PvpRankMatch:Instance():getReportListContentOffset()
  if contentOffset ~= nil then
    self.tableView:setContentOffset(contentOffset)
  end
end

function PvpRankMatchReportView:getLists()
	return self._Lists
end


return PvpRankMatchReportView