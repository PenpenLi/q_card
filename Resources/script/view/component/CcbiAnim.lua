require("helper.ccbRegisterPkg")
CcbiAnim = class("CcbiAnim",function()
    return display.newNode()
end)

local CcbiAnimNode = class("CcbiAnimNode",function()
    return display.newNode()
end)

function CcbiAnim:ctor(path,codeConnectionName,cc_type,params)
  assert(path ~= nil)
  if cc_type == nil then
    cc_type = "CCNode"
  end
  
  self:setNodeEventEnabled(true)
  
  self._callbacks = {}
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("mAnimationManager","CCBAnimationManager")
  if params then
    for key, property in pairs(params) do
      if property.name and property.type then
    	 pkg:addProperty(property.name,property.type)
    	end
    end
  end
  --pkg:addFunc("time_distance",function() end)
  --print(path..".ccbi")
  --local ccbiAnimation,owner = ccbHelper.load("skills/"..path..".ccbi",codeConnectionName,cc_type,pkg)
  local ccbiAnimation,owner = ccbHelper.load(path,codeConnectionName,cc_type,pkg)
  self:addChild(ccbiAnimation)
  
  local sequenceName = self.mAnimationManager:getRunningSequenceName()
  local duration = self.mAnimationManager:getSequenceDuration(sequenceName)
  self:setDuration(duration)
    
  self._Animation = CcbiAnimNode.new(self)
  self:addChild(self._Animation)
end

------
--  Getter & Setter for
--      CcbiAnim._Duration 
-----
function CcbiAnim:setDuration(Duration)
	self._Duration = Duration
end

function CcbiAnim:getDuration()
	return self._Duration
end

------
--  Getter & Setter for
--      CcbiAnim._Animation 
-----
function CcbiAnim:setAnimation(Animation)
	self._Animation = Animation
end

function CcbiAnim:getAnimation()
	return self._Animation
end

function CcbiAnim:play(name)
  self.mAnimationManager:runAnimationsForSequenceNamed(name)
end

function CcbiAnim:setCallBack(name,handler)
  self._callbacks[name] = handler
  self.mAnimationManager:setCallFuncForLuaCallbackNamed(handler,name)
end

function CcbiAnim:setAnimAnchorPoint(pos)
  self:setAnchorPoint(pos)
end

function CcbiAnim:setFlipX(is_flip)
  local scaleX = 1
  if is_flip == true then
    scaleX = -1
  end
  self:setScaleX(scaleX)
end

function CcbiAnim:setFlipY(is_flip)
  local scaleY = 1
  if is_flip == true then
    scaleY = -1
  end
  self:setScaleY(scaleY)
end


----------------- CcbiAnimNode -----------------

function CcbiAnimNode:ctor(delegate)
  self._delegate = delegate
end


function CcbiAnimNode:play(name)
  ---self._delegate:play(name)
end

