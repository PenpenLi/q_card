BattleFieldView = class("BattleFieldView",BaseView)
function BattleFieldView:ctor(field,battle)
   BattleFieldView.super.ctor(self)
   local viewConfig = battle:getViewConfig()
   self:setIsLocked(false)
   local opacity = 150
   if BATTLE_TEST_OPEN == 0 then --normal
     local i = field:getPos()%4
     if battle:getBattleView() ~= nil and battle:getBattleView()._isLocalPlay ~= true and i > 0 and field:getPos() > 3 and field:getPos() <= 27 then
       if GameData:Instance():checkSystemOpenCondition(32 + i) == true then
         self._normalTexture = _res(viewConfig.empty)
         self._normalTexture:setCascadeOpacityEnabled(true)
         self._normalTexture:setOpacity(opacity)
       else
         self._normalTexture = _res(3034005)
         self:setIsLocked(true)
       end
     else
       self._normalTexture = _res(viewConfig.empty)
       self._normalTexture:setCascadeOpacityEnabled(true)
       self._normalTexture:setOpacity(opacity)
     end
   else
     self._normalTexture = _res(viewConfig.empty)
     self._normalTexture:setCascadeOpacityEnabled(true)
     self._normalTexture:setOpacity(opacity)
   end
  
   self._specialTexture = nil
   self:addChild(self._normalTexture)
   self:setContentSize(self._normalTexture:getContentSize())
   if field == nil then 
      return
   end
   self:setData(field,battle)
end

------
--  Getter & Setter for
--      BattleFieldView._IsLocked 
-----
function BattleFieldView:setIsLocked(IsLocked)
	self._IsLocked = IsLocked
end

function BattleFieldView:getIsLocked()
	return self._IsLocked
end

function BattleFieldView:setData(field,battle)
  local viewConfig = battle:getViewConfig()
  self._field = field
  
  
  local type = field:getType()
  if type ~= nil then
     if self._specialTexture ~= nil then
        self:removeChild(self._specialTexture,true)
        self._specialTexture = nil
     end
      if type == PbFieldType.Hill then
        self._specialTexture = _res(viewConfig.hill)
        self:addChild(self._specialTexture)
      elseif type == PbFieldType.Forest then
        self._specialTexture = _res(viewConfig.forest)
        self:addChild(self._specialTexture)
      elseif type == PbFieldType.Tower then
        self._specialTexture = _res(viewConfig.tower)
        self:addChild(self._specialTexture)
      elseif type == PbFieldType.Empty then
      elseif type == PbFieldType.Wall then
        assert(false,string.format("Invalid field type:%s",type))
      end
      
  else
     if self._specialTexture ~= nil then
        self:removeChild(self._specialTexture,true)
        self._specialTexture = nil
     end
  end
      
end



function BattleFieldView:getData()
  return self._field
end

function BattleFieldView:playDropItem()
  -- TODO play drop item anim
  local anim,offsetX,offsetY,d = _res(5020131)
  anim:setPosition(ccp(offsetX,offsetY))
  self:addChild(anim,99)
  anim:getAnimation():play("default") 
  self:wait(d)
  anim:removeFromParentAndCleanup(true)
end

function BattleFieldView:wait(duration)
  local cur = coroutine.running()
  self:performWithDelay(function () 
  local success,error = coroutine.resume(cur)
    if not success then
      printf("coroutine error:"..error)
      print(debug.traceback(cur, error)) 
    end
  end,duration)
  coroutine.yield()

end

return BattleFieldView