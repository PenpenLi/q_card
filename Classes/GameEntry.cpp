#include "GameEntry.h"
#include <curl/curl.h>
#include <curl/easy.h>
#include "script_support/CCScriptSupport.h"
#include "CCLuaEngine.h"
#include "Lua_extensions_CCB.h"
#include "pbc-lua.h"
#include "Net/NetManager.h"
#include "Net/NetLua.h"
#include "UpdateVersion/NetUpdateLayer.h"
#include "lua_cjson.h"

#ifdef ENABLE_LOCAL_FIGHT
#include "Fight/LocalFight.h"
#endif

#if(CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "DSNotificationManager.h"
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <jni.h>
#include "platform/android/jni/JniHelper.h"
#include "platform/android/CCLuaJavaBridge.h"
#endif

USING_NS_CC;

USING_NS_GAME_FRM

extern int tolua_extensions_ccb_open(lua_State* tolua_S);
//extern int tolua_Cocos2d_open_for_IoRecord(lua_State* tolua_S);
extern int tolua_Cocos2d_open_for_DataEncrypt(lua_State* tolua_S);
extern int tolua_Cocos2d_open_for_ExtensionsDS(lua_State* tolua_S);
extern int tolua_Cocos2d_open_for_textInput(lua_State* tolua_S);
extern int tolua_Cocos2d_open_for_GameEntry(lua_State* tolua_S);
extern int tolua_Cocos2d_open_for_ScrollNum(lua_State* tolua_S);
extern int tolua_UserLogin_open(lua_State* tolua_S);
extern int tolua_CCCommonFunctionHelp_open(lua_State* tolua_S);
extern int tolua_Cocos2d_open_for_HttpRequest(lua_State* tolua_S);
extern int tolua_CFunctionToLua_open (lua_State* tolua_S);

#if(CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
extern int  tolua_DSNotificationManager_open(lua_State* tolua_S);
#endif

extern int tolua_ChannelManager_open(lua_State* tolua_S);

#if(CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
extern int  tolua_SdkPluginManager_open(lua_State* tolua_S);
#endif

//extern int tolua_Cocos2d_open_for_ScrollTable(lua_State* tolua_S);

GameEntry *pUcInstance = NULL;
GameEntry *GameEntry::instance() {
  if (!pUcInstance) {
    pUcInstance = new GameEntry();
  }

  return pUcInstance;
}

void GameEntry::runGame() {
  
	CCLOG("---GameEntry::runGame---");

  m_isKeypadForUser = false;

  // register lua engine
  CCLuaEngine* pEngine = CCLuaEngine::defaultEngine();
  
  CCScriptEngineManager::sharedManager()->setScriptEngine(pEngine);

  CCLuaStack *pStack = pEngine->getLuaStack();
  
  lua_State *tolua_s = pStack->getLuaState();
  
  tolua_extensions_ccb_open(tolua_s);
  
  luaopen_protobuf_c(tolua_s);
  
  luaopen_cjson(tolua_s);

  //tolua_Cocos2d_open_for_IoRecord(tolua_s); 

  //tolua_Cocos2d_open_for_DataEncrypt(tolua_s);

  tolua_Cocos2d_open_for_ExtensionsDS(tolua_s);

  tolua_Cocos2d_open_for_textInput(tolua_s);

  tolua_Cocos2d_open_for_GameEntry(tolua_s);

  tolua_Cocos2d_open_for_ScrollNum(tolua_s);

  tolua_CCCommonFunctionHelp_open(tolua_s);

  tolua_UserLogin_open(tolua_s);

  tolua_Cocos2d_open_for_HttpRequest(tolua_s);

  tolua_ChannelManager_open(tolua_s);

  tolua_CFunctionToLua_open(tolua_s);

#if(CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
  tolua_DSNotificationManager_open(tolua_s);
#endif

#if(CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
  tolua_SdkPluginManager_open(tolua_s);
  LuaJavaBridge::luaopen_luaj(tolua_s);
#endif

#ifdef ENABLE_LUA_BINDING
  NetLua::registWithLua(tolua_s);
#endif

#ifdef ENABLE_LOCAL_FIGHT
  DianShiTech::Battle::LocalFight::init();
#endif

  std::string path = CCFileUtils::sharedFileUtils()->fullPathForFilename("script/main.lua");
  
  pEngine->executeScriptFile(path.c_str());
}

void GameEntry::runResUpdate() {
  
  CCLOG("---GameEntry::runResUpdate---");
  
  CCDirector *pDirector = CCDirector::sharedDirector();
  
  CCScene *scene = CCScene::create();
  
  NetUpdateLayer *updateLayer = NetUpdateLayer::createNetUpdateLayer();
  
  scene->addChild(updateLayer);
  
  if (pDirector->getRunningScene())
  {
    pDirector->replaceScene(scene);
  }
  else 
  {
    pDirector->runWithScene(scene);
  }
}

const char *GameEntry::getUserName() {

  return m_userName.c_str();
}

const char *GameEntry::getPassword() {
  return m_password.c_str();
}

const char *GameEntry::getChannel() {
  return m_channel.c_str();
}

const char *GameEntry::getSign() {
  return m_sign.c_str();
}

bool GameEntry::isUcPlatform() {
  bool flag = false;

#if (defined ANDROID_UC)
  flag = true;
#endif

  return flag;
}

void GameEntry::gotoLoginWin() {
}

void GameEntry::exitGame() {
  CCLOG("---GameEntry::exitGame---");
  CCDirector::sharedDirector()->end();
}

void GameEntry::setKeypadForUser(bool enable) {
  CCLOG("setKeypadForUser:  %d", enable);
  m_isKeypadForUser = enable;
}

bool GameEntry::isKeypadForUser() {
  CCLOG("isKeypadForUser:  %d", m_isKeypadForUser);
  return m_isKeypadForUser;
}


dateInfo GameEntry::GetDayTime(long timeOffset)
{
    struct tm *tm ;
    time_t timep ;
    dateInfo tDate;
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 ) 
    time(&timep );
    timep += (time_t)timeOffset;
#else  
    struct cc_timeval now;  
    CCTime::gettimeofdayCocos2d (&now, NULL);  
    timep = now. tv_sec + timeOffset;
#endif

    tm = localtime(& timep);
    tDate.year = tm->tm_year + 1900;
    tDate.mon = tm->tm_mon + 1;
    tDate.day = tm->tm_mday ;
    tDate.hour = tm->tm_hour;
    tDate.min = tm->tm_min;
    tDate.sec = tm->tm_sec;
    
    return tDate;
}


#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)

extern "C" {

void Java_com_dst_sanguocard_SanguoCardMain_nativePlaySound(JNIEnv* env,jobject thiz, jint playId)
{
    jint isPlay = playId;
    bool isSoundOn = false;

    if (CCUserDefault::sharedUserDefault()->getStringForKey("sound_on") == "true"
        || CCUserDefault::sharedUserDefault()->getStringForKey("sound_on") == "") {
      isSoundOn = true;
    }

    if (isPlay == 1 && isSoundOn) {
      CocosDenshion::SimpleAudioEngine::sharedEngine()->resumeBackgroundMusic();
    } 
	else if (isPlay == 0) {
      CocosDenshion::SimpleAudioEngine::sharedEngine()->pauseBackgroundMusic();
    }
}

jboolean Java_com_dst_sanguocard_SanguoCardMain_isKeypadForUser(JNIEnv* env, jobject thiz)
{
    return GameEntry::instance()->isKeypadForUser();
}

#define KEYCODE_BACK 0x04
#define KEYCODE_MENU 0x52
jboolean Java_com_dst_sanguocard_SanguoCardMain_nativeKeyDown(JNIEnv * env,jobject thiz, jint keyCode)
{
    CCDirector* pDirector = CCDirector::sharedDirector();
    switch (keyCode) 
	{
      case KEYCODE_BACK:
        if (pDirector->getKeypadDispatcher()->dispatchKeypadMSG(
            kTypeBackClicked))
          return JNI_TRUE;
        break;
      case KEYCODE_MENU:
        if (pDirector->getKeypadDispatcher()->dispatchKeypadMSG(
            kTypeMenuClicked))
          return JNI_TRUE;
        break;
      default:
        return JNI_FALSE;
    }
    return JNI_FALSE;
}

}//extern "C"
;
#endif



