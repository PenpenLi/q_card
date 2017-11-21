#include "payment/ChargeManager.h"
#include "cocos2d.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "payment/SdkPluginManager.h"
#endif

#if(CC_TARGET_PLATFORM == CC_PLATFORM_IOS)// appstore pay
#include "IapBridge.h"
#endif

NS_GAME_FRM_BEGIN

void ChargeManager::doCharge(const std::string& notifyUrl,
    const std::string& goodsId, const std::string& playerId,
    const std::string& paymentCode, const std::string& serverId,const std::string& params) {
#ifdef ANDROID_BAIDU
  SdkPluginManager::doCharge(notifyUrl, goodsId, playerId,paymentCode, serverId);
#endif

#ifdef ANDROID_WANDOUJIA
  SdkPluginManager::doCharge(notifyUrl, goodsId, playerId,paymentCode, serverId);
#endif

#ifdef ANDROID_360
  SdkPluginManager::doCharge(notifyUrl, goodsId, playerId,paymentCode, serverId);
#endif

#ifdef ANDROID_GFAN
  SdkPluginManager::doCharge(notifyUrl, goodsId, playerId,paymentCode, serverId);
#endif

#ifdef ANDROID_ANZHI
  SdkPluginManager::doCharge(notifyUrl, goodsId, playerId,paymentCode, serverId);
#endif

#ifdef ANDROID_MI
  SdkPluginManager::doCharge(notifyUrl, goodsId, playerId,paymentCode, serverId,params);
#endif

#ifdef ANDROID_UC
  SdkPluginManager::doCharge(notifyUrl, goodsId, playerId,paymentCode, serverId,params);
#endif

#ifdef ANDROID_ALIPAY
  SdkPluginManager::doCharge(notifyUrl, goodsId, playerId,paymentCode, serverId);
#endif

#ifdef ANDROID_OPPO
  SdkPluginManager::doCharge(notifyUrl, goodsId, playerId,paymentCode, serverId);
#endif

#ifdef ANDROID_GOOGLEPLAY_JP
  SdkPluginManager::doCharge(notifyUrl, goodsId, playerId,paymentCode, serverId);
#endif

#if(CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    IapBridge::purchase(URL_DS_PAYMENT, notifyUrl, playerId, paymentCode, serverId, GAME_NAME,ORDER_SIGN_KEY);
#endif
}

void ChargeManager::doCharge(const std::string& notifyUrl,const std::string& goodsId,const std::string& playerId, const std::string& paymentCode,const std::string& serverId,const std::string& channelId,const std::string& params){
#ifdef ANDROID_GOOGLEPLAY_CT
  SdkPluginManager::doCharge(notifyUrl, goodsId, playerId,paymentCode, serverId,channelId,params);
#endif
#ifdef ANDROID_GOOGLEPLAY_SC
  SdkPluginManager::doCharge(notifyUrl, goodsId, playerId,paymentCode, serverId,channelId,params);
#endif
}
NS_GAME_FRM_END
