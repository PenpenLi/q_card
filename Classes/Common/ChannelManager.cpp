#include "Common/ChannelManager.h"
#include "cocos2d.h"
using namespace cocos2d;
NS_GAME_FRM_BEGIN

std::string ChannelManager::getCurrentLoginChannel(){
  return LOGIN_CHANNEL;
}


std::string ChannelManager::getCurrentDownloadChannel(){
  return DOWNLOAD_CHANNEL;
}


NS_GAME_FRM_END
