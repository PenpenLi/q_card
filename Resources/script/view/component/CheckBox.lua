
local CheckBox = class("CheckBox",function()
    return display.newLayer()
end)
CheckBox.__index = CheckBox
function CheckBox.convert(layer,imgsSetting)
	assert(layer.__isconverted == nil,"")
	layer.__isconverted = true
	
	layer = tolua.cast(layer,"CCLayer")
	local t = tolua.getpeer(layer)
    if not t then
        t = {}
        tolua.setpeer(layer, t)
    end
    setmetatable(t, CheckBox)

	layer._background = layer:getChildByTag(1001)
	layer._check_spr = layer:getChildByTag(1002)
	layer._background = tolua.cast(layer._background,"CCSprite")
	layer._check_spr = tolua.cast(layer._check_spr,"CCSprite")

	layer:_init(imgsSetting)
	return layer
end

function CheckBox:ctor(imgsSetting)
	self._check_spr = display.newSprite()
	self._background = display.newSprite()
	self:addChild(self._check_spr)
	self:addChild(self._background)
	self:_init(imgsSetting)
end

function CheckBox:_init(imgsSetting)
	self._isented=false

	self._events={}
	self._disable_events={click=function() return true end}
	self._lastcheckImg = nil
	self._isEnabled=true
	self:setImages(imgsSetting)

	self:registerScriptHandler(function(event)
		if (event=="enter" ) then
			self._isented =true
			MessageBox.Help.LayerClick(self,self._background,function()
				self:Select(not self._isSelected )
			end)
		elseif(event=="leave") then
			self._isented =false
			MessageBox.Help.LayerClickRemove(self)
		end
	end)
end
function CheckBox:setEvents(events)
	for n,v in pairs(events) do
		self._events[n]=v
	end
end
function CheckBox:_Select(isSelect)
	local ischanged = self._isSelected ~= isSelect
	self._isSelected = isSelect
	local imgsrc = self._isSelected and self._selectedImgSrc or self._nonselectedImgSrc
	if(imgsrc) then
		self._check_spr:setVisible(true)
		if(self._lastcheckImg ~= imgsrc) then
			MessageBox.Help.changeSpriteImage(self._check_spr,imgsrc)
			self._lastcheckImg = imgsrc
		end
	else
		self._check_spr:setVisible(false)
	end
	if (ischanged and self._events["state"]) then
		self._events["state"](isSelect)
	end
end
function CheckBox:Select(state,force)
	local event = self._events["click"]
	if force or  not( event and event(state) ) then
		self:_Select(state)
	end
end
function CheckBox:setEnable(isenable)
	if(self._isEnabled and not isenable) then
		self._events_bak = self._events
		self._events = self._disable_events
	elseif(not self._isEnabled and isenable) then
		self._events = self._events_bak		
	end
end
function CheckBox:setImages(imgs)
	if (not imgs) then
		return 
	end
	if(imgs.SelectedImage) then
		self._selectedImgSrc = imgs.SelectedImage
		if(self._isSelected) then
			self:Select(true)
		end
	end
	if(imgs.UnSelectedImage) then
		self._nonselectedImgSrc = imgs.UnSelectedImage
		if(not self._isSelected) then
			self:Select(false)
		end
	end
	if(imgs.Background) then
		self._backgroundSrc = imgs.Background
		MessageBox.Help.changeSpriteImage(self._background,self._backgroundSrc)
		if(self._isented) then
			self.onLeave()
			self.onEnter()
		end
	end
end

function CheckBox:getImages()
	return {
		SelectedImage = self._selectedImgSrc,
		UnSelectedImage = self._nonselectedImgSrc,
		Background = self._backgroundSrc
	}
end
function CheckBox:IsSelect()
	return self._isSelected
end

if(not UIComponent) then
	UIComponent = {}
end

UIComponent.CheckBox = CheckBox
return CheckBox