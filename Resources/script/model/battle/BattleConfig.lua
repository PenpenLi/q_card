require("GameInitConfig")

BattleConfig = {}

BattleConfig.BattleFieldRow = 8
BattleConfig.BattleFieldCol = 4
BattleConfig.BattleFieldBegin = 0
BattleConfig.BattleFieldCount = BattleConfig.BattleFieldRow * BattleConfig.BattleFieldCol
BattleConfig.BattleFieldEnd = BattleConfig.BattleFieldBegin + BattleConfig.BattleFieldCount
BattleConfig.BattleFieldWallLength = 4
BattleConfig.BattleFieldWallCols = BattleConfig.BattleFieldWallLength/BattleConfig.BattleFieldCol

BattleConfig.BattleFieldWidth = 491
BattleConfig.BattleFieldHeight = 747
BattleConfig.BattleFieldLen = 106

BattleConfig.BattleSpeedLevel1 = CONFIG_BATTLE_SPEED_RATIO_LV1
BattleConfig.BattleSpeedLevel2 = CONFIG_BATTLE_SPEED_RATIO_LV2
BattleConfig.BattleSpeedLevel3 = CONFIG_BATTLE_SPEED_RATIO_LV3

BattleConfig.MaxRound = 30
BattleConfig.WallHugePercentLimit = 1.0/3.0

BattleConfig.IsUseSumaryFile = false

BattleConfig.LocalPlayStageId = 9999999
BattleConfig.ActionTypeNormalAttack = 1
BattleConfig.ActionTypeUseSkill = 2
BattleConfig.ActionTypeEnterTurn = 3
BattleConfig.ActionTypeBattleFinished = 4

BattleConfig.CardOwnerTypeSelf = "_SELF_CARD_"
BattleConfig.CardOwnerTypeFriend = "_FRIEND_CARD_"
BattleConfig.CardOwnerTypeAll = "_ALL_CARD_"

function gt_time(d1,d2)
  if d1 > d2 then
    return d1
  else
    return d2
  end
end

BattleConfig.ViewSpeed = 0.9

BattleConfig.BattleSide = {["Blue"] = 0,["Red"] = 1}

PbFieldType = {["Empty"] = 1,["Hill"] = 2,["Forest"] = 3,["Tower"] = 4,["Wall"] = 999}

PbFightResultType = {["BlueGroupWin"] = 0,["RedGroupWin"] = 1,["TooMuchRound"] = 2}

PbEventType = {["EventTypeMove"] = 0,["EventTypeAttack"] = 1,["EventTypeAlive"] = 2,
["EventTypeWallBroken"] = 3,["EventTypeSkill"] = 4,["EventTypeSkillDamage"] = 5,
["EventTypeChangeStatus"] = 6,["EventTypeDropItem"] = 7,["EventTypeTurn"] = 8,
["EventTypeCombineSkill"] = 9,["EventTypeEffect"] = 10,["EventTypeChangeValue"] = 11,
["EventTypeWallBeCure"] = 12,["EventTypeWallChangeValue"] = 13,["EventTypeWallAttack"] = 14 }

PbAttackType = {["AttackNormal"] = 1,["AttackForceMelee"] = 2}

PbDamageType = {["DamageNormal"] = 0,["DamageMiss"] = 1,["DamageBlock"] = 2,
["DamageCritical"] = 3,["DamageResist"] = 4,["DamageCure"] = 5}

PbTargetType = {["TargetCard"] = 0,["TargetWall"] = 1}

PbTroopType = {["Infantry"] = 1,["Cavalry"] = 2,["Archer"] = 3,
["Martial"] = 4,["Hoursemen"] = 5,["Counselor"] = 6,
["Taoist"] = 7,["Geomancer"] = 8,["Dancer"] = 9,
["Catapult"] = 10}

PbExtraEffectId = {["Reduce"] = 1,["Reflect"] = 2,["React"] = 3,
["Resist"] = 4,["Shield"] = 5,["Immune"] = 6,
["Shake"] = 7,["Restriction"] = 8,["BeRestriction"] = 9,["DoubleAngry"] = 10,
["ReduceAngry"] = 11,
}

PbMoveEffect = {["Normal"] = 1,["kMoveTypeClash"] = 2 
}

PbTroopSpt = {[PbTroopType.Infantry] = 3030001,[PbTroopType.Cavalry] = 3030003,[PbTroopType.Archer] = 3030002,
[PbTroopType.Martial] = 3030004,[PbTroopType.Hoursemen] = 3030005,[PbTroopType.Counselor] = 3030006,
[PbTroopType.Taoist] = 3030008,[PbTroopType.Geomancer] = 3030007,[PbTroopType.Dancer] = 3030009,
[PbTroopType.Catapult] = 3030010}

PbTroopAttackSfx = {[PbTroopType.Infantry] = SFX_MELEE_ATTACK,[PbTroopType.Cavalry] = SFX_MELEE_ATTACK,[PbTroopType.Archer] = SFX_RANGED_ATTACK,
[PbTroopType.Martial] = SFX_MARTIAL_ARTIST_ATTACK,[PbTroopType.Hoursemen] = SFX_RANGED_ATTACK,[PbTroopType.Counselor] = SFX_MAGE_ATTACK,
[PbTroopType.Taoist] = SFX_WIZARD_ATTACK,[PbTroopType.Geomancer] = SFX_CLERIC_ATTACK,[PbTroopType.Dancer] = SFX_DANCER_ATTACK,
[PbTroopType.Catapult] = SFX_CATAPULT_ATTACK}

PbTroopMoveSfx = {[PbTroopType.Infantry] = SFX_SWORDMAN_MOVE,[PbTroopType.Cavalry] = SFX_HORSEMAN_MOVE,[PbTroopType.Archer] = SFX_SWORDMAN_MOVE,
[PbTroopType.Martial] = SFX_SWORDMAN_MOVE,[PbTroopType.Hoursemen] = SFX_HORSEMAN_MOVE,[PbTroopType.Counselor] = SFX_SWORDMAN_MOVE,
[PbTroopType.Taoist] = SFX_SWORDMAN_MOVE,[PbTroopType.Geomancer] = SFX_SWORDMAN_MOVE,[PbTroopType.Dancer] = SFX_SWORDMAN_MOVE,
[PbTroopType.Catapult] = SFX_SWORDMAN_MOVE}

BattleSkillHitType = {["Common"] = 1,["Fire"] = 2,["Water"] = 3,
["Lighting"] = 4,["Poison"] = 5,["Restore"] = 6,
["Chain"] = 7,["Shield"] = 8,["Injure"] = 14
}

BattleSkillHitSfx = {[BattleSkillHitType.Common] = SFX_SKILL_HIT,[BattleSkillHitType.Fire] = SFX_SKILL_FIRE,[BattleSkillHitType.Water] = SFX_SKILL_WATER,
[BattleSkillHitType.Lighting] = SFX_SKILL_LIGHTING,[BattleSkillHitType.Poison] = SFX_SKILL_POISON,[BattleSkillHitType.Restore] = SFX_SKILL_HPRESTORE,
[BattleSkillHitType.Chain] = SFX_SKILL_CHAIN,[BattleSkillHitType.Shield] = SFX_SKILL_SHIELD }

-- PbTroopAnim[TroopType][Normal/Melee].src
PbTroopAnim = {
  {{ src = { animId = 0,flip = false,delay = 0},dst ={animId =  7010001,flip = false,delay = 0} },{ src = { animId = 0,flip = false,delay = 0},dst ={animId =  7010001,flip = false,delay = 0} }}, -- Infantry步兵
  {{ src = { animId = 0,flip = false,delay = 0},dst ={animId =  7010001,flip = false,delay = 0} },{ src = { animId = 0,flip = false,delay = 0},dst ={animId =  7010001,flip = false,delay = 0} }}, -- Cavalry骑兵
  {{ src = { animId = 7010002,flip = true,delay = 433},dst ={animId =  7010003,flip = true,delay = 0} },{ src = { animId = 0,flip = false,delay = 0},dst ={animId =  7010001,flip = false,delay = 0} }}, -- Archer弓箭
  {{ src = { animId = 0,flip = true,delay = 0,delay = 0},dst ={animId =  7010004,flip = false,delay = 0} },{ src = { animId = 0,flip = false,delay = 0},dst ={animId =  7010004,flip = false,delay = 0} }}, -- Martial武术家
  {{ src = { animId = 7010002,flip = true,delay = 433},dst ={animId =  7010003,flip = true,delay = 0} },{ src = { animId = 0,flip = false,delay = 0},dst ={animId =  7010001,flip = false,delay = 0} }}, -- Hoursemen弓骑兵
  {{ src = { animId = 0,flip = false,delay = 0,delay = 0},dst ={animId =  7010008,flip = false,delay = 0} },{ src = { animId = 0,flip = false,delay = 0},dst ={animId =  7010008,flip = false,delay = 0} }}, -- Counselor策士
  {{ src = { animId = 0,flip = false,delay = 0,delay = 0},dst ={animId =  7010005,flip = false,delay = 1000} },{ src = { animId = 0,flip = false,delay = 0},dst ={animId =  7010005,flip = false,delay = 0} }}, -- Taoist道士
  {{ src = { animId = 0,flip = false,delay = 0,delay = 0},dst ={animId =  7010006,flip = false,delay = 0} },{ src = { animId = 0,flip = false,delay = 0},dst ={animId =  7010006,flip = false,delay = 0} }}, -- Geomancer风水师
  {{ src = { animId = 0,flip = false,delay = 0,delay = 0},dst ={animId =  7010007,flip = false,delay = 0} },{ src = { animId = 0,flip = false,delay = 0},dst ={animId =  7010007,flip = false,delay = 0} }}, -- Dancer舞娘
  {{ src = { animId = 0,flip = false,delay = 0,delay = 0},dst ={animId =  7010009,flip = false,delay = 1100} },{ src = { animId = 0,flip = false,delay = 0},dst ={animId =  7010001,flip = false,delay = 0} }} -- Catapult投石车
}