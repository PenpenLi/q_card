require("view.quest.QuestAwardDetailView")
QuestListItem = class("QuestListItem",BaseView)
function QuestListItem:ctor(data,idx)
  
  self._idx = idx

	local pkg = ccbRegisterPkg.new(self)
	pkg:addProperty("isSelectedHightLight","CCScale9Sprite")
	pkg:addProperty("listNormalBoader","CCScale9Sprite")
	pkg:addProperty("labelName","CCLabelTTF")
	pkg:addProperty("labelRequirement","CCLabelTTF")
	pkg:addProperty("labelCoin","CCLabelTTF")
	pkg:addProperty("labelExp","CCLabelTTF")
	pkg:addProperty("labelMoney","CCLabelTTF")
	pkg:addProperty("labelSkipCost","CCLabelTTF")
	pkg:addProperty("label_taskCondition","CCLabelTTF")
	pkg:addProperty("label_taskBonus","CCLabelTTF")
	pkg:addProperty("nodeMoney","CCNode")
	pkg:addProperty("nodeMoneyAward","CCNode")
	pkg:addProperty("btnGetAward","CCMenuItemImage")
	pkg:addProperty("btnGiveUp","CCMenuItemImage")
	pkg:addProperty("btnAccept","CCMenuItemImage")
	pkg:addProperty("btnMoneySkip","CCMenuItemImage")
	pkg:addProperty("spriteInProgress","CCSprite")
	pkg:addProperty("spriteFinished","CCSprite")
	pkg:addProperty("spriteOpenIcon","CCSprite")
	pkg:addFunc("onGetAwardHandler",QuestListItem.onGetAwardHandler)
	pkg:addFunc("onGiveUpHandler",QuestListItem.onGiveUpHandler)
	pkg:addFunc("onAcceptHandler",QuestListItem.onAcceptHandler)
	pkg:addFunc("onMoneySkipHandler",QuestListItem.onMoneySkipHandler)
	
	
	local layer,owner = ccbHelper.load("QuestListItem.ccbi","QuestListItemCCB","CCLayer",pkg)
	self:addChild(layer)
	
	self._ccbLayer = layer
	
	self.label_taskCondition:setString(_tr("task_condition"))
	self.label_taskBonus:setString(_tr("task_bonus"))
	
	self._isOpen = false
	
	self.isSelectedHightLight:setVisible(false)
	--self.spriteInProgress:setVisible(false)
	self.btnGetAward:setVisible(false)
	self.btnGiveUp:setVisible(false)
	self.btnAccept:setVisible(false)
	self.spriteFinished:setVisible(false)
	self.btnMoneySkip:setVisible(false)
	self.nodeMoney:setVisible(false)
	self:setData(data)

	self:initTouchEvent()
end

------
--  Getter & Setter for
--      QuestListItem._ContentSize 
-----
function QuestListItem:setContentSize(ContentSize)
	self._ContentSize = ContentSize
end

function QuestListItem:getContentSize()
	if self._isOpen == true then
		 return CCSizeMake(self.listNormalBoader:getContentSize().width,self.listNormalBoader:getContentSize().height + self._detailView.spriteBg:getContentSize().height)
	else
		 return self.listNormalBoader:getContentSize()
	end
end

------
--  Getter & Setter for
--      QuestListItem._ListDelegate 
-----
function QuestListItem:setListDelegate(ListDelegate)
	self._ListDelegate = ListDelegate
end

function QuestListItem:getListDelegate()
	return self._ListDelegate
end

function QuestListItem:setData(Data)
	self._Data = Data
	self._isOpen = false
	if Data ~= nil and Data ~= "" then
		 local taskTypeStr = ""
		 if Data:getTaskType() == 1 then
				taskTypeStr = _tr("main_line")
		 elseif Data:getTaskType() == 2 then
				taskTypeStr = _tr("sub_line")
		 elseif Data:getTaskType() == 3 then
				taskTypeStr = _tr("nor_line")
				self.btnMoneySkip:setVisible(true)
				self.nodeMoney:setVisible(true)
				local forcibleCount = Quest:Instance():getForcibleDoneDailyTaskCount()
				local needMoney = 0
				for key, var in pairs(AllConfig.cost) do
					 if var.type == 14 then
							--print(var.cost)
							if var.min_count == forcibleCount + 1 then
								 needMoney = var.cost
								 break
							end
					 end
				end
				
				self._forcibleDoneCost = needMoney
				
				if needMoney <= 0 then
					 self.nodeMoney:setVisible(false)
				else
					 self.labelSkipCost:setString(needMoney.."")
				end
		 end
		 
		 local taskName = ""
		 if Data:getName() ~= nil and Data:getProgressStr() ~= nil then	      	      
				taskName = taskTypeStr..Data:getName()..Data:getProgressStr()
		 end 
		 self.labelName:setString(taskName)
		 
		 --add linkline
		 local fontSize = self.labelName:getFontSize()
		 local tmpLabel1 = CCLabelTTF:create(taskTypeStr, "Courier-Bold", fontSize)
		 local tmpLabel2 = CCLabelTTF:create(Data:getName(), "Courier-Bold", fontSize)
		 local tmpWidth = tmpLabel2:getContentSize().width
		 local tmpStr= ""
		 for i=1, math.ceil(tmpWidth/fontSize) do 
			tmpStr = tmpStr.."__"
		 end 
		 local linkLabel = CCLabelTTF:create(tmpStr, "Courier-Bold", fontSize)
		 linkLabel:setColor(ccc3(69, 20, 1))
		 linkLabel:setPosition(tmpLabel1:getContentSize().width+linkLabel:getContentSize().width/2, fontSize/2)
		 self.labelName:addChild(linkLabel)

		 local linkSize = self.labelName:getContentSize() 
		 local px = self.labelName:getContentSize().width + 10
		 local py = -3

		if self._gotoIcon == nil then
			self._gotoIcon = display.newSprite("#mission-qianwang.png")
			self._gotoIcon:setAnchorPoint(ccp(0,0))
			self.labelName:addChild(self._gotoIcon)
		end  
		self._gotoIcon:setPosition(ccp(px, py))
		linkSize.width = linkSize.width + self._gotoIcon:getContentSize().width
     
		if GameData:Instance():getLanguageType() == LanguageType.JPN then 
			self._gotoIcon:setVisible(false)
		else 
			px = px + self._gotoIcon:getContentSize().width + 10
		end 

		 if self._arrowIcon == nil then 
				self._arrowIcon = display.newSprite("#mission-qianwang1.png")
				self._arrowIcon:setAnchorPoint(ccp(0,0))
				self.labelName:addChild(self._arrowIcon)
				linkSize.width = linkSize.width + self._arrowIcon:getContentSize().width
		 end 
		 self._arrowIcon:setPosition(ccp(px, py))
		 self._arrowIcon:stopAllActions()
		 local pos = ccp(self._arrowIcon:getPositionX(),self._arrowIcon:getPositionY())
		 local anim = CCSequence:createWithTwoActions(CCMoveTo:create(0.2, ccp(pos.x + 8,pos.y)), CCMoveTo:create(0.4, pos))
		 self._arrowIcon:runAction(CCRepeatForever:create(anim))
		 _registNewBirdComponent(114101 + self._idx,self.btnAccept)
		 _registNewBirdComponent(114201 + self._idx,self._gotoIcon)
		 _registNewBirdComponent(114301 + self._idx,self.btnGetAward)
		 
		 self.labelName:setContentSize(linkSize)


		 local taskRequirement = ""
		 if Data:getDesciption() ~= nil then
				taskRequirement = Data:getDesciption()
		 end
		 self.labelRequirement:setString(taskRequirement)
		 
		 local coin = "0"
		 if Data:getCoin() ~= nil then
				 coin = Data:getCoin()..""
		 end
		 self.labelCoin:setString(coin)
		 
		 local exp = "0"
		 if Data:getExp() ~= nil then
				exp = Data:getExp()..""
		 end
		 self.labelExp:setString(exp)
		 
		 local money= "0"
		 if Data:getMoney() ~= nil then
				money = Data:getMoney()..""
		 end
		 self.labelMoney:setString(money)
		 
		 if money == "0" then
				self.nodeMoneyAward:setVisible(false)
		 else
				self.nodeMoneyAward:setVisible(true)
		 end
		 
		 local progressFinished = false
		 if Data:getTaskConditionstates() ~= nil then
				 progressFinished = Data:checkFinished()
				 if Data:checkFinished() == true then
						self.btnGetAward:setVisible(true)
						self.spriteInProgress:setVisible(false)
						self.btnGiveUp:setVisible(false)
						self.btnAccept:setVisible(false)
				 end
		 end
		 
		 local taskState = Data:getTaskState()
		 if taskState ~= nil then
				self.btnGetAward:setVisible(false)
				self.spriteInProgress:setVisible(false)
				self.btnGiveUp:setVisible(false)
				self.btnAccept:setVisible(false)
				self.spriteInProgress:setVisible(false)
				self.spriteFinished:setVisible(false)
				if taskState == "Show" then
					 self.btnAccept:setVisible(true)
					 self.btnMoneySkip:setVisible(false)
					 self.nodeMoney:setVisible(false)
				elseif taskState == "Accept" then
					 if progressFinished == true then
							self.btnGetAward:setVisible(true)
							self.btnMoneySkip:setVisible(false)
							self.nodeMoney:setVisible(false)
					 else
							self.btnGiveUp:setVisible(true)
					 end
				elseif taskState == "Finished" then
						echo("task finished")
						self.spriteFinished:setVisible(true)
						self.btnMoneySkip:setVisible(false)
						self.nodeMoney:setVisible(false)
				elseif taskState == "Drop" then
						echo("task droped")
				else
				end
		 end
		 
		 local dropDatas = self:getData():getDropItemDatas()
		 if #dropDatas < 1 then
			 self.spriteOpenIcon:setVisible(false)
		 else
			 self.spriteOpenIcon:setVisible(true)
		 end
	end
end

function QuestListItem:onMoneySkipHandler()
  local needMoney = self._forcibleDoneCost or 0
  if GameData:Instance():getCurrentPlayer():getMoney() < needMoney then
    GameData:Instance():notifyForPoorMoney()
  else
    self:getDelegate():reqForcibleDoneDailyTask(self:getData():getDailyTaskId())
  end
end

function QuestListItem:onGiveUpHandler()
	echo("onGiveUpHandler")
	_playSnd(SFX_CLICK)
	local pop = PopupView:createTextPopup(_tr("cancel_task?"), function()
			 return  self:getDelegate():dropDailyTask(self:getData():getDailyTaskId())
	end)
	GameData:Instance():getCurrentScene():addChildView(pop,100)
	
end

function QuestListItem:onAcceptHandler()
	echo("onAcceptHandler: dailyTaskId:",self:getData():getDailyTaskId())
	_playSnd(SFX_CLICK)
	self:getDelegate():receiveDailyTask(self:getData():getDailyTaskId())
end

function QuestListItem:onGetAwardHandler()
	echo("onGetAwardHandler")
	_playSnd(SFX_CLICK)
	self:getDelegate():askForTaskAward(self:getData())
end

function QuestListItem:getData()
	return self._Data
end

------
--  Getter & Setter for
--      QuestListItem._IsLastest 
-----
function QuestListItem:setIsLastest(IsLastest)
	self._IsLastest = IsLastest
end

function QuestListItem:getIsLastest()
	return self._IsLastest
end


function QuestListItem:initTouchEvent()
	self:addTouchEventListener(handler(self,self.onTouch))
	self:setTouchEnabled(true)	
end 


function QuestListItem:onTouch(event, x,y)
	if event == "began" then
		local pos = self.labelName:convertToNodeSpace(ccp(x, y))
		local size = self.labelName:getContentSize()
		-- echo("==========pos", pos.x, pos.y, size.width, size.height)
		if pos.x >= 0 and pos.x <= size.width and pos.y >=0 and pos.y <= size.height then 
			local _type, value = self:getData():getJumpTypeValue()
			-- self:gotoViewByType(_type, value)
			GameData:Instance():gotoViewByJumpType(_type, value)
			return true 
		end 
		return false 
	end 
end 

--function QuestListItem:onTouch(event, x,y)
--	if event == "began" then
--	 self._startY = y
--	 return true
--	elseif  event == "ended" then
--		local pos = self.labelName:convertToNodeSpace(ccp(x, y))
--		local size = self.labelName:getContentSize()
--		
--		--local barpos = self.listNormalBoader:convertToNodeSpace(ccp(x, y))
--		--local barsize = self.listNormalBoader:getContentSize()
--		
--		-- echo("==========pos", pos.x, pos.y, size.width, size.height)
--		if pos.x >= 0 and pos.x <= size.width and pos.y >=0 and pos.y <= size.height then 
--			local _type, value = self:getData():getJumpTypeValue()
--			self:gotoViewByType(_type, value)
--	  --[[elseif barpos.x >= 0 and barpos.x <= barsize.width and barpos.y >=0 and barpos.y <= barsize.height then
--	    print("quest bar touched")
--	    local dropDatas = self:getData():getDropItemDatas()
--	    if #dropDatas < 1 then
--	      return
--	    end
--	    
--	    if math.abs(self._startY - y) > 10 then
--	      return
--	    end
--	    
--	    local offset = 0
--	    if self._isOpen == false then
--	       if self._detailView == nil then
--	          self._detailView = self:buildAwardDetails()
--	          self:addChild(self._detailView,0)
--	       end
--	       self._detailView:setVisible(true)
--	       self._ccbLayer:setPositionY(self._detailView.spriteBg:getContentSize().height)
--	       self._isOpen = true
--	       self.spriteOpenIcon:runAction(CCRotateTo:create(0.25, 180))
--	       offset = -self._detailView.spriteBg:getContentSize().height
--	    else
--	       if self._detailView ~= nil then
--	          self._detailView:setVisible(false)
--	       end
--	       self._ccbLayer:setPositionY(0)
--	       self._isOpen = false
--	       self.spriteOpenIcon:runAction(CCRotateTo:create(0.25, 0))
--	       offset = self._detailView.spriteBg:getContentSize().height
--	    end
--	    self:getListDelegate():resortListPos(offset)
--	    if self:getIsLastest() == true then
--	       self:getListDelegate():sortLastest()
--	    end ]]
--		end 
--	end 
--end 

function QuestListItem:gotoViewByType(_type, value)
	echo("===gotoViewByType:", _type, value)

	if _type == -1 then --元宝消费
		if GameData:Instance():checkSystemOpenCondition(15, true) == false then 
      return 
    end   
    local controller = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
    controller:enter(ShopCurViewType.DianCang)

	elseif _type == 1 then --关卡
		if value == -1 then --跳到当前最新关卡
			local stage = Scenario:Instance():getLastNormalStage()
			local controller = ControllerFactory:Instance():create(ControllerType.SCENARIO_CONTROLLER)
			controller:enter()
			controller:gotoStageById(stage:getStageId())			
		else 
			local controller = ControllerFactory:Instance():create(ControllerType.SCENARIO_CONTROLLER)
			controller:enter()
			controller:gotoChapterById(value)
			-- controller:gotoStageById(value,true)
		end 

	elseif _type == 2 then -- 不做任何处理

	elseif _type == 3 then --升级
		local controller = ControllerFactory:Instance():create(ControllerType.BAG_CONTROLLER)
		controller:enter()  

	elseif _type == 4 then --征战
		if GameData:Instance():checkSystemOpenCondition(4, true) == false then 
			return 
		end 
		local controller = ControllerFactory:Instance():create(ControllerType.EXPEDITION_CONTROLLER)
		controller:enter()

	elseif _type == 5 then --抽卡
		local controller = ControllerFactory:Instance():create(ControllerType.LOTTERY_CONTROLLER)
		controller:enter()

	elseif _type == 6 then --典藏
		if GameData:Instance():checkSystemOpenCondition(15, true) == false then 
			return 
		end 	
		local controller = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
		controller:enter(ShopCurViewType.DianCang)

	elseif _type == 7 then --矿场
		if GameData:Instance():checkSystemOpenCondition(3, true) == false then 
			return 
		end 	
		local controller = ControllerFactory:Instance():create(ControllerType.MINING_CONTROLLER)
		controller:enter()
		
	elseif _type == 8 then --集市
		if GameData:Instance():checkSystemOpenCondition(13, true) == false then 
			return 
		end 
		local controller = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
		controller:enter(ShopCurViewType.JiShi)

	elseif _type == 9 then --聚宝盆		
		Activity:instance():entryActView(ActMenu.MONEY_TREE, false)

	elseif _type == 10 then --特惠
		if GameData:Instance():checkSystemOpenCondition(14, true) == false then 
			return 
		end 
		local controller = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
		controller:enter(ShopCurViewType.TeHui)
	end
end 


return QuestListItem