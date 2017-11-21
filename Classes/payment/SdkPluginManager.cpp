#include "payment/SdkPluginManager.h"
#include "CCLuaEngine.h"
#include "json_lib.h"
#include <curl/curl.h>
#include <curl/easy.h>
#include "cocos2d.h"
#include "UpdateVersion/md5.h"

using namespace cocos2d;


#ifdef ANDROID_GOOGLEPLAY_JP
#define PLUGINCLASSNAME "com/somethingbigtech/plugin/SdkManager"
#else 
#define PLUGINCLASSNAME "com/m543/pay/FastSdk"
#endif

std::string jstringTostring(JNIEnv* env, jstring jstr) {
  if (jstr == NULL) {
    return "";
  }
  const char* chars = env->GetStringUTFChars(jstr, NULL);
  std::string ret(chars);
  env->ReleaseStringUTFChars(jstr, chars);
  return ret;
}
void Java_com_somethingbigtech_plugin_SdkManager_onLoginSuccess(JNIEnv *env, jobject thiz,jstring juid,jstring jsid){
  USING_NS_GAME_FRM;
  std::string path="";
  std::string host = URL_USER_MAPPING;
  std::string uid=jstringTostring(env,juid);
  std::string sid=jstringTostring(env,jsid);
#ifdef ANDROID_BAIDU
  path = host+"/auth/getUser?uid="+uid+"&sessionId="+sid+"&game=qcardsanguo&channel=baidu";
#endif
#ifdef ANDROID_WANDOUJIA
  path = host+"/wdj/getUser/"+uid+"/qcardsanguo/"+sid;
#endif
#ifdef ANDROID_360
  path = host + "/qihoo/getUser/" + sid + "/qcardsanguo";
#endif
#ifdef ANDROID_ANZHI
  path = host + "/anzhi/getUser?game=qcardsanguo&uid="+uid+"&sid="+sid;
#endif
#ifdef ANDROID_MI
  path = host + "/mi/getUser?game=qcardsanguo&uid=" + uid+ "&sid=" + sid;
#endif
  SdkPluginManager::getUser(path.c_str());
}
void Java_com_somethingbigtech_plugin_SdkManager_onLoginComplete(JNIEnv *env, jobject thiz,jstring jsid){
  USING_NS_GAME_FRM;
  std::string path="";
  std::string host = URL_USER_MAPPING;
  std::string sid=jstringTostring(env,jsid);
#ifdef ANDROID_GFAN
  path = host + "/gfan/getUser/qcardsanguo/?token="+sid;
#endif
#ifdef ANDROID_UC
  path = host + "/uc/getUser/"+sid+"/qcardsanguo";
#endif
  SdkPluginManager::getUser(path.c_str());
}


void Java_com_m543_pay_FastSdk_onLoginSuccess(
		JNIEnv *env, jobject thiz, jstring juid, jstring jsid,
	    jstring jchannel){

	USING_NS_GAME_FRM;
	std::string path = "";
	std::string host = URL_USER_MAPPING;
	std::string uid = jstringTostring(env, juid);
	std::string sid = jstringTostring(env, jsid);
#ifdef ANDROID_BAIDU
	path = host+"/auth/getUser?uid="+uid+"&sessionId="+sid+"&game=qcardsanguo&channel=baidu";
#endif
#ifdef ANDROID_WANDOUJIA
	path = host+"/wdj/getUser/"+uid+"/qcardsanguo/"+sid;
#endif
#ifdef ANDROID_360
	path = host + "/qihoo/getUser/" + sid + "/qcardsanguo";
#endif
#ifdef ANDROID_ANZHI
	path = host + "/anzhi/getUser?game=qcardsanguo&uid="+uid+"&sid="+sid;
#endif
#ifdef ANDROID_MI
	path = host + "/mi/getUser?game=qcardsanguo&uid=" + uid+ "&sid=" + sid;
#endif
#ifdef ANDROID_OPPO
	path = host + "/auth/getUser?uid="+uid+"&sessionId="+sid+"&game=qcardsanguo&channel=oppo";
#endif
#ifdef ANDROID_UC
	path = host + "/uc/getUser/"+sid+"/qcardsanguo";
#endif
	SdkPluginManager::getUser(path.c_str());


}


NS_GAME_FRM_BEGIN

  SdkPluginManager * SdkPluginManager::instance = NULL;

  int SdkPluginManager::mLuaHandlerId = -1;

  SdkPluginManager::SdkPluginManager():channel("default") {

  }
  SdkPluginManager::~SdkPluginManager() {

  }
  void SdkPluginManager::registerScriptHandler(int nHandler) {
    SdkPluginManager::mLuaHandlerId = nHandler;
  }

  SdkPluginManager* SdkPluginManager::getInstance() {
    if (instance == NULL) {
      instance = new SdkPluginManager();
    }
    return instance;
  }
  void SdkPluginManager::clear() {
    if (instance) {
      delete instance;
      instance = NULL;
    }
  }
  void SdkPluginManager::login() {
    JniMethodInfo t;
    if (JniHelper::getStaticMethodInfo(t, PLUGINCLASSNAME, "login", "()V")) {
      t.env->CallStaticVoidMethod(t.classID, t.methodID);
    }
  }
  void SdkPluginManager::release() {
    JniMethodInfo t;
    if (JniHelper::getStaticMethodInfo(t, PLUGINCLASSNAME, "release", "()V")) {
      t.env->CallStaticVoidMethod(t.classID, t.methodID);
    }
  }
  void SdkPluginManager::logout() {
    JniMethodInfo t;
    if (JniHelper::getStaticMethodInfo(t, PLUGINCLASSNAME, "logout", "()V")) {
      t.env->CallStaticVoidMethod(t.classID, t.methodID);
    }
  }
  void SdkPluginManager::doCharge(const std::string& notifyUrl,
      const std::string& goodsId, const std::string& playerId,
      const std::string& paymentCode, const std::string& serverId) {
    std::string game = GAME_NAME; //"qcardsanguo";
    std::string signKey = "chqcsg@paypower";
    std::string mode = "sdk";
    std::string paymentUrl = URL_DS_PAYMENT + "/payment/createOrder";
    std::string channel = PAY_CHANNEL_ID;
    std::string preSign = game + playerId + channel + paymentCode + signKey;
    MD5 md5;
    md5.reset();
    md5.update(preSign);
    std::string sign = md5.toString();
    std::string url = paymentUrl + "?from=mobile&game=" + game + "&playerId="
        + playerId + "&channel=" + channel + "&paymentCode=" + paymentCode
        + "&sign=" + sign + "&mode=" + mode + "&notifyUrl=" + notifyUrl
        + "&serverId=" + serverId;
    CCLog("url=%s", url.c_str());
    doCharge(url);
  }

  void SdkPluginManager::doCharge(int channel, const std::string& url) {
    JniMethodInfo t;
    if (JniHelper::getStaticMethodInfo(t, PLUGINCLASSNAME, "doCharge",
        "(ILjava/lang/String;)V")) {
      jstring jurl = t.env->NewStringUTF(url.c_str());
      jint jchannel=(jint)channel;
      t.env->CallStaticVoidMethod(t.classID, t.methodID,channel, jurl);
      t.env->DeleteLocalRef(jurl);
    }
  }
  void SdkPluginManager::openUrl(const std::string& url) {
    JniMethodInfo t;
    if (JniHelper::getStaticMethodInfo(t, PLUGINCLASSNAME, "openUrl",
        "(Ljava/lang/String;)V")) {
      jstring jurl = t.env->NewStringUTF(url.c_str());
      t.env->CallStaticVoidMethod(t.classID, t.methodID, jurl);
      t.env->DeleteLocalRef(jurl);
    }
  }
  void SdkPluginManager::doCharge(const std::string& url) {
    JniMethodInfo t;
    if (JniHelper::getStaticMethodInfo(t, PLUGINCLASSNAME, "doCharge",
        "(Ljava/lang/String;)V")) {
      jstring jurl = t.env->NewStringUTF(url.c_str());
      t.env->CallStaticVoidMethod(t.classID, t.methodID, jurl);
      t.env->DeleteLocalRef(jurl);
    }
  }

  void SdkPluginManager::getUser(const char *url) {
    CCLog("getUser url=%s", url);
    CURL * _curl = curl_easy_init();
    curl_easy_setopt(_curl, CURLOPT_URL, url);
    curl_easy_setopt(_curl, CURLOPT_WRITEFUNCTION,SdkPluginManager::verifyServiceResult);
    curl_easy_setopt(_curl, CURLOPT_CONNECTTIMEOUT, 10);
    CURLcode res = curl_easy_perform(_curl);
    int http_code = 0;
    curl_easy_getinfo(_curl, CURLINFO_RESPONSE_CODE, &http_code);
    curl_easy_cleanup(_curl);
    if (res != 0 || http_code != 200) {
      CCLog(" req url fail !!!!!:res=%d, http_code=%d", res, http_code);
      CCLuaStack* stack = CCLuaEngine::defaultEngine()->getLuaStack();
      std::string status = "error";
      std::string message = "Network Error";
      stack->pushString(status.c_str());
      stack->pushString(message.c_str());
      stack->pushString(message.c_str());
      stack->pushString(message.c_str());
      stack->pushString(message.c_str());
      stack->executeFunctionByHandler(SdkPluginManager::mLuaHandlerId, 5);
      stack->clean();
      return;
    }
  }
  size_t SdkPluginManager::verifyServiceResult(void *ptr, size_t size,
      size_t nmemb, void *userdata) {
    CCLog("verifyServiceResult.........");
    CSJson::Reader reader;
    std::string str = (char *) ptr;
    CSJson::Value root;
    reader.parse(str, root);
    std::string status = root["status"].asString();
    if (status == "success") {
      std::string user = root["data"]["user"].asString();
      std::string password = root["data"]["password"].asString();
      std::string channel = root["data"]["channel"].asString();
      std::string sign = root["data"]["sign"].asString();
      if (SdkPluginManager::mLuaHandlerId > 0) {
        CCLuaStack* stack = CCLuaEngine::defaultEngine()->getLuaStack();
        stack->pushString(status.c_str());
        stack->pushString(user.c_str());
        stack->pushString(password.c_str());
        stack->pushString(channel.c_str());
        stack->pushString(sign.c_str());
        stack->executeFunctionByHandler(SdkPluginManager::mLuaHandlerId, 5);
        stack->clean();
      }
    } else {
      CCLuaStack* stack = CCLuaEngine::defaultEngine()->getLuaStack();
      std::string message = root["data"]["message"].asString();
      stack->pushString(status.c_str());
      stack->pushString(message.c_str());
      stack->pushString(message.c_str());
      stack->pushString(message.c_str());
      stack->pushString(message.c_str());
      stack->executeFunctionByHandler(SdkPluginManager::mLuaHandlerId, 5);
      stack->clean();
      CCLog(" reqAccountResult: wrong data !!!!");
    }
    return (size * nmemb);
  }
  int SdkPluginManager::getLuaHandler() {
    return mLuaHandlerId;
  }
  void SdkPluginManager::switchAccount() {
#ifdef ANDROID_WANDOUJIA
    JniMethodInfo t;
    if (JniHelper::getStaticMethodInfo(t, PLUGINCLASSNAME, "switchAccount", "()V")) {
      t.env->CallStaticVoidMethod(t.classID, t.methodID);
    }
#endif
#ifdef ANDROID_360
    JniMethodInfo t;
    if (JniHelper::getStaticMethodInfo(t, PLUGINCLASSNAME, "switchAccount", "()V")) {
      t.env->CallStaticVoidMethod(t.classID, t.methodID);
    }
#endif
  }
  void SdkPluginManager::doCharge(const std::string& notifyUrl,
      const std::string& goodsId, const std::string& playerId,
      const std::string& paymentCode, const std::string& serverId,
      const std::string& channelId, const std::string& params) {
#ifdef ANDROID_GOOGLEPLAY_CT
    std::string game = "qcardsanguoct";
#else
    std::string game = "qcardsanguo";
#endif
    std::string signKey = "chqcsg@paypower";
    std::string mode = "sdk";
    std::string paymentUrl = URL_DS_PAYMENT + "/payment/createOrder";
    std::string channel = channelId;
    if (channel == "googleWorld") {
#ifdef ANDROID_GOOGLEPLAY_CT
      channel = "googlePlay";
#endif
#ifdef ANDROID_GOOGLEPLAY_SC
      channel = "googlePlay";
#endif
    }
  if(channelId=="gashPlusHK"||channelId=="gashPlusTW"||channelId=="gashPlusMY"){
     channel="gashPlus";
     mode = "web";
  }
  if(channelId=="paypal"){
    game = "qcardsanguo";
    mode = "web";
  }
  std::string preSign = game + playerId + channel + paymentCode + signKey;
  MD5 md5;
  md5.reset();
  md5.update(preSign);
  std::string sign = md5.toString();
  std::string url="";
  if(params==""){
  url = paymentUrl + "?from=mobile&game=" + game + "&playerId="
      + playerId + "&channel=" + channel + "&paymentCode=" + paymentCode
      + "&sign=" + sign + "&mode=" + mode + "&notifyUrl=" + notifyUrl
      + "&serverId=" + serverId;
  }else{
    url = paymentUrl + "?from=mobile&game=" + game + "&playerId="
          + playerId + "&channel=" + channel + "&paymentCode=" + paymentCode
          + "&sign=" + sign + "&mode=" + mode + "&notifyUrl=" + notifyUrl
          + "&serverId=" + serverId+"&"+params;
  }
  CCLog("url=%s", url.c_str());
  if(channelId=="gashPlusHK"||channelId=="gashPlusTW"||channelId=="gashPlusMY"||channelId=="paypal"){
     openUrl(url);
  }else if(channelId=="googleWorld"){
     doCharge(CHANNEL_GOOGLEPLAY,url);
  }else if(channelId=="mycard"){
     doCharge(CHANNEL_MYCARD,url);
  }
}
void SdkPluginManager::doCharge(const std::string& notifyUrl,
    const std::string& goodsId, const std::string& playerId,
    const std::string& paymentCode, const std::string& serverId,const std::string& params){
  std::string game = "qcardsanguo";
  std::string signKey = "chqcsg@paypower";
  std::string mode = "sdk";
  std::string paymentUrl = URL_DS_PAYMENT + "/payment/createOrder";
  std::string channel = PAY_CHANNEL_ID;
  std::string preSign = game + playerId + channel + paymentCode + signKey;
  MD5 md5;
  md5.reset();
  md5.update(preSign);
  std::string sign = md5.toString();
  std::string url = paymentUrl + "?from=mobile&game=" + game + "&playerId="
      + playerId + "&channel=" + channel + "&paymentCode=" + paymentCode
      + "&sign=" + sign + "&mode=" + mode + "&notifyUrl=" + notifyUrl
      + "&serverId=" + serverId+"&"+params;
  CCLog("url=%s", url.c_str());
  doCharge(url);
}

void SdkPluginManager::setSubChannel(const std::string &subChannel){
	channel=subChannel;
}
NS_GAME_FRM_END
