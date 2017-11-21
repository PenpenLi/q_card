/********************************************************************
	created:	2013/11/27
	created:	27:11:2013   13:12
	file base:	LocalFight
	file ext:	cpp
	author:		Kevin
	
*********************************************************************/

#ifdef CLIENT
#ifdef COCOS2D
#include "Common/CommonDefine.h"
#include "json_lib.h"
#include "cocos-ext.h"
#endif
#endif


#ifdef ENABLE_LOCAL_FIGHT

#include "LocalFight.h"
#include "FightCommon.h"
#include "FightMain.h"
#include "MicroFightMain.h"
#include "AllConfigs.h"
#include <queue>
#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include <tchar.h>
#include <fstream>
#include <iostream>

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WINDOWS)
using namespace CSJson;
#endif



#define USE_RANDOM_VARS 0
#define PLAYER_OR_MONSTER 1 // 1 player,0 monster

GAME_FIGHT_MOUDLE_NAMESPACE_BEGIN

DianShiTech::Config::AllConfigs LocalFight::configs; 

void LocalFight::init()
{

	bool success = configs.init("script/config/datas/all_config_data.data","script/config/datas/mapping_id_data.data");

	/*if(success)
	{	
		using namespace std;
		//cout<<configs.has_unit(1100101)<<endl;
		//cout<<configs.unit(1100101).unit_name()<<endl;
		//cout<<configs.unit(1100101).activate_units(0)<<endl;

		::google::protobuf::RepeatedPtrField< ::DianShiTech::Config::DropConfig >* pMutable = configs.mutable_drop();
		cout<<"size:"<<pMutable->size()<<endl;
		for(::google::protobuf::RepeatedPtrField< ::DianShiTech::Config::DropConfig >::iterator it = pMutable->begin(); it != pMutable->end(); ++it)
		{
			cout<<it->id()<<endl;

		}

	}*/

	DianShiTech::Battle::Config::init(&configs);

	srand((unsigned int)time(NULL));
}

LocalFight::LocalFight()
{

}

LocalFight::~LocalFight()
{

}

static const void setupPlayerCard(stCardInitData& card,CSJson::Value& jsonCard)
{

  _fassert(Config::pAllConfig->has_unit(card.id),"Invalid card id:%d",card.id);
  const DianShiTech::Config::UnitConfig& unit = Config::pAllConfig->unit(card.id);
  const DianShiTech::Config::UnitInitDataConfig& unit_init = Config::pAllConfig->unitinitdata(unit.config());
  const DianShiTech::Config::UnitGrownConfig& unit_grown = Config::pAllConfig->unitgrown(card.id);

  int currentLevel = 5;// for test,assume that this card level is 5
  if (!jsonCard["level"].isNull())
  {
    currentLevel = jsonCard["level"].asInt();
  }

  int init_hp_ratio = 10000;
  if (!jsonCard["init_hp_ratio"].isNull())
  {
    init_hp_ratio = jsonCard["init_hp_ratio"].asInt();
  }
  card.init_hpper = init_hp_ratio;

  const int attrId = unit.attr_type() * 1000 + currentLevel;
  const DianShiTech::Config::AttrTypeConfig& attr_type = Config::pAllConfig->attrtype(attrId);
  int equip_str_fix = 0;
  int equip_str_per = 0;
  int equip_int_fix = 0;
  int equip_int_per = 0;
  int equip_dom_fix = 0;
  int equip_dom_per = 0;
  int equip_hp_fix = 0;
  int equip_hp_per = 0;
  int equip_atk_fix = 0;
  int equip_atk_per = 0;

  if (!jsonCard["equip_str_fix"].isNull())
  {
    equip_str_fix = jsonCard["equip_str_fix"].asInt();
  }

  if (!jsonCard["equip_str_per"].isNull())
  {
    equip_str_per = jsonCard["equip_str_per"].asInt();
  }

  if (!jsonCard["equip_int_fix"].isNull())
  {
    equip_int_fix = jsonCard["equip_int_fix"].asInt();
  }

  if (!jsonCard["equip_int_per"].isNull())
  {
    equip_int_per = jsonCard["equip_int_per"].asInt();
  }

  if (!jsonCard["equip_dom_fix"].isNull())
  {
    equip_dom_fix = jsonCard["equip_dom_fix"].asInt();
  }

  if (!jsonCard["equip_dom_per"].isNull())
  {
    equip_dom_per = jsonCard["equip_dom_per"].asInt();
  }

  if (!jsonCard["equip_hp_fix"].isNull())
  {
    equip_hp_fix = jsonCard["equip_hp_fix"].asInt();
  }

  if (!jsonCard["equip_hp_per"].isNull())
  {
    equip_hp_per = jsonCard["equip_hp_per"].asInt();
  }

  if (!jsonCard["equip_atk_fix"].isNull())
  {
    equip_atk_fix = jsonCard["equip_atk_fix"].asInt();
  }

  if (!jsonCard["equip_atk_per"].isNull())
  {
    equip_atk_per = jsonCard["equip_atk_per"].asInt();
  }

  const float strTransfer = (float)unit_init.str_atk() / kOneHundredPercent;
  const float intTranser = (float)unit_init.int_atk() / kOneHundredPercent;
  const float leadTranser = (float)unit_init.dom_hp() / kOneHundredPercent;
  const float ooc_str = (float)((float)unit_grown.str_grown() / kOneHundredPercent * attr_type.str_fix() + equip_str_fix) * (float)((kOneHundredPercent + equip_str_per)/kOneHundredPercent);
  const float ooc_int = (float)((float)unit_grown.int_grown() / kOneHundredPercent * attr_type.int_fix() + equip_int_fix) * (float)((kOneHundredPercent + equip_int_per)/kOneHundredPercent);
  const float ooc_dom = (float)((float)unit_grown.dom_grown() / kOneHundredPercent * attr_type.dom_fix() + equip_dom_fix) * (float)((kOneHundredPercent + equip_dom_per)/kOneHundredPercent);
  const float ooc_hp = (float)(ooc_dom * leadTranser + attr_type.hp_fix() + equip_hp_fix) * (float)((kOneHundredPercent + equip_hp_per)/kOneHundredPercent);
  const float ooc_atk = (float)(ooc_str * strTransfer + ooc_int * intTranser + attr_type.atk_fix() + equip_atk_fix) * (float)((kOneHundredPercent + equip_atk_per)/kOneHundredPercent);

  card.properties[k_property_str_fix] = ooc_str;
  card.properties[k_property_int_fix] = ooc_int;
  card.properties[k_property_dom_fix] = ooc_dom;
  card.properties[k_property_hp_fix] = ooc_hp;
  card.properties[k_property_atk_fix] = ooc_atk;

  card.properties[k_property_str_per] = 0;
  card.properties[k_property_int_per] = 0;
  card.properties[k_property_dom_per] = 0;
  card.properties[k_property_hp_per] = 0;
  card.properties[k_property_atk_per] = 0;

  card.properties[k_property_hit] = unit_grown.hit();
  card.properties[k_property_evade] = unit_grown.evade();
  card.properties[k_property_cri] = unit_grown.cri();
  card.properties[k_property_tough] = unit_grown.toughness();
  card.properties[k_property_block] = unit_grown.block();

  card.properties[k_property_precision] = 0;
  card.properties[k_property_damage_increase] = unit_grown.damage_increase();
  card.properties[k_property_damage_reduce] = unit_grown.damage_reduce();
  card.properties[kReflectFixedAddPercent] = unit_grown.reflect_fix();
  card.properties[kReflectPercentAddPercent] = 0;

  card.properties[k_property_hp_steal_fix] = unit_grown.hp_steal_fix();
  card.properties[kBloodDamagePercentAddPercent] = 0;
  card.properties[kBloodHpPercentAddPercent] =0;
  card.properties[kCriticalDamageIncAddPercent] = 0;
  card.properties[kCriticalDamageRdsAddPercent] = 0;
  //card.properties[k_property_final_damage_inc_per] = kOneHundredPercent * 0.5f;// inc 50% damage

  card.type = unit.unit_type();
  //card.type = (group == 0?1:1);
  card.strTransfer = strTransfer;
  card.intTranser = intTranser;
  card.leadTranser = leadTranser;
  card.maxAngry = kPlayerMaxAngry;
  card.angry = unit_init.energy_base();
  card.baseMove = unit_init.base_move();
  card.uniqueSkillId = unit.skill();
  card.baseAttack = 0;
  card.baseHp = 0;
  card.isBoss = false;
  card.isActivePassive = true;
  card.passiveSkillId = unit.talent();


  // for test
  //card.properties[k_property_hp_fix] = 1000;
  //card.maxAngry = card.angry = kPlayerMaxAngry;
  if (!jsonCard["skill_id"].isNull())
  {
    card.uniqueSkillId = jsonCard["skill_id"].asInt();
  }
  if (!jsonCard["init_angry"].isNull())
  {
    card.angry = jsonCard["init_angry"].asInt();
  }
  if (!jsonCard["unit_type"].isNull())
  {
    card.type = jsonCard["unit_type"].asInt();
  }
  if (!jsonCard["forbi_skill"].isNull())
  {
    card.isForbiSkill = jsonCard["forbi_skill"].asInt();
  }
  if (!jsonCard["is_primary"].isNull())
  {
    card.primary = jsonCard["is_primary"].asInt();
  }

  if (!jsonCard["active_passive"].isNull())
  {
    card.isActivePassive = jsonCard["active_passive"].asInt();
  }

  if (!jsonCard["skill_level"].isNull())
  {
    card.skillLevel = jsonCard["skill_level"].asInt();
  }

}

static const void setupMonsterCard(stCardInitData& card,CSJson::Value& jsonCard)
{

  _fassert(Config::pAllConfig->has_unit(card.id),"Invalid card id:%d",card.id);
  const DianShiTech::Config::UnitConfig& unit = Config::pAllConfig->unit(card.id);
  const int level = jsonCard["level"].asInt();
  const int unit_type = jsonCard["unit_type"].asInt();
  const int skill = jsonCard["skill"].asInt();
  const int talent = jsonCard["talent"].asInt();
  const int config = jsonCard["config"].asInt();
  const int atk_fix = jsonCard["atk_fix"].asInt();
  const int hp_fix = jsonCard["hp_fix"].asInt();
  const int str_fix = jsonCard["str_fix"].asInt();
  const int int_fix = jsonCard["int_fix"].asInt();
  const int dom_fix = jsonCard["dom_fix"].asInt();
  const int evade = jsonCard["evade"].asInt();
  const int hit = jsonCard["hit"].asInt();
  const int cri = jsonCard["cri"].asInt();
  const int tough = jsonCard["tough"].asInt();
  const int block = jsonCard["block"].asInt();
  const int precision = jsonCard["precision"].asInt();
  const int damage_reduce = jsonCard["damage_reduce"].asInt();
  const int damage_increase = jsonCard["damage_increase"].asInt();
  const int reflect_fix = jsonCard["reflect_fix"].asInt();
  const int hp_steal_fix = jsonCard["hp_steal_fix"].asInt();
  const int reflect_per = jsonCard["reflect_per"].asInt();

  const int type = jsonCard["type"].asInt();
  
  const DianShiTech::Config::UnitInitDataConfig& unit_init = Config::pAllConfig->unitinitdata(config);
  //const DianShiTech::Config::UnitGrownConfig& unit_grown = Config::pAllConfig->unitgrown(card.id);

  float strTransfer = 0;
  float intTranser = 0;
  float leadTranser = 0;
  if(type == 1)
  {
    const int attrId = unit.attr_type() * 1000 + level;
    const DianShiTech::Config::AttrTypeConfig& attr_type = Config::pAllConfig->attrtype(attrId);
    const int equip_str_fix = str_fix;
    const int equip_str_per = 0;
    const int equip_int_fix = int_fix;
    const int equip_int_per = 0;
    const int equip_dom_fix = dom_fix;
    const int equip_dom_per = 0;
    const int equip_hp_fix = hp_fix;
    const int equip_hp_per = 0;
    const int equip_atk_fix = atk_fix;
    const int equip_atk_per = 0;
    strTransfer = (float)unit_init.str_atk() / kOneHundredPercent;
    intTranser = (float)unit_init.int_atk() / kOneHundredPercent;
    leadTranser = (float)unit_init.dom_hp() / kOneHundredPercent;
    const float ooc_str = (float)( attr_type.str_fix() + equip_str_fix) * (float)((kOneHundredPercent + equip_str_per)/kOneHundredPercent);
    const float ooc_int = (float)( attr_type.int_fix() + equip_int_fix) * (float)((kOneHundredPercent + equip_int_per)/kOneHundredPercent);
    const float ooc_dom = (float)( attr_type.dom_fix() + equip_dom_fix) * (float)((kOneHundredPercent + equip_dom_per)/kOneHundredPercent);
    const float ooc_hp = (float)(ooc_dom * leadTranser + attr_type.hp_fix() + equip_hp_fix) * (float)((kOneHundredPercent + equip_hp_per)/kOneHundredPercent);
    const float ooc_atk = (float)(ooc_str * strTransfer + ooc_int * intTranser + attr_type.atk_fix() + equip_atk_fix) * (float)((kOneHundredPercent + equip_atk_per)/kOneHundredPercent);

    card.properties[k_property_str_fix] = ooc_str;
    card.properties[k_property_int_fix] = ooc_int;
    card.properties[k_property_dom_fix] = ooc_dom;
    card.properties[k_property_hp_fix] = ooc_hp;
    card.properties[k_property_atk_fix] = ooc_atk;
  }
  else
  { 
    strTransfer = 0;
    intTranser = 0;
    leadTranser = 0;
    card.properties[k_property_str_fix] = str_fix;
    card.properties[k_property_int_fix] = int_fix;
    card.properties[k_property_dom_fix] = dom_fix;
    card.properties[k_property_hp_fix] = hp_fix;
    card.properties[k_property_atk_fix] = atk_fix;
  }

  card.properties[k_property_str_per] = 0;
  card.properties[k_property_int_per] = 0;
  card.properties[k_property_dom_per] = 0;
  card.properties[k_property_hp_per] = 0;
  card.properties[k_property_atk_per] = 0;

  card.properties[k_property_hit] = hit;
  card.properties[k_property_evade] = evade;
  card.properties[k_property_cri] = cri;
  card.properties[k_property_tough] = tough;
  card.properties[k_property_block] = block;

  card.properties[k_property_precision] = precision;
  card.properties[k_property_damage_increase] = damage_increase;
  card.properties[k_property_damage_reduce] = damage_reduce;
  card.properties[kReflectFixedAddPercent] = reflect_fix;
  card.properties[kReflectPercentAddPercent] = reflect_per;

  card.properties[k_property_hp_steal_fix] = hp_steal_fix;
  card.properties[kBloodDamagePercentAddPercent] = 0;
  card.properties[kBloodHpPercentAddPercent] =0;
  card.properties[kCriticalDamageIncAddPercent] = 0;
  card.properties[kCriticalDamageRdsAddPercent] = 0;
  //card.properties[k_property_final_damage_inc_per] = kOneHundredPercent * 0.5f;// inc 50% damage

  card.type = unit_type;
  //card.type = (group == 0?1:1);
  card.strTransfer = strTransfer;
  card.intTranser = intTranser;
  card.leadTranser = leadTranser;
  card.maxAngry = kPlayerMaxAngry;
  card.angry = unit_init.energy_base();
  card.baseMove = unit_init.base_move();
  card.uniqueSkillId = skill;
  card.baseAttack = 0;
  card.baseHp = 0;
  card.isBoss = false;
  card.isActivePassive = true;
  card.passiveSkillId = talent;

  int init_hp_ratio = 10000;
  if (!jsonCard["init_hp_ratio"].isNull())
  {
    init_hp_ratio = jsonCard["init_hp_ratio"].asInt();
  }
  card.init_hpper = init_hp_ratio;

  if (!jsonCard["skill_id"].isNull())
  {
    card.uniqueSkillId = jsonCard["skill_id"].asInt();
  }
  if (!jsonCard["init_angry"].isNull())
  {
    card.angry = jsonCard["init_angry"].asInt();
  }
  if (!jsonCard["unit_type"].isNull())
  {
    card.type = jsonCard["unit_type"].asInt();
  }
  if (!jsonCard["forbi_skill"].isNull())
  {
    card.isForbiSkill = jsonCard["forbi_skill"].asInt();
  }
  if (!jsonCard["is_primary"].isNull())
  {
    card.primary = jsonCard["is_primary"].asInt();
  }

  if (!jsonCard["active_passive"].isNull())
  {
    card.isActivePassive = jsonCard["active_passive"].asInt();
  }

  if (!jsonCard["skill_level"].isNull())
  {
    card.skillLevel = jsonCard["skill_level"].asInt();
  }


}

std::string LocalFight::runGameFromFile(const char* buf)
{
  DianShiTech::Protocal::NormalBattleResult result;
  if (!loadFightFile(result, buf))
  {
    return "";    
  }
  return result.SerializeAsString();
}

const std::string& LocalFight::runGame(const char* buf)
{

  CSJson::Reader reader;
  CSJson::Value  root;
  if (reader.parse(buf, root))
  {
    using namespace DianShiTech::Battle;

    // prepare init data
    stGameInitData gameData;

    const int testType = root["TestType"].asInt();
    const std::string file_name = root["file_name"].asString();
    const int show_type = root["battle_show_type"].asInt();

    // show_type > 0 
    if (show_type > 0)
    {
      m_file_load = runGameFromFile(file_name.c_str());
      return m_file_load;
    }

    int testTimes = 0;
    if (!root["TestTimes"].isNull())
    {
      testTimes = root["TestTimes"].asInt();
    }

    const int fightType = root["FightType"].asInt();
    if (fightType == 1)
    {

      int bossHp = root["BossHp"].asInt();

      //for test boos fight
      gameData.battleType = kBattleFightBoss;
      if(gameData.battleType == kBattleFightBoss)
      {
        gameData.bossGroup = kRedGroup;
        gameData.bossHp = bossHp;
        gameData.bossMaxHp = bossHp;
      }
    }

    // prepare map
    stMapInitData& mapData = gameData.map;
    // parese map
    CSJson::Value& jsonMap = root["MapInitData"];
    mapData.mapId = jsonMap["mapId"].asInt();
    mapData.mapLevel = jsonMap["mapLevel"].asInt();
    if (!jsonMap["battle_condition"].isNull())
    {
      gameData.stageCondition = jsonMap["battle_condition"].asInt();
    }
    if (!jsonMap["battle_theme"].isNull())
    {
      mapData.battleTheme = jsonMap["battle_theme"].asInt();
    }
    for (int i = 0; i < Config::FightMapSize; ++i)
    {
      mapData.fields[i].type = kEmpty;
    }
    // loop fields
    CSJson::Value& jsonFields = jsonMap["FieldInitData"];
    for(size_t i = 0; i < jsonFields.size();++i)
    {
      CSJson::Value& jsonField = jsonFields[i];
      const int index = jsonField["index"].asInt();
      const int type = jsonField["type"].asInt();
      mapData.fields[index].index = index;
      mapData.fields[index].type = type;
    }
    // parse red wall
    CSJson::Value& redWall = jsonMap["RedWall"];
    mapData.walls[kRedGroup].level = redWall["level"].asInt();
    mapData.walls[kRedGroup].hp = redWall["hp"].asInt();
    // parse blue wall
    CSJson::Value& blueWall = jsonMap["BlueWall"];
    mapData.walls[kBlueGroup].level = blueWall["level"].asInt();
    mapData.walls[kBlueGroup].hp = blueWall["hp"].asInt();

    //parse card telent
    CSJson::Value& jsonTelentInitDatas = root["TelentInitData"];
    int t_count[kMaxGroup] = {0};
    for(int t = 0;t < jsonTelentInitDatas.size(); ++t)
    {
      CSJson::Value& jsonTelent = jsonTelentInitDatas[t];
      if (jsonTelent["telent_skill_id"].isNull())
      {
        continue;
      }
      int telentSkillId = jsonTelent["telent_skill_id"].asInt();
      const int group = jsonTelent["group"].asInt();
      stPlayerInitData& player = gameData.player[group];
      player.telentSkillsId[t_count[group]] = telentSkillId;
      ++t_count[group];
    }

    // parse cards
    CSJson::Value& jsonCardInitDatas = root["CardInitData"];
    int count[kMaxGroup] = {0};

    for(int i = 0;i < jsonCardInitDatas.size(); ++i)
    {
      CSJson::Value& jsonCard = jsonCardInitDatas[i];
      if (jsonCard["id"].isNull())
      {
        continue;
      }
      int cardId = jsonCard["id"].asInt();
      
      const int group = jsonCard["group"].asInt();
      const int type = jsonCard["type"].asInt();
      const int pos = jsonCard["pos"].asInt();

      stPlayerInitData& player = gameData.player[group];

      stCardInitData& card = player.cards[count[group]];
      ++count[group];
      card.id = cardId;
      card.group = group;
      card.pos = pos;
      if(player.playerId == kDefaultMonsterPlayerId)
      {
        // for test
        card.dropMonsterId = 10100104;
      }
      if (type == 0)
      {
        // player card
        setupPlayerCard(card,jsonCard);
      }else
      {
        // monster
        setupMonsterCard(card,jsonCard);
      }
    }

    for (int group = 0; group < kMaxGroup; ++group)
    {
      stPlayerInitData& player = gameData.player[group];
      player.playerId = 1000 * group;
      player.side = group;
      player.cardSize = count[group];
    }

    bool isLoadFromData = false;
    if (testType == 0)
    {
      if (isLoadFromData)
      {
        //std::fstream  os("D:/temp/battle.data",std::ios::out | std::ios::binary);
        //gameData.write(os);
        //os.close();

        std::fstream  is("D:/temp/battle.data",std::ios::in | std::ios::binary);
        stGameInitData _tempData;
        _tempData.read(is);
        is.close();
        m_fight.setup(_tempData);
      }else
      {
        m_fight.setup(gameData);
      }
      const std::string& r = m_fight.run();
      saveFightFile(m_fight.getResult().getResult(), file_name.c_str());
      return r;
    }else
    {

      time_t beginTime = time(0);  
      clock_t start, finish; 
      double duration = 0; 
      double totalBuffSize = 0;
      char buf[1024];
      strftime(buf,sizeof(buf),"%Y %x %A %X ......",localtime(&beginTime));  
      printf("begin at %s\n",buf);
      start = clock(); 

      int winTimes[kMaxGroup] = {0};
      for (int i = 0; i < testTimes;++i)
      {
        
        if (testType == 3)
        {
          for (int group = 0; group < kMaxGroup; ++group)
          {
            stPlayerInitData& player = gameData.player[group];
            for (int i = 0; i < player.cardSize;++i)
            {
              stCardInitData& cardData = player.cards[i];
              // random cards
              const auto& it = Config::pAllConfig->unit();
              const auto& card = it.Get(rand()%it.size());
              cardData.id = card.id();
              //printf("cardId:%d\n",cardData.id);
            }
          }

        }

        FightMain fight;
        fight.setup(gameData);

        fight.run();
        const FightResult& result = fight.getResult();
        totalBuffSize += result.getResult().ByteSize();
        const int winGroup = result.getResult().result().win_group();
        winTimes[winGroup]++;

      }
      finish = clock();
      time_t endTime = time(0);  
      strftime(buf,sizeof(buf),"%Y %x %A %X ......",localtime(&endTime));  
      printf("end at %s\n",buf);
      duration = (double)(finish - start) / CLOCKS_PER_SEC; 
      printf( "Total duration:%f seconds.\nEach instance consume:%f seconds.\nEach second runs %f instance.\n", duration,duration/testTimes,testTimes/duration); 

      printf("Total times:%d,Player[win:%d times,percent:%.2f%%],Monster[win:%d times,percent:%.2f%%],totalBuffSize:%.4fMB,avg size:%.4fMB\n",
        testTimes,winTimes[kBlueGroup],
        ((float)winTimes[kBlueGroup]/testTimes) * 100,
        winTimes[kRedGroup],
        ((float)winTimes[kRedGroup]/testTimes) * 100,
        totalBuffSize / (1000 * 1000),
        totalBuffSize / (1000 * 1000) / testTimes);

      return m_empty;
    }

  }else
  {
    _Flog("Battle test data error:%s",reader.getFormattedErrorMessages().c_str());
    _fassert(false,"Error");
    return m_empty;
  }
}

const std::string& LocalFight::runGame()
{

  using namespace DianShiTech::Battle;

  // prepare init data
  stGameInitData gameData;
  gameData.battleType = kBattleFightBoss;
  if(gameData.battleType == kBattleFightBoss)
  {
    gameData.bossGroup = kRedGroup;
    gameData.bossHp = 100;
  }
  // prepare map
  stMapInitData& mapData = gameData.map;
  // for test
  mapData.mapId = 10001;
  mapData.mapLevel = 1;
  for (int i = 0; i < Config::FightMapSize; ++i)
  {
    mapData.fields[i].type = kEmpty;
  }
  // add field 3 for type 2(hill)
  mapData.fields[3].index = 3;
  mapData.fields[3].type = kHill;

  // add field 7 for type 3(forest)
  mapData.fields[7].index = 7;
  mapData.fields[7].type = kForest;

  // add field 16 for type 4(tower)
  mapData.fields[16].index = 16;
  mapData.fields[16].type = kTower;

  mapData.walls[kBlueGroup].level = 1;
  mapData.walls[kBlueGroup].hp = 1000;
  mapData.walls[kRedGroup].level = 2;
  mapData.walls[kRedGroup].hp = 2000;

   /*
      Ë¾ÂíÜ² 11050201
      Â³Ëà 13050201
      ²Ü²Ù 11050101
      ¹ØÓð 12050204
      ÏÄºîÔ¨ 11050301
      Ô¬ÉÜ 14050401
      ÂÀ²¼ 14050101
      ËïÈ¨ 13050604

      ¶¡·å 13040101
      º«µ± 13040201
      ÕÔÔÆ 12050403
      ÕÅ·É 12050301
      »ªÙ¢ 14050203
      ÕÅ½Ç 14050301
      Ô¬ÉÜ 14050401
      ËïÉÐÏã 13050401
      Áõ±¸ 12050101
      ÕÅËÉ 12030201
   */
  /*
      ÕÅÁÉ 11050401

  */
  int cards[][8] = { { 12050101,12050301,12050204,12050204,11050301,14050401,14050101,13050604 },
                    { 12040101,13040201,12050403,12050301,14050203,14050301,14050401,13050401 }};

  bool isRandomPos = false;
  for (int group = 0; group < 2; ++group)
  {
    int pos[12];
    if(group == 0)
    {
      //for (int i = 0; i < 12; ++i)
      //{
      //	pos[i] = 4 + i;
      //}
      pos[4] = 8;pos[5] = 9;pos[6] = 10;pos[7] = 11;
      pos[0] = 12;pos[1] = 5;pos[2] = 6;pos[3] = 7;
      //pos[1] = 8;pos[3] = 9;pos[5] = 10;pos[7] = 11;
      //pos[0] = 4;pos[2] = 5;pos[4] = 6;pos[6] = 7;
    }else
    {
      //for (int i = 0; i < 4; ++i)
      //{
      //	pos[i] = i + 24;
      //}
      //for (int i = 4; i < 8; ++i)
      //{
      //	pos[i] = i + 16;
      //}
      pos[0] = 16;pos[1] = 25;pos[2] = 26;pos[3] = 27;
      pos[4] = 20;pos[5] = 21;pos[6] = 22;pos[7] = 23;
      //pos[0] = 24;pos[2] = 25;pos[4] = 26;pos[6] = 27;
      //pos[1] = 20;pos[3] = 21;pos[5] = 22;pos[7] = 23;
    }

    if(isRandomPos)
    {
      std::random_shuffle(pos,pos + sizeof(pos)/sizeof(int));
    }

    stPlayerInitData& player = gameData.player[group];
    const int playerId = 1020123; // for test
    //player.playerId = (group == kBlueGroup?1020123:kDefaultMonsterPlayerId);

    player.playerId = (group == kBlueGroup?1232123213:kDefaultMonsterPlayerId);

    player.side = group;
    player.cardSize = 1;
    // add card 4 cards
    for (int i = 0; i < player.cardSize; ++i)
    {
      stCardInitData& card = player.cards[i];

      //card.id = (group == 0?11050201:13050201);
      card.id = cards[group][i];
      card.group = group;
      card.pos = pos[i];
      //if(player.playerId == kDefaultMonsterPlayerId)
      //{
      //  card.dropMonsterId = 10100104;
      //}
      //card.primary = true;
      //card.type = kTroopInfantry;
#if USE_RANDOM_VARS
      card.attack = 1000.0f + rand()%100;
      card.defence = 100.0f + rand()%10;
      card.hp = 2000.0f + rand()%1000;
#else

#if PLAYER_OR_MONSTER
      {
        // for player
        _fassert(Config::pAllConfig->has_unit(card.id),"Invalid card id:%d",card.id);
        const DianShiTech::Config::UnitConfig& unit = Config::pAllConfig->unit(card.id);
        const DianShiTech::Config::UnitInitDataConfig& unit_init = Config::pAllConfig->unitinitdata(unit.config());
        const DianShiTech::Config::UnitGrownConfig& unit_grown = Config::pAllConfig->unitgrown(card.id);

        const int currentLevel = 5;// for test,assum e that this card level is 5
        const int attrId = unit.attr_type() * 1000 + currentLevel;
        const DianShiTech::Config::AttrTypeConfig& attr_type = Config::pAllConfig->attrtype(attrId);
        const int equip_str_fix = 0;
        const int equip_str_per = 0;
        const int equip_int_fix = 0;
        const int equip_int_per = 0;
        const int equip_dom_fix = 0;
        const int equip_dom_per = 0;
        const int equip_hp_fix = 0;
        const int equip_hp_per = 0;
        const int equip_atk_fix = 0;
        const int equip_atk_per = 0;
        const int strTransfer = unit_init.str_atk();
        const int intTranser = unit_init.int_atk();
        const int leadTranser = unit_init.dom_hp();
        const int ooc_str = (int)((float)unit_grown.str_grown() / kOneHundredPercent * attr_type.str_fix() + equip_str_fix) * (float)((kOneHundredPercent + equip_str_per)/kOneHundredPercent);
        const int ooc_int = (int)((float)unit_grown.int_grown() / kOneHundredPercent * attr_type.int_fix() + equip_int_fix) * (float)((kOneHundredPercent + equip_int_per)/kOneHundredPercent);
        const int ooc_dom = (int)((float)unit_grown.dom_grown() / kOneHundredPercent * attr_type.dom_fix() + equip_dom_fix) * (float)((kOneHundredPercent + equip_dom_per)/kOneHundredPercent);
        const int ooc_hp = (int)(ooc_dom * leadTranser + attr_type.hp_fix() + equip_hp_fix) * (float)((kOneHundredPercent + equip_hp_per)/kOneHundredPercent);
        const int ooc_atk = (int)(ooc_str * strTransfer + ooc_int * intTranser + attr_type.atk_fix() + equip_atk_fix) * (float)((kOneHundredPercent + equip_atk_per)/kOneHundredPercent);

        card.properties[k_property_str_fix] = ooc_str;
        card.properties[k_property_int_fix] = ooc_int;
        card.properties[k_property_dom_fix] = ooc_dom;
        card.properties[k_property_hp_fix] = ooc_hp;
        card.properties[k_property_atk_fix] = ooc_atk;

        card.properties[k_property_str_per] = 0;
        card.properties[k_property_int_per] = 0;
        card.properties[k_property_dom_per] = 0;
        card.properties[k_property_hp_per] = 0;
        card.properties[k_property_atk_per] = 0;

        card.properties[k_property_hit] = unit_grown.hit();
        card.properties[k_property_evade] = unit_grown.evade();
        card.properties[k_property_cri] = unit_grown.cri();
        card.properties[k_property_tough] = unit_grown.toughness();
        card.properties[k_property_block] = unit_grown.block();

        card.properties[k_property_precision] = 0;
        card.properties[k_property_damage_increase] = unit_grown.damage_increase();
        card.properties[k_property_damage_reduce] = unit_grown.damage_reduce();
        card.properties[kReflectFixedAddPercent] = unit_grown.reflect_fix();
        card.properties[kReflectPercentAddPercent] = 0;

        card.properties[k_property_hp_steal_fix] = unit_grown.hp_steal_fix();
        card.properties[kBloodDamagePercentAddPercent] = 0;
        card.properties[kBloodHpPercentAddPercent] =0;
        card.properties[kCriticalDamageIncAddPercent] = 0;
        card.properties[kCriticalDamageRdsAddPercent] = 0;

        card.type = unit.unit_type();
        card.strTransfer = strTransfer;
        card.intTranser = intTranser;
        card.leadTranser = leadTranser;
        card.maxAngry = kPlayerMaxAngry;
        card.angry = unit_init.energy_base();
        card.baseMove = unit_init.base_move();
        card.uniqueSkillId = unit.skill();
        card.baseAttack = 0;
        card.baseHp = 0;
        card.isBoss = false;
        card.isActivePassive = true;
        card.passiveSkillId = unit.talent();
      }
#else
      {
        // for monster
        const int monster_id = 10100101;
        const DianShiTech::Config::MonsterConfig& monster = Config::pAllConfig->monster(monster_id);
        const DianShiTech::Config::UnitInitDataConfig& unit_init = Config::pAllConfig->unitinitdata(monster.config());
        const int strTransfer = 0;
        const int intTranser = 0;
        const int leadTranser = 0;
        const int ooc_str = 0;
        const int ooc_int = 0;
        const int ooc_dom = 0;
        const int ooc_hp = 0;
        const int ooc_atk = 0;

        card.properties[k_property_str_fix] = ooc_str;
        card.properties[k_property_int_fix] = ooc_int;
        card.properties[k_property_dom_fix] = ooc_dom;
        card.properties[k_property_hp_fix] = ooc_hp;
        card.properties[k_property_atk_fix] = ooc_atk;

        card.properties[k_property_str_per] = 0;
        card.properties[k_property_int_per] = 0;
        card.properties[k_property_dom_per] = 0;
        card.properties[k_property_hp_per] = 0;
        card.properties[k_property_atk_per] = 0;

        card.properties[k_property_hit] = monster.hit();
        card.properties[k_property_evade] = monster.evade();
        card.properties[k_property_cri] = monster.cri();
        card.properties[k_property_tough] = monster.tough();
        card.properties[k_property_block] = monster.block();

        card.properties[k_property_precision] = 0;
        card.properties[k_property_damage_increase] = monster.damage_increase();
        card.properties[k_property_damage_reduce] = monster.damage_reduce();
        card.properties[kReflectFixedAddPercent] = monster.reflect_fix();
        card.properties[kReflectPercentAddPercent] = 0;

        card.properties[k_property_hp_steal_fix] = monster.hp_steal_fix();
        card.properties[kBloodDamagePercentAddPercent] = 0;
        card.properties[kBloodHpPercentAddPercent] =0;
        card.properties[kCriticalDamageIncAddPercent] = 0;
        card.properties[kCriticalDamageRdsAddPercent] = 0;

        card.type = monster.unit_type();
        card.strTransfer = strTransfer;
        card.intTranser = intTranser;
        card.leadTranser = leadTranser;
        card.skillUseExp = 0;
        card.maxAngry = kMonsterMaxAngry;
        card.angry = unit_init.energy_base();
        card.angryInc = unit_init.energy_get();
        card.baseMove = unit_init.base_move();
        card.uniqueSkillId = monster.skill();
        card.baseAttack = 0;
        card.baseHp = 0;
      }
#endif

#endif

		}
		//player.cards[0].id = 1200501;
		//player.cards[0].hp = 12000.0f;
		//player.cards[0].primary = true;

	}

	m_fight.setup(gameData);
	return m_fight.run();

}

void LocalFight::runMicroGame(const char* buf)
{
  CSJson::Reader reader;
  CSJson::Value  root;
  if (reader.parse(buf, root))
  {
    using namespace DianShiTech::Battle;

    // prepare init data
    stMicroGameInitData gameData;
    CSJson::Value& jsonCardInitDatas = root["CardInitData"];
    
    for (int group = 0; group < kMaxGroup; ++group)
    {
      CSJson::Value& jsonCard = jsonCardInitDatas[group];
      stCardInitData& card = gameData.cards[group];
      if (jsonCard["id"].isNull())
      {
        continue;
      }
      const int cardId = jsonCard["id"].asInt();
      const int type = jsonCard["type"].asInt();
      const int pos = jsonCard["pos"].asInt();
      card.id = cardId;
      card.group = group;
      card.pos = pos;
      if (type == 0)
      {
        // player card
        setupPlayerCard(card,jsonCard);
      }else
      {
        // monster
        setupMonsterCard(card,jsonCard);
      }
      _Flog("Card[%d].id:%d",group,card.id);
    }
  

    MicroFightMain fight(gameData);
    const stMicroGameResult& result = fight.run();
    _Flog("Micro fight win group:%d",result.winGroup);
  }else
  {
    _Flog("Battle test data error:%s",reader.getFormattedErrorMessages().c_str());
    _fassert(false,"Error");
  }
}
bool LocalFight::saveFightFile(const DianShiTech::Protocal::NormalBattleResult & fight, const char* file){
  std::ofstream outfile;
  outfile.open(file,std::ios::binary);
  bool result = fight.SerializeToOstream(&outfile);
  outfile.close();
  return result;
}
bool LocalFight::loadFightFile(DianShiTech::Protocal::NormalBattleResult& fight, const char* file){
  std::ifstream infile;
  infile.open(file, std::ios::binary);
  bool result = fight.ParseFromIstream(&infile);
  infile.close();
  return result;
}
GAME_FIGHT_MOUDLE_NAMESPACE_END //namespace

#endif