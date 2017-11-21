#ifndef CHARGE_MANAGER_H_
#define CHARGE_MANAGER_H_
#include <string>
#include "Common/CommonDefine.h"
NS_GAME_FRM_BEGIN
class ChargeManager{
  public:
    static void  doCharge(const std::string& notifyUrl,const std::string& goodsId,const std::string& playerId, const std::string& paymentCode,const std::string& serverId,const std::string& params="");
    static void  doCharge(const std::string& notifyUrl,const std::string& goodsId,const std::string& playerId, const std::string& paymentCode,const std::string& serverId,const std::string& channelId,const std::string& params);
};
NS_GAME_FRM_END
#endif
