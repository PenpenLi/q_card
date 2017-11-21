
require("model.mail.Mail")

Liveness = class("Liveness")

Liveness._instance = nil 

function Liveness:ctor()
  net.registMsgCallback(PbMsgId.LivenessProgressB2C,self,Liveness.updateLiveness)
end

function Liveness:instance()
  if Liveness._instance == nil then 
    Liveness._instance = Liveness.new()
  end
  return Liveness._instance
end


function Liveness:exit()
  echo("---Liveness:exit---")
  --net.unregistAllCallback(self)
end


function Liveness:updateLiveness(action,msgId,msg)
  echo("===@@@ Liveness:updateLiveness: type, var_before, var_after, point =", msg.type, msg.var_before, msg.var_after, msg.point)
  local player = GameData:Instance():getCurrentPlayer()
  player:setLivenessItem(msg.type, msg.var_after)
  player:setGainedLivenessValue(msg.point)
  player:setCurWeekLivenessVal(msg.week_point)
end

function Liveness:getLivenessBonusArray()

  if self.livenessBonus == nil then
    self.livenessBonus = {}
    local dropItem
    local level = GameData:Instance():getCurrentPlayer():getLevel()

    for i=1, table.getn(AllConfig.livenessbonus) do 

        local tbl = {}
        local dropArray = AllConfig.livenessbonus[i].bonus
        for k, dropId in pairs(dropArray) do 
          dropItem = AllConfig.drop[dropId]
          if level >= dropItem.min_level and level <= dropItem.max_level then 
            for m, v in pairs(dropItem.drop_data) do
              v = v.array
              local bonusItem = nil

              if v[1] == 1 or v[1] == 2 or v[1] == 3 then  -- player/card/skill exp
                bonusItem = {iType = 88, configId = nil, iconId = 3059022, count = v[3]}
              elseif v[1] == 4 then --coin
                bonusItem = {iType = 88, configId = nil, iconId = 3050050, count = v[3]}
              elseif v[1] == 5 then --money
                bonusItem = {iType = 88, configId = nil, iconId = 3050049, count = v[3]}

              elseif v[1] >= 6 and v[1] <= 8 then 
                bonusItem = {iType = v[1], configId = v[2], iconId = nil, count = v[3]}

              elseif v[1] == 11 then --spirit
                bonusItem = {iType = 88, configId = nil, iconId = 3059015, count = v[3]}
              elseif v[1] == 12 then --token
                bonusItem = {iType = 88, configId = nil, iconId = 3050003, count = v[3]}
              end

              table.insert(tbl, bonusItem)
            end
          end 
        end 

        local tmp = {value=AllConfig.livenessbonus[i].liveness_value, bonus = tbl}
        table.insert(self.livenessBonus, tmp)
    end
  end

  return self.livenessBonus
end

function Liveness:getConditionByType(_type)
  local validFlag = true 
  local toastStr = " "
  if _type == 0 then --mine
    validFlag, toastStr = GameData:Instance():checkSystemOpenCondition(3, false)

  elseif _type == 1 or _type == 19 then --日常任务
    validFlag, toastStr = GameData:Instance():checkSystemOpenCondition(2, false)

  elseif _type == 4 then --官职俸禄
    validFlag, toastStr = GameData:Instance():checkSystemOpenCondition(17, false)

  elseif _type == 5 then --精英副本
    local isPassed, stageName
    local stage = Scenario:Instance():getStageById(1010071)
    if stage ~= nil then
      isPassed = stage:getIsPassed()
      stageName = stage:getStageName()      
    end
    if isPassed == false then
      toastStr = _tr("elite open condition %{name}", {name=stageName})
      validFlag = false 
    end

  elseif _type == 6 then --征战
    validFlag, toastStr = GameData:Instance():checkSystemOpenCondition(4, false)

  elseif _type == 9 then --每日登陆(每日签到)
    validFlag, toastStr = GameData:Instance():checkSystemOpenCondition(7, false)

  elseif _type == 10 or _type == 11 then --boss战
    validFlag, toastStr = GameData:Instance():checkSystemOpenCondition(5, false)

  elseif _type == 14 then --商城集市
    validFlag, toastStr = GameData:Instance():checkSystemOpenCondition(13, false)

  elseif _type == 15 then --升级
    validFlag, toastStr = GameData:Instance():checkSystemOpenCondition(6, false)

  elseif _type == 16 then --修行
    validFlag, toastStr = GameData:Instance():checkSystemOpenCondition(8, false)

  elseif _type == 17 then --商城特惠
    validFlag, toastStr = GameData:Instance():checkSystemOpenCondition(14, false)

  elseif _type == 18 then --商城典藏购买体力丹
    validFlag, toastStr = GameData:Instance():checkSystemOpenCondition(15, false)
  end 

  return validFlag, toastStr
end 

function Liveness:checkHasTipForItem(item)
  --该项已做过一次则不显示tips
  if item.counts > 0 then 
    return false 
  end 

  --当日所有奖励已领取
  local bonus = self:getLivenessBonusArray()
  local gainedValue = GameData:Instance():getCurrentPlayer():getGainedLivenessValue()
  if gainedValue ~= nil and gainedValue >= bonus[6].value then 
    return false 
  end 

  local hasTip = false 

  if item.iType == 0      --矿场打工
    or item.iType == 3    --祭天点将
    or item.iType == 4    --官职领取
    or item.iType == 5    --精英本次数
    or item.iType == 13   --活动摇钱树
    or item.iType == 15   --升级 
    or item.iType == 16   --修行
    or item.iType == 17   --商城特惠
    or item.iType == 18 then  --商城典藏购买体力丹
    hasTip = true 
  end 

  return hasTip 
end 


function Liveness:getValidLivenessItems()
  local tbl = {}
  local array = GameData:Instance():getCurrentPlayer():getLivenessArray()
  for k, v in pairs(array) do
    local flag, _ = self:getConditionByType(k-1)
    if flag == true then 
      -- echo("=== valid liveness type=", k-1)
      table.insert(tbl, array[k]) 
    end 
  end 

  --sort 
  local len = #tbl
  if len > 1 then 
    for i=1, len-1 do
      local k = i
      for j=i+1, len do 
        if tbl[k].id < 0 and tbl[j].id > 0 then
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

function Liveness:canFetchLivenessAwards()
  --check day liveness
  local player = GameData:Instance():getCurrentPlayer()
  local gainedValue = player:getGainedLivenessValue()
  local allBonusArr = self:getLivenessBonusArray()
  local canAward = false 
  for i=1, 6 do 
    if gainedValue >= allBonusArr[i].value then 
      if player:getLivenessAwardInfo(i) < 1 then 
        canAward = true 
        break 
      end 
    end 
  end 

  --check week liveness
  if canAward == false then 
    local prePoint = player:getPreWeekLivenessVal()
    if prePoint >= AllConfig.weekliveness[1].min_liveness then 
      local awardFlag = player:getWeekLivenessAwarded()
      if awardFlag ~= nil and awardFlag == 0 then   
        canAward = true 
      end 
    end 
  end 

  return canAward
end 

function Liveness:hasNewItemToFinish()
  local allItems = self:getValidLivenessItems()
  for k, v in pairs(allItems) do 
    if self:checkHasTipForItem(v) then 
      return true 
    end 
  end 

  return false 
end 

function Liveness:getWeekBonusInfo()
  if self._weekBonus == nil then 
    self._weekBonus = {}

    for i, tt in pairs(AllConfig.weekliveness) do      
        local tbl = {}
        for k, v in pairs(tt.bonus) do
          v = v.array
          local bonusItem = nil
          if v[1] == 1 or v[1] == 2 or v[1] == 3 then  -- player/card/skill exp
            bonusItem = {iType = 88, configId = nil, iconId = 3059022, count = v[3]}
          elseif v[1] == 4 then --coin
            bonusItem = {iType = 88, configId = nil, iconId = 3050050, count = v[3]}
          elseif v[1] == 5 then --money
            bonusItem = {iType = 88, configId = nil, iconId = 3050049, count = v[3]}
          elseif v[1] >= 6 and v[1] <= 8 then
            bonusItem = {iType = v[1], configId = v[2], iconId = nil, count = v[3]}
          elseif v[1] == 11 then --spirit
            bonusItem = {iType = 88, configId = nil, iconId = 3059015, count = v[3]}
          elseif v[1] == 12 then --token
            bonusItem = {iType = 88, configId = nil, iconId = 3050003, count = v[3]}
          end
          
          table.insert(tbl, bonusItem)
        end

        local item = {minVal=tt.min_liveness, maxVal=tt.max_liveness, bonus=tbl}
        table.insert(self._weekBonus, item)
    end 
  end 

  return self._weekBonus
end
