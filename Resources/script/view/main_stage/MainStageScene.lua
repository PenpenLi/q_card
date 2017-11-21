require("view.BaseScene")  
require("view.main_stage.MainStageView") 

MainStageScene = class("MainStageScene", BaseScene)

function MainStageScene:ctor()
    MainStageScene.super.ctor()
    -- add various views
    self:addChild(MainStageView.new())
end

return MainStageScene