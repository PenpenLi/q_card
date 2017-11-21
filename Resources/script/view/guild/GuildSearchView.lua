require("view.guild.GuildItemView")
GuildSearchView = class("GuildSearchView",BaseView)
function GuildSearchView:ctor(pos)
  GuildSearchView.super.ctor(self)
  self._pos = pos
end

function GuildSearchView:onEnter()
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("labelTip","CCLabelTTF")
  pkg:addProperty("nodeSearchCon","CCNode")
  pkg:addProperty("inputBg","CCScale9Sprite")
  
  pkg:addProperty("labelGuildInfo","CCLabelTTF")
  pkg:addProperty("labelRank","CCLabelTTF")
  
  pkg:addProperty("nodeSearchResult","CCNode")
  pkg:addProperty("nodeResultShowCon","CCNode")
  
  pkg:addFunc("searchHandler",GuildSearchView.searchHandler)
  
  local node,owner = ccbHelper.load("guild_search.ccbi","guild_search","CCNode",pkg)
  self:addChild(node)
  if self._pos ~= nil then
    node:setPosition(self._pos)
  end
  self.labelTip:setString("")
  self.labelRank:setString("")
  self.labelGuildInfo:setString("")
  self._fieldGuildName = UIHelper.convertBgToEditBox(self.inputBg,_tr("input_guild_id"),22,ccc3(66,66,66),false,50)
end

function GuildSearchView:onExit()
  
end

function GuildSearchView:searchHandler()
  printf("searchHandler")
  
  self.nodeResultShowCon:removeAllChildrenWithCleanup(true)
  self.labelTip:setString("")
  self.labelRank:setString("")
  self.labelGuildInfo:setString("")
  
  local toSearchGuildId = toint(self._fieldGuildName:getText())
  local result = Guild:Instance():getGuildById(toSearchGuildId)
  
  if result ~= nil then
      
    local sortListHandler = function(a,b)
      if a:getExp() == b:getExp() then
        return a:getId() < b:getId()
      end
      return a:getExp() > b:getExp()
    end
  
    local guildList = Guild:Instance():getGuildList()
    table.sort(guildList,sortListHandler)
    
    local idx = 1
    for i = 1, #guildList do
    	if result:getId() == guildList[i]:getId() then
    	 idx = i
    	 break
    	end
    end
  
    local guildItemView = GuildItemView.new(result)
    guildItemView:setIndex(idx)
    self.nodeResultShowCon:addChild(guildItemView)
    self.labelRank:setString(_tr("guild_rank_str"))
    self.labelGuildInfo:setString(_tr("guild_info_str"))
  else
    self.labelTip:setString(_tr("NOT_HAS_GUILD"))
  end
end

return GuildSearchView