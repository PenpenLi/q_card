require("view.component.MessageBox")

TalentMapViewItem = class("TalentMapViewItem")


function TalentMapViewItem:ctor(comps,config,parentSize,parent)
	self.parentSize = parentSize
	self.parentNode = parent
	self.GlobalConfig = config
	self.compents=comps
	self.left_time = 0
	self.timerID = nil
	self.toPath={}
	self.fromLine={}
	self:setCanUpdate(false)
	self._btn_Enable=true

	self.timerEvents={} --计时器事件，用于更新对话框等
	local button = comps.comp_btn

	local _ismoved=false
	button:addHandleOfControlEvent(
		function(obj,event)
			if not _ismoved then
				self:onLevelUpClick(event)
			end
		end
	,CCControlEventTouchUpInside)

	button:addHandleOfControlEvent(
		function(obj,event)
			 _ismoved=false
		end
	,CCControlEventTouchDown)

	--button:addHandleOfControlEvent(
	--	function(obj,event)
	--		 _ismoved = true
	--	end
	--,CCControlEventTouchDragInside)

	comps.comp_hit:registerScriptTapHandler(function() self:onHitClick() end)

	local parent=self
	self.data=setmetatable(
	{
	}
	,{
	__index=function(self,key)
		if (key == "clear_cd_cost")	then
			if(parent.LeveledConfig) then
				if (parent.left_time) then --safe for next level time is zero
					local left_time = parent.left_time <= parent.LeveledConfig.talent_next_level_time and parent.left_time or parent.LeveledConfig.talent_next_level_time

					return left_time==0 and 0 or math.ceil(parent.LeveleupConfig.clear_cd_cost /parent.LeveledConfig.talent_next_level_time * left_time )
				else
					return parent.LeveleupConfig.clear_cd_cost
				end
			else
				return 0
			end 
		end
	end
	})

end
function TalentMapViewItem:getCompHit()
	return self.compents.comp_hit
end
function TalentMapViewItem:getCompBtn()
	return self.compents.comp_btn
end
function TalentMapViewItem:getID()
	return self.LeveledConfig.id
end
function TalentMapViewItem:getRootID()
	return self.GlobalConfig.ID
end
function TalentMapViewItem:onHitClick()
	local str = string.format(Consts.Strings.TALENT_LEVELUP_TIME_HIT,
			self.LeveledSkill.skill_name,
			self.LeveledConfig.level,
			self.GlobalConfig.max_level,
			GameData:Instance():formatSkillDesc(self.LeveledSkill,false,true),
			Clock.format(self.LeveleupConfig.talent_next_level_time)
		)

	local display_pos = ccp(0,0)
	local p = self.compents.comp_hit:convertToWorldSpace(display_pos)
	if (p.x<260) then
		display_pos.x = 120
	else
		display_pos.x = -20
	end

	local allowdirection
 	if (p.y>220) then
		display_pos.y = 0
		if(display_pos.x >0 ) then
			allowdirection = TipDir.LeftLeftUp
		else
			allowdirection = TipDir.RightRightUp
		end

	else
		display_pos.y = 120
		if(display_pos.x >0 ) then
			allowdirection = TipDir.LeftLeftDown
		else
			allowdirection = TipDir.RightRightDown
		end
	end
	TipsInfo:showStringTip(str,CCSizeMake(220, 0), nil, self.compents.comp_hit, display_pos, nil, false, allowdirection, true)
end
function TalentMapViewItem:IsUpdating()
	return self._isLeveluping
end
function TalentMapViewItem:getAbsoluteButtonPostion(offsetX,offsetY)
	local size = self.compents.comp_btn:getPreferredSize()
	return self.compents.comp_btn:convertToWorldSpace(ccp(offsetX+size.width/2, offsetY+size.height/2))
end
function  TalentMapViewItem:playLevelupButtonAnimation(id)
	local anim,offsetX,offsetY,duration = _res(id)
	local pos = self:getAbsoluteButtonPostion(offsetX,offsetY)
	pos = self.compents.comp_topNode:convertToNodeSpace(pos)
	anim:setPosition(pos)
	self.compents.comp_topNode:addChild(anim)
	anim:getAnimation():play("default")
end
function TalentMapViewItem:onLevelUpClick()
	echo("TalentMapViewItem:onLevelUpClick()")
	if self:isCanUpdate() then
		self:onLevelupRequirements(true)
	else
		-- hit
		if (self:isEnabled()) then
			self:onLevelupRequirements()
			--self:setCanUpdate(true)
		elseif self._isLeveluping then
			self:onLevelUpFastFinish()
		else
			self:onLevelupHitInformation()
		end
	end
end
function TalentMapViewItem:onLevelUpFastFinish()
	local skillcurrent =  self.LeveledSkill
	local isenoughMoney = self.data.clear_cd_cost <=  GameData:Instance():getCurrentPlayer():getMoney()
	MessageBox.showTalentFinishRightNow(
	{
		lbl_time_hit={init=MessageBox.Help.bindStringTTFFormat()}, 
		lbl_money_hit={init=MessageBox.Help.bindStringTTFFormat()}, 
		--lbl_txt = {init=MessageBox.Help.bindStringTTF("立即完成天赋升级")},
		lbl_levelmin ={init=MessageBox.Help.bindStringTTF(self.LeveledConfig.level)}, 
		lbl_levelmax ={init=MessageBox.Help.bindStringTTF(self.LeveledConfigNext.level)}, 
		lbl_timer = {init = MessageBox.Help.bindStringTTF(Clock.format(self.left_time)) }, 
		lbl_money ={init=MessageBox.Help.bindStringTTF(self.data.clear_cd_cost, not(isenoughMoney) and ccc3(255,0,0))}, 
		lbl_skillname= {init=MessageBox.Help.bindStringBMF(skillcurrent.skill_name)},
		spr_icon = {init = MessageBox.Help.bindImageSprite("#" .. self.icon_Normal)}
	},
	{
		event_MB_OK=function(pop)
			pop:close()
			local data = PbRegist.pack(PbMsgId.TalentClearCDC2S, {type="TALENT_SKILL",talent=self.LeveledConfig.id})
			net.sendMessage(PbMsgId.TalentClearCDC2S, data)
		end,
		event_NOMB_LEAVE =function(pop)
			self.timerEvents["onLevelUpFastFinish"] = nil
		end,
		event_NOMB_ENTER=function(pop)
			pop:setEnableOKButton(isenoughMoney)			
			self.timerEvents["onLevelUpFastFinish"]	 = function(self,timer)
				if(timer) then
					pop._owner.lbl_timer:setString(Clock.format(timer) )
				end

				if(not timer or timer==0) then
					pop:setEnableOKButton(false)
					--pop:close()
					--pop =nil
				end
			end
		end
	})
end

function TalentMapViewItem:netevent_Levelup(talentid,time)
    --self:setEnabled(false,true)
	if(self.LeveledConfig.timer==-1) then
		self:_setCurrentLevelConfig(self:getID(),true)
	end
	self:LevelUp(talentid~=self:getID(),time) -- wait sync

	--net.sendMessage(PbMsgId.TalentDataQueryC2S)
end

function TalentMapViewItem:onLevelupHitInformation()
	self:onLevelupRequirements(false)
end

function TalentMapViewItem:isMaxLevel()
	return 	not (self.LeveledConfigNext) and true or false
end
function TalentMapViewItem:onLevelupRequirements(canUpdate)
	if (self:isMaxLevel()) then
		Toast:showString(GameData:Instance():getCurrentScene(), Consts.Strings.TALENT_TOP_LEVEL, ccp(display.cx, display.cy))
		return
	end
	local condition,requireTalentCfg = self:checkCondition_talent()
	local require_level = requireTalentCfg and requireTalentCfg.level or 0
	local require_name = requireTalentCfg and requireTalentCfg.skill_item.skill_name or "TABLE_ERROR"
	
	local itemcfg = self.LeveleupConfig
	local levelconfig =  self.LeveledConfig
	local skillcurrent =  self.LeveledSkill
	local skillnext = self.LeveledSkillNext

	--echo("TalentMapViewItem::onLevelupRequirements")
	MessageBox.showTalentUpgrade({
		lbl_pay={init=MessageBox.Help.bindStringTTF(levelconfig.cost,not(condition.coin) and ccc3(255,0,0) )},
		lbl_cost={init=MessageBox.Help.bindStringTTF(levelconfig.talent_point, not (condition.talent_point) and ccc3(255,0,0))},--levelconfig.talent_point
		lbl_lv={init=MessageBox.Help.bindStringTTF(levelconfig.level.."/"..self.GlobalConfig.max_level)},
		lbf_skillname = {init=MessageBox.Help.bindStringBMF(skillcurrent.skill_name)},
		lbl_desc_base = {init=MessageBox.Help.bindTTF2RichText({color=0xffffff,size={600,0}},
			{value=levelconfig.player_level,color=condition.player_level and 0xf32d or 0xff0000 },
			{value=self.parentNode:getViewTypeLocalName()},{value=levelconfig.total_talent_point,color=condition.total_talent_point and 0xf32d or 0xff0000 },
			function(default)
			if(self.LeveledConfig.condition_talent==0) then
				return ""
			end
			local ret= MessageBox.Help.getRichTextCfgString("DLGITEM_TALENT_UPGRADE_DESCBASE_CONDITION",default,{value=require_name,color=0xfff000},{value=require_level,color=(condition.condition_talent and 0xf32d or 0xff0000) })
			return ret.."</>"
			end			
		)},

		lbl_desc_time = {init=MessageBox.Help.bindStringTTFFormat()},
		lbl_desc_pay = {init=MessageBox.Help.bindStringTTFFormat()},
		lbl_desc_cost = {init=MessageBox.Help.bindStringTTFFormat()},
		node_show_require = {init = function(s,o) o:setVisible( self.LeveledConfig.condition_talent~=0 ) end},
		lbl_attack={init=MessageBox.Help.bindStringTTF(skillcurrent.d1)},
		lbl_attack_add={init=MessageBox.Help.bindStringTTF(skillnext and skillnext.d1 or skillcurrent.d1)},
		spr_skill = {init = MessageBox.Help.bindImageSprite("#" .. self.icon_Normal)},
		lbl_time ={init = MessageBox.Help.bindStringTTF(Clock.format(itemcfg.talent_next_level_time))},
		node_info={init = function(s,o)
			local str = GameData:formatSkillDesc(self.LeveledSkill,self.LeveledSkillNext,true)
			local label = RichLabel:create(str, "Courier-Bold",20,CCSizeMake(400, 0),false,false)
			o:addChild(label)
			end
		}		
	},	
	{
		event_NOMB_ENTER=function(self)
			self:setEnableOKButton(condition.all_condition)
		end,
		event_MB_OK=function(pop)
			pop:close()
			local canLevelUp = true
      --if self.parentNode.nodes ~= nil then
         --[[for key, itemView in pairs(self.parentNode.nodes) do
           if itemView:IsUpdating() == true then
             canLevelUp = false
             itemView:onLevelUpFastFinish()
             break
           end
         end]]
      --end
      
      local ret = TalentMapView.IsAnyOneCanUpdate()
      dump(ret)
      local isAnyOneUpdateing = next(ret.Updating) 
      if isAnyOneUpdateing then
         canLevelUp = false
         
         local lvingId = ret.Updating[1][1]
         print("lving info:",lvingId)
         if AllConfig.talent[lvingId] ~= nil then
           local talentType = AllConfig.talent[lvingId].type
           
           local talentView = self.parentNode.parentNode
           if talentView ~= nil then
            talentView:tabControlOnClick(talentType - 1,true)
           end
           
           
--           if self.parentNode.nodes ~= nil then
--            for key, itemView in pairs(self.parentNode.nodes) do
--               if itemView:IsUpdating() == true then
--                 canLevelUp = false
--                 itemView:onLevelUpFastFinish()
--                 break
--               end
--            end
--           end
         end 
         
         
         --table.insert(ret.Updating,{v.LeveledConfig.id,v.LeveledConfig.timer,Clock.Instance():DiffWithServerTime(v.LeveledConfig.timer)})
         
      end
      
      
      if canLevelUp == true then  --not self.parentNode:isUpdating()
       
       
       --condition
       
        local condition,cfg,node = self:checkRequiredTalentLevel()
--  local ret= {
--    player_level= self:checkPlayerLevel(),
--    total_talent_point = self:checkTalentPointRequire(),
--    condition_talent = condition,
--    coin = GameData:Instance():getCurrentPlayer():getCoin() >= self.LeveledConfig.cost,
--    isMaxlevel = self:isMaxLevel(),
--    talent_point = GameData:Instance():getCurrentPlayer():getTalentBankPoints()>= self.LeveledConfig.talent_point
--  }
      
       
        local needMorePoints = 0
        if GameData:Instance():getCurrentPlayer():getTalentBankPoints()>= self.LeveledConfig.talent_point then
         
        else
          needMorePoints = self.LeveledConfig.talent_point - GameData:Instance():getCurrentPlayer():getTalentBankPoints()
        end
        
        local needPointMoney = (needMorePoints/self.LeveledConfig.talent_point)*AllConfig.talent[self.LeveledConfig.id].point_cost
        needPointMoney = math.ceil(needPointMoney)
        
        print("self.LeveledConfig.talent_point:",self.LeveledConfig.talent_point, GameData:Instance():getCurrentPlayer():getTalentBankPoints())
         
         
        local needMoreCoin = 0
        if GameData:Instance():getCurrentPlayer():getCoin() >= self.LeveledConfig.cost then
         
        else
          needMoreCoin = self.LeveledConfig.cost - GameData:Instance():getCurrentPlayer():getCoin()
        end
        local needCoinMoney = (needMoreCoin/self.LeveledConfig.cost)*AllConfig.talent[self.LeveledConfig.id].coin_cost
        needCoinMoney = math.ceil(needCoinMoney)
        
        local isCostMoney = needMoreCoin > 0 or needMorePoints > 0
        
        local allMoneyCost = needCoinMoney + needPointMoney
        
        local sendReqToServer = function()
          self.LeveledConfig.timer = -1
          local data = PbRegist.pack(PbMsgId.TalentLevelUpC2S, {talent = self.LeveledConfig.id,cost = isCostMoney})
          net.sendMessage(PbMsgId.TalentLevelUpC2S, data) 
        end
        
        local showFastBuyPop = function(tip)
          local pop = PopupView:createTextPopup(tip, function()
          
            if allMoneyCost > GameData:Instance():getCurrentPlayer():getMoney() then
              GameData:Instance():notifyForPoorMoney()
            else
              sendReqToServer()
            end
          end)
          GameData:Instance():getCurrentScene():addChildView(pop)
        end

        if needMorePoints > 0 and needMoreCoin == 0 then
          showFastBuyPop(_tr("tip_buy_talent_point%{cost}",{cost = allMoneyCost}))
        elseif needMorePoints == 0 and needMoreCoin > 0 then
          showFastBuyPop(_tr("tip_buy_coin%{cost}",{cost = allMoneyCost}))
        elseif needMorePoints > 0 and needMoreCoin > 0 then
          showFastBuyPop(_tr("tip_buy_coin_and_talent%{cost}",{cost = allMoneyCost}))
        else
          sendReqToServer()
        end
      end
			
		end
	})

end

function TalentMapViewItem:onCleanup()
	self:_stopUpdateScheduler()
	local comps=self.compents
	comps.comp_hit:unregisterScriptTapHandler()
	comps.comp_btn:removeHandleOfControlEvent(CCControlEventTouchUpInside)
end

function TalentMapViewItem:levelupDone(hasLeveldup,id)
	--self.compents.comp_timer:setString(_tr("almost finish"))
	if(hasLeveldup) then
		self:netevent_levelupDone(id) --self:getID(),
	else
		assert(self.LeveledConfigNext,"not exist the next level but still upgrade")
		net.sendMessage(PbMsgId.TalentDataQueryC2S)
	end
end
function TalentMapViewItem:netevent_levelupDone(id)
	self:_stopUpdateScheduler(true,true)
	if(id==self.LeveledConfig.id) then
		--去除新增点数影响
		local currentRequireTalentTotalPoints = self:getRequireTalentTotalPoints()
 		self.parentNode:setSumTalentPoint( self.parentNode:getSumTalentPoint()+ currentRequireTalentTotalPoints)
		id = self.LeveledConfigNext.id
	elseif (id == self.LeveledConfig.pre.id or id==nil) then
		id = self.LeveledConfig.id
		self:setCurrentLevel(self.LeveledConfig.pre.id)
	else
		assert(false,"not support, pls check logic")
	end
	if(self.LeveledConfig.talent_root == 3022) then --号令天下
		CCNotificationCenter:sharedNotificationCenter():postNotification(EventType.PLAYER_UPDATE)
	end

	for k,v in pairs(self.toPath) do
		local b2,b3 = v[1]:setEnabledIf(true)
	end

	self:setCurrentLevel(id)

	local openedGroup={}
	local count=0
	for k,v in pairs(self.toPath) do
		local  ret,b2 =v[1]:checkEnableCondtion() 
		if (ret) then
			count = count+1
			openedGroup[count]=v[1]
		end
	end
	self.parentNode:ShowLevelupAction(self,openedGroup)
end


function TalentMapViewItem:ui_levelupCancel()
	assert(not self._isLeveluping , "should not in leveluping")
end
function TalentMapViewItem:_stopUpdateScheduler(isFinish,hasLeveldup)
	self.left_time = 0
	for k,v in pairs(self.timerEvents) do
		v(self,self.left_time)
	end
	if(self._anim_Talent_Update) then
		self._anim_Talent_Update:removeFromParentAndCleanup(true)
		self._anim_Talent_Update = nil
	end
	if(hasLeveldup) then
		self.compents.comp_timer:setString(_tr("almost finish"))
	else
		self:setTimerVisible()
	end
	self.timerEvents = {}
	self._isLeveluping=nil
	if self.timerID~=nil then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.timerID)
		self.timerID= nil
		if (self._processBar~=nil) then
			self._processBar:removeFromParent()
		end
		--if (isFinish) then
		--	self:levelupDone(hasLeveldup)
		--	return
		--end
	end
	self:ui_levelupCancel()
end

function TalentMapViewItem:LevelCancel(b)
	self:_stopUpdateScheduler()
end
function TalentMapViewItem:LevelUp(hasLevedup,time)
	self:setCanUpdate(false)
	self:setEnabled(false,true)

	local timer = self.LeveledConfig.timer or time

	if(self._isLeveluping) then
		if(timer and timer>0 and self.end_time<timer) then
			self.need_time = self.need_time  + (timer - self.end_time)
		end
		return
	end
	self._isLeveluping = true
	self.need_time = self.LeveleupConfig.talent_next_level_time
	self.end_time = timer and timer>0 and timer or (Clock:Instance():getCurServerUtcTime()+self.need_time)

	local function getLeftPercentage()
		local left = Clock:Instance():DiffWithServerTime(self.end_time)
		left = left>0 and left or 0
		self.left_time = left
		return (1- (left/self.need_time))*100
	end
	local percent = getLeftPercentage()

	local comp_timer = self.compents.comp_timer
 	local scheduler =  CCDirector:sharedDirector():getScheduler()
	local spr_frame =  display.newSpriteFrame(self.icon_Normal)
	local spr= CCSprite:createWithSpriteFrame(spr_frame)
  local left = CCProgressTimer:create(spr)
	self._processBar = left 

  left:setType( kCCProgressTimerTypeRadial )
	left:setPercentage( percent )
	local size = self.compents.comp_btn:getPreferredSize()
  left:setPosition(ccp(size.width/2, size.height/2))
	left:setScaleY(1.05)
  self.compents.comp_btn:addChild(left)

	self:setTimerVisible(true)
	comp_timer:setString(Clock.format(self.left_time) )


	local anim,offsetX,offsetY,duration = _res(5020197)
	comp_timer:getParent():addChild(anim)
	anim:setPosition(ccp(150,100))
	anim:getAnimation():play("default")
	self._anim_Talent_Update = anim

	local function update(isfinish)
		if( self.LeveledConfig.timer~= self.end_time ) then
			self.end_time =  self.LeveledConfig.timer==0 and Clock:Instance():getCurServerUtcTime() or self.LeveledConfig.timer 
		end

		local percent = getLeftPercentage()

		left:setPercentage(percent)
		comp_timer:setString(Clock.format(self.left_time))

		for k,v in pairs(self.timerEvents) do
			v(self, self.left_time,percent)
		end
		if self.left_time ==0 then
			self:_stopUpdateScheduler(true,true) --isfinish and hasLevedup or nil)
		end

	end

	if(self.left_time==0) then
		update(true)
	elseif(not self.timerID) then
		self.timerID = scheduler:scheduleScriptFunc(update,1,false)
	else
		-- assert
	end
end


function TalentMapViewItem:addPath(toNode,lineNode)
	self.toPath[toNode:getRootID()]={
		toNode,
		lineNode
	}

end
function TalentMapViewItem:addPathLine(fromid,lineNode)
	self.fromLine[fromid] = lineNode
	self:setLineEnable(fromid,false)
end

function  TalentMapViewItem:setLineEnable(lineIDOrNode,enable)
	local lineNode
	if (type(lineIDOrNode) =="number") then
		lineNode = self.fromLine[lineIDOrNode]
	else
		lineNode = lineIDOrNode
	end
	if (lineNode ==nil) then
		for n,v in pairs(self.fromLine) do
			UI_SetEnable(v,enable)
		end
	else
		UI_SetEnable(lineNode,enable)
	end
end
function  TalentMapViewItem:isLineEnable(lineIDOrNode)
	local lineNode
	if (type(lineIDOrNode) =="number") then
		lineNode = self.fromLine[lineID]
	else
		lineNode = lineIDOrNode
	end
	return UI_IsEnable(lineNode)
end

function TalentMapViewItem:onDisableClick()
	printf("disable click")
end
function TalentMapViewItem:fromLineCheck()
	return true
end
function TalentMapViewItem:isEnabled()
	return self._btn_Enable and true
end
function TalentMapViewItem:setEnabled(b,isForce)
	b= b and true 

	--if (isForce or b~= self:isEnabled()) then
		UI_SetEnable(self.compents.comp_background,b)
		UI_SetEnable(self.frame_normal,b)
		UI_SetEnable(self.frame_highlight,b)
	--end
	self._btn_Enable=b 
end

function  TalentMapViewItem:setCanUpdate(b)
	b=	b and true or false
	self.compents.comp_newInfo:setVisible(b)
	return b
end
function TalentMapViewItem:checkCanUpdate()
	local condition,requireTalentCfg = self:checkCondition_talent()
	return self:setCanUpdate( not(self.parentNode:isUpdating()) and condition.all_condition and (not self._isLeveluping) )
end
function TalentMapViewItem:isCanUpdate()
	return  self.compents.comp_newInfo:isVisible()
end
function TalentMapViewItem:getCurrentLevel()
	return  self.LeveledConfig and self.LeveledConfig.level or 0
end
function TalentMapViewItem:_setCurrentLevelConfig(talent_id,isForce)
	if (not isForce and self.LeveledConfig and self.LeveledConfig.id ==talent_id) then
		return true
	end

	--local requirePoints = self:getRequireTalentTotalPoints()
	local newitem =  GameData:Instance():getCurrentPlayer():getTalentItemsByIDAlways(talent_id)
	assert(newitem,"talent item not exist " .. talent_id)
 	self.LeveledConfig = newitem	
	self.LeveledConfigNext = newitem.next	 
 	self.LeveleupConfig = self.LeveledConfig.levelup_time
 	self.LeveledSkill = self.LeveledConfig.skill_item
	self.LeveledSkillNext = self.LeveledConfigNext and self.LeveledConfigNext.skill_item

	--self.parentNode:setSumTalentPoint( self.parentNode:getSumTalentPoint()+ requirePoints)
end

function TalentMapViewItem:setCurrentLevel(talent_id)
	if(self:_setCurrentLevelConfig(talent_id) ) then
		return true
	end
	local comp = self.compents
	comp.comp_level:setString(self.LeveledConfig.level)
	comp.comp_name:setString(self.LeveledSkill.skill_name)

	MessageBox.Help.changeSpriteImage(comp.comp_background, "#talent_juanzou_"..self.LeveledConfig.background..".png")

	local button = comp.comp_btn
	local frameConfig= {
		["btn_normal"]=self.GlobalConfig.btn_normal  or "",	 --[[or self.LeveledConfig.btn_normal]]
		["btn_highlight"]=self.GlobalConfig.btn_highlight  or "",		 --[[or self.LeveledConfig.btn_highlight]]
		["btn_disable"]=self.GlobalConfig.btn_disable or ""		 --[[or self.LeveledConfig.btn_disable]]
	}

	if (string.len(frameConfig.btn_normal) == 0) then
		frameConfig.btn_normal ="talent_icons_level_".. self:getRootID() ..".png"
	end

	self.icon_Normal = frameConfig.btn_normal
	--////////////////////////
	--printf(frameConfig.btn_normal)
	local frame =CCScale9Sprite:createWithSpriteFrame(display.newSpriteFrame(frameConfig.btn_normal))
	self.icon_Normal_Size = frame:getOriginalSize()
	button:setBackgroundSpriteForState(frame,CCControlStateNormal)
	self.frame_normal =  frame 

	if string.len(frameConfig.btn_highlight) == 0 then
		frameConfig.btn_highlight = frameConfig.btn_normal
	end	
	frame = CCScale9Sprite:createWithSpriteFrame( display.newSpriteFrame(frameConfig.btn_highlight))
	button:setBackgroundSpriteForState(frame,CCControlStateHighlighted)
	self.frame_highlight =  frame

	self:setEnabled(self:isEnabled())
	self:setTimerVisible()

end
function TalentMapViewItem:checkEnableCondtion()
	local condition = self:checkCondition_talent()
	return condition.condition_enable and not(self:isEnabled()),condition.condition_enable
end
function TalentMapViewItem:setEnabledIf(isPreCheck)
	local ret,buttonEnable = self:checkEnableCondtion()
	self:setEnabled(buttonEnable)
	self:setLineEnable(nil,buttonEnable)
	return ret
end

function TalentMapViewItem:init()
	if (not self.timerID) then
		self:setTimerVisible()
	end
	self:setEnabledIf()
end
function TalentMapViewItem:ShowLevelupDone()
	--self:init()
	Toast:showStringWithEndAction(GameData:Instance():getCurrentScene(),
									Consts.Strings.TALENT_HIT_LEVELUP_DONE,
									ccp(display.cx, display.cy),
									handler(Talent.Instance(),Talent.RecallTimer),
									self.LeveledSkill.skill_name,
									self.LeveledConfig.level)

end
function TalentMapViewItem:checkRequiredTalentLevel()
	local talentCfg = self:getRequireTalent()
	if talentCfg == nil then
		return true,nil,nil
	end

	local requireNode = self.parentNode:getSubNodeItem(talentCfg.talent_root)

	assert(requireNode,"the talnet is not on the map ".. talentCfg.id)
	
	return requireNode:getCurrentLevel()>=talentCfg.level ,talentCfg, requireNode
end

function TalentMapViewItem:checkPlayerLevel()
	return GameData:Instance():getCurrentPlayer():getLevel() >= self:getRequirePlayerLevel() 
end
function TalentMapViewItem:checkTalentPointRequire()
	 return self.parentNode:getSumTalentPoint()>= self:getRequireTalentTotalPoints()
end

function TalentMapViewItem:checkCondition_talent()
	local condition,cfg,node = self:checkRequiredTalentLevel()
--	local ret= {
--		player_level= self:checkPlayerLevel(),
--		total_talent_point = self:checkTalentPointRequire(),
--		condition_talent = condition,
--		coin = GameData:Instance():getCurrentPlayer():getCoin() >= self.LeveledConfig.cost,
--		isMaxlevel = self:isMaxLevel(),
--		talent_point = GameData:Instance():getCurrentPlayer():getTalentBankPoints()>= self.LeveledConfig.talent_point
--	}
	
	--only mind level
	local ret= {
    player_level= self:checkPlayerLevel(),
    total_talent_point = self:checkTalentPointRequire(),
    condition_talent = condition,
    coin = GameData:Instance():getCurrentPlayer():getCoin() >= self.LeveledConfig.cost,
    isMaxlevel = self:isMaxLevel(),
    talent_point = GameData:Instance():getCurrentPlayer():getTalentBankPoints()>= self.LeveledConfig.talent_point
  }
	ret.condition_enable = ret.player_level and ret.total_talent_point	and ret.condition_talent 
	--ret.all_condition = ret.condition_enable and ret.coin and  ret.talent_point and not(ret.isMaxlevel)
	ret.all_condition = ret.total_talent_point and ret.condition_talent and ret.player_level and not(ret.isMaxlevel)
	return ret,cfg,node
end

function TalentMapViewItem:getRequireTalent()
	return AllConfig.talentRootMap[self.LeveledConfig.condition_talent]
end
function TalentMapViewItem:getRequireTalentID()
	return self.LeveledConfig.condition_talent
end
function TalentMapViewItem:getSumTalentPoints()
	return self.LeveledConfig and self.LeveledConfig.sum_talent_point_for_pre or 0
end
function TalentMapViewItem:getRequireTalentTotalPoints()
	return self.LeveledConfig and  self.LeveledConfig.total_talent_point  or 0
end
function TalentMapViewItem:getRequirePlayerLevel()
	return self.LeveledConfig.player_level
end

function TalentMapViewItem:setTimerVisible(b)
	local comp = self.compents
	b = b or false
	comp.comp_timer:setVisible(b)
	--comp.comp_level_sp:setVisible(not b)
end


return TalentMapViewItem