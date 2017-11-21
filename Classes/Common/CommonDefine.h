#ifndef _H_COMMON_DEFINE_
#define _H_COMMON_DEFINE_

#include <string>
#include <cocos2d.h>

#define NS_GAME_FRM_BEGIN namespace DianshiTech {
#define NS_GAME_FRM_END };
#define USING_NS_GAME_FRM using namespace DianshiTech;

//#define ENABLE_LOCAL_FIGHT 1 // for other one,plz set to 0
//#define ENABLE_BATTLE_TESTER 1

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	static std::string APP_VERSION = "1.3";
#else
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	static std::string APP_VERSION = "1.3";
#else
	static std::string APP_VERSION = "0";
#endif
#endif

// Platform define (Switch ON/OFF in MAKE file)
//#define ANDROID_GOOGLEPLAY_SC
//#define ANDROID_GOOGLEPLAY_CT
//#define ANDROID_PAYPAL
//#define ANDROID_ALIPAY
//#define ANDROID_UC
//#define ANDROID_BAIDU
//#define ANDROID_360
//#define ANDROID_WANDOUJIA
//#define ANDROID_GFAN
//#define ANDROID_MI
//#define ANDROID_ANZHI
//#define ANDROID_TENCENT
//#define ANDROID_AMAZON
//#define ANDROID_GOOGLEPLAY_JP
//#define ANDROID_OTHERS
//#define APPSTORE
#define ANDROID_TEST
//#define ANDROID_BJST

#if(CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#define LOGIN_CHANNEL_DSUC
#define DOWNLOAD_CHANNEL_OW
#endif

// Payment channel
#define ANDROID_PAY_GOOGLEPLAY     "googleWorld"
#define ANDROID_PAY_ALIPAY         "alipay"
#define ANDROID_PAY_UC             "uc"
#define ANDROID_PAY_BAIDU          "baidu"
#define ANDROID_PAY_360            "360"
#define ANDROID_PAY_WANDOUJIA      "wandoujia"
#define ANDROID_PAY_GFAN           "gfan"
#define ANDROID_PAY_MI             "mi"
#define ANDROID_PAY_ANZHI          "anzhi"
#define ANDROID_PAY_COMBINATIONS   "googleWorld,mycard,gashPlusTW,gashPlusHK,gashPlusMY,paypal"
#define ANDROID_PAY_TENCENT	       "tencent"
#define ANDROID_PAY_OPPO		   "oppo"
#define ANDROID_PAY_AMAZON         "amazon"
#define ANDROID_PAY_GOOGLEPLAYJPN  "googlePlayjpn"
#define APPLE_PAY_APPSTORE         "appstore"
#define PAY_NOTHING                "mycard,gashPlusTW,gashPlusHK,gashPlusMY,paypal"

#if defined(ANDROID_UC)
	#define PAY_CHANNEL_ID ANDROID_PAY_UC
	#pragma message ("ANDROID_PAY_UC")
    
#elif defined(ANDROID_GOOGLEPLAY_SC)
	#define PAY_CHANNEL_ID ANDROID_PAY_GOOGLEPLAY
	#pragma message ("ANDROID_PAY_GOOGLEPLAY")
    
#elif defined(ANDROID_GOOGLEPLAY_CT)
	#define PAY_CHANNEL_ID ANDROID_PAY_COMBINATIONS
	#pragma message ("ANDROID_PAY_COMBINATIONS")
    
#elif defined(ANDROID_ALIPAY)
	#define PAY_CHANNEL_ID ANDROID_PAY_ALIPAY
	#pragma message ("ANDROID_PAY_ALIPAY")

#elif defined(ANDROID_AMAZON)
	#define PAY_CHANNEL_ID ANDROID_PAY_AMAZON
	#pragma message ("ANDROID_PAY_AMAZON")

#elif defined(ANDROID_BAIDU)
    #define PAY_CHANNEL_ID ANDROID_PAY_BAIDU
    #pragma message ("ANDROID_PAY_BAIDU")
    
#elif defined(ANDROID_360)
    #define PAY_CHANNEL_ID ANDROID_PAY_360
    #pragma message ("ANDROID_PAY_360")
    
#elif defined(ANDROID_WANDOUJIA)
    #define PAY_CHANNEL_ID ANDROID_PAY_WANDOUJIA
    #pragma message ("ANDROID_PAY_WANDOUJIA")
    
#elif defined(ANDROID_GFAN)
    #define PAY_CHANNEL_ID ANDROID_PAY_GFAN
    #pragma message ("ANDROID_PAY_GFAN")
    
#elif defined(ANDROID_MI)
   #define PAY_CHANNEL_ID ANDROID_PAY_MI
   #pragma message ("ANDROID_PAY_MI")
   
#elif defined(ANDROID_ANZHI)
   #define PAY_CHANNEL_ID ANDROID_PAY_ANZHI
   #pragma message ("ANDROID_PAY_ANZHI")
   
#elif defined(APPSTORE)
    #define PAY_CHANNEL_ID APPLE_PAY_APPSTORE
    #pragma message ("APPLE_PAY_APPSTORE")
    
#elif defined(ANDROID_TENCENT)
    #define PAY_CHANNEL_ID ANDROID_PAY_TENCENT
    #pragma message ("ANDROID_PAY_TENCENT")
    
#elif defined(ANDROID_OPPO)
    #define PAY_CHANNEL_ID ANDROID_PAY_OPPO
    #pragma message ("ANDROID_PAY_OPPO")

#elif defined(ANDROID_GOOGLEPLAY_JP)
	#define PAY_CHANNEL_ID ANDROID_PAY_GOOGLEPLAYJPN
	#pragma message ("ANDROID_PAY_GOOGLEPLAYJPN")

#else
	#define PAY_CHANNEL_ID PAY_NOTHING
	#pragma message ("PAY_NOTHING")
#endif

//------login channel------------------------------
//#define LOGIN_CHANNEL_DSUC
#if defined(LOGIN_CHANNEL_DSUC)
	static std::string LOGIN_CHANNEL = "dsuc";
	#pragma message ("LOGIN_CHANNEL = dsuc")
    
#elif defined(LOGIN_CHANNEL_BAIDU)
	static std::string LOGIN_CHANNEL = "baidu";
	#pragma message ("LOGIN_CHANNEL = baidu")
    
#elif defined(LOGIN_CHANNEL_360)
	static std::string LOGIN_CHANNEL = "360";
	#pragma message ("LOGIN_CHANNEL = 360")
    
#elif defined(LOGIN_CHANNEL_WANDOUJIA)
	static std::string LOGIN_CHANNEL = "wandoujia";
	#pragma message ("LOGIN_CHANNEL = wandoujia")
    
#elif defined(LOGIN_CHANNEL_UC)
	static std::string LOGIN_CHANNEL = "uc";
	#pragma message ("LOGIN_CHANNEL = uc")
    
#elif defined(LOGIN_CHANNEL_GFAN)
	static std::string LOGIN_CHANNEL = "gfan";
	#pragma message ("LOGIN_CHANNEL = gfan")
    
#elif defined(LOGIN_CHANNEL_MI)
	static std::string LOGIN_CHANNEL = "mi";
	#pragma message ("LOGIN_CHANNEL = mi")
    
#elif defined(LOGIN_CHANNEL_ANZHI)
	static std::string LOGIN_CHANNEL = "anzhi";
	#pragma message ("LOGIN_CHANNEL = anzhi")

#elif defined(LOGIN_CHANNEL_TENCENT)
	static std::string LOGIN_CHANNEL = "tencent";
	#pragma message ("LOGIN_CHANNEL = tencent")

#elif defined(LOGIN_CHANNEL_OPPO)
	static std::string LOGIN_CHANNEL = "oppo";
	#pragma message ("LOGIN_CHANNEL = oppo")

#else
	static std::string LOGIN_CHANNEL = "";
	#pragma message ("LOGIN_CHANNEL = [EMPTY]")
#endif


//------download channel---------------------------
//#define DOWNLOAD_CHANNEL_OW
#if defined(DOWNLOAD_CHANNEL_OW)
	static std::string DOWNLOAD_CHANNEL = "ow";// Official Website
	#pragma message ("DOWNLOAD_CHANNEL = ow")
    
#elif defined( DOWNLOAD_CHANNEL_GOOGLEPLAY)
	static std::string DOWNLOAD_CHANNEL = "googlePlay";
	#pragma message ("DOWNLOAD_CHANNEL = googlePlay")
    
#elif defined(DOWNLOAD_CHANNEL_BAIDU)
	static std::string DOWNLOAD_CHANNEL = "baidu";
	#pragma message ("DOWNLOAD_CHANNEL = baidu")

#elif defined(DOWNLOAD_CHANNEL_360)
	static std::string DOWNLOAD_CHANNEL = "360";
	#pragma message ("DOWNLOAD_CHANNEL = 360")

#elif defined(DOWNLOAD_CHANNEL_WANDOUJIA)
	static std::string DOWNLOAD_CHANNEL = "wandoujia";
	#pragma message ("DOWNLOAD_CHANNEL = wandoujia")

#elif defined(DOWNLOAD_CHANNEL_UC)
	static std::string DOWNLOAD_CHANNEL = "uc";
	#pragma message ("DOWNLOAD_CHANNEL = uc")

#elif defined(DOWNLOAD_CHANNEL_GFAN)
	static std::string DOWNLOAD_CHANNEL = "gfan";
	#pragma message ("DOWNLOAD_CHANNEL = gfan")

#elif defined(DOWNLOAD_CHANNEL_MI)
	static std::string DOWNLOAD_CHANNEL = "mi";
	#pragma message ("DOWNLOAD_CHANNEL = mi")

#elif defined(DOWNLOAD_CHANNEL_ANZHI)
	static std::string DOWNLOAD_CHANNEL = "anzhi";
	#pragma message ("DOWNLOAD_CHANNEL = anzhi")

#elif defined(DOWNLOAD_CHANNEL_OTHERS)
	static std::string DOWNLOAD_CHANNEL = "others";
	#pragma message ("DOWNLOAD_CHANNEL = others")

#elif defined(DOWNLOAD_CHANNEL_TENCENT)
	static std::string DOWNLOAD_CHANNEL = "tencent";
	#pragma message ("DOWNLOAD_CHANNEL = tencent")

#elif defined(DOWNLOAD_CHANNEL_OPPO)
	static std::string DOWNLOAD_CHANNEL = "oppo";
	#pragma message ("DOWNLOAD_CHANNEL = oppo")

#elif defined(DOWNLOAD_CHANNEL_AMAZON)
	static std::string DOWNLOAD_CHANNEL = "amazon";
	#pragma message ("DOWNLOAD_CHANNEL = amazon")

#elif defined(DOWNLOAD_CHANNEL_APPSTORE)
	static std::string DOWNLOAD_CHANNEL = "appstore";
	#pragma message ("DOWNLOAD_CHANNEL = appstore")

#else
	static std::string DOWNLOAD_CHANNEL = "";
	#pragma message ("DOWNLOAD_CHANNEL = [EMPTY]")
#endif

/* URL define */
#if ((defined ANDROID_TEST)||((CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)&&(defined COCOS2D_DEBUG)))
	static std::string URL_DS_USER      = "http://10.103.252.68:9999";
	static std::string URL_USER_MAPPING = "http://10.103.252.68:8081";
	static std::string URL_DS_PAYMENT   = "http://10.103.252.68:9998";
	static std::string URL_PAY_NOTIFY   = "http://10.103.252.68:8888";
	#pragma message ("URL = [TEST URL]")

#elif (defined ANDROID_BJST)
	static std::string URL_DS_USER      = "http://staging.u.m543.com";
	static std::string URL_USER_MAPPING = "http://staging.login.m543.com";
	static std::string URL_DS_PAYMENT   = "http://staging.pay.m543.com";
	static std::string URL_PAY_NOTIFY   = "http://staging.pay.qcard3.com";
	#pragma message ("URL = [bj.staging]")

#elif (defined ANDROID_GOOGLEPLAY_SC) || (defined ANDROID_GOOGLEPLAY_CT) || (defined ANDROID_PAYPAL) || (defined APPSTORE) || (defined ANDROID_AMAZON)
	static std::string URL_DS_USER      = "http://u.m543.com";
	static std::string URL_USER_MAPPING = "http://login.m543.com";
	static std::string URL_DS_PAYMENT   = "http://pay.m543.com";
	static std::string URL_PAY_NOTIFY   = "http://pay.qcard3.com";
	#pragma message ("URL = [*.m543.com]")

#elif (defined ANDROID_GOOGLEPLAY_JP)
	static std::string URL_DS_USER      = "http://u.m543.com";
	static std::string URL_USER_MAPPING = "http://login.m543.com";
	static std::string URL_DS_PAYMENT   = "http://pay.m543.com";
	static std::string URL_PAY_NOTIFY   = "http://pay.teppensangoku.com";
	#pragma message ("URL = [*.m543.com]")

#else
	static std::string URL_DS_USER      = "http://u.m543.com.cn";
	static std::string URL_USER_MAPPING = "http://login.m543.com.cn";
	static std::string URL_DS_PAYMENT   = "http://pay.m543.com.cn";
	static std::string URL_PAY_NOTIFY   = "http://pay.qcard3.com";
	#pragma message ("URL = [*.m543.com.cn]")
#endif



// Install update URL
#if defined(ANDROID_GOOGLEPLAY_SC)
	static const char * INST_UPDATE_URL_KEY = "google_player_url";
	#pragma message ("INST_UPDATE_URL_KEY = [google_player_url]")

#elif defined(ANDROID_UC)
	static const char * INST_UPDATE_URL_KEY = "uc_url";
	#pragma message ("INST_UPDATE_URL_KEY = [uc_url]")

#elif defined(ANDROID_BAIDU)
	static const char * INST_UPDATE_URL_KEY = "baidu_url";
	#pragma message ("INST_UPDATE_URL_KEY = [baidu_url]")

#elif defined(ANDROID_360)
	static const char * INST_UPDATE_URL_KEY = "v360_url";
	#pragma message ("INST_UPDATE_URL_KEY = [v360_url]")

#elif defined(ANDROID_WANDOUJIA)
	static const char * INST_UPDATE_URL_KEY = "wangdoujia_url";
	#pragma message ("INST_UPDATE_URL_KEY = [wangdoujia_url]")

#elif defined(ANDROID_GFAN)
	static const char * INST_UPDATE_URL_KEY = "gfan_url";
	#pragma message ("INST_UPDATE_URL_KEY = [gfan_url]")

#elif defined(ANDROID_MI)
	static const char * INST_UPDATE_URL_KEY = "mi_url";
	#pragma message ("INST_UPDATE_URL_KEY = [mi_url]")

#elif defined(ANDROID_ANZHI)
	static const char * INST_UPDATE_URL_KEY = "anzhi_url";
	#pragma message ("INST_UPDATE_URL_KEY = [anzhi_url]")

#elif defined(ANDROID_TENCENT)
	static const char * INST_UPDATE_URL_KEY = "tencent_url";
	#pragma message ("INST_UPDATE_URL_KEY = [tencent_url]")

#elif defined(ANDROID_OPPO)
	static const char * INST_UPDATE_URL_KEY = "oppo_url";
	#pragma message ("INST_UPDATE_URL_KEY = [oppo_url]")

#elif defined(ANDROID_AMAZON)
	static const char * INST_UPDATE_URL_KEY = "amazon_url";
	#pragma message ("INST_UPDATE_URL_KEY = [amazon_url]")
	
#elif defined(ANDROID_GOOGLEPLAY_JP)
	static const char * INST_UPDATE_URL_KEY = "googleplayer_jp_url";
	#pragma message ("INST_UPDATE_URL_KEY = [googleplayer_jp_url]")
	
#elif defined(APPSTORE)
	static const char * INST_UPDATE_URL_KEY = "app_store_url";
	#pragma message ("INST_UPDATE_URL_KEY = [app_store_url]")
    
#else
	static const char * INST_UPDATE_URL_KEY = "official_website_url";
	#pragma message ("INST_UPDATE_URL_KEY = [official_website_url]")
#endif

#ifdef ANDROID_GOOGLEPLAY_JP
static std::string GAME_NAME="teppensangoku";
#else
static std::string GAME_NAME="qcardsanguo";
#endif 

static std::string ORDER_SIGN_KEY="chqcsg@paypower";


#endif //_H_COMMON_DEFINE_
