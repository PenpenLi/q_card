/********************************************************************
	created:	2014/01/17
	created:	17:1:2014   13:41
	file base:	NetConnectionImpl_CSSocket
	file ext:	cpp
	author:    Kevin	
*********************************************************************/


#include "NetConnectionImpl_CSSocket.h"
#include "NetRingBuff.h"

#ifdef WIN32
#pragma comment(lib,"Wsock32.lib") //at windows system driver
#endif

NS_GAME_FRM_BEGIN

bool isValid(const int error)
{
    if(error != CSimpleSocket::SocketSuccess 
    && error != CSimpleSocket::SocketEwouldblock )
    {
        LOG("Socket error,errroCode:%d",error);
        //assert(false);
        return false;
    }

    return true;
}

static void* _connectToLoginServer(void* _pData)
{
    NetThreadData* pData = static_cast<NetThreadData*>(_pData);
    NetManagerImpl* pInstance = static_cast<NetManagerImpl*>(pData->pInstance);
    const NetConfig& config = pInstance->getNetLoginServerConfig();
    bool ret;
    CActiveSocket client; //init one socket begin
    ret = client.Initialize();
    _csassert(ret);
    ret = client.SetNonblocking();
    _csassert(ret);
    client.SetConnectTimeout(5);
    ret = client.SetReceiveTimeout(15);
    _csassert(ret);
    ret = client.SetSendTimeout(10);
    _csassert(ret);

    LOG("[ConnectToLoginServer] Prepare to connect login server[ip:%s,port:%d].",config.serverAddr.c_str(),config.port);
    int error = CSimpleSocket::SocketSuccess;

    if (client.Open((uint8 *)(config.serverAddr.c_str()), config.port))
    {
        LOG("[ConnectToLoginServer] Connected login server,waiting for response.");

        NetRingBuff buff;
        bool active = true;
        
        while (active) 
        {
            if(client.Select(0,30))
            {
                // read data
                while(client.Receive(MAX_RECV_BUFF_SIZE) > 0)
                {
                    buff.fill((char*)client.GetData(), client.GetBytesReceived());
                }
                
                if(buff.hasResponse())
                {
                    LOG("[ConnectToLoginServer] Received game server information.");
                    pInstance->changeNetState(kNetStateConnectedLoginServer);
                    PtrNetNotify notify(new NetNotify());
                    buff.pickResponse(kNetNotifyConnectedLoginServer,notify);
                    pInstance->appendNotify(notify); //pick by Lua in net loop(Timer) 
                    active = false;
                }
                
                error = client.GetSocketError();
                if( !isValid(error) )
                {
                    break;
                }
            }
        }
    }
    else
    {
        error = client.GetSocketError();
    }

    if( !isValid(error))
    {
        LOG("[ConnectToLoginServer] Connect to login server failed.Reason:%d",error);
        pInstance->changeNetState(kNetStateNone);
        pInstance->appendNotify(kNetNotifyConnectingLoginServerFailed);
    }

    client.Close();

    return NULL;
}

static void* _connectToGameServer(void* _pData)
{
    NetThreadData* pData = static_cast<NetThreadData*>(_pData);
    NetManagerImpl* pInstance = static_cast<NetManagerImpl*>(pData->pInstance);
    const NetConfig& config = pInstance->getNetGameServerConfig();
  
    CActiveSocket client;
    client.Initialize();
    client.SetNonblocking();
    client.SetConnectTimeout(5);
    bool ret = client.SetReceiveTimeout(5);
    assert(ret);
    ret = client.SetSendTimeout(5);
    assert(ret);

    LOG("[ConnectToGameServer] Prepare to connect game server.[ip:%s,port:%d].",config.serverAddr.c_str(),config.port);
    int error = CSimpleSocket::SocketSuccess;
    bool isOpened = false;
    
    if (client.Open((uint8 *)(config.serverAddr.c_str()), config.port))
    {
        LOG("[ConnectToGameServer] Connected game server,start read & write thread.");
        pInstance->changeNetState(kNetStateConnectedGameServer);
        pInstance->appendNotify(kNetNotifyConnectedGameServer);
        isOpened = true;

        NetRingBuff buff;

        while (pInstance->getNetState() != kNetStateDisconnectingFromGameServer) 
        {
            error = client.GetSocketError();
            if( !isValid(error) )
            {
                LOG("[ConnectToGameServer] Reading or writing game server failed.Reason:%d",error);
                //pInstance->changeNetState(kNetStateDisconnectedFromGameServer);
                break;
            }
            
            if(client.Select(0,30))
            {
                // read data 
                while(client.Receive(MAX_RECV_BUFF_SIZE) > 0)
                {
                    buff.fill((char*)client.GetData(), client.GetBytesReceived());
                }
                
                while(buff.hasResponse())
                {
                    PtrNetNotify notify(new NetNotify());
                    buff.pickResponse(kNetNotifyOnResponse,notify);
                    pInstance->appendNotify(notify);
                }
                
                error = client.GetSocketError();
                if( !isValid(error) )
                {
                  break;
                }
                
                // send
                PtrNetAction action = pInstance->pickNetAction();
                while(action && isValid(error))
                {
                    const int total = action->szPkg;
                    assert(total != 0);
                    int szSent = 0;
                    while(szSent != total)
                    {
                        assert(szSent <= total);
                        int size = client.Send((const uint8*)action->pData + szSent,total - szSent);
                        if(size > 0)
                        {
                            szSent += size;
                        }
                        else
                        {
                            error = client.GetSocketError();
                            break;
                        }
                    }
                    action = pInstance->pickNetAction();
                }
                
                if (!action)
                {
                #ifdef WIN32
                    Sleep(30);
                #else
                    usleep(30000); //30 microsecond
                #endif
                }

                if( !isValid(error) )
                {
                    LOG("[ConnectToGameServer] Reading or writing game server failed.Reason:%d",error);
                    break;
                }
            }            
        } 
    }
    else
    {
        // Open failed
        error = client.GetSocketError();
    }

    client.Close();
    //client.Shutdown(CSimpleSocket::Both);
    
    if(isOpened)
    {
        pInstance->changeNetState(kNetStateDisconnectedFromGameServer);
        pInstance->appendNotify(kNetNotifyDisconnect);
    }
    else
    {
        if(error != CSimpleSocket::SocketSuccess)
        {
            LOG("[ConnectToGameServer] Connect to game server failed.Reason:%d",error);
            pInstance->changeNetState(kNetStateConnectedLoginServer);
            pInstance->appendNotify(kNetNotifyConnectingGameServerFailed);
        }
    }
    return NULL;
}


NetConnectionImpl_CSSocket::NetConnectionImpl_CSSocket()
{

}

NetConnectionImpl_CSSocket::~NetConnectionImpl_CSSocket()
{

}

void NetConnectionImpl_CSSocket::connectToLoginServer(const std::string& ip,int port,NetManagerImpl* pInstance)
{
    static NetThreadData data;
    
    data.pInstance = pInstance;
    memset(&m_loginThreadId,0,sizeof(m_loginThreadId));
    pthread_create(&m_loginThreadId, 0, _connectToLoginServer, &data);
}

void NetConnectionImpl_CSSocket::connectToGameServer(const std::string& ip,int port,NetManagerImpl* pInstance)
{
    static NetThreadData data;
    
    data.pInstance = pInstance;
    memset(&m_gameThreadId,0,sizeof(m_gameThreadId));
    pthread_create(&m_gameThreadId, 0, _connectToGameServer, &data);
}

bool NetConnectionImpl_CSSocket::purge(NetManagerImpl* pInstance)
{
    if(pInstance->getNetState() == kNetStateConnectingLoginServer)
    {
        pthread_join(m_loginThreadId,NULL); //waiting for close thread
    }
    else if(pInstance->getNetState() == kNetStateConnectedGameServer)
    {
        pInstance->changeNetState(kNetStateDisconnectingFromGameServer);
        pthread_join(m_gameThreadId,NULL);
    }
    
    return true;
}

NS_GAME_FRM_END //namespace
