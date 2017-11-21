/*
** Lua binding: Cocos2d
** Generated automatically by tolua++-1.0.92 on 02/24/14 09:58:25.
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
#include "cocos2d.h"


#include "tolua++.h"
#include "CursorTextField.h"
using namespace cocos2d;



#ifdef __cplusplus
static int tolua_collect_ccColor3B (lua_State* tolua_S)
{
    ccColor3B* self = (ccColor3B*) tolua_tousertype(tolua_S,1,0);
    Mtolua_delete(self);
    return 0;
}
#endif

static int tolua_collect_CCSize (lua_State* tolua_S)
{
    CCSize* self = (CCSize*) tolua_tousertype(tolua_S,1,0);
    Mtolua_delete(self);
    return 0;
}

/* function to register type */
static void tolua_reg_types (lua_State* tolua_S)
{
 tolua_usertype(tolua_S,"ccColor3B");
 tolua_usertype(tolua_S,"CCTextFieldTTF");
 tolua_usertype(tolua_S,"CursorTextField");
}

#ifndef TOLUA_DISABLE_tolua_Cocos2d_CursorTextField_textFieldWithPlaceHolder00
static int tolua_Cocos2d_CursorTextField_textFieldWithPlaceHolder00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CursorTextField",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,4,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,5,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  const char* placeholder = ((const char*)  tolua_tostring(tolua_S,2,0));
  const char* fontName = ((const char*)  tolua_tostring(tolua_S,3,0));
  float fontSize = ((float)  tolua_tonumber(tolua_S,4,0));
  {
   CursorTextField* tolua_ret = (CursorTextField*)  CursorTextField::textFieldWithPlaceHolder(placeholder,fontName,fontSize);
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"CursorTextField");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'textFieldWithPlaceHolder'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setCursorColor of class  CursorTextField */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CursorTextField_setCursorColor00
static int tolua_Cocos2d_CursorTextField_setCursorColor00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CursorTextField",0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,2,&tolua_err) || !tolua_isusertype(tolua_S,2,"const ccColor3B",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CursorTextField* self = (CursorTextField*)  tolua_tousertype(tolua_S,1,0);
  const ccColor3B* color3 = ((const ccColor3B*)  tolua_tousertype(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setCursorColor'", NULL);
#endif
  {
   self->setCursorColor(*color3);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setCursorColor'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setDesignedSize of class  CursorTextField */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CursorTextField_setDesignedSize00
static int tolua_Cocos2d_CursorTextField_setDesignedSize00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CursorTextField",0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,2,&tolua_err) || !tolua_isusertype(tolua_S,2,"CCSize",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CursorTextField* self = (CursorTextField*)  tolua_tousertype(tolua_S,1,0);
  CCSize size = *((CCSize*)  tolua_tousertype(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setDesignedSize'", NULL);
#endif
  {
   self->setDesignedSize(size);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setDesignedSize'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getDesignedSize of class  CursorTextField */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CursorTextField_getDesignedSize00
static int tolua_Cocos2d_CursorTextField_getDesignedSize00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CursorTextField",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CursorTextField* self = (CursorTextField*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getDesignedSize'", NULL);
#endif
  {
   CCSize tolua_ret = (CCSize)  self->getDesignedSize();
   {
#ifdef __cplusplus
    void* tolua_obj = Mtolua_new((CCSize)(tolua_ret));
     tolua_pushusertype(tolua_S,tolua_obj,"CCSize");
    tolua_register_gc(tolua_S,lua_gettop(tolua_S));
#else
    void* tolua_obj = tolua_copy(tolua_S,(void*)&tolua_ret,sizeof(CCSize));
     tolua_pushusertype(tolua_S,tolua_obj,"CCSize");
    tolua_register_gc(tolua_S,lua_gettop(tolua_S));
#endif
   }
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getDesignedSize'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setEnabled of class  CursorTextField */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CursorTextField_setEnabled00
static int tolua_Cocos2d_CursorTextField_setEnabled00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CursorTextField",0,&tolua_err) ||
     !tolua_isboolean(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CursorTextField* self = (CursorTextField*)  tolua_tousertype(tolua_S,1,0);
  bool isEnable = ((bool)  tolua_toboolean(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setEnabled'", NULL);
#endif
  {
   self->setEnabled(isEnable);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setEnabled'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getEnabled of class  CursorTextField */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CursorTextField_getEnabled00
static int tolua_Cocos2d_CursorTextField_getEnabled00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CursorTextField",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CursorTextField* self = (CursorTextField*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getEnabled'", NULL);
#endif
  {
   bool tolua_ret = (bool)  self->getEnabled();
   tolua_pushboolean(tolua_S,(bool)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getEnabled'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: openIME of class  CursorTextField */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CursorTextField_openIME00
static int tolua_Cocos2d_CursorTextField_openIME00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CursorTextField",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CursorTextField* self = (CursorTextField*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'openIME'", NULL);
#endif
  {
   self->openIME();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'openIME'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: closeIME of class  CursorTextField */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CursorTextField_closeIME00
static int tolua_Cocos2d_CursorTextField_closeIME00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CursorTextField",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CursorTextField* self = (CursorTextField*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'closeIME'", NULL);
#endif
  {
   self->closeIME();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'closeIME'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE


/* Open function */
TOLUA_API int tolua_Cocos2d_open_for_textInput(lua_State* tolua_S)
{
 tolua_open(tolua_S);
 tolua_reg_types(tolua_S);
 tolua_module(tolua_S,NULL,0);
 tolua_beginmodule(tolua_S,NULL);
  tolua_cclass(tolua_S,"CursorTextField","CursorTextField","CCTextFieldTTF",NULL);
  tolua_cclass(tolua_S,"CursorTextField","CursorTextField","",NULL);
  
  tolua_beginmodule(tolua_S,"CursorTextField");
   tolua_function(tolua_S,"textFieldWithPlaceHolder",tolua_Cocos2d_CursorTextField_textFieldWithPlaceHolder00);
   tolua_function(tolua_S,"setCursorColor",tolua_Cocos2d_CursorTextField_setCursorColor00);
   tolua_function(tolua_S,"setDesignedSize",tolua_Cocos2d_CursorTextField_setDesignedSize00);
   tolua_function(tolua_S,"getDesignedSize",tolua_Cocos2d_CursorTextField_getDesignedSize00);   
   tolua_function(tolua_S,"setEnabled",tolua_Cocos2d_CursorTextField_setEnabled00);
   tolua_function(tolua_S,"getEnabled",tolua_Cocos2d_CursorTextField_getEnabled00);   
   tolua_function(tolua_S,"openIME",tolua_Cocos2d_CursorTextField_openIME00);
   tolua_function(tolua_S,"closeIME",tolua_Cocos2d_CursorTextField_closeIME00);
  tolua_endmodule(tolua_S);
  
 tolua_endmodule(tolua_S);
 return 1;
}

