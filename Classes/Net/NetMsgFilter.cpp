/********************************************************************
	created:	2014/01/17
	created:	17:1:2014   17:09
	file base:	NetMsgFilter
	file ext:	cpp
	author:		Kevin
	
*********************************************************************/


#include "NetMsgFilter.h"
#include "NetManager.h"

#ifdef ENABLE_LOCAL_FIGHT
#include "Fight/LocalFight.h"
#include "cocos2d.h"
#endif

#define TEST_MICRO_FIGHT 0

NS_GAME_FRM_BEGIN


namespace NetMsgFilter
{
  extern bool filter(int msgId,NetManagerImpl* pInstance)
  {
    if(msgId == 1543)
    {
#ifdef ENABLE_LOCAL_FIGHT

      DianShiTech::Battle::LocalFight localFight;

#if ENABLE_BATTLE_TESTER


#if TEST_MICRO_FIGHT
      const char* filename = "D:/temp/battle_micro_test_data.json";
      unsigned long size = 0;
      unsigned char* pBuff = cocos2d::CCFileUtils::sharedFileUtils()->getFileData(filename,"rb",&size);
      std::string result;
      localFight.runMicroGame((char*)pBuff); 

#else
      const char* filename = "C:/sanguo_card_trunk/battle_test_data/battle_test_data.json";
      unsigned long size = 0;
      unsigned char* pBuff = cocos2d::CCFileUtils::sharedFileUtils()->getFileData(filename,"rb",&size);
      std::string result;
      result = localFight.runGame((char*)pBuff);
#endif

#else
      const std::string& result = localFight.runGame();
      
#endif
      
      LOG("Battle result size:%d",result.size());

      if (!result.empty())
      {
        PtrNetNotify notify(new NetNotify(kNetNotifyOnResponse,8000,result));

        pInstance->appendNotify(notify);
      }

#endif
      return true;
    }
    return false;
  }

  

}


NS_GAME_FRM_END //namespace
