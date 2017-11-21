/********************************************************************
	created:	2014/01/17
	created:	17:1:2014   13:35
	file base:	NetConnetionInterface
	file ext:	h
	author:		Kevin
	
*********************************************************************/

#ifndef _H_NETCONNETIONINTERFACE_H_  
#define _H_NETCONNETIONINTERFACE_H_  

#include "Common/CommonDefine.h"
#include <string>

NS_GAME_FRM_BEGIN

class NetManagerImpl;

class NetConnetionInterface
{
public:
    virtual ~NetConnetionInterface(){}
    virtual void connectToLoginServer(const std::string& ip,int port,NetManagerImpl* pInstance) = 0;
    virtual void connectToGameServer(const std::string& ip,int port,NetManagerImpl* pInstance) = 0;
    virtual bool purge(NetManagerImpl* pInstance) = 0;
};

NS_GAME_FRM_END //namespace


#endif //_H_NETCONNETIONINTERFACE_H_  