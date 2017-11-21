RankMatchPlayer = class("RankMatchPlayer")
function RankMatchPlayer:ctor(rankMatchBase)
  self:update(rankMatchBase)
end

function RankMatchPlayer:update(rankMatchBase)
  --[[
  message RankMatchServerBase{
  optional int32 id       = 1;  //玩家id
  optional int32 rank     = 2;  //玩家排行  -1 无排行
  optional int32 max_rank   = 3;  //玩家最大排行 -1 无排行
  optional int32 fight    = 4;  //玩家战斗力
  optional int32 total_win  = 5;  //总计胜利场次
  optional int32 last_time  = 6;  //上次战斗时间
  optional int32 use_count  = 7;  //当天使用次数
  optional int32 max_count  = 10; //当天可以使用次数
  repeated int32 reports    = 8;  //战报
  optional int32 total_count  = 9;  //总计战斗次数
  repeated int32 target   = 11; //目标数据
  optional int32 flag     = 12; //入库标示
  }


  message RankMatchBase{
  required RankMatchServerBase base   = 1;  //基础数据
  optional int32 level        = 2;  //玩家等级
  optional string name        = 3;  //玩家名字
  optional int32 head         = 4;  //玩家头像
  optional FightCards card      = 5;  //玩家阵容
  }]]
  
  if rankMatchBase == nil or rankMatchBase.base == nil then
    return
  end
  
  self:setName(rankMatchBase.name)
  self:setLevel(rankMatchBase.level)
  self:setHead(rankMatchBase.head)
  self:setFightCards(rankMatchBase.card.card_pos)
  
  self:setId(rankMatchBase.base.id)
  self:setRank(rankMatchBase.base.rank)
  self:setMaxRank(rankMatchBase.base.max_rank)
  self:setFightNumber(rankMatchBase.base.fight)
  self:setTotalWin(rankMatchBase.base.total_win)
  self:setLastFightTime(rankMatchBase.base.last_time)
  self:setUsedCountToday(rankMatchBase.base.use_count)
  self:setMaxCountToday(rankMatchBase.base.max_count)
  self:setReports(rankMatchBase.base.reports)
  self:setTotalFightCount(rankMatchBase.base.total_count)
end

function RankMatchPlayer:parse(msg,battleFormationIdx)
  --[[
  message BaseSync {
  optional int32 money = 3;      //收费元宝
  optional int32 coin = 4;      //铜钱
  optional int32 level = 5;     //等级
  optional AddedBuy added_buy = 6;  //额外购买的背包格子
  optional int32 loyalty = 7;   //民心
  optional Limit limit = 1;     //背包上限数据
  optional int32 leader_power = 2;  //领导力
  optional int32 score = 8;     //新账号三选一的掉落包的ID
  optional int32 token = 9;     //废弃
  optional int32 vip_level = 10;  //VIP等级
  optional int32 vip_exp = 17;    //vip经验
  optional int32 avatar = 11;   //头像
  optional int32 experience = 12; //经验
  optional int32 level_reward = 13; //升级领奖
  optional int32 point = 14;    //免费元宝
  optional Statics statics = 15;  //玩家其他数据
  optional int32 jianghun = 16;   //将魂
  optional int32 honor = 18;    //荣誉点
  optional int32 rank_point = 19; //排行点
  optional int32 guild_point = 20;  //公会点
  optional int32 bable_point = 21;  //通天塔货币
  }
  
  
  message QueryPlayerShowResultS2C{
  enum traits {value = 5089;}
  message BattleCardsInfo{
  optional FightCards cards = 1;          //卡牌信息
  optional BattleFormation.BattleIndex index = 2; //
  };
  required bool result = 7;
  optional int32 id = 1;
  optional string nick_name = 2;    //昵称
  optional BaseSync common = 3;     //基础信息
  optional PVPBaseData pvpbase = 4;   //征战信息
  optional int32 achievement_point = 5; //成就点
  optional VipState vip_state = 6;    //包月卡
  repeated BattleCardsInfo info = 8;  //阵容信息
  }
  ]]
  
  if battleFormationIdx == nil then
    battleFormationIdx = BattleFormation.BATTLE_INDEX_NORMAL_1
  end
  
  self:setIsCommontype(true)
  
  self:setId(msg.id)
  self:setName(msg.nick_name)
  
  self:setLevel(msg.common.level)
  self:setHead(msg.common.avatar)
  
  local cards = nil
  for key, battleCardsInfo in pairs(msg.info) do
  	if battleCardsInfo.index == battleFormationIdx then
  	  cards = battleCardsInfo.cards.card_pos
  	  break
  	end
  end
  
  --dump(cards)
  
  self:setFightCards(cards or {})
  
  self:setRank(0)
  self:setMaxRank(0)
  self:setFightNumber(0)
  self:setTotalWin(0)
  self:setLastFightTime(0)
  self:setUsedCountToday(0)
  self:setMaxCountToday(0)
  self:setReports(0)
  self:setTotalFightCount(0)
  
end

------
--  Getter & Setter for
--      RankMatchPlayer._IsCommontype 
-----
function RankMatchPlayer:setIsCommontype(IsCommontype)
	self._IsCommontype = IsCommontype
end

function RankMatchPlayer:getIsCommontype()
	return self._IsCommontype
end

------
--  Getter & Setter for
--      RankMatchPlayer._Name 
-----
function RankMatchPlayer:setName(Name)
	self._Name = Name
end

function RankMatchPlayer:getName()
	return self._Name
end

------
--  Getter & Setter for
--      RankMatchPlayer._Level 
-----
function RankMatchPlayer:setLevel(Level)
	self._Level = Level
end

function RankMatchPlayer:getLevel()
	return self._Level
end

------
--  Getter & Setter for
--      RankMatchPlayer._Head 
-----
function RankMatchPlayer:setHead(Head)
  local unitRoot = Head
  local picId = 0
  if unitRoot <= 1 then
     picId = 3012502
  else
     local cardConfigId = tonumber(unitRoot.."01")
     picId = AllConfig.unit[cardConfigId].unit_head_pic
  end
	self._Head = picId
end

function RankMatchPlayer:getHead()
	return self._Head
end

------
--  Getter & Setter for
--      RankMatchPlayer._FightCards 
-----
function RankMatchPlayer:setFightCards(FightCards)
  --[[message FightCardPosition{
  required int32 card = 1;
  required int32 pos = 2;
  optional int32 config = 3;
  optional int32 monster = 4;
  optional int32 level = 5;
  repeated Equipment equip = 6;
  }
  message FightCards{
    repeated FightCardPosition card_pos = 1;
  }]]

	self._FightCards = FightCards
end

function RankMatchPlayer:getFightCards()
	return self._FightCards
end

------
--  Getter & Setter for
--      RankMatchPlayer._Id 
-----
function RankMatchPlayer:setId(Id)
	self._Id = Id
end

function RankMatchPlayer:getId()
	return self._Id
end

------
--  Getter & Setter for
--      RankMatchPlayer._Rank 
-----
function RankMatchPlayer:setRank(Rank)
	self._Rank = Rank
end

function RankMatchPlayer:getRank()
	return self._Rank
end

------
--  Getter & Setter for
--      RankMatchPlayer._MaxRank 
-----
function RankMatchPlayer:setMaxRank(MaxRank)
	self._MaxRank = MaxRank
end

function RankMatchPlayer:getMaxRank()
	return self._MaxRank
end

------
--  Getter & Setter for
--      RankMatchPlayer._FightNumber 
-----
function RankMatchPlayer:setFightNumber(FightNumber)
	self._FightNumber = FightNumber
end

function RankMatchPlayer:getFightNumber()
	return self._FightNumber
end

------
--  Getter & Setter for
--      RankMatchPlayer._TotalWin 
-----
function RankMatchPlayer:setTotalWin(TotalWin)
	self._TotalWin = TotalWin
end

function RankMatchPlayer:getTotalWin()
	return self._TotalWin
end

------
--  Getter & Setter for
--      RankMatchPlayer._LastFightTime 
-----
function RankMatchPlayer:setLastFightTime(LastFightTime)
	self._LastFightTime = LastFightTime
end

function RankMatchPlayer:getLastFightTime()
	return self._LastFightTime
end

function RankMatchPlayer:getRemainCountToday()
	return self:getMaxCountToday() - self:getUsedCountToday()
end

------
--  Getter & Setter for
--      RankMatchPlayer._UsedCountToday 
-----
function RankMatchPlayer:setUsedCountToday(UsedCountToday)
	self._UsedCountToday = UsedCountToday
end

function RankMatchPlayer:getUsedCountToday()
	return self._UsedCountToday
end

------
--  Getter & Setter for
--      RankMatchPlayer._MaxCountToday 
-----
function RankMatchPlayer:setMaxCountToday(MaxCountToday)
	self._MaxCountToday = MaxCountToday
end

function RankMatchPlayer:getMaxCountToday()
	return self._MaxCountToday
end

------
--  Getter & Setter for
--      RankMatchPlayer._Reports 
-----
function RankMatchPlayer:setReports(Reports)
	self._Reports = Reports
end

function RankMatchPlayer:getReports()
	return self._Reports
end

------
--  Getter & Setter for
--      RankMatchPlayer._TotalFightCount 
-----
function RankMatchPlayer:setTotalFightCount(TotalFightCount)
	self._TotalFightCount = TotalFightCount
end

function RankMatchPlayer:getTotalFightCount()
	return self._TotalFightCount
end

return RankMatchPlayer