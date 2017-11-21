require("view.guild.GuildFlagSettingsView")
GuildCreateView = class("GuildCreateView",function()
  return display.newNode()
end)
function GuildCreateView:ctor(pos)
  self:setNodeEventEnabled(true)
  self._pos = pos
end

function GuildCreateView:onEnter()
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("labelTip","CCLabelTTF")
  pkg:addProperty("inputBg","CCScale9Sprite")
  pkg:addProperty("nodeIconCon","CCNode")
  
  
  pkg:addProperty("labelCost","CCLabelTTF")
  
  pkg:addFunc("changeIconHandler",GuildCreateView.changeIconHandler)
  pkg:addFunc("createGuildHandler",GuildCreateView.createGuildHandler)
  
  local node,owner = ccbHelper.load("guild_create.ccbi","guild_create","CCNode",pkg)
  self:addChild(node)
  if self._pos ~= nil then
    node:setPosition(self._pos)
  end
  self._fieldGuildName = UIHelper.convertBgToEditBox(self.inputBg,_tr("input_guild_name"),22,ccc3(66,66,66),false,50)
  self.labelTip:setString("")
  self.labelCost:setString(AllConfig.guild[1].currency_count.."")
  
  local flagIcon = Guild:Instance():getFlagIconByInt(0)
  flagIcon:setScale(0.8)
  self.nodeIconCon:addChild(flagIcon)
  
end

function GuildCreateView:onExit()
  
end

function GuildCreateView:updateView()
  self.nodeIconCon:removeAllChildrenWithCleanup(true)
  local flagIcon = Guild:Instance():getFlagIconByInt(Guild:Instance():getTempFlagId())
  flagIcon:setScale(0.8)
  self.nodeIconCon:addChild(flagIcon)
end

function GuildCreateView:changeIconHandler()
  local guildFlagSettingsView = GuildFlagSettingsView.new()
  guildFlagSettingsView:setDelegate(self)
  GameData:Instance():getCurrentScene():addChildView(guildFlagSettingsView)
end

function GuildCreateView:createGuildHandler()
  self.labelTip:setString("")
  local guildName = self._fieldGuildName:getText()
  if guildName == "" then
    self.labelTip:setString(_tr("input_guild_name"))
    return
  elseif Guild:Instance():isRightLength(guildName,14) == false then
    self.labelTip:setString(_tr("guild_name_too_long"))
    return
  end
  
  if AllConfig.guild[1].currency_type == 2 then
    if GameData:Instance():getCurrentPlayer():getMoney() < AllConfig.guild[1].currency_count then
      GameData:Instance():notifyForPoorMoney()
      return
    end
  elseif AllConfig.guild[1].currency_type == 1 then
    if GameData:Instance():getCurrentPlayer():getMoney() < AllConfig.guild[1].currency_count then
      self.labelTip:setString(_tr("not enough coin"))
      return
    end
  end
  
  local guildFlag = Guild:Instance():getTempFlagId()
  local guildNotice = " "
  Guild:Instance():reqGuildCreateC2S(guildName,guildFlag,guildNotice)
end

return GuildCreateView