/********************************************************************
	created:	2014/01/17
	created:	17:1:2014   13:41
	file base:	NetConnectionImpl_CSSocket
	file ext:	cpp
	author:    Kevin	
*********************************************************************/

#ifndef _H_NETCONNECTIONIMPL_CSSOCKET_H_  
#define _H_NETCONNECTIONIMPL_CSSOCKET_H_  

#include "Common/CommonDefine.h"
#include "NetConnetionInterface.h"
#include "pthread.h"

NS_GAME_FRM_BEGIN

class NetConnectionImpl_CSSocket : public NetConnetionInterface
{
public:
    NetConnectionImpl_CSSocket();
    virtual ~NetConnectionImpl_CSSocket();
    virtual void connectToLoginServer(const std::string& ip,int port,NetManagerImpl* pInstance);
    virtual void connectToGameServer(const std::string& ip,int port,NetManagerImpl* pInstance);
    virtual bool purge(NetManagerImpl* pInstance);

private:
    //bool m_isConnectingLoginServer;
    //bool m_isConnectingGameServer;
    pthread_t m_loginThreadId;
    pthread_t m_gameThreadId;
};

NS_GAME_FRM_END //namespace


#endif //_H_NETCONNECTIONIMPL_CSSOCKET_H_  