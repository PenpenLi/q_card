ccbRegisterPkg = class("ccbRegisterPkg")
ccbRegisterPkg.outlineProperty = "labelOutlineProperty"
function ccbRegisterPkg:ctor(target)
	self._func = {}
	self._property = {}
	self._target = target
end

function ccbRegisterPkg:addFunc(name,handler)
	self._func[name] = handler
end

function ccbRegisterPkg:getFunc()
	return self._func
end

function ccbRegisterPkg:addProperty(name,type,strokeColor,strokeSize)
	self._property[name] = type
	if strokeColor ~= nil and type == "CCLabelTTF" then
	   local strokeProperty = {}
	   strokeProperty.strokeColor = strokeColor
	   strokeProperty.strokeSize = strokeSize or 2
	   self._target[name..ccbRegisterPkg.outlineProperty] = strokeProperty
	end
end

function ccbRegisterPkg:getProperty()
	return self._property
end

function ccbRegisterPkg:getTarget()
	return self._target
end

return ccbRegisterPkg