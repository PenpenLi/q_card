/*
** Lua binding: Cocos2d
** Generated automatically by tolua++-1.0.92 on 11/04/13 16:58:41.
*/

#ifndef __cplusplus
#include "stdlib.h"
#endif


#include "tolua++.h"


#include "GameEntry.h"

static int tolua_collect_dateInfo (lua_State* tolua_S)
{
 dateInfo* self = (dateInfo*) tolua_tousertype(tolua_S,1,0);
    Mtolua_delete(self);
    return 0;
}

static void tolua_reg_types (lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"dateInfo");
	tolua_usertype(tolua_S,"CCObject");
	tolua_usertype(tolua_S,"GameEntry");
}

/* method: instance of class  GameEntry */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_GameEntry_instance00
static int tolua_Cocos2d_GameEntry_instance00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"GameEntry",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   GameEntry* tolua_ret = (GameEntry*)  GameEntry::instance();
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"GameEntry");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'instance'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: runGame of class  GameEntry */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_GameEntry_runGame00
static int tolua_Cocos2d_GameEntry_runGame00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"GameEntry",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  GameEntry* self = (GameEntry*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'runGame'", NULL);
#endif
  {
   self->runGame();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'runGame'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: runResUpdate of class  GameEntry */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_GameEntry_runResUpdate00
static int tolua_Cocos2d_GameEntry_runResUpdate00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"GameEntry",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  GameEntry* self = (GameEntry*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'runResUpdate'", NULL);
#endif
  {
   self->runResUpdate();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'runResUpdate'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getUserName of class  GameEntry */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_GameEntry_getUserName00
static int tolua_Cocos2d_GameEntry_getUserName00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"GameEntry",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  GameEntry* self = (GameEntry*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getUserName'", NULL);
#endif
  {
   const char* tolua_ret = (const char*)  self->getUserName();
   tolua_pushstring(tolua_S,(const char*)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getUserName'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getPassword of class  GameEntry */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_GameEntry_getPassword00
static int tolua_Cocos2d_GameEntry_getPassword00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"GameEntry",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  GameEntry* self = (GameEntry*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getPassword'", NULL);
#endif
  {
   const char* tolua_ret = (const char*)  self->getPassword();
   tolua_pushstring(tolua_S,(const char*)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getPassword'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getChannel of class  GameEntry */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_GameEntry_getChannel00
static int tolua_Cocos2d_GameEntry_getChannel00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"GameEntry",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  GameEntry* self = (GameEntry*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getChannel'", NULL);
#endif
  {
   const char* tolua_ret = (const char*)  self->getChannel();
   tolua_pushstring(tolua_S,(const char*)tolua_ret);
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

/* method: getSign of class  GameEntry */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_GameEntry_getSign00
static int tolua_Cocos2d_GameEntry_getSign00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"GameEntry",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  GameEntry* self = (GameEntry*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getSign'", NULL);
#endif
  {
   const char* tolua_ret = (const char*)  self->getSign();
   tolua_pushstring(tolua_S,(const char*)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getSign'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE


/* method: isUcPlatform of class  GameEntry */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_GameEntry_isUcPlatform00
static int tolua_Cocos2d_GameEntry_isUcPlatform00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"GameEntry",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  GameEntry* self = (GameEntry*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'isUcPlatform'", NULL);
#endif
  {
   bool tolua_ret = (bool)  self->isUcPlatform();
   tolua_pushboolean(tolua_S,(bool)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'isUcPlatform'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: gotoLoginWin of class  GameEntry */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_GameEntry_gotoLoginWin00
static int tolua_Cocos2d_GameEntry_gotoLoginWin00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"GameEntry",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  GameEntry* self = (GameEntry*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'gotoLoginWin'", NULL);
#endif
  {
   self->gotoLoginWin();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'gotoLoginWin'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE


/* method: exitGame of class  GameEntry */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_GameEntry_exitGame00
static int tolua_Cocos2d_GameEntry_exitGame00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"GameEntry",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  GameEntry* self = (GameEntry*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'exitGame'", NULL);
#endif
  {
   self->exitGame();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'exitGame'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setKeypadForUser of class  GameEntry */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_GameEntry_setKeypadForUser00
static int tolua_Cocos2d_GameEntry_setKeypadForUser00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"GameEntry",0,&tolua_err) ||
     !tolua_isboolean(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  GameEntry* self = (GameEntry*)  tolua_tousertype(tolua_S,1,0);
  bool enable = ((bool)  tolua_toboolean(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setKeypadForUser'", NULL);
#endif
  {
   self->setKeypadForUser(enable);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setKeypadForUser'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: isKeypadForUser of class  GameEntry */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_GameEntry_isKeypadForUser00
static int tolua_Cocos2d_GameEntry_isKeypadForUser00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"GameEntry",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  GameEntry* self = (GameEntry*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'isKeypadForUser'", NULL);
#endif
  {
   bool tolua_ret = (bool)  self->isKeypadForUser();
   tolua_pushboolean(tolua_S,(bool)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'isKeypadForUser'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE


/* get function: year of class  dateInfo */
#ifndef TOLUA_DISABLE_tolua_get_dateInfo_year
static int tolua_get_dateInfo_year(lua_State* tolua_S)
{
  dateInfo* self = (dateInfo*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in accessing variable 'year'",NULL);
#endif
  tolua_pushnumber(tolua_S,(lua_Number)self->year);
 return 1;
}
#endif //#ifndef TOLUA_DISABLE

/* set function: year of class  dateInfo */
#ifndef TOLUA_DISABLE_tolua_set_dateInfo_year
static int tolua_set_dateInfo_year(lua_State* tolua_S)
{
  dateInfo* self = (dateInfo*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  tolua_Error tolua_err;
  if (!self) tolua_error(tolua_S,"invalid 'self' in accessing variable 'year'",NULL);
  if (!tolua_isnumber(tolua_S,2,0,&tolua_err))
   tolua_error(tolua_S,"#vinvalid type in variable assignment.",&tolua_err);
#endif
  self->year = ((int)  tolua_tonumber(tolua_S,2,0))
;
 return 0;
}
#endif //#ifndef TOLUA_DISABLE

/* get function: mon of class  dateInfo */
#ifndef TOLUA_DISABLE_tolua_get_dateInfo_mon
static int tolua_get_dateInfo_mon(lua_State* tolua_S)
{
  dateInfo* self = (dateInfo*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in accessing variable 'mon'",NULL);
#endif
  tolua_pushnumber(tolua_S,(lua_Number)self->mon);
 return 1;
}
#endif //#ifndef TOLUA_DISABLE

/* set function: mon of class  dateInfo */
#ifndef TOLUA_DISABLE_tolua_set_dateInfo_mon
static int tolua_set_dateInfo_mon(lua_State* tolua_S)
{
  dateInfo* self = (dateInfo*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  tolua_Error tolua_err;
  if (!self) tolua_error(tolua_S,"invalid 'self' in accessing variable 'mon'",NULL);
  if (!tolua_isnumber(tolua_S,2,0,&tolua_err))
   tolua_error(tolua_S,"#vinvalid type in variable assignment.",&tolua_err);
#endif
  self->mon = ((int)  tolua_tonumber(tolua_S,2,0))
;
 return 0;
}
#endif //#ifndef TOLUA_DISABLE

/* get function: day of class  dateInfo */
#ifndef TOLUA_DISABLE_tolua_get_dateInfo_day
static int tolua_get_dateInfo_day(lua_State* tolua_S)
{
  dateInfo* self = (dateInfo*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in accessing variable 'day'",NULL);
#endif
  tolua_pushnumber(tolua_S,(lua_Number)self->day);
 return 1;
}
#endif //#ifndef TOLUA_DISABLE

/* set function: day of class  dateInfo */
#ifndef TOLUA_DISABLE_tolua_set_dateInfo_day
static int tolua_set_dateInfo_day(lua_State* tolua_S)
{
  dateInfo* self = (dateInfo*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  tolua_Error tolua_err;
  if (!self) tolua_error(tolua_S,"invalid 'self' in accessing variable 'day'",NULL);
  if (!tolua_isnumber(tolua_S,2,0,&tolua_err))
   tolua_error(tolua_S,"#vinvalid type in variable assignment.",&tolua_err);
#endif
  self->day = ((int)  tolua_tonumber(tolua_S,2,0))
;
 return 0;
}
#endif //#ifndef TOLUA_DISABLE

/* get function: hour of class  dateInfo */
#ifndef TOLUA_DISABLE_tolua_get_dateInfo_hour
static int tolua_get_dateInfo_hour(lua_State* tolua_S)
{
  dateInfo* self = (dateInfo*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in accessing variable 'hour'",NULL);
#endif
  tolua_pushnumber(tolua_S,(lua_Number)self->hour);
 return 1;
}
#endif //#ifndef TOLUA_DISABLE

/* set function: hour of class  dateInfo */
#ifndef TOLUA_DISABLE_tolua_set_dateInfo_hour
static int tolua_set_dateInfo_hour(lua_State* tolua_S)
{
  dateInfo* self = (dateInfo*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  tolua_Error tolua_err;
  if (!self) tolua_error(tolua_S,"invalid 'self' in accessing variable 'hour'",NULL);
  if (!tolua_isnumber(tolua_S,2,0,&tolua_err))
   tolua_error(tolua_S,"#vinvalid type in variable assignment.",&tolua_err);
#endif
  self->hour = ((int)  tolua_tonumber(tolua_S,2,0))
;
 return 0;
}
#endif //#ifndef TOLUA_DISABLE

/* get function: min of class  dateInfo */
#ifndef TOLUA_DISABLE_tolua_get_dateInfo_min
static int tolua_get_dateInfo_min(lua_State* tolua_S)
{
  dateInfo* self = (dateInfo*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in accessing variable 'min'",NULL);
#endif
  tolua_pushnumber(tolua_S,(lua_Number)self->min);
 return 1;
}
#endif //#ifndef TOLUA_DISABLE

/* set function: min of class  dateInfo */
#ifndef TOLUA_DISABLE_tolua_set_dateInfo_min
static int tolua_set_dateInfo_min(lua_State* tolua_S)
{
  dateInfo* self = (dateInfo*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  tolua_Error tolua_err;
  if (!self) tolua_error(tolua_S,"invalid 'self' in accessing variable 'min'",NULL);
  if (!tolua_isnumber(tolua_S,2,0,&tolua_err))
   tolua_error(tolua_S,"#vinvalid type in variable assignment.",&tolua_err);
#endif
  self->min = ((int)  tolua_tonumber(tolua_S,2,0))
;
 return 0;
}
#endif //#ifndef TOLUA_DISABLE

/* get function: sec of class  dateInfo */
#ifndef TOLUA_DISABLE_tolua_get_dateInfo_sec
static int tolua_get_dateInfo_sec(lua_State* tolua_S)
{
  dateInfo* self = (dateInfo*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in accessing variable 'sec'",NULL);
#endif
  tolua_pushnumber(tolua_S,(lua_Number)self->sec);
 return 1;
}
#endif //#ifndef TOLUA_DISABLE

/* set function: sec of class  dateInfo */
#ifndef TOLUA_DISABLE_tolua_set_dateInfo_sec
static int tolua_set_dateInfo_sec(lua_State* tolua_S)
{
  dateInfo* self = (dateInfo*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  tolua_Error tolua_err;
  if (!self) tolua_error(tolua_S,"invalid 'self' in accessing variable 'sec'",NULL);
  if (!tolua_isnumber(tolua_S,2,0,&tolua_err))
   tolua_error(tolua_S,"#vinvalid type in variable assignment.",&tolua_err);
#endif
  self->sec = ((int)  tolua_tonumber(tolua_S,2,0))
;
 return 0;
}
#endif //#ifndef TOLUA_DISABLE


/* method: GetDayTime of class  GameEntry */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_GameEntry_GetDayTime00
static int tolua_Cocos2d_GameEntry_GetDayTime00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"GameEntry",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  GameEntry* self = (GameEntry*)  tolua_tousertype(tolua_S,1,0);
  long timeOffset = ((long)  tolua_tonumber(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'GetDayTime'", NULL);
#endif
  {
   dateInfo tolua_ret = (dateInfo)  self->GetDayTime(timeOffset);
   {
#ifdef __cplusplus
    void* tolua_obj = Mtolua_new((dateInfo)(tolua_ret));
     tolua_pushusertype(tolua_S,tolua_obj,"dateInfo");
    tolua_register_gc(tolua_S,lua_gettop(tolua_S));
#else
    void* tolua_obj = tolua_copy(tolua_S,(void*)&tolua_ret,sizeof(dateInfo));
     tolua_pushusertype(tolua_S,tolua_obj,"dateInfo");
    tolua_register_gc(tolua_S,lua_gettop(tolua_S));
#endif
   }
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'GetDayTime'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE



/* Open function */
TOLUA_API int tolua_Cocos2d_open_for_GameEntry(lua_State* tolua_S)
{
 tolua_open(tolua_S);
 tolua_reg_types(tolua_S);
 tolua_module(tolua_S,NULL,0);
 tolua_beginmodule(tolua_S,NULL);

  #ifdef __cplusplus
  tolua_cclass(tolua_S,"dateInfo","dateInfo","",tolua_collect_dateInfo);
  #else
  tolua_cclass(tolua_S,"dateInfo","dateInfo","",NULL);
  #endif
  tolua_beginmodule(tolua_S,"dateInfo");
   tolua_variable(tolua_S,"year",tolua_get_dateInfo_year,tolua_set_dateInfo_year);
   tolua_variable(tolua_S,"mon",tolua_get_dateInfo_mon,tolua_set_dateInfo_mon);
   tolua_variable(tolua_S,"day",tolua_get_dateInfo_day,tolua_set_dateInfo_day);
   tolua_variable(tolua_S,"hour",tolua_get_dateInfo_hour,tolua_set_dateInfo_hour);
   tolua_variable(tolua_S,"min",tolua_get_dateInfo_min,tolua_set_dateInfo_min);
   tolua_variable(tolua_S,"sec",tolua_get_dateInfo_sec,tolua_set_dateInfo_sec);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"GameEntry","GameEntry","CCObject",NULL);
  tolua_beginmodule(tolua_S,"GameEntry");
   tolua_function(tolua_S,"instance",tolua_Cocos2d_GameEntry_instance00);
   tolua_function(tolua_S,"runGame",tolua_Cocos2d_GameEntry_runGame00);
   tolua_function(tolua_S,"runResUpdate",tolua_Cocos2d_GameEntry_runResUpdate00);
   tolua_function(tolua_S,"getUserName",tolua_Cocos2d_GameEntry_getUserName00);
   tolua_function(tolua_S,"getPassword",tolua_Cocos2d_GameEntry_getPassword00);
   tolua_function(tolua_S,"getChannel",tolua_Cocos2d_GameEntry_getChannel00);
   tolua_function(tolua_S,"getSign",tolua_Cocos2d_GameEntry_getSign00);   
   tolua_function(tolua_S,"isUcPlatform",tolua_Cocos2d_GameEntry_isUcPlatform00);
   tolua_function(tolua_S,"gotoLoginWin",tolua_Cocos2d_GameEntry_gotoLoginWin00);
   tolua_function(tolua_S,"exitGame",tolua_Cocos2d_GameEntry_exitGame00);
   tolua_function(tolua_S,"setKeypadForUser",tolua_Cocos2d_GameEntry_setKeypadForUser00);
   tolua_function(tolua_S,"isKeypadForUser",tolua_Cocos2d_GameEntry_isKeypadForUser00);
   tolua_function(tolua_S,"GetDayTime",tolua_Cocos2d_GameEntry_GetDayTime00);
   
  tolua_endmodule(tolua_S);

 tolua_endmodule(tolua_S);
 return 1;
}


