require("view.talent.TalentMapView")

TalentView = class("TalentView",ViewWithEave)
function TalentView:ctor(delegate)
  TalentView.super.ctor(self)
  self:setDelegate(delegate)
  self:setNodeEventEnabled(true)
end

function TalentView:onEnter()
  TalentView.super:onEnter()
  self:getEaveView().btnHelp:setVisible(true)
  display.addSpriteFramesWithFile("talent/talent_guild_buttons.plist", "talent/talent_guild_buttons.png")
  display.addSpriteFramesWithFile("talent/talent_talent_all.plist", "talent/talent_talent_all.png")

  self:setTitleTextureName("#title_talent_name.png")
  local menuArray = { 
    {"#btn_talent_gongji1.png","#btn_talent_gongji2.png",CCSizeMake(198,100)},
    {"#btn_talent_fangyu1.png","#btn_talent_fangyu2.png",CCSizeMake(198,100)},
    {"#btn_talent_tongyong1.png","#btn_talent_tongyong2.png",CCSizeMake(165,100)}
  }
  self:setMenuArray(menuArray,{
	  image="#talent_point.png",
	  position = ccp(0,0)
  })

	self:setScrollBgVisible(false)

	local function checkJumpTalentPage2(self,talents,isDone)
		for n,v in pairs(talents) do
			local item = GameData:Instance():getCurrentPlayer():getTalentItemsByIDAlways(n)
			assert(item.type>=1 and item.type<=3,"config data error, talent type not support, id is "..n)
			self:getTabMenu():setItemSelectedByIndex(item.type)
			self:tabControlOnClick(item.type - 1)
			self._isChangedTab=true
			return
		end
	end

	local function checkJumpTalentPage(self,list,bankinfo)
			if(bankinfo[1] == Talent.BankStatus.BANK_LEVELUP_DONE) then
				return true
			end	
			
			checkJumpTalentPage2(self,list,true)	
	end

	--Talent.Instance().SetEvent("TALENT_LEVELUP_END",checkJumpTalentPage,self)
	Talent.Instance().SetEvent("TALENT_LEVELUP",checkJumpTalentPage2,self)
	Talent.Instance().SetEvent("TALENT_LEVELUP_CAN_END",checkJumpTalentPage,self)
	Talent.Instance().SetEvent("TALENT_GETPOINT", function(self,msg)
		Toast:showIconNum("+"..msg.point,msg.double_point and "#talent_crit.png" or "#talent_talent.png",nil,nil, ccp(display.cx, display.height*0.4))
	end, self)

	Talent.Instance():RecallTimer(true)
	Talent.Instance().SetEvent("TALENT_LEVELUP",nil,self)

	if( not self._isChangedTab) then
		self:tabControlOnClick(0)
	end

	local backMenu = self:getEaveView().btnBack
	--local normalSprite = display.newSprite("#tianfu_shouji1.png")
	--backMenu:setNormalImage(normalSprite)
	--local selectedImage = display.newSprite("#tianfu_shouji2.png")
	--backMenu:setSelectedImage(selectedImage)
	backMenu:setVisible(true)
	local disabledImage = display.newSprite("#tianfu_shouji3.png")
	backMenu:setDisabledImage(disabledImage)
	backMenu:setEnabled(false)

	local menu = backMenu:getParent()
	local menuItemPos = ccp(backMenu:getPosition())
	menuItemPos = menu:convertToWorldSpace(menuItemPos)
	backMenu:setPosition(ccp(0,0))
	local topnode = menu:getParent()
	menuItemPos = topnode:convertToNodeSpace(menuItemPos)

	local node = display.newNode()
	node:setPosition(menuItemPos)
	topnode:addChild(node)

	menu:removeFromParent()
	menu:setPosition(ccp(0,10))
	node:addChild(menu)
	


	local label = tolua.cast( CCLabelTTF:create("test","Courier-Bold",18), "CCLabelTTF" )
	label:setColor(ccc3(255,255,255))
	node:addChild(label,5)

	label:setPosition(ccp(0,-25))

	Talent.Instance().SetEvent("TALENT_PRODUCE_CHANGED",function(self,count)

		label:setString(""..count)
		if(count>0) then
			node:stopAllActions()
			local count,_,isProduceFull,isBankFull = Talent.getCurrentProduct()
			local normalSprite ,selectedImage
			if(isProduceFull) then
				normalSprite = display.newSprite("#tianfu_shouji11.png")
				selectedImage = display.newSprite("#tianfu_shouji22.png")
			else
				normalSprite = display.newSprite("#tianfu_shouji1.png")
				selectedImage = display.newSprite("#tianfu_shouji2.png")
			end
			backMenu:setNormalImage(normalSprite)
			backMenu:setSelectedImage(selectedImage)


			local strength = 5.0
			local times = 2
			local array = CCArray:create()
			local s_duration = 0.6/(times * 2)
			for i = 1, times do
			array:addObject(CCScaleTo:create(s_duration,1.15,1.10))
			array:addObject(CCScaleTo:create(s_duration,1.0,1.0))
			end
			array:addObject(CCDelayTime:create(3.0))
			local action = CCSequence:create(array)
			node:runAction(CCRepeatForever:create(action))

			backMenu:setEnabled(true)
		else
			node:stopAllActions()

			backMenu:setEnabled(false)
		end
	end,self)

end

function TalentView:onBackHandler()
	net.sendMessage(PbMsgId.TalentGetPointC2S)
end


function TalentView:resetButtonFlag()
	local ret = TalentMapView.IsAnyOneCanUpdate()
	self._isUpdating =next(ret.Updating) 
	self:setMenuItemTip(1,not(self._isUpdating) and ret[1]) 
	self:setMenuItemTip(2,not(self._isUpdating) and ret[2]) 
	self:setMenuItemTip(3,not(self._isUpdating) and ret[3])	
end
function TalentView:isUpdating()
	return self._isUpdating
end
function TalentView:setCurrentView(CurrentView)
	self._CurrentView = CurrentView
end

function TalentView:getCurrentView()
	return self._CurrentView
end

function TalentView:popupBlind()
  local pop = SystemBlindPopView.new()
  pop:setDelegate(self:getDelegate())
  self:addChild(pop)
end

function TalentView:popupAwardCode()
  local pop = SystemAwardCodeView.new()
  --pop:setDelegate(self:getDelegate())
  self:addChild(pop)
end

function TalentView:tabControlOnClick(idx,showFastFinish)
  
  local showPop = function()
    if showFastFinish == true then
      _showLoading()
      self:performWithDelay(function()
         _hideLoading()
        --self:getCurrentView():checkCurrentData()
        self:showFastFinishedAlert()
      end,1.1)
    end
  end


  if (self._index == idx) then
    showPop()
    return
  end

  self._index = idx
  if self:getCurrentView() ~= nil then
     self:getCurrentView():removeFromParentAndCleanup(true)
     self:setCurrentView(nil)
  end
  
  local canvasContentSize = self:getCanvasContentSize()
  canvasContentSize = tolua.cast(canvasContentSize,"CCSize")
  --canvasContentSize.height  = canvasContentSize.height  - 300
 -- if (canvasContentSize.height ~= 610) then
	--canvasContentSize.height = 610
 -- end
  local talentView = TalentMapView.new(idx,canvasContentSize,self)
  self._talentView = talentView
  self:getListContainer():addChild(talentView)
  self:setCurrentView(talentView)
  
  self:getTabMenu():setItemSelectedByIndex(idx + 1)
  
  showPop()
end
function TalentView:getCurrentTalentMapView()
	return  self._talentView 
end

function TalentView:showFastFinishedAlert()
  print("showFastFinishedAlert")
  local currentView = self:getCurrentView()
  if currentView ~= nil then
    print("currentView ~= nil")
     if currentView.nodes ~= nil then
      print("currentView.nodes ~= nil")
      for key, itemView in pairs(currentView.nodes) do
         print("isUpdating:",itemView:IsUpdating())
         if itemView:IsUpdating() then
           itemView:onLevelUpFastFinish()
           break
         end
      end
     end
  end
end

function TalentView:updateView()
  self:tabControlOnClick(self._index)
end

function TalentView:onExit()
	--Talent.Instance().SetEvent("TALENT_LEVELUP",nil,self)
	Talent.Instance().SetEvent("TALENT_LEVELUP_CAN_END",nil,self)
	Talent.Instance().SetEvent("TALENT_PRODUCE_CHANGED",nil,self)
	Talent.Instance().SetEvent("TALENT_GETPOINT", nil, self)

  self:getListContainer():removeAllChildrenWithCleanup(true)
  display.removeSpriteFramesWithFile("talent/talent_talent_all.plist", "talent/talent_talent_all.png")
  display.removeSpriteFramesWithFile("talent/talent_guild_buttons.plist", "talent/talent_guild_buttons.png")
  TalentView.super:onExit()
end

function TalentView:onHelpHandler()
	local help = self:getCurrentView():createHelpView()
	self:getDelegate():getScene():addChild(help, 1000)
end

--function TalentView:onBackHandler()
  --local controller = ControllerFactory:Instance():create(ControllerType.HOME_CONTROLLER)
  --controller:enter()
--end

return TalentView