/*
** Lua binding: CCCommonFunctionHelp
** Generated automatically by tolua++-1.0.92 on 07/21/14 14:12:21.
*/

/****************************************************************************
 Copyright (c) 2011 cocos2d-x.org

 http://www.cocos2d-x.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
#include "CCommonFunctionHelp.h"
extern "C" {
#include "tolua_fix.h"
}

#include <map>
#include <string>
#include "cocos2d.h"
#include "CCLuaEngine.h"
#include "SimpleAudioEngine.h"
#include "cocos-ext.h"

using namespace cocos2d;
using namespace cocos2d::extension;
using namespace CocosDenshion;
USING_NS_GAME_FRM
/* Exported function */
TOLUA_API int  tolua_CCCommonFunctionHelp_open (lua_State* tolua_S);


/* function to register type */
static void tolua_reg_types (lua_State* tolua_S)
{
 tolua_usertype(tolua_S,"CCScale9Sprite");
 tolua_usertype(tolua_S,"CCTexture2D");
 tolua_usertype(tolua_S,"CCSprite");
 tolua_usertype(tolua_S,"CCImage");
 tolua_usertype(tolua_S,"CCCommonFunctionHelp");
 tolua_usertype(tolua_S,"CCGLProgram");
}

/* method: getProgram of class  CCCommonFunctionHelp */
#ifndef TOLUA_DISABLE_tolua_CCCommonFunctionHelp_CCCommonFunctionHelp_getProgram00
static int tolua_CCCommonFunctionHelp_CCCommonFunctionHelp_getProgram00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CCCommonFunctionHelp",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  char* shardName = ((char*)  tolua_tostring(tolua_S,2,0));
  {
   CCGLProgram* tolua_ret = (CCGLProgram*)  CCCommonFunctionHelp::getProgram(shardName);
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"CCGLProgram");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getProgram'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* get function: kCCShaderExt_PositionTextureGrayColor of class  CCCommonFunctionHelp */
#ifndef TOLUA_DISABLE_tolua_get_CCCommonFunctionHelp_kCCShaderExt_PositionTextureGrayColor
static int tolua_get_CCCommonFunctionHelp_kCCShaderExt_PositionTextureGrayColor(lua_State* tolua_S)
{
  tolua_pushstring(tolua_S,(const char*)CCCommonFunctionHelp::kCCShaderExt_PositionTextureGrayColor);
 return 1;
}
#endif //#ifndef TOLUA_DISABLE

/* method: graylightWithTexture2D of class  CCCommonFunctionHelp */
#ifndef TOLUA_DISABLE_tolua_CCCommonFunctionHelp_CCCommonFunctionHelp_graylightWithTexture2D00
static int tolua_CCCommonFunctionHelp_CCCommonFunctionHelp_graylightWithTexture2D00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CCCommonFunctionHelp",0,&tolua_err) ||
     !tolua_isusertype(tolua_S,2,"CCTexture2D",0,&tolua_err) ||
     !tolua_isboolean(tolua_S,3,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCTexture2D* tex = ((CCTexture2D*)  tolua_tousertype(tolua_S,2,0));
  bool isLight = ((bool)  tolua_toboolean(tolua_S,3,0));
  {
   CCImage* tolua_ret = (CCImage*)  CCCommonFunctionHelp::graylightWithTexture2D(tex,isLight);
    int nID = (tolua_ret) ? (int)tolua_ret->m_uID : -1;
    int* pLuaID = (tolua_ret) ? &tolua_ret->m_nLuaID : NULL;
    toluafix_pushusertype_ccobject(tolua_S, nID, pLuaID, (void*)tolua_ret,"CCImage");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'graylightWithTexture2D'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: graylightWithCCSprite of class  CCCommonFunctionHelp */
#ifndef TOLUA_DISABLE_tolua_CCCommonFunctionHelp_CCCommonFunctionHelp_graylightWithCCSprite00
static int tolua_CCCommonFunctionHelp_CCCommonFunctionHelp_graylightWithCCSprite00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CCCommonFunctionHelp",0,&tolua_err) ||
     !tolua_isusertype(tolua_S,2,"CCSprite",0,&tolua_err) ||
     !tolua_isboolean(tolua_S,3,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCSprite* oldSprite = ((CCSprite*)  tolua_tousertype(tolua_S,2,0));
  bool isLight = ((bool)  tolua_toboolean(tolua_S,3,0));
  {
   CCImage* tolua_ret = (CCImage*)  CCCommonFunctionHelp::graylightWithCCSprite(oldSprite,isLight);
    int nID = (tolua_ret) ? (int)tolua_ret->m_uID : -1;
    int* pLuaID = (tolua_ret) ? &tolua_ret->m_nLuaID : NULL;
    toluafix_pushusertype_ccobject(tolua_S, nID, pLuaID, (void*)tolua_ret,"CCImage");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'graylightWithCCSprite'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: createScal9SpriteWithImage of class  CCCommonFunctionHelp */
#ifndef TOLUA_DISABLE_tolua_CCCommonFunctionHelp_CCCommonFunctionHelp_createScal9SpriteWithImage00
static int tolua_CCCommonFunctionHelp_CCCommonFunctionHelp_createScal9SpriteWithImage00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CCCommonFunctionHelp",0,&tolua_err) ||
     !tolua_isusertype(tolua_S,2,"CCImage",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCImage* image = ((CCImage*)  tolua_tousertype(tolua_S,2,0));
  {
   CCScale9Sprite* tolua_ret = (CCScale9Sprite*)  CCCommonFunctionHelp::createScal9SpriteWithImage(image);
    int nID = (tolua_ret) ? (int)tolua_ret->m_uID : -1;
    int* pLuaID = (tolua_ret) ? &tolua_ret->m_nLuaID : NULL;
    toluafix_pushusertype_ccobject(tolua_S, nID, pLuaID, (void*)tolua_ret,"CCScale9Sprite");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'createScal9SpriteWithImage'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: createSpriteWithImage of class  CCCommonFunctionHelp */
#ifndef TOLUA_DISABLE_tolua_CCCommonFunctionHelp_CCCommonFunctionHelp_createSpriteWithImage00
static int tolua_CCCommonFunctionHelp_CCCommonFunctionHelp_createSpriteWithImage00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CCCommonFunctionHelp",0,&tolua_err) ||
     !tolua_isusertype(tolua_S,2,"CCImage",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCImage* image = ((CCImage*)  tolua_tousertype(tolua_S,2,0));
  {
   CCSprite* tolua_ret = (CCSprite*)  CCCommonFunctionHelp::createSpriteWithImage(image);
    int nID = (tolua_ret) ? (int)tolua_ret->m_uID : -1;
    int* pLuaID = (tolua_ret) ? &tolua_ret->m_nLuaID : NULL;
    toluafix_pushusertype_ccobject(tolua_S, nID, pLuaID, (void*)tolua_ret,"CCSprite");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'createSpriteWithImage'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: graylightScale9SpriteWithTexture2D of class  CCCommonFunctionHelp */
#ifndef TOLUA_DISABLE_tolua_CCCommonFunctionHelp_CCCommonFunctionHelp_graylightScale9SpriteWithTexture2D00
static int tolua_CCCommonFunctionHelp_CCCommonFunctionHelp_graylightScale9SpriteWithTexture2D00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CCCommonFunctionHelp",0,&tolua_err) ||
     !tolua_isusertype(tolua_S,2,"CCTexture2D",0,&tolua_err) ||
     !tolua_isboolean(tolua_S,3,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCTexture2D* tex = ((CCTexture2D*)  tolua_tousertype(tolua_S,2,0));
  bool isLight = ((bool)  tolua_toboolean(tolua_S,3,0));
  {
   CCScale9Sprite* tolua_ret = (CCScale9Sprite*)  CCCommonFunctionHelp::graylightScale9SpriteWithTexture2D(tex,isLight);
    int nID = (tolua_ret) ? (int)tolua_ret->m_uID : -1;
    int* pLuaID = (tolua_ret) ? &tolua_ret->m_nLuaID : NULL;
    toluafix_pushusertype_ccobject(tolua_S, nID, pLuaID, (void*)tolua_ret,"CCScale9Sprite");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'graylightScale9SpriteWithTexture2D'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: graylightSpriteWithTexture2D of class  CCCommonFunctionHelp */
#ifndef TOLUA_DISABLE_tolua_CCCommonFunctionHelp_CCCommonFunctionHelp_graylightSpriteWithTexture2D00
static int tolua_CCCommonFunctionHelp_CCCommonFunctionHelp_graylightSpriteWithTexture2D00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CCCommonFunctionHelp",0,&tolua_err) ||
     !tolua_isusertype(tolua_S,2,"CCTexture2D",0,&tolua_err) ||
     !tolua_isboolean(tolua_S,3,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCTexture2D* tex = ((CCTexture2D*)  tolua_tousertype(tolua_S,2,0));
  bool isLight = ((bool)  tolua_toboolean(tolua_S,3,0));
  {
   CCSprite* tolua_ret = (CCSprite*)  CCCommonFunctionHelp::graylightSpriteWithTexture2D(tex,isLight);
    int nID = (tolua_ret) ? (int)tolua_ret->m_uID : -1;
    int* pLuaID = (tolua_ret) ? &tolua_ret->m_nLuaID : NULL;
    toluafix_pushusertype_ccobject(tolua_S, nID, pLuaID, (void*)tolua_ret,"CCSprite");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'graylightSpriteWithTexture2D'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* Open function */
TOLUA_API int tolua_CCCommonFunctionHelp_open (lua_State* tolua_S)
{
 tolua_open(tolua_S);
 tolua_reg_types(tolua_S);
 tolua_module(tolua_S,NULL,0);
 tolua_beginmodule(tolua_S,NULL);
  tolua_cclass(tolua_S,"CCCommonFunctionHelp","CCCommonFunctionHelp","",NULL);
  tolua_beginmodule(tolua_S,"CCCommonFunctionHelp");
   tolua_function(tolua_S,"getProgram",tolua_CCCommonFunctionHelp_CCCommonFunctionHelp_getProgram00);
   tolua_variable(tolua_S,"kCCShaderExt_PositionTextureGrayColor",tolua_get_CCCommonFunctionHelp_kCCShaderExt_PositionTextureGrayColor,NULL);
   tolua_function(tolua_S,"graylightWithTexture2D",tolua_CCCommonFunctionHelp_CCCommonFunctionHelp_graylightWithTexture2D00);
   tolua_function(tolua_S,"graylightWithCCSprite",tolua_CCCommonFunctionHelp_CCCommonFunctionHelp_graylightWithCCSprite00);
   tolua_function(tolua_S,"createScal9SpriteWithImage",tolua_CCCommonFunctionHelp_CCCommonFunctionHelp_createScal9SpriteWithImage00);
   tolua_function(tolua_S,"createSpriteWithImage",tolua_CCCommonFunctionHelp_CCCommonFunctionHelp_createSpriteWithImage00);
   tolua_function(tolua_S,"graylightScale9SpriteWithTexture2D",tolua_CCCommonFunctionHelp_CCCommonFunctionHelp_graylightScale9SpriteWithTexture2D00);
   tolua_function(tolua_S,"graylightSpriteWithTexture2D",tolua_CCCommonFunctionHelp_CCCommonFunctionHelp_graylightSpriteWithTexture2D00);
  tolua_endmodule(tolua_S);
 tolua_endmodule(tolua_S);
 return 1;
}


#if defined(LUA_VERSION_NUM) && LUA_VERSION_NUM >= 501
 TOLUA_API int luaopen_CCCommonFunctionHelp (lua_State* tolua_S) {
 return tolua_CCCommonFunctionHelp_open(tolua_S);
};
#endif

