/********************************************************************
	created:	2014/01/17
	created:	17:1:2014   11:55
	file base:	NetLua
	file ext:	h
	author:		Kevin
	
*********************************************************************/

#ifndef _H_NETLUA_H_  
#define _H_NETLUA_H_  

#include "Common/CommonDefine.h"

#define ENABLE_LUA_BINDING 1

#if ENABLE_LUA_BINDING
#if __cplusplus
extern "C" {
#endif // #if __cplusplus
#include "lauxlib.h"
#if __cplusplus
}
#endif // #if __cplusplus
#endif // #if ENABLE_LUA_BINDING


NS_GAME_FRM_BEGIN

namespace NetLua
{

extern void registWithLua(lua_State *L);

};



NS_GAME_FRM_END //namespace


#endif //_H_NETLUA_H_  