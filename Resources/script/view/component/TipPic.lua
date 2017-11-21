

TipPic = class("Mask",function()  return CCNode:create() end)


function TipPic:ctor(imgIdPath,isAnim)
  
  if isAnim == nil or isAnim == false then
    	local idPath = imgIdPath or "#common_tipImg.png"
    	self.img = display.newSprite(idPath)
    	if self.img ~= nil then 
    		self:addChild(self.img)
    		--show animation
    	    local strength = 5.0
    	    local times = 2
    
    	    local array = CCArray:create()
    	    local s_duration = 0.6/(times * 2)
    
    	    for i=1, times do
    	      local s_x =  0 --strength + math.random(strength * 100)/100.0
    	      local s_y =  strength + math.random(strength * 100)/100.0
    
    	      array:addObject(CCMoveBy:create(s_duration,ccp(s_x,s_y)))
    	      array:addObject(CCMoveBy:create(s_duration,ccp(-s_x,-s_y)))
    	    end
    
    	    array:addObject(CCDelayTime:create(3.0))
    
    	    local action = CCSequence:create(array)
    	    self.img:runAction(CCRepeatForever:create(action))
    	end
  else
      local effectAnim,offsetX,offsetY = _res(5020166)
      self:addChild(effectAnim)
      effectAnim:getAnimation():play("default")
      effectAnim:setPosition(ccp(offsetX - 27,offsetY - 45))
      --effectAnim:setPosition(ccp(offsetX,offsetY))
      self:setIsAnimation(true)
  end
  
end

------
--  Getter & Setter for
--      TipPic._IsAnimation 
-----
function TipPic:setIsAnimation(IsAnimation)
	self._IsAnimation = IsAnimation
end

function TipPic:getIsAnimation()
	return self._IsAnimation
end
