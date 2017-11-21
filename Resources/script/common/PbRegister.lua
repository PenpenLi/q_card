
PbRegist = {}

PbRegist.messageMapping = {}

PbRegist.messagePackage = {}

PbRegist.DefaultPackageName = "DianShiTech.Protocal."

PbMsgId = {}

function PbRegist.loadStruct(messageName)

  --print("=====>>:pbs".."/"..messageName..".pb")
  pb.load("pbs".."/"..messageName..".pb")
  
end

function PbRegist.registMessage(msgId,messageName,messagePkg)
  pb.load("pbs".."/"..messageName..".pb")
  PbMsgId[messageName] = msgId
  PbRegist.messageMapping[msgId] = messageName
  PbRegist.messagePackage[msgId] = messagePkg
end

function PbRegist.unpack(msgId,data)
  --  local pbPatternName = PbRegist.messagePackage[msgId]..PbRegist.messageMapping[msgId]
  if PbRegist.messageMapping[msgId] == nil then
    printf("Can not found msg mapping:%d",msgId)
    return nil
  end
  local pbPatternName = PbRegist.DefaultPackageName..PbRegist.messageMapping[msgId]
--  local pbMsg = pb.decode(pbPatternName , from_base64(data) or {})
  local pbMsg = pb.decode(pbPatternName , data or {})
  assert(pbMsg ~= nil,"Can not decode pb msg with msgId:%d",msgId)
  return pbMsg
end

function PbRegist.pack(msgId,data)
--  local pbPatternName = PbRegist.messagePackage[msgId]..PbRegist.messageMapping[msgId]
  local pbPatternName = PbRegist.DefaultPackageName..PbRegist.messageMapping[msgId]
  -- print("----->>>",pbPatternName)
  local pbMsg = pb.encode(pbPatternName , data or {})
  assert(pbMsg ~= nil,"Can not encode pb msg with msgId:%d",msgId)
--  return to_base64(pbMsg)
  return pbMsg
end

function PbRegist.unpackStruct(structName,data)
  return  pb.decode(PbRegist.DefaultPackageName..structName , data)
end

--- Load common structs ---
PbRegist.loadStruct("Talent")
PbRegist.loadStruct("EquipmentStatics")
PbRegist.loadStruct("VipState")
PbRegist.loadStruct("MoneyHistoryInformation")
PbRegist.loadStruct("CommanderCardGroup")
PbRegist.loadStruct("Item")
PbRegist.loadStruct("Equipment")
PbRegist.loadStruct("BattleCommon")
PbRegist.loadStruct("WallBeCureEvent")
PbRegist.loadStruct("CardMoveEvent")
PbRegist.loadStruct("CardAttackEvent")
PbRegist.loadStruct("CardAliveEvent")
PbRegist.loadStruct("WallBrokenEvent")
PbRegist.loadStruct("CardSkillEvent")
PbRegist.loadStruct("CardSkillDamageEvent")
PbRegist.loadStruct("CardSkillStatusEvent")
PbRegist.loadStruct("CardDropItemEvent")
PbRegist.loadStruct("CardTurnEvent")
PbRegist.loadStruct("CardCombineSkillEvent")
PbRegist.loadStruct("CardEffectEvent")
PbRegist.loadStruct("CardChangeValueEvent")
PbRegist.loadStruct("WallChangeValueEvent")
PbRegist.loadStruct("WallAttackEvent")
PbRegist.loadStruct("InstanceData")
PbRegist.loadStruct("TaskConditionState")
PbRegist.loadStruct("SingleTask")
PbRegist.loadStruct("DailyTaskMeta")
PbRegist.loadStruct("TaskState")
PbRegist.loadStruct("DailyTaskTable")
PbRegist.loadStruct("DropDailyTask")
PbRegist.loadStruct("Currency")
PbRegist.loadStruct("PlayerAwardRecord")
PbRegist.loadStruct("SyncCommon")
PbRegist.loadStruct("CardPictureState")
PbRegist.loadStruct("PlayerAchievementState")
PbRegist.loadStruct("BableInfo")
PbRegist.loadStruct("DrawCardRebate")
PbRegist.loadStruct("PlayerFightBaseData")
PbRegist.loadStruct("BattleFormation")
PbRegist.loadStruct("PVPRankMatchBase")
PbRegist.loadStruct("BableInfo")
PbRegist.loadStruct("FightBuff")
PbRegist.loadStruct("PlayerBaseInformation")
PbRegist.loadStruct("PlayerPVPBaseInfo")
PbRegist.loadStruct("PVPDataSyncCommon")
PbRegist.loadStruct("PlayerDailyChangedInformation")
PbRegist.loadStruct("ClientSync")
PbRegist.loadStruct("BossFightBase")
PbRegist.loadStruct("PlayerFriends")
PbRegist.loadStruct("InteractPlayerBase")
PbRegist.loadStruct("NoticeBase")
PbRegist.loadStruct("AwardCode")
PbRegist.loadStruct("AchievementProgress")
PbRegist.loadStruct("Commodity")
PbRegist.loadStruct("PVPArenaBase")
PbRegist.loadStruct("NormalBattleResult")
PbRegist.loadStruct("ReportReview")
PbRegist.loadStruct("StoreItem")
--guild
PbRegist.loadStruct("GuildBase")
PbRegist.loadStruct("GuildSync")



-- PbMsgId.PlayerDailyChangedInformation = 2238
PbRegist.registMessage(2238,"PlayerDailyChangedInformation")


-- PbMsgId.ClientSync = 1778
PbRegist.registMessage(1778,"ClientSync")

-- PbMsgId.PingPong = 1000
PbRegist.registMessage(1000,"PingPong")

-- PbMsgId.SyncTime = 1056
PbRegist.registMessage(1056,"SyncTime")

-- PbMsgId.ValidGateServerInformation = 3000
PbRegist.registMessage(3000,"ValidGateServerInformation")

-- PbMsgId.NoValidGateServer = 3001
PbRegist.registMessage(3001,"NoValidGateServer")

--------- for account ------------------

-- PbMsgId.FastCreatePlayer = 1014
PbRegist.registMessage(1014,"FastCreatePlayer")

-- PbMsgId.FastCreatePlayerResult = 1015
PbRegist.registMessage(1015,"FastCreatePlayerResult")

-- PbMsgId.Login = 1004
PbRegist.registMessage(1004,"Login")

-- PbMsgId.LoginResult = 1005
PbRegist.registMessage(1005,"LoginResult")

-- PbMsgId.ForceOffline = 3008
PbRegist.registMessage(3008,"ForceOffline")

-- PbMsgId.BindGameNickName = 1033
PbRegist.registMessage(1033,"BindGameNickName")

-- PbMsgId.BindGameNickNameResult = 1034
PbRegist.registMessage(1034,"BindGameNickNameResult")

-- PbMsgId.PlayerAchievementState = 4431
PbRegist.registMessage(4431,"PlayerAchievementState")

-- PbMsgId.AskForAchievementState = 4437
PbRegist.registMessage(4437,"AskForAchievementState")

--------- for game ------------------
---- PbMsgId.PlayerBaseInformation = 1024
PbRegist.registMessage(1024,"PlayerBaseInformation")

-- PbMsgId.DrawCardUseLoyalty = 1025
PbRegist.registMessage(1025,"DrawCardUseLoyalty")

-- PbMsgId.DrawCardUseLoyaltyResult = 1026
PbRegist.registMessage(1026,"DrawCardUseLoyaltyResult")

-- PbMsgId.GoIntoBattle = 1069
--PbRegist.registMessage(1069,"GoIntoBattle")

-- PbMsgId.GoIntoBattleResult = 1070
--PbRegist.registMessage(1070,"GoIntoBattleResult")

-- PbMsgId.GoDownFromBattle = 1075
--PbRegist.registMessage(1075,"GoDownFromBattle")

-- PbMsgId.GoDownFromBattleResult = 1076
--PbRegist.registMessage(1076,"GoDownFromBattleResult")

--PbMsgId.DrawCardUseItem = 3343
PbRegist.registMessage(3343,"DrawCardUseItem")

--PbMsgId.LoyaltyFreeDrawCard = 10002
PbRegist.registMessage(10002,"LoyaltyFreeDrawCard")

--PbMsgId.LoyaltyFreeDrawCardResult = 10003
PbRegist.registMessage(10003,"LoyaltyFreeDrawCardResult")

--PbMsgId.FreeDrawCard = 3215
PbRegist.registMessage(3215,"FreeDrawCard")

--PbMsgId.FreeDrawCardResult = 2777
PbRegist.registMessage(2777,"FreeDrawCardResult")

--PbMsgId.DrawCardUseItemResult = 3344
PbRegist.registMessage(3344,"DrawCardUseItemResult")

-- PbMsgId.ResetMasterCard = 1081
PbRegist.registMessage(1081,"ResetMasterCard")

-- PbMsgId.ResetMasterCardResult = 1082
PbRegist.registMessage(1082,"ResetMasterCardResult")

-- PbMsgId.EatCard = 1088
PbRegist.registMessage(1088,"EatCard")

-- PbMsgId.EatCardResult = 1089
PbRegist.registMessage(1089,"EatCardResult")

-- PbMsgId.UpdateRefreshDailyInformation = 2288
PbRegist.registMessage(2288,"UpdateRefreshDailyInformation")

-- PbMsgId.RemoveEquipmentFromCard = 2361
PbRegist.registMessage(2361,"RemoveEquipmentFromCard")

-- PbMsgId.RemoveEquipmentFromCardResult = 2438
PbRegist.registMessage(2438,"RemoveEquipmentFromCardResult")

--PbMsgId.AskForOnlineReward = 2555
PbRegist.registMessage(2555,"AskForOnlineReward")

--PbMsgId.AskForOnlineRewardResult = 2556
PbRegist.registMessage(2556,"AskForOnlineRewardResult")

-- PbMsgId.ItemCombineToItem = 3255
PbRegist.registMessage(3255,"ItemCombineToItem")

-- PbMsgId.ItemCombineToItemResult = 2356
PbRegist.registMessage(2356,"ItemCombineToItemResult")

-- PbMsgId.ItemCombineToCard = 2577
PbRegist.registMessage(2577,"ItemCombineToCard")

-- PbMsgId.ItemCombineToCardResult = 2578
PbRegist.registMessage(2578,"ItemCombineToCardResult")


-- PbMsgId.SellItemToSystem = 3271
PbRegist.registMessage(3271,"SellItemToSystem")

-- PbMsgId.SellItemToSystemResult = 3272
PbRegist.registMessage(3272,"SellItemToSystemResult")

-- PbMsgId.SellEquipmentToSystem = 3273
PbRegist.registMessage(3273,"SellEquipmentToSystem")

-- PbMsgId.SellEquipmentToSystemResult = 3274
PbRegist.registMessage(3274,"SellEquipmentToSystemResult")

-- PbMsgId.CardTurnback = 3285
PbRegist.registMessage(3285,"CardTurnback")

-- PbMsgId.CardTurnbackResult = 3286
PbRegist.registMessage(3286,"CardTurnbackResult")

-- PbMsgId.QuickExchangeCard = 2561
PbRegist.registMessage(2561,"QuickExchangeCard")

-- PbMsgId.QuickExchangeCardResult = 2562
PbRegist.registMessage(2562,"QuickExchangeCardResult")

-- PbMsgId.SmeltCard = 2637
PbRegist.registMessage(2637,"SmeltCard")

-- PbMsgId.SmeltCardResult = 2638
PbRegist.registMessage(2638,"SmeltCardResult")

-- PbMsgId.EatPatty = 3211
PbRegist.registMessage(3211,"EatPatty")

-- PbMsgId.EatPattyResult = 3212
PbRegist.registMessage(3212,"EatPattyResult")

-- PbMsgId.AskForMonthReward = 3323
PbRegist.registMessage(3323,"AskForMonthReward")

-- PbMsgId.AskForMonthRewardResult = 3325
PbRegist.registMessage(3325,"AskForMonthRewardResult")

-- PbMsgId.OpenItemCell = 3333
PbRegist.registMessage(3333,"OpenItemCell")

-- PbMsgId.OpenItemCellResult = 3334
PbRegist.registMessage(3334,"OpenItemCellResult")

-- PbMsgId.MonthRegister = 3337
PbRegist.registMessage(3337,"MonthRegister")

-- PbMsgId.MonthRegisterResult = 3338
PbRegist.registMessage(3338,"MonthRegisterResult")

-- PbMsgId.AskForMonthRegisterState = 3339
PbRegist.registMessage(3339,"AskForMonthRegisterState")

-- PbMsgId.AskForMonthRegisterStateResult = 3336
PbRegist.registMessage(3336,"AskForMonthRegisterStateResult")

-- PbMsgId.AskForCanEatPatty = 3432
PbRegist.registMessage(3432,"AskForCanEatPatty")

-- PbMsgId.AskForCanEatPattyResult = 3546
PbRegist.registMessage(3546,"AskForCanEatPattyResult")

-- PbMsgId.SellCardToSystem = 3541
PbRegist.registMessage(3541,"SellCardToSystem")

-- PbMsgId.SellCardToSystemResult = 3542
PbRegist.registMessage(3542,"SellCardToSystemResult")

-- PbMsgId.AskForLevelReward = 3557
PbRegist.registMessage(3557,"AskForLevelReward")

-- PbMsgId.AskForLevelRewardResult = 3558
PbRegist.registMessage(3558,"AskForLevelRewardResult")

-- PbMsgId.PlayerChangePassward = 3561
PbRegist.registMessage(3561,"PlayerChangePassward")

-- PbMsgId.PlayerChangePasswardResult = 4454
PbRegist.registMessage(4454,"PlayerChangePasswardResult")

-- PbMsgId.PlayerChangeUserName = 4451
PbRegist.registMessage(4451,"PlayerChangeUserName")

-- PbMsgId.PlayerChangeUserNameResult = 4457
PbRegist.registMessage(4457,"PlayerChangeUserNameResult")

-- PbMsgId.AskForTaskState = 3753
PbRegist.registMessage(3753,"AskForTaskState")

-- PbMsgId.TaskState = 3754
PbRegist.registMessage(3754,"TaskState")

-- PbMsgId.ReceiveDailyTask = 3761
PbRegist.registMessage(3761,"ReceiveDailyTask")

-- PbMsgId.ReceiveDailyTaskResult = 3772
PbRegist.registMessage(3772,"ReceiveDailyTaskResult")

-- PbMsgId.AskForMainTaskAward = 3567
PbRegist.registMessage(3567,"AskForMainTaskAward")

-- PbMsgId.AskForMainTaskAwardResult = 3568
PbRegist.registMessage(3568,"AskForMainTaskAwardResult")

-- PbMsgId.AskForSideTaskAward = 3577
PbRegist.registMessage(3577,"AskForSideTaskAward")

-- PbMsgId.AskForSideTaskAwardResult = 3236
PbRegist.registMessage(3236,"AskForSideTaskAwardResult")

-- PbMsgId.AskForDailyTaskTable = 3465
PbRegist.registMessage(3465,"AskForDailyTaskTable")

-- PbMsgId.AskForDailyTaskTableResult = 3466
PbRegist.registMessage(3466,"AskForDailyTaskTableResult")

-- PbMsgId.AskForDailyTaskReward = 4417
PbRegist.registMessage(4417,"AskForDailyTaskReward")

-- PbMsgId.AskForDailyTaskRewardResult = 4418
PbRegist.registMessage(4418,"AskForDailyTaskRewardResult")

-- PbMsgId.DropDailyTask = 4423
PbRegist.registMessage(4423,"DropDailyTask")

-- PbMsgId.DropDailyTaskResult = 4424
PbRegist.registMessage(4424,"DropDailyTaskResult")

-- PbMsgId.RefreshFreeDailyTaskTable = 4425
PbRegist.registMessage(4425,"RefreshFreeDailyTaskTable")

-- PbMsgId.RefreshFreeDailyTaskTableResult = 4426
PbRegist.registMessage(4426,"RefreshFreeDailyTaskTableResult")

-- PbMsgId.RefreshMoneyDailyTaskTable = 4427
PbRegist.registMessage(4427,"RefreshMoneyDailyTaskTable")

-- PbMsgId.RefreshMoneyDailyTaskTableResult = 4429
PbRegist.registMessage(4429,"RefreshMoneyDailyTaskTableResult")

-- PbMsgId.AskForVipGift = 3641
PbRegist.registMessage(3641,"AskForVipGift")

-- PbMsgId.AskForVipGiftResult = 3450
PbRegist.registMessage(3450,"AskForVipGiftResult")

-- PbMsgId.AskForVipRebate = 3747
PbRegist.registMessage(3747,"AskForVipRebate")

-- PbMsgId.AskForVipRebateResult = 3878
PbRegist.registMessage(3878,"AskForVipRebateResult")

-- PbMsgId.ChangeAvatar = 3779
PbRegist.registMessage(3779,"ChangeAvatar")

-- PbMsgId.ChangeAvatarResult = 3780
PbRegist.registMessage(3780,"ChangeAvatarResult")

-- PbMsgId.ItemCombineToEquipment = 4301
PbRegist.registMessage(4301,"ItemCombineToEquipment")

-- PbMsgId.ItemCombineToEquipmentResult = 4302
PbRegist.registMessage(4302,"ItemCombineToEquipmentResult")

-- PbMsgId.UpdateCardSkillExperience = 4461
PbRegist.registMessage(4461,"UpdateCardSkillExperience")

-- PbMsgId.UpdateCardSkillExperienceResult = 4462
PbRegist.registMessage(4462,"UpdateCardSkillExperienceResult")

-- PbMsgId.MsgC2SMailToFriend = 5008
PbRegist.registMessage(5008,"MsgC2SMailToFriend")

-- PbMsgId.MsgS2CMailList = 5009
PbRegist.registMessage(5009,"MsgS2CMailList")

-- PbMsgId.MsgC2SMailRemove = 5010
PbRegist.registMessage(5010,"MsgC2SMailRemove")

-- PbMsgId.MailGetAdjunctC2S = 5059
PbRegist.registMessage(5059,"MailGetAdjunctC2S")

-- PbMsgId.MailGetAdjunctResultS2C = 5080
PbRegist.registMessage(5080,"MailGetAdjunctResultS2C")

-- PbMsgId.MailUpdateC2S = 5081
PbRegist.registMessage(5081,"MailUpdateC2S")

-- PbMsgId.FightReqBS2FS = 5014
--PbRegist.registMessage(5014,"FightReqBS2FS")

-- PbMsgId.FightReqCS2BS = 5015
PbRegist.registMessage(5015,"FightReqCS2BS")

-- PbMsgId.FightErrorBS2CS = 5016
PbRegist.registMessage(5016,"FightErrorBS2CS")

-- PbMsgId.FightReqCheckCS2BS = 5017
PbRegist.registMessage(5017,"FightReqCheckCS2BS")

-- PbMsgId.PVPQueryDataC2S = 5020
PbRegist.registMessage(5020,"PVPQueryDataC2S")

-- PbMsgId.PVPQueryDataResultS2C = 5021
PbRegist.registMessage(5021,"PVPQueryDataResultS2C")

-- PbMsgId.PVPQueryDataResultS2C = 5022
PbRegist.registMessage(5022,"PVPQueryTargetC2S")

-- PbMsgId.PVPQueryTargetResultS2C = 5023
PbRegist.registMessage(5023,"PVPQueryTargetResultS2C")

-- PbMsgId.PVPFightCheckC2S = 5024
PbRegist.registMessage(5024,"PVPFightCheckC2S")

-- PbMsgId.PVPFightReqC2S = 5030
PbRegist.registMessage(5030,"PVPFightReqC2S")

-- PbMsgId.PVPFightResultS2C = 5028
PbRegist.registMessage(5028,"PVPFightResultS2C")

-- PbMsgId.PVPAwardC2S = 5029
PbRegist.registMessage(5029,"PVPAwardC2S")

-- PbMsgId.PVPAwardResultS2C = 5032
PbRegist.registMessage(5032,"PVPAwardResultS2C")

-- PbMsgId.PVPCalculateResultS2C = 5033
PbRegist.registMessage(5033,"PVPCalculateResultS2C")

-- PbMsgId.PVPQueryRankC2S = 5044
PbRegist.registMessage(5044,"PVPQueryRankC2S")

-- PbMsgId.PVPQueryRankResultS2C = 5045
PbRegist.registMessage(5045,"PVPQueryRankResultS2C")

-- PbMsgId.BossFightReqC2S = 5046
PbRegist.registMessage(5046,"BossFightReqC2S")

-- PbMsgId.BossFightCheckC2S = 5047
PbRegist.registMessage(5047,"BossFightCheckC2S")

-- PbMsgId.BossQueryDataC2S = 5048
PbRegist.registMessage(5048,"BossQueryDataC2S")

-- PbMsgId.BossQueryDataResultS2C = 5049
PbRegist.registMessage(5049,"BossQueryDataResultS2C")

-- PbMsgId.BossFightResultS2C = 5051
PbRegist.registMessage(5051,"BossFightResultS2C")

-- PbMsgId.BossFightClearTimeC2S = 5052
PbRegist.registMessage(5052,"BossFightClearTimeC2S")

-- PbMsgId.BossFightClearTimeResultS2C = 5053
PbRegist.registMessage(5053,"BossFightClearTimeResultS2C")

-- PbMsgId.BossFightStateS2C = 5055
PbRegist.registMessage(5055,"BossFightStateS2C")

-- PbMsgId.BossQueryRankC2S = 5056
PbRegist.registMessage(5056,"BossQueryRankC2S")

-- PbMsgId.BossQueryRankResultS2C = 5057
PbRegist.registMessage(5057,"BossQueryRankResultS2C")

-- PbMsgId.BossDamageNoticeS2C = 5058
PbRegist.registMessage(5058,"BossDamageNoticeS2C")

PbMsgId.QuickFightIntstanceC2S = 5082
PbRegist.registMessage(5082,"QuickFightInstanceC2S")

-- PbMsgId.QuickFightIntstanceResultS2C = 5083
PbRegist.registMessage(5083,"QuickFightInstanceResultS2C")

-- PbMsgId.Logout = 5109
PbRegist.registMessage(5109,"Logout")

--------- for battle ------------------

-- PbMsgId.DebugGetSingleFightResult = 1543
PbRegist.registMessage(1543,"DebugGetSingleFightResult")

-- PbMsgId.NormalBattleResult = 8000
PbRegist.registMessage(8000,"NormalBattleResult")

-- PbMsgId.FightResult = 5019
PbRegist.registMessage(5019,"FightResult")

-- PbMsgId.AskForDrawTenCardInformation = 1773
PbRegist.registMessage(1773,"AskForDrawTenCardInformation")
-- PbMsgId.AskForDrawTenCardInformationResult = 3268
PbRegist.registMessage(3268,"AskForDrawTenCardInformationResult")

-----------------for friend---------------
-- PbMsgId.MsgC2SQueryRelation = 5011
PbRegist.registMessage(5011,"MsgC2SQueryRelation")

-- PbMsgId.MsgS2CFriendLists = 5000
PbRegist.registMessage(5000,"MsgS2CFriendLists")

-- PbMsgId.MsgC2SInviteFriend = 5004
PbRegist.registMessage(5004,"MsgC2SInviteFriend")
-- PbMsgId.MsgS2CInviteLists = 5002    --
PbRegist.registMessage(5002,"MsgS2CInviteLists")

-- PbMsgId.MsgS2CRecommendLists = 5001    --
PbRegist.registMessage(5001,"MsgS2CRecommendLists")

-- PbMsgId.MsgS2CInviteResult = 5005    --
PbRegist.registMessage(5005,"MsgS2CInviteResult")

-- PbMsgId.MsgS2CInviteResult = 5003    --
PbRegist.registMessage(5003,"MsgC2SChooseInvite")

-- PbMsgId.MsgS2CChooseResult = 5091    --
PbRegist.registMessage(5091,"MsgS2CChooseResult")


-- PbMsgId.MsgC2SRemoveFriend = 5006    --
PbRegist.registMessage(5006,"MsgC2SRemoveFriend")
-- PbMsgId.MsgS2CRemoveFriendResult = 5007    --
PbRegist.registMessage(5007,"MsgS2CRemoveFriendResult")

-----------------for friend Interact ---------------

-- PbMsgId.InteractQueryDataC2S = 5060    --
PbRegist.registMessage(5060,"InteractQueryDataC2S")
-- PbMsgId.InteractQueryDataResultS2C = 5061    --
PbRegist.registMessage(5061,"InteractQueryDataResultS2C")

-- PbMsgId.InteractChangeCardC2S = 5062   --
PbRegist.registMessage(5062,"InteractChangeCardC2S")
-- PbMsgId.InteractChangeCardResultS2C = 5063    --
PbRegist.registMessage(5063,"InteractChangeCardResultS2C")

-- PbMsgId.InteractCardTryWorkC2S = 5064   --
PbRegist.registMessage(5064,"InteractCardTryWorkC2S")
-- PbMsgId.InteractCardTryWorkResultS2C = 5065    --
PbRegist.registMessage(5065,"InteractCardTryWorkResultS2C")

-- PbMsgId.InteractUpdateS2C  = 5066   --
PbRegist.registMessage(5066,"InteractUpdateS2C")

-- PbMsgId.InteractCardFightC2S  = 5067   --
PbRegist.registMessage(5067,"InteractCardFightC2S")
-- PbMsgId.InteractCardFightResultS2C = 5068    --
PbRegist.registMessage(5068,"InteractCardFightResultS2C")

-- PbMsgId.InteractCardFightC2S  = 5069   --
PbRegist.registMessage(5069,"InteractAddMinesPosC2S")
-- PbMsgId.InteractAddMinesPosResultS2C = 5070    --
PbRegist.registMessage(5070,"InteractAddMinesPosResultS2C")

-- PbMsgId.InteractGetCoinC2S  = 5075   --
PbRegist.registMessage(5075,"InteractGetCoinC2S")
-- PbMsgId.InteractGetCoinResultS2C = 5070    --
PbRegist.registMessage(5076,"InteractGetCoinResultS2C")

-- PbMsgId.SaveNewBirdStep = 3531    --
PbRegist.registMessage(3531,"SaveNewBirdStep")

-- PbMsgId.NoticeS2C = 5085
PbRegist.registMessage(5085,"NoticeS2C")

-- PbMsgId.QueryPlayerShowC2S = 5088    --
PbRegist.registMessage(5088,"QueryPlayerShowC2S")

-- PbMsgId.QueryPlayerShowResultS2C = 5089    --
PbRegist.registMessage(5089,"QueryPlayerShowResultS2C")

-- PbMsgId.VipFreeRefreshDailyTaskTable = 4725
PbRegist.registMessage(4725,"VipFreeRefreshDailyTaskTable")

-- PbMsgId.VipFreeRefreshDailyTaskTableResult = 4726
PbRegist.registMessage(4726,"VipFreeRefreshDailyTaskTableResult")

-- PbMsgId.SaveBattlePosition = 4473
PbRegist.registMessage(4473,"SaveBattlePosition")

-- PbMsgId.SaveBattlePositionResult = 4399
PbRegist.registMessage(4399,"SaveBattlePositionResult")

-- PbMsgId.AwardCodeC2S = 5093
PbRegist.registMessage(5093,"AwardCodeC2S")

-- PbMsgId.AwardCodeResultS2C = 5094
PbRegist.registMessage(5094,"AwardCodeResultS2C")

-- PbMsgId.InstanceRefresh = 5018  refresh data at 24:00
PbRegist.registMessage(5018,"InstanceRefresh")

-- PbMsgId.ChangeCardEquipmentC2S = 5099
PbRegist.registMessage(5099,"ChangeCardEquipmentC2S")

-- PbMsgId.ChangeCardEquipmentResultS2C = 5100
PbRegist.registMessage(5100,"ChangeCardEquipmentResultS2C")



-- PbMsgId.AchievementProgressB2C = 9900
PbRegist.registMessage(9900,"AchievementProgressB2C")


-- PbMsgId.ReqForcibleDoneDailyTaskReqForcibleDoneDailyTask = 9902
PbRegist.registMessage(9902,"ReqForcibleDoneDailyTask")

-- PbMsgId.ReqForcibleDoneDailyTaskResult = 9903
PbRegist.registMessage(9903,"ReqForcibleDoneDailyTaskResult")

-- PbMsgId.ReqForcibleBuyStage = 9904
PbRegist.registMessage(9904,"ReqForcibleBuyStage")

-- PbMsgId.ReqForcibleBuyStageResult = 9905
PbRegist.registMessage(9905,"ReqForcibleBuyStageResult")

-- PbMsgId.UseMoneyTree = 9906
PbRegist.registMessage(9906,"UseMoneyTree")

-- PbMsgId.UseMoneyTreeResult = 9907
PbRegist.registMessage(9907,"UseMoneyTreeResult")

-- PbMsgId.CommodityListS2C = 5097
PbRegist.registMessage(5097,"CommodityListS2C")

-- PbMsgId.CommodityQueryC2S = 5098
PbRegist.registMessage(5098,"CommodityQueryC2S")


-- PbMsgId.AskForAchievementGift = 3671
PbRegist.registMessage(3671,"AskForAchievementGift")

-- PbMsgId.AskForAchievementGiftResult = 4432
PbRegist.registMessage(4432,"AskForAchievementGiftResult")

-- PbMsgId.AskForAchievementDrop = 9909
PbRegist.registMessage(9909,"AskForAchievementDrop")


-- PbMsgId.AskForAchievementDropResult = 10001
PbRegist.registMessage(10001,"AskForAchievementDropResult")

-- PbMsgId.PlatformOrderResultS2C = 5096
PbRegist.registMessage(5096,"PlatformOrderResultS2C")

-- PbMsgId.PlayerQueryRndNameC2S = 5101
PbRegist.registMessage(5101,"PlayerQueryRndNameC2S")

-- PbMsgId.PlayerQueryRndNameS2C = 5102
PbRegist.registMessage(5102,"PlayerQueryRndNameS2C")

PbRegist.registMessage(9601,"SysNoticeBroadCast")

-- PbMsgId.BuyVipTicketC2S = 5103
PbRegist.registMessage(5103,"BuyVipTicketC2S")

-- PbMsgId.BuyVipTicketResultS2C = 5104
PbRegist.registMessage(5104,"BuyVipTicketResultS2C")

-- PbMsgId.QueryDrawCardRebateC2S = 5105
PbRegist.registMessage(5105,"QueryDrawCardRebateC2S")

-- PbMsgId.QueryDrawCardRebateResultS2C = 5106
PbRegist.registMessage(5106,"QueryDrawCardRebateResultS2C")

-- PbMsgId.LoginVersionChangeS2C = 5107
PbRegist.registMessage(5107,"LoginVersionChangeS2C")

-- PbMsgId.PVPUseProtectItemC2S = 5118
PbRegist.registMessage(5118,"PVPUseProtectItemC2S")

-- PbMsgId.PVPUseProtectItemResultS2C = 5119
PbRegist.registMessage(5119,"PVPUseProtectItemResultS2C")

-- PbMsgId.UseWordGameItemC2S = 5120
PbRegist.registMessage(5120,"UseWordGameItemC2S")

-- PbMsgId.UseWordGameItemResultS2C = 5121
PbRegist.registMessage(5121,"UseWordGameItemResultS2C")

-- PbMsgId.QuickDrawCardUseItem = 10020
PbRegist.registMessage(10020,"QuickDrawCardUseItem")

-- PbMsgId.QuickDrawCardUseItemResult = 10021
PbRegist.registMessage(10021,"QuickDrawCardUseItemResult")

--activity stage
-- PbMsgId.ActivityFightReqCheckCS2BS = 10030
PbRegist.registMessage(10030,"ActivityFightReqCheckCS2BS")

-- PbMsgId.ActivityFightReqCS2BS = 10031
PbRegist.registMessage(10031,"ActivityFightReqCS2BS")

-- PbMsgId.ReqForcibleBuyActivityStage = 10032
PbRegist.registMessage(10032,"ReqForcibleBuyActivityStage")

-- PbMsgId.ReqForcibleBuyActivityStageResult = 10033
PbRegist.registMessage(10033,"ReqForcibleBuyActivityStageResult")

-- PbMsgId.LivenessProgressB2C = 10035
PbRegist.registMessage(10035,"LivenessProgressB2C")

-- PbMsgId.AskForLivenessPointGift = 10036
PbRegist.registMessage(10036,"AskForLivenessPointGift")

-- PbMsgId.AskForLivenessPointGiftResult = 10037
PbRegist.registMessage(10037,"AskForLivenessPointGiftResult")

-- PbMsgId.AskForLivenessWeekPointGift = 10038
PbRegist.registMessage(10038,"AskForLivenessWeekPointGift")

-- PbMsgId.TalentBankLevelUpC2S = 5111
PbRegist.registMessage(5111,"TalentBankLevelUpC2S")

-- PbMsgId.TalentBankLevelUpResultS2C = 5113
PbRegist.registMessage(5113,"TalentBankLevelUpResultS2C")

-- PbMsgId.TalentClearCDC2S = 5115
PbRegist.registMessage(5115,"TalentClearCDC2S")

-- PbMsgId.TalentClearCDResultS2C = 5116
PbRegist.registMessage(5116,"TalentClearCDResultS2C")

-- PbMsgId.TalentDataQueryC2S = 5117
PbRegist.registMessage(5117,"TalentDataQueryC2S")

-- PbMsgId.TalentGetPointC2S = 5112
PbRegist.registMessage(5112,"TalentGetPointC2S")

-- PbMsgId.TalentGetPointResultS2C = 5123
PbRegist.registMessage(5123,"TalentGetPointResultS2C")

-- PbMsgId.TalentDataQueryResultS2C = 5124
PbRegist.registMessage(5124,"TalentDataQueryResultS2C")

-- PbMsgId.TalentLevelUpC2S = 5110
PbRegist.registMessage(5110,"TalentLevelUpC2S")

-- PbMsgId.TalentLevelUpResultS2C = 5114
PbRegist.registMessage(5114,"TalentLevelUpResultS2C")

-- PbMsgId.UseItemC2S = 5125
PbRegist.registMessage(5125,"UseItemC2S")

-- PbMsgId.UseItemResultS2C = 5126
PbRegist.registMessage(5126,"UseItemResultS2C")

-- PbMsgId.AskForLivenessWeekPointGiftResult = 10039
PbRegist.registMessage(10039,"AskForLivenessWeekPointGiftResult")

---- PbMsgId.EatEquip  = 10042
--PbRegist.registMessage(10042,"EatEquip")
--
---- PbMsgId.EatEquipResult = 10043
--PbRegist.registMessage(10043,"EatEquipResult")

-- PbMsgId.EquipTurnback   = 10045
PbRegist.registMessage(10045,"EquipTurnback")

-- PbMsgId.EquipTurnbackResult  = 10046
PbRegist.registMessage(10046,"EquipTurnbackResult")

---- PbMsgId.SmeltEquip   = 10040
--PbRegist.registMessage(10040,"SmeltEquip")
--
---- PbMsgId.SmeltEquipResult  = 10041
--PbRegist.registMessage(10041,"SmeltEquipResult")

---- PbMsgId.EatEquip   = 10042
--PbRegist.registMessage(10042,"EatEquip")
--
---- PbMsgId.EatEquipResult  = 10043
--PbRegist.registMessage(10043,"EatEquipResult")

-- PbMsgId.EquipXiLian   = 10047
PbRegist.registMessage(10047,"EquipXiLian")

-- PbMsgId.EquipXiLianResult  = 10048
PbRegist.registMessage(10048,"EquipXiLianResult")

-- PbMsgId.EquipXiLianReplace   = 10050
PbRegist.registMessage(10050,"EquipXiLianReplace")

-- PbMsgId.EquipXiLianReplaceResult  = 10051
PbRegist.registMessage(10051,"EquipXiLianReplaceResult")

-- PbMsgId.EquipStrengthen = 10057
PbRegist.registMessage(10057,"EquipStrengthen")

-- PbMsgId.EquipStrengthenResult = 10058
PbRegist.registMessage(10058,"EquipStrengthenResult")

-- PbMsgId.EquipTurnExclusive = 10059
PbRegist.registMessage(10059,"EquipTurnExclusive")

-- PbMsgId.EquipTurnExclusiveResult  = 10060
PbRegist.registMessage(10060,"EquipTurnExclusiveResult")

-- PbMsgId.NewPlayerCardGiftC2S = 5139
PbRegist.registMessage(5139,"NewPlayerCardGiftC2S")

-- PbMsgId.NewPlayerCardGiftResultS2C = 5140
PbRegist.registMessage(5140,"NewPlayerCardGiftResultS2C")

PbRegist.registMessage(5141,"ActivityProgressS2C")

-- PbMsgId.FestivalGiftQueryC2S = 5142
PbRegist.registMessage(5142,"FestivalGiftQueryC2S")

-- PbMsgId.FestivalGiftResultS2C = 5143
PbRegist.registMessage(5143,"FestivalGiftResultS2C")

--PVPArena
PbRegist.registMessage(5127,"PVPArenaQueryC2S")

PbRegist.registMessage(5128,"PVPArenaQueryResultS2C")

PbRegist.registMessage(5129,"PVPArenaSearchC2S")

PbRegist.registMessage(5130,"PVPArenaSearchResultS2C")

PbRegist.registMessage(5131,"PVPArenaChangeCardC2S")

PbRegist.registMessage(5132,"PVPArenaChangeCardResultS2C")

PbRegist.registMessage(5133,"PVPArenaTargetChangeCardS2C")

PbRegist.registMessage(5134,"PVPArenaFightReqC2S")

PbRegist.registMessage(5135,"PVPArenaFightResultS2C")

PbRegist.registMessage(5137,"PVPArenaStateS2C")

PbRegist.registMessage(5145,"PVPArenaRankS2C")

PbRegist.registMessage(5146,"PVPArenaBuyChanceC2S")

PbRegist.registMessage(5147,"PVPArenaBuyChanceResultS2C")

-- battle report review
PbRegist.registMessage(10052,"PVPQueryReportReview")

PbRegist.registMessage(10054,"PVPQueryReportReviewResult")

PbRegist.registMessage(10055,"ReqJianghun")

PbRegist.registMessage(10056,"ReqJianghunResult")

PbRegist.registMessage(5148,"PlayerStoreInfoS2C")

PbRegist.registMessage(5149,"PlayerBuyFormStoreC2S")

PbRegist.registMessage(5150,"PlayerBuyFormStoreResultS2C")

PbRegist.registMessage(5151,"PlayerRefreshStoreC2S")

PbRegist.registMessage(5152,"PlayerRefreshStoreResultS2C")

PbRegist.registMessage(5153,"BuyVipGiftC2S")

PbRegist.registMessage(5154,"BuyVipGiftResultS2c")

PbRegist.registMessage(5155,"GameServerInformationS2C")

PbRegist.registMessage(5156,"RankInformationS2C")

PbRegist.registMessage(5157,"QueryAwardResultS2C")

PbRegist.registMessage(5158,"QueryAwardC2S")

PbRegist.registMessage(5159,"RankInformationQueryC2S")

PbRegist.registMessage(10061,"ReqWechatShare")

PbRegist.registMessage(10062,"ReqWechatShareResult")

PbRegist.registMessage(5160,"PVPRankMatchQueryC2S")

PbRegist.registMessage(5161,"PVPRankMatchQueryResultS2C")

PbRegist.registMessage(5162,"PVPRankMatchSearchC2S")

PbRegist.registMessage(5163,"PVPRankMatchSearchResultS2C")

PbRegist.registMessage(5164,"PVPRankMatchFightCheckC2S")

PbRegist.registMessage(5165,"PVPRankMatchFightReqC2S")

PbRegist.registMessage(5166,"PVPRankMatchFightResultS2C")

PbRegist.registMessage(5167,"PVPRankMatchClearCDC2S")

PbRegist.registMessage(5168,"PVPRankMatchClearCDResultS2C")

PbRegist.registMessage(5169,"PVPRankMatchBuyCountC2S")

PbRegist.registMessage(5170,"PVPRankMatchBuyCountResultS2C")

PbRegist.registMessage(5171,"SaveBattleFormationC2S")

PbRegist.registMessage(5172,"SaveBattleFormationResultS2C")

PbRegist.registMessage(5174,"PVPRankMatchSyncS2C")

PbRegist.registMessage(10063,"ActivityMissionInfos")

PbRegist.registMessage(10064,"ReqActivityMissionAward")

PbRegist.registMessage(10065,"ReqActivityMissionAwardResult")

PbRegist.registMessage(10066,"ReqGetOddsAward")

PbRegist.registMessage(10067,"ReqGetOddsAwardResult")

PbRegist.registMessage(10068,"RechargeMaxInfo")

PbRegist.registMessage(10069,"ReqGiveLike")

PbRegist.registMessage(10070,"ReqGiveLikeResult")

PbRegist.registMessage(10071,"ReqGetLikeAward")

PbRegist.registMessage(10072,"ReqGetLikeAwardResult")

PbRegist.registMessage(5175,"ActivityStateS2C")

--guild
PbRegist.registMessage(5176,"GuildCreateC2S")
PbRegist.registMessage(5177,"GuildCreateResultS2C")
PbRegist.registMessage(5178,"GuildCreateApplyC2S")
PbRegist.registMessage(5179,"GuildCreateApplyResultS2C")
PbRegist.registMessage(5180,"GuildChangeMemberC2S")
PbRegist.registMessage(5181,"GuildChangeMemberResultS2C")
PbRegist.registMessage(5182,"GuildDonateC2S")
PbRegist.registMessage(5183,"GuildDonateResultS2C")
PbRegist.registMessage(5184,"GuildOpenInstanceC2S")
PbRegist.registMessage(5185,"GuildOpenInstanceResultS2C")
PbRegist.registMessage(5186,"GuildFightCheckC2S")
PbRegist.registMessage(5187,"GuildFightReqC2S")
PbRegist.registMessage(5188,"GuildLevelUpBuildC2S")
PbRegist.registMessage(5189,"GuildLevelUpBuildResultS2C")
PbRegist.registMessage(5190,"GuildMailC2S")
PbRegist.registMessage(5193,"GuildQueryC2S")
PbRegist.registMessage(5194,"GuildQueryResultS2C")
PbRegist.registMessage(5195,"GuildQuitC2S")
PbRegist.registMessage(5196,"GuildQuitResultS2C")
PbRegist.registMessage(5197,"GuildChangeBaseC2S")
PbRegist.registMessage(5198,"GuildChangeBaseResultS2C")
PbRegist.registMessage(5199,"GuildSyncS2C")
PbRegist.registMessage(5200,"GuildListS2C")

PbRegist.registMessage(10074,"ReqUseBigWheel")

PbRegist.registMessage(10075,"ReqUseBigWheelResult")

PbRegist.registMessage(10076,"ReqBigWheelAward")

PbRegist.registMessage(10077,"ReqBigWheelAwardResult")

PbRegist.registMessage(10104,"ReqUseQuickMoney")

PbRegist.registMessage(10105,"ReqUseQuickMoneyResult")

--chat
PbRegist.registMessage(5191,"ChatC2S")
PbRegist.registMessage(5192,"ChatS2C")

--bable 
PbRegist.registMessage(10084,"BableFightReqCheckC2S")
PbRegist.registMessage(10083,"BableFightReqCS2BS")
PbRegist.registMessage(10090,"ReqBableResetC2S")
PbRegist.registMessage(10091,"ReqBableResetResultS2C")
PbRegist.registMessage(10092,"ReqBableReliveC2S")
PbRegist.registMessage(10093,"ReqBableReliveResultS2C")
PbRegist.registMessage(10094,"ReqBableDailyAwardC2S")
PbRegist.registMessage(10095,"ReqBableDailyAwardResultS2C")
PbRegist.registMessage(10096,"BableSetHelpFriendCardC2S")
PbRegist.registMessage(10097,"BableSetHelpFriendCardResultS2C")
PbRegist.registMessage(10099,"BableGetHelpFriendAwardC2S")
PbRegist.registMessage(10100,"BableGetHelpFriendAwardResultS2C")
PbRegist.registMessage(10085,"BableChoiceFriendCardC2S")
PbRegist.registMessage(10086,"BableChoiceFriendCardResultS2C")
PbRegist.registMessage(10101,"BableSetHelpFriendCountC2B")
PbRegist.registMessage(10088,"BableChangeHelpCard")

--report share
PbRegist.registMessage(5208,"ReportShareS2C")
PbRegist.registMessage(5210,"ShareReportC2S")

PbRegist.registMessage(10102,"ReqExchangeActivityCard")
PbRegist.registMessage(10103,"ReqExchangeActivityCardResult")

--draw card
PbRegist.registMessage(5211,"GreatDrawCardC2S")
PbRegist.registMessage(5212,"GreatDrawCardResultS2C")