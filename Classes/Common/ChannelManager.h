#ifndef CHANNEL_MANAGER_H_
#define CHANNEL_MANAGER_H_
#include <string>
#include "Common/CommonDefine.h"
NS_GAME_FRM_BEGIN
class ChannelManager {
public:
  static std::string getCurrentLoginChannel();
  static std::string getCurrentDownloadChannel();
};
NS_GAME_FRM_END
#endif /* CHANNEL_MANAGER_H_ */

