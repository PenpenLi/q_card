require("view.guild.GuildChapterItemView")
GuildChaptersView = class("GuildChaptersView",PopModule)
function GuildChaptersView:ctor()
  local size = CCSizeMake(615,880)
  self._popSize = size
  GuildChaptersView.super.ctor(self,size)
  self:setNodeEventEnabled(true)
  self:setAutoDisposeEnabled(false)
end

function GuildChaptersView:onEnter()
  local bg = display.newSprite("img/pvp_rank_match/pvp_rank_match_bg.png")
  self:setMaskbackGround(bg)
  GuildChaptersView.super.onEnter(self)
  display.addSpriteFramesWithFile("guild/guild.plist", "guild/guild.png")
  self:setTitleWithSprite(display.newSprite("#guild_gonghuifuben.png"))
  self:buildTableView()
  Guild:Instance():setGuildView(self)
end

function GuildChaptersView:updateView()
  if self.tableView ~= nil then
     self.tableView:reloadData()
  end
end

function GuildChaptersView:buildTableView()
  local chapterCount,chapters = Scenario:Instance():getChapterCountByChapterType(StageConfig.ChapterTypeGuild)
  
  table.sort(chapters,function(a,b)
    return a:getId() < b:getId()
  end)
  local function tableCellTouched(table,cell)
      printf("cell touched at index: " .. cell:getIdx())
   end
  
   local function cellSizeForTable(table,idx) 
      return 140,535
   end
  
   local function tableCellAtIndex(tableView, idx)
      local cell = tableView:dequeueCell()
      if nil ~= cell then
        cell:removeFromParentAndCleanup(true)
      end
      
      cell = CCTableViewCell:new()
      local item = GuildChapterItemView.new(chapters[idx+1])
      item:setDelegate(tableView)
      cell:addChild(item)
      cell:setIdx(idx)
      return cell
  end
   
  local function numberOfCellsInTableView(val)
     return #chapters
  end
  local mSize = self:getCanvasContentSize()
  local tableView = CCTableView:create(mSize)
  tableView:setDirection(kCCScrollViewDirectionVertical)
  tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  tableView:setClippingToBounds(true)
  self:getListContainer():addChild(tableView)
  --tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  --tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)  
  tableView:reloadData()
  self.tableView = tableView
  tableView:setPositionX(8)
end

function GuildChaptersView:onCloseHandler()
  GuildChaptersView.super.onCloseHandler(self)
  local controller = ControllerFactory:Instance():create(ControllerType.GUILD_CONTROLLER)
  controller:enter()
end

function GuildChaptersView:onExit()
  GuildChaptersView.super.onExit(self)
  Guild:Instance():setGuildView(nil)
end




return GuildChaptersView