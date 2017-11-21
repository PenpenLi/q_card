/*
** Lua binding: Cocos2d
** Generated automatically by tolua++-1.0.92 on 11/04/13 16:58:41.
*/

#ifndef __cplusplus
#include "stdlib.h"
#endif
#include "string.h"

#include "tolua++.h"


#include "IoRecord/IoRecord.h" //by hlb 2013-11-04



/* function to register type */
static void tolua_reg_types (lua_State* tolua_S)
{
#ifndef Mtolua_typeid
#define Mtolua_typeid(L,TI,T)
#endif
 tolua_usertype(tolua_S,"IoRecord");
 Mtolua_typeid(tolua_S,typeid(IoRecord), "IoRecord");
}

/* method: setBoolForKey of class  IoRecord */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_IoRecord_setBoolForKey00
static int tolua_Cocos2d_IoRecord_setBoolForKey00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"IoRecord",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isboolean(tolua_S,3,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  IoRecord* self = (IoRecord*)  tolua_tousertype(tolua_S,1,0);
  int key = ((int)  tolua_tonumber(tolua_S,2,0));
  bool val = ((bool)  tolua_toboolean(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setBoolForKey'", NULL);
#endif
  {
   self->setBoolForKey(key,val);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setBoolForKey'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setIntegerForKey of class  IoRecord */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_IoRecord_setIntegerForKey00
static int tolua_Cocos2d_IoRecord_setIntegerForKey00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"IoRecord",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,3,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  IoRecord* self = (IoRecord*)  tolua_tousertype(tolua_S,1,0);
  int key = ((int)  tolua_tonumber(tolua_S,2,0));
  int val = ((int)  tolua_tonumber(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setIntegerForKey'", NULL);
#endif
  {
   self->setIntegerForKey(key,val);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setIntegerForKey'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setFloatForKey of class  IoRecord */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_IoRecord_setFloatForKey00
static int tolua_Cocos2d_IoRecord_setFloatForKey00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"IoRecord",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,3,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  IoRecord* self = (IoRecord*)  tolua_tousertype(tolua_S,1,0);
  int key = ((int)  tolua_tonumber(tolua_S,2,0));
  float val = ((float)  tolua_tonumber(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setFloatForKey'", NULL);
#endif
  {
   self->setFloatForKey(key,val);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setFloatForKey'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setStringForKey of class  IoRecord */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_IoRecord_setStringForKey00
static int tolua_Cocos2d_IoRecord_setStringForKey00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"IoRecord",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_iscppstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  IoRecord* self = (IoRecord*)  tolua_tousertype(tolua_S,1,0);
  int key = ((int)  tolua_tonumber(tolua_S,2,0));
  const std::string val = ((const std::string)  tolua_tocppstring(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setStringForKey'", NULL);
#endif
  {
   self->setStringForKey(key,val);
   tolua_pushcppstring(tolua_S,(const char*)val);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setStringForKey'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getBoolForKey of class  IoRecord */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_IoRecord_getBoolForKey00
static int tolua_Cocos2d_IoRecord_getBoolForKey00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"IoRecord",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  IoRecord* self = (IoRecord*)  tolua_tousertype(tolua_S,1,0);
  int key = ((int)  tolua_tonumber(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getBoolForKey'", NULL);
#endif
  {
   bool tolua_ret = (bool)  self->getBoolForKey(key);
   tolua_pushboolean(tolua_S,(bool)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getBoolForKey'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getIntegerForKey of class  IoRecord */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_IoRecord_getIntegerForKey00
static int tolua_Cocos2d_IoRecord_getIntegerForKey00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"IoRecord",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  IoRecord* self = (IoRecord*)  tolua_tousertype(tolua_S,1,0);
  int key = ((int)  tolua_tonumber(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getIntegerForKey'", NULL);
#endif
  {
   int tolua_ret = (int)  self->getIntegerForKey(key);
   tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getIntegerForKey'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getFloatForKey of class  IoRecord */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_IoRecord_getFloatForKey00
static int tolua_Cocos2d_IoRecord_getFloatForKey00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"IoRecord",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  IoRecord* self = (IoRecord*)  tolua_tousertype(tolua_S,1,0);
  int key = ((int)  tolua_tonumber(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getFloatForKey'", NULL);
#endif
  {
   float tolua_ret = (float)  self->getFloatForKey(key);
   tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getFloatForKey'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getStringForKey of class  IoRecord */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_IoRecord_getStringForKey00
static int tolua_Cocos2d_IoRecord_getStringForKey00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"IoRecord",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  IoRecord* self = (IoRecord*)  tolua_tousertype(tolua_S,1,0);
  int key = ((int)  tolua_tonumber(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getStringForKey'", NULL);
#endif
  {
   std::string tolua_ret = (std::string)  self->getStringForKey(key);
   tolua_pushcppstring(tolua_S,(const char*)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getStringForKey'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: sharedRecord of class  IoRecord */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_IoRecord_sharedRecord00
static int tolua_Cocos2d_IoRecord_sharedRecord00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"IoRecord",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   IoRecord* tolua_ret = (IoRecord*)  IoRecord::sharedRecord();
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"IoRecord");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'sharedRecord'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* Open function */
TOLUA_API int tolua_Cocos2d_open_for_IoRecord (lua_State* tolua_S)
{
 tolua_open(tolua_S);
 tolua_reg_types(tolua_S);
 tolua_module(tolua_S,NULL,0);
 tolua_beginmodule(tolua_S,NULL);
  tolua_cclass(tolua_S,"IoRecord","IoRecord","",NULL);
  tolua_beginmodule(tolua_S,"IoRecord");
   tolua_function(tolua_S,"setBoolForKey",tolua_Cocos2d_IoRecord_setBoolForKey00);
   tolua_function(tolua_S,"setIntegerForKey",tolua_Cocos2d_IoRecord_setIntegerForKey00);
   tolua_function(tolua_S,"setFloatForKey",tolua_Cocos2d_IoRecord_setFloatForKey00);
   tolua_function(tolua_S,"setStringForKey",tolua_Cocos2d_IoRecord_setStringForKey00);
   tolua_function(tolua_S,"getBoolForKey",tolua_Cocos2d_IoRecord_getBoolForKey00);
   tolua_function(tolua_S,"getIntegerForKey",tolua_Cocos2d_IoRecord_getIntegerForKey00);
   tolua_function(tolua_S,"getFloatForKey",tolua_Cocos2d_IoRecord_getFloatForKey00);
   tolua_function(tolua_S,"getStringForKey",tolua_Cocos2d_IoRecord_getStringForKey00);
   tolua_function(tolua_S,"sharedRecord",tolua_Cocos2d_IoRecord_sharedRecord00);
  tolua_endmodule(tolua_S);
 tolua_endmodule(tolua_S);
 return 1;
}


