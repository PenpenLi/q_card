require("view.guild.GuildStagesView")
require("view.guild.GuildChaptersView")
GuildStagesController = class("GuildStagesController",BaseController)
function GuildStagesController:ctor()
  GuildStagesController.super.ctor(self)
end

function GuildStagesController:enter()
  GuildStagesController.super.enter(self)
  local guildChaptersView = GuildChaptersView.new()
  self:getScene():replaceView(guildChaptersView,true)
end

function GuildStagesController:reqPVEFightCheck(stage)
  Guild:Instance():reqGuildFightCheckC2S()
end

return GuildStagesController