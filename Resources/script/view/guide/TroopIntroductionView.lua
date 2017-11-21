TroopIntroductionView = class("TroopIntroductionView",BaseView)

function TroopIntroductionView:ctor(battleView)
  TroopIntroductionView.super.ctor(self)
  self._battleView = battleView
  self:setNodeEventEnabled(true)
end

function TroopIntroductionView:areaWithUnitTypeAndPos(unitType,pos,direction)
  
  if pos < 4 or pos > 27 then
     return
  end
  
  self:removeAllChildrenWithCleanup(true)
  
  local mDirection = direction or 1
  
  local atkDistance = AllConfig.unittype[unitType].atk_distance
  local walkLength = AllConfig.unittype[unitType].move
  
  local startPos = pos
  
  -- close walk path
  --[[
  local walkPath = nil
  for i = 0, walkLength do
    --print("startPos:",startPos)
    if pos >= 4 and pos <= 27 then
      walkPath = display.newSprite("img/guide/guide_player_green.png")
      local m_pos = self._battleView:getPosByIndex(startPos)
      if m_pos.x == 0 and m_pos.y == 0 then
         m_pos = ccp(-500,-500)
      end
      walkPath:setPosition(m_pos)
      self:addChild(walkPath)
    end
    
    startPos = startPos + 4*mDirection
    
	  if(startPos < 0 or startPos>31) then --����С����
		  break
	  end
  end
  startPos = pos]]
  
  if unitType == 4 then
     atkDistance = atkDistance + 1
  end
  
  -- line targets
  local attackPositons = {}
  for j = 1, atkDistance do
      table.insert(attackPositons,startPos + j*4*mDirection)
  end
  
  -- clom targets
  if unitType == 10  then
     local left = startPos + 4*mDirection*atkDistance - 1
     if startPos % 4 ~= 0 then
        table.insert(attackPositons,left)
     end
     
     local right = startPos + 4*mDirection*atkDistance + 1
     if startPos % 4 ~= 3 then
         table.insert(attackPositons,right)
     end
  end
  
  if unitType == 10  then
     table.insert(attackPositons,startPos + (atkDistance+1)*4*mDirection)
  end
  
  for key, m_pos in pairs(attackPositons) do
      if m_pos >= 4 and m_pos <= 27 then
          local attackEnabledAnimation,offsetX,offsetY = _res(5020124)
          attackEnabledAnimation:setPosition(self._battleView:getPosByIndex(m_pos))
          attackEnabledAnimation:getAnimation():play("default") 
          self:addChild(attackEnabledAnimation)
      end
  end
  
end

function TroopIntroductionView:setPosAndWalkLength(pos,walkLength,attackPositons,direction)
  local startPos = pos
  local walkPath = nil
  
  local mdirection = direction or 1
  
  for i = 0, walkLength do
    --print("startPos:",startPos)
    walkPath = display.newSprite("img/guide/guide_player_green.png")
    walkPath:setPosition(self._battleView:getPosByIndex(startPos))
    self:addChild(walkPath)
    startPos = startPos - 4*mdirection
  end
  
  for key, m_pos in pairs(attackPositons) do
  	  local attackEnabledAnimation,offsetX,offsetY = _res(5020124)
      attackEnabledAnimation:setPosition(self._battleView:getPosByIndex(m_pos))
      attackEnabledAnimation:getAnimation():play("default") 
      self:addChild(attackEnabledAnimation)
  end
  
end


return TroopIntroductionView