Talent = class("Talent")

Talent.Instance = handler(Talent,Object.getInstance)

local function Talent_events_bind(list,name)
	return function(...)
		local ret=nil
		if (name) then
			echo ("EVENT ".. name)
		end
		for i,v in ipairs(list) do
			local tmp = nil
			if (v.obj) then
				tmp=v.fun(v.obj,...)
			else
				tmp = v.fun(...)
			end
			ret = ret or tmp
		end
		return ret
	end
end
local Talent_events_setting={
		["TALENT_GETPOINT"] = {},
		["BANK_LEVELUP"] = {},
		--["BANK_LEVELUP_END"] = {},
		["TALENT_LEVELUP"] = {},
		--["TALENT_LEVELUP_END"] = {},
		["TALENT_LEVELUP_CAN_END"] = {},
		["TALENT_BANK_CHANGED"]={},
		["TALENT_PRODUCE_CHANGED"]={}
}
local Talent_events={}

function Talent.CanOpenCheck()
  local ret, str = GameData:Instance():checkSystemOpenCondition(20, false)
	return  ret, str
end 

function Talent:hasAnyoneCanUpdate()
	if (not Talent.CanOpenCheck()) then
		return false
	end

	local ret = TalentMapView.IsAnyOneCanUpdate()
	return not(next(ret.Updating)) and (ret[1] or ret[2] or ret[3])
end
local bankstatus=enum({"NORMAL","BANK_LEVELUP","BANK_LEVELUP_DONE" --,"BANK_LEVELUP_CAN_DONE"
})
Talent.BankStatus = bankstatus
function Talent:ctor()
	Talent.RemoveAllEvents()
  net.registMsgCallback(PbMsgId.TalentBankLevelUpResultS2C,self,Talent.TalentBankLevelUpResultS2C)
  net.registMsgCallback(PbMsgId.TalentClearCDResultS2C,self,Talent.TalentClearCDResultS2C)
  net.registMsgCallback(PbMsgId.TalentLevelUpResultS2C,self,Talent.TalentLevelUpResultS2C)
  net.registMsgCallback(PbMsgId.TalentDataQueryResultS2C,self,Talent.TalentDataQueryResultS2C)
	net.registMsgCallback(PbMsgId.TalentGetPointResultS2C,self,Talent.TalentGetPointResultS2C)

	self._level_end_events={}
	self._bank_level_up_status={bankstatus.NORMAL}
	self:resetData()

	Talent_events={
			["TALENT_GETPOINT"] = Talent_events_bind(Talent_events_setting.TALENT_GETPOINT,"TALENT_GETPOINT"),
			["BANK_LEVELUP"] =Talent_events_bind(Talent_events_setting.BANK_LEVELUP,"BANK_LEVELUP"),
			["TALENT_LEVELUP"] = Talent_events_bind(Talent_events_setting.TALENT_LEVELUP,"TALENT_LEVELUP"),
			["TALENT_LEVELUP_CAN_END"] = Talent_events_bind(Talent_events_setting.TALENT_LEVELUP_CAN_END,"TALENT_LEVELUP_CAN_END"),
			["TALENT_BANK_CHANGED"] = Talent_events_bind(Talent_events_setting.TALENT_BANK_CHANGED,"TALENT_BANK_CHANGED"),
			["TALENT_PRODUCE_CHANGED"] = Talent_events_bind(Talent_events_setting.TALENT_PRODUCE_CHANGED,"TALENT_PRODUCE_CHANGED")
	}
	
end
function Talent._processError(msg,fun,errfun)
	if (msg.error == "NO_ERROR_CODE") then
		if(fun) then
			fun(msg)
		end
		GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)

		return true
	elseif (not (errfun) or not(errfun(msg)) ) then
		ServerError.GetOrShowDescrible(msg.error,true, ServerError.Type.TALENT_BLANK)
		--if(msg.client) then
		--	GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)
		--end
	end
	return false
end
function Talent:TalentGetPointResultS2C(action,msgId,msg)
	return Talent._processError(msg,function()
		Talent_events.TALENT_GETPOINT(msg)
		return true		
	end,function(msg)
		if(msg.error == "NO_PRODUCE_POINT") then
			local isfull = GameData:Instance():getCurrentPlayer():getTalentBankPoints()>=GameData:Instance():getCurrentPlayer():getTalentBankMaxPoint()
			ServerError.GetOrShowDescrible(	isfull and "ERROR_BANK_FULL" or "ERROR_NO_PRODUCT",true, ServerError.Type.TALENT_BLANK)
			return true
		end
	end
	)
end
function Talent:TalentBankLevelUpResultS2C(action,msgId,msg)
	return Talent._processError(msg)
end
function Talent:TalentClearCDResultS2C(action,msgId,msg)
	return Talent._processError(msg)
end
function Talent:_toPreLevelList(data,id_name)
	local ret={}
	for n,v in ipairs(data) do
		local id =id_name and v[id_name] or v
		assert(id,"TalentLevelUpResultS2C: talent item not exist")
		local item = AllConfig.talentRootMap[id]
		assert(item and item.pre,"TalentLevelUpResultS2C: talent item not exist")
		item = item.pre

		ret[item.id] = v
	end
	return ret;
end
function Talent:TalentLevelUpResultS2C(action,msgId,msg) --return curent level
	return Talent._processError(msg)
end

function Talent:TalentDataQueryResultS2C(action,msgId,msg) --next levels

	if(#msg.talent_up>0) then
		for n,v in ipairs(msg.talent_up) do
			local item = AllConfig.talentRootMap[v]
			assert(item and item.pre,"TalentLevelUpResultS2C: talent item not exist")
			item = item.pre
			self:talent_update(item.id)
		end
	end

	GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)
end

function Talent:bank_update(talentinfo)
	local currentBankLevel = GameData:Instance():getCurrentPlayer():getTalentBankLevel()
	local isBankLevelup =  talentinfo.talent_bank and talentinfo.talent_bank~= currentBankLevel or false

	local ret =true
	if (isBankLevelup) then
		self._bank_level_up_status = {bankstatus.BANK_LEVELUP_DONE,true,talentinfo.talent_bank}
	else
		if(talentinfo.bank_level_up_time~=0) then
			self._bank_level_up_status = {bankstatus.BANK_LEVELUP,talentinfo.bank_level_up_time,false,currentBankLevel}
		else
			if(self._bank_level_up_status[1] ~= bankstatus.BANK_LEVELUP_DONE) then
				self._bank_level_up_status = {bankstatus.NORMAL}
			end
		end
	end

	return ret
end
function Talent:talent_update(id,time)
	if(not time) then
		self._level_end_events[id]=true
		self._level_up_events[id] = nil
	else
		if (not (self._level_end_events[id]==true)) then
			self._level_up_events[id]=time
		end
	end
end
function Talent:talent_update_callback(callback)
	for n,v in pairs(self._level_end_events) do
		if(v == true) then
			callback(n)
		end
	end
end
function Talent:resetData()
	self._level_up_events={}

	for id,v in pairs(self._level_end_events) do
		if(v==false) then	--timer can be nil
			self._level_end_events[id]=nil
		end
	end

	if(self._bank_level_up_status[1]~=bankstatus.BANK_LEVELUP_DONE and self._bank_level_up_status[2]) then
		self._bank_level_up_status={bankstatus.NORMAL}
	end
end
function Talent.RemoveAllEvents()
end


function Talent.SetEvent(name,fun,obj)
	assert( Talent_events[name] ,"item not exist or function is nil")

	if(fun == nil or obj==true) then
		if(obj == true) then
			obj=nil
		end
		local ret = 0
		for n,v in ipairs(Talent_events_setting[name]) do
			if(v.obj == obj) then
				if(fun == nil or fun == v.fun) then
					table.remove(Talent_events_setting[name],n)
					ret = ret+1
				end
			end
		end
		--assert(ret>0,name .. "remove event");
	else
		for n,v in ipairs(Talent_events_setting[name]) do
			assert(v.obj~=obj or v.fun~=fun,"the event has set before.")
		end

		table.insert(Talent_events_setting[name],{["obj"]=obj,["fun"]=fun})
		if(name == "TALENT_PRODUCE_CHANGED") then
			Talent.Instance():_startProduceLocalCallback()
		end
	end

end
function Talent.getCurrentProduct()
	local curPlayer = GameData:Instance():getCurrentPlayer()
	if(curPlayer == nil) then
		return nil
	end
	local bankinfo = GameData:Instance():getCurrentPlayer():getTalentBankInfo()
	local currentProduct =  bankinfo.talent_product + AllConfig.talentSystemConfig.int_restore_talentcount* (-Clock:Instance():DiffWithServerTime(bankinfo.talent_product_time))/ (AllConfig.talentSystemConfig.int_talent_restore_interval)
	currentProduct = math.floor(currentProduct)

	if(currentProduct<0) then
		print("��������ʱ�䣬��ǰ����˿ɲɼ����츳��Ϊ����  " .. bankinfo.talent_product)
	end

	local isProduceFull = currentProduct >= AllConfig.talentSystemConfig.int_temp_max_cap
	local vaildProduct  =isProduceFull and AllConfig.talentSystemConfig.int_temp_max_cap or currentProduct>=0 and currentProduct or 0

	return vaildProduct,
			currentProduct,
			isProduceFull,
			curPlayer:getTalentBankPoints()>= curPlayer:getTalentBankMaxPoint()
end

function Talent:_startProduceLocalCallback()
	self:_stopProduceLocalCallback()
	local needTimer = AllConfig.talentSystemConfig.int_talent_restore_interval / AllConfig.talentSystemConfig.int_restore_talentcount

	local currentCount,realProduct = Talent.getCurrentProduct();
	if (currentCount == nil) then
		needTimer = 1
	else
		if(realProduct<0) then
			needTimer = needTimer -realProduct * needTimer;
		end
		Talent_events.TALENT_PRODUCE_CHANGED(currentCount)
	end

	self._produceTimer = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
		self:_startProduceLocalCallback()
	end, needTimer , false)
end
function Talent:_stopProduceLocalCallback()
	if(self._produceTimer ==nil) then
		return
	end
	CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self._produceTimer)
	self._produceTimer = nil
end


function Talent:dispose()
	net.unregistAllCallback(self)
	self:clearTimer()
	Talent.Instance():_stopProduceLocalCallback()
	for n,v in pairs(Talent_events_setting) do
		for i,vv in ipairs(v) do
			local fun = vv.obj ==true and vv.fun or nil
			Talent.Instance().SetEvent(n,fun,vv.obj)
		end
	end
end

function Talent:timer_update() --data

	Talent_events.TALENT_BANK_CHANGED()
	self:_startProduceLocalCallback()

	local delaylist={}
	for n,v in pairs(self._level_up_events) do
		table.insert(delaylist,{id=n,finish_time=v}) 
	end
	if(self._bank_level_up_status[1] == bankstatus.BANK_LEVELUP) then
		table.insert(delaylist,{id="BANK_LEVELUP",finish_time=self._bank_level_up_status[2]})
	end

	table.sort(delaylist,function(l,r)
		return l.finish_time>r.finish_time
	end)

	local function nextTimer()
		self:clearTimer()
		if (#delaylist==0) then
			return
		end

		local item = table.remove(delaylist,table.maxn(delaylist))

		function _exec(item)
			local ischanged=false
			if (item.id == "BANK_LEVELUP") then
				self._bank_level_up_status[1] = bankstatus.BANK_LEVELUP_DONE
				self._bank_level_up_status[2] = false
				ischanged = true
			else
				if (self._level_end_events[item.id]~=true) then
					self._level_end_events[item.id]=false
					ischanged = true
				end
			end

			nextTimer()
			if(ischanged) then
				self:RecallTimer()
			end
		end
		local time_left = Clock.Instance():DiffWithServerTime(item.finish_time)
		if(time_left>0) then
			self._RecallTimerID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(handler(item,_exec), time_left , false)
		else
			_exec(item)
		end
	end

	nextTimer()
	self:RecallTimer()	--�����֪ͨ
end

function Talent:clearTimer()
	if (self._RecallTimerID) then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self._RecallTimerID)
		self._RecallTimerID = nil
	end
end
function Talent:_RecallTimer()

	local ret
	local tmp_level_up={}
	for n,v in pairs(self._level_up_events) do
		if(self._level_end_events[n]~=nil) then
			self._level_up_events[n]=nil
			if(self._level_end_events[n]==false) then
				tmp_level_up[n]=v
			end
		end
	end
	ret =  self._bank_level_up_status[1] == bankstatus.BANK_LEVELUP and Talent_events.BANK_LEVELUP(self._bank_level_up_status) or false
	ret = next(self._level_up_events)~=nil and Talent_events.TALENT_LEVELUP(self._level_up_events) or false
	ret = (next(self._level_end_events)~=nil or self._bank_level_up_status[1] == bankstatus.BANK_LEVELUP_DONE) and Talent_events.TALENT_LEVELUP_CAN_END(self._level_end_events,self._bank_level_up_status)


	for n,v in pairs(tmp_level_up) do
		self._level_up_events[n]=v
	end
end

function Talent:RecallTimer(rightNow)
	if (self.TimerID) then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.TimerID); 
		self.TimerID=nil
	end

	if(rightNow) then
		self:_RecallTimer()
	else
		self.TimerID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.TimerID);
			self.TimerID=nil
			self:_RecallTimer()
		end,
		0.05,
		false
		)
	end
	
end

