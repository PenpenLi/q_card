require("view.pvp_rank_match.PvpRankMatchView")
require("model.pvp_rank_match.PvpRankMatch")
PvpRankMatchController = class("PvpRankMatchController",BaseController)
function PvpRankMatchController:ctor()
  PvpRankMatchController.super.ctor(self)
end

function PvpRankMatchController:enter()
  PvpRankMatchController.super.enter(self)
  GameData:Instance():pushViewType(ViewType.rank_match)
  self._pvpRankMatchView = PvpRankMatchView.new()
  self._pvpRankMatchView:setDelegate(self)
  self:getScene():replaceView(self._pvpRankMatchView)
  self:getScene():setTopVisible(false)
  self:getScene():setBottomVisible(false)
  if PvpRankMatch:Instance():getHasInited() ~= true then
    PvpRankMatch:Instance():init()
  end
end

function PvpRankMatchController:showReports()
  if self._pvpRankMatchView ~= nil then
    self._pvpRankMatchView:reportsHandler()
  end
end

function PvpRankMatchController:exit()
  PvpRankMatchController.super.exit(self)
  self:getScene():setTopVisible(true)
  self:getScene():setBottomVisible(true)
end

return PvpRankMatchController