require("view.BaseView")  
require("model.GameData")  

MainStageView = class("MainStageView", BaseView)

function MainStageView:ctor()
    MainStageView.super.ctor()
    
    display.addSpriteFramesWithFile(GAME_TEXTURE_DATA_FILENAME, GAME_TEXTURE_IMAGE_FILENAME)
    
    self.bg = display.newSprite("#MenuSceneBg.png", display.cx, display.cy)
    self:addChild(self.bg)
    
    local player = GameData:Instance():getCurrentPlayer()
    echo(player.name)

end

return MainStageView