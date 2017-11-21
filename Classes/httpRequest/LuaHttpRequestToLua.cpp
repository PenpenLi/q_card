/*
** Lua binding: Cocos2d
** Generated automatically by tolua++-1.0.92 on 08/21/14 18:12:50.
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

extern "C" {
#include "tolua_fix.h"
}

#include <map>
#include <string>
#include "LuaHttpRequest.h"
#include "cocos2d.h"
#include "CCLuaEngine.h"
#include "SimpleAudioEngine.h"
#include "cocos-ext.h"

using namespace cocos2d;
using namespace cocos2d::extension;
using namespace CocosDenshion;



#include "LuaCocos2d.h"

/* function to register type */
static void tolua_reg_types (lua_State* tolua_S)
{
 tolua_usertype(tolua_S,"CCLuaHttpRequest");
 
 tolua_usertype(tolua_S,"CCHttpRequest");
 tolua_usertype(tolua_S,"CCHttpClient");
 tolua_usertype(tolua_S,"CCObject");
}

/* method: getInstance of class  CCHttpClient */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCHttpClient_getInstance00
static int tolua_Cocos2d_CCHttpClient_getInstance00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CCHttpClient",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   CCHttpClient* tolua_ret = (CCHttpClient*)  CCHttpClient::getInstance();
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"CCHttpClient");
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

/* method: destroyInstance of class  CCHttpClient */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCHttpClient_destroyInstance00
static int tolua_Cocos2d_CCHttpClient_destroyInstance00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CCHttpClient",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   CCHttpClient::destroyInstance();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'destroyInstance'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: send of class  CCHttpClient */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCHttpClient_send00
static int tolua_Cocos2d_CCHttpClient_send00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCHttpClient",0,&tolua_err) ||
     !tolua_isusertype(tolua_S,2,"CCHttpRequest",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCHttpClient* self = (CCHttpClient*)  tolua_tousertype(tolua_S,1,0);
  CCHttpRequest* request = ((CCHttpRequest*)  tolua_tousertype(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'send'", NULL);
#endif
  {
   self->send(request);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'send'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setTimeoutForConnect of class  CCHttpClient */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCHttpClient_setTimeoutForConnect00
static int tolua_Cocos2d_CCHttpClient_setTimeoutForConnect00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCHttpClient",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCHttpClient* self = (CCHttpClient*)  tolua_tousertype(tolua_S,1,0);
  int value = ((int)  tolua_tonumber(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setTimeoutForConnect'", NULL);
#endif
  {
   self->setTimeoutForConnect(value);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setTimeoutForConnect'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getTimeoutForConnect of class  CCHttpClient */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCHttpClient_getTimeoutForConnect00
static int tolua_Cocos2d_CCHttpClient_getTimeoutForConnect00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCHttpClient",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCHttpClient* self = (CCHttpClient*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getTimeoutForConnect'", NULL);
#endif
  {
   int tolua_ret = (int)  self->getTimeoutForConnect();
   tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getTimeoutForConnect'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setTimeoutForRead of class  CCHttpClient */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCHttpClient_setTimeoutForRead00
static int tolua_Cocos2d_CCHttpClient_setTimeoutForRead00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCHttpClient",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCHttpClient* self = (CCHttpClient*)  tolua_tousertype(tolua_S,1,0);
  int value = ((int)  tolua_tonumber(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setTimeoutForRead'", NULL);
#endif
  {
   self->setTimeoutForRead(value);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setTimeoutForRead'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getTimeoutForRead of class  CCHttpClient */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCHttpClient_getTimeoutForRead00
static int tolua_Cocos2d_CCHttpClient_getTimeoutForRead00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCHttpClient",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCHttpClient* self = (CCHttpClient*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getTimeoutForRead'", NULL);
#endif
  {
   int tolua_ret = (int)  self->getTimeoutForRead();
   tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getTimeoutForRead'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setRequestType of class  CCHttpRequest */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCHttpRequest_setRequestType00
static int tolua_Cocos2d_CCHttpRequest_setRequestType00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCHttpRequest",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCHttpRequest* self = (CCHttpRequest*)  tolua_tousertype(tolua_S,1,0);
  CCHttpRequest::HttpRequestType type = ((CCHttpRequest::HttpRequestType) (int)  tolua_tonumber(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setRequestType'", NULL);
#endif
  {
   self->setRequestType(type);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setRequestType'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getRequestType of class  CCHttpRequest */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCHttpRequest_getRequestType00
static int tolua_Cocos2d_CCHttpRequest_getRequestType00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCHttpRequest",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCHttpRequest* self = (CCHttpRequest*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getRequestType'", NULL);
#endif
  {
   CCHttpRequest::HttpRequestType tolua_ret = (CCHttpRequest::HttpRequestType)  self->getRequestType();
   tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getRequestType'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setUrl of class  CCHttpRequest */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCHttpRequest_setUrl00
static int tolua_Cocos2d_CCHttpRequest_setUrl00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCHttpRequest",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCHttpRequest* self = (CCHttpRequest*)  tolua_tousertype(tolua_S,1,0);
  const char* url = ((const char*)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setUrl'", NULL);
#endif
  {
   self->setUrl(url);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setUrl'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getUrl of class  CCHttpRequest */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCHttpRequest_getUrl00
static int tolua_Cocos2d_CCHttpRequest_getUrl00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCHttpRequest",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCHttpRequest* self = (CCHttpRequest*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getUrl'", NULL);
#endif
  {
   const char* tolua_ret = (const char*)  self->getUrl();
   tolua_pushstring(tolua_S,(const char*)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getUrl'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setRequestData of class  CCHttpRequest */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCHttpRequest_setRequestData00
static int tolua_Cocos2d_CCHttpRequest_setRequestData00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCHttpRequest",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,3,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCHttpRequest* self = (CCHttpRequest*)  tolua_tousertype(tolua_S,1,0);
  const char* buffer = ((const char*)  tolua_tostring(tolua_S,2,0));
  unsigned int len = ((unsigned int)  tolua_tonumber(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setRequestData'", NULL);
#endif
  {
   self->setRequestData(buffer,len);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setRequestData'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getRequestData of class  CCHttpRequest */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCHttpRequest_getRequestData00
static int tolua_Cocos2d_CCHttpRequest_getRequestData00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCHttpRequest",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCHttpRequest* self = (CCHttpRequest*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getRequestData'", NULL);
#endif
  {
   char* tolua_ret = (char*)  self->getRequestData();
   tolua_pushstring(tolua_S,(const char*)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getRequestData'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getRequestDataSize of class  CCHttpRequest */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCHttpRequest_getRequestDataSize00
static int tolua_Cocos2d_CCHttpRequest_getRequestDataSize00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCHttpRequest",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCHttpRequest* self = (CCHttpRequest*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getRequestDataSize'", NULL);
#endif
  {
   int tolua_ret = (int)  self->getRequestDataSize();
   tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getRequestDataSize'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setTag of class  CCHttpRequest */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCHttpRequest_setTag00
static int tolua_Cocos2d_CCHttpRequest_setTag00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCHttpRequest",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCHttpRequest* self = (CCHttpRequest*)  tolua_tousertype(tolua_S,1,0);
  const char* tag = ((const char*)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setTag'", NULL);
#endif
  {
   self->setTag(tag);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setTag'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getTag of class  CCHttpRequest */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCHttpRequest_getTag00
static int tolua_Cocos2d_CCHttpRequest_getTag00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCHttpRequest",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCHttpRequest* self = (CCHttpRequest*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getTag'", NULL);
#endif
  {
   const char* tolua_ret = (const char*)  self->getTag();
   tolua_pushstring(tolua_S,(const char*)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getTag'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setResponseScriptCallback of class  CCLuaHttpRequest */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCLuaHttpRequest_setResponseScriptCallback00
static int tolua_Cocos2d_CCLuaHttpRequest_setResponseScriptCallback00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCLuaHttpRequest",0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,2,&tolua_err) || !toluafix_isfunction(tolua_S,2,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCLuaHttpRequest* self = (CCLuaHttpRequest*)  tolua_tousertype(tolua_S,1,0);
  LUA_FUNCTION aHandler = (  toluafix_ref_function(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setResponseScriptCallback'", NULL);
#endif
  {
   self->setResponseScriptCallback(aHandler);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setResponseScriptCallback'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: create of class  CCLuaHttpRequest */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCLuaHttpRequest_create00
static int tolua_Cocos2d_CCLuaHttpRequest_create00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CCLuaHttpRequest",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   CCLuaHttpRequest* tolua_ret = (CCLuaHttpRequest*)  CCLuaHttpRequest::create();
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"CCLuaHttpRequest");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'create'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: mkdirs of class  CCLuaHttpRequest */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCLuaHttpRequest_mkdirs00
static int tolua_Cocos2d_CCLuaHttpRequest_mkdirs00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CCLuaHttpRequest",0,&tolua_err) ||
     !tolua_iscppstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  std::string aDir = ((std::string)  tolua_tocppstring(tolua_S,2,0));
  {
   bool tolua_ret = (bool)  CCLuaHttpRequest::mkdirs(aDir);
   tolua_pushboolean(tolua_S,(bool)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'mkdirs'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* Open function */
TOLUA_API int tolua_Cocos2d_open_for_HttpRequest (lua_State* tolua_S)
{
 tolua_open(tolua_S);
 tolua_reg_types(tolua_S);
 tolua_module(tolua_S,NULL,0);
 tolua_beginmodule(tolua_S,NULL);
  tolua_cclass(tolua_S,"CCHttpClient","CCHttpClient","CCObject",NULL);
  tolua_beginmodule(tolua_S,"CCHttpClient");
   tolua_function(tolua_S,"getInstance",tolua_Cocos2d_CCHttpClient_getInstance00);
   tolua_function(tolua_S,"destroyInstance",tolua_Cocos2d_CCHttpClient_destroyInstance00);
   tolua_function(tolua_S,"send",tolua_Cocos2d_CCHttpClient_send00);
   tolua_function(tolua_S,"setTimeoutForConnect",tolua_Cocos2d_CCHttpClient_setTimeoutForConnect00);
   tolua_function(tolua_S,"getTimeoutForConnect",tolua_Cocos2d_CCHttpClient_getTimeoutForConnect00);
   tolua_function(tolua_S,"setTimeoutForRead",tolua_Cocos2d_CCHttpClient_setTimeoutForRead00);
   tolua_function(tolua_S,"getTimeoutForRead",tolua_Cocos2d_CCHttpClient_getTimeoutForRead00);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"CCHttpRequest","CCHttpRequest","CCObject",NULL);
  tolua_beginmodule(tolua_S,"CCHttpRequest");
   tolua_constant(tolua_S,"kHttpGet",CCHttpRequest::kHttpGet);
   tolua_constant(tolua_S,"kHttpPost",CCHttpRequest::kHttpPost);
   tolua_constant(tolua_S,"kHttpPut",CCHttpRequest::kHttpPut);
   tolua_constant(tolua_S,"kHttpDelete",CCHttpRequest::kHttpDelete);
   tolua_constant(tolua_S,"kHttpUnkown",CCHttpRequest::kHttpUnkown);
   tolua_function(tolua_S,"setRequestType",tolua_Cocos2d_CCHttpRequest_setRequestType00);
   tolua_function(tolua_S,"getRequestType",tolua_Cocos2d_CCHttpRequest_getRequestType00);
   tolua_function(tolua_S,"setUrl",tolua_Cocos2d_CCHttpRequest_setUrl00);
   tolua_function(tolua_S,"getUrl",tolua_Cocos2d_CCHttpRequest_getUrl00);
   tolua_function(tolua_S,"setRequestData",tolua_Cocos2d_CCHttpRequest_setRequestData00);
   tolua_function(tolua_S,"getRequestData",tolua_Cocos2d_CCHttpRequest_getRequestData00);
   tolua_function(tolua_S,"getRequestDataSize",tolua_Cocos2d_CCHttpRequest_getRequestDataSize00);
   tolua_function(tolua_S,"setTag",tolua_Cocos2d_CCHttpRequest_setTag00);
   tolua_function(tolua_S,"getTag",tolua_Cocos2d_CCHttpRequest_getTag00);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"CCLuaHttpRequest","CCLuaHttpRequest","CCHttpRequest",NULL);
  tolua_beginmodule(tolua_S,"CCLuaHttpRequest");
   tolua_function(tolua_S,"setResponseScriptCallback",tolua_Cocos2d_CCLuaHttpRequest_setResponseScriptCallback00);
   tolua_function(tolua_S,"create",tolua_Cocos2d_CCLuaHttpRequest_create00);
   tolua_function(tolua_S,"mkdirs",tolua_Cocos2d_CCLuaHttpRequest_mkdirs00);
  tolua_endmodule(tolua_S);
 tolua_endmodule(tolua_S);
 return 1;
}


#if defined(LUA_VERSION_NUM) && LUA_VERSION_NUM >= 501
 TOLUA_API int luaopen_HttpRequest (lua_State* tolua_S) {
 return tolua_Cocos2d_open_for_HttpRequest(tolua_S);
};
#endif

