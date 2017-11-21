require("model.Boss")


Activity = class("Activity")

Activity._instance = nil

--活动模块top menus
ActMenu = enum({"ARMY", "LEVELUP_BONUS", "DAILY_SIGNIN", "BOSS", "GROW_PLAN", "VIP_SIGNIN", "MONEY_TREE", 
                "REBATE_ONE", "REBATE_TEN","EXCHANGE", "ZHONG_QIU","CHARGE_REBATE", "ARENA","CHARGE_BONUS",
                "VIP_PRIVILEGE", "MONEY_CONSUME","BIG_WHEEL", "CARD_REPLACE", "QUICK_MONEY"
              })

--活动id映射表
ACI_ID_REBATE_ONE = 1002              --单抽返利
ACI_ID_REBATE_TEN = 1003              --十连抽返利  
ACI_ID_SCENARIO_DROP = 1004           --战役副本掉落
ACI_ID_SCENARIO_DROP_EX = 1005        --战役/征战掉落
ACI_ID_CHARGE_1 = 1007                --充值活动
ACI_ID_MID_AUTUMN = 1008              --中秋兑换
ACI_ID_ARENA = 1009                   --武斗大会
ACI_ID_CREATE_ROLE_GIFT = 3001        --角色创建礼包
ACI_ID_CHARGE_REBATE = 3004           --充值送张飞
ACI_ID_LOTTERY_REBATE_CHIP = 3005     --点将送碎片
ACI_ID_GROW_PLAN = 5001               --成长计划折扣
ACI_ID_BATTLE_SPIRITE_DISCOUNT = 5002 --副本体力折扣
ACI_ID_MARKET_REFRESH_TIMES = 5003    --集市刷新次数增加
ACI_ID_EXCHANGE = 1011                --Q卡三国兑换
ACI_ID_ARMY = 5005                    --犒赏三军活动
ACI_ID_CHARGE_BONUS = 5006            --累计充值
ACI_ID_CONSUME_MONEY = 5011           --元宝消耗奖励
ACI_ID_FESTIVAL_GIFT = 5007           --节日礼包
ACI_ID_ACTIVITY_STAGE = 9999          --剑阁副本
ACI_ID_MONEY_TREE_DISCOUNT = 5008     --摇钱树折扣 
ACI_ID_MONEY_TREE_DROP = 5009         --聚宝盆附加掉落
ACI_ID_SERVER_OPEN_BONUS = 5013       --7天开服活动
ACI_ID_CARD_SOUL_SHOP = 9998          --将魂商店
ACT_ID_BIG_WHEEL = 5014               --大转盘
ACT_ID_CARD_REPLACE = 5015
ACT_ID_QUICK_MONEY = 5016           --摇元宝

function Activity:ctor()
  net.registMsgCallback(PbMsgId.AskForCanEatPattyResult, self, Activity.askForCanEatPattyResult)

  net.registMsgCallback(PbMsgId.FightErrorBS2CS,self,Activity.onCheckBossFightResult)
  net.registMsgCallback(PbMsgId.BossQueryDataResultS2C, self, Activity.BossQueryDataResult)
  net.registMsgCallback(PbMsgId.AskForMonthRegisterStateResult, self, Activity.askSignedCountResult)
  net.registMsgCallback(PbMsgId.BossDamageNoticeS2C, self, Activity.updateBossDamage)
  net.registMsgCallback(PbMsgId.BossFightStateS2C, self, Activity.updateBossState)
  net.registMsgCallback(PbMsgId.BossFightResultS2C, self, Activity.bossFightResult)
  net.registMsgCallback(PbMsgId.ActivityProgressS2C, self, Activity.updateActivityProgress)

  self:initData()

  self:setPlusCardVisible(true)
  self:setIsAlreadySigned(true)
  self:setSignedCount(0)
end

function Activity:instance()
  if Activity._instance == nil then 
    Activity._instance = Activity.new() 
  end
  return Activity._instance
end

function Activity:checkActivityMsg()
  echo("Activity:checkActivityMsg")
  self:askForMonthRegister()
  self:askForBossFight()
  self:askForCanEatPatty()   
end 

function Activity:askForBossFight()
  net.sendMessage(PbMsgId.BossQueryDataC2S)
end

function Activity:askForMonthRegister()
  echo("askForMonthRegister")
  net.sendMessage(PbMsgId.AskForMonthRegisterState)
end 

function Activity:cleanup()
  echo("---Activity:cleanup---")
  net.unregistAllCallback(self)
  Activity._instance = nil
end

function Activity:setDelegate(Delegate)
	self._Delegate = Delegate
end

function Activity:getDelegate()
	return self._Delegate
end

------
--  Getter & Setter for
--      Activity._TargetBoss 
-----
function Activity:setTargetBoss(TargetBoss)
	self._TargetBoss = TargetBoss
end

function Activity:getTargetBoss()
	return self._TargetBoss
end
--
--function Activity:setTargetBossId(bossId)
--  self._targetBossId = bossId
--end 
--
--function Activity:getTargetBossId()
--  return self._targetBossId
--end 

function Activity:getBossById(id)

  for i=1, table.getn(self.bossArray) do 
    if self.bossArray[i]:getId() == id then 
      return self.bossArray[i]
    end
  end
  return nil
end

function Activity:reqBossFight(boss,isQuickFight)
  self._isQuickFight = isQuickFight
  self:setTargetBoss(boss)
  _showLoading()
  local data = PbRegist.pack(PbMsgId.BossFightCheckC2S, {boss=boss:getId()})
  net.sendMessage(PbMsgId.BossFightCheckC2S, data)
  --self.loading = Loading:show()
end

function Activity:onCheckBossFightResult(action,msgId,msg)
  echo("Activity:onCheckBossFightResult:", msg.info.fightType, msg.error)
--  echo("---------self.loading", self.loading)
--  if self.loading ~= nil then
--    self.loading:remove()
--    self.loading = nil
--  end
  _hideLoading()

  if self:getDelegate() ~= nil then
    self:getDelegate():startBattle(msg, self:getTargetBoss(),self._isQuickFight)
  end
end

function Activity:updateActivityProgress(action,msgId,msg)
  echo("=== updateActivityProgress")
  local tbl = self:getActProgress()
  for k, v in pairs(msg.activity) do 
    echo(" actId, same_index, progress:", v.id, v.index, v.progress)
    tbl[v.id][v.index] = v.progress
  end 
end 

function Activity:getActProgress(actId)
  if self.actProgress == nil then 
    self.actProgress = {}
    for k, v in pairs(AllConfig.activity) do 
      if self.actProgress[v.activity_id] == nil then 
        self.actProgress[v.activity_id] = {}
      end 
      self.actProgress[v.activity_id][v.act_same_index] = 0
    end 
  end 

  if actId then --获取有效时间的一项
    local leftSec, id = self:getActivityLeftTime(actId)
    local index = 1 
    if leftSec > 0 then 
      index = AllConfig.activity[id].act_same_index 
    end 
    return self.actProgress[actId][index]
  else 
    return self.actProgress
  end 
end 

function Activity:getEatPattyTime(timeIdx)
  if self.eatTime == nil then 
    local begin1 = math.floor(AllConfig.dailyevent[5].open_time) 
    local end1 = math.floor(AllConfig.dailyevent[5].close_time) 
    local begin2 = math.floor(AllConfig.dailyevent[6].open_time) 
    local end2 = math.floor(AllConfig.dailyevent[6].close_time) 
    echo("==========eat time=", begin1, end1, begin2, end2)
    self.eatTime = {begin1,end1,begin2,end2}
  end 

  return self.eatTime[timeIdx]
end 

function Activity:getEatPattyTimeIdx()
  local timeTable = Clock:Instance():getCurServerTimeAsTable()
  local curMin = timeTable.hour*60 + timeTable.min

  local index = 0
  if curMin >= self:getEatPattyTime(1) and curMin <= self:getEatPattyTime(2) then
    index = 0 --12:00 -- 14:00
  else 
    index = 1 --18:00 -- 20:00
  end
  
  return index
end

-- state: 1:before valid eat time; 2: in valid eat time; 3:after valid eat time
function Activity:getStateAndLeftTimeForEatPatty(canBeenEaten)
  local timeTable = Clock:Instance():getCurServerTimeAsTable()
  local curMin = timeTable.hour*60 + timeTable.min

  local state = 0  
  local leftTime = 0
  local eatBeginTime1 = self:getEatPattyTime(1)
  local eatEndTime1 = self:getEatPattyTime(2)
  local eatBeginTime2 = self:getEatPattyTime(3)
  local eatEndTime2 = self:getEatPattyTime(4)
  
  if curMin < eatBeginTime1 then 
    state = 1
    leftTime = eatBeginTime1 - curMin
  elseif curMin <= eatEndTime1 then 
    if canBeenEaten == false then 
      state = 1
      leftTime = eatBeginTime2 - curMin
    else 
      state = 2
      leftTime = eatEndTime1 - curMin
    end
  elseif curMin < eatBeginTime2 then 
    state = 1
    leftTime = eatBeginTime2 - curMin
  elseif curMin <= eatEndTime2 then 
    if canBeenEaten == false then 
      state = 3
    else 
      state = 2
      leftTime = eatEndTime2 - curMin
    end
  else
    state = 3
  end
  echo("================left sec:", leftTime)
  return state, leftTime*60
end

function Activity:getLevelBonus()
  local bonus = {}
  local tbl = {}
  local dropItem 
  local level = GameData:Instance():getCurrentPlayer():getLevel()
  for k,v in pairs(AllConfig.signupbonus) do
      if  v.type == 5 then
        local item = {}

        for m, dropId in pairs(v.bonus) do 
          dropItem = AllConfig.drop[dropId]
          if level >= dropItem.min_level and level <= dropItem.max_level then 
            local bonusGroup = dropItem.drop_data 
            for i=1, table.getn(bonusGroup) do
              table.insert(item, bonusGroup[i].array)
            end
          end       
        end 

        table.insert(bonus, {level= v.condition, data = item})
      end
  end

  -- self:sortBonus(bonus)
  local function sortTables(a, b)
     return a.level < b.level
  end 
  table.sort(bonus, sortTables)
  
  --先插入未领取项，最后插入已领取项
  local rewardIndex = GameData:Instance():getCurrentPlayer():getLevelReward()
  for k, v in pairs(bonus) do 
    if rewardIndex < k then 
      v.hasFetched = false 
      table.insert(tbl, v)
    end 
  end

  for k, v in pairs(bonus) do 
    if rewardIndex >= k then 
      v.hasFetched = true  
      table.insert(tbl, v)
    end
  end

  return tbl
end

function Activity:sortBonus(tbl)
  if tbl == nil then
    return
  end

  local endIdx = table.getn(tbl)

  for i=1, endIdx-1 do 
    local k = i 
    for j=i+1, endIdx do 
      if tbl[k].level > tbl[j].level then 
        k = j
      end
    end  

    if k > i then 
      local tmp =  tbl[k]
      tbl[k] = tbl[i]
      tbl[i] = tmp 
    end
  end
end


function Activity:getSignInBonus()
  local dateInfo = Clock:Instance():getCurServerTimeAsTable()

  echo("===getSignInBonus, month=", dateInfo.month)
  if self._bonusgroup == nil or self._signupmonth ~= dateInfo.month then 
    self._bonusgroup = {}
    self._animEffect = {}
    self._signupmonth = dateInfo.month 

    local dropItem
    local level = GameData:Instance():getCurrentPlayer():getLevel()
    for k,v in pairs(AllConfig.signupbonus) do
      if  v.type == 2 and v.month == self._signupmonth then        
        local item = {}

        for m, dropId in pairs(v.bonus) do 
          dropItem = AllConfig.drop[dropId]
          if level >= dropItem.min_level and level <= dropItem.max_level then 
            local bonusGroup = dropItem.drop_data 
            for i=1, table.getn(bonusGroup) do
              table.insert(item, bonusGroup[i].array)
            end  
          end 
        end 

        -- echo("=== k = ", k, v.bonus[1].array[2])
        self._bonusgroup[v.condition] = item
        self._animEffect[v.condition] = v.effect
      end
    end
  end 

  return self._bonusgroup, self._animEffect
end

function Activity:BossQueryDataResult(action,msgId,msg)
  echo("===Activity:BossQueryDataResult===")

--  if self.loading ~= nil then
--    self.loading:remove()
--    self.loading = nil
--  end
  _hideLoading()

  local bossArray = self:getAllBoss()

  for i=1, table.getn(msg.list) do 
    for j=1, table.getn(bossArray) do 
      if msg.list[i].boss == bossArray[j]:getId() then 
        echo(" is active boss, hp:", bossArray[j]:getName(), bossArray[j]:getId(), msg.list[i].hpper)
        bossArray[j]:setBossState(BossState.FIGHTING) --讨伐中
        bossArray[j]:setExtPlusCards(msg.list[i].card)
        bossArray[j]:setFrozenTime(msg.list[i].self.cd)
        bossArray[j]:setSpeedUpCount(msg.list[i].self.relive)
        local curHp = math.floor(bossArray[j]:getTotalHp()*msg.list[i].hpper/10000)
        bossArray[j]:setHp(curHp)
        --top 3 players' rank
        bossArray[j]:updateTopPlayerRank(msg.list[i].rank.rank)
        bossArray[j]:setDamageForPlayer(msg.list[i].self.damage)

        --update list if need
        CCNotificationCenter:sharedNotificationCenter():postNotification(EventType.BOSS_UPDATE)
      end
    end
  end
end

function Activity:askSignedCountResult(action,msgId,msg)
  echo("---Activity:askSignedCountResult: int=",msg.month_information)

  self:updateSignInInfo(msg.month_information)
end

function Activity:updateSignInInfo(month_information)
  local num = 0
  for i=0, 31 do
  local val=bit.rshift(month_information, i)
    if bit.band(val, 1) == 1 then
      num = num + 1
    end
  end
  echo(" updateSignInInfo: signed count = ", num)
  self:setSignedCount(num)
  if num < 31 then 
    local timeTable = Clock:Instance():getCurServerTimeAsTable()
    local val=bit.rshift(month_information, timeTable.day)
    if bit.band(val, 1) == 1 then
      self:setIsAlreadySigned(true)
    else
      self:setIsAlreadySigned(false)
    end
  else 
    self:setIsAlreadySigned(false)
  end 
end

--总共已经签到的次数
function Activity:setSignedCount(count)
  self.signedCount = count
end

function Activity:getSignedCount()
  return self.signedCount
end

--当天是否已领取
function Activity:setIsAlreadySigned(bSigned)
  self.alreadySigned = bSigned
end

function Activity:getIsAlreadySigned()
  local flag = GameData:Instance():checkSystemOpenCondition(7, false)
  if flag == false then
    return true
  end
  return self.alreadySigned
end

function Activity:getCanBuyGrowPlan()
  local viplevel = GameData:Instance():getCurrentPlayer():getVipLevel()
  if AllConfig.vipinitdata[viplevel+1].vip_cultivate > 0 then 
    return true 
  end 

  return false 
end 

function Activity:getCanFetchGrowBonus()
  if self:getCanBuyGrowPlan() == false then 
    return false  
  end 
  
  local hasBonusForFetch =false 
  local plans = self:getAllGrowthPlans()
  if plans[1].hasFetched == false and GameData:Instance():getCurrentPlayer():getLevel() >= plans[1].level then 
    hasBonusForFetch = true 
  end 

  echo("getCanFetchGrowBonus:", hasBonusForFetch)
  return hasBonusForFetch 
end 

function Activity:getCanFetchVipGif()
  local canFetch = false 
  local player = GameData:Instance():getCurrentPlayer()
  if player:getIsVipState() then 
    canFetch = player:checkCanFetchVipGif()    
  end 

  echo("getCanFetchVipGif:", canFetch)
  return canFetch 
end

function Activity:getAllCardHeaderPic()
  if self.allHeaderPicArray == nil then 
    local tmpTbl = {}
    local prePicId = 0
    for k, v in pairs(AllConfig.unit) do 
      if v.unit_head_pic ~= prePicId then 
        prePicId = v.unit_head_pic
        table.insert(tmpTbl, v.unit_head_pic)
      end
    end

    --sort to table
    local num = table.getn(tmpTbl)
    for i=1, num-1 do 
      local k = i 
      for j=i+1, num do 
        if tmpTbl[k] > tmpTbl[j] then 
          k = j
        end
      end

      if k > i then 
        local tmp = tmpTbl[k]
        tmpTbl[k] = tmpTbl[i]
        tmpTbl[i] = tmp 
      end
    end

    self.allHeaderPicArray = {}
    prePicId = 0
    for i=1, table.getn(tmpTbl) do 
      if tmpTbl[i] ~= prePicId then 
        prePicId = tmpTbl[i]
        table.insert(self.allHeaderPicArray, tmpTbl[i])
      end
    end
  end

  return self.allHeaderPicArray
end

function Activity:sortBossByLeftTime(tbl, startIdx, endIdx)
  if endIdx < startIdx then 
    return 
  end

  for i=startIdx, endIdx-1 do 
    local k = i 
    for j=i+1, endIdx do 
      if tbl[k]:getLeftTime(false, nil) < tbl[j]:getLeftTime(false, nil) then 
        k = j
      end
    end

    if k > i then 
      local tmp = tbl[k]
      tbl[k] = tbl[i]
      tbl[i] = tmp
    end
  end
end

function Activity:sortBoss(tbl)
  if tbl == nil or table.getn(tbl) < 1 then 
    echo("sortBoss: empty boss array..")
    return
  end 

  local bossNum = table.getn(tbl)

  --1.init current left time and status
  local curDate = Clock:Instance():getCurServerTimeAsTable()
  for i=1, bossNum do 
    tbl[i]:getLeftTime(true, curDate)
    tbl[i]:getBossState(true)
  end

  --2.start sort by states
  for i=1, bossNum-1 do 
    local k = i 
    for j=i+1, bossNum do 
      if tbl[k]:getBossState(false) > tbl[j]:getBossState(false) then 
        k = j
      end
    end

    if k > i then
      local tmp = tbl[k]
      tbl[k] = tbl[i]
      tbl[i] = tmp
    end
  end

  --3. sort by left time for same status
  local preType = tbl[1]:getBossState(false)
  local startIdx = 1

  for i = 2, bossNum do
    local curType = tbl[i]:getBossState(false)
    if i < bossNum then 
      if curType ~= preType then 
        self:sortBossByLeftTime(tbl, startIdx, i-1)

        startIdx = i
        preType = curType
      end
    else 
      if curType ~= preType then 
        self:sortBossByLeftTime(tbl, startIdx, i-1)
      else
        self:sortBossByLeftTime(tbl, startIdx, i)
      end
    end
  end
end

function Activity:getRecentBoss()
  local recentBoss = {}

  local timeTable = Clock:Instance():getCurServerTimeAsTable()
  local curSec = timeTable.hour*3600 + timeTable.min*60 + timeTable.sec
  -- echo("getRecentBoss: hour, min, sec=", timeTable.hour, timeTable.min, timeTable.sec)
  local validSec = 2*24*3600 - curSec
  local boss = self:getAllBoss()
  for k, v in pairs(boss) do 
    local lt = v:getLeftTime(true, timeTable)
    if lt < validSec then
      table.insert(recentBoss, v)
    end
  end

  --sort boss
  self:sortBoss(recentBoss)

  return recentBoss
end

-- function Activity:getTimeForNextOpeningBoss()
--   local recentBoss = self:getRecentBoss()
--   local leftTime = 0 
--   for i=#recentBoss, 1, -1 do 
--     if recentBoss[i]:getBossState() == BossState.BEFORE_OPEN then
--       leftTime = recentBoss[i]:getLeftTime(false, nil)
--       echo("=== next boss, leftTime:", recentBoss[i]:getName(), leftTime)
--       break 
--     end 
--   end 

--   return leftTime
-- end 

function Activity:getBossOpenTime()
  if self.bossOpenTime == nil then 
    local openTime1 = nil 
    local openTime2 = nil
    local closeTime1 = nil 
    local closeTime2 = nil
    for k, v in pairs(AllConfig.bossinitdata) do 
      if openTime1 == nil then 
        openTime1 = v.open_time 
        closeTime1 = v.close_time 
      end
      if openTime1 ~= nil and openTime1 ~= v.open_time then 
        openTime2 = v.open_time
        closeTime2 = v.close_time
        break 
      end 
    end 
    echo("=== boss open time:", openTime1, openTime2)
    self.bossOpenTime = {openTime1, openTime2, closeTime1, closeTime2}
  end 

  return self.bossOpenTime
end 

function Activity:isValidBossTime()
  local timeTable = Clock:Instance():getCurServerTimeAsTable()
  local curMin = timeTable.hour*60 + timeTable.min
  local flag = false 
  local validTime = self:getBossOpenTime()
  if (curMin >= validTime[1] and curMin <= validTime[3]) or (curMin >= validTime[2] and curMin <= validTime[4]) then 
    flag = true 
  end 

  echo("===isValidBossTime:", flag, timeTable.hour, timeTable.min)
  return flag 
end 

function Activity:initData()
  echo("Activity:initData")

  --self:setIsCanEatPatty(false)
  --self:setIsAlreadySigned(false)

  self.bossArray = {}
  for k, v in pairs(AllConfig.bossinitdata) do
    local boss = Boss.new(v)
    table.insert(self.bossArray, boss)
  end

  self.moneyTreeCost = {}
  for k, v in pairs(AllConfig.cost) do
    if v.type == 13 then
      for i=v.min_count, v.max_count do 
        self.moneyTreeCost[i] = v.cost
      end
    end
  end  
end

function Activity:getAllBoss()
  return self.bossArray
end

function Activity:getAllMoneyTreeCost()
  return self.moneyTreeCost
end

--this manage for every one
function Activity:updateBossDamage(action,msgId,msg)

  echo("===Activity:updateBossDamage:boss id,damage,hp=",msg.damage.boss, msg.damage.damage, msg.damage.hp)
  for k, v in pairs(self.bossArray) do 
    if v:getId() == msg.damage.boss then 
      v:setDamage(msg.damage.damage)
      local curHp = math.floor(v:getTotalHp()*msg.damage.hp/10000)
      v:setHp(curHp)
      break
    end
  end
end

function Activity:updateBossState(action,msgId,msg)
  echo("=== Activity:updateBossState ===:", msg.boss, msg.state)
  --dump(msg, "=====updateBossState")
  for k, v in pairs(self.bossArray) do 
    if v:getId() == msg.boss then 
      if msg.state == "BOSS_OPEN" then 
        if self:isValidBossTime() then 
          v:setBossState(BossState.FIGHTING)
        else 
          echo("=== waiting time to open boss....")
          v:setBossState(BossState.WAITING_FOR_OPEN) --如果时间未到则等待开启
        end 

      elseif msg.state == "BOSS_CLOSE" then
        v:setBossState(BossState.CLOSE) --关闭或已击杀
      end
      
      --update plus cards
      v:setExtPlusCards(msg.card)
      break
    end
  end  
end

function Activity:getCurActiveBoss()
  local allBoss = self:getAllBoss() 
  for k, v in pairs(allBoss) do 
    if v:getBossState() == BossState.FIGHTING then 
      return v 
    end 
  end 
  return nil 
end 

--this damage just for myself
function Activity:bossFightResult(action,msgId,msg)
  echo("=== Activity:bossFightResult ===")

  local boss = nil
   for k, v in pairs(self.bossArray) do
    if v:getId() == msg.damage.boss then
      boss = v
      break
    end
  end

  if boss ~= nil then
    echo("update cur /total damage=", msg.damage.damage, msg.data.damage)
    --update player damage
    boss:setDamage(msg.damage.damage) --latest one damage
    boss:setDamageForPlayer(msg.data.damage) --total damage
    local curHp = math.floor(boss:getTotalHp()*msg.damage.hp/10000)
    boss:setHp(curHp)
    boss:setFrozenTime(msg.data.cd)
    if msg.damage.hp <= 0 then
      boss:setBossState(BossState.KILLED) --已击杀
      boss:setFrozenTime(0)
    end

    echo("### fight result: damage.hp ,cd =", msg.damage.hp,msg.data.cd)
  end
end

function Activity:setArmyDelegate(target)
  self.armyDelegate = target
end

function Activity:getArmyDelegate()
  return self.armyDelegate
end

function Activity:checkEatPartyTime()
  local timeTable = Clock:Instance():getCurServerTimeAsTable()
  local curMin = timeTable.hour*60 + timeTable.min

  local isValid = false
  if (curMin >= self:getEatPattyTime(1) and curMin <= self:getEatPattyTime(2)) or 
     (curMin >= self:getEatPattyTime(3) and curMin <= self:getEatPattyTime(4)) then   

    echo("===in valid eat party time, and send msg to server...")
    --send msg
    self:askForCanEatPatty()
  else 
    echo(" not in eat party time.")
  end 
end 

function Activity:setIsCanEatPatty(isEatable)
  self.parryIsEatable = isEatable
end 

function Activity:getIsCanEatPatty()
  return self.parryIsEatable
end 

--can only set when boss opened
function Activity:getBossTipFlag()
  local hasBossTip = false 
  local flag, _ = GameData:Instance():checkSystemOpenCondition(5, false)
  if flag == false then
    return false 
  end

  return self:isValidBossTime() 
end 

function Activity:getHasBonusForLevelup()
  local bonusInfo = self:getLevelBonus()
  local rewardIndex = GameData:Instance():getCurrentPlayer():getLevelReward()
  local isFinish = (rewardIndex == #bonusInfo)
  local bonusLevel = bonusInfo[1].level 
  local hasBonusForFetch = false 

  if bonusInfo[1].hasFetched == false and GameData:Instance():getCurrentPlayer():getLevel() >= bonusLevel then 
    hasBonusForFetch = true 
  end 

  echo("getHasBonusForLevelup:", rewardIndex, hasBonusForFetch, bonusLevel, isFinish)
  return hasBonusForFetch, bonusLevel, isFinish
end

function Activity:askForCanEatPatty()
  local data = PbRegist.pack(PbMsgId.AskForCanEatPatty)
  net.sendMessage(PbMsgId.AskForCanEatPatty, data)
end 

function Activity:askForCanEatPattyResult(action,msgId,msg)
  echo("askForCanEatPattyResult: ", msg.state)
  if msg.state == "Ok" then
    self:setIsCanEatPatty(true)
  else
    self:setIsCanEatPatty(false)
  end

  if self:getArmyDelegate() ~= nil then
    self:getArmyDelegate():updateByMsgState(msg.state)
  end
end


function Activity:getHasNewTip()
  local needToTip = false

  local flag1 = self:getIsCanEatPatty()
  local flag2 = self:getHasBonusForLevelup()
  local flag3 = self:getIsAlreadySigned()
  local flag4 = self:getBossTipFlag()
  local flag5 = self:getCanFetchGrowBonus()
  local flag6 = self:getCanFetchVipGif()
  echo("---getHasNewTip: flag=", flag1,flag2,flag3,flag5)

  if (flag1 == true) or (flag2 == true) or (flag3 == false) or (flag5 == true) or (flag6 == true) then 
    needToTip = true
  end

  return needToTip
end


function Activity:getReliveCost(index)
  if self._reliveCost == nil then 
    self._reliveCost = {}
    for k, v in pairs(AllConfig.cost) do 
      if v.type == 5 then
        for i = v.min_count, v.max_count do 
          self._reliveCost[i] = v.cost
        end
      end
    end
  end

  local len = table.getn(self._reliveCost)
  if index > len then
    index = len
  end
  return self._reliveCost[index]
end

function Activity:getAllGrowthPlans()
  local tbl = {}
  local fetchedTbl = {}

  local count = GameData:Instance():getCurrentPlayer():getRewardCountForGrowPlan()
  for k, v in pairs(AllConfig.rebate) do 
    local item = {level=v.active_level, money=v.gain_gold, iconId=v.icon_pic}
    if count >= k then 
      item.hasFetched = true 
      table.insert(fetchedTbl, item)
    else 
      item.hasFetched = false 
      table.insert(tbl, item)
    end 
  end

  for k, v in pairs(fetchedTbl) do 
    table.insert(tbl, v)
  end 

  return tbl 
end

function Activity:getAllVipBonus()
  local tbl = {}

  for i=1, table.getn(AllConfig.vipsignup) do
    local group = AllConfig.vipsignup[i].bonus
    local tmpItem = {}
    for k=1, table.getn(group) do 
      table.insert(tmpItem, group[k].array)
    end
    table.insert(tbl, {bonus = tmpItem, dayIndex=1, hasFetched=false, canFetched=false})
  end

  local fetchDayIndex = 1 
  local canFetch = GameData:Instance():getCurrentPlayer():checkCanFetchVipGif()
  local count = GameData:Instance():getCurrentPlayer():getRewardCountForVipGif()
  local nextDay = count%7 + 1

  for k, v in pairs(tbl) do 
    v.dayIndex = k 
    if k < nextDay then 
      v.hasFetched = true 
      v.canFetched = false  
    elseif k == nextDay then 
      v.hasFetched = false  
      v.canFetched = canFetch  
      fetchDayIndex = k 
    else 
      v.hasFetched = false  
      v.canFetched = false 
    end 
  end 

  --将可领取排前面,已领取排后面
  local tmp = {}
  for i=fetchDayIndex, #tbl do 
    table.insert(tmp, tbl[i])
  end 

  for i=1, fetchDayIndex-1 do 

    table.insert(tmp, tbl[i])
  end 
  
  return tmp
end

function Activity:getVipInfoData()
  if self._vipPrivilegeData == nil then 
    self._vipPrivilegeData = {}
    for k, v in pairs(AllConfig.vipinitdata) do 
      -- if v.vip_level > 0 then 
        table.insert(self._vipPrivilegeData, v)
      -- end 
    end 
  end 

  return self._vipPrivilegeData
end 

function Activity:setTabMenuOffsetX(offsetX)
  self._tabOffsetX = offsetX
end

function Activity:getTabMenuOffsetX()
  if self._tabOffsetX == nil then 
    self._tabOffsetX = 0
  end
  return self._tabOffsetX
end

function Activity:setPlusCardVisible(isVisible)
  self._isPlusCardsShowing = isVisible
end

function Activity:getPlusCardVisible()
  return self._isPlusCardsShowing
end

function Activity:getExchangeArray(actId)
  local timeTable = Clock:Instance():getCurServerTimeAsTable()
  local curDate = timeTable.year * 10000 + timeTable.month * 100 + timeTable.day
  echo("===== actId", actId)
  local tbl = {} 
  for k, v in pairs(AllConfig.exchange) do 
    if v.activity_id == actId then 
      if (curDate >= v.open_time and curDate < v.close_time) then 
        table.insert(tbl, v) 
      end 
    end 
  end 

  return tbl 
end 

function Activity:getChargeBonus()
  local tbl = {} 
  local dropItem
  local level = GameData:Instance():getCurrentPlayer():getLevel()
  local leftSec, id = self:getActivityLeftTime(ACI_ID_CHARGE_BONUS)

  if leftSec > 0 then 
    local act_same_index = AllConfig.activity[id].act_same_index 
    for k, v in pairs(AllConfig.activity_commodity) do 
      if v.activity_id == ACI_ID_CHARGE_BONUS and v.act_same_index == act_same_index then 
        local bonusdata = {}       
        dropItem = AllConfig.drop[v.drop_id]
        if level >= dropItem.min_level and level <= dropItem.max_level then 
          for m, n in pairs(dropItem.drop_data) do 
            table.insert(bonusdata, n.array)
          end 
        end 
        table.insert(tbl, {countCondition=v.drop_condition, bonus=bonusdata})
      end 
    end 
  end 

  return tbl 
end 

function Activity:getMoneyConsumeBonus()
  local tbl = {} 
  local dropItem
  local level = GameData:Instance():getCurrentPlayer():getLevel()
  local leftSec, id = self:getActivityLeftTime(ACI_ID_CONSUME_MONEY)

  if leftSec > 0 then 
    local act_same_index = AllConfig.activity[id].act_same_index 
    for k, v in pairs(AllConfig.activity_consume_money) do 
      if v.activity_id == ACI_ID_CONSUME_MONEY and v.act_same_index == act_same_index then 
        for m, dropId in pairs(v.drop) do 
          local bonusdata = {}
          dropItem = AllConfig.drop[dropId]
          if level >= dropItem.min_level and level <= dropItem.max_level then           
            for m, n in pairs(dropItem.drop_data) do 
              table.insert(bonusdata, n.array)
            end 
          end 
          table.insert(tbl, {countCondition=v.data, bonus=bonusdata})
        end 
      end 
    end 
  end 

  return tbl 
end 

function Activity:getExchangeTimesLimit(needReset)
  if self._exchangeLimit == nil or needReset == true then 
    self._exchangeLimit = {}

    for k, v in pairs(AllConfig.exchange) do 
      self._exchangeLimit[v.id] = {}
      if v.daily_exchange == 0 then 
        self._exchangeLimit[v.id].totalCount = -1
      else 
        self._exchangeLimit[v.id].totalCount = v.daily_exchange
      end 

      self._exchangeLimit[v.id].usedCount = 0 
      self._exchangeLimit[v.id].leftCount = v.daily_exchange
    end 
  end 

  return self._exchangeLimit
end 

function Activity:updateExchangeTimesLimit(msgRecords)
  local len = #msgRecords
  local needRefresh = false 
  if len == 0 then --表示刚登录或者零点时数据清零操作
    needRefresh = true 
  end 
  local tbl = self:getExchangeTimesLimit(needRefresh)
  echo("=== updateExchangeTimesLimit: needRefresh=", needRefresh)
  for k, v in pairs(msgRecords) do 
    echo("====v.id, used count", v.id, v.count)
    if tbl[v.id] ~= nil then 
      tbl[v.id].usedCount = v.count 
      tbl[v.id].leftCount = math.max(0, tbl[v.id].totalCount - tbl[v.id].usedCount)
    end 
  end 
end 

function Activity:getOpenCloseTime(dateType, openDate, closeDate)
  local openTime = -1
  local closeTime = -1

  if dateType == 1 then --正常本地时间 
    if openDate > 0 then 
      openTime = Clock:Instance():getTimeByDate(openDate)
    end 
    if closeDate > 0 then 
      closeTime = Clock:Instance():getTimeByDate(closeDate)
    end

  elseif dateType == 2 then --开服时间起
    openTime = openDate*24*3600 + Clock:Instance():getServerOpenTime(false)
    closeTime = closeDate*24*3600 + Clock:Instance():getServerOpenTime(false)

  elseif dateType == 3 then --角色创建时间起
    openTime = openDate*24*3600 + Clock:Instance():getPlayerCreateTime(false)
    closeTime = closeDate*24*3600 + Clock:Instance():getPlayerCreateTime(false)    
  end 

  return openTime, closeTime 
end 

function Activity:getActivityLeftTime(actId)

  local id
  local leftSec = -1
  local curTime = Clock:Instance():getCurServerTime()

  for k, v in pairs(AllConfig.activity) do 
    if v.activity_id == actId then 
      id = v.id 

      local openTime, closeTime = self:getOpenCloseTime(v.date_type, v.open_date, v.close_date)

      if openTime < 0 or closeTime < 0 then --每天开启
        leftSec = 24*3600 
      else 
        if curTime < openTime then 
          leftSec = -1
          echo("=== activity not open ..")
        else 
          leftSec = closeTime - curTime
        end 
      end 

      if leftSec > 0 and self:getActivityOpenState(v.activity_id, v.act_same_index) then 
        break 
      else 
        leftSec = -1 
      end 
    end 
  end 

  echo("显示时间=== getActivityLeftTime:id, actId,leftSec=", id, actId, leftSec)
  return leftSec, id 
end 

function Activity:getActItemLeftTime(actItem)
  --如果服务器强制关闭该活动则返回
  if self:getActivityOpenState(actItem.activity_id, actItem.act_same_index) == false then 
    echo("=== force close activity by server :", actItem.activity_id, actItem.act_same_index)
    return -1
  end 

  local leftSec = -1 
  local curTime = Clock:Instance():getCurServerTime()
  local openTime, closeTime = self:getOpenCloseTime(actItem.date_type, actItem.open_date, actItem.close_date)
  if openTime < 0 or closeTime < 0 then --每天开启
    leftSec = 24*3600 
  else 
    if curTime < openTime then          
      leftSec = -1
      echo("=== activity not open ..", actItem.id, actItem.activity_id, leftSec)
    else 
      leftSec = closeTime - curTime
    end 
  end 

  echo("=== getActItemLeftTime:", actItem.id, actItem.activity_id, leftSec)
  return leftSec
end 


function Activity:initActivityOpenState(pbMsg)
  if self.actOpenState == nil then 
    self.actOpenState = {}
  end 

  for k, v in pairs(pbMsg.activity) do 
    echo("=== initActivityOpenState:", v.type, v.index, v.state)
    if self.actOpenState[v.type] == nil then 
      self.actOpenState[v.type] = {}
    end 
    self.actOpenState[v.type][v.index] = v.state 
  end 
end 

function Activity:getActivityOpenState(actId, sameIndex)
  sameIndex = sameIndex or 1 
  if self.actOpenState[actId] == nil or self.actOpenState[actId][sameIndex] == nil then --default open
    return true 
  end 

  return self.actOpenState[actId][sameIndex] > 0 
end 

--活动模块显示菜单
function Activity:getMenusArray()
  local menusArray = {
                      {ActMenu.ARMY, "act_bn_1.png", nil}, 
                      {ActMenu.REBATE_ONE, "act_bn_8.png", "act_xianshi.png"}, --单抽返利
                      {ActMenu.REBATE_TEN, "act_bn_9.png", "act_xianshi.png"}, --十连抽返利
                      {ActMenu.MONEY_CONSUME, "act_bn_16.png", nil},   --元宝消耗奖励
                      {ActMenu.CHARGE_REBATE, "act_bn_12.png", nil},  --充值送卡
                      {ActMenu.CHARGE_BONUS, "act_bn_14.png", nil},   --累计充值奖励
                      {ActMenu.ZHONG_QIU, "act_bn_11.png", nil},      --中秋
                      {ActMenu.EXCHANGE, "act_bn_10.png", nil},       --兑换活动
                      {ActMenu.BIG_WHEEL,"act_bn_17.png",nil},        --大转盘
                      {ActMenu.CARD_REPLACE,"act_bn_18.png",nil},    --卡牌替换
                      {ActMenu.QUICK_MONEY, "act_bn_19.png",nil},     --财源滚滚
                      {ActMenu.MONEY_TREE, "act_bn_7.png", nil},      --摇钱树
                      {ActMenu.VIP_SIGNIN, "act_bn_6.png", nil},     --VIP签到
                      {ActMenu.GROW_PLAN, "act_bn_5.png", nil},      --成长计划
                      {ActMenu.DAILY_SIGNIN, "act_bn_3.png", nil},  --每日奖励                      
                      {ActMenu.LEVELUP_BONUS, "act_bn_2.png", nil}, --升级奖励
                      {ActMenu.VIP_PRIVILEGE, "act_bn_15.png", nil},--VIP特权
                      {ActMenu.BOSS, "act_bn_4.png", nil},          --BOSS
                      {ActMenu.ARENA, "act_bn_13.png", nil}         --武斗大会
                     }

  local function removeMenu(menuType) 
    for k, v in pairs(menusArray) do
      if v[1] == menuType then
        table.remove(menusArray, k)
        break 
      end
    end
  end 

  if GameData:Instance():getLanguageType() == LanguageType.JPN then 
    removeMenu(ActMenu.VIP_PRIVILEGE)
    removeMenu(ActMenu.GROW_PLAN)
    removeMenu(ActMenu.VIP_SIGNIN)
    removeMenu(ActMenu.REBATE_ONE)
    removeMenu(ActMenu.REBATE_TEN)    
  end 

  if Mall:Instance():isShowRebateView(1) == false then
    removeMenu(ActMenu.REBATE_ONE)
  end 

  if Mall:Instance():isShowRebateView(2) == false then
    removeMenu(ActMenu.REBATE_TEN)
  end 


  if self:getActivityLeftTime(ACI_ID_EXCHANGE) <= 0 then --移除Q卡兑换菜单
    removeMenu(ActMenu.EXCHANGE)
  end 

  if self:getActivityLeftTime(ACI_ID_MID_AUTUMN) <= 0 then --移除中秋兑换菜单
    removeMenu(ActMenu.ZHONG_QIU)
  end 

  if self:getActivityLeftTime(ACI_ID_CHARGE_REBATE) <= 0 then --充值送张飞
    removeMenu(ActMenu.CHARGE_REBATE)
  end 

  if self:getActivityLeftTime(ACI_ID_CHARGE_BONUS) <= 0 then --累计充值奖励
    removeMenu(ActMenu.CHARGE_BONUS)
  end 

  if self:getActivityLeftTime(ACI_ID_CONSUME_MONEY) <= 0 then --元宝消耗奖励
    removeMenu(ActMenu.MONEY_CONSUME)
  end 

  if self:getActivityLeftTime(ACT_ID_BIG_WHEEL) <= 0 then --大转盘
    removeMenu(ActMenu.BIG_WHEEL)
  end 

  if self:getActivityLeftTime(ACT_ID_CARD_REPLACE) <= 0 then --卡牌替换
    removeMenu(ActMenu.CARD_REPLACE)
  end 

  if self:getActivityLeftTime(ACT_ID_QUICK_MONEY) <= 0 then --财源滚滚
    removeMenu(ActMenu.QUICK_MONEY)
  end

  return menusArray
end 

function Activity:getArrayIndexByMenuId(menuId)
  local array = self:getMenusArray()
  for k, v in pairs(array) do 
    if v[1] == menuId then 
      return k
    end 
  end 

  return 1 
end 

--首次登陆时进入首页弹出的活动列表框
function Activity:getActivityPopList()
  local tbl = {}
  
  for k, v in pairs(AllConfig.activity) do 
    if #v.activity_show > 1 then 
      if self:getActItemLeftTime(v) > 0 then 
        table.insert(tbl, v)
      end 
    end 
  end 

  --sort 
  local len = #tbl 
  if len > 1 then 
    for i=1, len-1 do 
      local k = i 
      for j=i+1, len do 
        if tbl[k].activity_show[1] > tbl[j].activity_show[1] then 
          k = j
        end
      end  

      if k > i then 
        local tmp = tbl[k]
        tbl[k] = tbl[i]
        tbl[i] = tmp 
      end
    end  
  end 

  return tbl 
end 

function Activity:setDaySurpriseRebateData(dataArray)
  for k, v in pairs(dataArray) do
    echo("==============rebate id", v.rebate_id)
    if v.rebate_id == 3001 then 
      self.surpriseRebateData = {}
      echo("day surprise data:", v.rebate_id, v.rebate_count, v.current_draw_count)
      self.surpriseRebateData.rebateId = v.rebate_id
      self.surpriseRebateData.rebateCount = v.rebate_count
      -- self.surpriseRebateData.rebateTime =  v.rebate_time 
      -- self.surpriseRebateData.rebateEndTime = v.rebate_end_time 
      self.surpriseRebateData.currentDrawCount = v.current_draw_count
      break 
    end 
  end
end 

function Activity:getDaySurpriseRebateData() 
  return self.surpriseRebateData 
end 

function Activity:getDaySurpriseBonus()
  local id = 3001
  local data = self:getDaySurpriseRebateData()
  if data ~= nil then 
    id = data.rebateId
  end 

  if self.surpriseArray == nil then 
    self.surpriseArray = {}
    local dropItem
    local level = GameData:Instance():getCurrentPlayer():getLevel()

    for k, v in pairs(AllConfig.activity_rebate) do 
      if k == id then 
        local group = v.rebate_money 
        for i=1, #group do 
          local dropId = group[i].array[2]
          local items = {}
          dropItem = AllConfig.drop[dropId]
          if level >= dropItem.min_level and level <= dropItem.max_level then 
            for m, n in pairs(dropItem.drop_data) do 
              table.insert(items, n.array)
            end 
          end 
          table.insert(self.surpriseArray, items)       
        end 

        break 
      end 
    end
  end 

  return self.surpriseArray 
end 

function Activity:getCanFetchSurpriseBonus()
  local rebateData = Activity:instance():getDaySurpriseRebateData() 

  return rebateData.currentDrawCount < rebateData.rebateCount
end 

function Activity:getFestivalGifBonus()
  local tbl = {}
  local id 
  local dropItem
  local level = GameData:Instance():getCurrentPlayer():getLevel()

  for i, v in pairs(AllConfig.activity) do 
    if v.activity_id == ACI_ID_FESTIVAL_GIFT then 
      if self:getActItemLeftTime(v) > 0 then 
        id = v.id 
        for k, dropId in pairs(v.activity_drop) do 
          local items = {}
          dropItem = AllConfig.drop[dropId]
          if level >= dropItem.min_level and level <= dropItem.max_level then 
            for m, n in pairs(dropItem.drop_data) do 
              table.insert(items, n.array)
            end 
          end 
          table.insert(tbl, items)   
        end 

        break 
      end 
    end 
  end 

  return tbl, id 
end 

function Activity:isDaySurpriseValid()
  local data = self:getDaySurpriseRebateData()
  if data ~= nil and data.currentDrawCount < 7 then 
    return true 
  end 

  return false 
end

function Activity:isFestivalGiftValid()
  local isValid = false 
  local leftTime = self:getActivityLeftTime(ACI_ID_FESTIVAL_GIFT)
  local flag = GameData:Instance():getCurrentPlayer():getFestivalGiftFlag()
  echo("=== isFestivalGiftValid", leftTime, flag)
  if leftTime>0 and flag==0 then 
    isValid = true
  end 
  
  echo("=== isFestivalGiftValid:", isValid)
  return isValid 
end

function Activity:getCurrentActDayIndex(id)
  local dayIndex = 1
  local curTime = Clock:Instance():getCurServerTime()

  for k, v in pairs(AllConfig.activity) do 
    if v.id == id then 
      local openTime, _ = self:getOpenCloseTime(v.date_type, v.open_date, v.close_date)
      if curTime >= openTime then 
        dayIndex = math.ceil((curTime-openTime)/(24*3600))
      end 

      break 
    end 
  end 

  echo("getCurrentActDayIndex: id, dayIndex", id, dayIndex)
  return dayIndex 
end 

function Activity:gotoViewByActId(actId)
  local ret = true 

  echo("=== Activity:gotoViewByActId:", actId)
  if actId == ACI_ID_SCENARIO_DROP or actId == ACI_ID_SCENARIO_DROP_EX  then --最近战役副本
    local stage = Scenario:Instance():getLastNormalStage()
    local controller = ControllerFactory:Instance():create(ControllerType.SCENARIO_CONTROLLER)
    controller:enter()
    controller:gotoStageById(stage:getStageId()) 

  elseif actId == ACI_ID_CHARGE_1 then
    local controller = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
    controller:enter(ShopCurViewType.PAY)    

  elseif actId == ACI_ID_CHARGE_REBATE then --燕人张飞在此
    self:entryActView(ActMenu.CHARGE_REBATE, false)

  elseif actId == ACI_ID_LOTTERY_REBATE_CHIP then --点将送碎片
    local controller = ControllerFactory:Instance():create(ControllerType.LOTTERY_CONTROLLER)
    controller:enter()  
      
  elseif actId == ACI_ID_GROW_PLAN then --成长计划折扣
    self:entryActView(ActMenu.GROW_PLAN, false)

  elseif actId == ACI_ID_BATTLE_SPIRITE_DISCOUNT then --副本体力折扣,跳转到最近的精英副本
    if Scenario:Instance():getLastEliteCheckPoint() ~= nil then
      local controller = ControllerFactory:Instance():create(ControllerType.SCENARIO_CONTROLLER)
      controller:enter()
      controller:gotoEliteStage()
    else
      Toast:showString(GameData:Instance():getCurrentScene(),_tr("elite not open"), ccp(display.cx, display.height*0.4))
    end

  elseif actId == ACI_ID_MARKET_REFRESH_TIMES then --集市刷新次数增加
    if GameData:Instance():checkSystemOpenCondition(13, true) == false then 
      return false
    end  

    local controller = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
    controller:enter(ShopCurViewType.JiShi)

  elseif actId == ACI_ID_EXCHANGE then --Q卡三国集换
    self:entryActView(ActMenu.EXCHANGE, false)

  elseif actId == ACI_ID_ARMY then --犒赏三军  
    self:entryActView(ActMenu.ARMY, false)
  elseif actId == ACI_ID_CHARGE_BONUS then --累计充值
    self:entryActView(ActMenu.CHARGE_BONUS, false)

  elseif actId == ACI_ID_CONSUME_MONEY then --元宝消耗奖励
    self:entryActView(ActMenu.MONEY_CONSUME, false)

  -- elseif actId == ACI_ID_FESTIVAL_GIFT then --节日登录礼包

  elseif actId == ACI_ID_ACTIVITY_STAGE then --剑阁副本显示
    local controller = ControllerFactory:Instance():create(ControllerType.ACTIVITY_STAGE_CONTROLLER)
    controller:enter() 

  elseif actId == ACI_ID_MONEY_TREE_DISCOUNT or actId == ACI_ID_MONEY_TREE_DROP then --摇钱树折扣/掉落
    self:entryActView(ActMenu.MONEY_TREE, false)

  elseif actId == ACI_ID_CARD_SOUL_SHOP then --将魂商店
    if GameData:Instance():checkSystemOpenCondition(27, true) == false then 
      return false
    end  
    local controller = ControllerFactory:Instance():create(ControllerType.CARD_SOUL_CONTROLLER)
    controller:enter(CardSoulMenu.SHOP)

  elseif actId == ACT_ID_BIG_WHEEL then --大转盘
    self:entryActView(ActMenu.BIG_WHEEL, false)

  elseif actId == ACT_ID_CARD_REPLACE then --卡牌替换
    self:entryActView(ActMenu.CARD_REPLACE, false)    

  elseif actId == ACT_ID_QUICK_MONEY then --摇元宝
    self:entryActView(ActMenu.CONSUME_MONEY, false)

  else 
    ret = false 
  end 

  return ret
end 

--供外部访问活动页面
function Activity:entryActView(viewType, isSubView)
  if viewType == nil then 
    viewType = ActMenu.ARMY
  end 
  echo("=== Activity:entryActView:", viewType, isSubView)
  local controller = ControllerFactory:Instance():create(ControllerType.ACTIVITY_CONTROLLER)
  local ret = controller:enterViewByIndex(viewType, isSubView)
  if ret then 
    local menuIdx = self:getArrayIndexByMenuId(viewType)
    controller:getBaseView():setHighlighMenu(menuIdx-1)
    controller:scrollToIndex(menuIdx)
  end 

  return ret 
end 

function Activity:getHomeActData()
  local tbl = {}
  
  for k, v in pairs(AllConfig.activity) do 
    if v.showornot > 0 and self:getActItemLeftTime(v) > 0 then 
      table.insert(tbl, v)
    end 
  end 

  return tbl 
end 

--7 天开服活动
function Activity:getIsServerOpenActValid(sameIndex)
  local leftSec = 0 
  for i, v in pairs(AllConfig.activity) do 
    if v.activity_id == ACI_ID_SERVER_OPEN_BONUS then 
      if sameIndex and sameIndex == v.act_same_index then 
        return self:getActItemLeftTime(v)
      else 
        leftSec = self:getActItemLeftTime(v)
      end 

      if leftSec > 0 then
        return leftSec 
      end 
    end 
  end 

  return leftSec
end 

--MSG: ActivityMissionInfos
function Activity:initActMissionState(infoMsg)
  echo("=== Activity:initActMissionState")

  if self._actMissions == nil then 
    self._actMissions = {}
    self._discountBuyFlag = {} --半价物品已经购买列表
    for k, v in pairs(AllConfig.mission_info) do 
      self._actMissions[v.id] = {}
      self._actMissions[v.id].rawData = v 
      self._actMissions[v.id].progress = 0          --进度
      self._actMissions[v.id].award_is_get = 0      --奖励是否已经领取   
    end 
  end 

  if infoMsg then 
    for k, v in pairs(infoMsg.active_missions) do 
      echo("=== id, progress, awarded", v.id, v.var, v.award_is_get)
      self._actMissions[v.id].progress = v.var 
      self._actMissions[v.id].award_is_get = v.award_is_get 
    end 

    for k, v in pairs(infoMsg.odds_award_is_get) do 
      echo("=== odds_award_is_get:", v)
      self._discountBuyFlag[v] = true 
    end 
  end 
end 

function Activity:setActMissionState(actId, isMissionAwarded, day, isDiscountBuy)
  if isMissionAwarded then 
    self._actMissions[actId].award_is_get = 1 
  end 

  if day and isDiscountBuy ~= nil then 
    self._discountBuyFlag[day] = isDiscountBuy
  end 
end 

function Activity:getActMissDisCountBuyFlag(day)
  return self._discountBuyFlag[day]
end 

function Activity:getActMissionByDay(day)
  local tbl = {}
  local preType = 0
  local index = 0   
  local actType = day 

  if self._actMissions == nil then
    self:initActMissionState(nil)
  end 

  for k, v in pairs(self._actMissions) do 
    if v.rawData.activity_type == actType then 
      if v.rawData.membership ~= preType then 
        preType = v.rawData.membership 
        index = index + 1 
      end 

      if tbl[index] == nil then 
        tbl[index] = {}
      end 
      table.insert(tbl[index], v)
    end 
  end 

  for i=1, #tbl do 
    self:sortActMission(tbl[i])
  end 

  return tbl 
end 

function Activity:getActMissionTipsState()
  local stateTbl = {false, false, false, false, false, false,false}
  local hasTips = false 
  if self._actMissions ~= nil then
    for k, v in pairs(self._actMissions) do 
      if v.award_is_get < 1 and ((v.rawData.jump_type~=18 and v.progress>=v.rawData.var) or (v.rawData.jump_type==18 and (v.progress > 0 and v.progress<=v.rawData.var))) then 
        stateTbl[v.rawData.activity_type] = true 
        hasTips = true 
      end  
    end 
  end

  return stateTbl, hasTips
end 

function Activity:sortActMission(dataArray)
  if dataArray == nil or #dataArray < 1 then 
    return 
  end 

  local startIdx = 1 
  local endIdx = #dataArray 

  local function isFinish(item)
    return (item.rawData.jump_type~=18 and item.progress>=item.rawData.var) or (item.rawData.jump_type==18 and (item.progress>0 and item.progress<=item.rawData.var))
  end 

  local function sortByType(tbl, idx_s, idx_e, _type)
    if idx_e <= idx_s + 1 then 
      return 
    end 

    local flag
    for i=idx_s, idx_e-1 do
      local k = i
      for j=i+1, idx_e do        
        if _type == "type_awarded" then 
          flag = tbl[k].award_is_get > tbl[j].award_is_get 
        elseif _type == "type_finish" then  
          flag = not isFinish(tbl[k]) and isFinish(tbl[j])
        elseif _type == "type_id" then
          flag = tbl[k].rawData.id > tbl[j].rawData.id
        end 

        if flag then 
          k = j
        end 
      end  

      if k > i then
        local tmp = tbl[k]
        tbl[k] = tbl[i]
        tbl[i] = tmp
      end
    end 
  end 

  --已完成放到最后
  sortByType(dataArray, startIdx, endIdx, "type_awarded")
  local getCount = 0 
  for i=startIdx, endIdx do  
    if dataArray[i].award_is_get > 0 then 
      getCount = getCount + 1 
    end 
  end 
  sortByType(dataArray, endIdx-getCount+1, endIdx, "type_id")

  endIdx = endIdx - getCount 

  --已完成可领取放到前面
  sortByType(dataArray, startIdx, endIdx, "type_finish")
  local finishCount = 0 
  for i=startIdx, endIdx do  
    if isFinish(dataArray[i]) then 
      finishCount = finishCount + 1 
    end 
  end 

  --中间部分按id排序
  startIdx = startIdx + finishCount 
  sortByType(dataArray, startIdx, endIdx, "type_id")
end 

function Activity:checkHasEnoughSpace(itemsArray)
  if itemsArray == nil then 
    return 
  end 

  local spaceFlag = 0  
  local str = ""
  for k, v in pairs(itemsArray) do 
    if v[1] == 6 then --props 
      local itemType = AllConfig.item[v[2]].item_type 
      if itemType ~= iType_CardChip and itemType ~= iType_EquipChip then 
        if GameData:Instance():getCurrentPackage():checkItemBagEnoughSpace(1) == false then 
          spaceFlag = 1 
          str = _tr("bag is full,clean up?")
          break 
        end 
      end 
    elseif v[1] == 7 then 
      if GameData:Instance():getCurrentPackage():checkEquipBagEnoughSpace(1) == false then 
        spaceFlag = 2 
        str = _tr("card bag is full,clean up?")
        break 
      end 
    elseif v[1] == 8 then 
      if GameData:Instance():getCurrentPackage():checkCardBagEnoughSpace(1) == false then 
        spaceFlag = 3 
        str = _tr("card bag is full,clean up?")
        break 
      end 
    elseif v[1] == 21 then --talent 
      if GameData:Instance():getCurrentPlayer():getTalentBankPoints()>=GameData:Instance():getCurrentPlayer():getTalentBankMaxPoint() then 
        spaceFlag = 4 
        str = _tr("not_found_talent_point")
      end       
    end 
  end 

  if spaceFlag > 0 then 
    local pop = PopupView:createTextPopupWithPath({leftNorBtn = "button-nor-zhengli.png",
                                                   leftSelBtn = "button-sel-zhengli.png",
                                                   text = str,
                                                   leftCallBack = function()
                                                      local controller
                                                      if spaceFlag == 1 then
                                                        controller = ControllerFactory:Instance():create(ControllerType.BAG_CONTROLLER)
                                                        controller:enter()
                                                      elseif spaceFlag == 2 then 
                                                        controller = ControllerFactory:Instance():create(ControllerType.CARDBAG_CONTROLLER)
                                                        controller:enter(true)                                                        
                                                      elseif spaceFlag == 3 then 
                                                        controller = ControllerFactory:Instance():create(ControllerType.CARDBAG_CONTROLLER)
                                                        controller:enter(false)
                                                      elseif spaceFlag == 4 then
                                                        controller = ControllerFactory:Instance():create(ControllerType.TALENT_CONTROLLER)
                                                        controller:enter()                                                         
                                                      end 
                                                  end})
    GameData:Instance():getCurrentScene():addChild(pop,9000)

    return false 
  end 

  return true 
end 

--武将替换分组: 
-- 0——不参与活动
-- 1——元宝/付费武将
-- 2——公会、竞技场、通天塔兑换的5星武将
-- 3——抽卡、副本、炼魂商店的5星武将
function Activity:getCardsForReplaced()
  local tbl = {}
  local groupId
  local allCards = GameData:Instance():getCurrentPackage():getAllCards()
  for k, v in pairs(allCards) do 
    groupId = v:getGroupIndex()
    if groupId > 0 and (v:getCradIsWorkState() == false) then 
      if tbl[groupId] == nil then 
        tbl[groupId] = {}
      end
      table.insert(tbl[groupId], v)
    end 
  end 

  return tbl 
end 

--当srcCard为空,则返回所有目标卡mode或者rootId
function Activity:getCardReplaceTarget(srcCard)
  local tbl = {}

  local index_start = 1
  local index_end = 3 
  local srcRootId = 0 
  local srcGrade 
  if srcCard then 
    index_start = srcCard:getGroupIndex()
    index_end = srcCard:getGroupIndex()
    srcRootId = srcCard:getUnitRoot()
    srcGrade = srcCard:getGrade()
  end    

  local groupData 
  for k, v in pairs(AllConfig.activity_exchange_card) do 
    if v.id == ACT_ID_CARD_REPLACE then 
      for groupId=index_start, index_end do 
        local groupData 
        if groupId == 1 then 
          groupData = v.card_group_high 
        elseif groupId == 2 then 
          groupData = v.card_group_normal         
        elseif groupId == 3 then 
          groupData = v.card_group_low 
        end 

        if groupData then 
          if tbl[groupId]==nil then 
            tbl[groupId] = {}
          end 

          for k, v in pairs(groupData) do 
            if v.array[1] ~= srcRootId then --目标与源卡不能相同
              if srcGrade then --如果源卡存在，则根据其星级来适配
                local configId = v.array[1] * 100 + srcGrade 
                if AllConfig.unit[configId] then 
                  local card = Card.new()
                  card:initAttrById(configId)
                  table.insert(tbl[groupId], card)
                else 
                  table.insert(tbl[groupId], v.array[1])
                end 
              else 
                table.insert(tbl[groupId], v.array[1])
              end 
            end 
          end 
        end 
      end 
    end 
  end 

  return tbl 
end 

function Activity:getCardReplaceCost(srcCard)
  if srcCard == nil then 
    return 0
  end 
  local cost = 0 
  local groupId = srcCard:getGroupIndex()
  for k, v in pairs(AllConfig.activity_exchange_card) do 
    if v.id == ACT_ID_CARD_REPLACE then 
      if groupId == 1 then 
        cost = v.cost_money_high 
      elseif groupId == 2 then 
        cost = v.cost_money_normal           
      elseif groupId == 3 then 
        cost = v.cost_money_low 
      end 
      break 
    end 
  end 

  return cost 
end 
