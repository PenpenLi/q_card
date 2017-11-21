/*
** Lua binding: ChannelManager
** Generated automatically by tolua++-1.0.92 on 08/08/14 11:19:21.
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
#include <string>
#include "Common/ChannelManager.h"
USING_NS_GAME_FRM
#include "tolua++.h"
extern "C" {
#include "tolua_fix.h"
}
#include "cocos2d.h"
#include "CCLuaEngine.h"
#include "LuaCocos2d.h"
#include <map>
#include <string>


using namespace cocos2d;


/* Exported function */
TOLUA_API int  tolua_ChannelManager_open (lua_State* tolua_S);


/* function to register type */
static void tolua_reg_types (lua_State* tolua_S)
{
 tolua_usertype(tolua_S,"ChannelManager");
}

/* method: getCurrentLoginChannel of class  ChannelManager */
#ifndef TOLUA_DISABLE_tolua_ChannelManager_ChannelManager_getCurrentLoginChannel00
static int tolua_ChannelManager_ChannelManager_getCurrentLoginChannel00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"ChannelManager",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   std::string tolua_ret = (std::string)  ChannelManager::getCurrentLoginChannel();
   tolua_pushcppstring(tolua_S,(const char*)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getCurrentLoginChannel'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getCurrentDownloadChannel of class  ChannelManager */
#ifndef TOLUA_DISABLE_tolua_ChannelManager_ChannelManager_getCurrentDownloadChannel00
static int tolua_ChannelManager_ChannelManager_getCurrentDownloadChannel00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"ChannelManager",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   std::string tolua_ret = (std::string)  ChannelManager::getCurrentDownloadChannel();
   tolua_pushcppstring(tolua_S,(const char*)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getCurrentDownloadChannel'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* Open function */
TOLUA_API int tolua_ChannelManager_open (lua_State* tolua_S)
{
 tolua_open(tolua_S);
 tolua_reg_types(tolua_S);
 tolua_module(tolua_S,NULL,0);
 tolua_beginmodule(tolua_S,NULL);
  tolua_cclass(tolua_S,"ChannelManager","ChannelManager","",NULL);
  tolua_beginmodule(tolua_S,"ChannelManager");
   tolua_function(tolua_S,"getCurrentLoginChannel",tolua_ChannelManager_ChannelManager_getCurrentLoginChannel00);
   tolua_function(tolua_S,"getCurrentDownloadChannel",tolua_ChannelManager_ChannelManager_getCurrentDownloadChannel00);
  tolua_endmodule(tolua_S);
 tolua_endmodule(tolua_S);
 return 1;
}


#if defined(LUA_VERSION_NUM) && LUA_VERSION_NUM >= 501
 TOLUA_API int luaopen_ChannelManager (lua_State* tolua_S) {
 return tolua_ChannelManager_open(tolua_S);
};
#endif

