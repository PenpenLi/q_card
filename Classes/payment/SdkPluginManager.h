#ifndef SDK_PLUGIN_MANAGER_H
#define SDK_PLUGIN_MANAGER_H
#include <jni.h>
#include "platform/android/jni/JniHelper.h"
#include <string>
#include "Common/CommonDefine.h"
#ifdef __cplusplus
extern "C" {
#endif
std::string jstringTostring(JNIEnv* env, jstring jstr);
void Java_com_somethingbigtech_plugin_SdkManager_onLoginSuccess(JNIEnv *env, jobject thiz,jstring juid,jstring jsid);
void Java_com_somethingbigtech_plugin_SdkManager_onLoginComplete(JNIEnv *env, jobject thiz,jstring jsid);
void Java_com_m543_pay_FastSdk_onLoginSuccess(
		JNIEnv *env, jobject thiz, jstring juid, jstring jsid,
	    jstring jchannel);


  NS_GAME_FRM_BEGIN
    class SdkPluginManager {
      public:
        static SdkPluginManager* getInstance();
        void login();
        void release();
        void logout();
        static void clear();
        static void registerScriptHandler(int nHandler);
        static void getUser(const char* url);
        static size_t verifyServiceResult(void *ptr, size_t size, size_t nmemb,
            void *userdata);
        static void doCharge(const std::string& url);
        static void doCharge(int channel,const std::string& url);
        static void openUrl(const std::string& url);
        static void doCharge(const std::string& notifyUrl,
            const std::string& goodsId, const std::string& playerId,
            const std::string& paymentCode, const std::string& serverId);
        static void doCharge(const std::string& notifyUrl,
            const std::string& goodsId, const std::string& playerId,
            const std::string& paymentCode, const std::string& serverId,const std::string& params);
        static void doCharge(const std::string& notifyUrl,
            const std::string& goodsId, const std::string& playerId,
            const std::string& paymentCode, const std::string& serverId, const std::string& channel,const std::string& params);
        static int getLuaHandler();
        static void switchAccount();
		void setSubChannel(const std::string &channel);

      private:
        static SdkPluginManager* instance;
        SdkPluginManager();
        virtual ~SdkPluginManager();
        static int mLuaHandlerId;
		std::string channel;
        enum SdkChannel{
            CHANNEL_GOOGLEPLAY = 1,
            CHANNEL_MYCARD=4,
        };
    };
  NS_GAME_FRM_END
#ifdef __cplusplus
}
#endif
#endif
