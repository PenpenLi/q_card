#include <sstream>
#include <time.h>
#include "Login/UserLogin.h"
#include "UpdateVersion/md5.h"
#include "Login/Sha1.h"
#include "Login/DSbase64.h"
#include "CCLuaEngine.h"
#include "json_lib.h"
#include <curl/curl.h>
#include <curl/easy.h>
#include "cocos2d.h"
#include "cocos-ext.h"  
USING_NS_CC;  
USING_NS_CC_EXT;  
using namespace CSJson; 

NS_GAME_FRM_BEGIN

  int UserLogin::mLuaHandlerId = -1;

  std::string UserLogin::m_loginUrl  = URL_DS_USER;
  std::string UserLogin::m_verifyUrl = URL_USER_MAPPING + "/dsuc/getUser";

  std::string UserLogin::m_password_key = "4h3e4hz6";
  std::string UserLogin::m_sign_key = "FEA6F4E8F4A6EF4AFE4";
  std::string UserLogin::m_userName="";
  std::string UserLogin::m_password="";
  std::string UserLogin::m_action="";

  UserLogin::~UserLogin() {
  }

  void UserLogin::login(const std::string &user, const std::string &password) {
    m_action="login";
    std::string url = m_loginUrl + "/auth/login" + buildParams(user, password);
    CCLog("UserLogin::login url=%s",url.c_str());
    fetchService(url.c_str());
  }

  void UserLogin::registe(const std::string &user,const std::string &password) {
    m_action="registe";
    std::string url = m_loginUrl + "/auth/register"+ buildParams(user, password);
	CCLog("UserLogin::registe url=%s",url.c_str());
    fetchService(url.c_str());
  }

  void UserLogin::registerScriptHandler(int nHandler) {
    UserLogin::mLuaHandlerId = nHandler;
  }

  std::vector<int> UserLogin::transKey(const std::string &key) {
    std::vector<int> result;
    size_t i = 0;
    size_t len = key.length();
    while (i < len) {
      result.push_back(key[i]);
      i++;
    }
    return result;
  }

  std::string UserLogin::encode(const std::string &text, const std::string &key) {
    size_t len = key.length();
    std::vector<int> transkey = transKey(key);
    size_t i = 0;
    size_t textLen = text.length();
    std::string sink("");
    while (i < textLen) {
      char c=text[i];
      int temp=((int)c) + transkey[i % len];
      if(temp<=127){
         sink += (char)temp;
         sink += (char)0;
      }
	  else {
         sink += (char)127;
         sink +=(char)(temp-127);
      }
      i++;
    }
    return Base64::encode((unsigned char *) sink.c_str(), sink.length());
  }

  std::string UserLogin::decode(const std::string &text, const std::string &key) {
    std::string txt = Base64::decode(text);
    size_t textLen = txt.length();
    size_t keyLen = key.length();
    std::vector<int> transkey = transKey(key);
    size_t i = 0;
    std::string sink("");
    while (i < textLen) {
      int ch = ((int) text[i]) - transkey[i % keyLen];
      sink += (char) ch;
      i++;
    }
    return sink;
  }

  std::string UserLogin::buildParams(const std::string &user, const std::string &pass) {
    std::string password = encode(pass, m_password_key);
    std::string source = "qcardsanguo";
    int seconds = time((time_t*) NULL);
    std::string timestamp;
    std::stringstream ss;
    std::string str;
    ss << seconds;
    ss >> timestamp;
    std::string preSign = user + password + source + timestamp + m_sign_key;
    MD5 md5;
    md5.reset();
    md5.update(preSign);
    std::string sign = md5.toString();
    std::string skey = CSHA1::sha1(sign);
    std::string data = "?user_account=" + user + "&password=" + password
        + "&source=" + source + "&timestamp=" + timestamp + "&skey=" + skey;
    return data;
  }

  void UserLogin::fetchService(const char *url) {
    CURL * _curl = curl_easy_init();
    curl_easy_setopt(_curl, CURLOPT_URL, url);
    curl_easy_setopt(_curl, CURLOPT_WRITEFUNCTION,UserLogin::fetchServiceResult);
    curl_easy_setopt(_curl, CURLOPT_CONNECTTIMEOUT, 10);
    CURLcode res = curl_easy_perform(_curl);
    int http_code = 0;
    curl_easy_getinfo(_curl, CURLINFO_RESPONSE_CODE, &http_code);
    curl_easy_cleanup(_curl);
    if (res != 0 || http_code != 200) {
      CCLog(" req url fail !!!!!:res=%d, http_code=%d", res, http_code);
      if(m_action=="login"||m_action=="registe") {
        invokeLuaCallbackFunction("error","10001");
      }
	  else if(m_action=="getUser") {
        CCLuaStack* stack = CCLuaEngine::defaultEngine()->getLuaStack();
        std::string status="error";
        std::string message="10001";
        stack->pushString(status.c_str());
        stack->pushString(message.c_str());
        stack->pushString(message.c_str());
        stack->pushString(message.c_str());
        stack->pushString(message.c_str());
        stack->executeFunctionByHandler(UserLogin::mLuaHandlerId, 5);
        stack->clean();
      }
      return;
    }
  }

  size_t UserLogin::fetchServiceResult(void *ptr, size_t size, size_t nmemb,void *userdata) {
    CSJson::Reader reader;
    std::string str = (char *) ptr;
    CSJson::Value root;
    reader.parse(str, root);
    std::string status = root["status"].asString();
    if(m_action=="login"||m_action=="registe"){
      if (status == "success") {
        std::string token = root["user_token"].asString();
        invokeLuaCallbackFunction(status, token);
      }
	  else if (status == "error") {
        std::string message = root["message"].asString();
        invokeLuaCallbackFunction(status, message);
      }
	  else {
        CCLog(" reqAccountResult: wrong data !!!!");
        invokeLuaCallbackFunction("error", "wrong data");
      }
    }
	else if(m_action=="getUser") {
      if (status == "success") {
        std::string user = root["data"]["user"].asString();
        std::string password = root["data"]["password"].asString();
        std::string channel = root["data"]["channel"].asString();
        std::string sign = root["data"]["sign"].asString();
        if (UserLogin::mLuaHandlerId > 0) {
          CCLuaStack* stack = CCLuaEngine::defaultEngine()->getLuaStack();
          stack->pushString(status.c_str());
          stack->pushString(user.c_str());
          stack->pushString(password.c_str());
          stack->pushString(channel.c_str());
          stack->pushString(sign.c_str());
          stack->executeFunctionByHandler(UserLogin::mLuaHandlerId, 5);
          stack->clean();
        }
      } 
	  else {
        CCLuaStack* stack = CCLuaEngine::defaultEngine()->getLuaStack();
        std::string message = root["data"]["message"].asString();
        stack->pushString(status.c_str());
        stack->pushString(message.c_str());
        stack->pushString(message.c_str());
        stack->pushString(message.c_str());
        stack->pushString(message.c_str());
        stack->executeFunctionByHandler(UserLogin::mLuaHandlerId, 5);
        stack->clean();
        CCLog(" reqAccountResult: wrong data !!!!");
      }
    }
	else if(m_action=="fastCreateUser") {
      if (status == "success") {
          std::string user_account = root["user_account"].asString();
          std::string password = root["password"].asString();
          CCLuaStack* stack = CCLuaEngine::defaultEngine()->getLuaStack();
          stack->pushString(status.c_str());
          stack->pushString(user_account.c_str());
          stack->pushString(password.c_str());
          stack->executeFunctionByHandler(UserLogin::mLuaHandlerId, 3);
          stack->clean();
      }
    }
	else if( m_action=="bindAccount") {
      CCLuaStack* stack = CCLuaEngine::defaultEngine()->getLuaStack();
      if (status == "success") {
        stack->pushString(status.c_str());
        stack->executeFunctionByHandler(UserLogin::mLuaHandlerId, 1);
      }
	  else {
         std::string message = root["message"].asString();
         stack->pushString(message.c_str());
         stack->executeFunctionByHandler(UserLogin::mLuaHandlerId, 1);
      }
      stack->clean();
    }
    return (size * nmemb);
  }

  void UserLogin::invokeLuaCallbackFunction(const std::string &status, const std::string &text) {
    if (UserLogin::mLuaHandlerId > 0) {
      CCLuaStack* stack = CCLuaEngine::defaultEngine()->getLuaStack();
      stack->pushString(status.c_str());
      stack->pushString(text.c_str());
      stack->executeFunctionByHandler(UserLogin::mLuaHandlerId, 2);
      stack->clean();
    }
  }

  void UserLogin::getUser(const std::string &token) {
    m_action="getUser";
    std::string path = m_verifyUrl + "/" + token + "/qcardsanguo";
    const char *url = path.c_str();
	CCLog("UserLogin::getUser url=%s",url);
    fetchService(url);
  }

  const std::string UserLogin::getChannel() {
#ifdef PAY_CHANNEL_ID
    const std::string strChannel = PAY_CHANNEL_ID;
    return strChannel;
#else
    return "alipay";
#endif
  }

  std::vector<std::string> UserLogin::split(const std::string str,int len) {
    size_t length = str.length();
    std::vector<std::string> result;
    for(size_t i=0;i<length;i=i+2) {
      result.push_back(str.substr(i,len));
    }
    return result;
  }

  void UserLogin::fastCreateUser(){
    m_action="fastCreateUser";
    std::string url = m_loginUrl + "/auth/registerQuick"+buildFastCreateUserParams();
    fetchService(url.c_str());
  }

  std::string UserLogin::buildFastCreateUserParams() {
    std::string source = "qcardsanguo";
    int seconds = time((time_t*) NULL);
    std::string timestamp;
    std::stringstream ss;
    std::string str;
    ss << seconds;
    ss >> timestamp;
    std::string preSign =source + timestamp + m_sign_key;
    MD5 md5;
    md5.reset();
    md5.update(preSign);
    std::string sign = md5.toString();
    std::string skey = CSHA1::sha1(sign);
    std::string data ="?source=" + source + "&timestamp=" + timestamp + "&skey=" + skey;
    return data;
  }

  void UserLogin::bindAccount(const std::string &oldUser,const std::string &oldPassword,const std::string &user,const std::string &password){
    m_action="bindAccount";
    m_userName=user;
    m_password=password;
    std::string url = m_loginUrl + "/auth/bindEmail"+buildBindAccountParams(oldUser,oldPassword,user,password);
    fetchService(url.c_str());
  }

  std::string UserLogin::buildBindAccountParams(const std::string &oldUser,const std::string &oldPassword,const std::string &user,const std::string &password) {
    std::string source = "qcardsanguo";
    int seconds = time((time_t*) NULL);
    std::string ecOldPassword = encode(oldPassword, m_password_key);
    std::string ecPassword = encode(password, m_password_key);
    std::string timestamp;
    std::stringstream ss;
    std::string str;
    ss << seconds;
    ss >> timestamp;
    std::string preSign =oldUser+ecOldPassword+user+ecPassword+source+timestamp + m_sign_key;
    MD5 md5;
    md5.reset();
    md5.update(preSign);
    std::string sign = md5.toString();
    std::string skey = CSHA1::sha1(sign);
    std::string data ="?user_account="+oldUser+"&password="+ecOldPassword
        +"&user_account_new="+user+"&password_new="+ecPassword
        +"&source=" + source + "&timestamp=" + timestamp + "&skey=" + skey;
    return data;
  }
void UserLogin::gameExit(){
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WINRT) || (CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
  CCMessageBox("You pressed the close button. Windows Store Apps do not implement a close button.","Alert");
#else
    CCDirector::sharedDirector()->end();
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    exit(0);
#endif
#endif
}
NS_GAME_FRM_END

