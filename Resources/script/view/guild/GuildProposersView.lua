require("view.guild.GuildApplyPlayerItemView")
GuildProposersView = class("GuildProposersView",PopModule)
local priority = -256
function GuildProposersView:ctor()
  local size = CCSizeMake(615,790)
  GuildProposersView.super.ctor(self,size,priority,true)
end

function GuildProposersView:onEnter()
  GuildProposersView.super.onEnter(self)
  local tableView = self:buildList()
  self:getListContainer():addChild(tableView)
  tableView:reloadData()
  self:setTitleWithSprite(display.newSprite("#guild_ruhuishenqing.png"))
end

function GuildProposersView:buildList()
  local applyMembers = Guild:Instance():getSelfGuildBase():getApplyMembers()
  for key, member in pairs(applyMembers) do
  	
  end
  --print("#applyMembers:",#applyMembers,table.getn(applyMembers))
  --dump(applyMembers)
  local function tableCellTouched(table,cell)
    printf("cell touched at index: " .. cell:getIdx())
  end
  
  local function cellSizeForTable(table,idx) 
    return 101,535
  end
  
  local function tableCellAtIndex(tableView, idx)
    local cell = tableView:dequeueCell()
    if nil ~= cell then
      cell:removeFromParentAndCleanup(true)
    end
    print("applyMembers[idx+1]:",applyMembers[idx+1]:getName())
    cell = CCTableViewCell:new()
    local item = GuildApplyPlayerItemView.new(applyMembers[idx+1])
    item:setDelegate(tableView)
    cell:addChild(item)
    cell:setIdx(idx)
    return cell
  end
   
  local function numberOfCellsInTableView(val)
     return #applyMembers
  end
  local canvasSize = self:getCanvasContentSize()
  local tableView = CCTableView:create(canvasSize)
  tableView:setDirection(kCCScrollViewDirectionVertical)
  tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  tableView:setClippingToBounds(true)
  --tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  --tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)  
  tableView:setTouchPriority(priority)
  return tableView

end

function GuildProposersView:onExit()
  GuildProposersView.super.onExit(self)
end

return GuildProposersView