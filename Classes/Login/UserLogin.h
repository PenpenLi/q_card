#ifndef USERLOGIN_H_
#define USERLOGIN_H_
#include <string>
#include <vector>
#include "Common/CommonDefine.h"
NS_GAME_FRM_BEGIN
class UserLogin {
public:
	UserLogin(){}
	virtual ~UserLogin();
	static void login(const std::string &user,const std::string &password);
	static void registe(const std::string &user,const std::string &password);
	static void registerScriptHandler(int nHandler);
	static void getUser(const std::string &token);
	static const std::string getChannel();
	static int mLuaHandlerId;
	static std::vector<std::string> split(const std::string str,int len);
	static void fastCreateUser();
	static std::string buildFastCreateUserParams();
	static void bindAccount(const std::string &oldUser,const std::string &oldPassword,const std::string &user,const std::string &password);
	static std::string buildBindAccountParams(const std::string &oldUser,const std::string &oldPassword,const std::string &user,const std::string &password);
	static void gameExit();
private:
	static std::string m_loginUrl;
	static std::string m_password_key;
	static std::string m_sign_key;
	static std::string m_verifyUrl;
	static std::string m_userName;
	static std::string m_password;
	static std::string m_action;
	static std::string buildParams(const std::string &user,const std::string &password);
	static std::string decode(const std::string &text, const std::string &key);
	static std::string encode(const std::string &text, const std::string &key);
	static std::vector<int> transKey(const std::string &key);
  static size_t fetchServiceResult(void *ptr, size_t size, size_t nmemb, void *userdata);
  static void fetchService(const char *url);
  static void invokeLuaCallbackFunction(const std::string &status, const std::string &message);
};
NS_GAME_FRM_END
#endif /* USERLOGIN_H_ */
//tolua++ -L cinvokelua.lua -o "../../scripting/lua/cocos2dx_support/lua_userlogin.cpp" UserLogin.pkg
