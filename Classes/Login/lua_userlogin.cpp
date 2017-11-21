/*
** Lua binding: UserLogin
** Generated automatically by tolua++-1.0.92 on 11/17/14 13:41:53.
*/

#ifndef __cplusplus
#include "stdlib.h"
#endif
#include <string>
#include "UserLogin.h"
USING_NS_GAME_FRM
#include "tolua++.h"
extern "C" {
#include "tolua_fix.h"
}
#include "cocos2d.h"
#include "CCLuaEngine.h"
#include "LuaCocos2d.h"
using namespace cocos2d;

/* Exported function */
TOLUA_API int  tolua_UserLogin_open (lua_State* tolua_S);


/* function to register type */
static void tolua_reg_types (lua_State* tolua_S)
{
 
 tolua_usertype(tolua_S,"UserLogin");
}

/* method: login of class  UserLogin */
#ifndef TOLUA_DISABLE_tolua_UserLogin_UserLogin_login00
static int tolua_UserLogin_UserLogin_login00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"UserLogin",0,&tolua_err) ||
     !tolua_iscppstring(tolua_S,2,0,&tolua_err) ||
     !tolua_iscppstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  const std::string user = ((const std::string)  tolua_tocppstring(tolua_S,2,0));
  const std::string password = ((const std::string)  tolua_tocppstring(tolua_S,3,0));
  {
   UserLogin::login(user,password);
   tolua_pushcppstring(tolua_S,(const char*)user);
   tolua_pushcppstring(tolua_S,(const char*)password);
  }
 }
 return 2;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'login'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: registe of class  UserLogin */
#ifndef TOLUA_DISABLE_tolua_UserLogin_UserLogin_registe00
static int tolua_UserLogin_UserLogin_registe00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"UserLogin",0,&tolua_err) ||
     !tolua_iscppstring(tolua_S,2,0,&tolua_err) ||
     !tolua_iscppstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  const std::string user = ((const std::string)  tolua_tocppstring(tolua_S,2,0));
  const std::string password = ((const std::string)  tolua_tocppstring(tolua_S,3,0));
  {
   UserLogin::registe(user,password);
   tolua_pushcppstring(tolua_S,(const char*)user);
   tolua_pushcppstring(tolua_S,(const char*)password);
  }
 }
 return 2;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'registe'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: registerScriptHandler of class  UserLogin */
#ifndef TOLUA_DISABLE_tolua_UserLogin_UserLogin_registerScriptHandler00
static int tolua_UserLogin_UserLogin_registerScriptHandler00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"UserLogin",0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,2,&tolua_err) || !toluafix_isfunction(tolua_S,2,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  LUA_FUNCTION nHandler = (  toluafix_ref_function(tolua_S,2,0));
  {
   UserLogin::registerScriptHandler(nHandler);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'registerScriptHandler'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getUser of class  UserLogin */
#ifndef TOLUA_DISABLE_tolua_UserLogin_UserLogin_getUser00
static int tolua_UserLogin_UserLogin_getUser00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"UserLogin",0,&tolua_err) ||
     !tolua_iscppstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  const std::string token = ((const std::string)  tolua_tocppstring(tolua_S,2,0));
  {
   UserLogin::getUser(token);
   tolua_pushcppstring(tolua_S,(const char*)token);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getUser'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getChannel of class  UserLogin */
#ifndef TOLUA_DISABLE_tolua_UserLogin_UserLogin_getChannel00
static int tolua_UserLogin_UserLogin_getChannel00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"UserLogin",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   const std::string tolua_ret = (const std::string)  UserLogin::getChannel();
   tolua_pushcppstring(tolua_S,(const char*)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getChannel'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: fastCreateUser of class  UserLogin */
#ifndef TOLUA_DISABLE_tolua_UserLogin_UserLogin_fastCreateUser00
static int tolua_UserLogin_UserLogin_fastCreateUser00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"UserLogin",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   UserLogin::fastCreateUser();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'fastCreateUser'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: bindAccount of class  UserLogin */
#ifndef TOLUA_DISABLE_tolua_UserLogin_UserLogin_bindAccount00
static int tolua_UserLogin_UserLogin_bindAccount00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"UserLogin",0,&tolua_err) ||
     !tolua_iscppstring(tolua_S,2,0,&tolua_err) ||
     !tolua_iscppstring(tolua_S,3,0,&tolua_err) ||
     !tolua_iscppstring(tolua_S,4,0,&tolua_err) ||
     !tolua_iscppstring(tolua_S,5,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,6,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  const std::string oldUser = ((const std::string)  tolua_tocppstring(tolua_S,2,0));
  const std::string oldPassword = ((const std::string)  tolua_tocppstring(tolua_S,3,0));
  const std::string user = ((const std::string)  tolua_tocppstring(tolua_S,4,0));
  const std::string password = ((const std::string)  tolua_tocppstring(tolua_S,5,0));
  {
   UserLogin::bindAccount(oldUser,oldPassword,user,password);
   tolua_pushcppstring(tolua_S,(const char*)oldUser);
   tolua_pushcppstring(tolua_S,(const char*)oldPassword);
   tolua_pushcppstring(tolua_S,(const char*)user);
   tolua_pushcppstring(tolua_S,(const char*)password);
  }
 }
 return 4;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'bindAccount'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: gameExit of class  UserLogin */
#ifndef TOLUA_DISABLE_tolua_UserLogin_UserLogin_gameExit00
static int tolua_UserLogin_UserLogin_gameExit00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"UserLogin",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   UserLogin::gameExit();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'gameExit'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* Open function */
TOLUA_API int tolua_UserLogin_open (lua_State* tolua_S)
{
 tolua_open(tolua_S);
 tolua_reg_types(tolua_S);
 tolua_module(tolua_S,NULL,0);
 tolua_beginmodule(tolua_S,NULL);
  tolua_cclass(tolua_S,"UserLogin","UserLogin","",NULL);
  tolua_beginmodule(tolua_S,"UserLogin");
   tolua_function(tolua_S,"login",tolua_UserLogin_UserLogin_login00);
   tolua_function(tolua_S,"registe",tolua_UserLogin_UserLogin_registe00);
   tolua_function(tolua_S,"registerScriptHandler",tolua_UserLogin_UserLogin_registerScriptHandler00);
   tolua_function(tolua_S,"getUser",tolua_UserLogin_UserLogin_getUser00);
   tolua_function(tolua_S,"getChannel",tolua_UserLogin_UserLogin_getChannel00);
   tolua_function(tolua_S,"fastCreateUser",tolua_UserLogin_UserLogin_fastCreateUser00);
   tolua_function(tolua_S,"bindAccount",tolua_UserLogin_UserLogin_bindAccount00);
   tolua_function(tolua_S,"gameExit",tolua_UserLogin_UserLogin_gameExit00);
  tolua_endmodule(tolua_S);
 tolua_endmodule(tolua_S);
 return 1;
}


#if defined(LUA_VERSION_NUM) && LUA_VERSION_NUM >= 501
 TOLUA_API int luaopen_UserLogin (lua_State* tolua_S) {
 return tolua_UserLogin_open(tolua_S);
};
#endif

