require("view.talent.TalentView")
TalentController = class("TalentController",BaseController)


function TalentController:enter()
  TalentController.super.enter(self)
  local talentView = TalentView.new(self)
  self.view = talentView
  self:getScene():replaceView(talentView)
end

function TalentController:getTalentConfig()
	return TalentData.GetTalentConfig()

end

function TalentController:exit()
    net.unregistAllCallback(self)
    TalentController.super.exit(self)
end

return TalentController