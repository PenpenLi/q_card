GuideBattleView = class("GuideBattleView",function()
    return display.newNode()
end)
function GuideBattleView:ctor()
  self:setNodeEventEnabled(true)
  --self:setAnchorPoint(ccp(0.5,0.5))
end

function GuideBattleView:onEnter()
  --self:setPosition(display.cx,display.cy)
end

function GuideBattleView:onExit()

end

function GuideBattleView:startMove(from,to)
    local hightLightedFrom = display.newSprite("img/guide/guide_image_bian.png")
    self:addChild(hightLightedFrom)
    hightLightedFrom:setPosition(from)
    
    local hightLightedTo = display.newSprite("img/guide/guide_image_bian.png")
    self:addChild(hightLightedTo)
    hightLightedTo:setPosition(to)
    
    local dragHandIcon = display.newSprite("img/guide/guide_drag_hand.png")
    self:addChild(dragHandIcon)
    dragHandIcon:setPosition(from)
    local drag_move = CCSequence:createWithTwoActions(CCMoveTo:create(0.01,from),CCMoveTo:create(1.5,to))
    dragHandIcon:runAction(CCRepeatForever:create(drag_move))
end


return GuideBattleView