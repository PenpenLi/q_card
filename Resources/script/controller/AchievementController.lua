require("view.achievement.AchievementView")
require("model.Achievement.Achievement")

AchievementController = class("AchievementController",BaseController)

function AchievementController:ctor()
	AchievementController.super.ctor(self)
end

function AchievementController:enter(achtype)
	AchievementController.super.enter(self)
  self:setCurViewType(achtype)
	local view = AchievementView.new()
	view:setDelegate(self)
	self:getScene():replaceView(view)
end


function AchievementController:goBackView()
	GameData:Instance():gotoPreView()
end

function AchievementController:setCurViewType(viewType)
  self._viewType = viewType
end 

function AchievementController:getCurViewType()
  return self._viewType or AchievementType.Official 
end 

return AchievementController