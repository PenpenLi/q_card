#include "NetManager.h"
#include "Common/CAutoLock.h"
//#include "common/base64.h"
#include "NetConnectionImpl_CSSocket.h"

NS_GAME_FRM_BEGIN

static CAutoLockMutex sNetStateLock;

static CAutoLockMutex sNetActionLock;

static CAutoLockMutex sNetNotifyLock;

static CAutoLockMutex sNetPkgLock;

static CAutoLockMutex sNetSocketLock;


NetManagerImpl::NetManagerImpl()
{
    
    m_netState = kNetStateNone;
    pthread_mutex_init(&sNetStateLock, NULL);
    pthread_mutex_init(&sNetActionLock, NULL);
    pthread_mutex_init(&sNetNotifyLock, NULL);
    pthread_mutex_init(&sNetPkgLock, NULL);
    pthread_mutex_init(&sNetSocketLock, NULL);
    
    pConnection = new NetConnectionImpl_CSSocket;
}

NetManagerImpl::~NetManagerImpl()
{
    pthread_mutex_destroy(&sNetStateLock);
    pthread_mutex_destroy(&sNetActionLock);
    pthread_mutex_destroy(&sNetNotifyLock);
    pthread_mutex_destroy(&sNetPkgLock);
    pthread_mutex_destroy(&sNetSocketLock);
    delete pConnection;
}



PtrNetNotify NetManagerImpl::pickNotify()
{
    CAutoLock lock(&sNetNotifyLock);
    if(!m_netNotify.empty())
    {
        const PtrNetNotify notify = m_netNotify.front();
        m_netNotify.pop();
        return notify;
    }

    return PtrNetNotify();
}

void NetManagerImpl::appendNotify(const NetNotifyEnum action)
{
    CAutoLock lock(&sNetNotifyLock);
    m_netNotify.push(PtrNetNotify(new NetNotify(action)));
}

void NetManagerImpl::appendNotify(PtrNetNotify notify)
{
    CAutoLock lock(&sNetNotifyLock);
    m_netNotify.push(notify);
}

PtrNetAction NetManagerImpl::pickNetAction()
{
    CAutoLock lock(&sNetActionLock);

    if(!m_netAction.empty())
    {
        const PtrNetAction action = m_netAction.front();
        m_netAction.pop();

        return action;
    }

    return PtrNetAction();
}

void NetManagerImpl::appendAction(PtrNetAction action)
{
    switch(action->action)
    {
        case kNetActionToConnectLoginServer:
        {
            if( checkNetState(kNetStateNone) )
            {
                pConnection->connectToLoginServer(m_netLoginServerConfig.serverAddr,m_netLoginServerConfig.port,this);
            }
            else if(checkNetState(kNetStateConnectedLoginServer) )
            {
                pConnection->connectToLoginServer(m_netLoginServerConfig.serverAddr,m_netLoginServerConfig.port,this);
            }
            else if(checkNetState(kNetStateDisconnectedFromGameServer))
            {
                pConnection->connectToLoginServer(m_netLoginServerConfig.serverAddr,m_netLoginServerConfig.port,this);
            }
            break;
        }
        
        case kNetActionToConnectGameServer:
        {
            if( checkNetState(kNetStateConnectedLoginServer) )
            {
                // login to game server
                m_netState = kNetStateConnectingLoginServer;
                pConnection->connectToGameServer(m_netGameServerConfig.serverAddr,m_netGameServerConfig.port,this);
            }
            else if (checkNetState(kNetStateDisconnectedFromGameServer))
            {
                m_netState = kNetStateConnectingGameServer;
                pConnection->connectToGameServer(m_netGameServerConfig.serverAddr,m_netGameServerConfig.port,this);
            }
            break;
        }
        
        case kNetActionToRequest:
        {
            // for local fight
            if( NetMsgFilter::filter(action->msgId,this))
            {
                // do nothing
            }
            else
            {
                if( checkNetState(kNetStateConnectedGameServer) )
                {
                    CAutoLock lock(&sNetActionLock);
                    m_netAction.push(action);
                }
            }
            break;
        }
        
        case kNetActionToDisconnect:
        {
            if( checkNetState(kNetStateConnectedGameServer))
            {
                changeNetState(kNetStateDisconnectingFromGameServer);			
            }
            break;
        }
        
        default:
        {
            LOG("Can not handle net action:%d", action->action);
            break;
        }
    }
}


bool NetManagerImpl::setupLoginServer(const std::string& ip,int port)
{
    m_netLoginServerConfig.serverAddr = ip;
    m_netLoginServerConfig.port = port;
    return true;
}

bool NetManagerImpl::setupGameServer(const std::string& ip,int port)
{
    m_netGameServerConfig.serverAddr = ip;
    m_netGameServerConfig.port = port;
    return true;
}


void NetManagerImpl::start()
{
    
    
}

void NetManagerImpl::stop()
{
    pConnection->purge(this);  
    LOG("stop the network");
}


bool NetManagerImpl::checkNetState(int state) const
{
    CAutoLock lock(&sNetStateLock);

    if( m_netState == state )
    {
        return true;
    }
    else
    {
        LOG("State not match,current state:[%d],expect state:[%d]",m_netState,state);
        //assert(false);
    }
    
    return false;
}


void NetManagerImpl::changeNetState(int state)
{
    CAutoLock lock(&sNetStateLock);

    LOG("change net state from [%d] to [%d]",m_netState,state);
    m_netState = state;
}




NS_GAME_FRM_END