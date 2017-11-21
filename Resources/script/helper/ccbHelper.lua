require("helper.ccbRegisterPkg")

ccbHelper = {}

function ccbHelper.load(filePath,nodeName,nodeType,pkg,remeberName)
  -- regist event handler
  local owner = {}
  local target = pkg:getTarget()
  local func = pkg:getFunc()
  for name, handler in pairs(func) do
  	owner[name] = function (eventName,control,controlEvent)
  	 handler(target,eventName,control,controlEvent)
  	end
  end
  
  -- mount ccb controller
  ccb[nodeName] = owner
  -- load ccb file
  local  proxy = CCBProxy:create()
  local  node  = CCBuilderReaderLoad(filePath,proxy,owner)
  local  layer = tolua.cast(node,nodeType)
  if nodeType == "CCNode" then
     CCNodeExtend.extend(layer)
  elseif nodeType == "CCLayer" then
     CCLayerExtend.extend(layer)
  elseif nodeType == "CCSprite" then
     CCSpriteExtend.extend(layer)
  end
  

  if nil ~= remeberName then
	  for k,v in pairs(owner) do 
		if type(v) ~= "function" then
			v.name = k
		end
	  end
  end

  local property = pkg:getProperty()
  for name, type in pairs(property) do
    target[name] = tolua.cast(owner[name],property[name])
    local strokeProperty = target[name..ccbRegisterPkg.outlineProperty]
    if strokeProperty ~= nil then
      if strokeProperty.strokeColor ~= nil and strokeProperty.strokeSize ~= nil then
       target[name]:enableStroke(strokeProperty.strokeColor,strokeProperty.strokeSize,true)
      end
    end
  end
  ccb[nodeName] = nil
  return layer,owner

end