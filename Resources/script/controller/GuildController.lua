require("view.guild.GuildView")
require("model.guild.Guild")
GuildController = class("GuildController",BaseController)

function GuildController:ctor()
  GuildController.super.ctor(self)
end

function GuildController:enter()
  GuildController.super.enter(self)
  local haveGuild = Guild:Instance():getSelfHaveGuild()
  local guildView = GuildView.new(haveGuild)
  self:getScene():replaceView(guildView,true)
end

return GuildController