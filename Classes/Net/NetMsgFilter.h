/********************************************************************
	created:	2014/01/17
	created:	17:1:2014   17:08
	file base:	NetMsgFilter
	file ext:	h
	author:		Kevin
	
*********************************************************************/

#ifndef _H_NETMSGFILTER_H_  
#define _H_NETMSGFILTER_H_  

#include "Common/CommonDefine.h"
#include "NetCommon.h"

NS_GAME_FRM_BEGIN

class NetManagerImpl;

namespace NetMsgFilter
{
  extern bool filter(int msgId,NetManagerImpl* pInstance);


}



NS_GAME_FRM_END //namespace


#endif //_H_NETMSGFILTER_H_  