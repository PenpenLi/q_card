
require("model.mail.Mail")

Home = class("Home")

Home._instance = nil 

function Home:ctor()

end

function Home:instance()
  if Home._instance == nil then 
    Home._instance = Home.new()
  end
  return Home._instance
end

function Home:setIsHomeActListVisible(isVisible)
  self._isActListMenuVisible = isVisible
end 

function Home:getIsHomeActListVisible()
  if self._isActListMenuVisible == nil then 
    self._isActListMenuVisible = true 
  end 
  return self._isActListMenuVisible
end 

function Home:setPreViewPositionX(x_fg, x_bg)
  self._preX_fg = x_fg 
  self._preX_bg = x_bg 
end 

function Home:getPreViewPositionX()
  return self._preX_fg, self._preX_bg
end 


--土豪雕像
function Home:initRechargeTopInfo(pbMsg)
  echo("=== Home:initRechargeTopInfo")

  self.preRechargeTopInfo = {}
  self.preRechargeTopInfo.id = pbMsg.id 
  self.preRechargeTopInfo.player = pbMsg.data 
  self.preRechargeTopInfo.rechargeVal = pbMsg.recharge_var 
  self.preRechargeTopInfo.praisedCount = pbMsg.get_like 
  self.preRechargeTopInfo.awardedFlag = pbMsg.award_is_get
end 

function Home:getRechargeTopInfo()
  return self.preRechargeTopInfo 
end 

function Home:getTopRechargerBonus(level, praisedCount)
  local idx = 1  
  for k, v in pairs(AllConfig.recharge_max) do 
    if level >= v.min_lv and level <= v.max_lv then 
      idx = k 
      break 
    end 
  end 

  local item = AllConfig.recharge_max[idx]
  local coin = item.award_base + math.min(praisedCount, item.max_like)*item.award_append 
  
  --点赞奖励
  local str = _tr("recharge_praised_bonus%{count}", {count=item.give_like_award})
  return coin, str 
end 

function Home:handleErrorCode(errorCode)
  local curScene = GameData:Instance():getCurrentScene()

  if errorCode == "TodayAlreadyGiveLike" then 
    Toast:showString(curScene, _tr("has_praised_today"), ccp(display.cx, display.cy)) 
  elseif errorCode == "CanNotGiveSelfLike" then 
    Toast:showString(curScene, _tr("praise_myself_is_forbidden"), ccp(display.cx, display.cy)) 
  elseif errorCode == "TodayAlreadyGetAward" then 
    Toast:showString(curScene, _tr("has_awarded_today"), ccp(display.cx, display.cy)) 
  elseif errorCode == "NotFistRank" then 
    Toast:showString(curScene, _tr("not_first_rank"), ccp(display.cx, display.cy))  
  else 
    Toast:showString(curScene, _tr("system error"), ccp(display.cx, display.cy))
  end 
end 

function Home:hasRechargeTopData()
  local tbl = GameData:Instance():getPlayersRank(RankEnum.Vip_Level) 
  if self:getRechargeTopInfo() and tbl and #tbl > 0 then 
    return true 
  end 

  return false 
end 