#ifndef _H_NETMANAGER_H_
#define _H_NETMANAGER_H_



#include "cocos2d.h"
#include "Common/CommonDefine.h"
#include "Common/Singleton.h"
#include "pthread.h"
#include <queue>
#include <vector>
#include "NetCommon.h"
#include "NetConnetionInterface.h"
#include "NetMsgFilter.h"

NS_GAME_FRM_BEGIN


typedef Singleton<NetManagerImpl> NetManager;
typedef std::queue<PtrNetAction> NetActionQueueType;
typedef std::queue<PtrNetNotify> NetNotifyQueueType;

class NetManagerImpl
{
public:
    NetManagerImpl();
    virtual ~NetManagerImpl();

    bool setupLoginServer(const std::string& ip,int port);
    bool setupGameServer(const std::string& ip,int port);

    void start();
    void stop();

    void changeNetState(int state);
    int getNetState() const { return m_netState;}

    PtrNetNotify pickNotify();
    void appendNotify(const NetNotifyEnum action);
    void appendNotify(PtrNetNotify notify);

    PtrNetAction pickNetAction();
    void appendAction(PtrNetAction action);

  const NetConfig& getNetLoginServerConfig() const { return m_netLoginServerConfig; }
  const NetConfig& getNetGameServerConfig() const { return m_netGameServerConfig; }

private:
    int m_netState;
    NetConfig m_netLoginServerConfig;
    NetConfig m_netGameServerConfig;
    NetActionQueueType m_netAction;

    NetNotifyQueueType m_netNotify;
    NetConnetionInterface* pConnection;

    bool checkNetState(int state) const;

};



NS_GAME_FRM_END

#endif //_H_NETMANAGER_H_