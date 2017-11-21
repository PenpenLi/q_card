require("model.guide.Guide")
require("model.scenario.Scenario")
require("model.Illustrated.Illustrated")
require("model.quest.Quest")
require("model.Achievement.Achievement")
require("model.talent.Talent")
require("model.Activity")
require("model.battle.BattleFormation")
Player = class("Player")

function Player:ctor()
   self._id = 0
   self._name = ""
   self._level = 1
   self._experience = 0
   self._coin = 0
   self._Money = 0
   self._energy = 0
   self._token = 0
   self._loyalty = 0
   self._talentBankLevel = 1
   self._talentBankPoints = 0
   self._talentBankInfo = 
   {
	   isFrist=true,
		 talent_bank = 0,
	   talent_point=0,
	   talent_product = 0,
	   talent_product_time = 0,
	   bank_level_up_time = 0,
		 talent_items={root_items={},id_items={}}
   }
   self._addition_talentup_list = {}
   Talent.Instance():resetData()
   self:setIsWeiXinSharedDone(0)
   self:setVipLevel(0)
   self:setMaxVipLevel(#AllConfig.vipinitdata - 1)

   net.registMsgCallback(PbMsgId.InstanceRefresh,self,Player.refreshAllData)
   net.registMsgCallback(PbMsgId.QueryAwardResultS2C,self,Player.onQueryAwardResultS2C)
   net.registMsgCallback(PbMsgId.QueryPlayerShowResultS2C,self,Player.onQueryPlayerShowResultS2C)
   
   Talent.Instance():RemoveAllEvents()
end

function Player:refreshAllData(action,msgId,msg) -- refresh data at 24:00
   print("refresh client sync ~~~~~~~")
   if msg.client ~= nil then
      GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)
      if Quest:Instance():getQuestView() ~= nil then
         Quest:Instance():getQuestView():updateView()
      end
      
      if Scenario:Instance():getView() ~= nil then
         Scenario:Instance():getView():updateView()
      end

      if ControllerFactory:Instance():getCurrentControllerType() == ControllerType.SHOP_STATES_CONTROLLER then
	      Mall:Instance():updateView()
      end

      self:initLiveness(msg.client.changed_information.liveness)
   end

   Activity:instance():askForMonthRegister()
end

function Player:update(msgId,pbMsg)

  print("#############pbMsg.mcoin",pbMsg.common.coin)
  print("#############pbMsg.money",pbMsg.common.money)
  print("#############pbMsg.nick_name",pbMsg.nick_name)
  print("#############pbMsg.loyalty",pbMsg.common.loyalty)
  print("#############pbMsg.CommanderCard",#pbMsg.card)
  print("##############pbMsg.item",#pbMsg.item)
  --print("##############pbMsg.token", pbMsg.common.token)
  print("##############pbMsg.max_active_card_bag_size", pbMsg.common.limit.max_active_card_bag_size)
  self:setId(pbMsg.id)
  self._name = pbMsg.nick_name
  --self:setScenarioData(pbMsg.instance.instance)
  Scenario:Instance():update(pbMsg.instance.instance)
  self:setIllustratedInstance(pbMsg)
  
  self:setRechargeMoneyCount(pbMsg.money_history.total_recharge_money)
  
  --init Quest instance
  Quest:Instance():update(pbMsg.task)
  Quest:Instance():updateDailyTask(pbMsg.daily_task_table)
  Achievement:instance():initAchievementState(pbMsg.achievement_state)

  self:updateBaseInfo(pbMsg.common)

  self:updateVipState(pbMsg.vip_state)
  self:updateTalentBank(pbMsg.talent)

  self:setCostMoney(pbMsg.money_history.total_consume_money)
  Guide:Instance():setCurGuideInfoById(pbMsg.newbird_step)
  
  self:setLastFreeGreatTime(pbMsg.last_free_great_draw_time)
  -- Guide:Instance():setCurGuideInfoById(28301)
  self:setLastItemFreeDrawTime(pbMsg.last_free_draw_time)
  self:setLastLoyaltyFreeDrawTime(pbMsg.last_loyalty_free_draw_time)
  self:setRebateData(pbMsg.rebate)
  self:updateAwardsRecordSync(pbMsg.award_record)  
  BattleFormation:Instance():update(pbMsg.battle)
  Bable:instance():setBableInfo(pbMsg.bable_info)
  
  self:setAppendFighterBuffers(pbMsg.append_buffer)
end

------
--  Getter & Setter for
--      Player._LastFreeGreatTime 
-----
function Player:setLastFreeGreatTime(LastFreeGreatTime)
	self._LastFreeGreatTime = LastFreeGreatTime
end

function Player:getLastFreeGreatTime()
	return self._LastFreeGreatTime
end

------
--  Getter & Setter for
--      Player._DrawCardGreatCount 
-----
function Player:setDrawCardGreatCount(DrawCardGreatCount)
	self._DrawCardGreatCount = DrawCardGreatCount
end

function Player:getDrawCardGreatCount()
	return self._DrawCardGreatCount
end

function Player:updateBaseInfo(baseSync)
  if baseSync ~= nil then 
    self._Money = baseSync.money + baseSync.point  -- 增加虚拟货币 point
    self._coin = baseSync.coin
    self:setLevel(baseSync.level)
    --print("##############baseSync.level", baseSync.level)
    self._loyalty = baseSync.loyalty
    self._maxCardOnBattle = baseSync.limit.max_active_card_bag_size
    self:setMaxItemBagCount(baseSync.limit.max_item_bag_size)
    self:setMaxCardBagCount(baseSync.limit.max_backup_card_bag_size)
    print("##############baseSync.max_equipment_bag_size", baseSync.limit.max_equipment_bag_size)
    self:setMaxEquipBagCount(baseSync.limit.max_equipment_bag_size)
    self:setAddedBuyItemBagCount(baseSync.added_buy.item_cell)
    self._cost = baseSync.leader_power
 
    self:setBattleScore(baseSync.score)
    self._experience = baseSync.experience
    self._Avatar = baseSync.avatar
    self._levelReward = baseSync.level_reward
  	self:setLoyaltyTotalDrawTimes(baseSync.statics.loyalty_total_draw_times)
  	self:setItemTotalDrawTimes(baseSync.statics.item_total_draw_times)
    self:setCreateTime(baseSync.statics.character_create_time)
    self:setDrawCardGreatCount(baseSync.statics.draw_card_great_count)
    self:setItemCountLimit(AllConfig.characterinitdata[11].data)
    self:setCardGiftFlag(baseSync.score)
    self:setCardSoul(baseSync.jianghun)
    self:setVipLevel(baseSync.vip_level)
    self:setVipExp(baseSync.vip_exp)
    self:setRankPoint(baseSync.rank_point)
    self:setGuildPoint(baseSync.guild_point)
    self:setBablePoint(baseSync.bable_point)
    self:updatePlayerInfo()
  end
end

------
--  Getter & Setter for
--      Player._AppendFighterBuffers 
-----
function Player:setAppendFighterBuffers(AppendFighterBuffers)
	self._AppendFighterBuffers = AppendFighterBuffers
end

function Player:getAppendFighterBuffers()
	return self._AppendFighterBuffers
end

function Player:setVipLevel(VipLevel)
	self._VipLevel = VipLevel
end

function Player:getVipLevel()
	return self._VipLevel
end

function Player:setVipExp(exp)
  self._vipExp = exp
end

function Player:getVipExp()
  return self._vipExp
end

------
--  Getter & Setter for
--      Player._MaxVipLevel 
-----
function Player:setMaxVipLevel(MaxVipLevel)
	self._MaxVipLevel = MaxVipLevel
end

function Player:getMaxVipLevel()
	return self._MaxVipLevel
end

function Player:getVipLevelId()
  return math.min(self:getVipLevel() + 1,self:getMaxVipLevel() + 1)
end




------
--  Getter & Setter for
--      Player._TalentList 
-----
function Player:setTalentList(TalentList)
	self._TalentList = TalentList
	local talentProperties = self:getTalentPropertiesByTalentIdsList(TalentList)
	self:setTalentProperties(talentProperties)
end

function Player:getTalentList()
	return self._TalentList
end

function Player:getTalentPropertiesByTalentIdsList(learnTalentList--[[talent ids]])
   --talent info
  local talentList = {}
  for i = 1, #learnTalentList do
    local talentid = learnTalentList[i]
    local talentConfig = AllConfig.talent[talentid]
    if talentConfig ~= nil then
      local talent_root = talentConfig.talent_root
      talentList[talent_root] = talentid
    end
  end
  
  local talentProperties = {}
  for key, talentId in pairs(talentList) do
    local talentConfig = AllConfig.talent[talentId]
    if talentConfig ~= nil and talentConfig.type ~= 3 then
     local skillId = AllConfig.talent[talentId].skill
     local skillConfig = AllConfig.cardskill[skillId]
     if skillConfig ~= nil and skillConfig.skill_type == 4 then
       local talentInfo = AllConfig.cardskill[skillId].talent_info
       print(skillConfig.skill_name,"skillId:",skillId)
       if #talentInfo == 2 then
         print(skillConfig.skill_name,"skillId:",skillId,"talentInfo:",talentInfo[1],talentInfo[2])
         local buffId = skillConfig.buffs[1]
         local buffConfig = AllConfig.skillbuff[buffId]
         if buffConfig ~= nil then
           talentProperties[talentInfo[2]] = {}
           talentProperties[talentInfo[2]].type = talentInfo[1]
           talentProperties[talentInfo[2]].value = buffConfig.para[1]
         end
       end
     end
    end
  end
  return talentProperties
end
------
--  Getter & Setter for
--      Player._TalentProperties 
-----
function Player:setTalentProperties(TalentProperties)
  self._TalentProperties = TalentProperties
end

function Player:getTalentProperties()
  return self._TalentProperties
end


function Player:isTalentInited()
	return not self._talentBankInfo.isFrist
end
function Player:updateTalentBank(talent)
	if(talent == nil) then
		return
	end 
  self:setTalentList(talent.talent_list)
	Talent.Instance():resetData()
	if(self:isTalentInited()) then
		Talent.Instance():bank_update(talent)
	end

	self._talentBankInfo.isFrist = nil

	local talent_up={}
	for n,v in ipairs(talent.talent_up) do
		if(v.talent_id~=0) then
			local item = AllConfig.talentRootMap[v.talent_id]
			assert(item and item.pre,"updating talnet id is not exist in local config, pls check is on server ".. v.talent_id )

			talent_up[item.pre.id] = v.talent_up_time
		end
	end

	local timerupdate={}
	--echo("++==+++==---++= current talent:"..self._talentBankInfo.talent_point)
	self._talentBankInfo = {
		talent_bank = talent.talent_bank or self._talentBankInfo.talent_bank,
		talent_point = talent.talent_point or self._talentBankInfo.talent_point,
		talent_product = talent.talent_product or self._talentBankInfo.talent_product,
		talent_product_time = talent.talent_product_time or self._talentBankInfo.talent_product_time,
		bank_level_up_time = talent.bank_level_up_time or self._talentBankInfo.bank_level_up_time,
		talent_items = (function(self_items, talent_list,talent_upinfo)

			local root_items ={} 
			local tmp = {}
			for k,v in ipairs(talent_list) do
				tmp[v]=0
			end
			local id_items={}
			local rootTalent = AllConfig.talentRootMap

			function update_root(item)
				local rootitem = root_items[item.talent_root]
				if (rootitem == nil or rootitem.level<item.level) then
					root_items[item.talent_root] = item
				end
				id_items[item.id]=item
			end
			Talent.Instance():talent_update_callback(function(id)
				local item = self_items.id_items[k]
				if(item) then
					item.timer=0
				end
			end)
			for k,v in pairs(tmp) do	--v allways 0
				local item =self_items.id_items[k]
                if(item) then
					if(item.timer~=0 and not talent_upinfo[k]) then		--在升级情况下清零 ,
						if(item.timer ~=-1) then --准备升级不算完成升级
							Talent.Instance():talent_update(k)
						end
						item.timer=v
					end
					item.nextid=0
				else
				    item = rootTalent[k]
                    assert(item,"talnet id is not exist in local config, pls check is on server ".. k )
                    item=Object.Extend(item,{timer=v,nextid=0})
				end
				update_root(item)
			end

			function timer_update(item,talent_up_time)
				if(not talent_up_time) then
					item.timer = Clock:Instance():getCurServerUtcTime()
					talent_up_time=0
				end
				timerupdate[item.id]={old_timer=item.timer,new_timer=talent_up_time}
				item.timer = talent_up_time

				--if(talent_up_time>0) then
					Talent.Instance():talent_update(item.id,talent_up_time)
				--end
			end

			for id,v in pairs(talent_upinfo) do
				local item = id_items[id]
				if (not(item)) then
					item = self_items.id_items[id]
					if(not(item)) then
						item = rootTalent[id]
						assert(item,"")
						item = Object.Extend(item,{timer=0,nextid=k})
					end
					update_root(item)
				end
				timer_update(item,v)
			end

			for n,v in pairs(id_items) do
				if (not(timerupdate[v.id])) then
					if (v.timer~=0) then
						timer_update(v, 0)
						v.timer=0
					end
				end
			end

			return {["root_items"] = root_items, ["id_items"] =  id_items}
		end)(self._talentBankInfo.talent_items or {},talent.talent_list,talent_up)
	}
	--echo("++==+++==---++= current talent 1:"..self._talentBankInfo.talent_point)

	--CCNotificationCenter:sharedNotificationCenter():postNotification(EventType.TALENT_BANK)
    --CCNotificationCenter:sharedNotificationCenter():postNotification(EventType.UPDATE_TIP)
	Talent:Instance():timer_update(timerupdate)
end


------
--  Getter & Setter for
--      Player._NextSpiritRefreshTime 
-----
function Player:setNextSpiritRefreshTime(NextSpiritRefreshTime)
	self._NextSpiritRefreshTime = NextSpiritRefreshTime
end

function Player:getNextSpiritRefreshTime()
	return self._NextSpiritRefreshTime
end

------
--  Getter & Setter for
--      Player._NextCommondRefreshTime 
-----
function Player:setNextCommondRefreshTime(NextCommondRefreshTime)
	self._NextCommondRefreshTime = NextCommondRefreshTime
end

function Player:getNextCommondRefreshTime()
	return self._NextCommondRefreshTime
end

function Player:updateVipState(vip_state)
  echo("vip state: end_time=", vip_state.end_time)
  echo("vip state: gif_time=", vip_state.last_receive_gift_time)
  echo("vip state: vip flag=", vip_state.receive_development_plan_time)
  echo("vip state: has reward plan times=", vip_state.receive_development_plan_gift_times)
  echo("vip state: has reward gift times=", vip_state.total_receive_gift_times)
  echo("vip state: has buy grow plan =", vip_state.vip_ticket_state)
  self:setVipEndTime(vip_state.end_time)
  self:setLastVipGifTime(vip_state.last_receive_gift_time)
  self:setIsMonthVipState(vip_state.receive_development_plan_time)
  self:setRewardCountForGrowPlan(vip_state.receive_development_plan_gift_times)
  self:setRewardCountForVipGif(vip_state.total_receive_gift_times)
  self:checkCanFetchVipGif()
  self:setGrowPlanBuyFlag(vip_state.vip_ticket_state)
  self:setVipBuyRecord(vip_state.vip_level_gift)
end

function Player:updatePlayerDailyChangedInformation(changeInfo, isClineSyncMsg)
  echo("=== updatePlayerDailyChangedInformation ===:", isClineSyncMsg)

  if changeInfo ~= nil then
    if changeInfo.spirit ~= nil then
      self:setSpirit(changeInfo.spirit.current)
      self:setNextSpiritRefreshTime(changeInfo.spirit.next_refresh_time)
    end

    if changeInfo.command ~= nil then
      self._token = changeInfo.command.current
      self:setNextCommondRefreshTime(changeInfo.command.next_refresh_time)
    end
    self:updatePlayerInfo()

    if changeInfo.refresh ~= nil then
      --echo("-- market_refresh_times = ", changeInfo.refresh.market_refresh_times)
      self._usedMarketRefreshTimes = changeInfo.refresh.market_refresh_times
      
      --refresh quest
      Quest:Instance():setDailyTaskTimes(changeInfo.refresh.current_receive_daily_task_count)
      Quest:Instance():setForcibleDoneDailyTaskCount(changeInfo.refresh.forcible_done_daily_task_count)
      
      --refresh scenario
      Scenario:Instance():setBuyStageCount(changeInfo.refresh.forcible_buy_stage_count)
      ActivityStages:Instance():setActivityBuyCount(changeInfo.refresh.forcible_buy_activity_stage_count)
      Scenario:Instance():setQuickFightCount(changeInfo.vip_daily.free_quick_stage)

      --money tree
      self:setMoneyTreeUsedCount(changeInfo.refresh.use_money_tree_count)
      self:setDailyBuyVitalityCount(changeInfo.refresh.daily_buy_vitality_item_count)
      self:setDailyBuyTokenCount(changeInfo.refresh.buy_lingpai_count)
      self:setPreMoneyTreeHitRateIdx(changeInfo.refresh.moneytree_last_use_hit_rating)
      
      self:setFestivalGiftFlag(changeInfo.refresh.festival)
      self:setIsWeiXinSharedDone(changeInfo.refresh.wechat_share_is_done)
      -- self:setCardSoulMarketRefreshTimes(changeInfo.refresh.jianghun_market_refresh_times)
      self:setPraisedFlag(changeInfo.refresh.is_give_like)
      Bable:instance():setResetTimes(changeInfo.refresh.bable_reset_times)
      Bable:instance():setDailyAwardFlag(changeInfo.refresh.bable_daily_award_get)
      Bable:instance():setDailyFightFlag(changeInfo.refresh.bable_daily_fight)
    end

    if changeInfo.online_reward_state ~= nil then 
      echo("########## received_times", changeInfo.online_reward_state.received_times)
      echo("########## current_reward_start_time", changeInfo.online_reward_state.current_reward_start_time)
      echo("########## online_time", changeInfo.online_reward_state.online_time)
      echo("########## received_times", changeInfo.online_reward_state.received_times)
      self:setOnlineRewardCount(changeInfo.online_reward_state.received_times)
      self:setOnlineRewardStartTime(changeInfo.online_reward_state.current_reward_start_time)
      self:setOnlineRewardTime(changeInfo.online_reward_state.online_time)
    end
    
    if changeInfo.task_refresh ~= nil then
       Quest:Instance():setFreeTaskRefreshTimes(changeInfo.task_refresh.current)
       Quest:Instance():setFreeTaskNextFreshTime(changeInfo.task_refresh.next_refresh_time)
    end

    if changeInfo.increase_buy ~= nil then
      Shop:instance():updateShopInfo(changeInfo.increase_buy)
    end

    if changeInfo.liveness ~= nil and (isClineSyncMsg ~= nil and isClineSyncMsg == false) then
      self:initLiveness(changeInfo.liveness)   --just updated after login/relogin.
    end

    if changeInfo.exchange ~= nil then 
      Activity:instance():updateExchangeTimesLimit(changeInfo.exchange.record)
    end 

    if changeInfo.bable_info ~= nil then 
      Bable:instance():setHpInfo(changeInfo.bable_info)
    end 

    if changeInfo.friend_card_info ~= nil then 
      Bable:instance():setFriendHelpInfo(changeInfo.friend_card_info)
    end 
        
  end
end

function Player:getRefreshMarketFreeTimes()
	self._refreshMarketfreeTimes = self:getTotalRefreshMarketFreeTimes() - self._usedMarketRefreshTimes
	return self._refreshMarketfreeTimes
end

function Player:updateUsedRefreshMarketFreeTimes()
	self._usedMarketRefreshTimes = self._usedMarketRefreshTimes + 1
end



function Player:setId(id)
  self._id = id
end

function Player:getId()
  return self._id
end

function Player:pidToCode(pid)
  local sssssdir = "PO0J1K2L3X4D5A6E7F8B9CDI"
  local str = string.format("%d", pid)
  local i = 1
  local result = ""
  local addStr = ""
  while true do
    local asc = string.byte(str, i);
    if asc ~= nil and asc >= string.byte("0") and asc <= string.byte("9") then
      local index = asc - string.byte("0") + 1
      result = result..string.sub(sssssdir, index, index)
      addStr = addStr..string.sub(sssssdir, 10 + index,  10 + index)
    else
      break
    end
    i = i+1
  end 
  result = result..addStr
  if string.len(result) < 10 then
    result = result..string.sub(sssssdir, 11, 21)
  end
  return string.sub(result, 1, 8)
end

function Player:setName(name)
	self._name = name
	self:updatePlayerInfo()
end

function Player:getName()
	return self._name
end

function Player:setMaxCardOnBattle(maxCardOnBattle)
  self._maxCardOnBattle = maxCardOnBattle
end

function Player:getMaxCardOnBattle()
  return self._maxCardOnBattle
end

--function Player:setScenarioData(scenairoInfo)
--  if self._scenairoInfo == nil then
--    self._scenairoInfo = Scenario.new(scenairoInfo)
--  else
--    self._scenairoInfo:update(scenairoInfo)
--  end
--end
--
--function Player:getScenarioData()
--  return self._scenairoInfo
--end

function Player:setIllustratedInstance(pbMsg)
  if self._IllustratedInstance == nil then
	   self._IllustratedInstance = Illustrated.new()
	end
	self._IllustratedInstance:updateCollection(pbMsg.collection)
	self._IllustratedInstance:updateEquipment(pbMsg.equipment_statics)
end

function Player:getIllustratedInstance()
  return self._IllustratedInstance
end

--function Player:setQuestInstance(normalTaskDatas,dailyTaskTable)
--	if self._QuestInstance == nil then
--	   self._QuestInstance = Quest.new()
--	end
--	self._QuestInstance:update(normalTaskDatas)
--	self._QuestInstance:updateDailyTask(dailyTaskTable)
--end
--
--function Player:getQuestInstance()
--  if self._QuestInstance == nil then
--     self._QuestInstance = Quest.new()
--  end
--	return self._QuestInstance
--end

function Player:setLevel(level)
  if self._level == nil or self._level ~= level then 
    self._level = level
    self:updatePlayerInfo()
    --self:updateNewPlayerGuide()
  end
end

function Player:getLevel()
	return self._level
end

function Player:getMaxLevel()
  return #AllConfig.charlevel
end

function Player:setExperience(experience)
	self._experience = experience
--	echo("nowExp:",experience)
--	--echo("LEvel:",AllConfig.charlevel,table.getn(AllConfig.charlevel))
--	--100
--  --105
--  -- level    exp totalexp
--  -- 1    0   0
--  -- 2    100 100
--  -- 3    104 204
--	local level = 1
--	for i = 1, table.getn(AllConfig.charlevel) do
--	  --echo("current Exp:",self._experience,"needExp:",AllConfig.charlevel[i].exp)
--		if self._experience < AllConfig.charlevel[i].totalexp then
--		  level = i - 1
--		  break
--		end
--	end
--	if level < 1 then
--	   level = 1
--	end
--  self:setLevel(level)
end

function Player:getExperience()
	return self._experience
end

function Player:setCost(cost)
    self._cost = cost
end

function Player:getCost()
    return self._cost
end

function Player:getLeadShip()
	local level = self:getLevel()
	local leadship = AllConfig.charlevel[level].leadship + self:getFriendLeadShip()

	local ext = self:getTalentItemsByRoot(3042)
	ext = ext and ext.skill_item or nil
	ext = ext and ext.para or 0
	return leadship + ext
end
function Player:getCostLeadShip()
      local battleCards = GameData:Instance():getCurrentPackage():getBattleCards()
      local cost = 0
      for i = 1,#battleCards do
          cost = cost + battleCards[i]:getLeadCost()
      end
	  return cost
end
function Player:setFriendLeadShip(friendsNum)
  self._friendLeadShip = 0
  if friendsNum > 0 and friendsNum <= table.getn(AllConfig.friend_leadership) then 
    self._friendLeadShip = AllConfig.friend_leadership[friendsNum].leadership_add
  end
  CCNotificationCenter:sharedNotificationCenter():postNotification(EventType.UPDATE_LEADSHIP)
end

function Player:getFriendLeadShip()
  if self._friendLeadShip == nil then 
    self._friendLeadShip = 0
  end

  return self._friendLeadShip
end

function Player:setCoin(coin)
    self._coin = coin
	self:updatePlayerInfo()
end

function Player:getCoin()
    return self._coin
end

function Player:setVipEndTime(endTime)
  self._timeEnd = endTime
end

function Player:getVipEndTime()
  return self._timeEnd
end

function Player:setLastVipGifTime(time)
  self._vipGifTime = time
end 

function Player:getLastVipGifTime(time)
  return self._vipGifTime
end

function Player:setRewardCountForVipGif(count)
  self._rewardGifCount = count
end

function Player:getRewardCountForVipGif()
  return self._rewardGifCount
end

function Player:setIsMonthVipState(isMonthVip)
  self._isMonthVip = isMonthVip
end

function Player:getIsMonthVipState()
  return self._isMonthVip
end

--包括周卡和月卡
function Player:getIsVipState()
  local curTime = Clock:Instance():getCurServerUtcTime()
  local endTime = GameData:Instance():getCurrentPlayer():getVipEndTime()
  return curTime < endTime
end

function Player:setGrowPlanBuyFlag(flag)
  self._growPlanFlag = flag 
end 

function Player:getGrowPlanBuyFlag()
  return self._growPlanFlag
end 

function Player:setVipBuyRecord(recordArray)
  if self._vipBuyRecord == nil then 
    self._vipBuyRecord = {}
    for i=1, 13 do 
      self._vipBuyRecord[i] = false 
    end 
  end

  echo("=== Player:setVipBuyRecord")
  for k, v in pairs(recordArray) do 
    echo("==== has Buy vip level:", v)
    self._vipBuyRecord[v+1] = true 
  end 
end 

function Player:getVipBuyRecord(vipLevel)
  if self._vipBuyRecord == nil then 
    self._vipBuyRecord = {}
    for i=1, 13 do 
      self._vipBuyRecord[i] = false 
    end 
  end
  return self._vipBuyRecord[vipLevel+1]
end 

function Player:setRewardCountForGrowPlan(count)
  self._rewardCount = count
end

function Player:getRewardCountForGrowPlan()
  return self._rewardCount
end

function Player:checkCanFetchVipGif()
  local canFetch = false
  local preTime = self:getLastVipGifTime()
  local curTime = Clock:Instance():getCurServerUtcTime()
  local timeTable1 = os.date("*t", preTime)
  local timeTable2 = os.date("*t", curTime)

  echo("year, mon, day=", timeTable1.year,timeTable1.month, timeTable1.day, timeTable2.year,timeTable2.month, timeTable2.day)
  if (timeTable2.year ~= timeTable1.year) or (timeTable2.month ~= timeTable1.month) or (timeTable2.day ~= timeTable1.day) then
    canFetch = true
  end

  return canFetch
end

------
--  Getter & Setter for
--      Player._Money 
-----
function Player:setMoney(Money)
	self._Money = Money
	self:updatePlayerInfo()
end

function Player:getMoney()
	return self._Money
end

-- function Player:setEnergy(energy)
--     self._energy = energy
-- 	self:updatePlayerInfo()
-- end

-- function Player:getEnergy()
--     return self._energy
-- end

function Player:setSpirit(spirit)
  self._spirit = spirit
  self:updatePlayerInfo()
end

function Player:getSpirit()
    return self._spirit
end

function Player:getMaxSpirit()
	local ext = self:getTalentItemsByRoot(3041)
	ext = ext and ext.skill_item or nil
	ext = ext and ext.para or 0
	
	local vipPlus = 0
	if AllConfig.vipinitdata[self:getVipLevel()] ~= nil then
	   vipPlus = AllConfig.vipinitdata[self:getVipLevelId()].vip_max_energy
	end
  return AllConfig.characterinitdata[4].data + ext + vipPlus
end

function Player:setToken(token)
  self._token = token
	self:updatePlayerInfo()
end

function Player:getToken()
  return self._token
end

function Player:setLoyalty(loyalty)
	self._loyalty = loyalty
	self:updatePlayerInfo()
end

function Player:getLoyalty()
	return self._loyalty
	--local ext = self:getTalentItemsByRoot(3062)	
	--ext = ext and ext.skill_item or nil
	--ext = ext and ext.para or 0
	--return self._loyalty + ext
end

function Player:updatePlayerInfo()
	CCNotificationCenter:sharedNotificationCenter():postNotification(EventType.PLAYER_UPDATE)
  CCNotificationCenter:sharedNotificationCenter():postNotification(EventType.HOME_UPDATE)
end

--function Player:updateNewPlayerGuide()
--  GameData:Instance():getCurrentScene():newPlayerGuide()
--  -- CCNotificationCenter:sharedNotificationCenter():postNotification(EventType.NEW_PLAYER_GUIDE)
--end

function Player:setMaxItemBagCount(count) --usable items count for player
	self._maxItemBagCount = count
end

function Player:getMaxItemBagCount()
	return self._maxItemBagCount
end

function Player:setItemCountLimit(count)
  self._itemCountLimit = count
end 

function Player:getItemCountLimit()
  return self._itemCountLimit
end 

function Player:setAddedBuyItemBagCount(count)
	self._addBuyItemBagCount = count
end

function Player:getAddedBuyItemBagCount()
	return self._addBuyItemBagCount
end

function Player:setMaxCardBagCount(count)
	self._maxCardBagCount = count
end

function Player:getMaxCardBagCount()
	return self._maxCardBagCount
end

function Player:setMaxEquipBagCount(count)
	self._maxEquipBagCount = count
end

function Player:getMaxEquipBagCount(count)
	return self._maxEquipBagCount
end

function Player:setBattleScore(BattleScore)
	self._BattleScore = BattleScore
end

function Player:getBattleScore()
	return self._BattleScore
end

function Player:setAvatar(Avatar)
	self._Avatar = Avatar
	self:updatePlayerInfo()
end

function Player:getAvatar()
	return self._Avatar
end

function Player:setLevelReward(count)
  self._levelReward = count
end

function Player:getLevelReward()
  return self._levelReward
end


-- 判断是否为VIP
function Player:isVipState()
  return self:getVipLevel() > 0
end

-- 读取数据表 保存玩家的免费刷新次数
function Player:getTotalRefreshMarketFreeTimes()
  local maxTimesPlus = 0
  for key, activity in ipairs(AllConfig.activity) do
    if activity.activity_id == 5003 then
      if Activity:instance():getActivityLeftTime(activity.activity_id) > 0 then       
        if self:isVipState() == true then
          maxTimesPlus = activity.activity_drop[2]
        else
          maxTimesPlus = activity.activity_drop[1]
        end
      end
    end
  end
  
	if self:isVipState() == true then
		return AllConfig.vipinitdata[2].daily_refresh + maxTimesPlus
	else
		return 0 + maxTimesPlus     --  免费玩家没有免费次数 AllConfig.vip[0].daily_refresh
	end
end

function Player:setCostMoney(costValue)
	self._costMoney = costValue
end

function Player:getCostMoney()
	return self._costMoney
end

function Player:setLoyaltyTotalDrawTimes(loyaltyTotalDrawTimes)
	self._loyaltyTotalDrawTimes = loyaltyTotalDrawTimes
end

function Player:getLoyaltyTotalDrawTimes()
	return self._loyaltyTotalDrawTimes
end

function Player:setCreateTime(utcTime)
  Clock:Instance():setPlayerCreateTime(utcTime)
end 

function Player:getCreateTime(bTableType)
  return Clock:Instance():getPlayerCreateTime(bTableType)
end 

function Player:setItemTotalDrawTimes(itemTotalDrawTimes)
	self._itemTotalDrawTimes = itemTotalDrawTimes
end

function Player:getItemTotalDrawTimes()
	return self._itemTotalDrawTimes
end

function Player:setOnlineRewardCount(count)
  self._receivedCounts = count
end 

function Player:getOnlineRewardCount()
  return self._receivedCounts
end 

function Player:setOnlineRewardStartTime(time)
  self._curOnlineStartTime = time
end 

function Player:getOnlineRewardStartTime()
  return self._curOnlineStartTime
end

function Player:setOnlineRewardTime(onlineTime)
  self._onlineTime = onlineTime
end 

function Player:getOnlineRewardTime()
  return self._onlineTime
end

function Player:setLastItemFreeDrawTime(lastFreeDrawTime)
  self._lastfreeDrawTime = toint(lastFreeDrawTime)
end

function Player:getLastItemFreeDrawTime()
	local lastFreeDrawTime =toint(self._lastfreeDrawTime)
	print("lastFreeDrawTime",lastFreeDrawTime)
	return lastFreeDrawTime
end

function Player:setLastLoyaltyFreeDrawTime(time)
	self.lastLoyaltyFreeDrawTime = time
end

function Player:setRebateData(reqRebateData)
	if reqRebateData.list ~= nil then
		Mall:Instance():setRebateData(reqRebateData.list)
    Activity:instance():setDaySurpriseRebateData(reqRebateData.list)
	end
end

function Player:getLastLoyaltyFreeDrawTime()
	local time = toint(self.lastLoyaltyFreeDrawTime)
	return time
end

function Player:setBuyTokenCount(count)

	self._buyTokenCount = count
end

function Player:getBuyTokenCount()
	if self._buyTokenCount ~= nil then
		return self._buyTokenCount
	else
		return 0
	end
end

function Player:setBuySpriteCount(count)
	self._buySpriteCount = count
end

function Player:getBuySpriteCount()
	if self._buySpriteCount ~= nil then
		return self._buySpriteCount
	else
		return 0
	end
end

function Player:setMoneyTreeUsedCount(count)
  self._moneyTreeCount = count
end

function Player:getMoneyTreeUsedCount()
  if self._moneyTreeCount == nil then
    self._moneyTreeCount = 0
  end
  return self._moneyTreeCount
end

function Player:setDailyBuyVitalityCount(count)
	self._dailyBuyVitalityItemCount = count
end

function Player:getDailyBuyVitalityCount()
	return self._dailyBuyVitalityItemCount
end

function Player:setDailyBuyTokenCount(count)
	self._dailyBuyTokenItemCount = count
end

function Player:getDailyBuyTokenCount()
	return self._dailyBuyTokenItemCount
end


function Player:initLiveness(livenessInfo) 
  print("=== Player:initLiveness")

  --只在登录游戏时初始化一次, 以后的数据通过消息LivenessProgressB2C来进行同步
  -- if self._livenessItem == nil then 
    --set empty before init
    self._livenessItem = {}
    self._livenessAward = {0, 0, 0, 0, 0, 0}
    self._totalLivenessVal = 0 

    local liveType = -1
    for k, v in pairs(AllConfig.liveness) do 
      if liveType ~= v.type then 
        --当前进度信息, id为表AllConfig.liveness索引,当id==-1时表示已完成; counts/countsMax表示进度; gainedVal:获得的积分点;
        local curMax = AllConfig.liveness[k].count
        self._livenessItem[v.type+1] = {id=k, iType=v.type, counts=0, countsMax=curMax, totalCounts=1, gainedVal=0, desc=v.desciption}
        liveType = v.type 
      else 
        self._livenessItem[v.type+1].totalCounts = self._livenessItem[v.type+1].totalCounts + 1
      end 
      --所有进度累加起来获得的积分
      self._totalLivenessVal = self._totalLivenessVal + v.value 
    end 

    --set newest liveness data 
    echo("day_point, week_point, pre_week_point=", livenessInfo.point, livenessInfo.week_point, livenessInfo.last_week_point)
    self:setGainedLivenessValue(livenessInfo.point)
    self:setCurWeekLivenessVal(livenessInfo.week_point)
    self:setPreWeekLivenessVal(livenessInfo.last_week_point)
    self:setWeekLivenessAwarded(livenessInfo.week_point_is_get)

    if livenessInfo.liveness ~= nil then 
      for k, v in pairs(livenessInfo.liveness) do 
        self:setLivenessItem(v.type, v.var)
      end 
    end 

    if livenessInfo.awrd_info ~= nil then 
      for k, v in pairs(livenessInfo.awrd_info) do 
        print("=== liveness award_id, is_get=", v.award_id, v.is_get)
        self:setLivenessAwardInfo(v.award_id, v.is_get)
      end 
    end 
  -- end 
end 

function Player:setLivenessItem(_type, counts)
  if _type ~= nil then 
    local item = self._livenessItem[_type+1]
    
    --set current item gained point 
    if counts > 0 then 
      while true do 
        if item.id > 0 then 
          if counts >= AllConfig.liveness[item.id].count then 
            item.gainedVal = item.gainedVal + AllConfig.liveness[item.id].value

            item.id = AllConfig.liveness[item.id].next_liveness
            if item.id > 0 then 
              item.countsMax = AllConfig.liveness[item.id].count
            end 
          else 
            break 
          end 
        else 
          break --complete 
        end 
      end 

      -- item.counts = math.min(counts, item.countsMax)
      item.counts = math.min(counts, item.totalCounts)
      
      print("=== liveness type, gained,id:", _type, item.gainedVal, item.id)
    end 
  end
end 

function Player:getLivenessItem(_type)
  if _type ~= nil then 
    return self._livenessItem[_type+1]
  end
  return nil 
end 

function Player:getLivenessArray()
  if self._livenessItem == nil then 
    self._livenessItem = {}
  end 
  return self._livenessItem
end 

function Player:setTotalLivenessVal(point)
  self._totalLivenessVal = point
end 

function Player:getTotalLivenessVal()
  return self._totalLivenessVal
end 

function Player:setGainedLivenessValue(value)
  self._gainedLiveness = value
end 

function Player:getGainedLivenessValue()
  if self._gainedLiveness == nil then 
    self._gainedLiveness = 0
  end 
  return self._gainedLiveness
end 

function Player:setLivenessAwardInfo(index, awardFlag)
  self._livenessAward[index] = awardFlag
end 

function Player:getLivenessAwardInfo(index)
  return self._livenessAward[index]
end
 
function Player:getTalentBankInfo()
	return self._talentBankInfo
end
function Player:getTalentBankLevel()
	return self._talentBankInfo.talent_bank
end
function Player:setTalentBankLevel(level)
	self._talentBankInfo.talent_bank = level
end
function Player:getTalentBankPoints()
	return self._talentBankInfo.talent_point
end
function Player:setTalentBankPoints(points)
	self._talentBankInfo.talent_point =points
end
function Player:getTalentRootItems()
	return self._talentBankInfo.talent_items.root_items
end
function Player:getTalentItemsByRoot(n)
	return self._talentBankInfo.talent_items.root_items[n]
end
function Player:getTalentItemsByID(id)
	return self._talentBankInfo.talent_items.id_items[id]
end

function Player:getTalentItemsByIDAlways(id)
	local talent_items = self._talentBankInfo.talent_items
	local item = talent_items.id_items[id]
	if (item == nil) then
		local cfgitem = AllConfig.talentRootMap[id]
		assert(cfgitem,id.."not found in Config.talent table")
		item = Object.Extend(cfgitem,{timer=0,nextid=0})
		if (talent_items.root_items[item.talent_root] == nil) then
			talent_items.root_items[item.talent_root] = item
		end
		talent_items.id_items[item.id]=item
	end
	return item
end
function Player:setCurWeekLivenessVal(value)
  self._curWeekLiveness = value
end 
function Player:getCurWeekLivenessVal()
  return self._curWeekLiveness
end 

function Player:setPreWeekLivenessVal(value)
  self._PreWeekLiveness = value
end 

function Player:getPreWeekLivenessVal()
  return self._PreWeekLiveness
end 

function Player:setWeekLivenessAwarded(awardFlag)
  self._weekLivenessAwarded = awardFlag
end 

function Player:getWeekLivenessAwarded()
  return self._weekLivenessAwarded
end 

function Player:getMaxToken()
	local ext = self:getTalentItemsByRoot(3022)
	ext = ext and ext.skill_item or nil
	ext = ext and ext.para or 0
	return AllConfig.characterinitdata[15].data+ ext	--max_vigor (token)
end

function Player:getTalentBankMaxPoint()
	return AllConfig.bank_levelup_time[self:getTalentBankLevel()].max_point 
end

function Player:setCardGiftFlag(flag)
  self._cardGift = flag
end 

function Player:getCardGiftFlag()
  return self._cardGift or 0
end 

function Player:setPreMoneyTreeHitRateIdx(idx)
  self._hitRateIdx = idx
end 

function Player:getPreMoneyTreeHitRateIdx()
  return self._hitRateIdx
end 

function Player:setFestivalGiftFlag(flag)
  self._festivalGiftFlag = flag
end 

function Player:getFestivalGiftFlag()
  return self._festivalGiftFlag or 0
end 

function Player:setIsWeiXinSharedDone(isDone)
  self._WXSharedDone = isDone 
end 

function Player:getIsWeiXinSharedDone()
  return self._WXSharedDone 
end 

function Player:setCardSoul(val)
  self._cardSoul = val 
end 

function Player:getCardSoul()
  return self._cardSoul or 0 
end 

function Player:setCardSoulMarketRefreshTimes(count)
  self._soulMarketRefreshTimes = count 
end 

function Player:getCardSoulMarketRefreshTimes()
  return self._soulMarketRefreshTimes 
end 

function Player:isEnabledEnterBattle()
  local pop = nil
  local battleCards = GameData:Instance():getCurrentPackage():getBattleCards()
  local hasLeaderCard = false
  for key, card in pairs(battleCards) do
    if card:getIsBoss() == true then
       hasLeaderCard = true
       break
    end
  end
  
  if #battleCards <= 0 then
     pop = PopupView:createTextPopup(_tr("need_more_card_on_battle"), function()
        local controller = ControllerFactory:Instance():create(ControllerType.PLAY_STATES_CONTROLLER)
        controller:enter(1)
     end)
  elseif hasLeaderCard == false then
     pop = PopupView:createTextPopup(_tr("need_leader"), function()
       local controller = ControllerFactory:Instance():create(ControllerType.PLAY_STATES_CONTROLLER)
       controller:enter(1)
     end)
  elseif self:getLeadShip() < self:getCostLeadShip() then
    pop = PopupView:createTextPopup(_tr("leadship_exceed_pls_off_battle"), function() 
      local playstatesController  = ControllerFactory:Instance():create(ControllerType.PLAY_STATES_CONTROLLER)
      playstatesController:enter()
    end,true)
  elseif GameData:Instance():getCurrentPackage():checkItemBagEnoughSpace(1) == false then
    pop = PopupView:createTextPopupWithPath({leftNorBtn = "button-nor-zhengli.png",leftSelBtn = "button-sel-zhengli.png",text = string._tran("bag is full"),
      leftCallBack = function() 
        local bagController = ControllerFactory:Instance():create(ControllerType.BAG_CONTROLLER)
        bagController:enter()
      end})
  elseif GameData:Instance():getCurrentPackage():checkCardBagEnoughSpace(1) == false then
    pop = PopupView:createTextPopupWithPath({leftNorBtn = "lianhun0.png",leftSelBtn = "lianhun1.png",rightNorBtn = "chushou.png", rightSelBtn = "chushou1.png",text = _tr("card bag is full,clean up?"),
      leftCallBack = function()
        if GameData:Instance():checkSystemOpenCondition(27, true) == false then 
          return 
        end 
        local controller = ControllerFactory:Instance():create(ControllerType.CARD_SOUL_CONTROLLER)
        controller:enter(CardSoulMenu.SHOP)     

      end,rightCallBack = function()
        local cardBagController =  ControllerFactory:Instance():create(ControllerType.CARDBAG_CONTROLLER)
        cardBagController:enter()
      end})

  elseif GameData:Instance():getCurrentPackage():checkEquipBagEnoughSpace(1) == false then
    pop = PopupView:createTextPopupWithPath({leftNorBtn = "button-nor-zhengli.png",leftSelBtn = "button-sel-zhengli.png",text =_tr("equip bag is full,clean up?"),
      leftCallBack = function()
        local cardBagController = ControllerFactory:Instance():create(ControllerType.CARDBAG_CONTROLLER)
        cardBagController:enter(true)
      end})

  else
    return true
  end
  
  if pop ~= nil then
    GameData:Instance():getCurrentScene():addChildView(pop)
  end
  
  return false
end

function Player:toastBattleAbility(preVal)
  if preVal ~= nil and preVal > 0 then 
    local battleCards = GameData:Instance():getCurrentPackage():getBattleCards()
    local curVal = GameData:Instance():getBattleAbilityForCards(battleCards)
    
    if curVal > preVal then 
      local str = string.format("+%d", curVal-preVal)
      Toast:showIconNum(str, "img/common/zhanLi+.png", nil, nil, ccp(display.cx-50, display.cy), "img/client/widget/words/float_number/abilities_plus.fnt")
    elseif curVal < preVal then 
      local str = string.format("%d", curVal-preVal)
      Toast:showIconNum(str, "img/common/zhanLi-.png", nil, nil, ccp(display.cx-50, display.cy), "img/client/widget/words/float_number/abilities_minus.fnt")
    end 
  end 
end 


function Player:reqQueryAwardC2S(awardId, awardType, callbackFunc)

  awardType = awardType or AwardType.CHEPTER_AWARD
  print("Player:reqQueryAwardC2S():", awardId, awardType)

  _showLoading()
  local data = PbRegist.pack(PbMsgId.QueryAwardC2S,{id = awardId,type = awardType})
  net.sendMessage(PbMsgId.QueryAwardC2S,data)

  self._awardCallbackFunc = callbackFunc
end

function Player:onQueryAwardResultS2C(action,msgId,msg)
  print("Player:onQueryAwardResultS2C:"..msg.error)
  _hideLoading()

  if msg.error == "NO_ERROR_CODE" then
    local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client)
    for i = 1,table.getn(gainItems) do
    local str = string.format("+%d", gainItems[i].count)
    Toast:showIconNumWithDelay(str, gainItems[i].iconId, gainItems[i].iType, gainItems[i].configId, ccp(display.width/2,display.height*0.5-i*40), 0.3*(i-1))
  end
  GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)

  elseif msg.error == "NO_AWARD" then
    Toast:showString(curScene, _tr("can not fetch award"), ccp(display.cx, display.cy)) 
  elseif msg.error == "HAS_GET_AWARD" then
    Toast:showString(curScene, _tr("has award"), ccp(display.cx, display.cy)) 
  else
    Toast:showString(curScene, _tr("system error"), ccp(display.cx, display.cy)) 
  end

  if self._awardCallbackFunc then 
    self._awardCallbackFunc(msg.error)
  end 
end

function Player:updateAwardsRecordSync(award_record)
  if award_record ~= nil then
	  self:setAllGetedAwards(award_record)
  end
end

------
--  Getter & Setter for
--      Player._AllGetedAwards 
-----
function Player:setAllGetedAwards(AllGetedAwards)
  --[[message AwardRecord{
  //可以动态扩展
  enum AwardType{
    CHEPTER_AWARD = 1;  //章节星星奖励
   }
  optional int32 id = 1;
  optional AwardType type = 2;
  optional int32 data = 3;
  }
  message PlayerAwardRecord{
    repeated AwardRecord chepter = 1; //星星奖励
  }]]
  
	self._AllGetedAwards = AllGetedAwards
end

function Player:getAllGetedAwards()
	return self._AllGetedAwards
end

--function Player:getGetedAwardsByAwardType(awardType)
--  local awards = {}
--  for key,award in pairs(self:getAllGetedAwards()) do
--  	if award.type == awardType then
--  	  table.insert(awards,award)
--  	end
--  end
--  return awards
--end

--当天是否给土豪雕像点过赞
function Player:setPraisedFlag(flag)
  echo("====setPraisedFlag")
  self._praisedFlag = flag
end  

function Player:getPraisedFlag()
  return self._praisedFlag or 0 
end 



function Player:setRechargeMoneyCount(count)
  self._rechargeCount = count 
end 

function Player:getRechargeMoneyCount()
  return self._rechargeCount or 0 
end 
-- 竞技场 排行点
function Player:setRankPoint(point)
  self._rankPoint = point 
end 

function Player:getRankPoint()
  return self._rankPoint or 0 
end 
-- 公会点
function Player:setGuildPoint(point)
  self._guildPoint = point 
end 

function Player:getGuildPoint()
  return self._guildPoint or 0  
end 

function Player:setBablePoint(point)
  self._bablePoint = point 
end 

function Player:getBablePoint()
  return self._bablePoint or 0
end 

function Player:reqQueryPlayerShowC2S(userId,callback)
  _showLoading()
  self._QueryPlayerShowCallBack = callback
  printf("Player:reqQueryPlayerShowC2S:user id:%s",userId)
  local data = PbRegist.pack(PbMsgId.QueryPlayerShowC2S,{pid = userId})
  net.sendMessage(PbMsgId.QueryPlayerShowC2S,data)
end

function Player:onQueryPlayerShowResultS2C(action,msgId,msg)
  _hideLoading()
  if self._QueryPlayerShowCallBack ~= nil then
    self._QueryPlayerShowCallBack(action,msgId,msg)
  end
  self._QueryPlayerShowCallBack = nil
end

return Player
