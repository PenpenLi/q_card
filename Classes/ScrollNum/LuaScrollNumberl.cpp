/*
** Lua binding: Cocos2d
** Generated automatically by tolua++-1.0.92 on 11/04/13 16:58:41.
*/

#ifndef __cplusplus
#include "stdlib.h"
#endif


#include "tolua++.h"
#include "cocos2d.h"
#include "cocos-ext.h"
#include "ScrollNumberl.h"

using namespace cocos2d;
using namespace cocos2d::extension;

static int tolua_collect_ccColor3B (lua_State* tolua_S)
{
    ccColor3B* self = (ccColor3B*) tolua_tousertype(tolua_S,1,0);
    Mtolua_delete(self);
    return 0;
}


static void tolua_reg_types (lua_State* tolua_S)
{
     tolua_usertype(tolua_S,"ccColor3B");
     tolua_usertype(tolua_S,"ScrollNumberl");
}



/* method: createScrollLabel of class  ScrollNumberl */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_ScrollNumberl_createScrollLabel00
static int tolua_Cocos2d_ScrollNumberl_createScrollLabel00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"ScrollNumberl",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,3,0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,4,&tolua_err) || !tolua_isusertype(tolua_S,4,"ccColor3B",0,&tolua_err)) ||
     !tolua_isnumber(tolua_S,5,1,&tolua_err) ||
     !tolua_isnoobj(tolua_S,6,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  char* fontName = ((char*)  tolua_tostring(tolua_S,2,0));
  float fontSize = ((float)  tolua_tonumber(tolua_S,3,0));
  ccColor3B* color3 = ((ccColor3B*)  tolua_tousertype(tolua_S,4,0));
  int maxCols = ((int)  tolua_tonumber(tolua_S,5,8));
  {
   ScrollNumberl* tolua_ret = (ScrollNumberl*)  ScrollNumberl::createScrollLabel(fontName,fontSize,*color3,maxCols);
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"ScrollNumberl");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'createScrollLabel'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: createScrollImg of class  ScrollNumberl */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_ScrollNumberl_createScrollImg00
static int tolua_Cocos2d_ScrollNumberl_createScrollImg00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"ScrollNumberl",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,3,1,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  char* fileName = ((char*)  tolua_tostring(tolua_S,2,0));
  int maxCols = ((int)  tolua_tonumber(tolua_S,3,8));
  {
   ScrollNumberl* tolua_ret = (ScrollNumberl*)  ScrollNumberl::createScrollImg(fileName,maxCols);
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"ScrollNumberl");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'createScrollImg'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setNumber of class  ScrollNumberl */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_ScrollNumberl_setNumber00
static int tolua_Cocos2d_ScrollNumberl_setNumber00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"ScrollNumberl",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  ScrollNumberl* self = (ScrollNumberl*)  tolua_tousertype(tolua_S,1,0);
  int number = ((int)  tolua_tonumber(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setNumber'", NULL);
#endif
  {
   self->setNumber(number);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setNumber'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setNumberExt of class  ScrollNumberl */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_ScrollNumberl_setNumberExt00
static int tolua_Cocos2d_ScrollNumberl_setNumberExt00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"ScrollNumberl",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  ScrollNumberl* self = (ScrollNumberl*)  tolua_tousertype(tolua_S,1,0);
  int number = ((int)  tolua_tonumber(tolua_S,2,0));
  const char* strSuffix = ((const char*)  tolua_tostring(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setNumberExt'", NULL);
#endif
  {
   self->setNumberExt(number,strSuffix);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setNumberExt'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE









/* Open function */
TOLUA_API int tolua_Cocos2d_open_for_ScrollNum(lua_State* tolua_S)
{
 tolua_open(tolua_S);
 tolua_reg_types(tolua_S);
 tolua_module(tolua_S,NULL,0);
 tolua_beginmodule(tolua_S,NULL);

  #ifdef __cplusplus
  tolua_cclass(tolua_S,"ccColor3B","ccColor3B","",tolua_collect_ccColor3B);
  #else
  tolua_cclass(tolua_S,"ccColor3B","ccColor3B","",NULL);
  #endif
  
  tolua_cclass(tolua_S,"ScrollNumberl","ScrollNumberl","CCNode",NULL);
  tolua_beginmodule(tolua_S,"ScrollNumberl");
   tolua_function(tolua_S,"createScrollLabel",tolua_Cocos2d_ScrollNumberl_createScrollLabel00);
   tolua_function(tolua_S,"createScrollImg",tolua_Cocos2d_ScrollNumberl_createScrollImg00);
   tolua_function(tolua_S,"setNumber",tolua_Cocos2d_ScrollNumberl_setNumber00);
   tolua_function(tolua_S,"setNumberExt",tolua_Cocos2d_ScrollNumberl_setNumberExt00); 
  tolua_endmodule(tolua_S);

 tolua_endmodule(tolua_S);
 return 1;
}


