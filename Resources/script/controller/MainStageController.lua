require("controller.BaseController")  
require("view.main_stage.MainStageScene")  

MainStageController = class("MainStageController",BaseController)

function MainStageController:ctor()
  MainStageController.super.ctor(self, "MainStageController")
  echo("MainStageScene:ctor")
end

function MainStageController:enter()
  MainStageController.super.enter(self)
  self.view = MainStageScene.new()
  display.replaceScene(self.view, "fade", 0.6, display.COLOR_WHITE)
  
end

return MainStageController