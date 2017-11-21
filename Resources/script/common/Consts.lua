Consts={
	Strings=require("localization.tr_consts"),
	Item={
		Base_WuJing = 22001001
	}
}


--props
iType_HunShi = 1
iType_JunLingZhuang = 2
iType_CardChip = 3 
iType_EquipChip = 4 
iType_HuFu = 5 
iType_BoxKey = 6 
iType_Box = 7 
iType_Spirite = 8 
iType_Token = 9 
iType_SkillBook = 10 
iType_JinNang = 11 
iType_YinPiao = 12 
iType_VipCard = 13
iType_ItemBox = 14 
iType_CardBox = 15 
iType_EqupBox = 16 
iType_GuaJiQuan = 17 
iType_MianZhanPai =18 
iType_Exchange = 19 
iType_XuanTie = 20 
iType_TalentPoint = 21 
iType_TalentTime = 22 
iType_WuJin = 23 
iType_ExpCard = 24 
iType_ItemBoxQKa = 25 --Q卡好礼宝箱
iType_ExpeditionMedicine = 26 --征战药水
iType_ArenaMedicine = 27  --武斗药水
iType_JingjiMedicine = 28 --竞技场药水
iType_Bable = 30  --还魂丹

RankEnum = {
  ["Level"] = 1,      --玩家等级
  ["Match"] = 2,      --排位赛等级
  ["Vip_Level"] = 3   --VIP等级
}

AwardType = {
  ["CHEPTER_AWARD"] = "CHEPTER_AWARD",
  ["BIGWHEEL_AWARD"] = "BIGWHEEL_AWARD",
  ["BABLE_AWARD"] = "BABLE_AWARD",
}


SourceType = enum({"None", "CardFromStage", "ChipFromStage", "Lottery", "Charpter", "Arena", "SoulShop", 
                    "Expedition","Gonghui", "JingJiChang", "Bable", "VipShop","TimeAct", "Battle", "SoulRefine"})

CurrencyType = {
  ["Coin"] = 1,       --铜钱
  ["Money"] = 2,      --元宝
  ["Soul"] = 5,       --将魂
  ["RankPoint"] = 6,  --竞技场
  ["GuildPoint"] = 7, --公会
  ["Bable"] = 8,      --过关斩将(通天塔)
}

SelectListType = enum({"CARD","ARMOR","ACCESSORY","WEAPON"})

CardListType = enum({"NONE","LEVEL_UP_CARD", "LEVEL_UP_EATTEN_CARD", "SURMOUNT", "DISMANTLE", "SKILL_UP", "CARD_SOUL", "CARD_REBORN", "BABLE_SHARE"})