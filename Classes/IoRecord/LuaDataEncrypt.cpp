/*
** Lua binding: Cocos2d
** Generated automatically by tolua++-1.0.92 on 11/04/13 16:58:41.
*/

#ifndef __cplusplus
#include "stdlib.h"
#endif


#include "tolua++.h"


#include "DataEncrypt.h"


static void tolua_reg_types (lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"DataEncrypt");
}


/* method: sharedParser of class  DataEncrypt */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_DataEncrypt_sharedParser00
static int tolua_Cocos2d_DataEncrypt_sharedParser00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"DataEncrypt",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   DataEncrypt* tolua_ret = (DataEncrypt*)  DataEncrypt::sharedParser();
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"DataEncrypt");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'sharedParser'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: byteEncode of class  DataEncrypt */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_DataEncrypt_byteEncode00
static int tolua_Cocos2d_DataEncrypt_byteEncode00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"DataEncrypt",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,3,0,&tolua_err) ||
     !tolua_isstring(tolua_S,4,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,5,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,6,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  DataEncrypt* self = (DataEncrypt*)  tolua_tousertype(tolua_S,1,0);
  unsigned char* inBuff = ((unsigned char*)  tolua_tostring(tolua_S,2,0));
  unsigned int inBufLen = ((unsigned int)  tolua_tonumber(tolua_S,3,0));
  unsigned char* outBuff = ((unsigned char*)  tolua_tostring(tolua_S,4,0));
  unsigned int outLen = ((unsigned int)  tolua_tonumber(tolua_S,5,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'byteEncode'", NULL);
#endif
  {
   bool tolua_ret = (bool)  self->byteEncode(inBuff,inBufLen,outBuff,outLen);
   tolua_pushboolean(tolua_S,(bool)tolua_ret);
   tolua_pushnumber(tolua_S,(lua_Number)outLen);
  }
 }
 return 2;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'byteEncode'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: byteDecode of class  DataEncrypt */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_DataEncrypt_byteDecode00
static int tolua_Cocos2d_DataEncrypt_byteDecode00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"DataEncrypt",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,3,0,&tolua_err) ||
     !tolua_isstring(tolua_S,4,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,5,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,6,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  DataEncrypt* self = (DataEncrypt*)  tolua_tousertype(tolua_S,1,0);
  unsigned char* inBuff = ((unsigned char*)  tolua_tostring(tolua_S,2,0));
  unsigned int inBufLen = ((unsigned int)  tolua_tonumber(tolua_S,3,0));
  unsigned char* outBuff = ((unsigned char*)  tolua_tostring(tolua_S,4,0));
  unsigned int outLen = ((unsigned int)  tolua_tonumber(tolua_S,5,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'byteDecode'", NULL);
#endif
  {
   bool tolua_ret = (bool)  self->byteDecode(inBuff,inBufLen,outBuff,outLen);
   tolua_pushboolean(tolua_S,(bool)tolua_ret);
   tolua_pushnumber(tolua_S,(lua_Number)outLen);
  }
 }
 return 2;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'byteDecode'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: fileEncode of class  DataEncrypt */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_DataEncrypt_fileEncode00
static int tolua_Cocos2d_DataEncrypt_fileEncode00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"DataEncrypt",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  DataEncrypt* self = (DataEncrypt*)  tolua_tousertype(tolua_S,1,0);
  char* fileName = ((char*)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'fileEncode'", NULL);
#endif
  {
   bool tolua_ret = (bool)  self->fileEncode(fileName);
   tolua_pushboolean(tolua_S,(bool)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'fileEncode'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: fileDecode of class  DataEncrypt */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_DataEncrypt_fileDecode00
static int tolua_Cocos2d_DataEncrypt_fileDecode00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"DataEncrypt",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  DataEncrypt* self = (DataEncrypt*)  tolua_tousertype(tolua_S,1,0);
  char* fileName = ((char*)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'fileDecode'", NULL);
#endif
  {
   bool tolua_ret = (bool)  self->fileDecode(fileName);
   tolua_pushboolean(tolua_S,(bool)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'fileDecode'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: encode of class  DataEncrypt */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_DataEncrypt_encode00
static int tolua_Cocos2d_DataEncrypt_encode00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"DataEncrypt",0,&tolua_err) ||
     !tolua_iscppstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  DataEncrypt* self = (DataEncrypt*)  tolua_tousertype(tolua_S,1,0);
  std::string str = ((std::string)  tolua_tocppstring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'encode'", NULL);
#endif
  {
   self->encode(str);
   tolua_pushcppstring(tolua_S,(const char*)str);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'encode'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: decode of class  DataEncrypt */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_DataEncrypt_decode00
static int tolua_Cocos2d_DataEncrypt_decode00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"DataEncrypt",0,&tolua_err) ||
     !tolua_iscppstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  DataEncrypt* self = (DataEncrypt*)  tolua_tousertype(tolua_S,1,0);
  std::string str = ((std::string)  tolua_tocppstring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'decode'", NULL);
#endif
  {
   self->decode(str);
   tolua_pushcppstring(tolua_S,(const char*)str);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'decode'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE







/* Open function */
TOLUA_API int tolua_Cocos2d_open_for_DataEncrypt(lua_State* tolua_S)
{
 tolua_open(tolua_S);
 tolua_reg_types(tolua_S);
 tolua_module(tolua_S,NULL,0);
 tolua_beginmodule(tolua_S,NULL);

  tolua_cclass(tolua_S,"DataEncrypt","DataEncrypt","",NULL);
  tolua_beginmodule(tolua_S,"DataEncrypt");
   tolua_function(tolua_S,"sharedParser",tolua_Cocos2d_DataEncrypt_sharedParser00);
   tolua_function(tolua_S,"byteEncode",tolua_Cocos2d_DataEncrypt_byteEncode00);
   tolua_function(tolua_S,"byteDecode",tolua_Cocos2d_DataEncrypt_byteDecode00);
   tolua_function(tolua_S,"fileEncode",tolua_Cocos2d_DataEncrypt_fileEncode00);
   tolua_function(tolua_S,"fileDecode",tolua_Cocos2d_DataEncrypt_fileDecode00);
   tolua_function(tolua_S,"encode",tolua_Cocos2d_DataEncrypt_encode00);
   tolua_function(tolua_S,"decode",tolua_Cocos2d_DataEncrypt_decode00);
  tolua_endmodule(tolua_S);


 tolua_endmodule(tolua_S);
 return 1;
}


