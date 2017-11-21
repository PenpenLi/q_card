/********************************************************************
	created:	2013/11/27
	created:	27:11:2013   13:12
	file base:	LocalFight
	file ext:	h
	author:		Kevin
	
*********************************************************************/

#ifndef _H_LOCALFIGHT_H_  
#define _H_LOCALFIGHT_H_  

#ifdef ENABLE_LOCAL_FIGHT

#include "FightDef.h"
#include "FightMain.h"
#include "AllConfigs.h"

GAME_FIGHT_MOUDLE_NAMESPACE_BEGIN

class LocalFight
{
private:
	static DianShiTech::Config::AllConfigs configs;

	FightMain m_fight;
  std::string m_empty;
public:

	LocalFight();

	virtual ~LocalFight();

  const std::string& runGame(const char* buf);

	const std::string& runGame();

  std::string runGameFromFile(const char* buf);

  void runMicroGame(const char* buf);

  bool saveFightFile(const DianShiTech::Protocal::NormalBattleResult & fight, const char* file);
  bool loadFightFile(DianShiTech::Protocal::NormalBattleResult& fight, const char* file);

	static void init();

  std::string m_file_load;

};



GAME_FIGHT_MOUDLE_NAMESPACE_END //namespace

#endif




#endif //_H_LOCALFIGHT_H_  