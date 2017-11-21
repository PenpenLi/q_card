require("view.component.PopModule") 
require("view.guild.GuildSearchView")
require("view.guild.GuildCreateView")
require("view.guild.GuildMyGuildView")
require("view.guild.GuildItemView")

GuildView = class("GuildView",PopModule)
function GuildView:ctor(hasJoinedGuild)
  local size = CCSizeMake(615,880)
  self._popSize = size
  GuildView.super.ctor(self,size)
  self:setNodeEventEnabled(true)
  self:setAutoDisposeEnabled(true)
  self._hasJoinedGuild = hasJoinedGuild
end

function GuildView:onEnter()
  _executeNewBird()
  --bg 
  local bg = display.newSprite("img/pvp_rank_match/pvp_rank_match_bg.png")
  self:setMaskbackGround(bg)
  GuildView.super.onEnter(self)
  
  Guild:Instance():setGuildView(self)
  display.addSpriteFramesWithFile("guild/guild.plist", "guild/guild.png")
 
  self:setTitleWithSprite(display.newSprite("#guild_gonghui.png"))
  self:tabControlOnClick(0)
  
  if Guild:Instance():getHasInited() ~= true then
    Guild:Instance():init()
  else
    self:updateView()
  end
  
end

function GuildView:onExit()
  GuildView.super.onExit(self)
  display.removeSpriteFramesWithFile("guild/guild.plist", "guild/guild.png")
  Guild:Instance():setGuildView(nil)
end

function GuildView:updateView(idx)
  if idx ~= nil then
    self._tabIdx = idx
  end

  printf("GuildView:updateView()")
  self._hasJoinedGuild = Guild:Instance():getSelfHaveGuild()
  
  local menuArray = {}
  local menuMyguild = {"#guild_btn_wodegonghui.png","#guild_btn_wodegonghui_1.png"}
  local menuGuildsList = {"#guild_btn_gonghuiliebiao.png","#guild_btn_gonghuiliebiao_1.png"}
  local menuCreateGuild = {"#guild_btn_chuangjiangonghui.png","#guild_btn_chuangjiangonghui_1.png"}
  local menuSearchGuild = {"#guild_btn_chazhaogonghui.png","#guild_btn_chazhaogonghui_1.png"}
  
  if self._hasJoinedGuild == true then
    menuArray = {menuMyguild,menuGuildsList,menuSearchGuild}
  else
    menuArray = {menuGuildsList,menuCreateGuild,menuSearchGuild}
  end

  self:setMenuArray(menuArray)
  
  local canvasSize = self:getCanvasContentSize()
  
  if self._sonbg == nil then
    local sonbg = display.newScale9Sprite("#guild_bj_1.png",0,0,canvasSize)
    self:getPopBg():addChild(sonbg,0)
    self._sonbg = sonbg
  else
    self._sonbg:setContentSize(canvasSize)
  end
  local posx,posy = self:getListContainer():getPosition()
  self._sonbg:setPosition(posx + canvasSize.width/2,posy + canvasSize.height/2)
  
  if self._tabIdx == nil then
    self._tabIdx = 0
  end
  self:tabControlOnClick(self._tabIdx)
  
--  local guildList = Guild:Instance():getGuildList()
--    dump(guildList)
end

function GuildView:buildGuildList()
  local sortListHandler = function(a,b)
    if a:getExp() == b:getExp() then
      return a:getId() < b:getId()
    end
    return a:getExp() > b:getExp()
  end

  local guildList = Guild:Instance():getGuildList()
  table.sort(guildList,sortListHandler)

  local function tableCellTouched(table,cell)
      printf("cell touched at index: " .. cell:getIdx())
   end
  
   local function cellSizeForTable(table,idx) 
      return 165,535
   end
  
   local function tableCellAtIndex(tableView, idx)
      local cell = tableView:dequeueCell()
      if nil ~= cell then
        cell:removeFromParentAndCleanup(true)
      end
      
      cell = CCTableViewCell:new()
      local item = GuildItemView.new(guildList[idx+1])
      item:setIndex(idx+1)
      cell:addChild(item)
      cell:setIdx(idx)
      return cell
  end
   
  local function numberOfCellsInTableView(val)
     return #guildList
  end
  local canvasSize = self:getCanvasContentSize()
  local tableView = CCTableView:create(canvasSize)
  tableView:setDirection(kCCScrollViewDirectionVertical)
  tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  tableView:setClippingToBounds(true)
  --tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)  
  tableView:reloadData()
  
  return tableView

end


function GuildView:onCloseHandler()
  GuildView.super.onCloseHandler(self)
  GameData:Instance():gotoPreView()
end

function GuildView:tabControlOnClick(idx)
  self._tabIdx = idx
  local container = self:getListContainer()
  container:removeAllChildrenWithCleanup(true)
  local canvasSize = self:getCanvasContentSize()
  
  if idx == 0 then
    if self._hasJoinedGuild == true then
      local myGuildView = GuildMyGuildView.new()
      container:addChild(myGuildView)
    else
      local guildList = Guild:Instance():getGuildList()
      if #guildList > 0 then
        local guildListView = self:buildGuildList()
        container:addChild(guildListView)
        guildListView:setPositionX(15)
      end
    end
  elseif idx == 1 then
    if self._hasJoinedGuild == true then
      local guildList = Guild:Instance():getGuildList()
      if #guildList > 0 then
        local guildListView = self:buildGuildList()
        container:addChild(guildListView)
        guildListView:setPositionX(15)
      end
    else
      local pos = ccp(canvasSize.width*0.5,canvasSize.height*0.5)
      local guildCreateView = GuildCreateView.new(pos)
      container:addChild(guildCreateView)
      --guildCreateView:setPosition(ccp(canvasSize.width*0.5,canvasSize.height*0.5))
    end
  elseif idx == 2 then
    local pos = ccp(canvasSize.width*0.5,canvasSize.height*0.5)
    local guildSearchView = GuildSearchView.new(pos)
    container:addChild(guildSearchView)
    --guildSearchView:setPosition(ccp(canvasSize.width*0.5,canvasSize.height*0.5))
  end
end

return GuildView