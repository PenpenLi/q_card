require("view.BaseView")
GuidePopup = class("GuidePopup", BaseView)

function GuidePopup:ctor(guideStep)
  assert(guideStep ~= nil,"must has an guide step info")
	GuidePopup.super.ctor(self)
  self:setNodeEventEnabled(true)
	local pkg = ccbRegisterPkg.new(self)
	pkg:addFunc("confirmCallback",GuidePopup.confirmCallback)
	pkg:addProperty("layer_mask","CCLayerColor")
	pkg:addProperty("node_pop","CCNode")
	pkg:addProperty("nodeIcon","CCNode")
	pkg:addProperty("bn_confirm","CCControlButton")
	pkg:addProperty("label_title","CCLabelTTF")
	pkg:addProperty("label_content","CCLabelTTF")

	local layer,owner = ccbHelper.load("GuidePopup.ccbi","GuidePopupCCB","CCLayer",pkg)
	self:addChild(layer)
	
	local title = guideStep:getPopTitle() 
	local content = guideStep:getPopContent()
	local resId = guideStep:getPopIcon()
	local closeType = guideStep:getPopCloseType()
	
	self.label_title:setString(title)
	self.label_title:setVisible(false)
	local labelTitle = RichLabel:create(title, "Courier-Bold", 22, CCSizeMake(302, 0),true,false)
	labelTitle:setColor(ccc3(69,20,1))
  labelTitle:setPosition(self.label_title:getPositionX() -  self.label_title:getContentSize().width/2,self.label_title:getPositionY() + self.label_title:getContentSize().height/2)
  self.node_pop:addChild(labelTitle)
  
  local labelContent = RichLabel:create(content, "Courier-Bold", 22, CCSizeMake(302, 0),true,false)
  labelContent:setColor(ccc3(69,20,1))
  labelContent:setPosition(self.label_content:getPosition())
  self.node_pop:addChild(labelContent)
  
  self.label_content:setString("")
  
  if resId > 0 then
    local res = _res(resId)
    assert(res ~= nil)
    if res ~= nil then
      self.nodeIcon:addChild(res)
    end
  end
  
  self._closeType = closeType
	
end

function GuidePopup:onEnter()
	local priority = -300
	self.layer_mask:addTouchEventListener(function(event, x, y)
																		if event == "began" then
																			return true
																		end
																	end,
															false, priority, true)
	self.layer_mask:setTouchEnabled(true)

	self.bn_confirm:setTouchPriority(priority-1)
end 

function GuidePopup:onExit()
  
end 

function GuidePopup:confirmCallback()
   self:setVisible(false)
   if self._closeType == 1 then
    if ControllerFactory:Instance():getCurrentControllerType() ~= ControllerType.HOME_CONTROLLER then
       local controller = ControllerFactory:Instance():create(ControllerType.HOME_CONTROLLER)
       controller:enter()
    else
      CCNotificationCenter:sharedNotificationCenter():postNotification(GuideConfig.SendGuideId2Server)
      CCNotificationCenter:sharedNotificationCenter():postNotification(GuideConfig.GuideLayerRemoved)
    end
  elseif self._closeType == 0 then
    Guide:Instance():removeGuideLayer()
    CCNotificationCenter:sharedNotificationCenter():postNotification(GuideConfig.SendGuideId2Server)
    CCNotificationCenter:sharedNotificationCenter():postNotification(GuideConfig.GuideLayerRemoved)
  end
  
  --handle next guide
	--self:removeFromParentAndCleanup(true)
end 
