
SequenceAnim = class("SequenceAnim",function()
    return display.newNode()
end)

local SequenceAnimNode = class("SequenceAnimNode",function()
    return display.newNode()
end)

-- offsetx,offsety,plists,pattern,from,to,duration,isloop

function SequenceAnim:ctor(info)
  assert(info ~= nil)
  
  self._Animation = SequenceAnimNode.new(info)
  self:addChild(self._Animation)
--  self._Animation:setPosition(ccp(info.offsetx,info.offsety))
end

------
--  Getter & Setter for
--      SequenceAnim._Animation 
-----
function SequenceAnim:setAnimation(Animation)
	self._Animation = Animation
end

function SequenceAnim:getAnimation()
	return self._Animation
end

function SequenceAnim:setAnimAnchorPoint(pos)
  self._Animation:setAnimAnchorPoint(pos)
end

function SequenceAnim:setFlipX(is_flip)
  self._Animation:setFlipX(is_flip)
end

function SequenceAnim:setFlipY(is_flip)
  self._Animation:setFlipY(is_flip)
end

----------------- SequenceAnimNode -----------------

function SequenceAnimNode:ctor(info)
  assert(info ~= nil)
  local cache = CCSpriteFrameCache:sharedSpriteFrameCache()
  local array = CCArray:create()
  for i=info.from, info.to do
    local frame_name = string.format(info.pattern,i)
    array:addObject(cache:spriteFrameByName(frame_name))
  end
  local animation = CCAnimation:createWithSpriteFrames(array)
  local duration = info.duration / 1000.0 * CONFIG_DEFAULT_ANIM_DELAY_RATIO
  animation:setDelayPerUnit(duration)
  local animate = CCAnimate:create(animation)
  self._animate = animate
  
  local spt = CCSprite:createWithSpriteFrameName(string.format(info.pattern,info.from))
  self:addChild(spt)
  self._spt = spt
  
  self._IsLoop = info.isloop
end

function SequenceAnimNode:setAnimAnchorPoint(pos)
  self._spt:setAnchorPoint(pos)
end

function SequenceAnimNode:setFlipX(is_flip)
  self._spt:setFlipX(is_flip)
end

function SequenceAnimNode:setFlipY(is_flip)
  self._spt:setFlipY(is_flip)
end


function SequenceAnimNode:play()
  if self._IsLoop == 0 then
    local array = CCArray:create()
    array:addObject(self._animate)
    array:addObject(CCHide:create())
    self._spt:runAction(CCSequence:create(array))
  else
    self._spt:runAction(CCRepeatForever:create(self._animate))
  end
  
end

------
--  Getter & Setter for
--      SequenceAnim._IsLoop 
-----
function SequenceAnimNode:setIsLoop(IsLoop)
	self._IsLoop = IsLoop
end

function SequenceAnimNode:getIsLoop()
	return self._IsLoop
end
