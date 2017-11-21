#include "Common/CFunctionToLua.h"
NS_GAME_FRM_BEGIN
bool CFunctionToLua::isDebug()
{
	#ifdef LUA_DEBUG
        return true;
	#endif
	return false;
}
NS_GAME_FRM_END