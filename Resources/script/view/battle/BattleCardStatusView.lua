
BattleCardStatusView = class("BattleCardStatusView",function()
    return display.newNode()
end)

function BattleCardStatusView:ctor()
  self._status = {}
end

function BattleCardStatusView:addStatus(statusId)
  local statusEffect = AllConfig.statuseffect[statusId]
  if statusEffect ~= nil and statusEffect.effect ~= 0 then
--    assert(self._status[statusId] == nil,string.format("Invalid state,status[%d] not yet been removed.",statusId))
    local statusNode,offsetX,offsetY = _res(statusEffect.effect)
    statusNode:setPosition(ccp(offsetX,offsetY))
    self:addChild(statusNode)
    self._status[statusId] = statusNode
    statusNode:getAnimation():play("default") 
  else
    printf("Not yet impl this status anim,statusId:%d",statusId)
  end

end

function BattleCardStatusView:removeStatus(statusId)
  local statusEffect = AllConfig.statuseffect[statusId]
  if statusEffect ~= nil and statusEffect.effect ~= 0 then
--    assert(self._status[statusId] ~= nil,string.format("Invalid state,status[%d] not yet been added.",statusId))
    self._status[statusId]:removeFromParentAndCleanup(true)
    self._status[statusId] = nil
  else
    printf("Not yet impl this status anim,statusId:%d",statusId)
  end

end