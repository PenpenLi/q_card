require("view.talent.TalentMapViewItem")
require("view.component.MessageBox")

TalentMapView = class("TalentMapView",BaseView)



local namelist={
	[-1] = {"Unknown",Consts.Strings.TABLE_ERROR},
	[0]={"Attack",Consts.Strings.TALENT_ATTACK},
	[1]={"Defense",Consts.Strings.TALENT_DEFENSE},
	[2]={"Common",Consts.Strings.TALENT_COMMON}
}


function TalentMapView:ctor(idx,size,parent)
	TalentMapView.super.ctor(self)

	self.parentNode = parent
	self.sum_talent_point=0
	self._idx = idx
	if(not (namelist[idx])) then
		idx = -1
	end
	self._name = namelist[idx][1]
	self._local_name = string._tran(namelist[idx][2])

	self._size = size
	self.timerEvents={}
	self.data=setmetatable(
	{
		--bank_timer = nil
	}
	,{
	__index=function(self,key)
		if (key == "player_lv")	then 
			return  GameData:Instance():getCurrentPlayer():getLevel()
		elseif (key == "money") then
			return  GameData:Instance():getCurrentPlayer():getMoney()
		elseif (key == "coin") then
			return GameData:Instance():getCurrentPlayer():getCoin()
		elseif(key =="talent_count") then
			return 	GameData:Instance():getCurrentPlayer():getTalentBankPoints()
		elseif(key =="bank_level") then
			return 	GameData:Instance():getCurrentPlayer():getTalentBankLevel()
		elseif (key =="bank_level_cfg") then
			local item = AllConfig.bank_levelup_time[GameData:Instance():getCurrentPlayer():getTalentBankLevel()]
			return item and Object.Extend(item,{coin_cost=item.money_cost}) or nil
		elseif (key =="bank_next_level_cfg") then
			local item = AllConfig.bank_levelup_time[GameData:Instance():getCurrentPlayer():getTalentBankLevel()+1] 
			return item and Object.Extend(item,{coin_cost=item.money_cost}) or nil
		end
	end
	})
end
function TalentMapView.IsAnyOneCanUpdate()
	local sum_talent_point = {}
	local nodes={}
	function checkCondition_talent(self)
		local parent=self.parentNode
		local talentCfg = TalentMapViewItem.getRequireTalent(self)
		local condition =true
		if (talentCfg~= nil ) then
			local requireNode = nodes[talentCfg.talent_root]
			assert(condition,"the talnet is not on the map ".. talentCfg.id)
			condition = TalentMapViewItem.getCurrentLevel(self,requireNode)>=talentCfg.level
		end

		local ret= {
			player_level=  GameData:Instance():getCurrentPlayer():getLevel() >= TalentMapViewItem.getRequirePlayerLevel(self),
			total_talent_point = sum_talent_point[self.LeveledConfig.type]>= TalentMapViewItem.getRequireTalentTotalPoints(self),
			condition_talent = condition,
			coin = GameData:Instance():getCurrentPlayer():getCoin() >= self.LeveledConfig.cost,
			isMaxlevel = TalentMapViewItem.isMaxLevel(self),
			talent_point = GameData:Instance():getCurrentPlayer():getTalentBankPoints()>= self.LeveledConfig.talent_point
		}
		ret.condition_enable = ret.player_level and ret.total_talent_point	and ret.condition_talent 
		ret.all_condition = ret.condition_enable and ret.coin and  ret.talent_point and not(ret.isMaxlevel)
		return ret
	end

	local talentTreeConfig = AllConfig.talentTree
	for n,v in pairs(AllConfig.talentTree) do
		local rootitem = GameData:Instance():getCurrentPlayer():getTalentItemsByRoot(n)
		local id 
		if (rootitem == nil) then
			rootitem = talentTreeConfig[n]
			assert(rootitem,"pls check config with talent ".. n)
			id = rootitem.start_id
		else
			id = rootitem.id
		end
		local item={}
		TalentMapViewItem._setCurrentLevelConfig(item,id)
		nodes[item.LeveledConfig.talent_root] = item 
	end

	for k,v in pairs(nodes) do
		local _sum = sum_talent_point[ v.LeveledConfig.type ] 
		_sum = _sum and _sum or 0

		_sum = _sum + TalentMapViewItem.getSumTalentPoints(v)
		sum_talent_point[ v.LeveledConfig.type ] =_sum
	end		

	local ret={
		Updating={}
	}
	local tmp={}
	for k,v in pairs(nodes) do
		if (not(ret[v.LeveledConfig.type])) then
			local condition = checkCondition_talent(v)
			if (condition.all_condition) then
				ret[v.LeveledConfig.type]=true
				--tmp[v.LeveledConfig.type] = { v.LeveledConfig.id, condition}
			end
		end

		if(v.LeveledConfig.timer~=0) then
			table.insert(ret.Updating,{v.LeveledConfig.id,v.LeveledConfig.timer,Clock.Instance():DiffWithServerTime(v.LeveledConfig.timer)})
		end
	end
	-- print("check talent flag")
	-- dump(tmp)

	return ret

end
function TalentMapView:isUpdating()
	return self.parentNode:isUpdating()
end

function TalentMapView:getViewTypeLocalName()
	return self._local_name
end
function TalentMapView:onEnter()
	local pkg = ccbRegisterPkg.new(self)
	local size = self._size
	local idx = self._idx


	for i=0,2,1 do
		local name = string.lower(namelist[i][1])
		display.removeSpriteFramesWithFile("talent/talent_icons_level_".. name ..".plist", "talent/talent_icons_level_".. name ..".png")
	end

	display.addSpriteFramesWithFile("talent/talent_icons_level_"..string.lower(self._name) ..".plist", "talent/talent_icons_level_"..string.lower(self._name) ..".png")
	display.addSpriteFramesWithFile("talent/talent_line_1.plist","talent/talent_line_1.png")

	local layer, homeOwner = ccbHelper.load("TalentLevelup"..self._name ..".ccbi","TalentLevelup" ,"CCLayer",pkg,true)
	local ccbSize = tolua.cast(layer:getContentSize(),"CCSize")
	ccbSize.height = size.height
	layer:setContentSize(ccbSize)
	homeOwner.rootNode:getParent():setPosition(ccp(0,size.height/2))

	local nodes = {}

	local thisConfig= TalentData.GetTalentConfig()
	local talentItems = GameData:Instance():getCurrentPlayer():getTalentRootItems()

	self.fristNode = nil
	self.secondNode = nil
	local lastfristPos = 9999
	local lastsecondPos =9999
	-- init sub nodes
	executeByTag(homeOwner.rootNode,2000,function(topNode)
		assert(topNode.name and string.sub(topNode.name,1,1) == "#","TalentMapView:ctor::must exist & eque with '#'")
		local key =tonumber(string.sub(topNode.name,2))
		assert(key ,"TalentMapView:ctor::must key exist" .. topNode.name)
		local comp_level_sp =  tolua.cast(topNode:getChildByTag(1002),"CCSprite")
		local comp_level  =  tolua.cast(comp_level_sp:getChildByTag(1002),"CCLabelBMFont")
		local comp_background = tolua.cast(topNode:getChildByTag(999),"CCSprite")

		local cfgitem=thisConfig[key]
		assert(cfgitem ,"TalentMapView:ctor::must talent config item exist" .. key)
		local item = TalentMapViewItem.new({
			comp_background = comp_background,
			comp_btn = tolua.cast(topNode:getChildByTag(1001),"CCControlButton"),
			comp_level_sp = comp_level_sp,
			comp_hit = tolua.cast(topNode:getChildByTag(1003):getChildByTag(1003),"CCMenuItemImage"),
			comp_timer = tolua.cast(topNode:getChildByTag(1004),"CCLabelTTF"),
			comp_level =  comp_level,
			comp_newInfo = tolua.cast(topNode:getChildByTag(1005),"CCSprite"),
			comp_topNode = topNode,
			comp_name = tolua.cast(topNode:getChildByTag(1006),"CCLabelBMFont")
		},cfgitem,self._size,self)

		local pos = {x=topNode:getPositionX(),y= topNode:getPositionY()}

		local current = (4 -pos.y/200)*20 + (pos.x/250) 
		if (current< lastsecondPos) then
			if (current < lastfristPos) then
				lastsecondPos = lastfristPos
				self.secondNode = self.fristNode
				self.fristNode = item
				lastfristPos = current
			else
				self.secondNode = item
				lastsecondPos = current
			end
		end



		nodes[key]= item
		local cfg = talentItems[key]
		local id = cfg and cfg.id or cfgitem.start_id
		item:setCurrentLevel(id)
	end)
	local topNode = homeOwner.rootNode:getChildByTag(1000) 
   
	executeByTag(topNode,1000,function(topNode) -- for lines
		if(topNode.name == nil or #topNode.name==0) then
			return
		end
		local splite_num= string.find(topNode.name,"#",2,true)
		assert(string.sub(topNode.name,1,1) == "#" and splite_num>1 and splite_num<string.len(topNode.name) , "TalentMapView:ctor::must exist & eque with '#' --2")
		local from =tonumber( string.sub(topNode.name,2,splite_num-1))
		local to = tonumber(string.sub(topNode.name,splite_num+1))
		local toNode = nodes[to]
		local fromNode = nodes[from]
		toNode:addPathLine(from,topNode)
		fromNode:addPath(toNode,topNode)
	end)

	local scrollView = CCScrollView:create()
	scrollView:setDirection(kCCScrollViewDirectionHorizontal)
	scrollView:setClippingToBounds(true)
	scrollView:setBounceable(true)
	scrollView:setTouchPriority(-128)
	scrollView:setContentOffset(ccp(0,0)) 

	scrollView:setContentSize(ccbSize)
	scrollView:setContainer(layer)
	size.width = 643
	scrollView:setViewSize(size)
	scrollView:registerScriptHandler(handler(self, self.scrollViewDidScroll),CCScrollView.kScrollViewScroll)

	self._scrollViewMinX =-( ccbSize.width-self._size.width)


	self:addChild(scrollView)
	self._scrollView = scrollView
	self.owner = homeOwner
	self.ccbLayer=layer

	self.nodes = nodes

	--floater
	local owner =	{
		event_talentHit = handler(self,self.event_talentHit),
		event_addTalent = handler(self,self.event_bankLevelup),
		event_idleline  = handler(self,self.event_idleline),
		event_type      = handler(self,self.event_type),
		event_quick     = handler(self,self.event_FishishRightNowConfirm)
	}
	layer  = CCBuilderReaderLoad("TalentFloater.ccbi",CCBProxy:create(),owner)
	self.floatOwner = owner
	self.talentFloater = tolua.cast(layer,"CCLayer")

	self.lbl_talentCount = owner.lbl_talentCount
	layer:setPosition(ccp(10,size.height-60))
	self:addChild(layer)
	self.floatOwner.menu_addTalent = tolua.cast(self.floatOwner.menu_addTalent,"CCMenuItemImage")
	self:setBankLevelupButton()

	owner.nod_timer:setVisible(false)
	owner.lbl_needTime = tolua.cast(owner.lbl_needTime,"CCLabelTTF")
	owner.lbl_needTime:setString(owner.lbl_needTime:getString():format())
	owner.lbl_times = tolua.cast(owner.lbl_times,"CCLabelTTF")
	owner.menu_type = tolua.cast(owner.menu_type,"CCMenuItemImage")
	local sprite = display.newSprite("#talent_rect_"..string.lower(self._name)..".png" )
	owner.menu_type:setNormalImage(sprite)

	owner.lbl_gongjinum = tolua.cast(owner.lbl_gongjinum,"CCLabelTTF")
	owner.lbl_talentHitnum =tolua.cast(owner.lbl_talentHitnum,"CCLabelTTF") 
	owner.lbl_talentHitnum:setString(self.data.talent_count)

	Talent.Instance().SetEvent("BANK_LEVELUP",function(self,bankinfo)
		local ret =self:updateBankLevelUpInfo(bankinfo[2])
		self:checkCurrentData()
		return ret
	end,self)
	Talent.Instance().SetEvent("TALENT_LEVELUP",function(self,talents)
		for id,time in pairs(talents) do
			local item = AllConfig.talentRootMap[id]
			assert(item,"TALENT_LEVELUP: talent item not exist")
			local node = self.nodes[item.talent_root]
			if (node) then
				node:netevent_Levelup(id,time)
			else
				printf("server return an not exist talent( %d ) ", id)
			end
		end

		self:checkCurrentData(true)
	end,self)

	Talent.Instance().SetEvent("TALENT_LEVELUP_CAN_END",TalentMapView.talent_EndOrCan,self)
	Talent.Instance().SetEvent("TALENT_BANK_CHANGED",TalentMapView.checkCurrentData,self)

	self:checkCurrentData()
	Talent:Instance():RecallTimer()
end



function TalentMapView:setBankLevelupButton()
	local spr =display.newSprite("#talent_tianfu_jiasu.png")
	if(self.data.bank_next_level_cfg == nil) then
		UI_SetEnable(spr,false)
	end

	self.floatOwner.menu_addTalent:setNormalImage(spr)
end
function TalentMapView:ShowLevelupAction(levelupNode,openedNodes)
	if (self.parentNode.IsPlayingBankLevelup) then
		self.parentNode.LevelupReplayFunction = Object.FunctionBinder(self.ShowLevelupAction,self,levelupNode,openedNodes)
		return
	else
		self.parentNode.LevelupReplayFunction=nil
	end

	local yield_routine=false
	local function_groups=false
	local scheduler = CCDirector:sharedDirector():getScheduler()

	function delay(n,fun)
 		local co  = coroutine.running()
		local timerID=scheduler:scheduleScriptFunc(function ()
			if (fun) then
				fun(co)
			else
				coroutine.resume(co)
			end 
        end,n,false)
		coroutine.yield()
		scheduler:unscheduleScriptEntry(timerID)
	end

	local ccbLayer = self.ccbLayer
	local homePos  = levelupNode:getAbsoluteButtonPostion(0,0)
	homePos = ccbLayer:convertToNodeSpace(homePos)
	local scrollView = self._scrollView
	local scrollViewSize  = scrollView:getViewSize()

	function _safeValue(v)
		return v>0 and 0 or v
	end
	yield_routine = coroutine.create(function()
		MessageBox.Help.LayerClick(ccbLayer,ccbLayer,nil,function() return true end,-9999,false)

		local curPos = scrollView:getContentOffset()
		local dest = ccp( _safeValue(scrollViewSize.width/2-homePos.x),0 )
		local timer = math.abs((curPos.x - dest.x)*0.002)
		scrollView:setContentOffsetInDuration(dest,timer)
		delay(timer)
			
		levelupNode:playLevelupButtonAnimation(5020187)--5020182
		if(table.getn(openedNodes)>0) then
			delay(0.8)
			for k,v in pairs(openedNodes)do
				local curNodePos  = v:getAbsoluteButtonPostion(0,0)
				curNodePos = ccbLayer:convertToNodeSpace(curNodePos)
				dest =ccp( _safeValue(scrollViewSize.width/2-curNodePos.x),0 )
				curPos = scrollView:getContentOffset()
				timer = math.abs((curPos.x - dest.x)*0.002)
				scrollView:setContentOffsetInDuration(dest,timer)
				delay(timer)

				v:setEnabledIf(true)
				v:playLevelupButtonAnimation(5020188)--5020183
				delay(0.8)

				dest =	ccp( _safeValue(scrollViewSize.width/2-homePos.x),0 )
				curPos = scrollView:getContentOffset()
				timer =math.abs( (curPos.x - dest.x)*0.002 )
				scrollView:setContentOffsetInDuration(dest,timer)
				delay(timer)
			end
		end
		delay(1.2)
		ccbLayer:setTouchEnabled(false)
		MessageBox.Help.LayerClickRemove(ccbLayer)
		levelupNode:ShowLevelupDone()
	end)

	self:checkCurrentData()

	coroutine.resume(yield_routine)
	self.yield_routine = yield_routine
end
function TalentMapView:getSumTalentPoint()
	return self.sum_talent_point
end

function TalentMapView:updateBankLevelUpInfo(bank_level_up_time)
	if (bank_level_up_time and bank_level_up_time~=0) then
		--local timer = Clock:Instance():DiffWithServerTime(bank_level_up_time)
		--if (timer>0)then
		--	self:bankLevelup(timer)
		--end

		self:bankLevelup(bank_level_up_time)
	end

end
function TalentMapView:checkCurrentData(onlyCheckCanUpdate)
	echo("TalentMapView:checkCurrentData")
	if(not onlyCheckCanUpdate) then
		self.floatOwner.lbl_talentHitnum:setString(self.data.talent_count)

		if not (self.floatOwner.nod_timer:isVisible()) then
			self:updateBankLevelUpInfo( GameData:Instance():getCurrentPlayer():getTalentBankInfo().bank_level_up_time )
		end

 		for k,v in pairs(self.nodes) do
			local cfg = GameData:Instance():getCurrentPlayer():getTalentItemsByRoot(k)
			if (cfg ~=nil) then
				if(v:getID() ~= cfg.id) then
					v:setCurrentLevel(cfg.id)
				end
			end
		end

		self.sum_talent_point = 0
		for k,v in pairs(self.nodes) do
			self.sum_talent_point = self.sum_talent_point + v:getSumTalentPoints()
		end

		for k,v in pairs(self.nodes) do
			v:init()
		end

		self.floatOwner.lbl_gongjinum:setString(self.sum_talent_point)
	end

	for k,v in pairs(self.nodes) do
		v:checkCanUpdate()
	end

	self.parentNode:resetButtonFlag(self._idx)
end
function  TalentMapView:getSumTalentPoint()
	return self.sum_talent_point
end
function  TalentMapView:setSumTalentPoint(v)
	self.sum_talent_point = v
end

function TalentMapView:talent_EndOrCan(can_end,bank_status)

	if(bank_status[1] == Talent.BankStatus.BANK_LEVELUP_DONE) then
		if (bank_status[2]) then
			self:bankLevelupDone(bank_status)
		else
			bank_status[1] = Talent.BankStatus.BANK_LEVELUP
			net.sendMessage(PbMsgId.TalentDataQueryC2S)
		end
		return true
	end
	local needupdate
	for n,v in pairs(can_end) do

		local item = AllConfig.talentRootMap[n]
		assert(item,"config error,talent item not exist")
		local node = self.nodes[item.talent_root]
		if(node) then
			can_end[n]=nil
			node:levelupDone(v,n)
			if(v) then
				needupdate=true
			end
		end

	end

	return true
end

function TalentMapView:bankLevelup(bank_level_up_time)

	self:_stopUpdateScheduler(nil,true)

	local left_time = Clock:Instance():DiffWithServerTime(bank_level_up_time)	
	local function update()
		left_time = Clock:Instance():DiffWithServerTime(bank_level_up_time)
		if(left_time <0) then
			left_time=0
			self:_stopUpdateScheduler(true)
		end

		self.floatOwner.lbl_times:setString(Clock.format(left_time) )
		for k,v in pairs(self.timerEvents) do
			v(self,left_time)
		end
	end

	local cfg = self.data.bank_level_cfg 	
	self.floatOwner.nod_timer:setVisible(true)
	if (left_time == nil)  then
		left_time = cfg.next_level_time
	end
	if (left_time<0) then
		left_time=0
	end
	self.floatOwner.lbl_times:setString(Clock.format(left_time) )

	if (left_time>0) then
		self.timerID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(update,1,false)
	end

	return true
end
function TalentMapView:_stopUpdateScheduler(isFinish,onlyStop)
	local  iscleard = false

	if self.timerID ~= nil then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.timerID)
		self.timerID =nil
		iscleard=true
		if(onlyStop) then
			return
		end
	else
		--new add
		--return
	end
	self.floatOwner.nod_timer:setVisible(false)
	self.timerEvents = {}
	if (isFinish) then
		self.left_time = 0
		for k,v in pairs(self.timerEvents) do
			v(self,self.left_time)
		end
	else
		--self:ui_levelupCancel()
	end
end
function TalentMapView:levelupDone(flag)
	--查询
	if(flag) then
		net.sendMessage(PbMsgId.TalentDataQueryC2S)
	end
end
function TalentMapView:getSubNodeItem(talentRootID)
	return 	self.nodes[talentRootID ]
end


function TalentMapView:checkCondition_blank()

	local bankcfg = self.data.bank_level_cfg
	local ret= {
		player_level= self.data.player_lv>= bankcfg.player_lv,
		coin = self.data.coin >= bankcfg.coin_cost
		--total_talent_point = item.LeveledConfig.sum_talent_point_for_pre>= item.LeveledConfig.total_talent_point,
		--condition_talent = self.nodes[ item.LeveledConfig.talent_root ]:getCurrentLevel() >=  AllConfig.talent[item.LeveledConfig.condition_talent].level
	}
	ret.all_condition = ret.player_level and ret.coin
	return ret
end


function TalentMapView:onExit() --onCleanup()
	if (self.timerIDAnimation) then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.timerIDAnimation)
		self.timerIDAnimation=nil
	end
	self:_stopUpdateScheduler(nil,true)
	--tolua.cast(self.floatOwner.menu_all_1,"CCMenu"):setTouchEnabled(false)
	--tolua.cast(self.floatOwner.menu_all_2,"CCMenu"):setTouchEnabled(false)

	Talent.Instance().SetEvent("BANK_LEVELUP",nil,self)
	Talent.Instance().SetEvent("TALENT_LEVELUP",nil,self)
	Talent.Instance().SetEvent("TALENT_LEVELUP_CAN_END",nil,self)
	Talent.Instance().SetEvent("TALENT_BANK_CHANGED",nil,self)

	self.talentFloater = nil
	for k,v in pairs(self.nodes) do
		v:onCleanup()
	end

	display.removeSpriteFramesWithFile("talent/talent_line_1.plist","talent/talent_line_1.png")
	display.removeSpriteFramesWithFile("talent/talent_icons_level_"..string.lower(self._name) ..".plist", "talent/talent_icons_level_"..string.lower(self._name) ..".png")
end

function TalentMapView:createHelpView()
	local obj =self._scrollView
	obj:setContentOffset(ccp(0,0))

  local help = HelpView.new()
  help:addHelpBox(1029,ccp(0,-500),true)
  help:addHelpItem(1030, self.floatOwner.lbl_talentHitnum, ccp(-30,0), ArrowDir.RightDown)
  help:addHelpItem(1031, self.floatOwner.lbl_talentHitnum, ccp(80,0), ArrowDir.LeftDown)
  help:addHelpItem(1032, self.fristNode:getCompHit(), ccp(-15,-5), ArrowDir.LeftUp)
  help:addHelpItem(1033, self.secondNode:getCompBtn(), ccp(-20,-10), ArrowDir.LeftUp)

  return help
end

function TalentMapView:event_idleline()
	if(not self.talentFloater) then
		return
	end

	--TipsInfo:showStringTip("11222333\n12231112",CCSizeMake(260, 480), nil, self.talentFloater, ccp(420, -10), nil, false, TipDir.LeftUp, true)
end

function TalentMapView:event_type()
	if(not self.talentFloater) then
		return
	end

	TipsInfo:showStringTip(string.format(Consts.Strings.TALENT_HIT_ALLOCATION,self:getViewTypeLocalName(),self.sum_talent_point ),
			CCSizeMake(260, 0), nil, self.talentFloater, ccp(40, -10), nil, false, TipDir.LeftUp, true)
end
function TalentMapView:event_talentHit()
	if(not self.talentFloater) then
		return
	end
	local data = self.data
	local bankcfg = self.data.bank_level_cfg
	local talentIncrease = GameData:Instance():getCurrentPlayer():getTalentItemsByRoot(3013)
	talentIncrease  = talentIncrease and talentIncrease.skill_item.d1 or "0%"

	local str =string.raw_format_tran(Consts.Strings.TALENT_ITEM_HIT, AllConfig.talent_init[3].data , AllConfig.talent_init[4].data, talentIncrease ,bankcfg.max_point,(bankcfg.bank_max_rate/100).."%")
	TipsInfo:showStringTip(str,CCSizeMake(220, 0), nil, self.talentFloater, ccp(260, -10), nil, false, TipDir.LeftUp, true)
end

function TalentMapView:event_FishishRightNowConfirm()
	if(not self.talentFloater) then
		return
	end
	local isenoughMoney = self.data.bank_level_cfg.clear_cd_cost <=  GameData:Instance():getCurrentPlayer():getMoney()

	MessageBox.showTalentBankFinishRightNow(
	{
		lbl_txt = {init=MessageBox.Help.bindStringTTFFormat()},
		lbl_nums={init=MessageBox.Help.bindStringTTF(self.data.bank_level_cfg.clear_cd_cost, not(isenoughMoney) and ccc3(255,0,0))}
	},
	{
		event_NOMB_ENTER=function(pop)
			pop:setEnableOKButton(isenoughMoney)
		end,
		event_MB_OK=handler(self,self.event_FinishRightNow)
	})

end
function TalentMapView:event_FinishRightNow(handle)
	handle:close()

 	local data = PbRegist.pack(PbMsgId.TalentClearCDC2S, {type="TALENT_BANK"})
	net.sendMessage(PbMsgId.TalentClearCDC2S, data)
end


function TalentMapView:event_bankLevelup()
	if(not self.talentFloater) then
		return
	end

	if (self.floatOwner.nod_timer:isVisible()) then
		Toast:showString(GameData:Instance():getCurrentScene(),Consts.Strings.HIT_TALENT_BANK_IS_LEVELUP, ccp(display.cx, display.cy))
		return
	end

	local bankcfg = self.data.bank_level_cfg 
	local backnext = self.data.bank_next_level_cfg
	if (not(backnext)) then
		Toast:showString(GameData:Instance():getCurrentScene(), Consts.Strings.HIT_TALENT_BANK_IS_MAX_LEVEL, ccp(display.cx, display.cy))
		return
	end
	local condition =self:checkCondition_blank()

	local stock_increase=  backnext.max_point - bankcfg.max_point
	local defense_increase = tonumber(bankcfg.bank_max_rate)/100
	function _increase_decrease_string(v)
		return v>=0 and "+"..v or "-"..v
	end
	function _req_color(v)
		return type(v) == "boolean" and( v and  0xf32d or 0xff0000 )
			or type(v) =="number" and (v>=0 and 0xf32d or 0xff0000)
			or v and 0xf32d or 0xff0000
	end
	MessageBox.showTalentBankUpgrade({
		lbl_level_req={init=MessageBox.Help.bindTTF2RichText({size={600,0}},{value=bankcfg.player_lv,color=_req_color(condition.player_level)})},
		lbl_stock_increase={init=MessageBox.Help.bindStringTTFFormat()},
		lbl_defense_increase={init=MessageBox.Help.bindStringTTFFormat()},
		lbl_pay_info={init=MessageBox.Help.bindStringTTFFormat()},
		lbl_build_time={init=MessageBox.Help.bindStringTTFFormat()},

		lbl_lv={init=MessageBox.Help.bindStringTTF(bankcfg.player_lv, not (condition.player_level) and ccc3(255,0,0) )},
		lbl_stock={init=MessageBox.Help.bindStringTTF(bankcfg.max_point)},
		lbl_stock_up={init=MessageBox.Help.bindStringTTF("+" .. backnext.max_point - bankcfg.max_point)},
		lbl_defense={init=MessageBox.Help.bindStringTTF( (tonumber(bankcfg.bank_max_rate)/100) .."%"  )},
		lbl_defense_up={init=MessageBox.Help.bindStringTTF("+" .. ((tonumber(backnext.bank_max_rate) - tonumber(bankcfg.bank_max_rate))/100).."%")},
		lbl_pay={init=MessageBox.Help.bindStringTTF(bankcfg.coin_cost, not (condition.coin) and ccc3(255,0,0) )},
		lbl_time ={init = MessageBox.Help.bindStringTTF(Clock.format(bankcfg.next_level_time)) }
	},
	{
		event_NOMB_ENTER=function(pop)
			pop:setEnableOKButton(condition.all_condition)
		end,
		event_MB_OK=handler(self,function(self,pop)
			pop:close()
			net.sendMessage(PbMsgId.TalentBankLevelUpC2S)
		end)}
	)

	return true
end

function TalentMapView:getAbsoluteButtonPostion(offsetX,offsetY)
	local size = self.floatOwner.menu_talentHit:getContentSize()
	return self.floatOwner.menu_talentHit:convertToWorldSpace(ccp(offsetX+size.width/2, offsetY+size.height/2))
end
function TalentMapView:bankLevelupDone(bankinfo)
	local parent = self:getParent()
	self:_stopUpdateScheduler(true)
	bankinfo[1] = Talent.BankStatus.NORMAL

	local anim,offsetX,offsetY,duration = _res(5020199)
	local pos = self:getAbsoluteButtonPostion(offsetX,offsetY)
	pos = self.floatOwner.menu_talentHit:convertToNodeSpace(pos)
	anim:setPosition(pos)
	self.floatOwner.menu_talentHit:addChild(anim)

	MessageBox.Help.LayerClick(self,self,function() return true end,-9999,false,true)
	anim:getAnimation():play("default")
	local function playerCallback()
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.timerIDAnimation)
		self.timerIDAnimation=nil
		parent.IsPlayingBankLevelup=false
		if(parent.LevelupReplayFunction) then					
			self.LevelupReplayFunction()
			parent.LevelupReplayFunction=nil
		else
			Talent.Instance():RecallTimer()
		end
		self:setBankLevelupButton()

		MessageBox.Help.LayerClickRemove(self)
	end

	self.timerIDAnimation=CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(playerCallback,duration,false)
	return true
end
function TalentMapView:scrollViewDidScroll(obj,x)
	obj =self._scrollView
	local coffset = obj:getContentOffset() 
	if (coffset.x<self._scrollViewMinX) then
		coffset.x=self._scrollViewMinX
		obj:setContentOffset(coffset)
	elseif (coffset.x>0) then
		coffset.x=0
		obj:setContentOffset(coffset)
	end
end


return TalentMapView