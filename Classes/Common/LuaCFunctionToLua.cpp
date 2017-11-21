/*
** Lua binding: CFunctionToLua
** Generated automatically by tolua++-1.0.92 on 12/25/14 10:35:47.
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


#ifndef __cplusplus
#include "stdlib.h"
#endif
#include <map>
#include <string>
#include "tolua++.h"
extern "C" {
#include "tolua_fix.h"
}
#include "cocos2d.h"
#include "CCLuaEngine.h"
#include "LuaCocos2d.h"
#include "Common/CFunctionToLua.h"
#include "Common/CommonDefine.h"

using namespace cocos2d;
using namespace cocos2d::extension;

USING_NS_GAME_FRM

/* Exported function */
TOLUA_API int  tolua_CFunctionToLua_open (lua_State* tolua_S);


/* function to register type */
static void tolua_reg_types (lua_State* tolua_S)
{
 tolua_usertype(tolua_S,"CFunctionToLua");
}

/* method: isDebug of class  CFunctionToLua */
#ifndef TOLUA_DISABLE_tolua_CFunctionToLua_CFunctionToLua_isDebug00
static int tolua_CFunctionToLua_CFunctionToLua_isDebug00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CFunctionToLua",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   bool tolua_ret = (bool)  CFunctionToLua::isDebug();
   tolua_pushboolean(tolua_S,(bool)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'isDebug'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* Open function */
TOLUA_API int tolua_CFunctionToLua_open (lua_State* tolua_S)
{
 tolua_open(tolua_S);
 tolua_reg_types(tolua_S);
 tolua_module(tolua_S,NULL,0);
 tolua_beginmodule(tolua_S,NULL);
  tolua_cclass(tolua_S,"CFunctionToLua","CFunctionToLua","",NULL);
  tolua_beginmodule(tolua_S,"CFunctionToLua");
   tolua_function(tolua_S,"isDebug",tolua_CFunctionToLua_CFunctionToLua_isDebug00);
  tolua_endmodule(tolua_S);
 tolua_endmodule(tolua_S);
 return 1;
}


#if defined(LUA_VERSION_NUM) && LUA_VERSION_NUM >= 501
 TOLUA_API int luaopen_CFunctionToLua (lua_State* tolua_S) {
 return tolua_CFunctionToLua_open(tolua_S);
};
#endif

