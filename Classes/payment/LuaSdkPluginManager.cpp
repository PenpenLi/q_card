/*
** Lua binding: SdkPluginManager
** Generated automatically by tolua++-1.0.92 on 08/11/14 11:36:12.
*/
//tolua++ -L cinvokelua.lua -o "../../scripting/lua/cocos2dx_support/LuaSdkPluginManager.cpp" SdkPluginManager.pkg
#ifndef __cplusplus
#include "stdlib.h"
#endif
#include <string>
#include "Common/CommonDefine.h"
#include "payment/SdkPluginManager.h"
#include "tolua++.h"
extern "C" {
#include "tolua_fix.h"
}
#include "cocos2d.h"
#include "CCLuaEngine.h"
#include "LuaCocos2d.h"

using namespace cocos2d;
USING_NS_GAME_FRM

/* Exported function */
TOLUA_API int  tolua_SdkPluginManager_open (lua_State* tolua_S);


/* function to register type */
static void tolua_reg_types (lua_State* tolua_S)
{
 tolua_usertype(tolua_S,"SdkPluginManager");
 
}

/* method: getInstance of class  SdkPluginManager */
#ifndef TOLUA_DISABLE_tolua_SdkPluginManager_SdkPluginManager_getInstance00
static int tolua_SdkPluginManager_SdkPluginManager_getInstance00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"SdkPluginManager",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   SdkPluginManager* tolua_ret = (SdkPluginManager*)  SdkPluginManager::getInstance();
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"SdkPluginManager");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getInstance'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: clear of class  SdkPluginManager */
#ifndef TOLUA_DISABLE_tolua_SdkPluginManager_SdkPluginManager_clear00
static int tolua_SdkPluginManager_SdkPluginManager_clear00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"SdkPluginManager",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   SdkPluginManager::clear();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'clear'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: login of class  SdkPluginManager */
#ifndef TOLUA_DISABLE_tolua_SdkPluginManager_SdkPluginManager_login00
static int tolua_SdkPluginManager_SdkPluginManager_login00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"SdkPluginManager",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  SdkPluginManager* self = (SdkPluginManager*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'login'", NULL);
#endif
  {
   self->login();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'login'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: release of class  SdkPluginManager */
#ifndef TOLUA_DISABLE_tolua_SdkPluginManager_SdkPluginManager_release00
static int tolua_SdkPluginManager_SdkPluginManager_release00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"SdkPluginManager",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  SdkPluginManager* self = (SdkPluginManager*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'release'", NULL);
#endif
  {
   self->release();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'release'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: logout of class  SdkPluginManager */
#ifndef TOLUA_DISABLE_tolua_SdkPluginManager_SdkPluginManager_logout00
static int tolua_SdkPluginManager_SdkPluginManager_logout00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"SdkPluginManager",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  SdkPluginManager* self = (SdkPluginManager*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'logout'", NULL);
#endif
  {
   self->logout();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'logout'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: registerScriptHandler of class  SdkPluginManager */
#ifndef TOLUA_DISABLE_tolua_SdkPluginManager_SdkPluginManager_registerScriptHandler00
static int tolua_SdkPluginManager_SdkPluginManager_registerScriptHandler00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"SdkPluginManager",0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,2,&tolua_err) || !toluafix_isfunction(tolua_S,2,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  LUA_FUNCTION nHandler = (  toluafix_ref_function(tolua_S,2,0));
  {
   SdkPluginManager::registerScriptHandler(nHandler);
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

/* method: switchAccount of class  SdkPluginManager */
#ifndef TOLUA_DISABLE_tolua_SdkPluginManager_SdkPluginManager_switchAccount00
static int tolua_SdkPluginManager_SdkPluginManager_switchAccount00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"SdkPluginManager",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   SdkPluginManager::switchAccount();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'switchAccount'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setSubChannel of class  SdkPluginManager */
#ifndef TOLUA_DISABLE_tolua_SdkPluginManager_SdkPluginManager_setSubChannel00
static int tolua_SdkPluginManager_SdkPluginManager_setSubChannel00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"SdkPluginManager",0,&tolua_err) ||
     !tolua_iscppstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  SdkPluginManager* self = (SdkPluginManager*)  tolua_tousertype(tolua_S,1,0);
  const std::string channel = ((const std::string)  tolua_tocppstring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setSubChannel'", NULL);
#endif
  {
   self->setSubChannel(channel);
   tolua_pushcppstring(tolua_S,(const char*)channel);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setSubChannel'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* Open function */
TOLUA_API int tolua_SdkPluginManager_open (lua_State* tolua_S)
{
 tolua_open(tolua_S);
 tolua_reg_types(tolua_S);
 tolua_module(tolua_S,NULL,0);
 tolua_beginmodule(tolua_S,NULL);
  tolua_cclass(tolua_S,"SdkPluginManager","SdkPluginManager","",NULL);
  tolua_beginmodule(tolua_S,"SdkPluginManager");
   tolua_function(tolua_S,"getInstance",tolua_SdkPluginManager_SdkPluginManager_getInstance00);
   tolua_function(tolua_S,"clear",tolua_SdkPluginManager_SdkPluginManager_clear00);
   tolua_function(tolua_S,"login",tolua_SdkPluginManager_SdkPluginManager_login00);
   tolua_function(tolua_S,"release",tolua_SdkPluginManager_SdkPluginManager_release00);
   tolua_function(tolua_S,"logout",tolua_SdkPluginManager_SdkPluginManager_logout00);
   tolua_function(tolua_S,"registerScriptHandler",tolua_SdkPluginManager_SdkPluginManager_registerScriptHandler00);
   tolua_function(tolua_S,"switchAccount",tolua_SdkPluginManager_SdkPluginManager_switchAccount00);
   tolua_function(tolua_S,"setSubChannel",tolua_SdkPluginManager_SdkPluginManager_setSubChannel00);
  tolua_endmodule(tolua_S);
 tolua_endmodule(tolua_S);
 return 1;
}


#if defined(LUA_VERSION_NUM) && LUA_VERSION_NUM >= 501
 TOLUA_API int luaopen_SdkPluginManager (lua_State* tolua_S) {
 return tolua_SdkPluginManager_open(tolua_S);
};
#endif



