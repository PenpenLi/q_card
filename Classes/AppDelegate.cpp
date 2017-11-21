#include "cocos2d.h"
#include "AppDelegate.h"
#include "SimpleAudioEngine.h"
#include "script_support/CCScriptSupport.h"
#include "CCLuaEngine.h"
#include "Lua_extensions_CCB.h"
#include "pbc-lua.h"
#include "Net/NetManager.h"
#include "Net/NetLua.h"
#include "Common/conv.h"
#include "UIWidgets/AnimatePacker.h"
#include "lua_cjson.h"
#include "json_lib.h"

#include "Common/CommonDefine.h"
#include "GameEntry.h"

#ifdef ENABLE_LOCAL_FIGHT
#include "Fight/LocalFight.h"
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "DSNotificationManager.h"
#include "IapBridge.h"
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "payment/SdkPluginManager.h"
#endif

USING_NS_CC;
USING_NS_GAME_FRM;

using namespace CocosDenshion;

AppDelegate::AppDelegate()
{
    // fixed me
    //_CrtSetDbgFlag(_CRTDBG_ALLOC_MEM_DF|_CRTDBG_LEAK_CHECK_DF);
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	icuuc_init();
#endif
}

AppDelegate::~AppDelegate()
{
    // end simple audio engine here, or it may crashed on win32
    SimpleAudioEngine::sharedEngine()->end();
    //CCScriptEngineManager::purgeSharedManager();
	CCNotificationCenter::sharedNotificationCenter()->postNotification("APP_SET_NOTIFICE_EVENT");

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	icuuc_uninit();
	SdkPluginManager::clear();
#endif
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    IapBridge::release();
#endif
    
	AnimatePacker::Instance()->clear();
}

bool AppDelegate::applicationDidFinishLaunching()
{
#if(CC_TARGET_PLATFORM == CC_PLATFORM_IOS )
    DSNotificationManager::clearAll();
#endif
    
    // initialize director
    CCDirector *pDirector = CCDirector::sharedDirector();
    pDirector->setOpenGLView(CCEGLView::sharedOpenGLView());

	CCSize size = CCEGLView::sharedOpenGLView()->getFrameSize();
//	Global::getInstance()->setDesignResolutionSize(CCSizeMake(640,size.height*640/size.width ));
	CCEGLView::sharedOpenGLView()->setDesignResolutionSize(
		640, size.height*640/size.width, kResolutionShowAll);

    
    // CCEGLView::sharedOpenGLView()->setDesignResolutionSize(640, 960, kResolutionNoBorder);

    // turn on display FPS
    //pDirector->setDisplayStats(true);

    // set FPS. the default value is 1.0/60 if you don't call this
    //pDirector->setAnimationInterval(1.0 / 60);
 
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    IapBridge::asyncNotifyServer(URL_DS_PAYMENT);
#endif
    

    #if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		GameEntry::instance()->runGame();
    #else
        GameEntry::instance()->runResUpdate();
    #endif
    return true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground()
{
    CCDirector::sharedDirector()->stopAnimation();
    SimpleAudioEngine::sharedEngine()->pauseBackgroundMusic();
    SimpleAudioEngine::sharedEngine()->pauseAllEffects();
    CCNotificationCenter::sharedNotificationCenter()->postNotification("APP_ENTER_BACKGROUND");
	CCNotificationCenter::sharedNotificationCenter()->postNotification("APP_SET_NOTIFICE_EVENT");
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
#if(CC_TARGET_PLATFORM == CC_PLATFORM_IOS )
    DSNotificationManager::clearAll();
#endif

	CCDirector::sharedDirector()->startAnimation();
    CCNotificationCenter::sharedNotificationCenter()->postNotification("APP_ENTER_FOREGROUND");
}


