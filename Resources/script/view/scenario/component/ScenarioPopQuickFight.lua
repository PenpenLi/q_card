require("view.scenario.component.AutoFightDropItem")
ScenarioPopQuickFight = class("ScenarioPopQuickFight",BaseView)

function ScenarioPopQuickFight:ctor(stages)
  self._stages = stages
  self:setNodeEventEnabled(true)
  self:setTouchEnabled(true)
  self:addTouchEventListener(
    function(event, x, y)
      return true
    end,false, -128, true)
    
    
	local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("popGuaji","CCNode")
  pkg:addProperty("nodeHookTicket","CCNode")
  pkg:addProperty("inputBg","CCScale9Sprite")
  pkg:addProperty("spriteBg","CCScale9Sprite")
  pkg:addProperty("resultLabel","CCLabelTTF")
  pkg:addProperty("labelProgress","CCLabelTTF")
  pkg:addProperty("labelHookTicketCount","CCLabelTTF")
  pkg:addProperty("label_times","CCLabelTTF")
  pkg:addProperty("btnStartHood","CCMenuItemImage")
  pkg:addProperty("btnStart","CCMenuItemImage")
  pkg:addProperty("btnCancleHook","CCMenuItemImage")
  pkg:addProperty("spriteEliteHookTip","CCSprite")
  pkg:addProperty("spriteNormalHookTip","CCSprite")
  pkg:addProperty("vipIcon","CCSprite")
  pkg:addProperty("counticon","CCSprite")
  
  
  pkg:addProperty("label_tickes_times","CCLabelTTF")
  pkg:addProperty("label_vip_times","CCLabelTTF")
  pkg:addProperty("labelHookVipCount","CCLabelTTF")
  
  
  
  pkg:addFunc("startGuajiHandler",ScenarioPopQuickFight.startHandler)
  pkg:addFunc("canleHandler",ScenarioPopQuickFight.canleHandler)
  pkg:addFunc("canleNoCloseHandler",ScenarioPopQuickFight.canleNoCloseHandler)
  
  pkg:addFunc("onMaxHandler",ScenarioPopQuickFight.onMaxHandler)
  
  local layer,owner = ccbHelper.load("ScenarioPopGuaji.ccbi","ScenarioPopCCB","CCLayer",pkg)
  self:addChild(layer)
  
  self.label_times:setString(_tr("times:"))
  self.label_tickes_times:setString(_tr("times:"))
  self.label_vip_times:setString(_tr("times:"))

  self:setNodeEventEnabled(true)
  
  if GameData:Instance():getLanguageType() == LanguageType.JPN then
    self.label_vip_times:setVisible(false)
    self.labelHookVipCount:setVisible(false)
    self.vipIcon:setVisible(false)
    
    local offsetY = 18
    self.counticon:setPositionY(self.counticon:getPositionY() - offsetY)
    self.label_tickes_times:setPositionY(self.label_tickes_times:getPositionY() - offsetY)
    self.labelHookTicketCount:setPositionY(self.labelHookTicketCount:getPositionY() - offsetY) 
  end
  
  self.spriteNormalHookTip:setVisible(false)
  self.spriteEliteHookTip:setVisible(false)
  
  self._stage = self._stages[1]
  self._isEliteHook = self._stage:getIsElite()
  if self._isEliteHook == false then
     assert(#self._stages == 1,"normal stage must hook alone")
     self.spriteNormalHookTip:setVisible(true)
     self.spriteEliteHookTip:setVisible(false)
  else
     self.popGuaji:setVisible(false)
     --self.nodeHookTicket:setPositionX(-50)
     self.spriteEliteHookTip:setVisible(true)
     self.spriteNormalHookTip:setVisible(false)
     self.spriteEliteHookTip:setVisible(true)
  end
  

  self.nodeHookTicket:setVisible(true)
  local hookTickets = GameData:Instance():getCurrentPackage():getPropsByConfigId(StageConfig.HookTicketConfigId)
  local ticketCount = 0
  if hookTickets ~= nil then
    ticketCount = hookTickets:getCount()
  end
  self.labelHookTicketCount:setString(ticketCount.."")
  
  local vipFreeCount = Scenario:Instance():getVipFreeQuickFightCount()
  self.labelHookVipCount:setString(vipFreeCount.."")

  local function editBoxTextEventHandle(strEventName,pSender)
      local num = toint(self.inputCount:getText())
      local maxCount = self:onMaxTimesToday()
      
      if strEventName == "began" then
      elseif strEventName == "changed" then
      elseif strEventName == "ended" then
      elseif strEventName == "return" then
        if num > maxCount then 
          num = maxCount
        elseif num < 0 then 
          num = 0
        end
      end
      self.inputCount:setText(string.format("%d",num))
  end
  
  self.inputCount = UIHelper.convertBgToEditBox(self.inputBg,"1",22,nil,nil,16)
  self.inputCount:setMaxLength(6)
  self.inputCount:setInputMode(kEditBoxInputModeNumeric)
  self.inputCount:setText("1")
  self.inputCount:setTouchPriority(-128)
  self.inputCount:registerScriptEditBoxHandler(editBoxTextEventHandle)
  
  if self._isEliteHook == true then
    self.labelProgress:setString("")
    self.labelProgress:setPositionY(self.labelProgress:getPositionY()+30)
  else
    self.labelProgress:setString(_tr("sao_dang_times_%{count}", {count=self:onMaxTimesToday()}))
  end
  
  self.btnCancleHook:setVisible(false)
  
  
  self.resultLabelContainer = display.newNode()
  self.resultLabelContainer:setContentSize(CCSizeMake(570,0))
  self.resultLabelArray = {}
  --self.resultLabelContainer:setAnchorPoint(ccp(0,1))
  
  self._scrollView = CCScrollView:create()
  self._scrollView:setViewSize(CCSizeMake(485,145))
  self._scrollView:setDirection(kCCScrollViewDirectionVertical)
  self._scrollView:setClippingToBounds(true)
  self._scrollView:setBounceable(true)
  self.resultLabel:getParent():addChild(self._scrollView)
  self._scrollView:setPosition(self.resultLabel:getPositionX(),self.resultLabel:getPositionY())
  self.resultLabel:getParent():removeChild(self.resultLabel,false)
  self.resultLabel:setPosition(0,0)
  --self._scrollView:setContainer(self.resultLabel)
  self._scrollView:setContainer(self.resultLabelContainer)
  self._resultString = ""
  self._scrollView:setTouchPriority(-128)
end

function ScenarioPopQuickFight:onEnter()
  Shop:instance():setView(self)
end

function ScenarioPopQuickFight:onExit()
  self:stopTimeCountDown()
  --guide for mining
  self:getParent():setPopQuickFightView(nil)
  Shop:instance():setView(nil)
  _executeNewBird()
end

function ScenarioPopQuickFight:updateView()
  self:onMaxHandler()
end

function ScenarioPopQuickFight:stopTimeCountDown()
  if self.scheduler ~= nil then
     CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduler)
     self.scheduler = nil
  end
end

function ScenarioPopQuickFight:reset()
  if self._isEliteHook == true then
    self.labelProgress:setString("")
    self.btnStart:setVisible(true)
    self.btnCancleHook:setVisible(false)
  else
    print("normal hook finished")
    self:onMaxHandler()
    self.labelProgress:setString(_tr("sao_dang_times_%{count}", {count=self:onMaxTimesToday()}))
    self.btnStart:setVisible(true)
    self.btnCancleHook:setVisible(false)
    self.popGuaji:setVisible(true)
  end
end

function ScenarioPopQuickFight:startOnHook(timesCount)
   print("startOnHook")
   self.spriteNormalHookTip:setVisible(false)
   self.spriteEliteHookTip:setVisible(false)
   self._enabledAutoNext = true
   self.countsTotal =  timesCount
   self.countsIdx = 0
   self._resultString = ""
   self.resultLabelArray = {}
   self.resultLabelContainer:removeAllChildrenWithCleanup()
   self:onhookOnceResult()
end

function ScenarioPopQuickFight:onhookOnceResult(clientSync)
   
   if clientSync ~= nil then
       --self.spriteBg:setVisible(false)
       self:parseClientSync(clientSync)
   end
   
   if self._enabledAutoNext == false then
      return
   end
   
   if self._isEliteHook == true then
      self.labelProgress:setString(_tr("sao_dang_elite")..self._stage:getStageChapterId().."-"..self._stage:getCheckPointIndex())
   else
      self.labelProgress:setString(_tr("sao_dang_being")..self.countsIdx.."/"..self.countsTotal)
   end
   
   local vipFreeCount = Scenario:Instance():getVipFreeQuickFightCount()
   if clientSync ~= nil then
    self.labelHookVipCount:setString(math.max(vipFreeCount - 1,0).."")
   end
   
   if vipFreeCount <= 0 and clientSync ~= nil then
     local hookTickets = GameData:Instance():getCurrentPackage():getPropsByConfigId(StageConfig.HookTicketConfigId)
     local ticketCount = 0
     if hookTickets ~= nil then
        ticketCount = hookTickets:getCount() - 1
     end
     self.labelHookTicketCount:setString(ticketCount.."")
   end


   local req_hood_once = function()
      self.countsIdx = self.countsIdx + 1
      print("self.countsIdx:",self.countsIdx)
      if self.countsIdx <= self.countsTotal then
          print("reqQuickFight")
          self._lastCoin = GameData:Instance():getCurrentPlayer():getCoin()
          self._lastExp =  GameData:Instance():getCurrentPlayer():getExperience()
          self._lastMoney = GameData:Instance():getCurrentPlayer():getMoney()
          self._lastJiangHun = GameData:Instance():getCurrentPlayer():getCardSoul()
          
          if self._isEliteHook == true then
             self._stage = self._stages[self.countsIdx]
          else
             self._stage = self._stages[1]
          end
          self:getDelegate():reqQuickFight(self._stage,1)
      else
          self:reset()
      end
      self:stopTimeCountDown()
   end
   
   print("onhookOnceResult")
   
   self.scheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(req_hood_once, 1.0, false)
end

function ScenarioPopQuickFight:parseClientSync(client_sync)
 
 if client_sync ~= nil then
       local getcoin = client_sync.common.coin - self._lastCoin
       local getexp = client_sync.common.experience - self._lastExp
       
       local drops = {}
       --local dropItemView = nil
       --local idx = 0
        --dropCards
        if client_sync.card ~= nil then
        for k,val in pairs(client_sync.card) do
          echo("drop card = : action=", val.action, val.object.id,val.object.config_id)
          if val.action == "Add" then
--             dropItemView = DropItemView.new(val.object.config_id,1)
--             table.insert(drops,dropItemView)
             table.insert(drops,{ configId = val.object.config_id,count = 1})
          elseif val.action == "Remove" then
          elseif val.action == "Update" then
          end
        end
      end
      
      --  drop money
      local money = client_sync.common.money + client_sync.common.point - self._lastMoney 
      if money > 0 then
--         dropItemView = DropItemView.new(5,money)
--         table.insert(drops,dropItemView)
        table.insert(drops,{ configId = 5,count = money})
      end
      
      -- drop jianghun
      local jianghun = client_sync.common.jianghun - self._lastJiangHun
      if jianghun > 0 then
        table.insert(drops,{ configId = 20,count = jianghun})
      end
      
      --  dropItems
      if client_sync.item ~= nil then
        for k,val in pairs(client_sync.item) do
          echo("drop item: action=", val.action, val.object.id, val.object.type_id, val.object.count)
          if val.action == "Add" then
--             dropItemView = DropItemView.new(val.object.type_id,val.object.count)
--             table.insert(drops,dropItemView)
            table.insert(drops,{ configId = val.object.type_id,count = val.object.count})
          elseif val.action == "Remove" then
             
          elseif val.action == "Update" then
             local item_in_bag = GameData:Instance():getCurrentPackage():getPropsById(val.object.id)
             local currentCount = 0
             if item_in_bag ~= nil then
               currentCount = item_in_bag:getCount()
             end
            
             local newGetCount = val.object.count - currentCount
             echo("getCount:",newGetCount,item_in_bag)
             if newGetCount > 0 then
--               dropItemView = DropItemView.new(val.object.type_id,newGetCount)
--               table.insert(drops,dropItemView)
                table.insert(drops,{ configId = val.object.type_id,count = newGetCount})
             end
          end
        end
      end
      
      --  dropEquipments
      if client_sync.equipment ~= nil then
        for k,val in pairs(client_sync.equipment) do
          echo("drop equipment: action=", val.action, val.object.id, val.object.config_id)
          if val.action == "Add" then
--             dropItemView = DropItemView.new(val.object.config_id,1)
--             table.insert(drops,dropItemView)
            table.insert(drops,{ configId = val.object.config_id,count = 1})
          elseif val.action == "Remove" then
            
          elseif val.action == "Update" then
             
          end
        end
      end
       
       local listItem = AutoFightDropItem.new(self._stage,drops,self.countsIdx,getcoin,getexp)
       listItem:setAnchorPoint(ccp(0,0))
       self.resultLabelContainer:addChild(listItem)
       for key, result_label in pairs(self.resultLabelArray) do
           result_label:setPositionY(result_label:getPositionY() + listItem:getContentSize().height)
       end
       table.insert(self.resultLabelArray,listItem)
       self.resultLabelContainer:setContentSize(CCSizeMake(self.resultLabelContainer:getContentSize().width,self.resultLabelContainer:getContentSize().height + listItem:getContentSize().height))
       self._scrollView:setContentSize(self.resultLabelContainer:getContentSize())
   end
end


function ScenarioPopQuickFight:startHandler()
  local pop = nil
  local vipLevelId = GameData:Instance():getCurrentPlayer():getVipLevelId()
  assert(AllConfig.vipinitdata[vipLevelId] ~= nil,"VipInitData Error")
  local freeMaxCountToday = AllConfig.vipinitdata[vipLevelId].quick_stage
  local freeCountToday = 0
  if Scenario:Instance():getQuickFightCount() < freeMaxCountToday then
     freeCountToday = freeMaxCountToday - Scenario:Instance():getQuickFightCount()
  end
  
  if freeCountToday <= 0 then
     local prop = GameData:Instance():getCurrentPackage():getPropsByConfigId(StageConfig.HookTicketConfigId)
     if prop ~= nil and prop:getCount() > 0 then
        
     else
        --pop = PopupView:createTextPopup(_tr("sao_dang_disable"),nil,true)
        
        local countToBuy = 10
        local shopItem = Shop:instance():getShopItemByConfigId(ShopCurViewType.DianCang, ShopItem.Ticket)
        assert(shopItem ~= nil,"config not found")
        local price = shopItem:getDiscountPrice() * countToBuy
        
        --_tr("扫荡券不足，是否花费"..price.."元宝购买"..countToBuy.."张扫荡券？")
        local alertStr = _tr("ask_buy_hook_ticket%{money}and%{count}",{money = price,count = countToBuy})
        pop = PopupView:createTextPopup(alertStr,function()
          
          if GameData:Instance():getCurrentPlayer():getMoney() < price then
            GameData:Instance():notifyForPoorMoney()
          else
            Shop:instance():reqBuyItem(shopItem,10)
          end
          
        end)
        GameData:Instance():getCurrentScene():addChildView(pop)
        return
     end
  end
    
  local stageCost = 0
  local currentSpirit = GameData:Instance():getCurrentPlayer():getSpirit()
  local maxCount = 0
 
  --start normal hook
  if self._isEliteHook == false then
    
    --[[stageCost = self._stage:getCost()
    maxCount = math.floor(currentSpirit/stageCost)
    
    local count = tonumber(self.inputCount:getText())
    if GameData:Instance():getCurrentPlayer():isVipState() == false then
       local ticketItem = GameData:Instance():getCurrentPackage():getPropsByConfigId(StageConfig.HookTicketConfigId)
       local ticketCount = 0
       if ticketItem ~= nil then
        ticketCount = ticketItem:getCount()
       end
       count = math.min(count,ticketCount)
    end
    
    if count > 0 then
      if count > maxCount then
        pop = PopupView:createTextPopup(_tr("sao_dang_max_times_%{count}", {count=maxCount}), function() return   end,true)
        self:getDelegate():getScene():addChildView(pop,100)
        return
      end
      self.popGuaji:setVisible(false)
      self:startOnHook(count)
      self.btnStart:setVisible(false)
      self.btnCancleHook:setVisible(true)
    else
      --pop = PopupView:createTextPopup(_tr("sao_dang_onetime_at_least"), function() return   end ,true)
      --self:getDelegate():getScene():addChildView(pop,100)
		  Common.CommonFastBuySpirit()
    end
    ]]
    
    local count = tonumber(self.inputCount:getText())
    count = math.min(count,self:onMaxTimesToday())
    if count > 0 then
      self.popGuaji:setVisible(false)
      self:startOnHook(count)
      self.btnStart:setVisible(false)
      self.btnCancleHook:setVisible(true)
    else
      Common.CommonFastBuySpirit()
    end
    
  else  --start elite hook
    local chapter = Scenario:Instance():getChapterById(self._stage:getStageChapterId())
    self._stages = Scenario:Instance():getEliteStagesToHookByChapter(chapter)
    if #self._stages <= 0 then
      local stagesToBuy = Scenario:Instance():getEliteStagesToBuyByChapter(chapter)
      if #stagesToBuy <= 0 then
        pop = PopupView:createTextPopup(_tr("no_elite_to_saodang"),nil,true)
        GameData:Instance():getCurrentScene():addChildView(pop)
        return
      else
        local totalCost = 0
        for key, stageToBuy in pairs(stagesToBuy) do
          local cost = stageToBuy:getBuyPriceNow()
          totalCost = totalCost + cost
        end
        
        --local strTip = "是否花费"..totalCost.."元宝购买当前章节"..#stagesToBuy.."个关卡各1次？"
        local strTip = _tr("cost_%{money}_buy_%{count}_chapter_elite",{money = totalCost,count = #stagesToBuy})
        pop = PopupView:createTextPopup(strTip,function()
           if GameData:Instance():getCurrentPlayer():getMoney() < totalCost then
            GameData:Instance():notifyForPoorMoney()
           else
            Scenario:Instance():reqForcibleBuyMultiStages(stagesToBuy)
           end
        end)
        GameData:Instance():getCurrentScene():addChildView(pop)
        return
      end
    else
      self._stage = self._stages[1]
    end
    stageCost = self._stage:getCost()
    maxCount = math.floor(currentSpirit/stageCost)
    if stageCost <= 0 then
      maxCount = #self._stages
    end
    if currentSpirit < self._stage:getCost() then
      --pop = PopupView:createTextPopup(_tr("no_spirite_to_saodang"),nil,true)
      --GameData:Instance():getCurrentScene():addChildView(pop)
	    Common.CommonFastBuySpirit()
      return
    end
    
    local count = math.min(#self._stages,maxCount)

    local hookTickets = GameData:Instance():getCurrentPackage():getPropsByConfigId(StageConfig.HookTicketConfigId)
    local ticketCount = 0
    if hookTickets ~= nil then
      ticketCount = hookTickets:getCount()
    end
    count = math.min(count,ticketCount + freeCountToday)
    
    if count > 0 then
      self.popGuaji:setVisible(false)
      self:startOnHook(count)
      self.btnStart:setVisible(false)
      self.btnCancleHook:setVisible(true)
    else
      pop = PopupView:createTextPopup(_tr("no_spirite_or_times_to_saodang"), function() return   end ,true)
      self:getDelegate():getScene():addChildView(pop,100)
    end
  end
end

function ScenarioPopQuickFight:onMaxTimesToday()
  return Scenario:Instance():getMaxQuickFightCountToday(self._stage)
end



-- max times to on-hook
function ScenarioPopQuickFight:onMaxHandler()
  self.inputCount:setText(self:onMaxTimesToday())
  local hookTickets = GameData:Instance():getCurrentPackage():getPropsByConfigId(StageConfig.HookTicketConfigId)
  local ticketCount = 0
  if hookTickets ~= nil then
    ticketCount = hookTickets:getCount()
  end
  self.labelHookTicketCount:setString(ticketCount.."")
  
  local vipFreeCount = Scenario:Instance():getVipFreeQuickFightCount()
  self.labelHookVipCount:setString(vipFreeCount.."")
end

function ScenarioPopQuickFight:canleHandler()
  self:getParent().map:updateMapFlags()
  self:getParent():refreshChapterTip()
  self:removeFromParentAndCleanup(true)
end


function ScenarioPopQuickFight:canleNoCloseHandler()
  self._enabledAutoNext = false
  self:onMaxHandler()
  self:stopTimeCountDown()
  self.btnStart:setVisible(true)
  self.btnCancleHook:setVisible(false)
  
  if self._isEliteHook == true then
    self.popGuaji:setVisible(false)
    self.labelProgress:setString("")
  else
    self.popGuaji:setVisible(true)
    self.labelProgress:setString(_tr("sao_dang_times_%{count}", {count=self:onMaxTimesToday()}))
  end
end

return ScenarioPopQuickFight