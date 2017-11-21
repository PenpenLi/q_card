
local k_property_atk_per = 10
local k_property_block = 15
local k_property_evade = 12
--local k_property_cri = 13
local kCriticalDamageIncAddPercent = 24
local k_property_hit = 11
local k_property_becure_per = 36

BattleCardEnhanceView = class("BattleCardEnhanceView",function()
    return display.newNode()
end)

function BattleCardEnhanceView:ctor(cardView)
  self._Count = 0
  self._Index = 0
  self._property = {}
  self._cardView = cardView
end

function BattleCardEnhanceView:addProperty(propertyId,type)
  self._Index = self._Index + 1
  local pkg = {}
  pkg.propertyId = propertyId
  pkg.type = type
  pkg.index = self._Index
  self._property[pkg.index] = pkg
  
  self:resetViews()

end

function BattleCardEnhanceView:removeProperty(propertyId,type)
--  assert(pkg[propertyId] ~= nil,string.format("[property = %d,type = %d] not yet been added.",propertyId,type))
  for key, pkg in pairs(self._property) do
  	if pkg.propertyId == propertyId and pkg.type == type then
  	 self._property[pkg.index] = nil
  	end
  end
  
  
  
  self:resetViews()
end

function BattleCardEnhanceView:getPropertyAtkIconPosition()
  return self._propertyAtkIconPosition
end

function BattleCardEnhanceView:resetViews()
  self:removeAllChildrenWithCleanup(true)
  local count = 0
  self._propertyAtkIconPosition = nil
  for key, pkg in pairs(self._property) do
    local spt = self:pickSpt(pkg.propertyId,pkg.type)
    if spt ~= nil then
      local height = 32
      spt:setPosition(ccp(43,-count * height + height))
      self:addChild(spt)
      
      if k_property_atk_per == pkg.propertyId and 1 == pkg.type then
         self._propertyAtkIconPosition = ccp(43,-count * height + height)
         self._cardView:updateFieldEffectPosition()
      end
      count = count + 1
    end
    self:setCount(count)
    if count == 3 then
      break
    end
  end
  
  if self._propertyAtkIconPosition == nil then
     local height = 32
     self._propertyAtkIconPosition = ccp(43,-count * height + height)
     self._cardView:updateFieldEffectPosition()
  end
  
end

function BattleCardEnhanceView:pickSpt(propertyId,type)
  local spt = nil
  if type == 1 then
    if propertyId == k_property_atk_per then
      spt = _res(3031001)
    elseif propertyId == k_property_block then
      spt = _res(3031002)
    elseif propertyId == k_property_evade then
      spt = _res(3031003)
    --elseif propertyId == k_property_cri then
    elseif propertyId == kCriticalDamageIncAddPercent then
      spt = _res(3031004)
    elseif propertyId == k_property_hit then
      spt = _res(3031005)
    elseif propertyId == k_property_hit then
    end
  elseif type == -1 then
    if propertyId == k_property_atk_per then
      spt = _res(3032001)
    elseif propertyId == k_property_block then
      spt = _res(3032002)
    elseif propertyId == k_property_evade then
      spt = _res(3032003)
    elseif propertyId == kCriticalDamageIncAddPercent then
      spt = _res(3032004)
    elseif propertyId == k_property_hit then
      spt = _res(3032005)
    elseif propertyId == k_property_becure_per then
      local statusNode,offsetX,offsetY = _res(5020123)
      statusNode:setPosition(ccp(offsetX,offsetY))
      self:addChild(statusNode)
      statusNode:getAnimation():play("default") 
    end
  end
  return spt
end

------
--  Getter & Setter for
--      BattleCardEnhanceView._Count 
-----
function BattleCardEnhanceView:setCount(Count)
	self._Count = Count
end

function BattleCardEnhanceView:getCount()
	return self._Count
end
