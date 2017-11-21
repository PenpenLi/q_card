/********************************************************************
	created:	2014/01/17
	created:	17:1:2014   11:58
	file base:	NetLua
	file ext:	cpp
	author:		Kevin
	
*********************************************************************/

#include "NetLua.h"
#include "NetManager.h"
#include "cocos2d.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "payment/ChargeManager.h"
#endif


NS_GAME_FRM_BEGIN

namespace NetLua
{

  static int c_setup_login_server(lua_State *L)
  {
    size_t len;
    const char* cstr = lua_tolstring(L, 1, &len);
    std::string ip(cstr, len);
    int port = lua_tointeger(L,2);

    CCLOG("Call setup from lua[ ip:%s,port:%d]",ip.c_str(),port);
    NetManager::Instance()->setupLoginServer(ip,port);

    return 0;
  }

  static int c_setup_game_server(lua_State *L)
  {
    size_t len;
    const char* cstr = lua_tolstring(L, 1, &len);
    std::string ip(cstr, len);
    int port = lua_tointeger(L,2);

    CCLOG("Call setup from lua[ ip:%s,port:%d]",ip.c_str(),port);
    NetManager::Instance()->setupGameServer(ip,port);

    return 0;
  }

  static int c_send_action(lua_State *L)
  {
    const NetActionEnum action = (NetActionEnum)lua_tointeger(L,1);
    const int msgId = lua_tointeger(L,2);
    const int userId = lua_tointeger(L,3);
    size_t len;
    const char* cstr = lua_tolstring(L, 4, &len);
    if (msgId != 1000) {
      CCLOG("Get send action from lua[ action:%d,msgId:%d,data len:%d]",action,msgId,len);
	}
    PtrNetAction net_action = PtrNetAction(new NetAction(action,msgId,userId,cstr,len));
    NetManager::Instance()->appendAction(net_action);

    return 0;
  }

  static int c_pump_action(lua_State *L)
  {
    PtrNetNotify notify = NetManager::Instance()->pickNotify();
    if(notify)
    {
      lua_pushnumber(L,notify->action);
      lua_pushnumber(L,notify->msgId);
      lua_pushlstring(L,notify->data.c_str(),notify->data.size());
      return 3;
    }

	return 0;
  }

  static int c_pay_item(lua_State *L)
  {
    size_t len;
    std::string goodsId = std::string(lua_tolstring(L,1,&len));
    std::string playerId = std::string(lua_tolstring(L,2,&len));
    std::string paymentCode = std::string(lua_tolstring(L,3,&len));
    std::string serverId = std::string(lua_tolstring(L,4,&len));
    std::string notifyUrl = URL_PAY_NOTIFY + "/payment/notifyreceiver";
    std::string params=std::string(lua_tolstring(L,6,&len));
#ifdef ANDROID_GOOGLEPLAY_CT
    std::string channel=std::string(lua_tolstring(L,5,&len));
    ChargeManager::doCharge(notifyUrl,goodsId,playerId,paymentCode,serverId,channel,params);
    return 0;
#endif
#ifdef ANDROID_GOOGLEPLAY_SC
    std::string channel=std::string(lua_tolstring(L,5,&len));
    ChargeManager::doCharge(notifyUrl,goodsId,playerId,paymentCode,serverId,channel,params);
    return 0;
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS||CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    ChargeManager::doCharge(notifyUrl,goodsId,playerId,paymentCode,serverId,params);
#endif
    return 0;	
  }

  extern void registWithLua(lua_State *L)
  {
    lua_register(L, "c_send_action", c_send_action);
    lua_register(L, "c_pump_action", c_pump_action);
    lua_register(L, "c_setup_login_server", c_setup_login_server);  
    lua_register(L, "c_setup_game_server", c_setup_game_server);  
	  lua_register(L, "c_pay_item", c_pay_item);
  }

};
NS_GAME_FRM_END //namespace
