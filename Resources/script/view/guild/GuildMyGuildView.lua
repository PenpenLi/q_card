require("view.guild.GuildMemberItemView")
require("view.guild.GuildMenusView")
require("view.guild.GuildDonateView")
require("view.guild.GuildStagesView")
require("view.guild.GuildChaptersView")
require("view.chat.ChatView")
require("view.guild.GuildLogsView")

GuildMyGuildView = class("GuildMyGuildView",BaseView)
function GuildMyGuildView:ctor()
  GuildMyGuildView.super.ctor(self)
end
function GuildMyGuildView:onEnter()
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("nodeMemberList","CCNode")
  pkg:addProperty("nodeGuildFlag","CCNode")
  pkg:addProperty("labelGuildName","CCLabelTTF")
  pkg:addProperty("labelGuildId","CCLabelTTF")
  pkg:addProperty("labelPreMemberSize","CCLabelTTF")
  pkg:addProperty("labelMemberSize","CCLabelTTF")
  pkg:addProperty("labelPreGuildLevel","CCLabelTTF")
  pkg:addProperty("labelGuildLevel","CCLabelTTF")
  pkg:addProperty("labelNotice","CCLabelTTF")
  pkg:addProperty("labelGuildGold","CCLabelTTF")
  pkg:addProperty("labelPreGuildExp","CCLabelTTF")
  pkg:addProperty("labelGuildExp","CCLabelTTF")
  pkg:addProperty("meunSetting","CCMenu")
  
  pkg:addFunc("editGuildHandler",GuildMyGuildView.editGuildHandler)
  pkg:addFunc("openDonateHandler",GuildMyGuildView.openDonateHandler)
  pkg:addFunc("openStageViewHandler",GuildMyGuildView.openStageViewHandler)
  --pkg:addFunc("chatOpenHandler",GuildMyGuildView.chatOpenHandler)
  pkg:addFunc("openShopViewHandler",GuildMyGuildView.openShopViewHandler)
    
  local node,owner = ccbHelper.load("guild_my_guild.ccbi","guild_my_guild","CCNode",pkg)
  self:addChild(node)
  node:setPositionX(7)
  
  self.labelPreGuildLevel:setString(_tr("level"))
  self.labelPreMemberSize:setString(_tr("member_str"))
  
  local members = {}
  self:buildTableView()
  
  local myGuildBase = Guild:Instance():getSelfGuildBase()
  if myGuildBase ~= nil then
    self.labelGuildName:setString(myGuildBase:getName())
    self.labelGuildId:setString(myGuildBase:getId().."")
    local guildLevel = myGuildBase:getLevel()
    print("guildLevel:",guildLevel)
    self.labelGuildLevel:setString(guildLevel.."")
    self.labelNotice:setString(myGuildBase:getNotice())
    local maxMembers = AllConfig.guild_level[guildLevel].max_member
    self.labelMemberSize:setString(#myGuildBase:getMembers().."/"..maxMembers)
    
    local flagIcon = Guild:Instance():getFlagIconByInt(myGuildBase:getFlag())
    self.nodeGuildFlag:addChild(flagIcon)
    flagIcon:setScale(0.75)
    
    self.labelGuildGold:setString(myGuildBase:getMoney().."")
    
    local maxExpStr = ""
    local nextLevelExp = 0
    if AllConfig.guild_level[guildLevel + 1] ~= nil then
      nextLevelExp = AllConfig.guild_level[guildLevel + 1].guild_exp
      maxExpStr = "/"..nextLevelExp
    else
      maxExpStr = "/MAX"
    end
    
    self.labelGuildExp:setString(myGuildBase:getExp()..maxExpStr)
  end
  
  local selfMember = myGuildBase:getMemberById(GameData:Instance():getCurrentPlayer():getId())
  if selfMember ~= nil then
    if selfMember:getJob() == GuildConfig.MemberTypeChairman
    or selfMember:getJob() == GuildConfig.MemberTypeViceChairman
    then
      self.meunSetting:setVisible(true)
    else
      self.meunSetting:setVisible(false)
    end
  end

end

function GuildMyGuildView:onExit()
  
end

function GuildMyGuildView:buildTableView()
  local members = Guild:Instance():getSelfGuildBase():getMembers()
  --[[
  GuildConfig.MemberTypeChairman = "CHAIRMAN" --会长
  GuildConfig.MemberTypeViceChairman = "VICE_CHAIRMAN" --副会长
  ]]  
  local sortMembers = function(a,b)
    if a:getJobId() == b:getJobId() then
      if a:getPoint() == b:getPoint() then
        return a:getPlayerId() < b:getPlayerId()
      end
      
      return a:getPoint() > b:getPoint()
    end
    return a:getJobId() < b:getJobId()
    
  end
  print("sortMember~~~~~~~~~~~~~~~")
  table.sort(members,sortMembers)

   local function tableCellTouched(table,cell)
      printf("cell touched at index: " .. cell:getIdx())
      
      local selfMember = Guild:Instance():getSelfGuildBase():getMemberById(GameData:Instance():getCurrentPlayer():getId())
      --if selfMember:getPlayerId() ~= members[cell:getIdx()+1]:getPlayerId() then
        local guildMenusView = GuildMenusView.new(1,members[cell:getIdx()+1])
        GameData:Instance():getCurrentScene():addChildView(guildMenusView)
      --end
   end
  
   local function cellSizeForTable(table,idx) 
      return 100,535
   end
  
   local function tableCellAtIndex(tableView, idx)
      local cell = tableView:dequeueCell()
      if nil ~= cell then
        cell:removeFromParentAndCleanup(true)
      end
      
      cell = CCTableViewCell:new()
      local item = GuildMemberItemView.new(members[idx+1])
      cell:addChild(item)
      cell:setIdx(idx)
      return cell
  end
   
  local function numberOfCellsInTableView(val)
     return #members
  end
  local mSize = self.nodeMemberList:getContentSize()
  local tableView = CCTableView:create(mSize)
  tableView:setDirection(kCCScrollViewDirectionVertical)
  tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  tableView:setClippingToBounds(true)
  self.nodeMemberList:addChild(tableView)
  --tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)  
  tableView:reloadData()
  self.tableView = tableView
end

function GuildMyGuildView:editGuildHandler()
  Guild:Instance():reqGuildQueryC2S()

  local guildMenusView = GuildMenusView.new(0)
  GameData:Instance():getCurrentScene():addChildView(guildMenusView)
end

function GuildMyGuildView:openDonateHandler()
  local guildDonateView = GuildDonateView.new()
  GameData:Instance():getCurrentScene():addChildView(guildDonateView)
end

function GuildMyGuildView:chatOpenHandler()
  local chatView = ChatView.new(Chat.ChannelGuild)
  GameData:Instance():getCurrentScene():addChildView(chatView)
end

function GuildMyGuildView:openStageViewHandler()
  local controller = ControllerFactory:Instance():create(ControllerType.GUILD_STAGES_CONTROLLER)
  controller:enter()
end

function GuildMyGuildView:openShopViewHandler()
 local view = PopShopListView.new(ShopCurViewType.GongHui,-300)
 view:setTopBottomVisibleWhenExit(false)
 GameData:Instance():getCurrentScene():addChildView(view)
end


return GuildMyGuildView